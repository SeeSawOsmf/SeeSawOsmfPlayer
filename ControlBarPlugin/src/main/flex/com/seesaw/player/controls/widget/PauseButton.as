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
import com.seesaw.player.events.AdEvents;
import com.seesaw.player.traits.ads.AdState;
import com.seesaw.player.traits.ads.AdTrait;
import com.seesaw.player.traits.ads.AdTraitType;

import controls.seesaw.widget.interfaces.IWidget;

import flash.events.Event;
import flash.events.MouseEvent;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.chrome.widgets.ButtonWidget;
import org.osmf.events.PlayEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;

public class PauseButton extends ButtonWidget implements IWidget {
    private var logger:ILogger = LoggerFactory.getClassLogger(PauseButton);

    // Internals

    private var _playable:PlayTrait;

    /* static */
    private static const QUALIFIED_NAME:String = "com.seesaw.player.controls.widget.PauseButton";
    private static const _requiredTraits:Vector.<String> = new Vector.<String>;
    private var _adTrait:AdTrait;
    _requiredTraits[0] = MediaTraitType.PLAY;

    public function PauseButton() {
        logger.debug("Pause Button Constructor");
        buttonMode = true;
    }

    // Protected
    //

    protected function get playable():PlayTrait {
        return _playable;
    }

    // Overrides
    //

    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function processRequiredTraitsAvailable(element:MediaElement):void {
        _playable = element.getTrait(MediaTraitType.PLAY) as PlayTrait;
        _playable.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
        _playable.addEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
        adTrait = media ? media.getTrait(AdTraitType.AD_PLAY) as AdTrait : null;
        if (adTrait) {
            adTrait.addEventListener(AdEvents.PLAY_PAUSE_CHANGE, visibilityDeterminingAdEventHandler);
        }
        visibilityDeterminingEventHandler();
    }

    override protected function processRequiredTraitsUnavailable(element:MediaElement):void {
        if (_playable) {
            _playable.removeEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
            _playable.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
            _playable = null;
        }

        visibilityDeterminingEventHandler();
    }

    override protected function onMouseClick(event:MouseEvent):void {
        var playable:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
        adTrait = media ? media.getTrait(AdTraitType.AD_PLAY) as AdTrait : null;
        if (adTrait)
            if (adTrait.adState == AdState.AD_STARTED) {

                adTrait.pause();

            } else if (!adTrait) {
                playable.pause();
            }

    }

    // Stubs
    //

    protected function visibilityDeterminingEventHandler(event:Event = null):void {
        logger.debug("VISIBLE = " + (playable && playable.playState != PlayState.PAUSED && playable.canPause));
        if (adTrait)
            if (adTrait.adState == AdState.AD_STOPPED) {
                visible = playable && playable.playState != PlayState.PAUSED && playable.canPause;
            }
    }


    private function visibilityDeterminingAdEventHandler(event:AdEvents):void {
        visible = adTrait && adTrait.playPauseState == AdState.PLAYING;
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }

    public function get adTrait():AdTrait {
        return _adTrait;
    }

    public function set adTrait(value:AdTrait):void {
        _adTrait = value;
    }
}
}