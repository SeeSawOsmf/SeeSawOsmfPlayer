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
import com.seesaw.player.buttons.PlayStartButton;
import com.seesaw.player.captioning.sami.SAMIPluginInfo;
import com.seesaw.player.external.PlayerExternalInterface;
import com.seesaw.player.external.PlayerExternalInterfaceImpl;
import com.seesaw.player.impl.services.ResumeServiceImpl;
import com.seesaw.player.init.ServiceRequest;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.logging.CommonsOsmfLoggerFactory;
import com.seesaw.player.logging.TraceAndArthropodLoggerFactory;
import com.seesaw.player.namespaces.contentinfo;
import com.seesaw.player.namespaces.smil;
import com.seesaw.player.panels.GuidanceBar;
import com.seesaw.player.panels.GuidancePanel;
import com.seesaw.player.panels.PosterFrame;
import com.seesaw.player.preloader.Preloader;
import com.seesaw.player.services.ResumeService;

import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.external.ExternalInterface;

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

    // Returned by the player initialiser AJAX call
    private var playerInit:XML;

    // Returned by the video info AJAX call
    private var videoInfo:XML;

    public function Player() {
        super();

        logger.debug("created new player");

        registerServices();

        loaderParams = LoaderInfo(this.root.loaderInfo).parameters;

        // TODO: this needs to be in a flashvar from the page
        loaderParams.playerInitUrl = "http://kgd-blue-test-zxtm01.dev.vodco.co.uk/" +
                "player.playerinitialisation:playerinit?t:ac=TV:DRAMA/p/33535/Sintel";

        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event):void {
        logger.debug("added to stage");
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        preloader = new Preloader();
        addChild(preloader);

        requestPlayerInitData(loaderParams.playerInitUrl);
    }

    private function setupExternalInterface():void {
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("getGuidance", this.checkGuidance);
            ExternalInterface.addCallback("getCurrentItemTitle", this.getCurrentItemTitle);
            ExternalInterface.addCallback("getCurrentItemDuration", this.getCurrentItemDuration);
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
        else {
            nextInitialisationStage();
        }
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
        this.setupExternalInterface();
        resetInitialisationStages();
        nextInitialisationStage();
    }

    private function requestProgrammeData(videoInfoUrl:String):void {
        logger.debug("requesting programme data: " + videoInfoUrl);

        var request:ServiceRequest = new ServiceRequest(videoInfoUrl, onSuccessFromVideoInfo, onFailFromVideoInfo);
        request.submit();
    }

    private function onSuccessFromVideoInfo(response:Object):void {
        logger.debug("received programme data");

        var xmlDoc:XML = new XML(response);
        xmlDoc.ignoreWhitespace = true;

        videoInfo = xmlDoc;

        if (videoInfo.geoblocked == "true") {
            // TODO: show the geoblock panel
            return;
        }

        if (videoInfo.smil != null) {
            var resource:MediaResourceBase = createMediaResource(videoInfo);
            loadVideo(resource);
        }
        else {
            // TODO: show the error panel
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

        addChild(videoPlayer);
    }

    private function createMediaResource(videoInfo:XML):MediaResourceBase {
        logger.debug("creating media resource");
        // var resource:DynamicStream = new DynamicStream(videoInfo);
        var resource:MediaResourceBase = new MediaResourceBase();

        resource.addMetadataValue(PlayerConstants.CONTENT_INFO, playerInit);
        resource.addMetadataValue(PlayerConstants.VIDEO_INFO, videoInfo);
        resource.addMetadataValue(SMILConstants.SMIL_DOCUMENT, videoInfo.smil);

        // This allows plugins to check that the media is the main content
        var metaSettings:Metadata = new Metadata();
        metaSettings.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);
        resource.addMetadataValue(PlayerConstants.CONTENT_ID, metaSettings);

        // The SMIL plugin needs to remove the main content id from all the elements it creates otherwise
        // they will be wrapped in proxies - leading to double wrapping of proxies (since the smil element is proxied).
        resource.addMetadataValue(SMILConstants.PROXY_TRIGGER, PlayerConstants.CONTENT_ID);

        if (videoInfo && videoInfo.subtitleLocation) {
            var subtitleMetadata:Metadata = new Metadata();
            subtitleMetadata.addValue(SAMIPluginInfo.METADATA_KEY_URI, String(videoInfo.subtitleLocation));
            resource.addMetadataValue(SAMIPluginInfo.METADATA_NAMESPACE, subtitleMetadata);
        }

        return resource;
    }

    private function onFailFromPlayerInit():void {
        logger.debug("failed to retrieve init data");

        removePreloader();

        // TODO: set the error ('programme not playing') panel as the main content

        // TODO: request a test file but this should be removed eventually
        var request:ServiceRequest = new ServiceRequest("../src/test/resources/contentInfo.xml", onSuccessFromPlayerInit, null);
        request.submit();
    }

    private function onFailFromVideoInfo():void {
        logger.debug("failed to retrieve programme data");
        // TODO: set the error ('programme not playing') panel as the main content

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
        var provider:ObjectProvider = ObjectProvider.getInstance();
        var resumeService:ResumeService = provider.getObject(ResumeService);
        var resumeValue:Number = resumeService.getResumeCookie();
        return resumeValue;
    }

    private function removePreloader():void {
        if (preloader) {
            removeChild(preloader);
            preloader = null;
        }
    }

    private function get useLivreailAds():Boolean {
        // TODO: this needs work
        return Boolean(videoInfo.avod) || Boolean(videoInfo.exceededDrmRule);
    }

    public function get videoPlayer():SeeSawPlayer {
        return _videoPlayer;
    }

    public function set videoPlayer(value:SeeSawPlayer):void {
        _videoPlayer = value;
    }
}
}