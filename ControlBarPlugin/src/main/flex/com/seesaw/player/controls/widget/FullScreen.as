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
import com.seesaw.player.ui.PlayerToolTip;
import com.seesaw.player.ui.StyledTextField;

import controls.seesaw.widget.interfaces.IWidget;

import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.ui.Keyboard;

import flash.ui.Mouse;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.chrome.widgets.ButtonWidget;
import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitType;

public class FullScreen extends ButtonWidget implements IWidget {

    private static const QUALIFIED_NAME:String = "com.seesaw.player.controls.widget.FullScreen";
    private static const FULLSCREEN_LABEL:String = "Full Screen";
    private static const EXIT_FULLSCREEN_LABEL:String = "Exit Full Screen";

    private var logger:ILogger = LoggerFactory.getClassLogger(FullScreen);
    private var fullScreenLabel:TextField;
    private var toolTip:PlayerToolTip;
    private var _requiredTraits:Vector.<String> = new Vector.<String>;

    public function FullScreen() {
        logger.debug("FullScreen()");
        _requiredTraits[0] = MediaTraitType.DISPLAY_OBJECT;

        fullScreenLabel = new StyledTextField();
        fullScreenLabel.width = 100;
        fullScreenLabel.text = FULLSCREEN_LABEL;
        formatLabelFont();
        fullScreenLabel.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        fullScreenLabel.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        toolTip = new PlayerToolTip(this, "FullScreen");
        addChild(fullScreenLabel);

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event) {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        stage.addChild(toolTip);
        stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
    }

    private function onMouseOver (event:MouseEvent):void {
        formatLabelHoverFont();
    }

    private function onMouseOut (event:MouseEvent):void {
        formatLabelFont();
    }

    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function processRequiredTraitsAvailable(element:MediaElement):void {
        addEventListener(KeyboardEvent.KEY_DOWN, KeyPressed);
        visible = true;
    }

    override protected function processRequiredTraitsUnavailable(element:MediaElement):void {
        removeEventListener(KeyboardEvent.KEY_DOWN, KeyPressed);
       // visible = false;
    }

    override protected function onMouseClick(event:MouseEvent):void {
        if (stage) {
            setFullScreen(stage.displayState == StageDisplayState.NORMAL);
        }
    }

    private function KeyPressed(event:KeyboardEvent):void {
        if (event.keyCode == Keyboard.ESCAPE) {
            stage.displayState = StageDisplayState.NORMAL;
        }
    }

    private function setFullScreen(fullScreen:Boolean):void {
        if (stage) {
            if (fullScreen && stage.displayState == StageDisplayState.NORMAL) {
                stage.displayState = StageDisplayState.FULL_SCREEN;
            } else if (!fullScreen && stage.displayState == StageDisplayState.FULL_SCREEN) {
                stage.displayState = StageDisplayState.NORMAL;
            }
        }
    }

    private function onFullScreen(event:FullScreenEvent):void {
        if (event.fullScreen) {
            fullScreenLabel.text = EXIT_FULLSCREEN_LABEL;
            toolTip.updateToolTip(EXIT_FULLSCREEN_LABEL);
        }
        else {
            fullScreenLabel.text = FULLSCREEN_LABEL;
            toolTip.updateToolTip(FULLSCREEN_LABEL);
        }
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }

    private function formatLabelFont():void {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 11;
        textFormat.color = 0x00A78D;
        textFormat.align = "right";
        fullScreenLabel.setTextFormat(textFormat);
    }

    private function formatLabelHoverFont():void {
        var textFormat:TextFormat = new TextFormat();
        textFormat.color = 0xFFFFFF;
        fullScreenLabel.setTextFormat(textFormat);
    }
}
}