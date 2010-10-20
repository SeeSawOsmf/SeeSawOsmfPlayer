package com.seesaw.player.logging {
public class ColourMap {
    public function ColourMap(category:String, colour:uint) {
        _category = category;
        _colour = colour;


    }

    private var _category:String;
    private var _colour:uint;

    public function get category():String {
        return _category;
    }

    public function set category(value:String):void {
        _category = value;
    }

    public function get colour():uint {
        return _colour;
    }

    public function set colour(value:uint):void {
        _colour = value;
    }
}
}