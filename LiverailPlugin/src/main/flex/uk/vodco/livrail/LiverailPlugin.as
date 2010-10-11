package uk.vodco.livrail {
import flash.display.Sprite;

import org.osmf.media.PluginInfo;

public class LiverailPlugin  extends Sprite {
    public function LiverailPlugin() {
        _pluginInfo = new LiverailPluginInfo();
    }

    public function get pluginInfo():PluginInfo {
        return _pluginInfo;
    }

    private var _pluginInfo:LiverailPluginInfo;
}

}