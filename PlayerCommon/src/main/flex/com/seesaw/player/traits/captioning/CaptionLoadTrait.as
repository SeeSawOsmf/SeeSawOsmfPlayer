package com.seesaw.player.traits.captioning {
import com.seesaw.player.parsers.captioning.CaptionDocument;

import org.osmf.media.MediaResourceBase;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.LoaderBase;

public class CaptionLoadTrait extends LoadTrait {

    private var _document:CaptionDocument;

    public function CaptionLoadTrait(loader:LoaderBase, resource:MediaResourceBase) {
        super(loader, resource);
    }

    public function get document():CaptionDocument {
        return _document;
    }

    public function set document(value:CaptionDocument):void {
        _document = value;
    }
}
}