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
import com.seesaw.player.events.AdEvents;
import com.seesaw.player.traits.ads.AdState;
import com.seesaw.player.traits.ads.AdTrait;
import com.seesaw.player.traits.ads.AdTraitType;

import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.Security;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.DisplayObjectEvent;
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.PlayEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;

public class AdProxy extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(AdProxy);

    private var _adTrait:AdTrait;
    private var _innerViewable:DisplayObjectTrait;
    private var outerViewable:AdProxyDisplayObjectTrait;
    private var displayObject:Sprite;

    private var _adManager:*;
    private var liverailLoader:Loader;
    private var liverailConfig:LiverailConfig;

    public function AdProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);

        Security.allowDomain("*");

        displayObject = new Sprite();
        outerViewable = new AdProxyDisplayObjectTrait(displayObject);
    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {

            super.proxiedElement = proxiedElement;

            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onProxiedTraitsChange);
            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onProxiedTraitsChange);

            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onProxiedTraitsChange);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onProxiedTraitsChange);

            var traitType:String
            for each (var traitType:String in proxiedElement.traitTypes) {
                processTrait(traitType, true);
            }

            createLiverail();
        }
    }

    override protected function setupTraits():void {
        logger.debug("setupTraits");

        _adTrait = new AdTrait();
        _adTrait.addEventListener(AdEvents.PLAY_PAUSE_CHANGE, playPauseEventHandler);
        addTrait(AdTraitType.AD_PLAY, _adTrait);

        super.setupTraits();
    }

    private function playPauseEventHandler(event:AdEvents):void {
        if (_adTrait && _adTrait.playPauseState == AdState.PLAYING) {
            pause();
        } else if (_adTrait && _adTrait.playPauseState == AdState.PAUSED) {
            play();
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
        displayObject.addChild(_adManager);

        setupAdManager();
    }

    private function onLoadError(e:IOErrorEvent):void {
        removeTrait(AdTraitType.AD_PLAY);
    }

    private function setupAdManager():void {
        _adManager.addEventListener(LiveRailEvent.INIT_COMPLETE, onLiveRailInitComplete);
        _adManager.addEventListener(LiveRailEvent.AD_BREAK_START, adbreakStart);
        _adManager.addEventListener(LiveRailEvent.AD_BREAK_COMPLETE, adbreakComplete);

        /*adManager.addEventListener(LiveRailEvent.INIT_ERROR, onLiveRailInitError);

         adManager.addEventListener(LiveRailEvent.PREROLL_COMPLETE, onLiveRailPrerollComplete);
         adManager.addEventListener(LiveRailEvent.POSTROLL_COMPLETE, onLiveRailPostrollComplete);

         adManager.addEventListener(LiveRailEvent.AD_START, onLiveRailAdStart);
         adManager.addEventListener(LiveRailEvent.AD_END, onLiveRailAdEnd);

         adManager.addEventListener(LiveRailEvent.CLICK_THRU, onLiveRailClickThru);
         adManager.addEventListener(LiveRailEvent.VOLUME_CHANGE, onLiveRailVolumeChange);

         adManager.addEventListener(LiveRailEvent.AD_PROGRESS,onAdProgress);
         */

        liverailConfig = new LiverailConfig();
        _adManager.initAds(liverailConfig.config);
    }

    private function onLiveRailInitComplete(e:Event):void {
        logger.debug("Liverail ---- onLiveRailInitComplete")
        _adManager.setSize(new Rectangle(0, 0, outerViewable.mediaWidth, outerViewable.mediaHeight));
        _adManager.onContentStart();
    }

    private function adbreakStart(e:Event):void {
        if (proxiedElement != null) {
            var playTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;

            if (_adTrait) {
                if (_adTrait.adState == AdState.AD_STOPPED) {
                    _adTrait.adStarted();
                }
            }
            if (playTrait) {    /// todo 
                if (playTrait.playState == PlayState.PLAYING) {

                    var traitsToBlock:Vector.<String> = new Vector.<String>();
                    traitsToBlock[0] = MediaTraitType.SEEK;
                    traitsToBlock[1] = MediaTraitType.TIME;

                    blockedTraits = traitsToBlock;
                    playTrait.pause();
                }
            }
        }
    }

    private function adbreakComplete(e:Event):void {
        if (proxiedElement != null) {

            var playTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;

            if (_adTrait.adState == AdState.AD_STARTED) {
                _adTrait.adStopped();
            }

            if (playTrait) {
                if (playTrait.playState == PlayState.PAUSED) {
                    blockedTraits = new Vector.<String>();
                    playTrait.play();
                }
            }
        }
    }

    public function volume(vol:Number):void {
        _adManager.setVolume(vol / 10, false);
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
            if (event.traitType == MediaTraitType.DISPLAY_OBJECT) {
                innerViewable = DisplayObjectTrait(proxiedElement.getTrait(event.traitType));
                if (_innerViewable) {
                    addTrait(MediaTraitType.DISPLAY_OBJECT, outerViewable);
                }
            }
        } else {
            if (event.traitType == MediaTraitType.DISPLAY_OBJECT) {
                innerViewable = null;
                removeTrait(MediaTraitType.DISPLAY_OBJECT);
            }
        }
    }

    private function set innerViewable(value:DisplayObjectTrait):void {
        if (_innerViewable != value) {
            if (_innerViewable) {
                _innerViewable.removeEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onInnerDisplayObjectChange);
                _innerViewable.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onInnerMediaSizeChange);
            }

            _innerViewable = value;

            if (_innerViewable) {
                _innerViewable.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onInnerDisplayObjectChange);
                _innerViewable.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onInnerMediaSizeChange);
            }

            updateView();
        }
    }

    private function onInnerDisplayObjectChange(event:DisplayObjectEvent):void {
        updateView();
    }

    private function onInnerMediaSizeChange(event:DisplayObjectEvent):void {
        outerViewable.setSize(event.newWidth, event.newHeight);
    }

    private function updateView():void {
        if (_innerViewable == null
                || _innerViewable.displayObject == null
                || displayObject.contains(_innerViewable.displayObject) == false
                ) {
            if (displayObject.numChildren == 2) {
                displayObject.removeChildAt(0);
            }
        }

        if (_innerViewable != null
                && _innerViewable.displayObject != null
                && displayObject.contains(_innerViewable.displayObject) == false
                ) {
            displayObject.addChildAt(_innerViewable.displayObject, 0);
        }

    }
}
}