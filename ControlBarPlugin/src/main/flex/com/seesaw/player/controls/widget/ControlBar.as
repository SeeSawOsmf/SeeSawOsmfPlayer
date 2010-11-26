package com.seesaw.player.controls.widget {
import com.seesaw.player.controls.ControlBarMetadata;

import flash.events.Event;
import flash.events.MouseEvent;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.chrome.widgets.Widget;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;

public class ControlBar extends Widget {

    private var logger:ILogger = LoggerFactory.getClassLogger(ControlBar);

    private var _superVisible:Boolean;

    public function ControlBar() {
        this.addEventListener(Event.ADDED_TO_STAGE, setupEvents);
    }

    private function setupEvents(event:Event):void {
        stage.addEventListener(MouseEvent.MOUSE_OVER, showControlBar);
        stage.addEventListener(MouseEvent.MOUSE_OUT, hideControlBar);
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

    private function showControlBar(event:MouseEvent):void {
        this.visible = true;
    }

    private function hideControlBar(event:MouseEvent):void {
        this.visible = false;
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