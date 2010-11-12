package com.seesaw.player.captioning.sami {
import com.seesaw.player.logging.CommonsOsmfLoggerFactory;
import com.seesaw.player.logging.TraceAndArthropodLoggerFactory;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.logging.Log;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;
import org.osmf.metadata.Metadata;

public class SAMIPluginInfo extends PluginInfo {

    public static const METADATA_NAMESPACE:String = "http://www.seesaw.com/sami/1.0";
    public static const METADATA_KEY_URI:String = "uri";

    private static var loggerSetup:* = (LoggerFactory.loggerFactory = new TraceAndArthropodLoggerFactory());
    private static var osmfLoggerSetup:* = (Log.loggerFactory = new CommonsOsmfLoggerFactory());

    private var logger:ILogger = LoggerFactory.getClassLogger(SAMIPluginInfo);

    public function SAMIPluginInfo() {
        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();

        var item:MediaFactoryItem = new MediaFactoryItem("com.seesaw.player.captioning.sami.SAMIPluginInfo",
                canHandleResource, createSAMIProxyElement, MediaFactoryItemType.PROXY);
        items.push(item);

        super(items);
    }

    private function canHandleResource(resource:MediaResourceBase):Boolean {
        var canHandle:Boolean = false;

        if (resource != null) {
            var settings:Metadata = resource.getMetadataValue(METADATA_NAMESPACE) as Metadata;
            canHandle = settings != null;
        }

        return canHandle;
    }

    private function createSAMIProxyElement():MediaElement {
        return new SAMIProxyElement();
    }
}
}