package com.seesaw.player.controls.widget {
import com.seesaw.player.controls.ControlBarMetadata;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.events.TimerEvent;
import flash.utils.Timer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.chrome.widgets.Widget;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;

public class ControlBar extends Widget {
    private var logger:ILogger = LoggerFactory.getClassLogger(ControlBar);

    //Timer for the auto hide of the control bar
    private var controlsTimer:Timer=new Timer(2500, 1);

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

    override public function set media(value:MediaElement):void {
        super.media = value;

        if(media){
            var metadata:Metadata = media.getMetadata(ControlBarMetadata.CONTROL_BAR_METADATA);
            if (metadata == null) {
                metadata = new Metadata();
                media.addMetadata(ControlBarMetadata.CONTROL_BAR_METADATA, metadata);
            }
            metadata.addValue(ControlBarMetadata.CONTROL_BAR_HIDDEN, visible);
        }
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
        //show the control bar
        this.visible = true;
        //resent the timer and start it again
        this.controlsTimer.reset();
		this.controlsTimer.start();
    }

    private function moveShowControlsListener(event:MouseEvent):void {
        //Check that the mouse is over the player to prevent this being fired constantly
        if (this.mouseOnStage == true) {
            //Show the control bar
            this.visible = true;
            //Restart the timer and start it again
            this.controlsTimer.reset();
		    this.controlsTimer.start();
        }
    }

    private function hideControls(evt:TimerEvent=null):void {
        //Check that the mouse is not over the control bar
        if (this.overControls == false) {
            //Hide the control bar
            this.visible = false;
        }
    }

    private function hideOnLeave(e:Event):void {
        //set mouseOnStage to false when leaving the stage
        this.mouseOnStage = false;
        //hide the control bar
		this.hideControls(null);
	}

    private function updateMetadata():void {
        var metadata:Metadata = media.getMetadata(ControlBarMetadata.CONTROL_BAR_METADATA);
        if (metadata) {
            metadata.addValue(ControlBarMetadata.CONTROL_BAR_HIDDEN, !visible);
        }
    }

    protected override function setSuperVisible(value:Boolean):void {
        super.setSuperVisible(value);
        if(value != _superVisible) {
            logger.debug("updating metadata: visibility = " + value);
            updateMetadata();
            _superVisible = value;
        }
    }
}
}