package com.seesaw.proxyplugin {
import com.seesaw.proxyplugin.traits.FullScreenTrait;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.media.MediaElement;

public class DefaultProxyElement extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(DefaultProxyElement);

    public function DefaultProxyElement(proxiedElement:MediaElement = null) {
        logger.debug("DefaultProxyElement()");
        super(proxiedElement);
    }

    override protected function setupTraits():void {
        logger.debug("setupTraits");
        addTrait(FullScreenTrait.FULL_SCREEN, new FullScreenTrait());
        super.setupTraits();
    }
}
}