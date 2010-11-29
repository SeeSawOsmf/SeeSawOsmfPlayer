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
import com.seesaw.player.events.FullScreenEvent;
import com.seesaw.player.traits.fullscreen.FullScreenTrait;

import com.seesaw.player.ui.PlayerToolTip;
import com.seesaw.player.ui.StyledTextField;

import controls.seesaw.widget.interfaces.IWidget;

import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.ui.Keyboard;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.chrome.widgets.ButtonWidget;
import org.osmf.media.MediaElement;

public class FullScreen extends ButtonWidget implements IWidget {

    private static const QUALIFIED_NAME:String = "com.seesaw.player.controls.widget.FullScreen";

    private static const FULLSCREEN_LABEL:String = "Full Screen";

    private static const EXIT_FULLSCREEN_LABEL:String = "Exit Full Screen";

    private var logger:ILogger = LoggerFactory.getClassLogger(FullScreen);

    private var _fullScreenTrait:FullScreenTrait;

    private var _fullScreenLabel:TextField;

    private var toolTip:PlayerToolTip;

    private var _requiredTraits:Vector.<String> = new Vector.<String>;

    public function FullScreen() {

        //var toolTip = new PlayerToolTip();

        this.toolTip = new PlayerToolTip(this, "FullScreen");

        logger.debug("FullScreen()");

        _requiredTraits[0] = FullScreenTrait.FULL_SCREEN;

        createView();

        this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
    }

    private function onAddedToStage(event:Event) {
        stage.addChild(this.toolTip);
    }

    public override function layout(availableWidth:Number, availableHeight:Number, deep:Boolean = true):void
    {
       super.layout(availableWidth, availableHeight, deep);
     }

    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function processRequiredTraitsAvailable(element:MediaElement):void {
        _fullScreenTrait = element.getTrait(FullScreenTrait.FULL_SCREEN) as FullScreenTrait;

        if (_fullScreenTrait) {
            _fullScreenTrait.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
            addEventListener(KeyboardEvent.KEY_DOWN, KeyPressed);
            this.formatLabelFont();
            addChild(_fullScreenLabel);
        }

        visible = media.hasTrait(FullScreenTrait.FULL_SCREEN);
    }

    private function formatLabelFont():void {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 12;
        textFormat.color = 0x00A78D;
        textFormat.align = "right";
        this._fullScreenLabel.setTextFormat(textFormat);
        this._fullScreenLabel.autoSize = TextFieldAutoSize.RIGHT;
    }

    override protected function processRequiredTraitsUnavailable(element:MediaElement):void {
        if (_fullScreenTrait) {
            _fullScreenTrait.removeEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen);
            removeEventListener(KeyboardEvent.KEY_DOWN, KeyPressed);
            removeChild(_fullScreenLabel);
            _fullScreenTrait = null;
        }

        visible = media.hasTrait(FullScreenTrait.FULL_SCREEN);
    }

    override protected function onMouseClick(event:MouseEvent):void {
        setFullScreen(!_fullScreenTrait.fullscreen);
    }

    private function KeyPressed(event:KeyboardEvent):void {
        if (_fullScreenTrait && _fullScreenTrait.fullscreen == true && event.keyCode == Keyboard.ESCAPE) {
            _fullScreenTrait.fullscreen = false;
        }
    }

    private function setFullScreen(fullScreen:Boolean):void {
        if (_fullScreenTrait) {
            if (fullScreen && stage.displayState == StageDisplayState.NORMAL) {
                stage.displayState = StageDisplayState.FULL_SCREEN;
            } else if (!fullScreen && stage.displayState == StageDisplayState.FULL_SCREEN) {
                stage.displayState = StageDisplayState.NORMAL;
            }
            _fullScreenTrait.fullscreen = fullScreen;
        }
    }

    private function onFullScreen(event:FullScreenEvent):void {
        if (event.value) {
            _fullScreenLabel.text = EXIT_FULLSCREEN_LABEL;
            this.toolTip.updateToolTip(EXIT_FULLSCREEN_LABEL);
        }
        else {
            _fullScreenLabel.text = FULLSCREEN_LABEL;
            this.toolTip.updateToolTip(FULLSCREEN_LABEL);
        }
    }

    private function createView():void {
        _fullScreenLabel = new StyledTextField();
        _fullScreenLabel.text = FULLSCREEN_LABEL;
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }
}
}