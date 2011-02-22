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