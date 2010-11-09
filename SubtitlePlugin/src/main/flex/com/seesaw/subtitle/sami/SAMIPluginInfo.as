package com.seesaw.subtitle.sami {
import com.seesaw.subtitle.sami.SAMIElement;
import com.seesaw.subtitle.sami.SAMILoader;

import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;

public class SAMIPluginInfo extends PluginInfo {

    public function SAMIPluginInfo() {
        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();

        var item:MediaFactoryItem = new MediaFactoryItem("com.seesaw.subtitle.sami.SAMIPluginInfo",
                new SAMILoader().canHandleResource, createSAMIProxyElement);
        items.push(item);

        super(items);
    }

    private function createSAMIProxyElement():MediaElement {
        return new SAMIElement(null, new SAMILoader(mediaFactory));
    }

    override public function initializePlugin(resource:MediaResourceBase):void {
        // We'll use the player-supplied MediaFactory for creating all MediaElements.
        mediaFactory = resource.getMetadataValue(PluginInfo.PLUGIN_MEDIAFACTORY_NAMESPACE) as MediaFactory;
    }

    private var mediaFactory:MediaFactory;
}
}