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