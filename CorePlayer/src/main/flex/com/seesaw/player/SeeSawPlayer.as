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
import com.seesaw.player.ads.liverail.AdProxyPluginInfo;
import com.seesaw.player.ads.auditude.AdProxyPluginInfo;
import com.seesaw.player.autoresume.AutoResumeProxyPluginInfo;
import com.seesaw.player.batchEventService.BatchEventServicePlugin;
import com.seesaw.player.captioning.sami.SAMIPluginInfo;
import com.seesaw.player.controls.ControlBarMetadata;
import com.seesaw.player.controls.ControlBarPlugin;
import com.seesaw.player.external.ExternalInterfaceMetadata;
import com.seesaw.player.external.PlayerExternalInterface;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.namespaces.contentinfo;
import com.seesaw.player.netstatus.NetStatusMetadata;
import com.seesaw.player.panels.BufferingPanel;
import com.seesaw.player.preventscrub.ScrubPreventionProxyPluginInfo;
import com.seesaw.player.smil.SeeSawSMILLoader;

import com.auditude.ads.osmf.constants.AuditudeOSMFConstants;
  import com.auditude.ads.AuditudePlugin;
  import com.auditude.ads.osmf.IAuditudeMediaElement;
import com.seesaw.player.ads.AuditudeConstants;

import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.events.NetStatusEvent;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.containers.MediaContainer;
import org.osmf.elements.ParallelElement;
import org.osmf.events.BufferEvent;
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.events.MetadataEvent;
import org.osmf.events.PlayEvent;
import org.osmf.layout.HorizontalAlign;
import org.osmf.layout.LayoutMetadata;
import org.osmf.layout.ScaleMode;
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

import uk.co.vodco.osmfDebugProxy.DebugPluginInfo;

public class SeeSawPlayer extends Sprite {

    use namespace contentinfo;

    private static const AUDITUDE_PLUGIN_URL:String = "http://asset.cdn.auditude.com/flash/sandbox/plugin/osmf/AuditudeOSMFProxyPlugin.swf";

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawPlayer);

    private var config:PlayerConfiguration;
    private var contentElement:MediaElement;

    private var factory:MediaFactory;
    private var player:MediaPlayer;
    private var container:MediaContainer;
    private var mainContainer:MediaContainer;
    private var bufferingContainer:MediaContainer;
    private var controlbarContainer:MediaContainer;
    private var subtitlesContainer:MediaContainer;
    private var rootElement:ParallelElement;
    private var subtitleElement:MediaElement;
    private var bufferingPanel:BufferingPanel;

    private var xi:PlayerExternalInterface;
    
    // This is so we wait on Auditude loading before setting up the rest of the plugins and player
    private var pluginsToLoad:int = 2;

    private var playerInit:XML;
    private var videoInfo:XML;

    public function SeeSawPlayer(playerConfig:PlayerConfiguration) {
        logger.debug("creating player");

        xi = ObjectProvider.getInstance().getObject(PlayerExternalInterface);

        config = playerConfig;

        var metadata:Metadata = config.resource.getMetadataValue(PlayerConstants.METADATA_NAMESPACE) as Metadata;

        playerInit = metadata.getValue(PlayerConstants.CONTENT_INFO) as XML;
        if (playerInit == null) {
            throw new ArgumentError("player initialisation metadata not specified");
        }

        videoInfo = metadata.getValue(PlayerConstants.VIDEO_INFO) as XML;
        if (videoInfo == null) {
            throw new ArgumentError("video initialisation metadata not specified");
        }

        factory = config.factory;
        factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
        factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadFailed);
        factory.addEventListener(NetStatusEvent.NET_STATUS, netStatusChanged);
        factory.addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onMediaElementCreate);

        player = new MediaPlayer();
        player.autoPlay = false;

        rootElement = new ParallelElement();
        container = new MediaContainer();

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event) {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
    }

    public function init():void {
        logger.debug("initialising media player");

        mainContainer = new MediaContainer();
        mainContainer.y = 0;
        mainContainer.x = 0;
        mainContainer.layoutMetadata.percentWidth = 100;
        mainContainer.layoutMetadata.percentHeight = 100;
        addChild(mainContainer);

        bufferingContainer = new MediaContainer();
        bufferingContainer.y = 0;
        bufferingContainer.x = 0;
        bufferingContainer.backgroundColor = 0x000000;
        bufferingContainer.backgroundAlpha = 0;
        bufferingContainer.layoutMetadata.percentWidth = 100;
        bufferingContainer.layoutMetadata.percentHeight = 100;
        bufferingContainer.layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
        bufferingContainer.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
        addChild(bufferingContainer);

        subtitlesContainer = new MediaContainer();
        subtitlesContainer.y = 0;
        subtitlesContainer.x = 0;
        subtitlesContainer.layoutMetadata.percentWidth = 100;
        subtitlesContainer.layoutMetadata.percentHeight = 100;
        subtitlesContainer.layoutMetadata.verticalAlign = VerticalAlign.BOTTOM;
        addChild(subtitlesContainer);

        controlbarContainer = new MediaContainer();
        controlbarContainer.y = 0;
        controlbarContainer.x = 0;
        controlbarContainer.layoutMetadata.percentWidth = 100;
        controlbarContainer.layoutMetadata.height = 100;
        controlbarContainer.layoutMetadata.verticalAlign = VerticalAlign.BOTTOM;
        addChild(controlbarContainer);

        container.layoutRenderer.addTarget(mainContainer);
        container.layoutRenderer.addTarget(bufferingContainer);
        container.layoutRenderer.addTarget(subtitlesContainer);
        container.layoutRenderer.addTarget(controlbarContainer);

        // TODO: Only do this if we need auditude, otherwise just load the SMIL Plugin and then loadPlugins()
        loadAuditude(); // Once the auditude plugin is loaded, we'll set up the video and controls etc

        //handler to show and hide the buffering panel
        player.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);

        logger.debug("adding media container to stage");
        addChild(container);
    }

    private function loadAuditude():void {
        factory.loadPlugin(new URLResource(AUDITUDE_PLUGIN_URL));
        factory.loadPlugin(new PluginInfoResource(new SMILPluginInfo(new SeeSawSMILLoader())));
    }

    private function onPluginLoaded(event:MediaFactoryEvent):void {
      logger.debug("Loaded plugin " + event.resource);

      if (--pluginsToLoad <= 0) {
          logger.debug("All plugins loaded");
          loadPlugins();
      }
    }

    private function loadPlugins():void {
        logger.debug("loading the proxy plugins that wrap the video element");

        factory.removeEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
        factory.removeEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadFailed);

        factory.loadPlugin(new PluginInfoResource(new DebugPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new AutoResumeProxyPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new ScrubPreventionProxyPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new com.seesaw.player.ads.liverail.AdProxyPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new com.seesaw.player.ads.auditude.AdProxyPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new BatchEventServicePlugin()));
        
        createVideoElement();
    }    

    private function onPluginLoadFailed(event:MediaFactoryEvent):void {
      logger.debug("PROBLEM LOADING " + event.toString());
    }

    private function createBufferingPanel():void {
        //Create the Buffering Panel
        bufferingPanel = new BufferingPanel(bufferingContainer);
        bufferingContainer.addMediaElement(bufferingPanel);
    }

    private function onBufferingChange(event:BufferEvent):void {
        (event.buffering) ? bufferingPanel.show() : bufferingPanel.hide();
    }

    private function createSubtitleElement():void {
        if (captionUrl) {
            logger.debug("creating captions: " + captionUrl);

            var targetMetadata:Metadata = new Metadata();
            targetMetadata.addValue(PlayerConstants.CONTENT_ID, PlayerConstants.MAIN_CONTENT_ID);
            contentElement.addMetadata(SAMIPluginInfo.NS_TARGET_ELEMENT, targetMetadata);

            factory.loadPlugin(new PluginInfoResource(new SAMIPluginInfo()));
            subtitleElement = factory.createMediaElement(new URLResource(captionUrl));

            var layout:LayoutMetadata = new LayoutMetadata();
            subtitleElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);

            layout.percentWidth = 100;
            layout.height = 50;
            layout.bottom = 100;
            layout.horizontalAlign = HorizontalAlign.CENTER;
            layout.verticalAlign = VerticalAlign.BOTTOM;

            subtitlesContainer.addMediaElement(subtitleElement);
        }
    }

    private function createVideoElement():void {
        logger.debug("creating video element");
        contentElement = factory.createMediaElement(config.resource);

        contentElement.addEventListener(MediaElementEvent.METADATA_ADD, onContentMetadataAdd);
        contentElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onContentMetadataRemove);

        contentElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
        contentElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

        createBufferingPanel();
        createControlBarElement();
        createSubtitleElement();

        if (contentElement is IAuditudeMediaElement) {
          var _auditude:AuditudePlugin = IAuditudeMediaElement(contentElement).plugin;

          // We set this in the metadata so the auditude AdProxy can pick up the plugin
          var metadata:Metadata = config.resource.getMetadataValue(AuditudeOSMFConstants.AUDITUDE_METADATA_NAMESPACE) as Metadata;
          metadata.addValue(AuditudeConstants.PLUGIN_INSTANCE, _auditude);
        }

        player.media = contentElement;

        setContainerSize(contentWidth, contentHeight);

        mainContainer.addMediaElement(contentElement);
    }

    private function createControlBarElement():void {
        logger.debug("adding control bar media element to container");

        var controlBarTarget:Metadata = new Metadata();
        controlBarTarget.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);
        contentElement.addMetadata(ControlBarPlugin.NS_TARGET, controlBarTarget);

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

        controlbarContainer.addMediaElement(controlBarElement);
    }

    private function updateTraitListeners(element:MediaElement, traitType:String, add:Boolean):void {
        switch (traitType) {
            case MediaTraitType.PLAY:
                changeListeners(element, add, traitType, PlayEvent.PLAY_STATE_CHANGE, onPlayStateChanged);
                break;
              case MediaTraitType.LOAD:
                changeListeners(element, add, traitType, LoadEvent.LOAD_STATE_CHANGE, onLoadStateChanged);
                break;
        }
    }

    private function onLoadStateChanged(event:LoadEvent):void {
        trace(event.loadState);
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
        var lightsDown:Boolean = false;

        var metadata:Metadata = contentElement.getMetadata(ExternalInterfaceMetadata.EXTERNAL_INTERFACE_METADATA);

        if(metadata == null) {
            metadata = new Metadata();
            contentElement.addMetadata(ExternalInterfaceMetadata.EXTERNAL_INTERFACE_METADATA, metadata);
        }

        lightsDown = metadata.getValue(ExternalInterfaceMetadata.LIGHTS_DOWN);

        var timeTrait:TimeTrait = contentElement.getTrait(MediaTraitType.TIME) as TimeTrait;
        if (event.playState == PlayState.PLAYING && !lightsDown) {
            if (xi.available) {
                xi.callLightsDown();
                metadata.addValue(ExternalInterfaceMetadata.LIGHTS_DOWN, true);
            }
        }
        if (event.playState == PlayState.PAUSED && timeTrait && (timeTrait.currentTime != timeTrait.duration)) {
            if (xi.available) {
                xi.callLightsUp();
                metadata.addValue(ExternalInterfaceMetadata.LIGHTS_DOWN, false);
            }
        }


    }

    private function netStatusChanged(event:*):void {

         if(event.info == "NetConnection.Connect.NetworkChange"){

            factory.removeEventListener(NetStatusEvent.NET_STATUS, netStatusChanged);

            var metadata:Metadata = contentElement.getMetadata(NetStatusMetadata.NET_STATUS_METADATA);

            if (metadata == null) {
                metadata = new Metadata();
                contentElement.addMetadata(NetStatusMetadata.NET_STATUS_METADATA, metadata);
            }

                metadata.addValue(NetStatusMetadata.STATUS, event.type);
        }
    }


    private function onFullscreen(event:FullScreenEvent):void {
        logger.debug("onFullscreen: " + event.fullScreen);
        setContainerSize(contentWidth, contentHeight);
    }

    private function setContainerSize(width:int, height:int) {
        container.width = width;
        container.height = height;
    }

    private function onContentMetadataAdd(event:MediaElementEvent):void {
        if (event.namespaceURL == ControlBarMetadata.CONTROL_BAR_METADATA) {
            var metadata:Metadata = contentElement.getMetadata(ControlBarMetadata.CONTROL_BAR_METADATA);
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onControlBarMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onControlBarMetadataChange);
        }
    }

    private function onContentMetadataRemove(event:MediaElementEvent):void {
        if (event.namespaceURL == ControlBarMetadata.CONTROL_BAR_METADATA) {
            var metadata:Metadata = contentElement.getMetadata(ControlBarMetadata.CONTROL_BAR_METADATA);
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

    private function onMediaElementCreate(event:MediaFactoryEvent):void {
        var mediaElement:MediaElement = event.mediaElement;

        var _setContentLayout:Function = function(metadataEvent:MetadataEvent):void {
            if (metadataEvent.key == PlayerConstants.CONTENT_TYPE) {
                setContentLayout(metadataEvent.value, mediaElement);
            }
        }

        event.mediaElement.addEventListener(MediaElementEvent.METADATA_ADD, function(mediaElementEvent:MediaElementEvent):void {
            if (mediaElementEvent.namespaceURL == SMILConstants.SMIL_METADATA_NS) {
                mediaElementEvent.metadata.addEventListener(MetadataEvent.VALUE_ADD, _setContentLayout);
                mediaElementEvent.metadata.addEventListener(MetadataEvent.VALUE_CHANGE, _setContentLayout);
            }
        })
    }

    private function setRootElementLayout():void {
        var layout:LayoutMetadata = rootElement.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
        if (layout == null) {
            layout = new LayoutMetadata();
            rootElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
        }
        layout.percentWidth = 100;
        layout.percentHeight = 100;
    }

    private function setContentLayout(contentType:String, element:MediaElement):void {
        var layout:LayoutMetadata = element.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
        if (layout == null) {
            layout = new LayoutMetadata();
            element.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
        }
        switch (contentType) {
            case PlayerConstants.DOG_CONTENT_ID:
                layout.x = 5;
                layout.y = 5;
                layout.verticalAlign = VerticalAlign.TOP;
                layout.horizontalAlign = HorizontalAlign.LEFT;
                break;
            case PlayerConstants.MAIN_CONTENT_ID:
            case PlayerConstants.STING_CONTENT_ID:
            case PlayerConstants.AD_CONTENT_ID:
            default:
                layout.percentWidth = 100; //contentWidth;
                layout.percentHeight = 100; //contentHeight;
                layout.verticalAlign = VerticalAlign.MIDDLE;
                layout.horizontalAlign = HorizontalAlign.CENTER;
                layout.scaleMode = ScaleMode.LETTERBOX;
                break;
        }

        element.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
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

    private function get captionUrl():String {
        var metadata:Metadata = config.resource.getMetadataValue(SAMIPluginInfo.METADATA_NAMESPACE) as Metadata;
        if (metadata) {
            return metadata.getValue(SAMIPluginInfo.METADATA_KEY_URI) as String;
        }
        return null;
    }

    public function mediaPlayer():MediaPlayer {
        return player;
    }
}
}
