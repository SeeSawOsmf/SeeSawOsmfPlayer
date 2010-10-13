package com.seesaw.player {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;

public class MediaSizePluginInfo extends PluginInfo {

    private var logger:ILogger = LoggerFactory.getClassLogger(MediaSizePluginInfo);

    private var _proxy:MediaSizeProxyElement;

    public function MediaSizePluginInfo() {
        logger.debug("MediaSizePluginInfo()");
        
        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();

        var item:MediaFactoryItem = new MediaFactoryItem(
                "com.seesaw.player.fullscreen",
                canHandleResourceCallback,
                createMediaElement,
                MediaFactoryItemType.PROXY
                );

        items.push(item);

        super(items, mediaElementCreated);
    }

    private function canHandleResourceCallback(resource:MediaResourceBase):Boolean {
        logger.debug("canHandleResourceCallback");
        return true;
    }

    protected function mediaElementCreated(mediaElement:MediaElement):void {
        logger.debug("mediaElementCreated");
        _proxy.proxiedElement = mediaElement; 
    }

    public function createMediaElement():MediaSizeProxyElement {
        logger.debug("createMediaElement");
        _proxy = new MediaSizeProxyElement(null);
        return _proxy;
    }
}
}