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
import com.auditude.ads.osmf.constants.AuditudeOSMFConstants;
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.ads.AuditudeConstants;
import com.seesaw.player.ads.LiverailConstants;
import com.seesaw.player.buttons.PlayStartButton;
import com.seesaw.player.captioning.sami.SAMIPluginInfo;
import com.seesaw.player.external.PlayerExternalInterface;
import com.seesaw.player.external.PlayerExternalInterfaceImpl;
import com.seesaw.player.impl.services.ResumeServiceImpl;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.liverail.LiverailConfig;
import com.seesaw.player.logging.CommonsOsmfLoggerFactory;
import com.seesaw.player.logging.TraceAndArthropodLoggerFactory;
import com.seesaw.player.namespaces.contentinfo;
import com.seesaw.player.namespaces.smil;
import com.seesaw.player.panels.GuidanceBar;
import com.seesaw.player.panels.GuidancePanel;
import com.seesaw.player.panels.OverUsePanel;
import com.seesaw.player.panels.ParentalControlsPanel;
import com.seesaw.player.panels.PosterFrame;
import com.seesaw.player.preloader.Preloader;
import com.seesaw.player.preventscrub.ScrubPreventionConstants;
import com.seesaw.player.services.ResumeService;
import com.seesaw.player.utils.ServiceRequest;

import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.external.ExternalInterface;
import flash.net.URLVariables;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.logging.Log;
import org.osmf.media.MediaResourceBase;
import org.osmf.metadata.Metadata;
import org.osmf.smil.SMILConstants;

[SWF(width=PLAYER::Width, height=PLAYER::Height, backgroundColor="#000000")]
public class Player extends Sprite {

    use namespace contentinfo;
    use namespace smil;

    private static const PLAYER_WIDTH:int = PLAYER::Width;
    private static const PLAYER_HEIGHT:int = PLAYER::Height;

    private static var loggerSetup:* = (LoggerFactory.loggerFactory = new TraceAndArthropodLoggerFactory());
    private static var osmfLoggerSetup:* = (Log.loggerFactory = new CommonsOsmfLoggerFactory());

    private static const LIVERAIL_PLUGIN_URL:String = "http://vox-static.liverail.com/swf/v4/admanager.swf";

    private var logger:ILogger = LoggerFactory.getClassLogger(Player);

    private var _videoPlayer:SeeSawPlayer;

    private var loaderParams:Object;
    private var preInitStages:Vector.<Function>;
    private var posterFrame:PosterFrame;
    private var guidanceBar:Sprite;
    private var preloader:Preloader;
    private var xi:PlayerExternalInterface;

    private var playerInit:XML;
    private var videoInfo:XML;

    private var ASX_data:String;

    private var config:PlayerConfiguration;

    var testApi:TestApi;

    public function Player() {
        super();

        logger.debug("created new player");

        registerServices();

        xi = ObjectProvider.getInstance().getObject(PlayerExternalInterface);

        loaderParams = LoaderInfo(this.root.loaderInfo).parameters;

        // If no flashVar, use a default for testing
        // TODO: remove this altogether
        loaderParams.playerInitUrl = loaderParams.playerInitUrl || "http://localhost/player/initinfo/29053";
        /// loaderParams.playerInitUrl = loaderParams.playerInitUrl || "http://kgd-blue-test-zxtm01.dev.vodco.co.uk/player/initinfo/13602";

        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        // created purely to allow testing
        testApi = new TestApi(this);
    }

    private function onAddedToStage(event:Event):void {
        logger.debug("added to stage");
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        preloader = new Preloader();
        addChild(preloader);

        requestPlayerInitData(loaderParams.playerInitUrl);
    }

    private function setupExternalInterface():void {
        if (xi.available) {
            xi.addGetGuidanceCallback(checkGuidance);
            xi.addGetCurrentItemTitleCallback(getCurrentItemTitle);
            xi.addGetCurrentItemDurationCallback(getCurrentItemDuration);
            xi.addSetPlaylistCallback(setPlaylist);
            // Let JS know we're ready to receive calls (e.g. C4 ad script):
            xi.callSWFInit();
        }
    }

    private function checkGuidance():Boolean {
        if (playerInit.guidance.length() > 0) {
            return true;
        } else {
            return false;
        }
    }

    private function getCurrentItemTitle():String {
        if (playerInit.programmeTitle) {
            return playerInit.programmeTitle;
        } else {
            return "Title unavailable";
        }
    }

    private function getCurrentItemDuration():Number {
        if (playerInit.duration) {
            return playerInit.duration;
        }
        return 0;
    }

    private function resetInitialisationStages() {
        logger.debug("reseting pre-initialisation stages");
        // sets the order of stuff to evaluate during initialisation
        preInitStages = new Vector.<Function>();
        preInitStages[0] = showPosterFrame;
        preInitStages[1] = showPlayPanel;
        preInitStages[2] = showGuidancePanel;
        preInitStages[3] = checkEntitlements;
        preInitStages[4] = attemptPlaybackStart;
    }

    private function checkEntitlements():void {
        requestProgrammeData(playerInit.videoInfoUrl);
        //nextInitialisationStage();
    }

    private function showPosterFrame():void {
        //Play / resume / preview button
        posterFrame = new PosterFrame(playerInit.largeImageUrl);
        posterFrame.addEventListener(PosterFrame.LOADED, function(event:Event) {
            nextInitialisationStage();
        });

        //if there is guidance, show the guidance bar
        if (playerInit.guidance.length() > 0) {
            guidanceBar = new GuidanceBar(playerInit.guidance.message);
            posterFrame.addChild(guidanceBar);
        }
        addChild(posterFrame);
    }

    private function removePosterFrame():void {
        removeChild(posterFrame);
        posterFrame = null;
        nextInitialisationStage();
    }

    private function showPlayPanel():void {
        var mode:String = getResumePosition() > 0 ? PlayStartButton.RESUME : PlayStartButton.PLAY;
        var playButton:PlayStartButton = new PlayStartButton(mode);
        playButton.addEventListener(PlayStartButton.PROCEED, function(event:Event) {
            nextInitialisationStage();
        });
        addChild(playButton);
    }

    private function showOverUsePanel(errorType:String):void {

        //over use panel checks if the error is "NO_ADS", if it is it show no ads messaging, otherwise it shows pack messaging.
        //var errorType:String = "NO_ADS";
        var overUsePanel = new OverUsePanel(errorType, playerInit.parentalControls.termsAndConditionsLinkURL);
        addChild(overUsePanel);

        overUsePanel.addEventListener(OverUsePanel.OVERUSE_ACCEPTED, function(event:Event) {
            nextInitialisationStage();
        });

        overUsePanel.addEventListener(OverUsePanel.OVERUSE_REJECTED, function(event:Event) {
            resetInitialisationStages(); // sends the user back to stage 0
            nextInitialisationStage();
        });
    }

    private function showGuidancePanel():void {
        if (playerInit.tvAgeRating && playerInit.tvAgeRating >= 16 && playerInit.guidance) {
            if (guidanceBar) {
                guidanceBar.visible = false;
            }

            if (ExternalInterface.available) {
                var hashedPassword:String = ParentalControlsPanel.getHashedPassword();
                logger.debug("COOKIE PASSWORD: " + hashedPassword);
            }

            var assetType:String = "programme";

            if (playerInit.guidance.type != "tv" && playerInit.guidance.type != "TV") {
                assetType = "film";
            }

            if (hashedPassword) {
                var parentalControlsPanel = new ParentalControlsPanel(
                        hashedPassword,
                        playerInit.guidance.message,
                        assetType,
                        playerInit.guidance.age,
                        playerInit.parentalControls.parentalControlsPageURL,
                        playerInit.parentalControls.whatsThisLinkURL
                        );

                parentalControlsPanel.addEventListener(ParentalControlsPanel.PARENTAL_CHECK_PASSED, function(event:Event) {
                    nextInitialisationStage();
                });

                parentalControlsPanel.addEventListener(ParentalControlsPanel.PARENTAL_CHECK_FAILED, function(event:Event) {
                    resetInitialisationStages(); // sends the user back to stage 0
                    nextInitialisationStage();
                });

                addChild(parentalControlsPanel);
            } else {
                var guidancePanel = new GuidancePanel(
                        playerInit.guidance.message,
                        assetType,
                        playerInit.guidance.age,
                        playerInit.parentalControls.parentalControlsPageURL,
                        playerInit.parentalControls.whatsThisLinkURL
                        );

                guidancePanel.addEventListener(GuidancePanel.GUIDANCE_ACCEPTED, function(event:Event) {
                    nextInitialisationStage();
                });

                guidancePanel.addEventListener(GuidancePanel.GUIDANCE_DECLINED, function(event:Event) {
                    resetInitialisationStages(); // sends the user back to stage 0
                    nextInitialisationStage();
                });

                addChild(guidancePanel);
            }

        }
        else {
            nextInitialisationStage();
        }
    }

    private function setPlaylist(asx:String):void {
        if (playerInit.adMode != AdMetadata.CHANNEL_4_AD_TYPE) return; //we don't care

        logger.info("Retreived ASX data from C4");
        logger.info(asx);

        ASX_data = asx;

        resetInitialisationStages();
        nextInitialisationStage();
    }

    private function attemptPlaybackStart():void {
        if (videoInfo.smil != null) {
            var resource:MediaResourceBase = createMediaResource(videoInfo);
            loadVideo(resource);
        }
    }

    private function requestPlayerInitData(playerInitUrl:String):void {
        logger.debug("requesting programme data from: " + playerInitUrl);

        var request:ServiceRequest = new ServiceRequest(playerInitUrl, onSuccessFromPlayerInit, onFailFromPlayerInit);
        request.submit();
    }

    private function onSuccessFromPlayerInit(response:Object):void {
        logger.debug("received player init data");

        removePreloader();

        var xmlDoc:XML = new XML(response);
        xmlDoc.ignoreWhitespace = true;

        playerInit = xmlDoc;
        setupExternalInterface();

        ///adModulePlayableEvaluation
        if (playerInit.adMode != AdMetadata.CHANNEL_4_AD_TYPE) {
            resetInitialisationStages();
            nextInitialisationStage();
        }
    }

    private function requestProgrammeData(videoInfoUrl:String):void {
        logger.debug("requesting programme data: " + videoInfoUrl);
        var request:ServiceRequest = new ServiceRequest(videoInfoUrl, onSuccessFromVideoInfo, onFailFromVideoInfo);
        // For C4 ads we POST the ASX we receive from the ad script. For liverail and auditude, there's no need
        if (playerInit.adMode != AdMetadata.CHANNEL_4_AD_TYPE) {
            request.submit();
        } else {
            var post_data:URLVariables = new URLVariables();
            post_data.advertASX = ASX_data;
            request.submit(post_data);
        }
    }

    private function onSuccessFromVideoInfo(response:Object):void {
        logger.debug("received programme data");

        var xmlDoc:XML = new XML(response);
        xmlDoc.ignoreWhitespace = true;

        videoInfo = xmlDoc;
        playerInit.adMode[0] = adModulePlayableEvaluation();
        if (videoInfo.geoblocked == "true") {
            return;
        }

        if (videoInfo.exceededDrmRule == "true" && videoInfo.noAdsPlayable == "true") {
            this.showOverUsePanel("NO_ADS");
            return;
        }

        if (videoInfo.exceededDrmRule == "true" && videoInfo.svodPlayable == "true") {
            this.showOverUsePanel("SVOD");
            return;
        }

        if (videoInfo.exceededDrmRule == "true" && videoInfo.tvodPlayable == "true") {
            this.showOverUsePanel("TVOD");
            return;
        }

        nextInitialisationStage();
    }

    private function loadVideo(content:MediaResourceBase):void {
        logger.debug("loading video");

        if (videoPlayer) {
            logger.debug("destroying existing player");
            removeChild(videoPlayer);
            videoPlayer = null;
        }

        logger.debug("creating player");

        //var config:PlayerConfiguration = new PlayerConfiguration(PLAYER_WIDTH, PLAYER_HEIGHT, content);
        config = new PlayerConfiguration(PLAYER_WIDTH, PLAYER_HEIGHT, content);
        videoPlayer = new SeeSawPlayer(config);
        videoPlayer.addEventListener(PlayerConstants.DESTROY, reBuildPlayer);
        // Since we have autoPlay to false for liverail, we need to manually call play for C4:
        if (playerInit.adMode != AdMetadata.LR_AD_TYPE) {
            videoPlayer.mediaPlayer().autoPlay = true;
            if (playerInit.adMode == AdMetadata.AUDITUDE_AD_TYPE) {
                var metadata:Metadata = content.getMetadataValue(AuditudeOSMFConstants.AUDITUDE_METADATA_NAMESPACE) as Metadata;
                metadata.addValue(AuditudeOSMFConstants.PLAYER_INSTANCE, videoPlayer.mediaPlayer());
            }
        }

        removePosterFrame();

        addChild(videoPlayer);

        videoPlayer.init();
    }

    private function reBuildPlayer(event:Event):void {
        onAddedToStage(event);
    }

    private function createMediaResource(videoInfo:XML):MediaResourceBase {
        logger.debug("creating media resource");
        var resource:MediaResourceBase = new MediaResourceBase();

        var metadata:Metadata = new Metadata();
        metadata.addValue(PlayerConstants.CONTENT_INFO, playerInit);
        metadata.addValue(PlayerConstants.VIDEO_INFO, videoInfo);
        resource.addMetadataValue(PlayerConstants.METADATA_NAMESPACE, metadata);

        metadata = new Metadata();
        metadata.addValue(SMILConstants.SMIL_DOCUMENT, videoInfo.smil);
        resource.addMetadataValue(SMILConstants.SMIL_METADATA_NS, metadata);

        metadata = new Metadata();
        resource.addMetadataValue(ScrubPreventionConstants.SETTINGS_NAMESPACE, metadata);

        if (videoInfo && videoInfo.subtitleLocation) {
            metadata = new Metadata();
            metadata.addValue(SAMIPluginInfo.METADATA_KEY_URI, String(videoInfo.subtitleLocation));
            resource.addMetadataValue(SAMIPluginInfo.METADATA_NAMESPACE, metadata);
        }

        if (playerInit && playerInit.adMode == LiverailConstants.AD_MODE_ID) {
            metadata = new Metadata();
            metadata.addValue(LiverailConstants.VERSION, playerInit.liverail.version);
            metadata.addValue(LiverailConstants.PUBLISHER_ID, playerInit.liverail.publisherId);
            metadata.addValue(LiverailConstants.CONFIG_OBJECT, new LiverailConfig(playerInit));
            metadata.addValue(LiverailConstants.RESUME_POSITION, getResumePosition());
            metadata.addValue(LiverailConstants.ADMANAGER_URL, LIVERAIL_PLUGIN_URL);
            resource.addMetadataValue(LiverailConstants.SETTINGS_NAMESPACE, metadata);
        } else if (playerInit && playerInit.adMode == AuditudeConstants.AD_MODE_ID) {
            metadata = new Metadata();

            // the following 4 keys are required attributes for the Auditude plug-in
            // a) version: version of auditude plug-in
            // b) domain: adserver domain
            // c) zone-id: zone id assigned by Auditude
            // d) media-id: The video id of the currently playing content
            metadata.addValue(AuditudeOSMFConstants.VERSION, "adunitv2-1.0");
            metadata.addValue(AuditudeOSMFConstants.DOMAIN, "sandbox.auditude.com");
            metadata.addValue(AuditudeOSMFConstants.ZONE_ID, 1947);
            metadata.addValue(AuditudeOSMFConstants.MEDIA_ID, "GcE_e7ewtw2lMJVbDEJClpllo6mVJXSb"); //playerInit.programmeId

            // pass the mediaplayer instance to Auditude. This is required to listen for audio and content progress updates
            //metadata.addValue(AuditudeOSMFConstants.PLAYER_INSTANCE, videoPlayer.mediaPlayer());

            // any additional metadata can be passed to the Auditude plug-in through this key.
            metadata.addValue(AuditudeOSMFConstants.USER_DATA, null);

            metadata.addValue(AuditudeConstants.RESUME_POSITION, getResumePosition());
            resource.addMetadataValue(AuditudeOSMFConstants.AUDITUDE_METADATA_NAMESPACE, metadata)
        }

        return resource;
    }

    private function onFailFromPlayerInit():void {
        logger.debug("failed to retrieve init data");

        removePreloader();

        // TODO: request a test file but this should be removed eventually
        var request:ServiceRequest = new ServiceRequest("../src/test/resources/contentInfo.xml", onSuccessFromPlayerInit, null);
        request.submit();
    }

    private function onFailFromVideoInfo():void {
        logger.debug("failed to retrieve programme data");

        // TODO: request a test file but this should be removed eventually
        var request:ServiceRequest = new ServiceRequest("../src/test/resources/videoInfo.xml", onSuccessFromVideoInfo, null);
        request.submit();
    }

    /**
     * Is this the best place for this?
     */
    private function registerServices() {
        logger.debug("registering services");

        var provider:ObjectProvider = ObjectProvider.getInstance();
        provider.register(ResumeService, new ResumeServiceImpl());
        provider.register(PlayerExternalInterface, new PlayerExternalInterfaceImpl());
    }

    private function nextInitialisationStage():void {
        // remove the next initialisation step and evaluate it
        var initialisationStage:Function = preInitStages.shift();
        if (initialisationStage) {
            logger.debug("evaluating pre-initialisation stage");
            initialisationStage.call(this);
        }
    }

    private function getResumePosition():Number {
        var resumeService:ResumeService = ObjectProvider.getInstance().getObject(ResumeService);
        resumeService.programmeId = playerInit.programmeId;
        var resumeValue:Number = resumeService.getResumeCookie();
        return resumeValue;
    }

    private function removePreloader():void {
        if (preloader) {
            removeChild(preloader);
            preloader = null;
        }
    }

    private function adModulePlayableEvaluation():String {
        var playableType:String;
        var noAdsPlayable:String = videoInfo.noAdsPlayable;
        var svodPlayable:String = videoInfo.svodPlayable;
        var tvodPlayable:String = videoInfo.tvodPlayable;

        if (noAdsPlayable == "true" || svodPlayable == "true" || tvodPlayable == "true") {
            playableType = "none"
        } else {
            playableType = playerInit.adMode;
        }
        return playableType;
    }

    public function get videoPlayer():SeeSawPlayer {
        return _videoPlayer;
    }

    public function set videoPlayer(value:SeeSawPlayer):void {
        _videoPlayer = value;
    }
}
}
