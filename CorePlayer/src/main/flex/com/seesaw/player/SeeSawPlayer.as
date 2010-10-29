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
import com.seesaw.player.ads.AdProxyPluginInfo;
import com.seesaw.player.components.ControlBarComponent;
import com.seesaw.player.components.MediaComponent;
import com.seesaw.player.events.FullScreenEvent;
import com.seesaw.player.fullscreen.FullScreenProxyPluginInfo;
import com.seesaw.player.preventscrub.ScrubPreventionProxyPluginInfo;
import com.seesaw.player.traits.FullScreenTrait;

import flash.display.Sprite;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ParallelElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.layout.LayoutMetadata;
import org.osmf.media.MediaElement;
import org.osmf.media.PluginInfoResource;

import uk.co.vodco.osmfDebugProxy.DebugPluginInfo;

public class SeeSawPlayer extends Sprite {

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawPlayer);

    private var _config:PlayerConfiguration;
    private var _rootElement:ParallelElement;
    private var _videoElement:MediaElement;

    public function SeeSawPlayer(playerConfig:PlayerConfiguration) {
        logger.debug("creating player");

        config = playerConfig;
        initialisePlayer();
    }

    private function initialisePlayer():void {
        logger.debug("initialising media player");

        config.factory.addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onMediaElementCreate);

        createRootElement();
        createVideoElement();
        createMediaElementPlugins();

        logger.debug("adding container to stage");
        addChild(config.container);
    }

    private function createMediaElementPlugins():void {
        logger.debug("adding control bar media element to container");
        addMediaElement(new ControlBarComponent());

    }

    private function addMediaElement(component:MediaComponent) {
        var mediaElement:MediaElement = component.createMediaElement(config.factory, _videoElement);
        _rootElement.addChild(mediaElement);
    }

    private function createVideoElement():void {
        logger.debug("loading the proxy plugins that wrap the video element");

        config.factory.loadPlugin(new PluginInfoResource(new DebugPluginInfo()));
        config.factory.loadPlugin(new PluginInfoResource(new FullScreenProxyPluginInfo()));

        config.factory.loadPlugin(new PluginInfoResource(new ScrubPreventionProxyPluginInfo()));
        config.factory.loadPlugin(new PluginInfoResource(new AdProxyPluginInfo()));


        logger.debug("creating video element");
        _videoElement = config.factory.createMediaElement(config.resource);


        if (_videoElement == null) {
            throw ArgumentError("failed to create main media element for player");
        }

        var fullScreen:FullScreenTrait = _videoElement.getTrait(FullScreenTrait.FULL_SCREEN) as FullScreenTrait;
        if (fullScreen) {
            fullScreen.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
        }

        logger.debug("adding video element to container");
        _rootElement.addChild(_videoElement);
    }

    private function createRootElement():void {
        logger.debug("creating root element");

        _rootElement = new ParallelElement();
        layout(config.width, config.height);
        config.player.media = _rootElement;

        logger.debug("adding root element to container");
        config.container.addMediaElement(_rootElement);
    }

    private function onMediaElementCreate(event:MediaFactoryEvent):void {
        event.mediaElement.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaTraitsChange);
        event.mediaElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaTraitsChange);
    }

    private function onMediaTraitsChange(event:MediaElementEvent):void {
        var target = event.target as MediaElement;

        var fullScreen:FullScreenTrait = target.getTrait(FullScreenTrait.FULL_SCREEN) as FullScreenTrait;


        if (fullScreen && event.traitType == FullScreenTrait.FULL_SCREEN) {
            if (event.type == MediaElementEvent.TRAIT_ADD) {
                logger.debug("adding handler for full screen trait: " + target);
                fullScreen.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
            }
            else {
                logger.debug("removing handler for full screen trait: " + target);
                fullScreen.removeEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);

            }
        }
    }

    private function onFullscreen(event:FullScreenEvent):void {
        logger.debug("onFullscreen: " + event.value);
        if (event.value) {
            layout(stage.fullScreenWidth, stage.fullScreenHeight);
        }
        else {
            layout(config.width, config.height);
        }
    }

    private function layout(width:int, height:int):void {
        logger.debug("setting new layout for root media element: " + width + "x" + height);

        var rootElementLayout:LayoutMetadata = new LayoutMetadata();
        _rootElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, rootElementLayout);

        rootElementLayout.width = width;
        rootElementLayout.height = height;

        config.container.layout(width, height, true);
    }

    public function get config():PlayerConfiguration {
        return _config;
    }

    public function set config(value:PlayerConfiguration):void {
        _config = value;
    }
}
}