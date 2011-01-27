package com.seesaw.player.batchEventService {
import com.seesaw.player.PlayerConstants;
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.ads.AdState;
import com.seesaw.player.batchEventService.events.ContentEvent;
import com.seesaw.player.batchEventService.events.ContentTypes;
import com.seesaw.player.batchEventService.events.CumulativeDurationEvent;
import com.seesaw.player.batchEventService.events.UserEvent;
import com.seesaw.player.batchEventService.events.UserEventTypes;
import com.seesaw.player.batchEventService.events.ViewEvent;
import com.seesaw.player.batchEventService.events.manager.EventsManager;
import com.seesaw.player.batchEventService.events.manager.EventsManagerImpl;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.namespaces.contentinfo;
import com.seesaw.player.services.ResumeService;

import flash.events.TimerEvent;
import flash.utils.Timer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.BufferEvent;
import org.osmf.events.DisplayObjectEvent;
import org.osmf.events.DynamicStreamEvent;
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MetadataEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
import org.osmf.events.TimeEvent;
import org.osmf.layout.LayoutMetadata;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.net.StreamingURLResource;
import org.osmf.traits.BufferTrait;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.DynamicStreamTrait;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class BatchEventService extends ProxyElement {

    use namespace contentinfo;

    private static const CUMULATIVE_DURATION_MONITOR_TIMER_DELAY_INTERVAL = 500;
    private static const CUMULATIVE_DURATION_FLUSH_DELAY_INTERVAL:int = 300000;

    private var userEventId:int = 0;
    private var contentEventId:int = 0;

    private var logger:ILogger = LoggerFactory.getClassLogger(BatchEventService);

    private var resumeService:ResumeService;

    private var cumulativeDurationFlushTimer:Timer;
    private var cumulativeDurationCount:Number;
    private var cumulativeDurationMonitor:Timer;

    private var seeking:Boolean;

    private var transactionItemId:uint;
    private var serverTimeStamp:uint;
    private var mainAssetId:uint;
    private var sectionCount:uint;
    private var programmeId:uint;
    private var userId:uint;
    private var anonymousUserId:uint;

    private var contentViewingSequenceNumber:int = 0;
    private var currentAdBreakSequenceNumber:int = 0;

    private var batchEventURL:String;
    private var cumulativeDurationURL:String;

    private var playingMainContent:Boolean;

    // TODO these values are hardcoded - waiting on ads to be fully implemented
    private var isPopupInteractive:Boolean = false;
    private var isOverlayInteractive:Boolean = false;
    private var campaignId:int;
    private var contentUrl:String;
    private var contentDuration:int = 5;

    private var eventsManager:EventsManager;
    private var tooSlowTimer:Timer;
    private var mainContentCount:int;
    private var playable:PlayTrait;
    private var loadable:LoadTrait;
    private var adMetadata:Metadata;
    private var SMILMetadata:Metadata;
    private var playerMetadata:Metadata;
    private var dynamicStream:DynamicStreamTrait;
    private var adMode:String;
    private var viewEvent:ViewEvent;
    private var userEvent:UserEvent;
    private var availabilityType:String;

    public function BatchEventService(proxiedElement:MediaElement = null) {
        var provider:ObjectProvider = ObjectProvider.getInstance();
        resumeService = provider.getObject(ResumeService);
        if (resumeService == null) {
            throw ArgumentError("no resume service implementation provided");
        }
    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            super.proxiedElement = proxiedElement;

            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
            proxiedElement.removeEventListener(MediaElementEvent.METADATA_ADD, onMetaDataAdd);
            proxiedElement.removeEventListener(MediaElementEvent.METADATA_REMOVE, onMetaDataRemove);

            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
            proxiedElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetaDataAdd);
            proxiedElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onMetaDataRemove);

            cumulativeDurationCount = 0;
            cumulativeDurationMonitor = new Timer(CUMULATIVE_DURATION_MONITOR_TIMER_DELAY_INTERVAL, 0);
            cumulativeDurationMonitor.addEventListener(TimerEvent.TIMER, incrementCumulativeDurationCounter);
            cumulativeDurationMonitor.start();

            cumulativeDurationFlushTimer = new Timer(CUMULATIVE_DURATION_FLUSH_DELAY_INTERVAL, 0);
            cumulativeDurationFlushTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
            cumulativeDurationFlushTimer.start();

            playerMetadata = proxiedElement.resource.getMetadataValue(PlayerConstants.METADATA_NAMESPACE) as Metadata;
            playerMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, playerMetaChanged);
             playerMetadata.addEventListener(MetadataEvent.VALUE_ADD, playerMetaChanged);
            playerMetadata.addEventListener(MediaElementEvent.METADATA_ADD, playerMetaChanged);


            if (playerMetadata) {
                transactionItemId = playerMetadata.getValue("videoInfo").transactionItemId;
                serverTimeStamp = playerMetadata.getValue("videoInfo").serverTimeStamp;
                mainAssetId = playerMetadata.getValue("videoInfo").mainAssetID;
                batchEventURL = playerMetadata.getValue("contentInfo").batchEventService;
                cumulativeDurationURL = playerMetadata.getValue("contentInfo").cumulativeDurationService;
                sectionCount = playerMetadata.getValue("videoInfo").sectionCount;
                userId = playerMetadata.getValue("contentInfo").userId;
                anonymousUserId = playerMetadata.getValue("contentInfo").anonymousUserId;
                programmeId = playerMetadata.getValue("contentInfo").programme;
                adMode = playerMetadata.getValue("contentInfo").adMode;
                availabilityType = playerMetadata.getValue("videoInfo").availabilityType;

                viewEvent = new ViewEvent(transactionItemId, serverTimeStamp, sectionCount, mainAssetId, userId, anonymousUserId);

                var number:Number = resumeService.getResumeCookie();
                if (number == 0) {
                    userEvent = buildAndReturnUserEvent(UserEventTypes.AUTO_PLAY);
                } else {
                    userEvent = buildAndReturnUserEvent(UserEventTypes.AUTO_RESUME);
                }
                if (adMode != AdMetadata.LR_AD_TYPE || AdMetadata.AUDITUDE_AD_TYPE) {
                    eventsManager = new EventsManagerImpl(viewEvent, availabilityType, batchEventURL, cumulativeDurationURL);
                    eventsManager.addUserEvent(userEvent);
                    eventsManager.flushAll();
                }
            }
        }
    }

    private function playerMetaChanged(event:MetadataEvent):void {
        //TODO  lIVERAIL METDATA CHANGE AGAINST THE SECTIONCOUNT BEFORE THIS IS FIRED......
        if (event.key == AdMetadata.AD_STATE) {
            eventsManager = new EventsManagerImpl(viewEvent, availabilityType, batchEventURL, cumulativeDurationURL);
            eventsManager.addUserEvent(userEvent);
            eventsManager.flushAll();
        }
    }


    private function incrementCumulativeDurationCounter(event:TimerEvent):void {
        cumulativeDurationCount += CUMULATIVE_DURATION_MONITOR_TIMER_DELAY_INTERVAL;
    }

    private function onMetaDataRemove(event:MediaElementEvent):void {
        if (event.namespaceURL == PlayerConstants.CONTROL_BAR_METADATA) {
            var metadata:Metadata = event.target.getMetadata(PlayerConstants.CONTROL_BAR_METADATA);
            metadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onControlBarMetadataChange);
            metadata.removeEventListener(MetadataEvent.VALUE_ADD, onControlBarMetadataChange);

        } else if (event.namespaceURL == AdMetadata.AD_NAMESPACE) {
            adMetadata = event.target.getMetadata(AdMetadata.AD_NAMESPACE);
            adMetadata.removeEventListener(MetadataEvent.VALUE_ADD, onAdsMetaDataAdd);
            adMetadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onAdsMetaDataChange);
        }
    }

    private function onMetaDataAdd(event:MediaElementEvent):void {
        var metadata:Metadata;
        if (event.namespaceURL == PlayerConstants.CONTROL_BAR_METADATA) {
            metadata = event.target.getMetadata(PlayerConstants.CONTROL_BAR_METADATA);
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onControlBarMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onControlBarMetadataChange);

        } else if (event.namespaceURL == AdMetadata.AD_NAMESPACE) {
            adMetadata = event.target.getMetadata(AdMetadata.AD_NAMESPACE);
            adMetadata.addEventListener(MetadataEvent.VALUE_ADD, onAdsMetaDataAdd);
            adMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, onAdsMetaDataChange);

        } else if (event.namespaceURL == PlayerConstants.SMIL_METADATA_NS) {
            // TODO this seems to be the only way currently to detect main content is being loaded and played
            // TODO there is a bug outstanding where stings are appearing as mainContent
            SMILMetadata = event.target.getMetadata(PlayerConstants.SMIL_METADATA_NS);

            var contentType:String = SMILMetadata.getValue(PlayerConstants.CONTENT_TYPE);
            switch (contentType) {
                case PlayerConstants.MAIN_CONTENT_ID :
                    playingMainContent = true;
                    break;
                case PlayerConstants.STING_CONTENT_ID :
                    playingMainContent = false;
                    break;
                case PlayerConstants.AD_CONTENT_ID :
                    playingMainContent = false;
                    break;
            }

        } else if (event.namespaceURL == "http://www.seesaw.com/netstatus/metadata") {
            metadata = event.target.getMetadata("http://www.seesaw.com/netstatus/metadata");
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onNetstatusMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onNetstatusMetadataChange);

        } else if (event.namespaceURL == LayoutMetadata.LAYOUT_NAMESPACE) {
            metadata = event.target.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE);
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onLayoutMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onLayoutMetadataChange);

        }
    }

    private function onLayoutMetadataChange(event:MetadataEvent):void {
        trace(event);
    }

    private function onNetstatusMetadataChange(event:MetadataEvent):void {
        if (event.value == "NetConnection.Connect.NetworkChange")
            eventsManager.addUserEvent(buildAndReturnUserEvent(UserEventTypes.CONNECTION_CLOSED));

        if (event.value == "NetConnection.Connect.Reconnection") // Todo this event does not exist yet...
        {
            eventsManager.addUserEvent(buildAndReturnUserEvent(UserEventTypes.CONNECTION_RESTART));
            eventsManager.flushAll();        /// since we have just lost connection and reconnected we want to force an event record..

        }
    }

    private function onAdsMetaDataAdd(event:MetadataEvent):void {
        if (event.key == AdMetadata.AD_STATE) {
            AdMetaEvaluation(event.value);
        } else {
            AdMetaEvaluation(event.key);
        }
    }

    private function onAdsMetaDataChange(event:MetadataEvent):void {
        if (event.key == AdMetadata.AD_STATE) {
            AdMetaEvaluation(event.value);
        } else {
            AdMetaEvaluation(event.key);
        }
    }

    private function AdMetaEvaluation(value:String):void {
        if (value == AdState.AD_BREAK_COMPLETE) {
            playingMainContent = true;
            contentViewingSequenceNumber++;
            eventsManager.addContentEvent(buildAndReturnContentEvent(ContentTypes.MAIN_CONTENT));
            eventsManager.flushAll();

        } else if (value == AdState.AD_BREAK_START) {
            playingMainContent = false;
            contentViewingSequenceNumber++;
            currentAdBreakSequenceNumber++;
            eventsManager.addContentEvent(buildAndReturnContentEvent(ContentTypes.AD_BREAK));

        } else if (value == AdMetadata.CLICK_THRU) {
            eventsManager.addUserEvent(buildAndReturnUserEvent(UserEventTypes.CLICK));
        }
    }

    private function onControlBarMetadataChange(event:MetadataEvent):void {
        var userEventType:String;
        if (event.key == "subtitlesVisible" && event.type != MetadataEvent.VALUE_ADD) {
            if (event.value) {
                userEventType = UserEventTypes.SUBTITLES_ON;
            } else {
                userEventType = UserEventTypes.SUBTITLES_OFF;
            }
        } else if (event.key == "fullScreen" && event.type != MetadataEvent.VALUE_ADD) {
            if (event.value) {
                userEventType = UserEventTypes.ENTER_FULL_SCREEN;
            } else {
                userEventType = UserEventTypes.EXIT_FULL_SCREEN;
            }
        } else if (event.key == "userClickState") {
            if (event.value == "playing") {
                userEventType = UserEventTypes.PLAY;
            }
            if (event.value == "pause") {
                userEventType = UserEventTypes.PAUSE;
            }
        }
        if (userEventType != null) {
            eventsManager.addUserEvent(buildAndReturnUserEvent(userEventType));
        }
    }

    private function onTimerTick(event:TimerEvent):void {
        eventsManager.flushCumulativeDuration(new CumulativeDurationEvent(programmeId, transactionItemId));
    }

    private function onBufferingChange(event:BufferEvent):void {
        if (playingMainContent) {
            if (event.buffering) {
                tooSlowTimer = new Timer(2500, 1);
                tooSlowTimer.start();
                tooSlowTimer.addEventListener(TimerEvent.TIMER_COMPLETE, bufferShowEvent);
            } else {
                tooSlowTimer.stop();
            }
        }
    }

    private function bufferShowEvent(event:TimerEvent):void {
        eventsManager.addUserEvent(buildAndReturnUserEvent(UserEventTypes.BUFFERING));
    }

    private function processTrait(traitType:String, added:Boolean):void {
        switch (traitType) {
            case MediaTraitType.BUFFER:
                toggleBufferListeners(added);
                break;
            case MediaTraitType.SEEK:
                toggleSeekListeners(added);
                break;
            case MediaTraitType.TIME:
                toggleTimeListeners(added);
                break;
            case MediaTraitType.PLAY:
                togglePlayListeners(added);
                break;
            case MediaTraitType.LOAD:
                toggleLoadListeners(added);
                break;
            case MediaTraitType.DYNAMIC_STREAM:
                toggleDynamicStreamListeners(added);
                break;
            case MediaTraitType.DISPLAY_OBJECT:
                toggleDisplayListeners(added);
                break;
        }
    }


    private function toggleDisplayListeners(added:Boolean):void {
        var display:DisplayObjectTrait = proxiedElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;

        if (display) {
            display.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onDisplayObjectChange);
            display.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
        } else {
            display.removeEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onDisplayObjectChange);
            display.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
        }
    }

    private function onMediaSizeChange(event:DisplayObjectEvent):void {
        logger.debug("On Media Size Change old:{0}x{1} new:{2}x{3}", event.oldHeight, event.oldWidth, event.newHeight, event.newWidth);
    }

    private function onDisplayObjectChange(event:DisplayObjectEvent):void {
        logger.debug("On Display Object Change old:{0} new:{1}", event.oldDisplayObject, event.newDisplayObject)
    }


    private function togglePlayListeners(added:Boolean):void {
        playable = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playable) {
            if (added) {
                playable.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
            }
            else {
                playable.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
            }
        }
    }

    private function toggleDynamicStreamListeners(added:Boolean):void {
        dynamicStream = proxiedElement.getTrait(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait;
        if (dynamicStream) {
            if (added) {
                dynamicStream.addEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, onAutoSwitchChange);
                dynamicStream.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onSwitchingChange);
            } else {
                dynamicStream.removeEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, onAutoSwitchChange);
                dynamicStream.removeEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onSwitchingChange);
            }
        }
    }

    private function toggleLoadListeners(added:Boolean):void {
        loadable = proxiedElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
        if (loadable) {


            trace(loadable.loadState);
            /* loadable.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadableStateChange);
             loadable.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);*/


        }
    }

    private function onAutoSwitchChange(event:DynamicStreamEvent):void {
        trace(event.autoSwitch);
    }

    private function onSwitchingChange(event:DynamicStreamEvent):void {
        var trait:DynamicStreamTrait = getTrait(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait;
        if (trait && trait.switching) {
            trace("Switching dynamic stream: bitrate = {0}", trait.getBitrateForIndex(trait.currentIndex));
        }
    }

    private function onBytesTotalChange(event:LoadEvent):void {
    }

    private function onLoadableStateChange(event:LoadEvent):void {
        trace(event);
    }


    private function onPlayStateChange(event:PlayEvent):void {
        if (playingMainContent) {
            switch (event.playState) {
                case PlayState.PAUSED:
                    cumulativeDurationMonitor.stop();
                    break;
                case PlayState.PLAYING:
                    if (!cumulativeDurationMonitor.running) {
                        cumulativeDurationMonitor.start();
                    }
                    break;
                case PlayState.STOPPED:
                    if (cumulativeDurationMonitor.running) {
                        cumulativeDurationMonitor.stop();
                    }
                    break;
            }
        }
    }

    private function onTraitAdd(event:MediaElementEvent):void {
        //   processTrait(event.traitType, true);
        var traitType:String;
        for each (traitType in event.target.traitTypes) {
            processTrait(traitType, true);
        }
    }

    private function onTraitRemove(event:MediaElementEvent):void {
       /// processTrait(event.traitType, false);
         var traitType:String;
        for each (traitType in event.target.traitTypes) {
            processTrait(traitType, false);
        }
    }

    private function toggleBufferListeners(added:Boolean):void {
        var buffer:BufferTrait = proxiedElement.getTrait(MediaTraitType.BUFFER) as BufferTrait;
        if (buffer) {
            if (added) {
                buffer.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
            }
            else {
                buffer.removeEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
            }
        }
    }

    private function toggleSeekListeners(added:Boolean):void {
        var seek:SeekTrait = proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
        if (seek) {
            seek.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
        } else {
            seek.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
        }
    }


    private function onSeekingChange(event:SeekEvent):void {
        if (playingMainContent) {
            if (event.seeking) {
                if (!seeking) {
                    cumulativeDurationMonitor.stop();
                    eventsManager.addUserEvent(buildAndReturnUserEvent(UserEventTypes.SCRUB));
                    seeking = event.seeking;
                }
            } else {
                seeking = event.seeking;
            }
        }
        logger.debug("------------On Seek Change:{0}", event.seeking);
    }

    private function toggleTimeListeners(added:Boolean):void {
        var time:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;
        if (time) {
            time.addEventListener(TimeEvent.COMPLETE, onComplete);
            time.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
        } else {
            time.removeEventListener(TimeEvent.COMPLETE, onComplete);
            time.removeEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
        }
    }

    private function onComplete(event:TimeEvent):void {

        if (mainContentCount * 2 == sectionCount || (sectionCount == 1 && availabilityType == "PREVIEW")) {
            eventsManager.addUserEvent(buildAndReturnUserEvent(UserEventTypes.END));
            eventsManager.flushAll();
            /// todo reinstate this method when we get section counts in...
            // playerMetadata.addValue(PlayerConstants.DESTROY, true);   //// main content has finished so we need to reInit the Player... This might not be the best location for this event, but we can look at moving it in the future.
        }
    }

    private function onDurationChange(event:TimeEvent):void {
        ///MetaDataAdded of the MediaElementEvent, fires 3 times, so wiring this to the duration change seems to be the next most reliable event....
        if (playingMainContent) {
            defineContentUrl(false);
            contentViewingSequenceNumber++;
            mainContentCount++;
            eventsManager.addContentEvent(buildAndReturnContentEvent(ContentTypes.MAIN_CONTENT));
            eventsManager.flushAll();
        } else if (!adMetadata) {
            defineContentUrl(true);
            eventsManager.addContentEvent(buildAndReturnContentEvent(ContentTypes.AD_BREAK));
        }
    }

    private function defineContentUrl(checkResource:Boolean):void {
        if (loadable && checkResource) {
            var streamingUrlResource:StreamingURLResource = loadable.resource as StreamingURLResource;
            if (streamingUrlResource) {
                contentUrl = streamingUrlResource.url;
            }
        } else if (!adMetadata) {
            contentUrl = "mainResource";
        } else {

        }
    }

    private function incrementAndGetUserEventId():int {
        userEventId++;
        return userEventId;
    }

    private function incrementAndGetContentEventId():int {
        contentEventId++;
        return contentEventId;
    }

    private function buildAndReturnUserEvent(userEventType:String):UserEvent {
        return new UserEvent(incrementAndGetUserEventId(), cumulativeDurationCount, userEventType, programmeId);
    }

    private function buildAndReturnContentEvent(contentType:String):ContentEvent {
        return new ContentEvent(isPopupInteractive, mainAssetId, new Date(), isOverlayInteractive, contentViewingSequenceNumber, incrementAndGetContentEventId(), campaignId, cumulativeDurationCount, userEventId, contentDuration, contentType, currentAdBreakSequenceNumber, contentUrl);
    }
}
}