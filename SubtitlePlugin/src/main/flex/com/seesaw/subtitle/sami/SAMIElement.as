package com.seesaw.subtitle.sami {
import org.osmf.elements.LoadFromDocumentElement;
import org.osmf.media.MediaResourceBase;

public class SAMIElement extends LoadFromDocumentElement {
    public function SAMIElement(resource:MediaResourceBase = null, loader:SAMILoader = null) {
        if (loader == null) {
            loader = new SAMILoader();
        }
        super(resource, loader);
    }
}
}