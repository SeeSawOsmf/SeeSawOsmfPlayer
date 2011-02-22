/*
 * The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *   The Initial Developer of the Original Code is Arqiva Ltd.
 *   Portions created by Arqiva Limited are Copyright (C) 2010, 2011 Arqiva Limited.
 *   Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe
 * 	Systems Incorporated.
 *   All Rights Reserved.
 *
 *   Contributor(s):  Adobe Systems Incorporated
 */

package com.seesaw.player.controls.widget {
import com.seesaw.player.ui.PlayerToolTip;

import controls.seesaw.widget.interfaces.IWidget;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

public class PlayButton extends PlayPauseButtonBase implements IWidget {

    private var toolTip:PlayerToolTip;
    private static const QUALIFIED_NAME:String = "com.seesaw.player.controls.widget.PlayButton";

    public function PlayButton() {
        this.toolTip = new PlayerToolTip(this, "Play");
        this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
    }

    private function onAddedToStage(event:Event) {
        stage.addChild(this.toolTip);
        stage.addEventListener(KeyboardEvent.KEY_UP, this.onKeyPress);
    }

    override protected function updateVisibility():void {
        visible = paused;
    }

    override protected function onMouseClick(event:MouseEvent):void {
        playPause();
        updateVisibility();
        updateMetadata();

    }

    protected function onKeyPress(event:KeyboardEvent):void {
        if (event.keyCode == Keyboard.SPACE) {
            if (visible) {
                playTrait.play();
                updateMetadata();
            } else {
                playTrait.pause();
                updateMetadata();
            }
        }
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }
}
}