package com.seesaw.player.controls {
import flash.display.Sprite;

import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;
import org.osmf.metadata.Metadata;

public class ControlBarPlugin extends Sprite {

    public static const ID:String = "com.seesaw.player.controls.controlbar";
    public static const NS_CONTROL_BAR_SETTINGS:String = "http://www.seesaw.com/player/controlbar/settings";
    public static const NS_CONTROL_BAR_TARGET:String = "http://www.seesaw.com/player/controlbar/target";

    private var info:PluginInfo;
    private var controlBarElement:MediaElement;
    private var targetElement:MediaElement;

    /**
     * Gives the player the PluginInfo.
     */
    public function get pluginInfo():PluginInfo {
        if (info == null) {
            var item:MediaFactoryItem = new MediaFactoryItem(
                    ID, canHandleResourceCallback, mediaElementCreationCallback);

            var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
            items.push(item);

            info = new PluginInfo(items, mediaElementCreationNotificationCallback);
        }

        return pluginInfo;
    }

    private function canHandleResourceCallback(resource:MediaResourceBase):Boolean {
        var result:Boolean;

        if (resource != null) {
            var settings:Metadata = resource.getMetadataValue(NS_CONTROL_BAR_SETTINGS) as Metadata;
            result = settings != null;
        }

        return result;
    }

    /**
     *  Creates a new instance of the media element
     */
    private function mediaElementCreationCallback():MediaElement {
        return controlBarElement;
    }

    private function mediaElementCreationNotificationCallback(target:MediaElement):void {
        targetElement = target;
    }
}
}