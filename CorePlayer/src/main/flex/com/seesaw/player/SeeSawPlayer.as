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
import com.seesaw.player.components.LiverailComponent;

import flash.display.Sprite;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ParallelElement;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.layout.LayoutMetadata;
import org.osmf.media.MediaElement;
import org.osmf.media.PluginInfoResource;

public class SeeSawPlayer extends Sprite {

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawPlayer);

    private var _controlBar:ControlBarComponent;
    private var _liverail:LiverailComponent;
    private var _config:PlayerConfiguration;
    private var _rootElement:ParallelElement;

    public function SeeSawPlayer(playerConfig:PlayerConfiguration) {
        logger.debug("creating player");

        _config = playerConfig;

        initialisePlayer();
        createComponents();
    }

    private function initialisePlayer():void {
        logger.debug("initialising media player");

        _config.factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
        _config.factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadError);

        _config.player.media = createRootElement();

        _config.container.addMediaElement(_rootElement);
        addChild(_config.container);
    }

    private function createComponents():void {
        logger.debug("creating components");

        _controlBar = new ControlBarComponent(this);
        _config.factory.loadPlugin(_controlBar.info);

        _liverail = new LiverailComponent(this);
        _config.factory.loadPlugin(_liverail.info);
    }

    private function createRootElement():MediaElement {
        logger.debug("creating root element");

        _rootElement = new ParallelElement();
        _rootElement.addChild(_config.element);

        var rootElementLayout:LayoutMetadata = new LayoutMetadata();
        _rootElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, rootElementLayout);

        rootElementLayout.width = _config.width;
        rootElementLayout.height = _config.height;

        return _rootElement;
    }

    private function onPluginLoaded(event:MediaFactoryEvent):void {
        logger.debug("plugin loaded");


        if (event.resource is PluginInfoResource) {
            // We can now construct a control

            var pluginInfo:PluginInfoResource = PluginInfoResource(event.resource);

            if (pluginInfo.pluginInfo.numMediaFactoryItems > 0) {
                switch (pluginInfo.pluginInfo.getMediaFactoryItemAt(0).id) {
                    case ControlBarPlugin.ID:
                        controlBar.pluginLoaded(event);
                        break;


                }

            }
        }
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

    public function get controlBar():ControlBarComponent {
        return _controlBar;
    }

    public function set controlBar(value:ControlBarComponent):void {
        _controlBar = value;
    }

    public function get liverail():LiverailComponent {
        return _liverail;
    }

    public function set liverail(value:LiverailComponent):void {
        _liverail = value;
    }
}
}