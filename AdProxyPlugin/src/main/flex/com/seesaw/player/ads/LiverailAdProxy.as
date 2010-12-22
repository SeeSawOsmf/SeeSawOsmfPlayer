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

import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.net.URLRequest;
import flash.system.Security;
import flash.utils.Timer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.AudioEvent;
import org.osmf.events.DisplayObjectEvent;
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.PlayEvent;
import org.osmf.media.MediaElement;
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

    private var _innerViewable:DisplayObjectTrait;
    private var outerViewable:DisplayObjectTrait;
    private var outerViewableSprite:Sprite;

    private var adManager:*;
    private var liverailLoader:Loader;
    private var liverailConfig:LiverailConfiguration;
    private var resumePosition:int;

    private var adMetadata:AdMetadata;
    private var timer:Timer;

    public function LiverailAdProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);
        Security.allowDomain("vox-static.liverail.com");
    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            super.proxiedElement = proxiedElement;

            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onProxiedTraitsChange);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onProxiedTraitsChange);

            adMetadata = getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
            if (adMetadata == null) {
                adMetadata = new AdMetadata();
                addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);
            }

            outerViewableSprite = new Sprite();
            outerViewable = new DisplayObjectTrait(outerViewableSprite);
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
        var audible:AudioTrait = proxiedElement.getTrait(MediaTraitType.AUDIO) as AudioTrait;
        if (audible) {
            if (added) {
                audible.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
                audible.addEventListener(AudioEvent.MUTED_CHANGE, onMutedChange);
            }
            else {
                audible.removeEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
                audible.removeEventListener(AudioEvent.MUTED_CHANGE, onMutedChange);
            }
        }
    }

    private function toggleLoadListeners(added:Boolean):void {
        var loadable:LoadTrait = proxiedElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
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
            createLiverail();

            var playTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
            if (playTrait) {
                playTrait.pause();
            }
        }
    }

    private function onMutedChange(event:AudioEvent):void {
        logger.debug("Mute change: {0}", event.muted);
    }

    private function onVolumeChange(event:AudioEvent):void {
        adManager.setVolume(event.volume, false);
    }

    private function createLiverail():void {
        var liverailPath:String = getSetting(LiverailConstants.ADMANAGER_URL) as String;

        if (liverailPath && adManager == null) {
            var urlResource:URLRequest = new URLRequest(liverailPath);
            liverailLoader = new Loader();
            liverailLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
            liverailLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
            liverailLoader.load(urlResource);
        }
    }

    private function onLoadComplete(event:Event):void {
        adManager = liverailLoader.content;
        outerViewableSprite.addChild(adManager);
        setupAdManager();
    }

    private function onLoadError(e:IOErrorEvent):void {
    }

    private function setupAdManager():void {
        adManager.addEventListener(LiveRailEvent.INIT_COMPLETE, onLiveRailInitComplete);
        adManager.addEventListener(LiveRailEvent.AD_BREAK_START, adbreakStart);
        adManager.addEventListener(LiveRailEvent.AD_BREAK_COMPLETE, adbreakComplete);
        adManager.addEventListener(LiveRailEvent.PREROLL_COMPLETE, onLiveRailPrerollComplete);
        adManager.addEventListener(LiveRailEvent.AD_START, onLiveRailAdStart);

        /*adManager.addEventListener(LiveRailEvent.INIT_ERROR, onLiveRailInitError);
         adManager.addEventListener(LiveRailEvent.POSTROLL_COMPLETE, onLiveRailPostrollComplete);
         adManager.addEventListener(LiveRailEvent.AD_END, onLiveRailAdEnd);
         adManager.addEventListener(LiveRailEvent.CLICK_THRU, onLiveRailClickThru);
         adManager.addEventListener(LiveRailEvent.VOLUME_CHANGE, onLiveRailVolumeChange);

         */

        liverailConfig = getSetting(LiverailConstants.CONFIG_OBJECT) as LiverailConfiguration;
        resumePosition = getSetting(LiverailConstants.RESUME_POSITION) as int;
        adManager.initAds(liverailConfig.config);
        adMarkers = liverailConfig.adPositions;
    }

    private function set adMarkers(adMarkers:Array):void {
        if (adMetadata) {
            adMetadata.adMarkers = adMarkers;
        }
    }

    private function onLiveRailAdStart(event:Event):void {
        logger.debug("onLiveRailAdStart");
    }

    private function onLiveRailPrerollComplete(event:Event):void {
        logger.debug("onLiveRailPrerollComplete");

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

        //        if (resumePosition == 0) {
        //            adManager.onContentStart();
        //        } else {
        //            adbreakComplete();
        //        }

        // adManager.setSize(new Rectangle(0, 0, 672, 378));

        timer = new Timer(CONTENT_UPDATE_INTERVAL);
        timer.addEventListener(TimerEvent.TIMER, onTimerTick);
        timer.start();

        adManager.onContentStart();
    }

    private function adbreakStart(event:Event):void {
        logger.debug("adbreakStart");

        var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;

        if (playTrait) {
            var traitsToBlock:Vector.<String> = new Vector.<String>();
            traitsToBlock[0] = MediaTraitType.SEEK;

            blockedTraits = traitsToBlock;
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

        var adTimeTrait:AdTimeTrait = new AdTimeTrait(80);
        addTrait(MediaTraitType.TIME, adTimeTrait);
    }

    private function adbreakComplete(event:Event = null):void {
        removeTrait(MediaTraitType.PLAY);
        removeTrait(MediaTraitType.TIME);

        var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playTrait) {
            var traitsToBlock:Vector.<String> = new Vector.<String>();
            blockedTraits = traitsToBlock;
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
        }
    }

    public function volume(vol:Number):void {
    }

    public function onContentUpdate(time:Number, duration:Number):void {
        adManager.onContentUpdate(time, duration);
    }

    private function onProxiedTraitsChange(event:MediaElementEvent):void {
        if (event.type == MediaElementEvent.TRAIT_ADD) {
            if (event.traitType == MediaTraitType.DISPLAY_OBJECT && !_innerViewable) {

                // proxiedElement.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onInnerDisplayObjectChange);
                // proxiedElement.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onInnerMediaSizeChange);

                innerViewable = DisplayObjectTrait(proxiedElement.getTrait(MediaTraitType.DISPLAY_OBJECT));

                if (_innerViewable) {
                    addTrait(MediaTraitType.DISPLAY_OBJECT, outerViewable);
                }
            }
        }
        processTrait(event.traitType, true);
    }

    private function set innerViewable(value:DisplayObjectTrait):void {
        if (value != null) {
            if (_innerViewable) {
                _innerViewable.removeEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onInnerDisplayObjectChange);
                _innerViewable.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onInnerMediaSizeChange);
            }

            _innerViewable = value;
            _innerViewable.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onInnerDisplayObjectChange);
            _innerViewable.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onInnerMediaSizeChange);

            updateView();
        }
    }

    private function onInnerDisplayObjectChange(event:DisplayObjectEvent):void {
        updateView();
    }

    private function onInnerMediaSizeChange(event:DisplayObjectEvent):void {
        _innerViewable.displayObject.height = 378;
        _innerViewable.displayObject.width = 672;
    }

    private function updateView():void {
        outerViewableSprite.addChildAt(_innerViewable.displayObject, 0);
        _innerViewable.displayObject.height = 378;
        _innerViewable.displayObject.width = 672;

    }

    private function onTimerTick(event:TimerEvent):void {
        var timeTrait:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;
        if (timeTrait) {
            onContentUpdate(timeTrait.currentTime, timeTrait.duration);
        }
    }

    private function getSetting(key:String):* {
        var metadata:Metadata = resource.getMetadataValue(LiverailConstants.SETTINGS_NAMESPACE) as Metadata;
        return metadata ? metadata.getValue(key) : null;
    }
}
}