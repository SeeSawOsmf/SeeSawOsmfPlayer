package com.seesaw.player {
import flash.display.DisplayObject;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.DisplayObjectEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.MediaTraitType;

public class MediaSizeProxyElement extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(MediaSizeProxyElement);

    public function MediaSizeProxyElement(proxiedElement:MediaElement = null) {
        logger.debug("MediaSizeProxyElement()");
        super(proxiedElement);
    }

    override public function set proxiedElement(value:MediaElement):void {
        logger.debug("proxiedElement: " + value);
        
        super.proxiedElement = value;
        
        if (proxiedElement != null) {
            logger.debug("adding trait listeners");
            
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onAddTrait);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onRemoveTrait);
        }
    }

    protected function onAddTrait(event:MediaElementEvent):void {
        logger.debug("onAddTrait: " + event.traitType);

        if (event.traitType == MediaTraitType.DISPLAY_OBJECT) {
            var doTrait:DisplayObjectTrait = proxiedElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
            doTrait.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, processDisplayObjectChange);
            doTrait.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, processMediaSizeChange);
        }
    }

    protected function onRemoveTrait(event:MediaElementEvent):void {
        logger.debug("onRemoveTrait: " + event.traitType);
    }

    protected function processDisplayObjectChange(event:DisplayObjectEvent):void {
        logger.debug("processDisplayObjectChange: " + event);

        var oldDisplayObject:DisplayObject = event.oldDisplayObject;
        var newView:DisplayObject = event.newDisplayObject;
    }

    protected function processMediaSizeChange(event:DisplayObjectEvent):void {
        logger.debug("processMediaSizeChange: " + event);

        var oldWidth:Number = event.oldWidth;
        var oldHeight:Number = event.oldHeight;

        var newWidth:Number = event.newWidth;
        var newHeight:Number = event.newHeight;
    }
}
}