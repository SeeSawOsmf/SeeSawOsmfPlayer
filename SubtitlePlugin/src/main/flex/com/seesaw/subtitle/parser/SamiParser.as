package com.seesaw.subtitle.parser {
import com.seesaw.subtitle.*;
import com.seesaw.subtitle.*;
import com.seesaw.player.init.ServiceRequest;

import flash.display.Sprite;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;

public class SamiParser implements CaptionParser {

    private var logger:ILogger = LoggerFactory.getClassLogger(SamiParser);

    // A new caption is displayed every second (1000ms).
    public static const CAPTION_INTERVAL:int = 1000;

    public function parse(strSubs:String):Vector.<CaptionSync> {
        
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

        var captions = new Vector.<CaptionSync>();
        for each(var item:* in arrFromString) {
            try {
                counter++;

                captions.push(new CaptionSync(displayPattern.exec(item)[2].toString(),
                        Number(syncPattern.exec(item)[2]) / CAPTION_INTERVAL));
            } catch(e:Error) {
                logger.error("failed to add caption", e);
            }
        }
        return captions;
    }
}
}