package com.seesaw.player.components {
import com.seesaw.player.PlayerConstants;
import com.seesaw.player.SeeSawPlayer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfoResource;
import org.osmf.metadata.Metadata;

import uk.vodco.livrail.LiverailPlugin;
import uk.vodco.livrail.LiverailPluginInfo;

public class LiverailComponent implements PluginLifecycle {

    private var logger:ILogger = LoggerFactory.getClassLogger(LiverailComponent);

    private var player:SeeSawPlayer;

    private var loaded:Boolean;

    private var qualifiedDefinition:String;

    public function LiverailComponent(player:SeeSawPlayer) {
        this.player = player;
    }


    public function get info():PluginInfoResource {
        var plugin:LiverailPlugin = new LiverailPlugin();
        var pluginInfo:PluginInfoResource = new PluginInfoResource(plugin.pluginInfo);
        return pluginInfo;
    }

    public function pluginLoaded(event:MediaFactoryEvent):void {
        logger.debug("plugin loaded");

        player.rootElement.addChild(constructPlugInElement());
        this.loaded = true;
    }

    public function pluginLoadError(event:MediaFactoryEvent):void {
        logger.error("plugin load error");
    }

    private function constructPlugInElement():MediaElement {
        var pluginSettings:Metadata = new Metadata();
        pluginSettings.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);

        var resource:MediaResourceBase = new MediaResourceBase();
        resource.addMetadataValue(LiverailPluginInfo.NS_SETTINGS, pluginSettings);

        var plugin:MediaElement = player.config.factory.createMediaElement(resource);

        /*     var layout:LayoutMetadata = plugin.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
         if (layout == null) {
         layout = new LayoutMetadata();
         plugin.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
         }
         layout.verticalAlign = VerticalAlign.BOTTOM;
         layout.horizontalAlign = HorizontalAlign.CENTER;

         layout.index = 1;
         */
        return plugin;
    }

    public function applyMetadata(target:MediaElement):void {
        logger.debug("applying metadata: " + target);
        var controlBarTarget:Metadata = new Metadata();
        controlBarTarget.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);
        target.addMetadata(LiverailPluginInfo.NS_TARGET, controlBarTarget);

    }
}
}