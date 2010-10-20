package com.seesaw.player.ads {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;

public class AdProxyPluginInfo extends PluginInfo {

    private static var logger:ILogger = LoggerFactory.getClassLogger(AdProxyPluginInfo);

    public static const ID:String = "com.seesaw.player.ads.AdProxy";

    public function AdProxyPluginInfo() {
        logger.debug("AdProxyPluginInfo()");

        var item:MediaFactoryItem = new MediaFactoryItem(
                ID,
                canHandleResourceFunction,
                mediaElementCreationFunction,
                MediaFactoryItemType.PROXY);

        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
        items.push(item);

        super(items);
    }

    private static function canHandleResourceFunction(resource:MediaResourceBase):Boolean {
        logger.debug("can handle this resource: " + resource);
        return true;
    }

    private static function mediaElementCreationFunction():MediaElement {
        logger.debug("constructing proxy element");
        return new AdProxy();
    }
}
}