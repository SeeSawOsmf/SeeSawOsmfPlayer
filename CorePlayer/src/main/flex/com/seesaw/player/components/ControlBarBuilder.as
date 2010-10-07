package com.seesaw.player.components {
import com.seesaw.player.*;

import org.osmf.events.MediaFactoryEvent;
import org.osmf.layout.HorizontalAlign;
import org.osmf.layout.LayoutMetadata;
import org.osmf.layout.VerticalAlign;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfoResource;
import org.osmf.metadata.Metadata;

public class ControlBarBuilder implements MediaElementBuilder {

    private var factory:MediaFactory;

    public function ControlBarBuilder(factory:MediaFactory) {
        this.factory = factory;
        var controlBarPlugin:ControlBarPlugin = new ControlBarPlugin();
        var controlBarPluginInfo:PluginInfoResource = new PluginInfoResource(controlBarPlugin.pluginInfo);
        factory.loadPlugin(controlBarPluginInfo);
    }

    public function newInstance(id:String):MediaElement {
        var controlBarSettings:Metadata = new Metadata();
        controlBarSettings.addValue(PlayerConstants.ID, id);

        var resource:MediaResourceBase = new MediaResourceBase();
        resource.addMetadataValue(ControlBarPlugin.NS_CONTROL_BAR_SETTINGS, controlBarSettings);

        var controlBar:MediaElement = factory.createMediaElement(resource);

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

    public function isSourceOf(event:MediaFactoryEvent):Boolean {
        var pluginInfo:PluginInfoResource = PluginInfoResource(event.resource);

        if (pluginInfo.pluginInfo.numMediaFactoryItems > 0) {
            return pluginInfo.pluginInfo.getMediaFactoryItemAt(0).id == ControlBarPlugin.ID;
        }

        return false;
    }

    public function applyMetadataToElement(mediaElement:MediaElement):void {
        var controlBarTarget:Metadata = new Metadata();
        controlBarTarget.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);
        mediaElement.addMetadata(ControlBarPlugin.NS_CONTROL_BAR_TARGET, controlBarTarget);
    }
}
}