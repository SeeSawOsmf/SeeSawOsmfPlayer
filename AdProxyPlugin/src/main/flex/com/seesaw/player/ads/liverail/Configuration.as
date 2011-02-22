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
 *   All Rights Reserved.
 *
 *   Contributor(s):
 */

package com.seesaw.player.ads.liverail {
public class Configuration {

    private var _adPositions:Array = [];
    private var _totalAdPositions:Array = [];
    private var _config:Object;

    public function get adPositions():Array {
        return _adPositions;
    }

    public function set adPositions(value:Array):void {
        _adPositions = value;
    }

    public function get totalAdPositions():Array {
        return _totalAdPositions;
    }

    public function set totalAdPositions(value:Array):void {
        _totalAdPositions = value;
    }

    public function get config():Object {
        return _config;
    }

    public function set config(value:Object):void {
        _config = value;
    }

    public function generateMap():void {

    }

}
}
