/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *   The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *
 *   The Initial Developer of the Original Code is ioko365 Ltd.
 *   Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *   Incorporated. All Rights Reserved.
 */

package com.seesaw.player.components {
import com.seesaw.player.PlayerConstants;
import com.seesaw.player.SeeSawPlayer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.layout.HorizontalAlign;
import org.osmf.layout.LayoutMetadata;
import org.osmf.layout.VerticalAlign;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfoResource;
import org.osmf.metadata.Metadata;

import uk.co.vodco.osmfPlayer.Player;

public class ControlBarComponent {

    private var logger:ILogger = LoggerFactory.getClassLogger(Player);

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
        logger.info('onPluginLoaded');
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