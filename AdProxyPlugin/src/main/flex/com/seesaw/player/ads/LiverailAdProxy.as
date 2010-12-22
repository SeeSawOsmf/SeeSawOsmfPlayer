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

package com.seesaw.player.ads {
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
import org.osmf.events.PlayEvent;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.URLResource;
import org.osmf.metadata.Metadata;
import org.osmf.traits.AudioTrait;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.LoadState;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.TimeTrait;

public class LiverailAdProxy extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(LiverailAdProxy);

    private static const CONTENT_UPDATE_INTERVAL:int = 500;

    private var adManager:*;
    private var liverailConfig:LiverailConfiguration;
    private var resumePosition:int;

    private var adMetadata:AdMetadata;
    private var timer:Timer;

    private var adTimeTrait:AdTimeTrait;

    public function LiverailAdProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);
        Security.allowDomain("vox-static.liverail.com");
    }

    override public function set resource(value:MediaResourceBase):void {
        super.resource = value;
        updateLoadTrait();
    }

    private function updateLoadTrait():void {
        var loadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
        var liverailPath:String = getSetting(LiverailConstants.ADMANAGER_URL) as String;
        if (loadTrait && liverailPath) {
            var liverailLoadTrait:LiverailLoadTrait = new LiverailLoadTrait(new LiverailLoader(), new URLResource(liverailPath));
            liverailLoadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLiverailLoadStateChange);
            addTrait(MediaTraitType.LOAD, liverailLoadTrait);
        }
    }

    private function onLiverailLoadStateChange(event:LoadEvent):void {
        var loadTrait:LiverailLoadTrait = getTrait(MediaTraitType.LOAD) as LiverailLoadTrait;
        if (event.loadState == LoadState.READY) {
            adManager = loadTrait.adManager;
            setupAdManager();
            removeTrait(MediaTraitType.LOAD);
        }
        else if (event.loadState == LoadState.LOAD_ERROR) {
            removeTrait(MediaTraitType.LOAD);
        }
    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            super.proxiedElement = proxiedElement;

            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onProxiedTraitAdd);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onProxiedTraitRemove);

            adMetadata = getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
            if (adMetadata == null) {
                adMetadata = new AdMetadata();
                addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);
            }
        }
    }

    private function processTrait(traitType:String, added:Boolean):void {
        switch (traitType) {
            case MediaTraitType.LOAD:
                toggleLoadListeners(added);
                break;
            case MediaTraitType.AUDIO:
                toggleAudioListeners(added);
                break;
        }
    }

    private function toggleAudioListeners(added:Boolean):void {
        var audible:AudioTrait = getTrait(MediaTraitType.AUDIO) as AudioTrait;
        if (audible) {
            if (added) {
                audible.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
                audible.addEventListener(AudioEvent.MUTED_CHANGE, onVolumeChange);
            }
            else {
                audible.removeEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
                audible.removeEventListener(AudioEvent.MUTED_CHANGE, onVolumeChange);
            }
        }
    }

    private function toggleLoadListeners(added:Boolean):void {
        var loadable:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
        if (loadable) {
            if (added) {
                loadable.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadableStateChange);
            }
            else {
                loadable.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadableStateChange);
            }
        }
    }

    private function onLoadableStateChange(event:LoadEvent):void {
        if (event.loadState == LoadState.READY) {
            if (adManager) {
                pause();
                adManager.initAds(liverailConfig.config);
            }
        }
    }

    private function onVolumeChange(event:AudioEvent):void {
        if (event.muted) {
            adManager.setVolume(0);
        }
        else {
            adManager.setVolume(event.volume);
        }
    }

    private function setupAdManager():void {
        adManager.addEventListener(LiveRailEvent.INIT_COMPLETE, onLiveRailInitComplete);
        adManager.addEventListener(LiveRailEvent.AD_BREAK_START, adbreakStart);
        adManager.addEventListener(LiveRailEvent.AD_BREAK_COMPLETE, adbreakComplete);
        adManager.addEventListener(LiveRailEvent.PREROLL_COMPLETE, onLiveRailPrerollComplete);
        adManager.addEventListener(LiveRailEvent.AD_START, onLiveRailAdStart);
        adManager.addEventListener(LiveRailEvent.AD_END, onLiveRailAdEnd);
        adManager.addEventListener(LiveRailEvent.AD_PROGRESS, onLiverailAdProgress);
        adManager.addEventListener(LiveRailEvent.CLICK_THRU, onLiveRailClickThru);

        /*adManager.addEventListener(LiveRailEvent.INIT_ERROR, onLiveRailInitError);
         adManager.addEventListener(LiveRailEvent.POSTROLL_COMPLETE, onLiveRailPostrollComplete);
         adManager.addEventListener(LiveRailEvent.AD_END, onLiveRailAdEnd);

         adManager.addEventListener(LiveRailEvent.VOLUME_CHANGE, onLiveRailVolumeChange);
         */

        liverailConfig = getSetting(LiverailConstants.CONFIG_OBJECT) as LiverailConfiguration;
        resumePosition = getSetting(LiverailConstants.RESUME_POSITION) as int;

        adMarkers = liverailConfig.adPositions;
    }

    private function onLiveRailClickThru(event:Object):void {
        pause();
    }

    private function onLiverailAdProgress(event:Object):void {
        if (adTimeTrait == null) {
            adTimeTrait = new AdTimeTrait(event.data.duration);
            addTrait(MediaTraitType.TIME, adTimeTrait);
        }
        adTimeTrait.adTime = event.data.time;
    }

    private function onLiveRailAdStart(event:Object):void {
        logger.debug("onLiveRailAdStart");
        play();
    }

    private function onLiveRailAdEnd(event:Event):void {
        logger.debug("onLiveRailAdEnd");
        if (adTimeTrait) {
            removeTrait(MediaTraitType.TIME);
            adTimeTrait = null;
        }
    }

    private function onLiveRailPrerollComplete(event:Event):void {
        logger.debug("onLiveRailPrerollComplete");
    }

    private function adbreakStart(event:Object):void {
        logger.debug("adbreakStart");

        var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playTrait) {
            setTraitsToBlock(MediaTraitType.SEEK);
            playTrait.pause();
        }

        var timeTrait:TimeTrait = getTrait(MediaTraitType.TIME) as TimeTrait;
        if (timeTrait) {
            timer.stop();
        }

        // mask the existing play trait so we get the play state changes here
        var adPlayTrait:AdPlayTrait = new AdPlayTrait();
        adPlayTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onAdPlayStateChange);
        addTrait(MediaTraitType.PLAY, adPlayTrait);

        // add a display trait that will display the ads
        addTrait(MediaTraitType.DISPLAY_OBJECT, new DisplayObjectTrait(adManager));
    }

    private function adbreakComplete(event:Event = null):void {
        removeTrait(MediaTraitType.PLAY);
        removeTrait(MediaTraitType.DISPLAY_OBJECT);

        var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playTrait) {
            setTraitsToBlock();
            playTrait.play();
        }

        var timeTrait:TimeTrait = getTrait(MediaTraitType.TIME) as TimeTrait;
        if (timeTrait) {
            timer.start();
        }
    }

    private function onAdPlayStateChange(event:PlayEvent):void {
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

    private function onLiveRailInitComplete(ev:Object):void {
        logger.debug("onLiveRailInitComplete");

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

        timer = new Timer(CONTENT_UPDATE_INTERVAL);
        timer.addEventListener(TimerEvent.TIMER, onTimerTick);
        timer.start();

        adManager.onContentStart();
    }

    public function volume(vol:Number):void {
        adManager.setVolume(vol);
    }

    public function onContentUpdate(time:Number, duration:Number):void {
        logger.debug("content update: time = {0}, duration = {1}", time, duration);
        adManager.onContentUpdate(time, duration);
    }

    private function onProxiedTraitAdd(event:MediaElementEvent):void {
        processTrait(event.traitType, true);
    }

    private function onProxiedTraitRemove(event:MediaElementEvent):void {
        processTrait(event.traitType, false);
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

    private function set adMarkers(adMarkers:Array):void {
        if (adMetadata) {
            adMetadata.adMarkers = adMarkers;
        }
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
        if (hasTrait(MediaTraitType.PLAY)) {
            playTrait.pause();
        }
    }

    private function play() {
        var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (hasTrait(MediaTraitType.PLAY)) {
            playTrait.play();
        }
    }

}
}