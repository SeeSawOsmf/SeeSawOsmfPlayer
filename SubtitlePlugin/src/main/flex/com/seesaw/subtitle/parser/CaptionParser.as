package com.seesaw.subtitle.parser {
public interface CaptionParser {
    function parse(strSubs:String):Vector.<CaptionSync>;
}
}