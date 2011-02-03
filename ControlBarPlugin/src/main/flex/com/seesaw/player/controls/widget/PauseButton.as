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

import controls.seesaw.widget.interfaces.IWidget;

import flash.events.Event;
import flash.events.MouseEvent;

public class PauseButton extends PlayPauseButtonBase implements IWidget {

    private var toolTip:PlayerToolTip;

    private static const QUALIFIED_NAME:String = "com.seesaw.player.controls.widget.PauseButton";

    public function PauseButton() {
        this.toolTip = new PlayerToolTip(this, "Pause");
        this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
    }

    private function onAddedToStage(event:Event) {
        stage.addChild(this.toolTip);
    }

    override protected function updateVisibility():void {
        visible = playing;
    }

    override protected function onMouseClick(event:MouseEvent):void {
        playTrait.pause();
        updateMetadata();
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }
}
}