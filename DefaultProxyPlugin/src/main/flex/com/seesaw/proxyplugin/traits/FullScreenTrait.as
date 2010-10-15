package com.seesaw.proxyplugin.traits {
import com.seesaw.proxyplugin.events.FullScreenEvent;

import org.osmf.traits.MediaTraitBase;

[Event(name="fullscreenChange", type="com.seesaw.proxyplugin.events.FullScreenEvent")]

public class FullScreenTrait extends MediaTraitBase {

    private var _fullscreen:Boolean;

    public static const FULL_SCREEN:String = "fullscreen";

    public function FullScreenTrait() {
        super(FULL_SCREEN);
    }

    public function get fullscreen():Boolean {
        return _fullscreen;
    }

    public function set fullscreen(value:Boolean):void {
        _fullscreen = value;
        dispatchEvent(new FullScreenEvent(value));
    }
}
}