package uk.vodco.livrail {
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;

public class LiverailPluginInfo extends PluginInfo {
    public function LiverailPluginInfo() {
        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
        items.push(mediaFactoryItem);

        super(items, mediaElementCreationNotificationFunction);
    }

    public static function get mediaFactoryItem():MediaFactoryItem {
        return _mediaFactoryItem;
    }

    private static function canHandleResourceFunction(resource:MediaResourceBase):Boolean {
        return true;
    }

    private static function mediaElementCreationFunction():MediaElement {

        return new LiverailElement();
    }

    private static var _mediaFactoryItem:MediaFactoryItem
            = new MediaFactoryItem
            (ID
                    , canHandleResourceFunction
                    , mediaElementCreationFunction
                    , MediaFactoryItemType.PROXY
                    );

    public static const ID:String = "uk.co.vodco.liverail.LiverailPluginInfo";
    public static const NS_SETTINGS:String = "http://www.seesaw.com/liverail/settings";
    public static const NS_TARGET:String = "http://www.seesaw.com/liverail/target";

}
}