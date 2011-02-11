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
import com.auditude.ads.AuditudePlugin;
import com.auditude.ads.osmf.IAuditudeMediaElement;
import com.auditude.ads.osmf.constants.AuditudeOSMFConstants;
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.ads.AdMode;
import com.seesaw.player.ads.AuditudeConstants;
import com.seesaw.player.ads.auditude.AdProxyPluginInfo;
import com.seesaw.player.ads.liverail.AdProxyPluginInfo;
import com.seesaw.player.autoresume.AutoResumeProxyPluginInfo;
import com.seesaw.player.batchEventService.BatchEventServicePlugin;
import com.seesaw.player.captioning.sami.SAMIPluginInfo;
import com.seesaw.player.controls.ControlBarElement;
import com.seesaw.player.controls.ControlBarMetadata;
import com.seesaw.player.controls.ControlBarPlugin;
import com.seesaw.player.external.ExternalInterfaceMetadata;
import com.seesaw.player.external.PlayerExternalInterface;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.namespaces.contentinfo;
import com.seesaw.player.namespaces.smil;
import com.seesaw.player.netstatus.NetStatusMetadata;
import com.seesaw.player.panels.BufferingPanel;
import com.seesaw.player.preventscrub.ScrubPreventionProxyPluginInfo;
import com.seesaw.player.smil.AdCapabilitiesProxy;
import com.seesaw.player.smil.SMILContentCapabilitiesPluginInfo;
import com.seesaw.player.smil.SMILParser;
import com.seesaw.player.smil.SMILParserEvent;

import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.events.NetStatusEvent;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.containers.MediaContainer;
import org.osmf.elements.ParallelElement;
import org.osmf.elements.SerialElement;
import org.osmf.events.BufferEvent;
import org.osmf.events.DynamicStreamEvent;
import org.osmf.events.LoadEvent;
import org.osmf.events.LoaderEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.events.MediaPlayerStateChangeEvent;
import org.osmf.events.MetadataEvent;
import org.osmf.events.TimeEvent;
import org.osmf.events.TimelineMetadataEvent;
import org.osmf.layout.HorizontalAlign;
import org.osmf.layout.LayoutMetadata;
import org.osmf.layout.ScaleMode;
import org.osmf.layout.VerticalAlign;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaPlayer;
import org.osmf.media.MediaPlayerState;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.MediaType;
import org.osmf.media.PluginInfoResource;
import org.osmf.media.URLResource;
import org.osmf.metadata.CuePoint;
import org.osmf.metadata.CuePointType;
import org.osmf.metadata.Metadata;
import org.osmf.metadata.TimelineMetadata;
import org.osmf.smil.SMILConstants;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.DynamicStreamTrait;
import org.osmf.traits.LoadState;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.TimeTrait;

import uk.co.vodco.osmfDebugProxy.DebugPluginInfo;

public class SeeSawPlayer extends Sprite {

    use namespace contentinfo;
    use namespace smil;

    private static const AUDITUDE_PLUGIN_URL:String = "http://asset.cdn.auditude.com/flash/sandbox/plugin/osmf/AuditudeOSMFProxyPlugin.swf";

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawPlayer);

    private var config:PlayerConfiguration;

    private var factory:MediaFactory;
    private var player:MediaPlayer;
    private var adPlayer:MediaPlayer;
    private var adContainer:MediaContainer;
    private var container:MediaContainer;
    private var mainContainer:MediaContainer;
    private var bufferingContainer:MediaContainer;
    private var controlbarContainer:MediaContainer;
    private var subtitlesContainer:MediaContainer;
    private var serialPlaylist:SerialElement;
    private var mainElement:ParallelElement;
    private var subtitleElement:MediaElement;
    private var bufferingPanel:BufferingPanel;
    private var controlBarElement:MediaElement;

    private var xi:PlayerExternalInterface;

    // This is so we wait on Auditude loading before setting up the rest of the plugins and player
    private var pluginsToLoad:int = 1;

    private var playerInit:XML;
    private var videoInfo:XML;
    private var adMode:String;

    private var parser:SMILParser;

    public function SeeSawPlayer(playerConfig:PlayerConfiguration) {
        logger.debug("creating player");

        xi = ObjectProvider.getInstance().getObject(PlayerExternalInterface);

        config = playerConfig;

        var metadata:Metadata = config.resource.getMetadataValue(PlayerConstants.METADATA_NAMESPACE) as Metadata;

        metadata.addEventListener(MetadataEvent.VALUE_ADD, playerMetaChange);
        metadata.addEventListener(MetadataEvent.VALUE_CHANGE, playerMetaChange);

        playerInit = metadata.getValue(PlayerConstants.CONTENT_INFO) as XML;
        adMode = String(metadata.getValue(PlayerConstants.CONTENT_INFO).adMode);
        videoInfo = metadata.getValue(PlayerConstants.VIDEO_INFO) as XML;

        factory = config.factory;
        factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
        factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadFailed);
        factory.addEventListener(NetStatusEvent.NET_STATUS, netStatusChanged);

        player = new MediaPlayer();
        player.autoPlay = false;

        mainElement = new ParallelElement();
        container = new MediaContainer();

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function playerMetaChange(event:MetadataEvent):void {
        if (event.key == PlayerConstants.DESTROY) {
            if (event.value) {
                // wipe out the objects from memory and off the displayList
                // removeChild seems to throw errors when trying to removeChild( container ) etc..
                mainContainer.removeMediaElement(mainElement);
                mainContainer = null;
                bufferingContainer = null;
                subtitlesContainer = null;
                controlbarContainer = null;
                mainElement = null;
                player = null;
                container = null;

                dispatchEvent(new Event(PlayerConstants.DESTROY));
            }
        }
    }

    private function onAddedToStage(event:Event):void {
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

        adContainer = new MediaContainer();
        adContainer.y = 0;
        adContainer.x = 0;
        adContainer.layoutMetadata.percentWidth = 100;
        adContainer.layoutMetadata.percentHeight = 100;
        addChild(adContainer);

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
        controlbarContainer.layoutMetadata.percentHeight = 100;
        controlbarContainer.layoutMetadata.verticalAlign = VerticalAlign.BOTTOM;
        addChild(controlbarContainer);

        container.layoutRenderer.addTarget(mainContainer);
        container.layoutRenderer.addTarget(adContainer);
        container.layoutRenderer.addTarget(bufferingContainer);
        container.layoutRenderer.addTarget(subtitlesContainer);
        container.layoutRenderer.addTarget(controlbarContainer);

        if (adMode == AdMetadata.AUDITUDE_AD_TYPE) {
            loadAuditude();
        } else {
            loadPlugins();
        }

        mainContainer.addMediaElement(mainElement);

        //handler to show and hide the buffering panel
        player.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
        player.media = mainElement;

        player.addEventListener(
                MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE,
                               function(event:MediaPlayerStateChangeEvent):void {
                                   logger.debug("main: " + event.state);
                                   onMediaPlayerStateChange(event);
                               });

        if (serialPlaylist && serialPlaylist.numChildren > 0) {
            logger.debug("configuring container for playlist ads");

            adContainer.addMediaElement(serialPlaylist);

            adPlayer = new MediaPlayer();
            adPlayer.autoPlay = false;
            adPlayer.media = serialPlaylist;

            adPlayer.addEventListener(
                    MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE,
                                     function(event:MediaPlayerStateChangeEvent):void {
                                         logger.debug("ad: " + event.state);
                                         onMediaPlayerStateChange(event);
                                     });
        }

        logger.debug("adding media container to stage");
        addChild(container);
    }

    private function loadAuditude():void {
        factory.loadPlugin(new URLResource(AUDITUDE_PLUGIN_URL));
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

        factory.loadPlugin(new PluginInfoResource(new AutoResumeProxyPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new DebugPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new ScrubPreventionProxyPluginInfo()));
        if (adMode == AdMetadata.LR_AD_TYPE)
            factory.loadPlugin(new PluginInfoResource(new com.seesaw.player.ads.liverail.AdProxyPluginInfo()));
        else if (adMode == AdMetadata.AUDITUDE_AD_TYPE)
            factory.loadPlugin(new PluginInfoResource(new com.seesaw.player.ads.auditude.AdProxyPluginInfo()));
//        else if (adMode == AdMetadata.CHANNEL_4_AD_TYPE)
        serialPlaylist = new SerialElement();

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

    private function createSubtitleElement(target:MediaElement):void {
        // The subtitle location is actually in the smil document so we have to search for it
        var subtitleLocation:String = parser.getHeadMetaValue(PlayerConstants.SUBTITLE_LOCATION);

        if (subtitleLocation) {
            logger.debug("creating captions: " + subtitleLocation);

            if (subtitleElement) {
                mainElement.removeChild(subtitleElement);
                subtitleElement = null;
            }

            var targetMetadata:Metadata = new Metadata();
            targetMetadata.addValue(PlayerConstants.CONTENT_ID, PlayerConstants.MAIN_CONTENT_ID);
            target.addMetadata(SAMIPluginInfo.NS_TARGET_ELEMENT, targetMetadata);

            logger.debug("loading subtitle plugin");
            factory.loadPlugin(new PluginInfoResource(new SAMIPluginInfo()));

            subtitleElement = factory.createMediaElement(new URLResource(subtitleLocation));

            var layout:LayoutMetadata = new LayoutMetadata();
            subtitleElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);

            layout.percentWidth = 100;
            layout.height = 50;
            layout.bottom = 100;
            layout.horizontalAlign = HorizontalAlign.CENTER;
            layout.verticalAlign = VerticalAlign.BOTTOM;
            layout.index = 10;

            // The subtitle element needs to check and set visibility every time it sets a new display object
            subtitleElement.addEventListener(MediaElementEvent.TRAIT_ADD, function(event:MediaElementEvent):void {
                if (event.traitType == MediaTraitType.DISPLAY_OBJECT) {
                    var metadata:Metadata = player.media.getMetadata(ControlBarMetadata.CONTROL_BAR_METADATA);
                    if (metadata) {
                        var visible:Boolean = metadata.getValue(ControlBarMetadata.SUBTITLES_VISIBLE) as Boolean;
                        var displayObjectTrait:DisplayObjectTrait =
                                MediaElement(event.target).getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
                        displayObjectTrait.displayObject.visible = visible == null ? false : visible;
                    }
                }
            });

            var loadTrait:LoadTrait = subtitleElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
            loadTrait.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, function(event:LoadEvent):void {
                if (event.loadState == LoadState.LOAD_ERROR) {
                    // if the subtitles fail to load remove the element to allow the rest of the media to load correctly
                    mainElement.removeChild(subtitleElement);
                    subtitleElement = null;
                }
            });
            mainElement.addChild(subtitleElement);
        }
    }

    private function createVideoElement():void {
        logger.debug("creating video element");

        mainElement.addEventListener(MediaElementEvent.METADATA_ADD, onContentMetadataAdd);
        mainElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onContentMetadataRemove);

        parser = new SMILParser(new XML(videoInfo.smil), factory);

        parser.addEventListener(SMILParserEvent.MEDIA_ELEMENT_CREATED, onSmilElementCreated);
        parser.parse();

        if (serialPlaylist) {
            setupAdBreaks(mainElement, parser.adBreaks);
        }

        setContainerSize(contentWidth, contentHeight);
    }

    private function onSmilElementCreated(event:SMILParserEvent):void {
        var mediaElement:MediaElement = event.mediaElement;

        var layout:LayoutMetadata = new LayoutMetadata();
        if (event.mediaType == MediaType.VIDEO && event.contentType == PlayerConstants.AD_CONTENT_ID) {
            if (serialPlaylist) {
                logger.debug("created ad element and adding to serial playlist");
                mediaElement.addEventListener(MediaElementEvent.TRAIT_ADD, onAdElementTraitAdd);
                serialPlaylist.addChild(new AdCapabilitiesProxy(mediaElement));
            }
        }
        else if (event.mediaType == MediaType.VIDEO && event.contentType == PlayerConstants.MAIN_CONTENT_ID) {
            logger.debug("created main video element");
            parser.addIgnoredContentType(PlayerConstants.MAIN_CONTENT_ID); // notify only once

            createBufferingPanel();
            createControlBarElement();
            createSubtitleElement(mediaElement);
            configureAuditude();

            mainElement.addChild(mediaElement);
        }
        else if (event.mediaType == MediaType.IMAGE && event.contentType == PlayerConstants.DOG_CONTENT_ID) {
            logger.debug("created dog image element");
            parser.addIgnoredContentType(PlayerConstants.DOG_CONTENT_ID); // notify only once

            // Layout the DOG image in the top left corner
            layout.x = 5;
            layout.y = 5;
            layout.verticalAlign = VerticalAlign.TOP;
            layout.horizontalAlign = HorizontalAlign.LEFT;
            layout.index = 5;

            mainElement.addChild(mediaElement);
        }

        mediaElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
    }

    private function configureAuditude():void {
        if (mainElement is IAuditudeMediaElement) {
            logger.debug("configuring Auditude");
            var _auditude:AuditudePlugin = IAuditudeMediaElement(mainElement).plugin;

            // We set this in the metadata so the auditude AdProxy can pick up the plugin
            var metadata:Metadata = config.resource.getMetadataValue(AuditudeOSMFConstants.AUDITUDE_METADATA_NAMESPACE) as Metadata;
            metadata.addValue(AuditudeConstants.PLUGIN_INSTANCE, _auditude);
        }
    }

    private function setupAdBreaks(element:MediaElement, adBreaks:Vector.<AdBreak>):void {
        var timelineMetadata:TimelineMetadata = element.getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
        if (timelineMetadata == null) {
            timelineMetadata = new TimelineMetadata(element);
            element.addMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE, timelineMetadata);
        }

        for each (var adBreak:AdBreak in adBreaks) {
            logger.debug("creating ad break at {0}", adBreak.startTime);
            timelineMetadata.addMarker(new CuePoint(CuePointType.EVENT, adBreak.startTime, "adBreakStart", adBreak));
        }

        timelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onCuePoint);
    }

    private function onAdElementTraitAdd(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.TIME) {
            var element:MediaElement = event.target as MediaElement;
            var timeTrait:TimeTrait = element.getTrait(MediaTraitType.TIME) as TimeTrait;
            timeTrait.addEventListener(TimeEvent.COMPLETE, function(event:TimeEvent):void {
                adBreakCompleted();
            });
        }
    }

    private function onCuePoint(event:TimelineMetadataEvent):void {
        logger.debug("triggering cue point: {0}", event.marker.time);
        if (player.canPause) {
            player.pause();
        }
        if (adPlayer.canPlay) {
            adPlayer.play();
        }
        mainContainer.visible = false;
        adContainer.visible = true;

        // get the control bar to point at the ads
        ControlBarElement(controlBarElement).target = serialPlaylist;
    }

    private function adBreakCompleted():void {
        logger.debug("ad break complete");
        if (adPlayer.canPause) {
            adPlayer.pause();
        }
        if (player.canPlay) {
            player.play();
        }
        mainContainer.visible = true;
        adContainer.visible = false;

        // get the control bar to point at the main content
        ControlBarElement(controlBarElement).target = mainElement;
    }

    private function createControlBarElement():void {
        logger.debug("adding control bar media element to container");

        logger.debug("loading control bar plugin");
        factory.loadPlugin(new PluginInfoResource(new ControlBarPlugin().pluginInfo));

        var controlBarSettings:Metadata = new Metadata();
        controlBarSettings.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);

        var resource:MediaResourceBase = new MediaResourceBase();
        resource.addMetadataValue(ControlBarPlugin.NS_SETTINGS, controlBarSettings);

        logger.debug("creating control bar media element");
        controlBarElement = factory.createMediaElement(resource);

        // get the control bar to point at the main content
        ControlBarElement(controlBarElement).target = mainElement;

        controlbarContainer.addMediaElement(controlBarElement);
    }

    private function netStatusChanged(event:NetStatusEvent):void {
        if (event.info == "NetConnection.Connect.NetworkChange") {

            factory.removeEventListener(NetStatusEvent.NET_STATUS, netStatusChanged);

            var metadata:Metadata = mainElement.getMetadata(NetStatusMetadata.NET_STATUS_METADATA);
            if (metadata == null) {
                metadata = new Metadata();
                mainElement.addMetadata(NetStatusMetadata.NET_STATUS_METADATA, metadata);
            }

            metadata.addValue(NetStatusMetadata.STATUS, event.info);
        }
    }

    private function onFullscreen(event:FullScreenEvent):void {
        logger.debug("onFullscreen: " + event.fullScreen);
        setContainerSize(contentWidth, contentHeight);
    }

    private function setContainerSize(width:int, height:int):void {
        container.width = width;
        container.height = height;
    }

    private function onContentMetadataAdd(event:MediaElementEvent):void {
        if (event.namespaceURL == ControlBarMetadata.CONTROL_BAR_METADATA) {
            var metadata:Metadata = mainElement.getMetadata(ControlBarMetadata.CONTROL_BAR_METADATA);
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onControlBarMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onControlBarMetadataChange);
        }
    }

    private function onContentMetadataRemove(event:MediaElementEvent):void {
        if (event.namespaceURL == ControlBarMetadata.CONTROL_BAR_METADATA) {
            var metadata:Metadata = mainElement.getMetadata(ControlBarMetadata.CONTROL_BAR_METADATA);
            metadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onControlBarMetadataChange);
            metadata.removeEventListener(MetadataEvent.VALUE_ADD, onControlBarMetadataChange);
        }
    }

    private function onControlBarMetadataChange(event:MetadataEvent):void {
        switch (event.key) {
            case ControlBarMetadata.CONTROL_BAR_HIDDEN:
                if (subtitleElement) {
                    var layoutMetadata:LayoutMetadata =
                            subtitleElement.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
                    if (layoutMetadata) {
                        layoutMetadata.bottom = event.value ? 20 : 110;
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

    private function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void {
        switch (event.state) {
            case MediaPlayerState.PLAYING:
                toggleLights();
                break;
            case MediaPlayerState.PAUSED:
                toggleLights();
                break;
        }
    }

    private function toggleLights():void {
        var lightsDown:Boolean = false;

        var metadata:Metadata = player.media.getMetadata(ExternalInterfaceMetadata.EXTERNAL_INTERFACE_METADATA);

        if (metadata == null) {
            metadata = new Metadata();
            player.media.addMetadata(ExternalInterfaceMetadata.EXTERNAL_INTERFACE_METADATA, metadata);
        }

        lightsDown = metadata.getValue(ExternalInterfaceMetadata.LIGHTS_DOWN);

        var playTrait:PlayTrait = player.media.getTrait(MediaTraitType.PLAY) as PlayTrait;
        var timeTrait:TimeTrait = player.media.getTrait(MediaTraitType.TIME) as TimeTrait;

        if (playTrait.playState == PlayState.PLAYING && !lightsDown) {
            if (xi.available) {
                logger.debug("calling lights down");
                xi.callLightsDown();
                metadata.addValue(ExternalInterfaceMetadata.LIGHTS_DOWN, true);
            }
        }
        else if (playTrait.playState == PlayState.PAUSED && timeTrait && (timeTrait.currentTime != timeTrait.duration)) {
            if (xi.available) {
                logger.debug("calling lights up");
                xi.callLightsUp();
                metadata.addValue(ExternalInterfaceMetadata.LIGHTS_DOWN, false);
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

    public function get mediaPlayer():MediaPlayer {
        return player;
    }
}
}
