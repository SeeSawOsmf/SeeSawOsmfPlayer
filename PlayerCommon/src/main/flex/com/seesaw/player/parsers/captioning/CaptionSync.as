package com.seesaw.player.parsers.captioning {
public class CaptionSync {

    private var _display:String;

    private var _time:Number;

    private var _duration:Number;

    public function CaptionSync(display:String = "", time:Number = 0.0, duration:Number = 1.0) {
        _display = display;
        _time = time;
    }

    public function get display():String {
        return _display;
    }

    public function set display(value:String):void {
        _display = value;
    }

    public function get time():Number {
        return _time;
    }

    public function set time(value:Number):void {
        _time = value;
    }

    public function get duration():Number {
        return _duration;
    }

    public function set duration(value:Number):void {
        _duration = value;
    }
}
}