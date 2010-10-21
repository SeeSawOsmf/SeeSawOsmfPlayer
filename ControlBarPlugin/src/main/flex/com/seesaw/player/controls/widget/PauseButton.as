/*****************************************************
 *
 *  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
 *
 *****************************************************
 *  The contents of this file are subject to the Mozilla Public License
 *  Version 1.1 (the "License"); you may not use this file except in
 *  compliance with the License. You may obtain a copy of the License at
 *  http://www.mozilla.org/MPL/
 *
 *  Software distributed under the License is distributed on an "AS IS"
 *  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *  License for the specific language governing rights and limitations
 *  under the License.
 *
 *
 *  The Initial Developer of the Original Code is Adobe Systems Incorporated.
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems
 *  Incorporated. All Rights Reserved.
 *
 *****************************************************/

package com.seesaw.player.controls.widget {
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
    _requiredTraits[0] = MediaTraitType.PLAY;

    public function PauseButton() {
        logger.debug("Pause Button Constructor");
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
        playable.pause();
    }

    // Stubs
    //

    protected function visibilityDeterminingEventHandler(event:Event = null):void {
        logger.debug("VISIBLE = " + (playable && playable.playState != PlayState.PAUSED && playable.canPause));
        visible = playable && playable.playState != PlayState.PAUSED && playable.canPause;
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }
}
}