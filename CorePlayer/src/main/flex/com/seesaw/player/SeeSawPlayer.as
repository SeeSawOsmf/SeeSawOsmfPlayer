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
import org.osmf.layout.HorizontalAlign;
import org.osmf.layout.LayoutMetadata;
import org.osmf.layout.VerticalAlign;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfoResource;
import org.osmf.metadata.Metadata;

import uk.co.vodco.osmfDebugProxy.DebugPluginInfo;
import uk.vodco.liverail.LiverailPlugin;

public class SeeSawPlayer extends Sprite {

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawPlayer);

    private var _controlBar:ControlBarComponent;
    private var _config:PlayerConfiguration;
    private var _rootElement:ParallelElement;

    private var _components:Dictionary;
    private var _liveRail:LiverailComponent;
    private var _defaultProxy:DefaultProxyComponent;
    private var _debugProxy:DebugProxyComponent;
    private var _videoElement:MediaElement;

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
        createVideoElement();
        createMediaElementPlugins();
        addChild(config.container);
    }

    private function createMediaElementPlugins():void {
        createControlBarElement();
        createLiverailElement();
    }

    private function createLiverailElement():void {
        logger.debug("creating control bar");

        _liveRail.applyMetadata(_videoElement);
        config.factory.loadPlugin(_liveRail.info);

        var pluginSettings:Metadata = new Metadata();
        pluginSettings.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);

        var resource:MediaResourceBase = new MediaResourceBase();
        resource.addMetadataValue(LiverailPlugin.NS_SETTINGS, pluginSettings);

        var pluginElement:MediaElement = config.factory.createMediaElement(resource);

        rootElement.addChild(pluginElement);
    }

    private function createVideoElement():void {
        logger.debug("loading plugins");

        config.factory.loadPlugin(_defaultProxy.info);
        config.factory.loadPlugin(_debugProxy.info);

        _videoElement = config.factory.createMediaElement(config.resource);
        logger.debug("VIDEO ELEMENT: " + _videoElement);
        rootElement.addChild(_videoElement);
    }

    private function createComponents():void {
        logger.debug("creating components");

        _components = new Dictionary();

        _debugProxy = new DebugProxyComponent(this);
        _components[DebugPluginInfo.ID] = _debugProxy;

        _defaultProxy = new DefaultProxyComponent(this);
        _components[DefaultProxyPluginInfo.ID] = _defaultProxy;

        _controlBar = new ControlBarComponent(this);
        _components[ControlBarPlugin.ID] = _controlBar;

        _liveRail = new LiverailComponent(this);
        _components[LiverailPlugin.ID] = _liveRail;
    }

    private function createControlBarElement():void {
        logger.debug("creating control bar");

        _controlBar.applyMetadata(_videoElement);
        config.factory.loadPlugin(_controlBar.info);

        var controlBarSettings:Metadata = new Metadata();
        controlBarSettings.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);

        var resource:MediaResourceBase = new MediaResourceBase();
        resource.addMetadataValue(ControlBarPlugin.NS_SETTINGS, controlBarSettings);

        var controlBarElement:MediaElement = config.factory.createMediaElement(resource);

        var layout:LayoutMetadata = controlBarElement.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
        if (layout == null) {
            layout = new LayoutMetadata();
            controlBarElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
        }
        layout.verticalAlign = VerticalAlign.BOTTOM;
        layout.horizontalAlign = HorizontalAlign.CENTER;

        layout.index = 1;

        rootElement.addChild(controlBarElement);
    }

    private function createRootElement():void {
        logger.debug("creating root element");

        rootElement = new ParallelElement();
        layout(config.width, config.height);

        config.player.media = rootElement;
        config.container.addMediaElement(rootElement);
    }

    private function onPluginLoaded(event:MediaFactoryEvent):void {
        logger.debug("plugin loaded");

        if (event.resource is PluginInfoResource) {
            var pluginInfo:PluginInfoResource = PluginInfoResource(event.resource);

            if (pluginInfo.pluginInfo.numMediaFactoryItems > 0) {
                var id:String = pluginInfo.pluginInfo.getMediaFactoryItemAt(0).id;
                var component:PluginLifecycle = _components[id] as PluginLifecycle;
                if (component) {
                    component.pluginLoaded(event);
                }
            }
        }
    }

    private function onPluginLoadError(event:MediaFactoryEvent):void {
        logger.debug("plugin error");
        _controlBar.pluginLoadError(event);
    }

    private function onMediaElementCreate(event:MediaFactoryEvent):void {
        logger.debug("CREATED MEDIA ELEMENT: " + event.mediaElement);

        var fullscreen:FullScreenTrait = event.mediaElement.getTrait(FullScreenTrait.FULL_SCREEN) as FullScreenTrait;
        if (fullscreen) {
            logger.debug("adding handler for full screen trait");
            fullscreen.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
        }
    }

    private function onFullscreen(event:FullScreenEvent):void {
        logger.debug("onFullscreen");

        if (event.value) {
            layout(stage.fullScreenWidth, stage.fullScreenHeight);
        }
        else {
            layout(config.width, config.height);
        }
    }

    private function layout(width:int, height:int):void {
        var rootElementLayout:LayoutMetadata = new LayoutMetadata();
        rootElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, rootElementLayout);

        rootElementLayout.width = width;
        rootElementLayout.height = height;

        config.container.layout(width, height, true);
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