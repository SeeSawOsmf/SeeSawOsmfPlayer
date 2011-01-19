package com.seesaw.player.batchEventService {
import com.seesaw.player.PlayerConstants;
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
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MediaErrorEvent;
import org.osmf.events.MetadataEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
import org.osmf.events.TimeEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.traits.BufferTrait;
import org.osmf.traits.LoadState;
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

    private var contentViewingSequenceNumber = 0;
    private var currentAdBreakSequenceNumber = 0;

    private var batchEventURL:String;
    private var cumulativeDurationURL:String;

    private var playingMainContent:Boolean;

    // TODO these values are hardcoded - waiting on ads to be fully implemented
    private var isPopupInteractive:Boolean = false;
    private var isOverlayInteractive:Boolean = false;
    private var campaignId = null;
    private var contentUrl = "http://www.a_dummy_url.com";
    private var contentDuration = 5;

    private var eventsManager:EventsManager;
    private var tooSlowTimer:Timer;

    public function BatchEventService(proxiedElement:MediaElement = null) {
        super(proxiedElement);
        var provider:ObjectProvider = ObjectProvider.getInstance();
        resumeService = provider.getObject(ResumeService);
        addEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadableStateChange);
        if (resumeService == null) {
            throw ArgumentError("no resume service implementation provided");
        }
    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            super.proxiedElement = proxiedElement;
            var traitType:String
            if (proxiedElement != null) {
                toggleTraitListeners(false);
                for each (traitType in proxiedElement.traitTypes) {
                    processTrait(traitType, false);
                }
            }
            if (proxiedElement != null) {
                toggleTraitListeners(true);
                for each (traitType in proxiedElement.traitTypes) {
                    processTrait(traitType, true);
                }
            }

          /*  var setVideoElement: VideoElement =    proxiedElement    as VideoElement;
            if(setVideoElement)
            setVideoElement.client.addHandler(NetStreamCodes.ON_META_DATA, onLoadableStateChange);*/

            cumulativeDurationCount = 0;
            cumulativeDurationMonitor = new Timer(CUMULATIVE_DURATION_MONITOR_TIMER_DELAY_INTERVAL, 0);
            cumulativeDurationMonitor.addEventListener(TimerEvent.TIMER, incrementCumulativeDurationCounter);
            cumulativeDurationMonitor.start();

            cumulativeDurationFlushTimer = new Timer(CUMULATIVE_DURATION_FLUSH_DELAY_INTERVAL, 0);
            cumulativeDurationFlushTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
            cumulativeDurationFlushTimer.start();

            var infoData:Metadata = proxiedElement.resource.getMetadataValue(PlayerConstants.METADATA_NAMESPACE) as Metadata;

            if (infoData) {
                transactionItemId = infoData.getValue("videoInfo").transactionItemId;
                serverTimeStamp = infoData.getValue("videoInfo").serverTimeStamp;
                mainAssetId = infoData.getValue("videoInfo").mainAssetID;
                batchEventURL = infoData.getValue("contentInfo").batchEventService;
                cumulativeDurationURL = infoData.getValue("contentInfo").cumulativeDurationService;
                sectionCount = infoData.getValue("videoInfo").sectionCount;
                userId = infoData.getValue("contentInfo").userId;
                anonymousUserId = infoData.getValue("contentInfo").anonymousUserId;
                programmeId = infoData.getValue("contentInfo").programme;

                var viewEvent:ViewEvent = new ViewEvent(transactionItemId, serverTimeStamp, sectionCount, mainAssetId, userId, anonymousUserId);
                var number:Number = resumeService.getResumeCookie();
                var userEvent:UserEvent;
                if (number == 0) {
                    userEvent = buildAndReturnUserEvent(UserEventTypes.AUTO_PLAY);
                } else {
                    userEvent = buildAndReturnUserEvent(UserEventTypes.AUTO_RESUME);
                }

                eventsManager = new EventsManagerImpl(viewEvent);
                eventsManager.addUserEvent(userEvent);
                eventsManager.flushAll();
            }
        }
    }

    private function toggleTraitListeners(add:Boolean):void {
        if (add) {
            addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
            addEventListener(MediaElementEvent.METADATA_ADD, onMetaDataAdd);
            addEventListener(MediaElementEvent.METADATA_REMOVE, onMetaDataRemove);

        } else {
            removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
            removeEventListener(MediaElementEvent.METADATA_ADD, onMetaDataAdd);
            removeEventListener(MediaElementEvent.METADATA_REMOVE, onMetaDataRemove);
        }
    }

    private function incrementCumulativeDurationCounter(event:TimerEvent):void {
        cumulativeDurationCount += CUMULATIVE_DURATION_MONITOR_TIMER_DELAY_INTERVAL;
    }

    private function onMetaDataRemove(event:MediaElementEvent):void {
        if (event.namespaceURL == "http://www.osmf.org/samples/controlbar/metadata") {
            var metadata:Metadata = event.target.getMetadata("http://www.osmf.org/samples/controlbar/metadata");
            metadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onControlBarMetadataChange);
            metadata.removeEventListener(MetadataEvent.VALUE_ADD, onControlBarMetadataChange);
        } else if (event.namespaceURL == "http://www.seesaw.com/player/ads/1.0") {
            var metadata:Metadata = event.target.getMetadata("http://www.seesaw.com/player/ads/1.0");
            metadata.removeEventListener(MetadataEvent.VALUE_ADD, onAdsMetaDataAdd);
            metadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onAdsMetaDataChange);
        }
    }

    private function onMetaDataAdd(event:MediaElementEvent):void {
        var metadata:Metadata;
        if (event.namespaceURL == "http://www.osmf.org/samples/controlbar/metadata") {
            metadata = event.target.getMetadata("http://www.osmf.org/samples/controlbar/metadata");
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onControlBarMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onControlBarMetadataChange);
        } else if (event.namespaceURL == "http://www.seesaw.com/player/ads/1.0") {
            metadata = event.target.getMetadata("http://www.seesaw.com/player/ads/1.0");
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onAdsMetaDataAdd);
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onAdsMetaDataChange);
        } else if (event.namespaceURL == "http://www.w3.org/ns/SMIL") {
            // TODO this seems to be the only way currently to detect main content is being loaded and played
            // TODO there is a bug outstanding where stings are appearing as mainContent
            metadata = event.target.getMetadata("http://www.w3.org/ns/SMIL");
            var contentType:String = metadata.getValue("contentType");
            switch (contentType) {
                case "mainContent" :
                    playingMainContent = true;
                    contentViewingSequenceNumber++;
                    eventsManager.addContentEvent(buildAndReturnContentEvent(ContentTypes.MAIN_CONTENT));
                    eventsManager.flushAll();
                    break;
                case "sting" :
                    playingMainContent = false;
                    break;
                default : trace("############ unknown content type found in meta data ############### " + contentType)

            }
        }else  if (event.namespaceURL == "http://www.seesaw.com/netstatus/metadata") {
            trace("http://www.seesaw.com/netstatus/metadata");
        }
    }

    private function onAdsMetaDataChange(event:MetadataEvent):void {
        if (event.key == "adState") {
            if (event.value == "stopped") {
                // TODO - this may be duplicated by the onMetaDataAdd event handler - which adds a content event data when SMIL data is added
                playingMainContent = true;
                contentViewingSequenceNumber++;
                eventsManager.addContentEvent(buildAndReturnContentEvent(ContentTypes.MAIN_CONTENT));
                eventsManager.flushAll();
            }
        }
    }

    private function onAdsMetaDataAdd(event:MetadataEvent):void {
        if (event.key == "adState") {
            if (event.value == "started") {
                playingMainContent = false;
                contentViewingSequenceNumber++;
                currentAdBreakSequenceNumber++;
                eventsManager.addContentEvent(buildAndReturnContentEvent(ContentTypes.AD_BREAK));
            }
        }
    }

    private function onControlBarMetadataChange(event:MetadataEvent):void {
        var userEventType:String;
        if (event.key == "subtitlesVisible") {
            if (event.value) {
                userEventType = UserEventTypes.SUBTITLES_ON;
            } else {
                userEventType = UserEventTypes.SUBTITLES_OFF;
            }
        } else if (event.key == "fullScreen") {
            if (event.value) {
                userEventType = UserEventTypes.ENTER_FULL_SCREEN;
            } else {
                userEventType = UserEventTypes.EXIT_FULL_SCREEN;
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
            }else{
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
           /// case   private var playTrait:PlayTrait;
        }
    }

    private function togglePlayListeners(added:Boolean):void {
        var playable:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playable) {
            if (added) {
                playable.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
            }
            else {
                playable.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
            }
        }
    }
    private function toggleLoadListeners(added:Boolean):void {
        var loadable:LoadTrait = proxiedElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
        if (loadable) {
            if (added) {
                proxiedElement.addEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadableStateChange);
               ///proxiedElement.client.addHandler(NetStreamCodes.ON_META_DATA, onLoadableStateChange)
            }
            else {
                loadable.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadableStateChange);
            }
        }
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
        processTrait(event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        processTrait(event.traitType, false);
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


    private function onLoadableStateChange(event:MediaErrorEvent):void {
         switch (event)
         {

            case LoadState.READY:
             /// trace(event.target.resource.loader.netStream);
             /*    var loadedContext:NetLoadedContext = event.loadable.loadedContext as  NetLoadedContext;
                var netStream:NetStream =  loadedContext.stream;*/

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
        logger.debug("On Seek Change:{0}", event.seeking);
    }

    private function toggleTimeListeners(added:Boolean):void {
        var time:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;
        if (time) {
            time.addEventListener(TimeEvent.COMPLETE, onComplete);
        } else {
            time.removeEventListener(TimeEvent.COMPLETE, onComplete);
        }
    }

    private function onComplete(event:TimeEvent):void {
        eventsManager.addUserEvent(buildAndReturnUserEvent(UserEventTypes.END));
        eventsManager.flushAll();
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