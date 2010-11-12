/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *    The contents of this file are subject to the Mozilla Public License
 *    Version 1.1 (the "License"); you may not use this file except in
 *    compliance with the License. You may obtain a copy of the
 *    License athttp://www.mozilla.org/MPL/
 *
 *    Software distributed under the License is distributed on an "AS IS"
 *    basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *    License for the specific language governing rights and limitations
 *    under the License.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 */

package com.seesaw.player.playlist {
import flash.utils.Dictionary;

public class AdMap extends Dictionary {
    private var indexedMainAsset:XML;

    public function AdMap() {
    }

    public function createPlaylistEntry(item:XML):Array {
        var adItem:Object;
        var adList:Array = new Array();
        for each (var x:XML in item.ENTRY) {
            adItem = new Object();
            for each (var e:XML in x.children()) {
                var name:String = e.name().toString();
                switch (name) {
                    case "REF":
                        adItem[name] = e.@HREF.toString();
                        break;

                    case "TITLE":
                        adItem[name] = e.toString();
                        break;
                    case "STARTTIME":
                        adItem[name] = e.@VALUE;
                        break;
                    case "DURATION":
                        adItem[name] = e.@VALUE;
                        break;
                    case "PARAM":
                        adItem[name] = processParams(e);
                        break;
                    case "MAINCONTENT":
                        indexedMainAsset = e;
                        adItem[name] = e
                        break;
                    default:

                        break;
                }
            }
            adList.push(adItem);
        }
        if (adItem["REF"] == null) {
            adItem["REF"] = item.@HREF.toString();
            if (adItem["REF"] == null) {
                //todo add a fallBack error....
            }
        }
        return adList;
    }

    private static function processParams(e:XML):Object {
        var name:String = e.@NAME.toString();
        var value:String = e.@VALUE.toString();
        var params:Object = new Object();

        switch (name) {
            case "CanSeek":
                params[name] = convertBoolean(value);
                break;
            case "CanSkipForward":
                params[name] = convertBoolean(value);
                break;
            case "CanSkipBack":
                params[name] = convertBoolean(value);
                break;
            case "vodco.subtitlesUrl":
                params[name] = value;
                break;
            case "vodco.interactiveAdvertisingUrl":
                params[name] = value;
                break;
            case "vodco.popupAdvertisingUrl":
                params[name] = value;
                break;
            case "vodco.interactiveAdvertisingCaption":
                params[name] = value;
                break;
            case "vodco.adType":
                params[name] = value;
                break;
            default:
                if (name != null && name.length > 0) {
                    params[name] = value;
                }
                break;
        }
        return params;
    }

    private static function convertBoolean(str:String):Boolean {
        switch (str.toLowerCase()) {
            case 'yes':
            case '1':
            case 'true':
                return true;
            default:
                return false;
        }
    }
}
}