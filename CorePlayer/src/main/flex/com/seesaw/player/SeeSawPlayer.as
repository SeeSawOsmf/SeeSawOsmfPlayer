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

package com.seesaw.player {
import com.seesaw.player.components.ControlBarComponent;

import flash.display.Sprite;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ParallelElement;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.layout.LayoutMetadata;
import org.osmf.media.MediaElement;
import org.osmf.media.PluginInfoResource;

import uk.vodco.livrail.LiverailPluginInfo;

public class SeeSawPlayer extends Sprite {

    private static const PLAYER_WIDTH:int = PLAYER::Width;
    private static const PLAYER_HEIGHT:int = PLAYER::Height;

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawPlayer);

    private var controlBar:ControlBarComponent;

    private var _config:PlayerConfiguration;
    private var _rootElement:ParallelElement;

    public function SeeSawPlayer(playerConfig:PlayerConfiguration) {
        logger.debug("creating player");

        config = playerConfig;

        initialisePlayer();
        createComponents();
    }

    private function initialisePlayer():void {
        logger.debug("initialising media player");

        config.factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
        config.factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadError);

        config.player.media = createRootElement();

        config.container.addMediaElement(rootElement);
        addChild(config.container);
    }

    private function createComponents():void {
        logger.debug("creating components");

        controlBar = new ControlBarComponent(this);
        config.factory.loadPlugin(controlBar.info);


        config.factory.loadPlugin(new PluginInfoResource(new LiverailPluginInfo()));
    }

    private function createRootElement():MediaElement {
        logger.debug("creating root element");

        rootElement = new ParallelElement();
        rootElement.addChild(config.element);

        var rootElementLayout:LayoutMetadata = new LayoutMetadata();
        rootElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, rootElementLayout);

        rootElementLayout.width = config.width;
        rootElementLayout.height = config.height;

        return rootElement;
    }

    // Event Handlers

    private function onPluginLoaded(event:MediaFactoryEvent):void {
        logger.debug("plugin loaded");
        controlBar.pluginLoaded(event);
    }

    private function onPluginLoadError(event:MediaFactoryEvent):void {
        logger.debug("plugin error");
        controlBar.pluginLoadError(event);
    }

    public function get rootElement():ParallelElement {
        return _rootElement;
    }

    public function set rootElement(value:ParallelElement):void {
        _rootElement = value;
    }

    public function get config():PlayerConfiguration {
        return _config;
    }

    public function set config(value:PlayerConfiguration):void {
        _config = value;
    }
}
}