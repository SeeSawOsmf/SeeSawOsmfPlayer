package com.seesaw.player.controls.widget {
import flash.events.Event;

import flash.events.MouseEvent;

import org.osmf.chrome.widgets.Widget;

public class ControlBar extends Widget {
    public function ControlBar() {
        this.addEventListener(Event.ADDED_TO_STAGE, setupEvents);
    }

    private function setupEvents (event:Event):void {
        stage.addEventListener(MouseEvent.MOUSE_OVER, showControlBar);
        stage.addEventListener(MouseEvent.MOUSE_OUT, hideControlBar);
    }

    private function showControlBar (event:MouseEvent):void {
        this.visible = true;        
    }

    private function hideControlBar (event:MouseEvent):void {
        this.visible = false;        
    }
}
}