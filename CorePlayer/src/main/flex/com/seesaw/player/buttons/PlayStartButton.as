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

package com.seesaw.player.buttons {
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.system.Security;

public class PlayStartButton extends Sprite {

    // the event to listen for
    public static const PROCEED = "PROCEED";

    // constants for the button types
    public static const PLAY:String = "play";
    public static const PLAY_SUBSCRIBED:String = "playSubscribed";
    public static const PREVIEW:String = "preview";
    public static const RESUME:String = "resume";

    // Requested button type - play, resume or preview
    private var buttonType:String;

    //Embed images
    [Embed(source="resources/preplayButton.png")]
    private var playButtonImageEmbed:Class;
    private var playButtonImage:Bitmap = new playButtonImageEmbed();
    [Embed(source="resources/Player_Subscribed.png")]
    private var playSubscribedButtonImageEmbed:Class;
    private var playSubscribedButtonImage:Bitmap = new playSubscribedButtonImageEmbed();
    [Embed(source="resources/resumePreplayButton.png")]
    private var resumeButtonImageEmbed:Class;
    private var resumeButtonImage:Bitmap = new resumeButtonImageEmbed();
    [Embed(source="resources/Player_Preview.png")]
    private var previewButtonImageEmbed:Class;
    private var previewButtonImage:Bitmap = new previewButtonImageEmbed();

    /*Constructor
     * Takes: warning:String - the guidance warning that appears at the top of the panel
     *
     */
    public function PlayStartButton(type:String) {

        this.buttonType = type;

        Security.allowDomain("*");
        super();

        //Build the panel and add it to the GuidancePanel MovieClip
        addChild(this.buildButton());

        this.addEventListener(Event.ADDED_TO_STAGE, this.positionButton);

    }

    private function positionButton(event:Event):void {
        this.x = (stage.stageWidth / 2) - (this.width / 2);
        this.y = (stage.stageHeight / 2) - (this.height / 2);
    }


    private function buildButton():Sprite {
        var proceedButton:Sprite = new Sprite();

        //setup the hand cursor
        proceedButton.useHandCursor = true;
        proceedButton.buttonMode = true;
        proceedButton.mouseChildren = false;

        switch (this.buttonType) {

            case "play":
                proceedButton.addChild(this.playButtonImage);
                break;
            case "playSubscribed":
                proceedButton.addChild(this.playSubscribedButtonImage);
                break;
            case "preview":
                proceedButton.addChild(this.previewButtonImage);
                break;
            case "resume":
                proceedButton.addChild(this.resumeButtonImage);
                break;
            default:
                // setting an invalid button type is a coding error so throw an exception
                throw new ArgumentError("button type not recognised: " + buttonType);
        }

        proceedButton.addEventListener(MouseEvent.CLICK, this.onProceedClick);

        proceedButton.height = 170;
        proceedButton.width = 170;

        return proceedButton;
    }

    private function onProceedClick(event:MouseEvent):void {
        this.visible = false;
        this.dispatchEvent(new Event(PROCEED));
    }

}

}