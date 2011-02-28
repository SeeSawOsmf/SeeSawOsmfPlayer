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

package com.seesaw.player.ads.liverail {
// These three rom PlayerCommon, not here

import com.seesaw.player.PlayerConstants;
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.ads.AdMode;
import com.seesaw.player.ads.AdState;
import com.seesaw.player.ads.LiverailConstants;
import com.seesaw.player.ads.events.LiveRailEvent;
import com.seesaw.player.namespaces.contentinfo;
import com.seesaw.player.traits.ads.AdPlayTrait;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.system.Security;
import flash.utils.Timer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.AudioEvent;
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.TimeEvent;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.URLResource;
import org.osmf.metadata.Metadata;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.LoadState;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.TimeTrait;

public class AdProxy extends ProxyElement {

    use namespace contentinfo;

    private var logger:ILogger = LoggerFactory.getClassLogger(AdProxy);

    private static const CONTENT_UPDATE_INTERVAL:int = 500;

    private var adManager:*;
    private var config:Configuration;
    private var resumePosition:int;
    private var timer:Timer;
    private var playerMetadata:Metadata;
    private var currentAdBreak:AdBreak;

    public function AdProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);
        Security.allowDomain("vox-static.liverail.com");
        timer = new Timer(CONTENT_UPDATE_INTERVAL);
        timer.addEventListener(TimerEvent.TIMER, onTimerTick);
    }

    override public function set resource(value:MediaResourceBase):void {
        super.resource = value;

        playerMetadata = proxiedElement.resource.getMetadataValue(PlayerConstants.METADATA_NAMESPACE) as Metadata;

        updateLoadTrait();
    }

    private function updateLoadTrait():void {
        var loadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
        var liverailPath:String = getSetting(LiverailConstants.ADMANAGER_URL) as String;
        if (loadTrait && liverailPath) {
            var proxiedLoadTrait:LiveRailLoadTrait = new LiveRailLoadTrait(new Loader(), new URLResource(liverailPath));
            proxiedLoadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
            addTrait(MediaTraitType.LOAD, proxiedLoadTrait);
        }
    }

    private function onLoadStateChange(event:LoadEvent):void {
        logger.debug("onLoadStateChange: " + event.loadState);
        var loadTrait:LiveRailLoadTrait = getTrait(MediaTraitType.LOAD) as LiveRailLoadTrait;
        if (event.loadState == LoadState.READY) {
            adManager = loadTrait.adManager;
            adManager.addEventListener(LiveRailEvent.INIT_COMPLETE, onInitComplete);
            adManager.addEventListener(LiveRailEvent.INIT_ERROR, onInitError);
            adManager.addEventListener(LiveRailEvent.AD_BREAK_START, adbreakStart);
            adManager.addEventListener(LiveRailEvent.AD_BREAK_COMPLETE, adbreakComplete);
            adManager.addEventListener(LiveRailEvent.PREROLL_COMPLETE, onPrerollComplete);
            // adManager.addEventListener(LiveRailEvent.POSTROLL_COMPLETE, onPostrollComplete);
            adManager.addEventListener(LiveRailEvent.AD_START, onAdStart);
            adManager.addEventListener(LiveRailEvent.AD_END, onAdEnd);
            adManager.addEventListener(LiveRailEvent.AD_PROGRESS, onAdProgress);
            adManager.addEventListener(LiveRailEvent.CLICK_THRU, onClickThru);

            config = getSetting(LiverailConstants.CONFIG_OBJECT) as Configuration;
            resumePosition = getSetting(LiverailConstants.RESUME_POSITION) as int;

            // block these until the liverail events kick in
            setTraitsToBlock(MediaTraitType.PLAY, MediaTraitType.TIME, MediaTraitType.DISPLAY_OBJECT);

            // After calling initAds(config), the main video playerï¿½s controls should be disabled and any requests to
            // play a movie should be cancelled or delayed until the initComplete (or the initError) event is received
            // from the ad manager. If initComplete has been received, first call lrAdManager.onContentStart() and only
            // resume your main video after prerollComplete event is triggered.
            // This ensures that pre-roll ads are handled properly.
            adManager.initAds(config.config);

            // triggers the original load trait
            removeTrait(MediaTraitType.LOAD);
        }
        else if (event.loadState == LoadState.LOAD_ERROR) {
            removeTrait(MediaTraitType.LOAD);
        }
    }

    public override function set proxiedElement(value:MediaElement):void {
        if (value) {
            logger.debug("proxiedElement: " + value);

            if (proxiedElement) {
                proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
                proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
            }

            super.proxiedElement = value;

            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
        }
    }

    private function onPlayStateChange(event:PlayEvent):void {
        logger.debug("onPlayStateChange: " + event.playState);
        if (adManager) {
            if (event.playState == PlayState.PLAYING) {
                if (timer == null) {
                    timer = new Timer(CONTENT_UPDATE_INTERVAL);
                    timer.addEventListener(TimerEvent.TIMER, onTimerTick);
                }
                timer.start();
            }
            else {
                if (timer) {
                    timer.stop();
                }
            }
        }
    }

    private function onAdPlayStateChange(event:PlayEvent):void {
        logger.debug("onAdPlayStateChange: " + event.playState);
        switch (event.playState) {
            case PlayState.PAUSED:
                adManager.pauseAd();
                break;
            case PlayState.PLAYING:
                adManager.resumeAd();
                break;
            case PlayState.STOPPED:
                adManager.pauseAd();
                break;
        }
    }

    private function onVolumeChange(event:AudioEvent):void {
        logger.debug("onVolumeChange");
        if (adManager) {
            if (event.muted) {
                adManager.setVolume(0);
            }
            else {
                adManager.setVolume(event.volume);
            }
        }
    }

    private function onInitComplete(ev:Object):void {
        logger.debug("onInitComplete");

        var adMap:Object = ev.data.adMap;
        var adBreaks:Array = adMap.adBreaks;

        var metadataAdBreaks:Vector.<AdBreak> = new Vector.<AdBreak>();

        for (var i:uint = 0; i < adBreaks.length; i++) {
            var adBreak:Object = adBreaks[i];

            //total number of ads in this ad-break
            var queueAdsTotal:uint = adBreak.queueAdsTotal;

            //total duration of ad-break in seconds
            //sometimes duration is not available for 3rd party ads such as VPAID
            //when duration cannot be computed, this value remains zero
            var queueDuration:Number = adBreak.queueDuration;

            // (queueAdsTotal > 0)
            var hasAds:Boolean = adBreak.hasAds;

            //start time passed in the LR_ADMAP param: "0", "768.52" and "100%", all values are String
            var startTimeString:String = adBreak.startTimeString;

            //start time value converted to Number: 0, 768.52, 100
            var startTimeValue:Number = adBreak.startTimeValue;

            //specifies whether the startTimeValue is Percent (true) or  seconds (false)
            var startTimeIsPercent:Boolean = adBreak.startTimeIsPercent;

            // sets the ad breaks as metadata on the element
            var metadataAdBreak:AdBreak = new AdBreak();
            metadataAdBreak.queueAdsTotal = queueAdsTotal;
            metadataAdBreak.queueDuration = queueDuration;
            metadataAdBreak.startTime = startTimeValue;
            metadataAdBreak.startTimeIsPercent = startTimeIsPercent;

            // Dont add the break if it has no ads, eg no content to play, so we don't want a blip for this item
            if (hasAds) {
                metadataAdBreak.seekOffset = 0.5; // seek back half a second to trigger the ads
                metadataAdBreaks[i] = metadataAdBreak;
            }
        }
        adMetadata.adBreaks = metadataAdBreaks;

        // section count need to occur before we start the adContent. as this is required for the first view to be registered.
        playerMetadata.addValue(AdMetadata.SECTION_COUNT, metadataAdBreaks.length);
        adManager.onContentStart();
    }

    private function onInitError(ev:Object):void {
        logger.debug("onInitError");
        setTraitsToBlock();
        play();
    }

    private function onClickThru(event:Object):void {
        adMetadata.clickThru = event.data.ad.clickThruUrl;    ///use the Url to force a value change event to occur..
        pause();
    }

    private function onAdProgress(event:Object):void {
    }

    private function onAdStart(event:Object):void {
        logger.debug("onAdStart");

        var dataObject:Object = new Object();
        dataObject["state"] = AdState.STARTED;
        dataObject["contentUrl"] = event.data.ad.linear.url;
        dataObject["campaignId"] = event.data.ad.campaignID;
        dataObject["creativeId"] = event.data.ad.creativeID;

        adMetadata.adState = dataObject;
        play();
    }

    private function onAdEnd(event:Object):void {
        logger.debug("onAdEnd");

        var dataObject:Object = new Object();
        dataObject["state"] = AdState.STOPPED;
        dataObject["contentUrl"] = event.data.ad.linear.url;
        dataObject["campaignId"] = event.data.ad.campaignID;
        dataObject["creativeId"] = event.data.ad.creativeID;

        adMetadata.adState = dataObject;
    }

    private function onPrerollComplete(event:Event):void {
        logger.debug("onPrerollComplete");
        setTraitsToBlock();
        play();
    }

    private function adbreakStart(event:Object):void {
        logger.debug("adbreakStart");
        adMetadata.adState = AdState.AD_BREAK_START;
        adMetadata.adMode = AdMode.AD;
        currentAdBreak = adMetadata.getAdBreakWithTime(event.data.breakTime);

        setTraitsToBlock(MediaTraitType.SEEK, MediaTraitType.TIME);
        // Perhaps this is needed for mid-rolls
        if (event.data.breakTime > 0)   /// not to pause for preROll...
            pause();

        // mask the existing play trait so we get the play state changes here
        var adPlayTrait:AdPlayTrait = new AdPlayTrait();
        adPlayTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onAdPlayStateChange);
        addTrait(MediaTraitType.PLAY, adPlayTrait);

        // add a display trait that will display the ads
        addTrait(MediaTraitType.DISPLAY_OBJECT, new DisplayObjectTrait(adManager));
    }

    private function adbreakComplete(event:Object):void {
        logger.debug("adbreakComplete");
        removeTrait(MediaTraitType.PLAY);
        removeTrait(MediaTraitType.DISPLAY_OBJECT);
        removeTrait(MediaTraitType.TIME);

        adMetadata.adState = AdState.AD_BREAK_COMPLETE;
        adMetadata.adMode = AdMode.MAIN_CONTENT;

        if (currentAdBreak) {
            // This dispatches an event that seeks to the user's final seek point
            currentAdBreak.complete = true;
        }

        setTraitsToBlock();
        play();
    }

    private function onContentUpdate(time:Number, duration:Number):void {
        adManager.onContentUpdate(time, duration);
    }

    private function onComplete(event:TimeEvent) {
        logger.debug("onComplete");
        if (adManager) {
            // This function triggers any available post-roll ads.
            adManager.onContentEnd();
        }
    }

    private function onTimerTick(event:TimerEvent):void {
        var timeTrait:TimeTrait = getTrait(MediaTraitType.TIME) as TimeTrait;
        if (timeTrait && !isNaN(timeTrait.duration) && !isNaN(timeTrait.currentTime)) {
            onContentUpdate(timeTrait.currentTime, timeTrait.duration);
        }
    }

    private function getSetting(key:String):* {
        var metadata:Metadata = resource.getMetadataValue(LiverailConstants.SETTINGS_NAMESPACE) as Metadata;
        return metadata ? metadata.getValue(key) : null;
    }

    private function setTraitsToBlock(...traitTypes):void {
        var traitsToBlock:Vector.<String> = new Vector.<String>();
        for (var i:int = 0; i < traitTypes.length; i++) {
            traitsToBlock[i] = traitTypes[i];
        }
        blockedTraits = traitsToBlock;
    }

    private function pause() {
        var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playTrait) {
            // pauses the main content or the ads depending on the current adtrait
            playTrait.pause();
        }
    }

    private function stop() {
        var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playTrait) {
            // stops the main content - no affect on liverail
            playTrait.stop();
        }
    }

    private function play() {
        var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playTrait) {
            // plays the main content or the ads depending on the current adtrait
            playTrait.play();
        }
    }

    private function onTraitAdd(event:MediaElementEvent):void {
        var target = event.target as MediaElement;
        updateTraitListeners(target, event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        var target = event.target as MediaElement;
        updateTraitListeners(target, event.traitType, false);
    }

    private function updateTraitListeners(element:MediaElement, traitType:String, add:Boolean):void {
        switch (traitType) {
            case MediaTraitType.PLAY:
                changeListeners(element, add, traitType, PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
                break;
            case MediaTraitType.AUDIO:
                changeListeners(element, add, traitType, AudioEvent.VOLUME_CHANGE, onVolumeChange);
                changeListeners(element, add, traitType, AudioEvent.MUTED_CHANGE, onVolumeChange);
                break;
            case MediaTraitType.TIME:
                changeListeners(element, add, traitType, TimeEvent.COMPLETE, onComplete);
                break;
        }
    }

    private function changeListeners(element:MediaElement, add:Boolean, traitType:String, event:String, listener:Function):void {
        if (add) {
            element.getTrait(traitType).addEventListener(event, listener);
        }
        else if (element.hasTrait(traitType)) {
            element.getTrait(traitType).removeEventListener(event, listener);
        }
    }

    private function get adMetadata():AdMetadata {
        var adMetadata:AdMetadata = getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
        if (adMetadata == null) {
            adMetadata = new AdMetadata();
            addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);
        }
        return adMetadata;
    }
}
}
