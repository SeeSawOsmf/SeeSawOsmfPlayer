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
import com.seesaw.player.controls.ControlBarConstants;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.ui.Mouse;
import flash.utils.Timer;

import org.osmf.chrome.widgets.Widget;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;

public class ControlBar extends Widget {
    //Timer for the auto hide of the control bar
    private var controlsTimer:Timer = new Timer(2500, 1);

    //mouseOnStage - true if the mouse is over the stage
    private var mouseOnStage:Boolean = false;

    //mouseOnStage - true if the mouse is over the control bar
    private var overControls:Boolean = false;

    private var _superVisible:Boolean;

    public function ControlBar() {
        this.addEventListener(Event.ADDED_TO_STAGE, setupEvents);
    }

    private function setupEvents(event:Event):void {
        //Stage events...
        stage.addEventListener(MouseEvent.MOUSE_OVER, showControlsListener);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, moveShowControlsListener);
        stage.addEventListener(Event.MOUSE_LEAVE, hideOnLeave);

        //Control bar events
        this.addEventListener(MouseEvent.MOUSE_MOVE, showControlsListener);
        this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverControls);
        this.addEventListener(MouseEvent.MOUSE_OUT, mouseLeaveControls);

        //Timer event
        controlsTimer.addEventListener(TimerEvent.TIMER_COMPLETE, hideControls);

        //Start the timer
        controlsTimer.start();
    }

    override protected function processMediaElementChange(oldMediaElement:MediaElement):void {
        var metadata:Metadata = media.getMetadata(ControlBarConstants.CONTROL_BAR_METADATA);
        if (metadata == null) {
            metadata = new Metadata();
            media.addMetadata(ControlBarConstants.CONTROL_BAR_METADATA, metadata);
        }
        metadata.addValue(ControlBarConstants.CONTROL_BAR_HIDDEN, visible);
    }

    private function mouseOverControls(event:MouseEvent):void {
        this.overControls = true;
    }

    private function mouseLeaveControls(event:MouseEvent):void {
        this.overControls = false;
    }

    private function showControlsListener(event:MouseEvent):void {
        //set mouseOnStage to be true
        this.mouseOnStage = true;
        /// update the metadata to force a change on the controlBar visibility metaData, for the subtitles.....
        updateMetadata();
        //show the control bar
        this.visible = true;
        //Show the mouse
        Mouse.show();
        //resent the timer and start it again
        this.controlsTimer.reset();
        this.controlsTimer.start();
    }

    private function moveShowControlsListener(event:MouseEvent):void {
        //Check that the mouse is over the player to prevent this being fired constantly
        if (this.mouseOnStage == true) {
            //Show the control bar
            this.visible = true;
            updateMetadata();
            //Show the mouse
            Mouse.show();
            //Restart the timer and start it again
            this.controlsTimer.reset();
            this.controlsTimer.start();
        }
    }

    private function hideControls(evt:TimerEvent = null):void {
        //Check that the mouse is not over the control bar
        if (this.overControls == false) {
            //Hide the control bar
            this.visible = false;
            //Hide the mouse
            Mouse.hide();
        }
    }

    private function hideOnLeave(e:Event):void {
        //set mouseOnStage to false when leaving the stage
        this.mouseOnStage = false;
        //hide the control bar
        this.hideControls(null);
    }

    private function updateMetadata():void {
        var metadata:Metadata = media.getMetadata(ControlBarConstants.CONTROL_BAR_METADATA);
        if (metadata) {
            metadata.addValue(ControlBarConstants.CONTROL_BAR_HIDDEN, !visible);
        }
    }

    protected override function setSuperVisible(value:Boolean):void {
        super.setSuperVisible(value);
        if (value != _superVisible) {
            updateMetadata();
            _superVisible = value;
        }
    }
}
}