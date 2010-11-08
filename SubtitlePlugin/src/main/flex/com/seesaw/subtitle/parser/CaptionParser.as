package com.seesaw.subtitle.parser {
import com.seesaw.subtitle.parser.CaptionSync;

public interface CaptionParser {
    function parse(strSubs:String):Vector.<CaptionSync>;
}
}