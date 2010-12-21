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

package com.seesaw.player.playlist {
import com.seesaw.player.ads.AdState;
import com.seesaw.player.events.AdEvent;
import com.seesaw.player.traits.ads.AdTrait;
import com.seesaw.player.traits.ads.AdTraitType;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.Timer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ParallelElement;
import org.osmf.elements.ProxyElement;
import org.osmf.elements.VideoElement;
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.SeekEvent;
import org.osmf.events.TimeEvent;
import org.osmf.media.MediaElement;
import org.osmf.net.NetLoader;
import org.osmf.net.StreamingURLResource;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class PlaylistlElement extends ProxyElement {


    public var contentInfo:XML;
    private var _adTrait:AdTrait;

    private var logger:ILogger = LoggerFactory.getClassLogger(PlaylistlElement);
    private var _proxiedElement:MediaElement;
    private var _isVASTLoaded:Boolean;
    private var _timer:Timer;
    private var _VASTLoader:URLLoader;
    private var _instreamAdElement:VideoElement;
    private var _adShown:Boolean;
    private const AD_INTERVAL:int = 10;
    private var AD_SERVER_LOCATION:String = "../src/test/resources/adPlaylist.xml";
    private var proxiedElementTimeTrait:TimeTrait;
    private var instreamAdProxiedElementTimeTrait:TimeTrait;
    private var adList:Array;
    private var autoResume:Number;


    public function PlaylistlElement() {
        logger.debug("Initialising PlaylistElement");
        _timer = new Timer(1000);
        _timer.addEventListener(TimerEvent.TIMER, onTimerTick);
        _timer.start();

    }

    private function loadVASTDocument():void {
        _VASTLoader = new URLLoader();
        _VASTLoader.addEventListener(Event.COMPLETE, onVASTDocumentLoaded);
        _VASTLoader.addEventListener(IOErrorEvent.IO_ERROR, onVASTError);
        _VASTLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onVASTError);
        _VASTLoader.load(new URLRequest(AD_SERVER_LOCATION));
    }

    private function onVASTDocumentLoaded(e:Event):void {
        trace("onVastLoaded");

        var data:XML = XML(e.currentTarget.data);
        var url:String = String(data.ENTRY[1].REF.@HREF);
        adList = new AdMap().createPlaylistEntry(data);

        _instreamAdElement = new VideoElement(new StreamingURLResource(url), new NetLoader);
        _instreamAdElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
        _isVASTLoaded = true;

        if (_proxiedElement) {
            proxiedElement = _proxiedElement;
        }
    }

    private function onVASTError(e:ErrorEvent):void {
        trace(e.text);
    }

    private function onTimerTick(e:TimerEvent):void {
        // Only attempt to switch proxiedElements around if both a wrapped and advert element exist
        if (proxiedElement && _instreamAdElement) {
            proxiedElementTimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;


            if (proxiedElementTimeTrait && proxiedElementTimeTrait.currentTime && proxiedElementTimeTrait.currentTime > 1) {
                if (!_adShown && ( int(proxiedElementTimeTrait.currentTime) % AD_INTERVAL == 0 )) {
                    _adShown = true;

                    var traitsToBlock:Vector.<String> = new Vector.<String>();

                    blockedTraits = traitsToBlock;

                    _proxiedElement = proxiedElement;

                    if (_proxiedElement.hasTrait(MediaTraitType.PLAY)) {
                        ( _proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait ).pause();
                    }

                    proxiedElement = _instreamAdElement;

                    _timer.stop();
                    trace('changing to ad');
                }

            }
        }
    }


    public override function set proxiedElement(value:MediaElement):void {
        var element:VideoElement = new VideoElement();
        if (value && value is VideoElement) {
            element = value as VideoElement;
            trace("ProxiedElement Created");

            if (!_isVASTLoaded) {
                loadVASTDocument();
            }
        }
        if (!_proxiedElement) {
            if (value) {
                _proxiedElement = value;
                if (!autoResume) {
                    //   autoResume = _proxiedElement.resource.getMetadataValue("contentInfo").resume as Number;
                    autoResume = 3000;
                }
                _proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
                _proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
            }

        }

        super.proxiedElement = element;


    }

    private function onTraitAdd(event:MediaElementEvent):void {
        processTrait(event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        processTrait(event.traitType, false);
    }


    override protected function setupTraits():void {

        var traitType:String

        if (_proxiedElement != null) {
            // Clear our old listeners.
            _proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            _proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

            for each (traitType in _proxiedElement.traitTypes) {
                processTrait(traitType, false);
            }
        }


        if (_proxiedElement != null) {
            // Listen for traits being added and removed.
            _proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            _proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

            for each (traitType in _proxiedElement.traitTypes) {
                processTrait(traitType, true);
            }
        }
        addLocalTraits();
        super.setupTraits();


    }


    private function processTrait(traitType:String, added:Boolean):void {
        switch (traitType) {

            case MediaTraitType.LOAD:
                toggleLoadListeners(added);
                break;

            case MediaTraitType.PLAY:
                togglePlayListeners(added);
                break;

            case MediaTraitType.TIME:
                setUpTimeListeners(added)
                break;
            case MediaTraitType.SEEK:
                toggleSeekListeners(added)
                break;
        }
        logger.debug(traitType);
    }

    private function setUpTimeListeners(added:Boolean):void {
        if (_instreamAdElement) {
            instreamAdProxiedElementTimeTrait = _instreamAdElement.getTrait(MediaTraitType.TIME) as TimeTrait;
            if (instreamAdProxiedElementTimeTrait) {
                instreamAdProxiedElementTimeTrait.addEventListener(TimeEvent.COMPLETE, onComplete);
            }
        }
    }


    private function togglePlayListeners(added:Boolean):void {
        if (_instreamAdElement) {
            var play:PlayTrait = _instreamAdElement.getTrait(MediaTraitType.PLAY) as PlayTrait;

            if (play) {

                ( _instreamAdElement.getTrait(MediaTraitType.PLAY) as PlayTrait ).play();
                _adTrait.started();

            }
        }
    }

    private function toggleSeekListeners(added:Boolean):void {
        var seek:SeekTrait = _proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
        if (seek) {
            seek.seek(autoResume);
            seek.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
        } else {
            seek.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
        }
    }

    private function onSeekingChange(event:SeekEvent):void {
        logger.debug("On Seek Change:{0}", event.seeking);
    }

    private function toggleLoadListeners(added:Boolean):void {
        var loadable:LoadTrait = _proxiedElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
        if (loadable) {
            if (added) {
                loadable.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadableStateChange);
                ///  loadable.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);

            }
            else {
                loadable.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadableStateChange);
                ///   loadable.removeEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);
            }
        }
    }

    private function onLoadableStateChange(event:LoadEvent):void {
        var playTrait:PlayTrait = _proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;

        if (playTrait && autoResume == 0) {
            playTrait.pause();
        } else if (playTrait) {
            playTrait.play();
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


    private function playPauseEventHandler(event:AdEvent):void {
        if (_adTrait && _adTrait.adState == AdState.STARTED) {
            if (_adTrait.playState == AdState.PLAYING) {
                //     play();
            } else if (_adTrait.playState == AdState.PAUSED) {
                //    pause();
            }
            else {
                logger.warn("invalid play state: " + _adTrait.playState);
            }
        }
    }

    private function onComplete(event:TimeEvent):void {
        logger.debug("On Complete");

        _adShown = false;
        proxiedElement = _proxiedElement;
        blockedTraits = new Vector.<String>();

        if (_proxiedElement.hasTrait(MediaTraitType.PLAY)) {
            ( _proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait ).play();
            _adTrait.stopped();

            _timer.start();
        }
    }

    public var element:ParallelElement = new ParallelElement();
    /* static */

    private static const ID:String = "ID";
}
}