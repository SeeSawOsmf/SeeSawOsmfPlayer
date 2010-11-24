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
import com.seesaw.player.controls.ControlBarMetadata;
import com.seesaw.player.controls.ControlBarPlugin;
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
import org.osmf.layout.HorizontalAlign;
import org.osmf.layout.LayoutMetadata;
import org.osmf.layout.VerticalAlign;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaPlayer;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfoResource;
import org.osmf.media.URLResource;
import org.osmf.metadata.Metadata;
import org.osmf.metadata.MetadataWatcher;

public class SeeSawPlayer extends Sprite {

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawPlayer);

    private var config:PlayerConfiguration;
    private var videoElement:MediaElement;

    private var factory:MediaFactory;
    private var player:MediaPlayer;
    private var rootContainer:MediaContainer;
    private var rootElement:ParallelElement;
    private var subtitleElement:MediaElement;

    private var autoHideWatcher:MetadataWatcher;

    public function SeeSawPlayer(playerConfig:PlayerConfiguration) {
        logger.debug("creating player");

        config = playerConfig;

        factory = config.factory;
        player = new MediaPlayer();

        rootElement = new ParallelElement();
        rootContainer = new MediaContainer();

        initialisePlayer();
    }

    private function initialisePlayer():void {
        logger.debug("initialising media player");

        factory.addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onMediaElementCreate);

        createVideoElement();
        createControlBarElement();
        createSubtitleElement();

        player.media = videoElement;

        setPlayerSize(config.width, config.height);
        rootContainer.addMediaElement(rootElement);

        logger.debug("adding media container to stage");
        addChild(rootContainer);
    }

    private function createSubtitleElement():void {
        factory.loadPlugin(new PluginInfoResource(new SAMIPluginInfo()));

        subtitleElement = factory.createMediaElement(
                new URLResource("http://kgd-blue-test-zxtm01.dev.vodco.co.uk/s/ccp/00000025/2540.smi"));

        var layout:LayoutMetadata = new LayoutMetadata();
        subtitleElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);

        layout.index = 3;
        layout.percentWidth = 100;
        layout.height = 50;
        layout.bottom = 100;
        layout.horizontalAlign = HorizontalAlign.CENTER;
        layout.verticalAlign = VerticalAlign.BOTTOM;

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

        if (videoElement == null) {
            throw new ArgumentError("failed to create video element");
        }

        var fullScreen:FullScreenTrait = videoElement.getTrait(FullScreenTrait.FULL_SCREEN) as FullScreenTrait;
        if (fullScreen) {
            fullScreen.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
        }

        // watch the control bar for metadata changes in visibility
        autoHideWatcher
                = new MetadataWatcher
                (videoElement.metadata
                        , ControlBarMetadata.CONTROL_BAR_METADATA
                        , ControlBarMetadata.CONTROL_BAR_HIDDEN
                        , controlBarHiddenChangeCallback
                        );
        autoHideWatcher.watch();

        rootElement.addChild(videoElement);
    }

    private function createControlBarElement():void {
        logger.debug("adding control bar media element to container");

        var controlBarTarget:Metadata = new Metadata();
        controlBarTarget.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);
        videoElement.addMetadata(ControlBarPlugin.NS_TARGET, controlBarTarget);

        logger.debug("loading control bar plugin");
        factory.loadPlugin(new PluginInfoResource(new ControlBarPlugin().pluginInfo));

        var controlBarSettings:Metadata = new Metadata();
        controlBarSettings.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);

        var resource:MediaResourceBase = new MediaResourceBase();
        resource.addMetadataValue(ControlBarPlugin.NS_SETTINGS, controlBarSettings);

        logger.debug("creating control bar media element");
        var controlBarElement:MediaElement = factory.createMediaElement(resource);

        if (controlBarElement == null) {
            logger.warn("failed to create control bar for player");
            return;
        }

        var layout:LayoutMetadata = new LayoutMetadata();
        controlBarElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);

        layout.index = 1;
        layout.verticalAlign = VerticalAlign.BOTTOM;
        layout.horizontalAlign = HorizontalAlign.CENTER;

        rootElement.addChild(controlBarElement);
    }

    private function onMediaElementCreate(event:MediaFactoryEvent):void {
        event.mediaElement.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaTraitsChange);
        event.mediaElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaTraitsChange);
    }

    private function onMediaTraitsChange(event:MediaElementEvent):void {
        var target = event.target as MediaElement;
        if (event.traitType == FullScreenTrait.FULL_SCREEN) {
            var fullScreen:FullScreenTrait = target.getTrait(FullScreenTrait.FULL_SCREEN) as FullScreenTrait;
            if (fullScreen) {
                if (event.type == MediaElementEvent.TRAIT_ADD) {
                    fullScreen.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
                }
                else {
                    fullScreen.removeEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
                }
            }
        }
    }

    private function onFullscreen(event:FullScreenEvent):void {
        logger.debug("onFullscreen: " + event.value);
        var width:int = event.value ? stage.fullScreenWidth : config.width;
        var height:int = event.value ? stage.fullScreenHeight : config.height;
        setPlayerSize(width, height);
    }

    private function setPlayerSize(width:int, height:int) {
        var layout:LayoutMetadata = rootElement.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
        if (layout == null) {
            layout = new LayoutMetadata();
            rootElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);

        }
        layout.width = width;
        layout.height = height;
        rootContainer.layout(width, height, true);
    }

    private function controlBarHiddenChangeCallback(value:Boolean):void {
        logger.debug("control bar hidden: " + value);
        if (subtitleElement) {
            var layoutMetadata:LayoutMetadata = subtitleElement.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
            if (layoutMetadata) {
                layoutMetadata.bottom = value ? 20 : 100;
            }
        }
    }
}
}