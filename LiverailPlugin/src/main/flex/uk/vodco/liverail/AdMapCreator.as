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

package uk.vodco.liverail {
public class AdMapCreator {

    private var _adPositions:Array = [];

    private var _totalAdPositions:Array = [];

    private var contentInfo:XML;

    private var autoResumePoint:Number = 0;

    public var adSlots:int = 0;

    public function AdMapCreator(contentInfoXml:XML) {
        contentInfo = contentInfoXml;
    }


    private function generateAdMap():String {

        var liveRailAdMap:String = "";


        for each(var item:XML in contentInfo.loggingSheet.children()) {
            var name:String = item.name().toString();
            switch (name) {
                case "break":
                    if (item.breakOffset != null) {
                        var pos:Number = convertDuration(item.breakOffset);
                        if (!(pos < autoResumePoint)) {

                            liveRailAdMap += "in::" + pos.toString();

                            if (Math.abs(pos) > 0) {
                                _adPositions.push(pos);
                            }


                        }
                        _totalAdPositions.push(pos);
                    }
                    liveRailAdMap += ";";
                    adSlots++;
                    break;
            }
        }

        //hardcode the preroll if not exist in string already
        if (!liveRailAdMap.match("in::0")) {
            liveRailAdMap = "in::0;" + liveRailAdMap + "in::100%;";
            _totalAdPositions.push(0);
        }

        //remove the last semi-colon in the string, apparently there is a reason for this as LR asked us to do it
        liveRailAdMap = liveRailAdMap.substring(0, liveRailAdMap.lastIndexOf(";"));

    }


    private static function convertDuration(str:String):Number {
        var arrDuration:Array = str.split(":");
        var iHours:Number = Number(arrDuration[0]);
        var iMinutes:Number = Number(arrDuration[1]);
        var iSeconds:Number = Number(arrDuration[2]);
        var finalSeconds:Number = ((iHours * (60 * 60)) + (iMinutes * 60) + iSeconds);
        return finalSeconds;
    }

}
}