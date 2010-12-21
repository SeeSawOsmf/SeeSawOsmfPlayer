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
package com.seesaw.player.controls.widget {
import com.seesaw.player.events.AdEvent;
import com.seesaw.player.ads.AdState;
import com.seesaw.player.traits.ads.AdTrait;
import com.seesaw.player.traits.ads.AdTraitType;

import flash.events.Event;

import flash.external.ExternalInterface;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.events.PlayEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;

public class PlayPauseButtonBase extends ButtonWidget {

    private var logger:ILogger = LoggerFactory.getClassLogger(PlayPauseButtonBase);

    private var _playTrait:PlayTrait;
    private var _adTrait:AdTrait;

    private var _requiredTraits:Vector.<String> = new Vector.<String>;

    public function PlayPauseButtonBase() {
        logger.debug("PlayPauseButtonBase()");
        _requiredTraits[0] = MediaTraitType.PLAY;
        this.setupExternalInterface();
    }

    private function setupExternalInterface():void {
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("playPause", this.playPause);
        }
    }

    private function playPause():void {
        if ((adMode && adPlaying) || playing) {
            if (adMode && adPlaying) {
                logger.debug("pausing ad");
                adTrait.pause();
            }
            else if (playing) {
                logger.debug("pausing main content");
                playTrait.pause();
            }
        } else if ((adMode && adPaused) || paused) {
            if (adMode && adPaused) {
                logger.debug("ad paused");
                adTrait.play();
            }
            else if (paused) {
                logger.debug("main content paused");
                playTrait.play();
            }
        }
    }

    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function processRequiredTraitsAvailable(element:MediaElement):void {
        _playTrait = element.getTrait(MediaTraitType.PLAY) as PlayTrait;
        _playTrait.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
        _playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);

        _adTrait = element.getTrait(AdTraitType.AD_PLAY) as AdTrait;
        if (_adTrait) {
            _adTrait.addEventListener(AdEvent.AD_STATE_CHANGE, visibilityDeterminingEventHandler);
            _adTrait.addEventListener(AdEvent.PLAY_PAUSE_CHANGE, visibilityDeterminingEventHandler);
        }

        visibilityDeterminingEventHandler();
    }

    override protected function processRequiredTraitsUnavailable(element:MediaElement):void {
        if (_playTrait) {
            _playTrait.removeEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
            _playTrait.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
            _playTrait = null;
        }

        if (_adTrait) {
            _adTrait.removeEventListener(AdEvent.AD_STATE_CHANGE, visibilityDeterminingEventHandler);
            _adTrait.removeEventListener(AdEvent.PLAY_PAUSE_CHANGE, visibilityDeterminingEventHandler);
            _adTrait = null;
        }
    }

    protected function visibilityDeterminingEventHandler(event:Event = null):void {
        updateVisibility();
    }

    /**
     * Override this in a base class.
     */
    protected function updateVisibility():void {
        visible = false;
    }

    protected function get paused():Boolean {
        return playTrait && playTrait.playState == PlayState.PAUSED;
    }

    protected function get playing():Boolean {
        return playTrait && playTrait.playState == PlayState.PLAYING;
    }

    protected function get adMode():Boolean {
        return adTrait && adTrait.adState == AdState.STARTED;
    }

    protected function get adPaused():Boolean {
        return adTrait && adTrait.playState == AdState.PAUSED;
    }

    protected function get adPlaying():Boolean {
        return adTrait && adTrait.playState == AdState.PLAYING;
    }

    public function get playTrait():PlayTrait {
        return _playTrait;
    }

    public function set playTrait(value:PlayTrait):void {
        _playTrait = value;
    }

    public function get adTrait():AdTrait {
        return _adTrait;
    }

    public function set adTrait(value:AdTrait):void {
        _adTrait = value;
    }
}
}