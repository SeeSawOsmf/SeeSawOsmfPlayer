/*
 * * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *  *
 *  *   The contents of this file are subject to the Mozilla Public License
 *  *   Version 1.1 (the "License"); you may not use this file except in
 *  *   compliance with the License. You may obtain a copy of the License at
 *  *   http://www.mozilla.org/MPL/
 *  *
 *  *   Software distributed under the License is distributed on an "AS IS"
 *  *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *  *   License for the specific language governing rights and limitations
 *  *   under the License.
 *  *
 *  *
 *  *   The Initial Developer of the Original Code is ioko365 Ltd.
 *  *   Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *  *   Incorporated. All Rights Reserved.
 */

package com.seesaw.player.components {
import com.seesaw.player.PlayerConstants;
import com.seesaw.player.SeeSawPlayer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ParallelElement;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.media.MediaElement;
import org.osmf.media.PluginInfoResource;
import org.osmf.metadata.Metadata;

import uk.vodco.liverail.LiverailPlugin;

public class LiverailComponent implements PluginLifecycle {

    private var logger:ILogger = LoggerFactory.getClassLogger(LiverailComponent);

    private var player:SeeSawPlayer;

    private var loaded:Boolean;

    private var liveRailPluginInfo:PluginInfoResource;
    private var liveRailPlugin:LiverailPlugin = new LiverailPlugin();

    public function LiverailComponent(player:SeeSawPlayer) {
        this.player = player;
    }

    public function get info():PluginInfoResource {

        liveRailPluginInfo = new PluginInfoResource(liveRailPlugin.pluginInfo);
        return liveRailPluginInfo;
    }

    public function pluginLoaded(event:MediaFactoryEvent):void {
        logger.debug("plugin loaded");

        if (!this.loaded) {
            //    var LRElement:ParallelElement = new ParallelElement();
            //  LRElement.addChild(new DurationElement(20, new ImageElement(new URLResource("http://kgd-red-test-zxtm01.dev.vodco.co.uk/i/ccp/00000180/18055.jpg"))));
            //   player.rootElement.addChild(constructElement());

            ///     player.rootElement.addChild(LRElement);
            this.loaded = true;
        }
    }

    public function pluginLoadError(event:MediaFactoryEvent):void {
        logger.error("plugin load error");
    }

    public function applyMetadata(target:MediaElement):void {
        logger.debug("applying metadata: " + target);
        var Target:Metadata = new Metadata();
        Target.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);
        target.addMetadata(LiverailPlugin.NS_TARGET, Target);
    }

    private function constructElement():ParallelElement {

        var element:ParallelElement = liveRailPlugin.liverailElement.element;

        return element;


    }

}
}