package com.seesaw.proxyplugin.events {
import flash.events.Event;

public class FullScreenEvent extends Event {

    public static const FULL_SCREEN:String = "fullscreenChange";

    private var _value:Boolean;

    public function FullScreenEvent(value:Boolean) {
        super(FULL_SCREEN, false, false);
        _value = value;
    }

    public function get value():Boolean {
        return _value;
    }
}
}