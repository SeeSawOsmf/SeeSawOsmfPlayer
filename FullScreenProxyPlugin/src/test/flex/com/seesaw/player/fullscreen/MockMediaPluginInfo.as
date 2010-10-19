package com.seesaw.player.fullscreen {
import com.seesaw.player.*;

import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;

public class MockMediaPluginInfo extends PluginInfo {
    
    public static const ID:String = "com.seesaw.test.Mock";

    public function MockMediaPluginInfo() {
        var item:MediaFactoryItem = new MediaFactoryItem(
                ID,
                canHandleResourceFunction,
                mediaElementCreationFunction,
                MediaFactoryItemType.STANDARD);

        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
        items.push(item);

        super(items);
    }

    private static function canHandleResourceFunction(resource:MediaResourceBase):Boolean {
        return true;
    }

    private static function mediaElementCreationFunction():MediaElement {
        return new MockMediaElement();
    }
}
}