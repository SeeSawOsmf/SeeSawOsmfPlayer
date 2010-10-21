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

package controls.seesaw.widget {
import controls.seesaw.widget.interfaces.*;
import controls.seesaw.widget.*;

import com.seesaw.proxyplugin.traits.FullScreenTrait;

import controls.seesaw.widget.interfaces.IWidget;

import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.chrome.widgets.ButtonWidget;

import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayTrait;

public class SubtitlesButton extends ButtonWidget implements IWidget {
    private var logger:ILogger = LoggerFactory.getClassLogger(SubtitlesButton);

    // Internals

    private var _playableTrait:PlayTrait;
    private var _fullscreenTrait:FullScreenTrait;

    private var subtitlesOn:Boolean;

    private var subtitlesLabel:TextField;

    /* static */
    private static const QUALIFIED_NAME:String = "controls.seesaw.widget.SubtitlesButton";

    private static const _requiredTraits:Vector.<String> = new Vector.<String>;
    _requiredTraits[0] = MediaTraitType.PLAY;

    public function SubtitlesButton() {
        logger.debug("Subtitles Constructor");
        subtitlesLabel = new TextField();
        subtitlesLabel.text = "Subtitles are off";
        this.formatLabelFont();

        addChild(subtitlesLabel);
    }

    // Protected
    //

    private function formatLabelFont():void {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 12;
        textFormat.color = 0x00A78D;
        textFormat.align = "right";
        this.subtitlesLabel.setTextFormat(textFormat);
    }

    protected function subtitlesHandler(event:Event):void {
        /*if(_fullscreenTrait) {
            logger.debug("NEW STAGE HEIGHT : " + stage.stageHeight);
            logger.debug("NEW STAGE WIDTH : " + stage.stageWidth);
            _fullscreenTrait.fullscreen = !_fullscreenTrait.fullscreen;
        }*/
    }

    protected function get playable():PlayTrait {
        return _playableTrait;
    }

    // Overrides
    //

    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function processRequiredTraitsAvailable(element:MediaElement):void {
        _playableTrait = element.getTrait(MediaTraitType.PLAY) as PlayTrait;
        _fullscreenTrait = element.getTrait(FullScreenTrait.FULL_SCREEN) as FullScreenTrait;

        //stage.addEventListener(Event.RESIZE, subtitlesHandler);

        //_playable.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
        //_playable.addEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);

        //visibilityDeterminingEventHandler();
    }

    override protected function processRequiredTraitsUnavailable(element:MediaElement):void {
        if (_playableTrait) {
            //_playable.removeEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
            //_playable.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
            //_playable = null;
        }

        //visibilityDeterminingEventHandler();
    }

    override protected function onMouseClick(event:MouseEvent):void {
        if (this.subtitlesOn == false) {
            subtitlesLabel.text = "Subtitles are on";
            this.subtitlesOn = true;
        } else {
            subtitlesLabel.text = "Subtitles are off";
            this.subtitlesOn = false;
        }
        //var playable:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
        //playable.play();
    }

    // Stubs
    //

    protected function visibilityDeterminingEventHandler(event:Event = null):void {
        //visible = playable && playable.playState != PlayState.PAUSED && playable.canPause;
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }
}
}