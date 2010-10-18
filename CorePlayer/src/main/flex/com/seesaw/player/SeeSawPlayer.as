/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *    The contents of this file are subject to the Mozilla Public License
 *    Version 1.1 (the "License"); you may not use this file except in
 *    compliance with the License. You may obtain a copy of the
 *    License athttp://www.mozilla.org/MPL/
 *
 *    Software distributed under the License is distributed on an "AS IS"
 *    basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *    License for the specific language governing rights and limitations
 *    under the License.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 */

package com.seesaw.player {
import com.seesaw.player.components.ControlBarComponent;
import com.seesaw.player.components.DebugProxyComponent;
import com.seesaw.player.components.DefaultProxyComponent;
import com.seesaw.player.components.LiverailComponent;
import com.seesaw.player.components.PluginLifecycle;
import com.seesaw.proxyplugin.DefaultProxyPluginInfo;
import com.seesaw.proxyplugin.events.FullScreenEvent;
import com.seesaw.proxyplugin.traits.FullScreenTrait;

import flash.display.Sprite;
import flash.utils.Dictionary;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ParallelElement;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.layout.LayoutMetadata;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfoResource;
import org.osmf.metadata.Metadata;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.MediaTraitType;

import uk.co.vodco.osmfDebugProxy.DebugPluginInfo;
import uk.vodco.liverail.LiverailPlugin;

public class SeeSawPlayer extends Sprite {

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawPlayer);

    private var _controlBar:ControlBarComponent;
    private var _config:PlayerConfiguration;
    private var _rootElement:ParallelElement;

    private var components:Dictionary;
    private var _liveRail:LiverailComponent;
    private var _defaultProxy:DefaultProxyComponent;
    private var debugProxy:DebugProxyComponent;

    public function SeeSawPlayer(playerConfig:PlayerConfiguration) {
        logger.debug("creating player");

        config = playerConfig;

        initialisePlayer();
    }

    private function initialisePlayer():void {
        logger.debug("initialising media player");

        config.factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
        config.factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadError);
        config.factory.addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onMediaElementCreate);

        createComponents();
        createRootElement();

        loadPlugins();

        // create video element
        var videoElement:MediaElement = config.factory.createMediaElement(config.resource);

        // the control bar wants to be loaded after annotating the video
        var targetMetadata:Metadata = new Metadata();
        targetMetadata.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);
        videoElement.addMetadata(ControlBarPlugin.NS_TARGET, targetMetadata);

        config.factory.loadPlugin(liveRail.info);

        var liverailMetadata:Metadata = new Metadata();
        liverailMetadata.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);

        var resource:MediaResourceBase = new MediaResourceBase();
        resource.addMetadataValue(LiverailPlugin.NS_SETTINGS, liverailMetadata);

        var liverailElement:ParallelElement = config.factory.createMediaElement(resource) as ParallelElement;
        //  rootElement.addChild(liverailElement);

        config.factory.loadPlugin(controlBar.info);

        rootElement.addChild(videoElement);
        config.container.addMediaElement(rootElement);

        addChild(config.container);
    }

    private function loadPlugins():void {
        logger.debug("loading plugins");

        // config.factory.loadPlugin(controlBar.info);

        config.factory.loadPlugin(debugProxy.info);
        config.factory.loadPlugin(defaultProxy.info);
    }

    private function createComponents():void {
        logger.debug("creating components");

        components = new Dictionary();

        // TODO: this is still being worked out


        debugProxy = new DebugProxyComponent(this);
        //defaultProxy.applyMetadata(config.element);
        components[DebugPluginInfo.ID] = debugProxy;

        defaultProxy = new DefaultProxyComponent(this);
        // defaultProxy.applyMetadata(config.element);
        components[DefaultProxyPluginInfo.ID] = defaultProxy;

        controlBar = new ControlBarComponent(this);
        // controlBar.applyMetadata(config.element);
        components[ControlBarPlugin.ID] = controlBar;

        liveRail = new LiverailComponent(this);

        components[LiverailPlugin.ID] = liveRail;

    }

    private function createRootElement():void {
        logger.debug("creating root element");

        rootElement = new ParallelElement();

        var rootElementLayout:LayoutMetadata = new LayoutMetadata();
        rootElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, rootElementLayout);

        rootElementLayout.width = config.width;
        rootElementLayout.height = config.height;

        config.player.media = rootElement;
    }

    private function onPluginLoaded(event:MediaFactoryEvent):void {
        logger.debug("plugin loaded");

        if (event.resource is PluginInfoResource) {
            var pluginInfo:PluginInfoResource = PluginInfoResource(event.resource);

            if (pluginInfo.pluginInfo.numMediaFactoryItems > 0) {
                var id:String = pluginInfo.pluginInfo.getMediaFactoryItemAt(0).id;
                var component:PluginLifecycle = components[id] as PluginLifecycle;
                if (component) {
                    component.pluginLoaded(event);
                }
            }
        }
    }

    private function onPluginLoadError(event:MediaFactoryEvent):void {
        logger.debug("plugin error");
        controlBar.pluginLoadError(event);
    }

    private function onMediaElementCreate(event:MediaFactoryEvent):void {
        logger.debug("created media element");

        var displayable:DisplayObjectTrait = event.mediaElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
        if (displayable) {
            logger.debug("adding display object trait");
        }

        var fullscreen:FullScreenTrait = event.mediaElement.getTrait(FullScreenTrait.FULL_SCREEN) as FullScreenTrait;
        if (fullscreen) {
            logger.debug("adding handler for full screen trait");
            fullscreen.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
        }
    }

    private function onFullscreen(event:FullScreenEvent):void {
        logger.debug("onFullscreen");
        if (event.value) {
            config.container.width = stage.fullScreenWidth;
            config.container.height = stage.fullScreenHeight;
        }
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

    public function set liveRail(value:LiverailComponent):void {
        _liveRail = value;
    }

    public function get liveRail():LiverailComponent {
        return _liveRail;
    }

    public function set defaultProxy(value:DefaultProxyComponent):void {
        _defaultProxy = value;
    }

    public function get defaultProxy():DefaultProxyComponent {
        return _defaultProxy;
    }
}
}