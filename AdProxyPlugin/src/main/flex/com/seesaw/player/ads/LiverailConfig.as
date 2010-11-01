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

package com.seesaw.player.ads {
import com.seesaw.player.namespaces.contentinfo;

public class LiverailConfig {
    private var _config:Object;
    private var contentInfo:XML;
    private var liveRailAdMap:String = "";
    private var liveRailTags:String = "";
    private var genres:Array;
    private var ageRating:int;
    private var _adPositions:Array = [];
    private var _totalAdPositions:Array = [];
    private var adSlots:int = 0;

    use namespace contentinfo;

    public function LiverailConfig(contentInfoXml:XML) {


        contentInfo = contentInfoXml as XML;
        if (contentInfo) {
            generateMap();
        }
    }

    public function generateMap():void {


        var autoResumePoint:Number = 0;


        liveRailAdMap = "";
        liveRailTags = "";
        if (contentInfo != null) {


            liveRailTags += "sourceId_" + stripSpecialChars(contentInfo.sourceId);
            liveRailTags += ",firstPresentationBrand_" + stripSpecialChars(contentInfo.firstPresentationBrand);
            liveRailTags += ",minimumAge_" + ageRating.toString();
            liveRailTags += ",catchup_" + stripSpecialChars(contentInfo.catchup);


            for each(var genre:String in genres) {
                liveRailTags += "," + stripSpecialChars(genre);
            }

            var duration:Number = Number(contentInfo.duration);
            if (duration < 900) {
                liveRailTags += ",duration_less_than_15_min";
            } else if (duration < 3600) {
                liveRailTags += ",duration_less_than_1_hour";
            } else {
                liveRailTags += ",duration_greater_than_1_hour";
            }


            for each(var item:XML in contentInfo.loggingSheet.children()) {
                var name:String = item.name().localName;
                switch (name) {
                    case "break":
                        if (item.breakOffset != null) {
                            var pos:Number = convertDuration(item.breakOffset);
                            if (!(pos < autoResumePoint)) {

                                liveRailAdMap += "in::" + pos.toString();

                                if (Math.abs(pos) > 0) {
                                    _adPositions.push(convertPercenage(pos));
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


    }

    private static function convertDuration(str:String):Number {
        var arrDuration:Array = str.split(":");
        var iHours:Number = Number(arrDuration[0]);
        var iMinutes:Number = Number(arrDuration[1]);
        var iSeconds:Number = Number(arrDuration[2]);
        var finalSeconds:Number = ((iHours * (60 * 60)) + (iMinutes * 60) + iSeconds);
        return finalSeconds;
    }

    private function convertPercenage(num:Number):Number {
        var duration:Number = contentInfo.duration;

        return (num / duration);
    }


    private function stripSpecialChars(original:String):String {
        original = original.replace(/_|:/ig, "");
        return original;
    }

    private function extractMidLevelGenresAndAddToGenresArray(genre:*, index:int, original:Array):void {

        var startPositionToFindSecondColon:int;

        if (genre.indexOf("TV:") == 0) {
            startPositionToFindSecondColon = 3;
        } else {
            startPositionToFindSecondColon = 5;
        }

        var positionOfSecondColon:int = genre.indexOf(":", startPositionToFindSecondColon);
        if (positionOfSecondColon > 0) {
            var midLevelGenre:String = genre.substring(0, positionOfSecondColon);
            if (genres.indexOf(midLevelGenre) <= 0) {
                genres[genres.length] = midLevelGenre;
            }
        }
    }

    public function get config():Object {



        /*  // set to true if you are using Junction or false if you are using AdServer
         config["LR_USE_JUNCTION"] = false;

         // the Junction or the AdServer Publisher ID, located on the Account page of the Publisher;
         config["LR_PUBLISHER_ID"] = liverailPublisherId;
         //once we migrate to next platform version
         config["LR_VERSION"] = liverailVersion;

         //Partner ID maps to CP id
         config["LR_PARTNERS"] = "SHERBET";

         // a unique code identifying the video played by your Flash player;
         config["LR_VIDEO_ID"] = programmeId;

         config["LR_LAYOUT_LINEAR_PAUSEONCLICKTHRU"] = false;
         config["LR_LAYOUT_SKIN_ID"] = 1;

         // ADMAP (optional param)
         // admap string is: [ad-type]:[timings(start-time,end-time)];
         // for more details on how to generate the ADMAP please see "Run-time Parameters Specification" pdf document
         config["LR_ADMAP"] = liveRailAdMap;

         config["LR_TAGS"] = liveRailTags;

         //For now we will set the sting and ident (bumpers) param to default, causing LiveRail to use the defaults
         //stored in their system. Once we are ready to specify these, then this can be changed.
         var defaultValue:String = "default";

         config["LR_BUMPER_PREROLL_PRE_HIGH"] = defaultValue;
         config["LR_BUMPER_PREROLL_POST_HIGH"] = defaultValue;
         config["LR_BUMPER_PREROLL_PRE_MED"] = defaultValue;
         config["LR_BUMPER_PREROLL_POST_MED"] = defaultValue;
         config["LR_BUMPER_PREROLL_PRE_LOW"] = defaultValue;
         config["LR_BUMPER_PREROLL_POST_LOW"] = defaultValue;
         config["LR_BUMPER_PREROLL_ADONLY"] = defaultValue;

         config["LR_BUMPER_MIDROLL_PRE_HIGH"] = defaultValue;
         config["LR_BUMPER_MIDROLL_POST_HIGH"] = defaultValue;
         config["LR_BUMPER_MIDROLL_PRE_MED"] = defaultValue;
         config["LR_BUMPER_MIDROLL_POST_MED"] = defaultValue;
         config["LR_BUMPER_MIDROLL_PRE_LOW"] = defaultValue;
         config["LR_BUMPER_MIDROLL_POST_LOW"] = defaultValue;
         config["LR_BUMPER_MIDROLL_ADONLY"] = defaultValue;

         config["LR_BUMPER_POSTROLL_PRE_HIGH"] = defaultValue;
         config["LR_BUMPER_POSTROLL_POST_HIGH"] = defaultValue;
         config["LR_BUMPER_POSTROLL_PRE_MED"] = defaultValue;
         config["LR_BUMPER_POSTROLL_POST_MED"] = defaultValue;
         config["LR_BUMPER_POSTROLL_PRE_LOW"] = defaultValue;
         config["LR_BUMPER_POSTROLL_POST_LOW"] = defaultValue;
         config["LR_BUMPER_POSTROLL_ADONLY"] = defaultValue;

         ////	liveRailConfig["LR_ALLOWDUPLICATES"] = 1;


         config["LR_BITRATE"] = "medium";
         //StatusService.info("Setting LiveRail ad bitrate to "+liveRailConfig["LR_BITRATE"]);

         */
        _config = {
            "LR_ADMAP" : liveRailAdMap,

            "LR_TAGS" : liveRailTags,
            "LR_BITRATE" :    "low",
            "LR_BUMPER_MIDROLL_ADONLY"    :"default",
            "LR_BUMPER_MIDROLL_POST_HIGH"    :"default",
            "LR_BUMPER_MIDROLL_POST_LOW" :    "default",
            "LR_BUMPER_MIDROLL_POST_MED"    : "default",
            "LR_BUMPER_MIDROLL_PRE_HIGH" :    "default",
            "LR_BUMPER_MIDROLL_PRE_LOW" :    "default",
            "LR_BUMPER_MIDROLL_PRE_MED" :    "default",
            "LR_BUMPER_POSTROLL_ADONLY" :    "default",
            "LR_BUMPER_POSTROLL_POST_HIGH" :    "default"  ,
            "LR_BUMPER_POSTROLL_POST_LOW" :    "default"  ,
            "LR_BUMPER_POSTROLL_POST_MED" :    "default" ,
            "LR_BUMPER_POSTROLL_PRE_HIGH" :    "default" ,
            "LR_BUMPER_POSTROLL_PRE_LOW" :    "default"  ,
            "LR_BUMPER_POSTROLL_PRE_MED" :    "default"  ,
            "LR_BUMPER_PREROLL_ADONLY" :    "default" ,
            "LR_BUMPER_PREROLL_POST_HIGH" :    "default"  ,
            "LR_BUMPER_PREROLL_POST_LOW" :    "default"   ,
            "LR_BUMPER_PREROLL_POST_MED" :    "default"   ,
            "LR_BUMPER_PREROLL_PRE_HIGH" :    "default"   ,
            "LR_BUMPER_PREROLL_PRE_LOW" :    "default"    ,
            "LR_BUMPER_PREROLL_PRE_MED" :    "default"   ,
            "LR_LAYOUT_LINEAR_PAUSEONCLICKTHRU" :    false  ,
            "LR_LAYOUT_SKIN_ID" :    1 ,
            "LR_PARTNERS" :    "SHERBET" ,
            "LR_PUBLISHER_ID" :    contentInfo.publisherId ,
            /// "LR_TAGS" :    "sourceId_BBCWORLDWIDE,firstPresentationBrand_BBC,minimumAge_18,catchup_false,TVDRAMACONTEMPORARYBRITISH,TVDRAMA,duration_less_than_1_hour",
            "LR_USE_JUNCTION" :    false,
            "LR_VERSION" :    "4.1",
            "LR_VIDEO_ID"    : contentInfo.programmeId
        }
        return _config;
    }

    public function get adPositions():Array {
        return _adPositions;
    }
}
}