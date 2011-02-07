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

package com.seesaw.player {
import com.adobe.errors.IllegalStateError;
import com.seesaw.player.namespaces.contentinfo;
import com.seesaw.player.namespaces.smil;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;

public class TestApi {

    use namespace contentinfo;
    use namespace smil;

    var player:Player;

    public function TestApi(player:Player) {
        this.player = player;
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("proceed", proceed);
            ExternalInterface.addCallback("guidancePanelAccept", guidancePanelAccept);
            ExternalInterface.addCallback("guidancePanelDecline", guidancePanelDecline);
            ExternalInterface.addCallback("playState", playState);
            ExternalInterface.addCallback("getElementByName", getElementByName);
            ExternalInterface.addCallback("getElementsByName", getElementsByName);
            ExternalInterface.addCallback("getAllStageElements", getAllStageElements);
            ExternalInterface.addCallback("getStageElements", getStageElements);
        }
    }

    public function playState():String {
        if (player.videoPlayer == null) return "NOT_STARTED";
        if (player.videoPlayer.mediaPlayer.playing) return "PLAYING";
        if (player.videoPlayer.mediaPlayer.paused) return "PAUSED";
        if (player.videoPlayer.mediaPlayer.seeking) return "SEEKING";
        return "UNKNOWN";
    }

    public function guidancePanelAccept():void {
        var button:DisplayObject = getElementByName(PlayerConstants.GUIDANCE_PANEL_ACCEPT_BUTTON_NAME);
        button.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
    }

    public function guidancePanelDecline():void {
        var button:DisplayObject = getElementByName(PlayerConstants.GUIDANCE_PANEL_CANCEL_BUTTON_NAME);
        button.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
    }

    public function proceed():void {
        var playButton:DisplayObject = getElementByName(PlayerConstants.PROCEED_BUTTON_NAME);
        playButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
    }

    public function getElementByName(name:String):DisplayObject {
        var result:Array = new Array();
        getElementsByName(player.stage, name, result);
        if (result.length != 1) {
            throw new IllegalStateError("There should only be one element on the stage with name: [" + name + "], but " + result.length + " were found.");
        }
        return result.pop();
    }

    public function getElementsByName(object:DisplayObject, name:String, result:Array):void {

        if (object.name == name) {
            result.push(object);
            return;
        }

        if (object instanceof DisplayObjectContainer) {
            var container:DisplayObjectContainer = DisplayObjectContainer(object);
            for (var index:Number = 0; index < container.numChildren; index += 1) {
                getElementsByName(container.getChildAt(index), name, result);
            }
        }
    }


    // useful debug function
    public function getAllStageElements():Array {
        var result:Array = new Array();
        getStageElements(player.stage, result);
        return result;
    }

    public function getStageElements(object:DisplayObject, result:Array):void {
        result.push(object.name);
        if (object instanceof DisplayObjectContainer) {
            var container:DisplayObjectContainer = DisplayObjectContainer(object);
            for (var index:Number = 0; index < container.numChildren; index += 1) {
                getStageElements(container.getChildAt(index), result);
            }
        }
    }
}
}