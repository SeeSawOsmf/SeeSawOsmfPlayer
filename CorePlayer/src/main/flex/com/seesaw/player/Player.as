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
import com.seesaw.player.ads.LiverailConstants;
import com.seesaw.player.buttons.PlayStartButton;
import com.seesaw.player.captioning.sami.SAMIPluginInfo;
import com.seesaw.player.external.PlayerExternalInterface;
import com.seesaw.player.external.PlayerExternalInterfaceImpl;
import com.seesaw.player.impl.services.ResumeServiceImpl;
import com.seesaw.player.utils.ServiceRequest;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.liverail.LiverailConfig;
import com.seesaw.player.logging.CommonsOsmfLoggerFactory;
import com.seesaw.player.logging.TraceAndArthropodLoggerFactory;
import com.seesaw.player.namespaces.contentinfo;
import com.seesaw.player.namespaces.smil;
import com.seesaw.player.panels.GuidanceBar;
import com.seesaw.player.panels.GuidancePanel;
import com.seesaw.player.panels.ParentalControlsPanel;
import com.seesaw.player.panels.PosterFrame;
import com.seesaw.player.preloader.Preloader;
import com.seesaw.player.preventscrub.ScrubPreventionConstants;
import com.seesaw.player.services.ResumeService;

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

    var testApi:TestApi;

    public function Player() {
        super();

        logger.debug("created new player");

        registerServices();

        xi = ObjectProvider.getInstance().getObject(PlayerExternalInterface);

        loaderParams = LoaderInfo(this.root.loaderInfo).parameters;

        // If no flashVar, use a default for testing
        // TODO: remove this altogether
        loaderParams.playerInitUrl = loaderParams.playerInitUrl || "http://kgd-blue-test-zxtm01.dev.vodco.co.uk/" +
                "player.playerinitialisation:playerinit?t:ac=TV:FACTUAL/s/7675/Around-the-World-in-80-Days";

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
        if (playerInit.guidance) {
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
        preInitStages[3] = removePosterFrame;
        preInitStages[4] = attemptPlaybackStart;
    }

    private function showPosterFrame():void {
        //Play / resume / preview button
        posterFrame = new PosterFrame(playerInit.largeImageUrl);
        posterFrame.addEventListener(PosterFrame.LOADED, function(event:Event) {
            nextInitialisationStage();
        });

        //if there is guidance, show the guidance bar
        if (playerInit.guidance) {
            guidanceBar = new GuidanceBar(playerInit.guidance.warning);
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

    private function showGuidancePanel():void {
        if (playerInit.tvAgeRating && playerInit.tvAgeRating >= 16 && playerInit.guidance) {
            if (guidanceBar) {
                guidanceBar.visible = false;
            }

            if (ExternalInterface.available) {
                var hashedPassword:String = ParentalControlsPanel.getHashedPassword();
                logger.debug("COOKIE PASSWORD: " + hashedPassword);
            }

            if (hashedPassword) {
                var parentalControlsPanel = new ParentalControlsPanel(
                        hashedPassword,
                        playerInit.guidance.warning,
                        playerInit.guidance.explanation,
                        playerInit.guidance.guidance,
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
                        playerInit.guidance.warning,
                        playerInit.guidance.explanation,
                        playerInit.guidance.guidance,
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
      logger.info("Retreived ASX data from C4");
      logger.info(asx);

      ASX_data = asx;

      resetInitialisationStages();
      nextInitialisationStage();
    }

    private function attemptPlaybackStart():void {
        requestProgrammeData(playerInit.videoInfoUrl);
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

        if (playerInit.adMode != "channel4") {
          resetInitialisationStages();
          nextInitialisationStage();
        }
    }

    private function requestProgrammeData(videoInfoUrl:String):void {
        logger.debug("requesting programme data: " + videoInfoUrl);
        var request:ServiceRequest = new ServiceRequest(videoInfoUrl, onSuccessFromVideoInfo, onFailFromVideoInfo);
        // For C4 ads we POST the ASX we receive from the ad script. For liverail and auditude, there's no need
        if (playerInit.adMode != "channel4") {
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

        if (videoInfo.geoblocked == "true") {
            return;
        }

        if (videoInfo.smil != null) {
            var resource:MediaResourceBase = createMediaResource(videoInfo);
            loadVideo(resource);
        }
    }

    private function loadVideo(content:MediaResourceBase):void {
        logger.debug("loading video");

        if (videoPlayer) {
            logger.debug("destroying existing player");
            removeChild(videoPlayer);
            videoPlayer = null;
        }

        logger.debug("creating player");

        var config:PlayerConfiguration = new PlayerConfiguration(PLAYER_WIDTH, PLAYER_HEIGHT, content);
        videoPlayer = new SeeSawPlayer(config);

        // Since we have autoPlay to false for liverail, we need to manually call play for C4:
        if (playerInit.adMode == "channel4")
            videoPlayer.mediaPlayer().autoPlay = true;
        
        addChild(videoPlayer);
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
            metadata.addValue(LiverailConstants.ADMANAGER_URL,  "http://vox-static.liverail.com/swf/v4/admanager.swf");
            resource.addMetadataValue(LiverailConstants.SETTINGS_NAMESPACE, metadata);
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

    public function get videoPlayer():SeeSawPlayer {
        return _videoPlayer;
    }

    public function set videoPlayer(value:SeeSawPlayer):void {
        _videoPlayer = value;
    }
}
}
