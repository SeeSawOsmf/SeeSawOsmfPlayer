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
import com.seesaw.player.external.PlayerExternalInterface;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.namespaces.contentinfo;
import com.seesaw.player.preventscrub.ScrubPreventionProxyPluginInfo;
import com.seesaw.player.smil.SeeSawSMILLoader;

import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.FullScreenEvent;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.containers.MediaContainer;
import org.osmf.elements.ParallelElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MediaFactoryEvent;
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
import org.osmf.smil.SMILConstants;
import org.osmf.smil.SMILPluginInfo;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.TimeTrait;

public class SeeSawPlayer extends Sprite {

    use namespace contentinfo;

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawPlayer);

    private var config:PlayerConfiguration;
    private var videoElement:MediaElement;

    private var factory:MediaFactory;
    private var player:MediaPlayer;
    private var rootContainer:MediaContainer;
    private var rootElement:ParallelElement;
    private var subtitleElement:MediaElement;
    private var dogImage:MediaElement;

    private var xi:PlayerExternalInterface;

    private var playerInit:XML;
    private var videoInfo:XML;

    private var lightsDown:Boolean = false;

    public function SeeSawPlayer(playerConfig:PlayerConfiguration) {
        logger.debug("creating player");

        xi = ObjectProvider.getInstance().getObject(PlayerExternalInterface);

        config = playerConfig;
        playerInit = playerConfig.resource.getMetadataValue(PlayerConstants.CONTENT_INFO) as XML;
        videoInfo = playerConfig.resource.getMetadataValue(PlayerConstants.VIDEO_INFO) as XML;

        factory = config.factory;

        factory.addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onMediaElementCreate);

        player = new MediaPlayer();
        rootElement = new ParallelElement();
        rootContainer = new MediaContainer();

        initialisePlayer();

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event) {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
    }

    private function initialisePlayer():void {
        logger.debug("initialising media player");

        createVideoElement();
        createControlBarElement();
        createSubtitleElement();

        player.media = videoElement;

        setPlayerSize(contentWidth, contentHeight);
        rootContainer.addMediaElement(rootElement);

        logger.debug("adding media container to stage");
        addChild(rootContainer);
    }

    private function createSubtitleElement():void {
        factory.loadPlugin(new PluginInfoResource(new SAMIPluginInfo()));

        if (captionUrl) {
            logger.debug("creating captions: " + captionUrl);
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
        // factory.loadPlugin(new PluginInfoResource(new DebugPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new AutoResumeProxyPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new ScrubPreventionProxyPluginInfo()));

        if (config.resource.getMetadataValue("contentInfo").adType == config.adModuleType)
            factory.loadPlugin(new PluginInfoResource(new AdProxyPluginInfo()));

        logger.debug("creating video element");
        videoElement = factory.createMediaElement(config.resource);

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
            if (xi.available) {
                xi.callLightsDown();
                this.lightsDown = true;
            }
        }
        if (event.playState == PlayState.PAUSED && (timeTrait.currentTime != timeTrait.duration)) {
            if (xi.available) {
                xi.callLightsUp();
                this.lightsDown = false;
            }
        }
    }

    private function onFullscreen(event:FullScreenEvent):void {
        logger.debug("onFullscreen: " + event.fullScreen);
        setPlayerSize(contentWidth, contentHeight);
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
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onControlBarMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onControlBarMetadataChange);
        }
        else if (event.namespaceURL == SMILConstants.SMIL_METADATA_NS) {
            var metadata:Metadata = videoElement.getMetadata(SMILConstants.SMIL_METADATA_NS);
            var contentType:String = metadata.getValue(PlayerConstants.CONTENT_TYPE) as String;
            logger.debug("switching to content: " + contentType);
        }
    }

    private function onVideoMetadataRemove(event:MediaElementEvent):void {
        if (event.namespaceURL == ControlBarMetadata.CONTROL_BAR_METADATA) {
            var metadata:Metadata = videoElement.getMetadata(ControlBarMetadata.CONTROL_BAR_METADATA);
            metadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onControlBarMetadataChange);
            metadata.removeEventListener(MetadataEvent.VALUE_ADD, onControlBarMetadataChange);
        }
    }

    private function onControlBarMetadataChange(event:MetadataEvent):void {
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

    private function onMediaElementCreate(event:MediaFactoryEvent):void {
        var resource:MediaResourceBase = event.mediaElement.resource;

        if (resource) {
            var smilMetadata:Metadata = resource.getMetadataValue(SMILConstants.SMIL_METADATA_NS) as Metadata;

            if (smilMetadata) {
                var contentType:String = smilMetadata.getValue(PlayerConstants.CONTENT_TYPE) as String;
                var mediaElement:MediaElement = event.mediaElement;

                switch (contentType) {
                    case PlayerConstants.DOG_CONTENT_ID:
                        var layout:LayoutMetadata = new LayoutMetadata();
                        layout.x = 5;
                        layout.y = 5;
                        layout.verticalAlign = VerticalAlign.TOP;
                        layout.horizontalAlign = HorizontalAlign.LEFT;
                        mediaElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
                        break;
                    case PlayerConstants.MAIN_CONTENT_ID:
                    case PlayerConstants.STING_CONTENT_ID:
                    case PlayerConstants.AD_CONTENT_ID:
                        var layout:LayoutMetadata = new LayoutMetadata();
                        layout.width = contentWidth;
                        layout.height = contentHeight;
                        mediaElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
                        break;
                }
            }
        }
    }

    public function get contentWidth():int {
        if (stage == null) {
            return config.width;
        }
        return stage.displayState == StageDisplayState.FULL_SCREEN ? stage.fullScreenWidth : config.width;
    }

    public function get contentHeight():int {
        if (stage == null) {
            return config.height;
        }
        return stage.displayState == StageDisplayState.FULL_SCREEN ? stage.fullScreenHeight : config.height;
    }
}
}