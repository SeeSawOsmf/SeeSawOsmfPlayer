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
import com.seesaw.player.impl.services.ResumeServiceImpl;
import com.seesaw.player.init.ServiceRequest;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.logging.CommonsOsmfLoggerFactory;
import com.seesaw.player.logging.TraceAndArthropodLoggerFactory;
import com.seesaw.player.namespaces.contentinfo;
import com.seesaw.player.panels.GuidanceBar;
import com.seesaw.player.panels.GuidancePanel;
import com.seesaw.player.panels.PosterFrame;
import com.seesaw.player.services.ResumeService;

import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.logging.Log;
import org.osmf.metadata.Metadata;
import org.osmf.net.StreamingURLResource;

[SWF(width=PLAYER::Width, height=PLAYER::Height, backgroundColor="#000000")]
public class Player extends Sprite {

    use namespace contentinfo;

    private static const PLAYER_WIDTH:int = PLAYER::Width;
    private static const PLAYER_HEIGHT:int = PLAYER::Height;

    private static var loggerSetup:* = (LoggerFactory.loggerFactory = new TraceAndArthropodLoggerFactory());
    private static var osmfLoggerSetup:* = (Log.loggerFactory = new CommonsOsmfLoggerFactory());

    private var logger:ILogger = LoggerFactory.getClassLogger(Player);

    private var _videoPlayer:SeeSawPlayer;
    private var _loaderParams:Object;
    private var _preInitStages:Vector.<Function>;
    private var _posterFrame:PosterFrame;
    private var _guidanceBar:Sprite;

    // Returned by the player initialiser AJAX call
    private var _playerInit:XML;

    // Returned by the video info AJAX call
    private var _videoInfo:XML;

    public function Player() {
        super();

        logger.debug("created new player");

        registerServices();

        _loaderParams = LoaderInfo(this.root.loaderInfo).parameters;

        // TODO: this needs to be in a flashvar from the page
        _loaderParams.playerInitUrl = "http://localhost:8080/player.playerinitialisation:playerinit" +
                "?t:ac=TV:ENTERTAINMENT/p/12001018002/South-Park-programme-2";

        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event):void {
        logger.debug("added to stage");
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        requestPlayerInitData(_loaderParams.playerInitUrl);
    }

    private function resetInitialisationStages() {
        logger.debug("reseting pre-initialisation stages");
        // sets the order of stuff to evaluate during initialisation
        _preInitStages = new Vector.<Function>();
        _preInitStages[0] = showPosterFrame;
        _preInitStages[1] = showPlayPanel;
        _preInitStages[2] = showGuidancePanel;
        _preInitStages[3] = removePosterFrame;
        _preInitStages[4] = attemptPlaybackStart;
    }

    private function showPosterFrame():void {
        //Play / resume / preview button
        _posterFrame = new PosterFrame(_playerInit.largeImageUrl);
        _posterFrame.addEventListener(PosterFrame.LOADED, function(event:Event) {
            nextInitialisationStage();
        });

        //if there is guidance, show the guidance bar
        if (_playerInit.guidance) {
            _guidanceBar = new GuidanceBar(_playerInit.guidance.warning);
            _posterFrame.addChild(_guidanceBar);
        }
        addChild(_posterFrame);
    }

    private function removePosterFrame():void {
        removeChild(_posterFrame);
        _posterFrame = null;
        nextInitialisationStage();
    }

    private function showPlayPanel():void {
        var playButton:PlayStartButton = new PlayStartButton(PlayStartButton.PLAY);
        playButton.addEventListener(PlayStartButton.PROCEED, function(event:Event) {
            nextInitialisationStage();
        });
        addChild(playButton);
    }

    private function showGuidancePanel():void {
        if (_playerInit.guidance) {
            if (_guidanceBar) {
                _guidanceBar.visible = false;
            }
            var guidancePanel = new GuidancePanel(
                    _playerInit.guidance.warning,
                    _playerInit.guidance.explanation,
                    _playerInit.guidance.guidance,
                    _playerInit.parentalControls.parentalControlsPageURL,
                    _playerInit.parentalControls.whatsThisLinkURL
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
        requestProgrammeData(_playerInit.videoInfoUrl);
    }

    private function requestPlayerInitData(playerInitUrl:String):void {
        logger.debug("requesting programme data from: " + playerInitUrl);

        var request:ServiceRequest = new ServiceRequest(playerInitUrl, onSuccessFromPlayerInit, onFailFromPlayerInit);
        request.submit();
    }

    private function onSuccessFromPlayerInit(response:Object):void {
        logger.debug("received player init data for programme: " + response);

        var xmlDoc:XML = new XML(response);
        xmlDoc.ignoreWhitespace = true;

        _playerInit = xmlDoc;

        resetInitialisationStages();
        nextInitialisationStage();
    }

    private function requestProgrammeData(videoInfoUrl:String):void {
        logger.debug("requesting programme data: " + videoInfoUrl);

        var request:ServiceRequest = new ServiceRequest(videoInfoUrl, onSuccessFromVideoInfo, onFailFromVideoInfo);
        request.submit();
    }

    private function onSuccessFromVideoInfo(response:Object):void {
        logger.debug("received programme data for programme: " + response);

        var xmlDoc:XML = new XML(response);
        xmlDoc.ignoreWhitespace = true;

        _videoInfo = xmlDoc;

        if (_videoInfo.geoblocked == "true") {
            // TODO: show the geoblock panel
            return;
        }

        if (_videoInfo.asset.length() > 0) {
            var resource:StreamingURLResource = createMediaResource(_videoInfo);
            loadVideo(resource);
        }
        else {
            // TODO: show the error panel
        }
    }

    private function loadVideo(content:StreamingURLResource):void {
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

    private function createMediaResource(videoInfo:XML):StreamingURLResource {
        logger.debug("creating media resource");
        var resource:DynamicStream = new DynamicStream(videoInfo);

        var metaSettings:Metadata = new Metadata();
        // Use this to check the resource is the mainContent, e.g. for the AdProxypPlugins
        metaSettings.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);

        resource.addMetadataValue(PlayerConstants.CONTENT_ID, metaSettings);
        resource.addMetadataValue(PlayerConstants.CONTENT_INFO, _playerInit);
        resource.addMetadataValue(PlayerConstants.VIDEO_INFO, _videoInfo);

        return resource;
    }

    private function onFailFromPlayerInit():void {
        logger.debug("failed to retrieve init data");
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
        //     var en:String =  provider.getObject(ResumeService).getEncryptedValue("hello");
        //    var de:String =   provider.getObject(ResumeService).getDecryptedValue(en);
        //     var finalVal:String =  de;
    }

    private function nextInitialisationStage():void {
        // remove the next initialisation step and evaluate it
        var initialisationStage:Function = _preInitStages.shift();
        if (initialisationStage) {
            logger.debug("evaluating pre-initialisation stage");
            initialisationStage.call(this);
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