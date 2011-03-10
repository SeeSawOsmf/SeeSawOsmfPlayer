/*
 * The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *   The Initial Developer of the Original Code is Arqiva Ltd.
 *   Portions created by Arqiva Limited are Copyright (C) 2010, 2011 Arqiva Limited.
 *   Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe
 * 	Systems Incorporated.
 *   All Rights Reserved.
 *
 *   Contributor(s):  Adobe Systems Incorporated
 */

package com.seesaw.player {
import com.auditude.ads.AuditudePlugin;
import com.auditude.ads.osmf.IAuditudeMediaElement;
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.ads.AdMode;
import com.seesaw.player.ads.AdState;
import com.seesaw.player.ads.AuditudeConstants;
import com.seesaw.player.ads.auditude.AdProxy;
import com.seesaw.player.ads.liverail.AdProxyPluginInfo;
import com.seesaw.player.autoresume.AutoResumeProxyPluginInfo;
import com.seesaw.player.batcheventservices.BatchEventServicePlugin;
import com.seesaw.player.buffering.BufferManager;
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
import com.seesaw.player.services.ResumeService;
import com.seesaw.player.smil.SMILConstants;
import com.seesaw.player.smil.SMILContentCapabilitiesPluginInfo;
import com.seesaw.player.smil.SMILParser;
import com.seesaw.player.utils.HelperUtils;
import com.seesaw.player.utils.LoggerUtils;

import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.events.NetStatusEvent;
import flash.utils.ByteArray;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.containers.MediaContainer;
import org.osmf.elements.ParallelElement;
import org.osmf.elements.SerialElement;
import org.osmf.events.BufferEvent;
import org.osmf.events.DRMEvent;
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.events.MediaPlayerStateChangeEvent;
import org.osmf.events.MetadataEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
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
import org.osmf.metadata.Metadata;
import org.osmf.metadata.TimelineMetadata;
import org.osmf.traits.DRMState;
import org.osmf.traits.DRMTrait;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.LoadState;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitBase;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.TimeTrait;
import org.osmf.traits.TraitEventDispatcher;

import uk.co.vodco.osmfDebugProxy.DebugPluginInfo;

public class SeeSawPlayer extends Sprite {

    use namespace contentinfo;
    use namespace smil;

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
    private var userInfo:XML;
    private var adMode:String;

    private var currentAdBreak:AdBreak;
    private var controlBarMetadata:Metadata;

    private var resumeService:ResumeService;

    public function SeeSawPlayer(playerConfig:PlayerConfiguration) {
        logger.debug("creating player");

        var provider:ObjectProvider = ObjectProvider.getInstance();
        xi = provider.getObject(PlayerExternalInterface);
        resumeService = provider.getObject(ResumeService);

        config = playerConfig;

        var metadata:Metadata = config.resource.getMetadataValue(PlayerConstants.METADATA_NAMESPACE) as Metadata;

        playerInit = metadata.getValue(PlayerConstants.CONTENT_INFO) as XML;
        videoInfo = metadata.getValue(PlayerConstants.VIDEO_INFO) as XML;
        userInfo = metadata.getValue(PlayerConstants.USER_INFO) as XML;

        adMode = String(playerInit.adMode);

        factory = config.factory;
        factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
        factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadFailed);
        factory.addEventListener(NetStatusEvent.NET_STATUS, netStatusChanged);

        player = new MediaPlayer();
        player.autoPlay = false;

        adPlayer = new MediaPlayer();
        adPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onAdPlayerStateChange);
        adPlayer.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);

        mainElement = new ParallelElement();
        container = new MediaContainer();

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onComplete(event:TimeEvent):void {
        logger.debug("onComplete: requesting player re-initialisation");
        removeChild(container);
        dispatchEvent(new Event(PlayerConstants.REINITIALISE_PLAYER));
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

        if (adsEnabled && adMode == AdMetadata.AUDITUDE_AD_TYPE) {
            loadAuditude();
        } else {
            loadPlugins();
        }

        mainContainer.addMediaElement(mainElement);

        //handler to show and hide the buffering panel
        player.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);

        player.media = mainElement;

        player.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMainPlayerStateChange);

        setContainerSize(contentWidth, contentHeight);

        logger.debug("adding media container to stage");
        addChild(container);
    }

    private function onMainPlayerStateChange(event:MediaPlayerStateChangeEvent):void {
        logger.debug("main::::::::::: " + event.state);
        onMediaPlayerStateChange(event);
    }

    private function onAdPlayerStateChange(event:MediaPlayerStateChangeEvent):void {
        logger.debug("ad::::::::::::::::::: " + event.state);
        onMediaPlayerStateChange(event);
    }

    private function onCuePoint(event:TimelineMetadataEvent):void {
        logger.debug("triggering cue point: {0}", event.marker.time);
        if (event.marker is CuePoint) {
            var cuePoint:CuePoint = event.marker as CuePoint;
            if (cuePoint.name == AdMetadata.AD_BREAK_CUE) {
                var adBreak:AdBreak = cuePoint.parameters as AdBreak;
                if (adPlayer && adBreak && adBreak.canPlayAdPlaylist) {
                    player.pause();
                    mainContainer.visible = false;

                    currentAdBreak = adBreak;
                    currentAdBreak.adPlaylist.addEventListener(MediaElementEvent.TRAIT_ADD, onAdElementTraitAdd);

                    adContainer.addMediaElement(currentAdBreak.adPlaylist);
                    adPlayer.media = currentAdBreak.adPlaylist;

                    if (!controlBarMetadata) {
                        controlBarMetadata = new Metadata();
                        controlBarMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, onControlBarMetadataChange);
                        controlBarMetadata.addEventListener(MetadataEvent.VALUE_ADD, onControlBarMetadataChange);
                    }
                    currentAdBreak.adPlaylist.addMetadata(ControlBarConstants.CONTROL_BAR_METADATA, controlBarMetadata);

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


    private function adPlayStateChange(event:PlayEvent):void {
        if (!currentAdBreak.complete) {
            if (event.playState == PlayState.STOPPED) {
                var adMetadata:AdMetadata = mainElement.getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
                var dataObject:Object = new Object();
                dataObject["state"] = AdState.STOPPED;
                adMetadata.adState = dataObject;
            }
        }
    }

    private function adDurationChange(event:TimeEvent):void {
        if (!currentAdBreak.complete) {
            if (event.type == TimeEvent.DURATION_CHANGE) {
                var adMetadata:AdMetadata = mainElement.getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
                var dataObject:Object = new Object();
                dataObject["state"] = AdState.STARTED;
                dataObject["contentUrl"] = URLResource(adPlayer.media.resource).url;
                adMetadata.adState = dataObject;
            }
        }
    }

    private function adBreakCompleted(event:Event = null):void {
        logger.debug("ad break complete");
        if (currentAdBreak) {
            var adPlaylist:SerialElement = currentAdBreak.adPlaylist;
            var timeTrait:TimeTrait = adPlaylist.getTrait(MediaTraitType.TIME) as TimeTrait;
            var playable:PlayTrait = adPlaylist.getTrait(MediaTraitType.PLAY) as PlayTrait;
            if (timeTrait) {
                timeTrait.removeEventListener(TimeEvent.COMPLETE, adBreakCompleted);
                timeTrait.addEventListener(TimeEvent.DURATION_CHANGE, adDurationChange);
            }
            if (playable) {
                playable.addEventListener(PlayEvent.PLAY_STATE_CHANGE, adPlayStateChange);
            }
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


            mainContainer.visible = true;

            player.play();

            adMetadata.adMode = AdMode.MAIN_CONTENT;        /// notify the bachEvents tht we have transitioned to main content..
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
        factory.loadPlugin(new URLResource(AuditudeConstants.AUDITUDE_PLUGIN_URL));
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

        setupAdProvider();

        factory.loadPlugin(new PluginInfoResource(new BatchEventServicePlugin()));
        factory.loadPlugin(new PluginInfoResource(new AutoResumeProxyPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new DebugPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new ScrubPreventionProxyPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new SMILContentCapabilitiesPluginInfo()));

        createVideoElement();
    }

    private function setupAdProvider():void {
        if (!adsEnabled) {
            // just play and don't bother to load the ad plugins
            player.autoPlay = true;
            return;
        }

        if (adMode == AdMetadata.LR_AD_TYPE) {
            logger.debug("configuring liverail ads");
            factory.loadPlugin(new PluginInfoResource(new AdProxyPluginInfo()));
        } else if (adMode == AdMetadata.CHANNEL_4_AD_TYPE) {
            logger.debug("configuring playlist ads");
        }
    }

    private function onPluginLoadFailed(event:MediaFactoryEvent):void {
        logger.debug("PROBLEM LOADING " + event.toString());
    }

    private function createBufferingPanel():void {
        //Create the Buffering Panel
        bufferingPanel = new BufferingPanel(bufferingContainer);
        bufferingPanel.addEventListener(PlayerConstants.BUFFER_MESSAGE_HIDE, updateBufferMetaData)
        bufferingPanel.addEventListener(PlayerConstants.BUFFER_MESSAGE_SHOW, updateBufferMetaData);
        bufferingContainer.addMediaElement(bufferingPanel);
    }

    private function updateBufferMetaData(event:Event):void {
        var metadata:Metadata = userEventMetaData as Metadata;
        if (metadata) {
            if (event.type == PlayerConstants.BUFFER_MESSAGE_SHOW) {
                metadata.addValue(PlayerConstants.BUFFER_MESSAGE_SHOW, true);
            } else if (event.type == PlayerConstants.BUFFER_MESSAGE_HIDE) {
                metadata.addValue(PlayerConstants.BUFFER_MESSAGE_SHOW, false);
            }
        }
    }

    private function onBufferingChange(event:BufferEvent):void {
        if (event.currentTarget.bufferLength < 0.1) {
            (event.buffering) ? bufferingPanel.show() : bufferingPanel.hide();
        } else {
            bufferingPanel.hide();
        }
    }

    private function get userEventMetaData():Metadata {
        var playerMetadata:Metadata = config.resource.getMetadataValue(PlayerConstants.METADATA_NAMESPACE) as Metadata;
        var metadata:Metadata = playerMetadata.getValue(PlayerConstants.USEREVENTS_METADATA_NAMESPACE);
        if (!metadata) {
            metadata = new Metadata();
            playerMetadata.addValue(PlayerConstants.USEREVENTS_METADATA_NAMESPACE, metadata);
        }
        return metadata;
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
            layout.bottom = 20;

            // The subtitle element needs to check and set visibility every time it sets a new display object
            subtitleElement.addEventListener(MediaElementEvent.TRAIT_ADD, onSubtitleTraitAdd);

            var loadTrait:LoadTrait = subtitleElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
            loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onSubtitleLoadStateChange);

            mainElement.addChild(subtitleElement);
        }else{
           setSubtitlesButtonEnabled(false);
        }
    }

    private function onSubtitleLoadStateChange(event:LoadEvent):void {
        if (event.loadState == LoadState.LOAD_ERROR) {
            logger.error("failed to load subtitles");
            // if the subtitles fail to load remove the element to allow the rest of the media to load correctly
            mainElement.removeChild(subtitleElement);
            subtitleElement = null;
            setSubtitlesButtonEnabled(false);
        }
        else if (event.loadState == LoadState.READY) {
            setSubtitlesButtonEnabled(true);
        }
    }

    private function onSubtitleTraitAdd(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.DISPLAY_OBJECT) {
            if (controlBarMetadata) {
                var visible:Boolean = controlBarMetadata.getValue(ControlBarConstants.SUBTITLES_VISIBLE) as Boolean;

                var displayObjectTrait:DisplayObjectTrait =
                        MediaElement(event.target).getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
                displayObjectTrait.displayObject.visible = visible == null ? false : visible;
            }
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
            mainElement.addChild(new BufferManager(PlayerConstants.MIN_BUFFER_SIZE_SECONDS,
                    PlayerConstants.MAX_BUFFER_SIZE_SECONDS, mediaElement));

            mediaElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);

            var timelineMetadata:TimelineMetadata =
                    mediaElement.getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
            if (timelineMetadata) {
                timelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onCuePoint);
            }

            var subtitleMetadata:Metadata = new Metadata();
            subtitleMetadata.addValue(PlayerConstants.CONTENT_ID, PlayerConstants.MAIN_CONTENT_ID);
            mediaElement.addMetadata(SAMIPluginInfo.NS_TARGET_ELEMENT, subtitleMetadata);

            controlBarMetadata = new Metadata();
            controlBarMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, onControlBarMetadataChange);
            controlBarMetadata.addEventListener(MetadataEvent.VALUE_ADD, onControlBarMetadataChange);
            mainElement.addMetadata(ControlBarConstants.CONTROL_BAR_METADATA, controlBarMetadata);

            createBufferingPanel();
            createControlBarElement();

            if (adMode == AdMetadata.AUDITUDE_AD_TYPE) {
                mediaElement = createAuditudeElement(mediaElement);
            }

            createSubtitleElement();

            if (logger.debugEnabled)
                LoggerUtils.logWhenLoaded(logger, mediaElement);

            var dispatcher:TraitEventDispatcher = new TraitEventDispatcher();
            dispatcher.media = mediaElement;
            dispatcher.addEventListener(TimeEvent.COMPLETE, onComplete);
            dispatcher.addEventListener(SeekEvent.SEEKING_CHANGE, mainElementSeekChange);
        }

        // get the control bar to point at the main content
        setControlBarTarget(mainElement);
    }

    private function mainElementSeekChange(event:SeekEvent):void {
        if (event.seeking) {
            player.removeEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
        } else if (!event.seeking) {
            player.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
        }
    }

    private function onSmilElementCreated(event:MediaFactoryEvent):void {
        var metadata:Metadata;
        if (event.mediaElement.resource) {
            metadata = event.mediaElement.resource.getMetadataValue(SMILConstants.SMIL_NAMESPACE) as Metadata;
        } else if (event.mediaElement) {
            metadata = event.mediaElement.getMetadata(SMILConstants.SMIL_NAMESPACE) as Metadata;
        }

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
                setMediaLayout(event.mediaElement);
            }
        }
    }

    /**
     * Used to find out when the DRM trait is added to the media element
     * @param event
     */
    private function onTraitAdd(event:MediaElementEvent) {

        logger.debug("On Trait add");

        if (event.traitType == MediaTraitType.DRM) {
            event.target.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);

            logger.debug("Adding DRM trait listener");

            // Add a listener to the DRM trait so we know what is going on
            var drmTrait:MediaTraitBase = (event.target as MediaElement).getTrait(MediaTraitType.DRM);
            drmTrait.addEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMStateChange);
        }
    }

    private function onDRMStateChange(event:DRMEvent) {
        switch (event.drmState) {

            case DRMState.AUTHENTICATION_NEEDED:
                logger.debug("DRM Authentication needed");
                var entitlement:String = videoInfo.entitlement;
                var signature:String = videoInfo.signature;
                var authToken:String = signature + "," + entitlement;

                var byteArray:ByteArray = new ByteArray();
                byteArray.writeUTFBytes(authToken);

                logger.debug("DRM Sending token to license server");
                (event.target as DRMTrait).authenticateWithToken(byteArray);
                break;

            case DRMState.AUTHENTICATION_ERROR:
                logger.debug("DRM Authentication error: " + event.mediaError.message);
                logger.debug("DRM Authentication error: " + event.mediaError.getStackTrace());
                break;

            default:
                logger.debug("DRM Some other DRM state: " + event.drmState);
                break;
        }
    }

    private function setMediaLayout(element:MediaElement):void {
        var layout:LayoutMetadata = element.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
        if (layout == null) {
            layout = new LayoutMetadata();
            element.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
        }
        layout.percentWidth = 100;
        layout.percentHeight = 100;
        layout.verticalAlign = VerticalAlign.MIDDLE;
        layout.horizontalAlign = HorizontalAlign.CENTER;
    }

    private function createAuditudeElement(mediaElement:MediaElement):MediaElement {
        if (mediaElement is IAuditudeMediaElement) {
            logger.debug("configuring Auditude proxy");
            var auditude:AuditudePlugin = IAuditudeMediaElement(mediaElement).plugin;
            mediaElement = new AdProxy(mediaElement);

            var metadata:Metadata = new Metadata();
            mediaElement.addMetadata(AuditudeConstants.SETTINGS_NAMESPACE, metadata);

            metadata.addValue(AuditudeConstants.PLUGIN_INSTANCE, auditude);
        }
        return mediaElement;
    }

    private function onAdElementTraitAdd(event:MediaElementEvent):void {
        var element:MediaElement = event.target as MediaElement;
        if (event.traitType == MediaTraitType.TIME) {
            var timeTrait:TimeTrait = element.getTrait(MediaTraitType.TIME) as TimeTrait;
            timeTrait.addEventListener(TimeEvent.COMPLETE, adBreakCompleted);
            timeTrait.addEventListener(TimeEvent.DURATION_CHANGE, adDurationChange);
        } else if (event.traitType == MediaTraitType.PLAY) {
            var playable:PlayTrait = element.getTrait(MediaTraitType.PLAY) as PlayTrait;
            if (playable)  playable.addEventListener(PlayEvent.PLAY_STATE_CHANGE, adPlayStateChange);
        }
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

        var metadata:Metadata = mainElement.getMetadata(NetStatusMetadata.NET_STATUS_METADATA);
        if (metadata == null) {
            metadata = new Metadata();
            mainElement.addMetadata(NetStatusMetadata.NET_STATUS_METADATA, metadata);
        }

        metadata.addValue(NetStatusMetadata.STATUS, event.info);

    }

    private function onFullscreen(event:FullScreenEvent):void {
        logger.debug("onFullscreen: " + event.fullScreen);
        setContainerSize(contentWidth, contentHeight);
        container.validateNow();
    }

    private function setContainerSize(width:int, height:int):void {
        container.width = width;
        container.height = height;
    }

    private function onControlBarMetadataChange(event:MetadataEvent):void {
        switch (event.key) {
            case ControlBarConstants.CONTROL_BAR_HIDDEN:
                updateSubtitlePosition();
                break;
            case ControlBarConstants.SUBTITLES_VISIBLE:
                if (subtitleElement) {
                    updateSubtitlePosition();

                    var displayTrait:DisplayObjectTrait =
                            subtitleElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
                    if (displayTrait) {
                        displayTrait.displayObject.visible = event.value;
                    }
                }
                break;
        }
        generateUserEventMetadata(event);
    }

    private function generateUserEventMetadata(event:MetadataEvent):void {
        var metadata:Metadata = userEventMetaData as Metadata;
        if (metadata) {
            metadata.addValue(event.key, event.value);
        }
    }

    private function updateSubtitlePosition():void {
        if (subtitleElement) {
            var layoutMetadata:LayoutMetadata =
                    subtitleElement.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;

            var controlBarHeight:int = 0;
            var controlBarVisible:Boolean = false;

            if (controlBarElement) {
                var displayTrait:DisplayObjectTrait =
                        controlBarElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
                if (displayTrait) {
                    controlBarVisible = displayTrait.displayObject.visible;
                    controlBarHeight = displayTrait.mediaHeight + 10;
                }
            }

            if (layoutMetadata) {
                layoutMetadata.bottom = controlBarVisible ? controlBarHeight : 20;
            }
        }
    }

    private function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void {
        switch (event.state) {
            case MediaPlayerState.PLAYING:
                bufferingPanel.hide();       // hide the buffering Panel if content is playing...
                // This was the simplest fix I could find for FEEDBACK-2311.
                container.validateNow();
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

    public function get adsEnabled():Boolean {
        // This has been expanded to make it easy to debug as e4x can't be expanded in the debugger
        var tvVodPlayable:Boolean = HelperUtils.getBoolean(userInfo.availability.tvodPlayable);
        var svodPlayable:Boolean = HelperUtils.getBoolean(userInfo.availability.svodPlayable);
        var preview:Boolean = HelperUtils.getBoolean(playerInit.preview);
        var noAds:Boolean = HelperUtils.getBoolean(userInfo.availability.noAdsPlayable);
        var exceededDrm:Boolean = HelperUtils.getBoolean(userInfo.availability.exceededDrmRule);
        if (tvVodPlayable) {
            return false;
        } else if (svodPlayable) {
            return false;
        } else if (preview) {
            return false
        } else if (noAds && !exceededDrm) {
            return false;
        } else {
            return true;
        }
    }

    private function setSubtitlesButtonEnabled(enabled:Boolean):void {
        if (controlBarMetadata)
            controlBarMetadata.addValue(ControlBarConstants.SUBTITLE_BUTTON_ENABLED, enabled);
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
