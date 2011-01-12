package com.seesaw.player.batchEventService {
import com.seesaw.player.PlayerConstants;

import flash.display.Stage;

import flash.events.Event;

import flash.events.FullScreenEvent;

import mx.containers.ControlBar;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.VideoElement;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;
import org.osmf.metadata.Metadata;

public class BatchEventServicePlugin extends PluginInfo {

    private static var logger:ILogger = LoggerFactory.getClassLogger(BatchEventServicePlugin);

    public static const ID:String = "com.seesaw.player.batchEventService";

      public function BatchEventServicePlugin() {
        logger.debug("com.seesaw.player.batchEventService -- initialise");

        var item:MediaFactoryItem = new MediaFactoryItem(
                ID,
                canHandleResourceFunction,
                mediaElementCreationFunction,
                MediaFactoryItemType.PROXY);

        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
        items.push(item);

        super(items, mediaElementCreationNotificationCallback);
    }

    private static function canHandleResourceFunction(resource:MediaResourceBase):Boolean {
        logger.debug("can handle this resource: " + resource);
        var result:Boolean;


        if (resource != null) {
            var settings:Metadata = resource.getMetadataValue(PlayerConstants.SMIL_METADATA_NS) as Metadata;
            result = settings != null;
        }

        return result;
    }

    private static function mediaElementCreationFunction():MediaElement {
        logger.debug("constructing proxy element");
        return new BatchEventService();
    }

    private function mediaElementCreationNotificationCallback(target:MediaElement):void {
        logger.debug("mediaElementCreationNotificationCallback:" + target);
    }
}
}