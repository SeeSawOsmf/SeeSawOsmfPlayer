package com.seesaw.player {
import org.osmf.events.MediaFactoryEvent;
import org.osmf.media.MediaElement;

public interface MediaElementBuilder {
    function newInstance(id:String):MediaElement;

    function isSourceOf(event:MediaFactoryEvent):Boolean;

    function applyMetadataToElement(mediaElement:MediaElement):void;
}
}