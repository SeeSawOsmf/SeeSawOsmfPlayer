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
import com.seesaw.player.autoresume.AutoResumeProxyPluginInfo;
import com.seesaw.player.captioning.sami.SAMIPluginInfo;
import com.seesaw.player.components.ControlBarComponent;
import com.seesaw.player.events.FullScreenEvent;
import com.seesaw.player.fullscreen.FullScreenProxyPluginInfo;
import com.seesaw.player.preventscrub.ScrubPreventionProxyPluginInfo;
import com.seesaw.player.smil.SMILPluginInfo;
import com.seesaw.player.traits.fullscreen.FullScreenTrait;

import flash.display.Sprite;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.containers.MediaContainer;
import org.osmf.elements.ParallelElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.layout.LayoutMetadata;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaPlayer;
import org.osmf.media.PluginInfoResource;
import org.osmf.media.URLResource;

public class SeeSawPlayer extends Sprite {

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawPlayer);

    private var config:PlayerConfiguration;
    private var rootElement:ParallelElement;
    private var videoElement:MediaElement;

    private var factory:MediaFactory;
    private var player:MediaPlayer;
    private var rootContainer:MediaContainer;
    private var mainContainer:MediaContainer;

    public function SeeSawPlayer(playerConfig:PlayerConfiguration) {
        logger.debug("creating player");

        config = playerConfig;

        factory = config.factory;
        player = new MediaPlayer();

        rootContainer = new MediaContainer();
        mainContainer = new MediaContainer();

        initialisePlayer();
    }

    private function initialisePlayer():void {
        logger.debug("initialising media player");

        factory.addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onMediaElementCreate);

        rootElement = new ParallelElement();

        createVideoElement();
        createControlBarElement();
        createSubtitleElement();

        logger.debug("adding root parallel element to container");
        player.media = rootElement;
        layout(config.width, config.height);
        mainContainer.addMediaElement(rootElement);

        rootContainer.layoutRenderer.addTarget(mainContainer);

        logger.debug("adding container to stage");
        addChild(rootContainer);
    }

    private function createSubtitleElement():void {
        factory.loadPlugin(new PluginInfoResource(new SAMIPluginInfo()));

        var subtitleElement:MediaElement = factory.createMediaElement(
                new URLResource("http://kgd-blue-test-zxtm01.dev.vodco.co.uk/s/ccp/00000025/2540.smi"));

        var layout:LayoutMetadata = new LayoutMetadata();
        subtitleElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);

        layout.index = 5;
        layout.x = 0;
        layout.y = config.height * 0.75;

        layout.width = config.width;
        layout.height = 200;

        rootElement.addChild(subtitleElement);
    }

    private function createVideoElement():void {
        logger.debug("loading the proxy plugins that wrap the video element");
        factory.loadPlugin(new PluginInfoResource(new SMILPluginInfo()));
        // factory.loadPlugin(new PluginInfoResource(new DebugPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new FullScreenProxyPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new AutoResumeProxyPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new ScrubPreventionProxyPluginInfo()));
        // factory.loadPlugin(new PluginInfoResource(new AdProxyPluginInfo()));

        if (config.resource.getMetadataValue("contentInfo").adType == config.adModuleType)
            factory.loadPlugin(new PluginInfoResource(new AdProxyPluginInfo()));

        ///      if (config.adModuleType == "com.seesaw.player.ads.serial")
        ///       factory.loadPlugin(new PluginInfoResource(new PlaylistPluginInfo()));

        logger.debug("creating video element");
        videoElement = factory.createMediaElement(config.resource);
        // videoElement = new BufferManager(0.5, 5, _videoElement);

        var fullScreen:FullScreenTrait = videoElement.getTrait(FullScreenTrait.FULL_SCREEN) as FullScreenTrait;
        if (fullScreen) {
            fullScreen.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
        }

        logger.debug("adding video element to container");
        rootElement.addChild(videoElement);
    }

    private function createControlBarElement():void {
        logger.debug("adding control bar media element to container");

        var controlBarComponent:ControlBarComponent = new ControlBarComponent();
        var controlBarElement:MediaElement = controlBarComponent.createMediaElement(factory, videoElement);
        rootElement.addChild(controlBarElement);
    }

    private function onMediaElementCreate(event:MediaFactoryEvent):void {
        event.mediaElement.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaTraitsChange);
        event.mediaElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaTraitsChange);
    }

    private function onMediaTraitsChange(event:MediaElementEvent):void {
        var target = event.target as MediaElement;

        var fullScreen:FullScreenTrait = target.getTrait(FullScreenTrait.FULL_SCREEN) as FullScreenTrait;

        if (fullScreen && event.traitType == FullScreenTrait.FULL_SCREEN) {
            fullScreen.removeEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
            if (event.type == MediaElementEvent.TRAIT_ADD) {
                fullScreen.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
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
        logger.debug("setting new layout for main media element: " + width + "x" + height);

        var rootElementLayout:LayoutMetadata = new LayoutMetadata();
        rootElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, rootElementLayout);

        rootElementLayout.width = width;
        rootElementLayout.height = height;

        rootContainer.layout(width, height, true);
    }
}
}