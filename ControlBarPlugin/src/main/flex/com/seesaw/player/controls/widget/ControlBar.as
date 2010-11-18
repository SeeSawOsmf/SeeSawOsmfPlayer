package com.seesaw.player.controls.widget {
import com.seesaw.player.controls.ControlBarMetadata;

import flash.events.Event;
import flash.events.MouseEvent;

import org.osmf.chrome.widgets.Widget;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;

public class ControlBar extends Widget {

    public function ControlBar() {
        this.addEventListener(Event.ADDED_TO_STAGE, setupEvents);
    }

    private function setupEvents(event:Event):void {
        stage.addEventListener(MouseEvent.MOUSE_OVER, showControlBar);
        stage.addEventListener(MouseEvent.MOUSE_OUT, hideControlBar);
    }

    override public function set media(value:MediaElement):void {
        super.media = value;

        var metadata:Metadata = media.getMetadata(ControlBarMetadata.CONTROL_BAR_METADATA);
        if (metadata == null) {
            var metadata = new Metadata();
            metadata.addValue(ControlBarMetadata.CONTROL_BAR_HIDDEN, visible);
            media.addMetadata(ControlBarMetadata.CONTROL_BAR_METADATA, metadata);
        }
    }

    private function showControlBar(event:MouseEvent):void {
        this.visible = true;
        updateMetadata();
    }

    private function hideControlBar(event:MouseEvent):void {
        this.visible = false;
        updateMetadata();
    }

    private function updateMetadata():void {
        var metadata:Metadata = media.getMetadata(ControlBarMetadata.CONTROL_BAR_METADATA);
        if (metadata) {
            metadata.addValue(ControlBarMetadata.CONTROL_BAR_HIDDEN, !visible);
        }
    }
}
}