/**
 * Created by IntelliJ IDEA.
 * User: bmeade
 * Date: 07/02/11
 * Time: 16:37
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.asyncproxy {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.MediaType;
import org.osmf.media.PluginInfo;

public class AsyncProxyPluginInfo extends PluginInfo {

     private static var logger:ILogger = LoggerFactory.getClassLogger(AsyncProxyPluginInfo);

    public static const ID:String = "com.seesaw.player.preventscrub.ScrubPreventionProxyPluginInfo";


    public function AsyncProxyPluginInfo() {
       logger.debug("ScrubPreventionProxyPluginInfo()");

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
        var canHandle:Boolean = resource && resource.mediaType == MediaType.VIDEO;
        logger.debug("can handle this resource {0} = {1}", resource, canHandle);
        return canHandle;
    }

    private static function mediaElementCreationFunction():MediaElement {
        logger.debug("constructing proxy element");
        return new AsyncProxy();
    }
}
}