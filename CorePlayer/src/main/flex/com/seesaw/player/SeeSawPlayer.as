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
import com.seesaw.player.ads.AdState;
import com.seesaw.player.ads.AuditudeConstants;
import com.seesaw.player.ads.auditude.AdProxyPluginInfo;
import com.seesaw.player.ads.liverail.AdProxyPluginInfo;
import com.seesaw.player.autoresume.AutoResumeProxyPluginInfo;
import com.seesaw.player.batcheventservices.BatchEventServicePlugin;
import com.seesaw.player.captioning.sami.SAMIPluginInfo;
import com.seesaw.player.controls.ControlBarConstants;
import com.seesaw.player.controls.ControlBarPlugin;
import com.seesaw.player.external.ExternalInterfaceMetadata;
import com.seesaw.player.external.PlayerExternalInterface;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.namespaces.contentinfo;
import com.seesaw.player.namespaces.smil;
import com.seesaw.player.netstatus.NetStatusMetadata;
import com.seesaw.player.panels.BufferingPanel;
import com.seesaw.player.preventscrub.ScrubPreventionProxyPluginInfo;
import com.seesaw.player.smil.SMILConstants;
import com.seesaw.player.smil.SMILContentCapabilitiesPluginInfo;
import com.seesaw.player.smil.SMILParser;

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
import org.osmf.layout.VerticalAlign;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaPlayer;
import org.osmf.media.MediaPlayerState;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfoResource;
import org.osmf.media.URLResource;
import org.osmf.metadata.CuePoint;
import org.osmf.metadata.CuePointType;
import org.osmf.metadata.Metadata;
import org.osmf.metadata.TimelineMetadata;
import org.osmf.traits.DisplayObjectTrait;
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

    private var currentAdBreak:AdBreak;

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

        player.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMainPlayerStateChange);

        if (adMode == AdMetadata.CHANNEL_4_AD_TYPE)
        {
            logger.debug("configuring container for playlist ads");
            adPlayer = new MediaPlayer();
            adPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onAdPlayerStateChange);
        }

        logger.debug("adding media container to stage");
        addChild(container);
    }

    private function onMainPlayerStateChange(event:MediaPlayerStateChangeEvent):void {
        logger.debug("main: " + event.state);
        onMediaPlayerStateChange(event);
    }

    private function onAdPlayerStateChange(event:MediaPlayerStateChangeEvent):void {
        logger.debug("ad: " + event.state);
        onMediaPlayerStateChange(event);
    }

    private function onCuePoint(event:TimelineMetadataEvent):void {
        logger.debug("triggering cue point: {0}", event.marker.time);
        if (adPlayer && event.marker is CuePoint) {
            var cuePoint:CuePoint = event.marker as CuePoint;
            if (cuePoint.name == AdMetadata.AD_BREAK_CUE) {
                var adBreak:AdBreak = cuePoint.parameters as AdBreak;
                if (adBreak && !adBreak.complete && adBreak.adPlaylist && adBreak.adPlaylist.numChildren > 0) {
                    player.pause();
                    mainContainer.visible = false;

                    currentAdBreak = adBreak;
                    currentAdBreak.adPlaylist.addEventListener(MediaElementEvent.TRAIT_ADD, onAdElementTraitAdd);

                    adContainer.addMediaElement(currentAdBreak.adPlaylist);
                    adPlayer.media = currentAdBreak.adPlaylist;

                    // get the control bar to point at the ads
                    setControlBarTarget(currentAdBreak.adPlaylist);

                    // Set the main content to ad mode just like liverail and auditude do
                    var adMetadata:AdMetadata = mainElement.getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
                    adMetadata.adState = AdState.AD_BREAK_START;
                    adMetadata.adMode = AdMode.AD;

                    adContainer.visible = true;
                }
            }
        }
    }

    private function adBreakCompleted(event:Event = null):void {
        logger.debug("ad break complete");
        if (currentAdBreak) {
            var adPlaylist:SerialElement = currentAdBreak.adPlaylist;
            var timeTrait:TimeTrait = adPlaylist.getTrait(MediaTraitType.TIME) as TimeTrait;
            if (timeTrait) timeTrait.removeEventListener(TimeEvent.COMPLETE, adBreakCompleted);
            adPlaylist.removeEventListener(MediaElementEvent.TRAIT_ADD, onAdElementTraitAdd);
            adContainer.removeMediaElement(adPlaylist);
            currentAdBreak.complete = true;
            currentAdBreak = null;
        }

        if (!player.playing) {
            adContainer.visible = false;

            // get the control bar to point at the main content
            setControlBarTarget(mainElement);

            // Set the main content to ad mode just like liverail and auditude do
            var adMetadata:AdMetadata = mainElement.getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
            adMetadata.adState = AdState.AD_BREAK_COMPLETE;
            adMetadata.adMode = AdMode.MAIN_CONTENT;

            mainContainer.visible = true;

            player.play();
        }
    }

    private function setControlBarTarget(element:MediaElement):void {
        var metadata:Metadata = controlBarElement.getMetadata(ControlBarConstants.CONTROL_BAR_METADATA);
        if (metadata == null) {
            metadata = new Metadata();
            controlBarElement.addMetadata(ControlBarConstants.CONTROL_BAR_METADATA, metadata);
        }
        metadata.addValue(ControlBarConstants.TARGET_ELEMENT, element);
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

        if (adMode == AdMetadata.LR_AD_TYPE)
            factory.loadPlugin(new PluginInfoResource(new com.seesaw.player.ads.liverail.AdProxyPluginInfo()));
        else if (adMode == AdMetadata.AUDITUDE_AD_TYPE)
            factory.loadPlugin(new PluginInfoResource(new com.seesaw.player.ads.auditude.AdProxyPluginInfo()));

        factory.loadPlugin(new PluginInfoResource(new BatchEventServicePlugin()));
        factory.loadPlugin(new PluginInfoResource(new AutoResumeProxyPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new DebugPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new ScrubPreventionProxyPluginInfo()));



        factory.loadPlugin(new PluginInfoResource(new SMILContentCapabilitiesPluginInfo()));

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
        // The subtitle location is actually in the smil document so we have to search for it
        var subtitleLocation:String = SMILParser.getHeadMetaValue(new XML(videoInfo.smil), PlayerConstants.SUBTITLE_LOCATION);

        if (subtitleLocation) {
            logger.debug("creating captions: " + subtitleLocation);

            if (subtitleElement) {
                mainElement.removeChild(subtitleElement);
                subtitleElement = null;
            }

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
                    var metadata:Metadata = player.media.getMetadata(ControlBarConstants.CONTROL_BAR_METADATA);
                    if (metadata) {
                        var visible:Boolean = metadata.getValue(ControlBarConstants.SUBTITLES_VISIBLE) as Boolean;
                        var displayObjectTrait:DisplayObjectTrait =
                                MediaElement(event.target).getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
                        displayObjectTrait.displayObject.visible = visible == null ? false : visible;

                        metadata.addValue(ControlBarConstants.SUBTITLE_BUTTON_ENABLED, true);
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

        var metadata:Metadata = new Metadata();
        metadata.addValue(SMILConstants.SMIL_DOCUMENT, new XML(videoInfo.smil));
        config.resource.addMetadataValue(SMILConstants.SMIL_NAMESPACE, metadata);

        factory.addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onSmilElementCreated);
        var mediaElement:MediaElement = factory.createMediaElement(config.resource);
        factory.removeEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onSmilElementCreated);

        if (mediaElement) {
            mainElement.addChild(mediaElement);

            mainElement.addEventListener(MediaElementEvent.METADATA_ADD, onContentMetadataAdd);
            mainElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onContentMetadataRemove);

            var timelineMetadata:TimelineMetadata =
                    mediaElement.getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
            if (timelineMetadata) {
                timelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onCuePoint);
            }

            createBufferingPanel();
            createControlBarElement();
            configureAuditude();
            createSubtitleElement();
        }

        // get the control bar to point at the main content
        setControlBarTarget(mainElement);

        setContainerSize(contentWidth, contentHeight);
    }

    private function onSmilElementCreated(event:MediaFactoryEvent):void {
        var metadata:Metadata = event.mediaElement.resource.getMetadataValue(SMILConstants.SMIL_NAMESPACE) as Metadata;
        if (metadata) {
            var contentType:String = metadata.getValue(SMILConstants.CONTENT_TYPE) as String;
            if (contentType == PlayerConstants.DOG_CONTENT_ID) {
                // Layout the DOG image in the top left corner
                var layout:LayoutMetadata = new LayoutMetadata();
                layout.x = 5;
                layout.y = 5;
                layout.verticalAlign = VerticalAlign.TOP;
                layout.horizontalAlign = HorizontalAlign.LEFT;
                layout.index = 5;
                event.mediaElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
            }
            else if (contentType == PlayerConstants.AD_CONTENT_ID) {
                setMediaLayout(event.mediaElement);
            }
            else if (contentType == PlayerConstants.MAIN_CONTENT_ID) {
                var targetMetadata:Metadata = new Metadata();
                targetMetadata.addValue(PlayerConstants.CONTENT_ID, PlayerConstants.MAIN_CONTENT_ID);
                event.mediaElement.addMetadata(SAMIPluginInfo.NS_TARGET_ELEMENT, targetMetadata);
                setMediaLayout(event.mediaElement);
            }
        }
    }

    private function setMediaLayout(element:MediaElement):void {
        var layout:LayoutMetadata = element.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
        if (layout) {
            layout.percentWidth = 100;
            layout.percentHeight = 100;
            layout.verticalAlign = VerticalAlign.MIDDLE;
            layout.horizontalAlign = HorizontalAlign.CENTER;
        }
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

    private function onAdElementTraitAdd(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.TIME) {
            var element:MediaElement = event.target as MediaElement;
            var timeTrait:TimeTrait = element.getTrait(MediaTraitType.TIME) as TimeTrait;
            timeTrait.addEventListener(TimeEvent.COMPLETE, adBreakCompleted);
        }
    }

    private function setupAdBreaks(element:MediaElement, adBreaks:Vector.<AdBreak>):void {
        var timelineMetadata:TimelineMetadata = element.getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
        if (timelineMetadata == null) {
            timelineMetadata = new TimelineMetadata(element);
            element.addMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE, timelineMetadata);
        }

        for each (var adBreak:AdBreak in adBreaks) {
            logger.debug("creating ad break at {0} seconds", adBreak.startTime);
            timelineMetadata.addMarker(new CuePoint(CuePointType.EVENT, adBreak.startTime, "adBreakStart", adBreak));
        }

        timelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onCuePoint);
    }

    private function createControlBarElement():void {
        logger.debug("adding control bar media element to container");

        logger.debug("loading control bar plugin");
        factory.loadPlugin(new PluginInfoResource(new ControlBarPlugin().pluginInfo));

        var controlBarSettings:Metadata = new Metadata();
        controlBarSettings.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);

        var resource:MediaResourceBase = new MediaResourceBase();
        resource.addMetadataValue(ControlBarConstants.CONTROL_BAR_SETTINGS, controlBarSettings);

        logger.debug("creating control bar media element");
        controlBarElement = factory.createMediaElement(resource);

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
        if (event.namespaceURL == ControlBarConstants.CONTROL_BAR_METADATA) {
            var metadata:Metadata = mainElement.getMetadata(ControlBarConstants.CONTROL_BAR_METADATA);
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onControlBarMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onControlBarMetadataChange);
        }
    }

    private function onContentMetadataRemove(event:MediaElementEvent):void {
        if (event.namespaceURL == ControlBarConstants.CONTROL_BAR_METADATA) {
            var metadata:Metadata = mainElement.getMetadata(ControlBarConstants.CONTROL_BAR_METADATA);
            metadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onControlBarMetadataChange);
            metadata.removeEventListener(MetadataEvent.VALUE_ADD, onControlBarMetadataChange);
        }
    }

    private function onControlBarMetadataChange(event:MetadataEvent):void {
        switch (event.key) {
            case ControlBarConstants.CONTROL_BAR_HIDDEN:
                if (subtitleElement) {
                    var layoutMetadata:LayoutMetadata =
                            subtitleElement.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
                    if (layoutMetadata) {
                        layoutMetadata.bottom = event.value ? 20 : 110;
                    }
                }
                break;
            case ControlBarConstants.SUBTITLES_VISIBLE:
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
