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
import com.seesaw.player.smil.SeeSawSMILLoader;
import com.seesaw.player.traits.fullscreen.FullScreenTrait;

import flash.display.Sprite;
import flash.external.ExternalInterface;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.containers.MediaContainer;
import org.osmf.elements.ParallelElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MetadataEvent;
import org.osmf.events.PlayEvent;
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
import org.osmf.smil.SMILPluginInfo;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.TimeTrait;

import uk.co.vodco.osmfDebugProxy.DebugPluginInfo;

public class SeeSawPlayer extends Sprite {

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawPlayer);

    private var config:PlayerConfiguration;
    private var videoElement:MediaElement;

    private var lightsDown:Boolean = false;

    private var factory:MediaFactory;
    private var player:MediaPlayer;
    private var rootContainer:MediaContainer;
    private var rootElement:ParallelElement;
    private var subtitleElement:MediaElement;
    private var dOGImage:MediaElement;

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

        createVideoElement();
        createControlBarElement();
        createSubtitleElement();
        createDOG("http://www.davemoorhouse.co.uk/DOG.png");

        player.media = videoElement;

        setPlayerSize(config.width, config.height);
        rootContainer.addMediaElement(rootElement);

        logger.debug("adding media container to stage");
        addChild(rootContainer);

    }

    private function createDOG(dOGURL:String):void {
        this.dOGImage = factory.createMediaElement(new URLResource(dOGURL));
        var layout:LayoutMetadata = new LayoutMetadata();
        this.dOGImage.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);

        layout.index = 5;
        layout.x = 5;
        layout.y = 5;
        layout.verticalAlign = VerticalAlign.TOP;
        layout.horizontalAlign = HorizontalAlign.LEFT;

        if (ExternalInterface.available) {
            ExternalInterface.addCallback("hideDOG", this.hideDOG);
            ExternalInterface.addCallback("showDOG", this.showDOG);
        }

        this.showDOG();
    }

    private function showDOG():void {
        rootElement.addChild(this.dOGImage);
    }

    private function hideDOG():void {
        rootElement.removeChild(this.dOGImage);
    }

    private function createSubtitleElement():void {
        factory.loadPlugin(new PluginInfoResource(new SAMIPluginInfo()));

        if (captionUrl) {
            subtitleElement = factory.createMediaElement(new URLResource(captionUrl));

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
    }

    private function createVideoElement():void {
        logger.debug("loading the proxy plugins that wrap the video element");
        factory.loadPlugin(new PluginInfoResource(new SMILPluginInfo(new SeeSawSMILLoader())));
        factory.loadPlugin(new PluginInfoResource(new DebugPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new FullScreenProxyPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new AutoResumeProxyPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new ScrubPreventionProxyPluginInfo()));
        // factory.loadPlugin(new PluginInfoResource(new AdProxyPluginInfo()));

        if (config.resource.getMetadataValue("contentInfo").adType == config.adModuleType)
            factory.loadPlugin(new PluginInfoResource(new AdProxyPluginInfo()));

        logger.debug("creating video element");
        videoElement = factory.createMediaElement(config.resource);
        // videoElement = new BufferManager(0.5, 5, videoElement);

        if (videoElement == null) {
            throw new ArgumentError("failed to create video element");
        }

        var fullScreen:FullScreenTrait = videoElement.getTrait(FullScreenTrait.FULL_SCREEN) as FullScreenTrait;
        if (fullScreen) {
            fullScreen.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
        }

        videoElement.addEventListener(MediaElementEvent.METADATA_ADD, onVideoMetadataAdd);
        videoElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onVideoMetadataRemove);

        videoElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
        videoElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

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

    private function updateTraitListeners(element:MediaElement, traitType:String, add:Boolean):void {
        switch (traitType) {
            case FullScreenTrait.FULL_SCREEN:
                changeListeners(element, add, traitType, FullScreenEvent.FULL_SCREEN, onFullscreen);
                break;
            case MediaTraitType.PLAY:
                changeListeners(element, add, traitType, PlayEvent.PLAY_STATE_CHANGE, onPlayStateChanged);
                break;
        }
    }

    private function onTraitAdd(event:MediaElementEvent):void {
        var target = event.target as MediaElement;
        updateTraitListeners(target, event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        var target = event.target as MediaElement;
        updateTraitListeners(target, event.traitType, false);
    }

    private function changeListeners(element:MediaElement, add:Boolean, traitType:String, event:String, listener:Function):void {
        if (add) {
            element.getTrait(traitType).addEventListener(event, listener);
        }
        else if (element.hasTrait(traitType)) {
            element.getTrait(traitType).removeEventListener(event, listener);
        }
    }

    private function onPlayStateChanged(event:PlayEvent):void {
        var timeTrait:TimeTrait = videoElement.getTrait(MediaTraitType.TIME) as TimeTrait;
        if (event.playState == PlayState.PLAYING && !this.lightsDown) {
            if (ExternalInterface.available) {
                ExternalInterface.call("lightsDown.lightsDown");
                this.lightsDown = true;
            }
        }
        if (event.playState == PlayState.PAUSED && (timeTrait.currentTime != timeTrait.duration)) {
            if (ExternalInterface.available) {
                ExternalInterface.call("lightsDown.lightsUp");
                this.lightsDown = false;
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

    private function onVideoMetadataAdd(event:MediaElementEvent):void {
        if (event.namespaceURL == ControlBarMetadata.CONTROL_BAR_METADATA) {
            var metadata:Metadata = videoElement.getMetadata(ControlBarMetadata.CONTROL_BAR_METADATA);
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, controlBarMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_ADD, controlBarMetadataChange);
        }
    }

    private function onVideoMetadataRemove(event:MediaElementEvent):void {
        if (event.namespaceURL == ControlBarMetadata.CONTROL_BAR_METADATA) {
            var metadata:Metadata = videoElement.getMetadata(ControlBarMetadata.CONTROL_BAR_METADATA);
            metadata.removeEventListener(MetadataEvent.VALUE_CHANGE, controlBarMetadataChange);
            metadata.removeEventListener(MetadataEvent.VALUE_ADD, controlBarMetadataChange);
        }
    }

    private function controlBarMetadataChange(event:MetadataEvent):void {
        logger.debug("control bar metadata change: key = {0}, value = {1}", event.key, event.value);
        switch (event.key) {
            case ControlBarMetadata.CONTROL_BAR_HIDDEN:
                if (subtitleElement) {
                    var layoutMetadata:LayoutMetadata =
                            subtitleElement.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
                    if (layoutMetadata) {
                        layoutMetadata.bottom = event.value ? 20 : 100;
                    }
                }
                break;
            case ControlBarMetadata.SUBTITLES_VISIBLE:
                if (subtitleElement) {
                    var displayTrait:DisplayObjectTrait =
                            subtitleElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
                    if (displayTrait) {
                        displayTrait.displayObject.visible = event.value;
                    }
                }
                break;
        }
    }

    private function get captionUrl():String {
        var metadata:Metadata = config.resource.getMetadataValue(SAMIPluginInfo.METADATA_NAMESPACE) as Metadata;
        if (metadata) {
            return metadata.getValue(SAMIPluginInfo.METADATA_KEY_URI) as String;
        }
        return null;
    }
}
}