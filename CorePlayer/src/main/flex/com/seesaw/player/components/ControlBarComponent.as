package com.seesaw.player.components {
import com.seesaw.player.PlayerConstants;
import com.seesaw.player.SeeSawPlayer;

import org.osmf.events.MediaFactoryEvent;
import org.osmf.layout.HorizontalAlign;
import org.osmf.layout.LayoutMetadata;
import org.osmf.layout.VerticalAlign;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfoResource;
import org.osmf.metadata.Metadata;

public class ControlBarComponent {

    private var player:SeeSawPlayer;

    public function ControlBarComponent(player:SeeSawPlayer) {
        this.player = player;

        player.factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
        player.factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadError);

        var controlBarPlugin:ControlBarPlugin = new ControlBarPlugin();
        var controlBarPluginInfo:PluginInfoResource = new PluginInfoResource(controlBarPlugin.pluginInfo);
        player.factory.loadPlugin(controlBarPluginInfo);
    }

    private function onPluginLoaded(event:MediaFactoryEvent):void {
        if (event.resource is PluginInfoResource) {
            var pluginInfo:PluginInfoResource = PluginInfoResource(event.resource);

            if (pluginInfo.pluginInfo.numMediaFactoryItems > 0) {
                if (pluginInfo.pluginInfo.getMediaFactoryItemAt(0).id == ControlBarPlugin.ID) {
                    player.element.addChild(constructControlBarElement());
                }
            }
        }
    }

    private function onPluginLoadError(event:MediaFactoryEvent):void {
    }

    private function constructControlBarElement():MediaElement {
        var controlBarSettings:Metadata = new Metadata();
        controlBarSettings.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);

        var resource:MediaResourceBase = new MediaResourceBase();
        resource.addMetadataValue(ControlBarPlugin.NS_CONTROL_BAR_SETTINGS, controlBarSettings);

        var controlBar:MediaElement = player.factory.createMediaElement(resource);

        var layout:LayoutMetadata = controlBar.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
        if (layout == null) {
            layout = new LayoutMetadata();
            controlBar.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
        }
        layout.verticalAlign = VerticalAlign.BOTTOM;
        layout.horizontalAlign = HorizontalAlign.CENTER;

        layout.index = 1;

        return controlBar;
    }

}
}