package com.seesaw.player.parsers.captioning {
public class CaptionDocument {

    private var _captions:Vector.<CaptionSync>;

    public function CaptionDocument(captions:Vector.<CaptionSync> = null) {
        if (captions == null) {
            captions = new Vector.<CaptionSync>;
        }
        _captions = captions;
    }

    public function get captions():Vector.<CaptionSync> {
        return _captions;
    }

    public function set captions(value:Vector.<CaptionSync>):void {
        _captions = value;
    }
}
}