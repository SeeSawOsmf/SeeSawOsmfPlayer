/*
 * The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *   The Initial Developer of the Original Code is Arqiva Ltd.
 *   Portions created by Arqiva Limited are Copyright (C) 2010, 2011 Arqiva Limited.
 *   Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe
 * 	Systems Incorporated.
 *   All Rights Reserved.
 *
 *   Contributor(s):  Adobe Systems Incorporated
 */

package com.seesaw.player.batcheventservices {
import com.seesaw.player.PlayerConstants;
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.ads.AdState;
import com.seesaw.player.batcheventservices.events.ContentEvent;
import com.seesaw.player.batcheventservices.events.ContentTypes;
import com.seesaw.player.batcheventservices.events.CumulativeDurationEvent;
import com.seesaw.player.batcheventservices.events.UserEvent;
import com.seesaw.player.batcheventservices.events.UserEventTypes;
import com.seesaw.player.batcheventservices.events.ViewEvent;
import com.seesaw.player.batcheventservices.events.manager.EventsManager;
import com.seesaw.player.batcheventservices.events.manager.EventsManagerImpl;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.namespaces.contentinfo;
import com.seesaw.player.services.ResumeService;
import com.seesaw.player.utils.HelperUtils;

import flash.events.TimerEvent;
import flash.external.ExternalInterface;
import flash.utils.Timer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.BufferEvent;
import org.osmf.events.DynamicStreamEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MetadataEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
import org.osmf.events.TimeEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.net.StreamingURLResource;
import org.osmf.traits.BufferTrait;
import org.osmf.traits.DynamicStreamTrait;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class BatchEventServices extends ProxyElement {

    use namespace contentinfo;

    private static const CUMULATIVE_DURATION_MONITOR_TIMER_DELAY_INTERVAL = 500;
    private static const CUMULATIVE_DURATION_FLUSH_TIMER_MAX = 300000;
    private static const CUMULATIVE_DURATION_FLUSH_DELAY_INTERVAL:int = 10000;

    private var userEventId:int = 0;
    private var contentEventId:int = 0;

    private var logger:ILogger = LoggerFactory.getClassLogger(BatchEventServices);

    public var resumeService:ResumeService;

    private var cumulativeDurationFlushTimer:Timer;
    private var cumulativeDurationCount:Number;
    private var cumulativeDurationMonitor:Timer;

    private var seeking:Boolean;

    private var transactionItemId:Number;
    private var serverTimeStamp:Number;
    private var mainAssetId:int;
    private var sectionCount:int;
    private var programmeId:int;
    private var userId:Number;
    private var anonymousUserId:Number;

    private var contentViewingSequenceNumber:int = 0;
    private var currentAdBreakSequenceNumber:int = 0;

    private var batchEventURL:String;
    private var cumulativeDurationURL:String;

    private var playingMainContent:Boolean;

    private var isPopupInteractive:Boolean = false;
    private var isOverlayInteractive:Boolean = false;
    private var campaignId:int;
    private var contentUrl:String;

    public var eventsManager:EventsManager;
    private var tooSlowTimer:Timer;
    private var mainContentCount:int;
    private var playable:PlayTrait;
    private var loadable:LoadTrait;
    private var playerMetadata:Metadata;
    private var dynamicStream:DynamicStreamTrait;
    private var adMode:String;
    private var viewEvent:ViewEvent;
    private var userEvent:UserEvent;
    private var availabilityType:String;
    private var adUrlResource:String;
    private var oldUserEventId:int = 0;
    private var previewMode:String;
    private var userEventMetadata:Metadata;
    private var adBreaks:Vector.<AdBreak>;
    private var timeTrait:TimeTrait;
    private var cumulativeFlushCounter:int;

    public function BatchEventServices(proxiedElement:MediaElement = null) {
        super(proxiedElement);
        var provider:ObjectProvider = ObjectProvider.getInstance();
        resumeService = provider.getObject(ResumeService);
        if (resumeService == null) {
            throw ArgumentError("no resume service implementation provided");
        }
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("exitPlayerWindow", exitEvent);  // fire the exit event hooked into the window.onUnLoad we currently use...
        }
    }

    public override function set proxiedElement(value:MediaElement):void {
        if (value) {
            if (proxiedElement) {
                proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
                proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
                proxiedElement.removeEventListener(MediaElementEvent.METADATA_ADD, onMetaDataAdd);
                proxiedElement.removeEventListener(MediaElementEvent.METADATA_REMOVE, onMetaDataRemove);
            }

            super.proxiedElement = value;

            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
            proxiedElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetaDataAdd);
            proxiedElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onMetaDataRemove);

            cumulativeDurationCount = 0;
            cumulativeDurationMonitor = new Timer(CUMULATIVE_DURATION_MONITOR_TIMER_DELAY_INTERVAL, 0);
            cumulativeDurationMonitor.addEventListener(TimerEvent.TIMER, incrementCumulativeDurationCounter);

            cumulativeDurationFlushTimer = new Timer(CUMULATIVE_DURATION_FLUSH_DELAY_INTERVAL, 0);
            cumulativeDurationFlushTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
            cumulativeDurationFlushTimer.start();

            playerMetadata = proxiedElement.resource.getMetadataValue(PlayerConstants.METADATA_NAMESPACE) as Metadata;
            playerMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, playerMetaChanged);
            playerMetadata.addEventListener(MetadataEvent.VALUE_ADD, playerMetaChanged);
            playerMetadata.addEventListener(MediaElementEvent.METADATA_ADD, playerMetaChanged);


            adMetadata.addEventListener(MetadataEvent.VALUE_ADD, onAdsMetaDataAdd);
            adMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, onAdsMetaDataChange);


            if (playerMetadata) {

                var videoInfo:XML = playerMetadata.getValue("videoInfo");
                var contentInfo:XML = playerMetadata.getValue("contentInfo");

                transactionItemId = videoInfo.transactionItemId;
                serverTimeStamp = new Number(String(videoInfo.serverTimestamp));
                mainAssetId = videoInfo.mainAssetId;
                batchEventURL = contentInfo.batchEventUrl;
                cumulativeDurationURL = contentInfo.playIntervalEventUrl;
                sectionCount = videoInfo.sectionCount;
                userId = contentInfo.userId;
                anonymousUserId = videoInfo.anonymousUserId;
                programmeId = contentInfo.programme;
                adMode = contentInfo.adMode;
                availabilityType = videoInfo.availabilityType;
                previewMode = contentInfo.preview;

                if (!adsEnabled) createView();

                if (adsEnabled && adMode != AdMetadata.LR_AD_TYPE && adMode != AdMetadata.AUDITUDE_AD_TYPE) createView();


            }
        }

    }

    private function createView():void {
        if (eventsManager) throw ArgumentError("Event Manager Already Exists");

        viewEvent = new ViewEvent(transactionItemId, serverTimeStamp, sectionCount, mainAssetId, userId, anonymousUserId);
        eventsManager = new EventsManagerImpl(viewEvent, previewMode, batchEventURL, cumulativeDurationURL);

        if (sectionCount == 1 && !adsEnabled)  mainContentCount++;
        playingMainContent = true;/// we must have Paid content with no adverts eg MTV...

        var number:Number = resumeService.getResumeCookie();
        if (number == 0) {
            userEvent = buildAndReturnUserEvent(UserEventTypes.AUTO_PLAY);
        } else {
            userEvent = buildAndReturnUserEvent(UserEventTypes.AUTO_RESUME);
        }
        eventsManager.addUserEvent(userEvent);
        eventsManager.flushAll();
    }

    public function get adsEnabled():Boolean {
        // This has been expanded to make it easy to debug as e4x can't be expanded in the debugger
        var tvVodPlayable:Boolean = HelperUtils.getBoolean(playerMetadata.getValue("videoInfo").availability.tvodPlayable);
        var svodPlayable:Boolean = HelperUtils.getBoolean(playerMetadata.getValue("videoInfo").availability.svodPlayable);
        var preview:Boolean = HelperUtils.getBoolean(playerMetadata.getValue("contentInfo").preview);
        var noAds:Boolean = HelperUtils.getBoolean(playerMetadata.getValue("videoInfo").availability.noAdsPlayable);
        var exceededDrm:Boolean = HelperUtils.getBoolean(playerMetadata.getValue("videoInfo").availability.exceededDrmRule);
        if (tvVodPlayable) {
            return false;
        } else if (svodPlayable) {
            return false;
        } else if (preview) {
            return false
        } else if (noAds && !exceededDrm) {
            return false;
        } else {
            return true;
        }
    }


    private function playerMetaChanged(event:MetadataEvent):void {
        //TODO  lIVERAIL METDATA CHANGE AGAINST THE SECTIONCOUNT BEFORE THIS IS FIRED......
        if (adMode == AdMetadata.LR_AD_TYPE || AdMetadata.AUDITUDE_AD_TYPE) {
            if (event.key == AdMetadata.SECTION_COUNT) {
                sectionCount = evaluateNewSectionCount(event.value);
                createView();
            }
        }
        if (event.key == PlayerConstants.USEREVENTS_METADATA_NAMESPACE) {
            userEventMetadata = playerMetadata.getValue(PlayerConstants.USEREVENTS_METADATA_NAMESPACE) as Metadata;
            userEventMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, userEventMetaChanged);
            userEventMetadata.addEventListener(MetadataEvent.VALUE_ADD, userEventMetaChanged);
            userEventMetadata.addEventListener(MediaElementEvent.METADATA_ADD, userEventMetaChanged);
        }
    }


    private function userEventMetaChanged(event:MetadataEvent):void {
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
            if (event.value == "paused") {
                userEventType = UserEventTypes.PAUSE;
            }
        }
        if (userEventType != null) {
            eventsManager.addUserEvent(buildAndReturnUserEvent(userEventType));
        }
    }

    private function evaluateNewSectionCount(value:int):int {
        var newSectionCount:int;
        /// SMILResource should only have one video resource in the event of liverail or auditude and we ALWAYS presume there is a preRoll
        // ELSE this rule will fail..
        if (value == 1 && sectionCount == 1) {
            newSectionCount = value + sectionCount;
        } else {
            newSectionCount = value * 2;
        }
        return  newSectionCount;
    }


    private function get adMetadata():AdMetadata {
        var adMetadata:AdMetadata = proxiedElement.getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
        if (adMetadata == null) {
            adMetadata = new AdMetadata();
            addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);
        }
        return adMetadata;
    }


    private function incrementCumulativeDurationCounter(event:TimerEvent):void {
        cumulativeDurationCount += CUMULATIVE_DURATION_MONITOR_TIMER_DELAY_INTERVAL;
    }

    private function onMetaDataRemove(event:MediaElementEvent):void {
        if (event.namespaceURL == AdMetadata.AD_NAMESPACE) {
            adMetadata.removeEventListener(MetadataEvent.VALUE_ADD, onAdsMetaDataAdd);
            adMetadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onAdsMetaDataChange);
        }
    }

    private function onMetaDataAdd(event:MediaElementEvent):void {
        var metadata:Metadata;
        if (event.namespaceURL == AdMetadata.AD_NAMESPACE) {

            if (adMetadata) {
                adMetadata.removeEventListener(MetadataEvent.VALUE_ADD, onAdsMetaDataAdd);
                adMetadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onAdsMetaDataChange);
            }
            adMetadata.addEventListener(MetadataEvent.VALUE_ADD, onAdsMetaDataAdd);
            adMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, onAdsMetaDataChange);

        } else if (event.namespaceURL == "http://www.seesaw.com/netstatus/metadata") {
            metadata = event.target.getMetadata("http://www.seesaw.com/netstatus/metadata");
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onNetstatusMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onNetstatusMetadataChange);

        }
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
        } else if (event.key == AdMetadata.AD_BREAKS) {
            adBreaks = event.key as Vector.<AdBreak>;
        } else {
            AdMetaEvaluation(event.key);
        }
    }

    private function onAdsMetaDataChange(event:MetadataEvent):void {
        if (event.key == AdMetadata.AD_STATE || event.key == AdMetadata.AD_MODE) {
            AdMetaEvaluation(event.value);
        } else if (event.key == AdMetadata.AD_BREAKS) {
            adBreaks = event.key as Vector.<AdBreak>;
        } else {
            AdMetaEvaluation(event.key);
        }
    }

    private function AdMetaEvaluation(value:*):void {
        if (value == AdState.AD_BREAK_COMPLETE) {
            playingMainContent = true;

        } else if (value == AdState.AD_BREAK_START) {
            playingMainContent = false;
            contentViewingSequenceNumber++;

        } else if (typeof(value) == "object") {
            if (value.state == AdState.STARTED) {

                adUrlResource = value.contentUrl;
                currentAdBreakSequenceNumber++;
                defineContentUrl(true);
                eventsManager.addContentEvent(buildAndReturnContentEvent(ContentTypes.AD_BREAK));

            } else if (value.state == AdState.STOPPED) {

            }

        } else if (value == AdMetadata.CLICK_THRU) {
            eventsManager.addUserEvent(buildAndReturnUserEvent(UserEventTypes.CLICK));
        } else if (value == "mainContent") {
            if (playingMainContent) {

                if (!cumulativeDurationMonitor.running) cumulativeDurationMonitor.start();    // this should only fire when the main content starts...

                contentUrl = "mainResource";
                defineContentUrl(false);

                contentViewingSequenceNumber = evaluateMainContentCount;        // content sequence has changed by 1. same occurs when an advert starts
                currentAdBreakSequenceNumber = 0;     ///we are not in an adBreak so set it to 0
                mainContentCount++;

                eventsManager.addContentEvent(buildAndReturnContentEvent(ContentTypes.MAIN_CONTENT));
                eventsManager.flushAll();
            }
        }
    }


    private function onTimerTick(event:TimerEvent):void {
        cumulativeFlushCounter += CUMULATIVE_DURATION_FLUSH_DELAY_INTERVAL;
        if(cumulativeFlushCounter == CUMULATIVE_DURATION_FLUSH_TIMER_MAX){
            cumulativeFlushCounter = 0;
            eventsManager.flushCumulativeDuration(new CumulativeDurationEvent(programmeId, transactionItemId));
        }
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
        }
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

    private function onPlayStateChange(event:PlayEvent):void {
        if (playingMainContent) {
            switch (event.playState) {
                case PlayState.PAUSED:
                    cumulativeDurationMonitor.stop();
                    cumulativeDurationFlushTimer.stop();
                    break;
                case PlayState.PLAYING:
                    if (!cumulativeDurationMonitor.running) {
                        cumulativeDurationMonitor.start();
                        cumulativeDurationFlushTimer.start();
                    }
                    break;
                case PlayState.STOPPED:
                    if (cumulativeDurationMonitor.running) {
                        cumulativeDurationMonitor.stop();
                        cumulativeDurationFlushTimer.stop();
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
            } else {
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
                    cumulativeDurationMonitor.stop(); //todo check this checker is actually working accurately....

                    contentViewingSequenceNumber = evaluateMainContentCount;

                    eventsManager.addUserEvent(buildAndReturnUserEvent(UserEventTypes.SCRUB));

                }
            }
            seeking = event.seeking;
        }
        logger.debug("------------On Seek Change:{0}", event.seeking);
    }

    private function toggleTimeListeners(added:Boolean):void {
        timeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;
        if (timeTrait) {
            timeTrait.addEventListener(TimeEvent.COMPLETE, onComplete);
        } else {
            timeTrait.removeEventListener(TimeEvent.COMPLETE, onComplete);
        }
    }

    private function onComplete(event:TimeEvent):void {
        eventsManager.addUserEvent(buildAndReturnUserEvent(UserEventTypes.END));
        eventsManager.flushAll();
    }

    private function get evaluateMainContentCount():int {
        var currentSection:int;
        if (adBreaks) {

            for each (var breakItem:AdBreak in adBreaks) {

                if (timeTrait.currentTime >= breakItem.startTime) {
                    currentSection = currentSection + 2;// since we are checking adBreaks, we need to increment twice (once for the ad, once into the current content...
                }
            }

        } else {
            currentSection = 1;
        }
        return currentSection;
    }


    private function defineContentUrl(checkResource:Boolean):void {
        if (loadable && checkResource) {
            var streamingUrlResource:StreamingURLResource = loadable.resource as StreamingURLResource;
            if (streamingUrlResource) {
                contentUrl = streamingUrlResource.url;
            } else if (adUrlResource) {
                contentUrl = adUrlResource;
            }
        }
    }

    private function exitEvent():void {
        eventsManager.addUserEvent(buildAndReturnUserEvent(UserEventTypes.EXIT));
        eventsManager.flushExitEvent();
    }

    private function evaluateContentViewingSeqNum():int {
        //// TODO match the sequence number against the seekPosition using the adMap.. this could be done in the scrubPreventionProxy  -  NICE TO HAVE
        var value:int;

        return value;
    }

    private function incrementAndGetUserEventId():int {
        userEventId++;
        return userEventId;
    }

    private function incrementAndGetContentEventId():int {
        if (oldUserEventId == userEventId) {
            contentEventId++;
        } else {
            contentEventId = 0;
        }
        oldUserEventId = userEventId;

        return contentEventId;
    }


    private function buildAndReturnUserEvent(userEventType:String):UserEvent {
        generateAssociatedContentEvent();
        return new UserEvent(incrementAndGetUserEventId(), cumulativeDurationCount, userEventType, programmeId);
    }

    private function generateAssociatedContentEvent():void {
        playingMainContent ? eventsManager.addContentEvent(buildAndReturnMainContentEvent(ContentTypes.MAIN_CONTENT)) : eventsManager.addContentEvent(buildAndReturnContentEvent(ContentTypes.AD_BREAK));
    }

    private function buildAndReturnContentEvent(contentType:String):ContentEvent {
        return new ContentEvent(isPopupInteractive, mainAssetId, new Date(), isOverlayInteractive, contentViewingSequenceNumber, incrementAndGetContentEventId(), campaignId, cumulativeDurationCount, userEventId, cumulativeDurationCount, contentType, currentAdBreakSequenceNumber, contentUrl);
    }

    private function buildAndReturnMainContentEvent(contentType:String):ContentEvent {
        return new ContentEvent(isPopupInteractive, mainAssetId, new Date(), isOverlayInteractive, evaluateMainContentCount, incrementAndGetContentEventId(), campaignId, cumulativeDurationCount, userEventId, cumulativeDurationCount, contentType, currentAdBreakSequenceNumber, contentUrl);
    }
}
}