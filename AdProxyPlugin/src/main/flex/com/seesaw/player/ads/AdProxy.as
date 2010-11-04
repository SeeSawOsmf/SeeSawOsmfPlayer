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
import com.seesaw.player.events.AdEvent;
import com.seesaw.player.namespaces.contentinfo;
import com.seesaw.player.traits.ads.AdState;
import com.seesaw.player.traits.ads.AdTrait;
import com.seesaw.player.traits.ads.AdTraitType;

import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
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
import org.osmf.traits.AudioTrait;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.TimeTrait;

public class AdProxy extends ProxyElement {

    use namespace contentinfo;

    private var logger:ILogger = LoggerFactory.getClassLogger(AdProxy);

    private static const CONTENT_UPDATE_INTERVAL:int = 500;

    private var _adTrait:AdTrait;
    private var _innerViewable:DisplayObjectTrait;
    private var outerViewable:AdProxyDisplayObjectTrait;
    private var outerViewableSprite:Sprite;

    private var _adManager:*;
    private var liverailLoader:Loader;
    private var liverailConfig:LiverailConfig;
    private var _contentInfoResource:XML;

    public function AdProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);

        Security.allowDomain("vox-static.liverail.com");


    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            super.proxiedElement = proxiedElement;

            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onProxiedTraitsChange);
            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onProxiedTraitsChange);

            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onProxiedTraitsChange);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onProxiedTraitsChange);

            outerViewableSprite = new Sprite();
            outerViewable = new AdProxyDisplayObjectTrait(outerViewableSprite);


            createLiverail();
        }
    }

    override protected function setupTraits():void {
        logger.debug("setupTraits");
        addLocalTraits();
        super.setupTraits();
    }

    private function playPauseEventHandler(event:AdEvent):void {
        if (_adTrait && _adTrait.adState == AdState.STARTED) {
            if (_adTrait.playState == AdState.PLAYING) {
                play();
            } else if (_adTrait.playState == AdState.PAUSED) {
                pause();
            }
            else {
                logger.warn("invalid play state: " + _adTrait.playState);
            }
        }
    }

    private function processTrait(traitType:String, added:Boolean):void {
        logger.debug(" --------- traitType -----------" + traitType);
        switch (traitType) {
            case MediaTraitType.LOAD:
                toggleLoadListeners(added);
                break;
            case MediaTraitType.PLAY:
                togglePlayListeners(added);
                break;
            case MediaTraitType.AUDIO:
                toggleAudioListeners(added);
                break;
        }
    }

    private function togglePlayListeners(added:Boolean):void {
        var playable:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playable) {
            if (added) {
                playable.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
                playable.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, onCanPauseChange);
            }
            else {
                playable.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
                playable.removeEventListener(PlayEvent.CAN_PAUSE_CHANGE, onCanPauseChange);
            }
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
                loadable.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);

            }
            else {
                loadable.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadableStateChange);
                loadable.removeEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);
            }
        }
    }

    private function onLoadableStateChange(event:LoadEvent):void {
        var playTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;

        if (playTrait) {
            playTrait.pause();
        }
    }

    private function onBytesTotalChange(event:LoadEvent):void {
        /// logger.debug("Load onBytesTotal change:{0}", event.bytes);
    }

    private function onCanPauseChange(event:PlayEvent):void {
        logger.debug("Can Pause Change:{0}", event.canPause);
    }

    private function onPlayStateChange(event:PlayEvent):void {
        logger.debug("Play State Change:{0}", event.playState);
    }

    private function onMutedChange(event:AudioEvent):void {
        logger.debug("Mute change: {0}", event.muted);
    }

    private function onVolumeChange(event:AudioEvent):void {

        _adManager.setVolume(event.volume, false);
    }

    private function createLiverail():void {
        // TODO: maybe we can get this from metadata
        var liverailPath:String = "http://vox-static.liverail.com/swf/v4/admanager.swf";
        var urlResource:URLRequest = new URLRequest(liverailPath);

        liverailLoader = new Loader();
        liverailLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
        liverailLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        liverailLoader.load(urlResource);
    }


    private function onLoadComplete(event:Event):void {
        logger.debug("Liverail Loaded ---- onLoadComplete")
        _adManager = liverailLoader.content;
        outerViewableSprite.addChild(_adManager);

        setupAdManager();
    }

    private function onLoadError(e:IOErrorEvent):void {
        removeLocalTraits();
    }

    private function setupAdManager():void {
        _adManager.addEventListener(LiveRailEvent.INIT_COMPLETE, onLiveRailInitComplete);
        _adManager.addEventListener(LiveRailEvent.AD_BREAK_START, adbreakStart);
        _adManager.addEventListener(LiveRailEvent.AD_BREAK_COMPLETE, adbreakComplete);
        _adManager.addEventListener(LiveRailEvent.PREROLL_COMPLETE, onLiveRailPrerollComplete);
        _adManager.addEventListener(LiveRailEvent.AD_START, onLiveRailAdStart);
        /*adManager.addEventListener(LiveRailEvent.INIT_ERROR, onLiveRailInitError);


         adManager.addEventListener(LiveRailEvent.POSTROLL_COMPLETE, onLiveRailPostrollComplete);


         adManager.addEventListener(LiveRailEvent.AD_END, onLiveRailAdEnd);

         adManager.addEventListener(LiveRailEvent.CLICK_THRU, onLiveRailClickThru);
         adManager.addEventListener(LiveRailEvent.VOLUME_CHANGE, onLiveRailVolumeChange);

         adManager.addEventListener(LiveRailEvent.AD_PROGRESS,onAdProgress);
         */


        _contentInfoResource = resource.getMetadataValue("contentInfo") as XML;
        liverailConfig = new LiverailConfig(_contentInfoResource);
        _adManager.initAds(liverailConfig.config);
        _adTrait.createMarkers(liverailConfig.adPositions);

    }

    private function onLiveRailAdStart(e:Event):void {

    }

    private function onLiveRailPrerollComplete(event:Event):void {

    }

    private function onLiveRailInitComplete(event:Event):void {
        logger.debug("Liverail ---- onLiveRailInitComplete")
        // _adManager.setSize(new Rectangle(0, 0, outerViewable.mediaWidth, outerViewable.mediaHeight));

        _adManager.setSize(new Rectangle(0, 0, 672, 378));   ///todo use the actual stageWidth to set the adModule.

        if (_contentInfoResource.resume == 0) {
            _adManager.onContentStart();
        } else {
            adbreakComplete();
        }

        var timer:Timer = new Timer(CONTENT_UPDATE_INTERVAL);
        timer.addEventListener(TimerEvent.TIMER, onTimerTick);
        timer.start();

    }

    private function adbreakStart(event:Event):void {
        if (proxiedElement != null) {
            var playTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;

            if (playTrait) {
                var traitsToBlock:Vector.<String> = new Vector.<String>();
                traitsToBlock[0] = MediaTraitType.SEEK;
                traitsToBlock[1] = MediaTraitType.TIME;

                blockedTraits = traitsToBlock;
                playTrait.pause();
            }

            if (_adTrait) {
                _adTrait.started();
            }
        }
    }

    private function adbreakComplete(event:Event = null):void {
        if (proxiedElement != null) {

            blockedTraits = new Vector.<String>();

            if (_adTrait) {
                _adTrait.stopped();
            }

            var playTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;

            if (playTrait) {

                playTrait.play();
            }
        }
        // var ob:Object = proxiedElement.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE);

    }

    public function volume(vol:Number):void {

    }

    public function pause():void {
        _adManager.pauseAd();
    }

    public function play():void {
        _adManager.resumeAd();
    }

    public function onContentUpdate(time:Number, duration:Number):void {
        _adManager.onContentUpdate(time, duration);
    }

    private function onProxiedTraitsChange(event:MediaElementEvent):void {
        if (event.type == MediaElementEvent.TRAIT_ADD) {
            if (event.traitType == MediaTraitType.DISPLAY_OBJECT && !_innerViewable) {

                proxiedElement.removeEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onInnerDisplayObjectChange);
                proxiedElement.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onInnerMediaSizeChange);

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
        if (proxiedElement != null) {
            var timeTrait:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;
            var playTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;

            if (timeTrait && playTrait && playTrait.playState == PlayState.PLAYING) {
                onContentUpdate(timeTrait.currentTime, timeTrait.duration);
            }
        }
    }

    private function addLocalTraits():void {
        if (_adTrait == null) {
            _adTrait = new AdTrait();
            _adTrait.addEventListener(AdEvent.PLAY_PAUSE_CHANGE, playPauseEventHandler);
            addTrait(AdTraitType.AD_PLAY, _adTrait);
        }
    }

    private function removeLocalTraits():void {
        removeTrait(AdTraitType.AD_PLAY);
        if (_adTrait) {
            _adTrait.removeEventListener(AdEvent.PLAY_PAUSE_CHANGE, playPauseEventHandler);
            _adTrait = null;
        }
    }
}
}