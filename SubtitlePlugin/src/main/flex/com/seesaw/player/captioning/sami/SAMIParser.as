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

package com.seesaw.player.captioning.sami {
import com.seesaw.player.parsers.captioning.CaptionDocument;
import com.seesaw.player.parsers.captioning.CaptionParser;
import com.seesaw.player.parsers.captioning.CaptionSync;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;

public class SAMIParser implements CaptionParser {

    private var logger:ILogger = LoggerFactory.getClassLogger(SAMIParser);

    // A new captioning is displayed every second (1000ms).
    public static const CAPTION_INTERVAL:int = 1000;

    public function SAMIParser() {
    }

    public function parse(strSubs:String):CaptionDocument {
        strSubs = strSubs.replace(/<span/ig, "<font");
        strSubs = strSubs.replace(/<\/span>/ig, "</font>");
        strSubs = strSubs.replace(/style=([^>]*)/ig, "style=\"$1\"");

        strSubs = strSubs.replace(/style="color:\s*yellow\s*;"/ig, "color=\"#FFFF00\"");
        strSubs = strSubs.replace(/style="color:\s*cyan\s*;"/ig, "color=\"#00FFFF\"");
        strSubs = strSubs.replace(/style="color:\s*white\s*;"/ig, "color=\"#FFFFFF\"");
        strSubs = strSubs.replace(/style="color:\s*#(\w*)\s*;"/ig, "color=\"#$1\"");

        var arrFromString:Array = strSubs.split("</Sync>");
        var syncPattern:RegExp = new RegExp("(<Sync Start=\")(\\d*)", "i");
        var displayPattern:RegExp = new RegExp("(<Sync Start=\"\\d*\">)(\.*)", "i");
        var counter:int = 0;

        var captions:Vector.<CaptionSync> = new Vector.<CaptionSync>();
        for each(var item:* in arrFromString) {
            try {
                counter++;

                captions.push(new CaptionSync(displayPattern.exec(item)[2].toString(),
                        Number(syncPattern.exec(item)[2]) / CAPTION_INTERVAL));
            } catch(e:Error) {
                logger.error("failed to add caption: " + e.message);
            }
        }

        logger.debug("read " + counter + " caption events");

        return new CaptionDocument(captions);
    }
}
}