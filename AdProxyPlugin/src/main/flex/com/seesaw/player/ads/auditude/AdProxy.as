/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *    The contents of this file are subject to the Mozilla Public License
 *    Version 1.1 (the "License"); you may not use this file except in
 *    compliance with the License. You may obtain a copy of the
 *    License athttp://www.mozilla.org/MPL/
 *
 *    Software distributed under the License is distributed on an "AS IS"
 *    basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *    License for the specific language governing rights and limitations
 *    under the License.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 */

package com.seesaw.player.ads.auditude {
import com.auditude.ads.AuditudePlugin;
import com.auditude.ads.event.AdClickThroughEvent;
import com.auditude.ads.event.AdPluginEvent;
import com.auditude.ads.event.LinearAdEvent;
import com.auditude.ads.event.NonLinearAdEvent;
import com.auditude.ads.model.ILinearAsset;
import com.auditude.ads.osmf.IAuditudeMediaElement;
import com.auditude.ads.osmf.constants.AuditudeOSMFConstants;
import com.auditude.ads.NotificationType;

// These three rom PlayerCommon, not here
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.ads.AdMetadata; 
import com.seesaw.player.ads.AdState; 

import com.seesaw.player.ads.AuditudeConstants;
import com.seesaw.player.ads.events.LiveRailEvent;
import com.seesaw.player.traits.ads.AdPlayTrait;
import com.seesaw.player.traits.ads.AdTimeTrait;

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
import org.osmf.events.MediaFactoryEvent;
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

import org.osmf.media.DefaultMediaFactory;

public class AdProxy extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(AdProxy);

    private static const CONTENT_UPDATE_INTERVAL:int = 500;

    private var adManager:*;
    private var config:Configuration;
    private var resumePosition:int;
		private var _mediaFactory:DefaultMediaFactory;

    private var timer:Timer;

    private var adTimeTrait:AdTimeTrait;

    public function AdProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);
        Security.allowDomain("sandbox.auditude.com");
        //timer = new Timer(CONTENT_UPDATE_INTERVAL);
        //timer.addEventListener(TimerEvent.TIMER, onTimerTick);
    }

    override public function set resource(value:MediaResourceBase):void {
        super.resource = value;
        updateLoadTrait();
    }

    private function updateLoadTrait():void {
var loadPath:String = getSetting(AuditudeConstants.ADMANAGER_URL) as String;
logger.debug("UPDATE LOAD TRAIT: " + loadPath);
			/*_mediaFactory = new DefaultMediaFactory();
			_mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
			_mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadFailed);
			_mediaFactory.loadPlugin(new URLResource(loadPath));

return;*/
        var loadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
        var loadPath:String = getSetting(AuditudeConstants.ADMANAGER_URL) as String;
        if (loadTrait && loadPath) {
            var proxiedLoadTrait:AuditudeLoadTrait = new AuditudeLoadTrait(new Loader(), new URLResource(loadPath));
            proxiedLoadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
            addTrait(MediaTraitType.LOAD, proxiedLoadTrait);
        }
    }

		private function onPluginLoaded(event:MediaFactoryEvent):void {
logger.debug("GETTING AUDITUDE AD MANAGER");
				if (proxiedElement is IAuditudeMediaElement) {
var _auditude:AuditudePlugin = IAuditudeMediaElement(proxiedElement).plugin;
if (_auditude) logger.debug("WE HAVE THE PLUGIN");
				}
		}

private function onPluginLoadFailed(event:MediaFactoryEvent):void {
logger.debug("auditude load failed");
}

    private function onLoadStateChange(event:LoadEvent):void {
        logger.debug("onLoadStateChange: " + event.loadState);
        var loadTrait:AuditudeLoadTrait = getTrait(MediaTraitType.LOAD) as AuditudeLoadTrait;
        if (event.loadState == LoadState.READY) {
logger.debug("GETTING AUDITUDE AD MANAGER");
if (proxiedElement is IAuditudeMediaElement)
				{
var _auditude:AuditudePlugin = IAuditudeMediaElement(proxiedElement).plugin;
if (_auditude) logger.debug("WE HAVE THE PLUGIN");
				}

            adManager = loadTrait.adManager;
            /*adManager.addEventListener(LiveRailEvent.INIT_COMPLETE, onInitComplete);
            adManager.addEventListener(LiveRailEvent.INIT_ERROR, onInitError);
            adManager.addEventListener(LiveRailEvent.AD_BREAK_START, adbreakStart);
            adManager.addEventListener(LiveRailEvent.AD_BREAK_COMPLETE, adbreakComplete);
            adManager.addEventListener(LiveRailEvent.PREROLL_COMPLETE, onPrerollComplete);
            // adManager.addEventListener(LiveRailEvent.POSTROLL_COMPLETE, onPostrollComplete);
            adManager.addEventListener(LiveRailEvent.AD_START, onAdStart);
            adManager.addEventListener(LiveRailEvent.AD_END, onAdEnd);
            adManager.addEventListener(LiveRailEvent.AD_PROGRESS, onAdProgress);
            adManager.addEventListener(LiveRailEvent.CLICK_THRU, onClickThru);*/

						adManager.addEventListener(AdPluginEvent.BREAK_BEGIN, adbreakStart);
						adManager.addEventListener(AdPluginEvent.BREAK_END, adbreakComplete);

						adManager.addEventListener(AdClickThroughEvent.AD_CLICK, onClickThru);
						adManager.addEventListener(LinearAdEvent.AD_BEGIN, onAdStart);
						adManager.addEventListener(LinearAdEvent.AD_END, onAdEnd);
						//adManager.addEventListener(NonLinearAdEvent.AD_BEGIN, onNonLinearAdBegin);
						//adManager.addEventListener(NonLinearAdEvent.AD_END, onNonLinearAdEnd);


            //config = getSetting(AuditudeConstants.CONFIG_OBJECT) as Configuration;
            resumePosition = getSetting(AuditudeConstants.RESUME_POSITION) as int;

            // block these until the liverail events kick in
            //setTraitsToBlock(MediaTraitType.PLAY, MediaTraitType.TIME);

            // After calling initAds(config), the main video player’s controls should be disabled and any requests to
            // play a movie should be cancelled or delayed until the initComplete (or the initError) event is received
            // from the ad manager. If initComplete has been received, first call lrAdManager.onContentStart() and only
            // resume your main video after prerollComplete event is triggered.
            // This ensures that pre-roll ads are handled properly.
            //adManager.initAds(config.config);

						//adManager.notify(NotificationType.BREAK_BEGIN)


            // triggers the original load trait
            removeTrait(MediaTraitType.LOAD);
        }
        else if (event.loadState == LoadState.LOAD_ERROR) {
            removeTrait(MediaTraitType.LOAD);
        }
    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            logger.debug("proxiedElement: " + proxiedElement);
            super.proxiedElement = proxiedElement;

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

        adManager.onContentStart();

        var adMap:Object = ev.data.adMap;
        var adBreaks:Array = adMap.adBreaks;

        var metadataAdBreaks:Vector.<AdBreak> = new Vector.<AdBreak>(adBreaks.length, true);

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

            metadataAdBreaks[i] = metadataAdBreak;
        }

        adMetadata.adBreaks = metadataAdBreaks;
    }

    private function onInitError(ev:Object):void {
        logger.debug("onInitError");
        setTraitsToBlock();
        play();
    }

    private function onClickThru(event:Object):void {
        logger.debug("onClickThru");
        pause();
    }

    private function onAdProgress(event:Object):void {
        adTimeTrait.adDuration = event.data.duration;
        adTimeTrait.adTime = event.data.time;
    }

    private function onAdStart(event:Object):void {
        logger.debug("onAdStart");
        play();
    }

    private function onAdEnd(event:Event):void {
        logger.debug("onAdEnd");
        adTimeTrait.adDuration = 0;
        adTimeTrait.adTime = 0;
    }

    private function onPrerollComplete(event:Event):void {
        logger.debug("onPrerollComplete");
        setTraitsToBlock();
        //play(); //adbreakComplete will handle this
    }

    private function adbreakStart(event:Object):void {
        logger.debug("adbreakStart");

        adMetadata.adState = AdState.STARTED;

        setTraitsToBlock(MediaTraitType.SEEK);
        // Perhaps this is needed for mid-rolls
        //pause();

        // mask the existing play trait so we get the play state changes here
        var adPlayTrait:AdPlayTrait = new AdPlayTrait();
        adPlayTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onAdPlayStateChange);
        addTrait(MediaTraitType.PLAY, adPlayTrait);

        // add a display trait that will display the ads
        addTrait(MediaTraitType.DISPLAY_OBJECT, new DisplayObjectTrait(adManager));

        adTimeTrait = new AdTimeTrait();
        addTrait(MediaTraitType.TIME, adTimeTrait);
    }

    private function adbreakComplete(event:Object):void {
        logger.debug("adbreakComplete");
        removeTrait(MediaTraitType.PLAY);
        removeTrait(MediaTraitType.DISPLAY_OBJECT);
        removeTrait(MediaTraitType.TIME);
        adTimeTrait = null;

        adMetadata.adState = AdState.STOPPED;

        setTraitsToBlock();
        play();
    }

    private function volume(vol:Number):void {
        adManager.setVolume(vol);
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
        var metadata:Metadata = resource.getMetadataValue(AuditudeOSMFConstants.AUDITUDE_METADATA_NAMESPACE) as Metadata;
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
        logger.debug("updateTraitListeners: element = {0}, type = {1}, add = {2}", element, traitType, add);
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
