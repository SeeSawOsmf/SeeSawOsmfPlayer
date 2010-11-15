package com.seesaw.player.parsers.captioning {
public interface CaptionParser {
    function parse(strSubs:String):CaptionDocument;
}
}