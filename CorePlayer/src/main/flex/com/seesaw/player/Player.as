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
import com.seesaw.player.mockData.MockData;
import com.seesaw.player.panels.GuidancePanel;

import com.seesaw.player.posterFrame.PosterFrame;
import com.seesaw.player.services.ResumeService;

import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.logging.Log;
import org.osmf.net.StreamingURLResource;

[SWF(width=PLAYER::Width, height=PLAYER::Height, backgroundColor="#222222")]
public class Player extends Sprite {

    private static const PLAYER_WIDTH:int = PLAYER::Width;
    private static const PLAYER_HEIGHT:int = PLAYER::Height;

    private static var loggerSetup:* = (LoggerFactory.loggerFactory = new TraceAndArthropodLoggerFactory());
    private static var osmfLoggerSetup:* = (Log.loggerFactory = new CommonsOsmfLoggerFactory());

    private var logger:ILogger = LoggerFactory.getClassLogger(Player);

    private var _videoPlayer:SeeSawPlayer;
    private var _params:Object;

    // TODO: this is mocked for now
    private var _playerInitParams = new MockData().playerInit;

    private var _preInitStages:Vector.<Function>;

    public function Player() {
        super();

        logger.debug("created new player");

        registerServices();

        params = LoaderInfo(this.root.loaderInfo).parameters;

        // TODO: this needs to be in a flashvar from the page
        params.videoPlayerInfo = "http://localhost:8080/player.videoplayerinfo:getvideoplayerinfo?t:ac=TV:COMEDY/p/41001001001/No-Series-programmes-programme-1";

        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event):void {
        logger.debug("added to stage");
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        resetPreInitStages();
        evaluatePreInitStages();
    }

    private function resetPreInitStages() {
        // sets the order of stuff to evaluate during initialisation
        _preInitStages = new Vector.<Function>();
        _preInitStages[0] = showPosterFrame;
        _preInitStages[1] = showPlayPanel;
        _preInitStages[2] = showGuidancePanel;
        _preInitStages[3] = attemptPlaybackStart;
    }

    private function evaluatePreInitStages():void {
        // remove the next initialisation step and evaluate it
        var initialisationStage:Function = _preInitStages.shift();
        if (initialisationStage) {
            initialisationStage.call(this);
        }
    }

    private function showPosterFrame():void {
        //Play / resume / preview button
        var posterFrame = new PosterFrame("http://www.seesaw.com/i/ccp/00000210/21035.jpg");
        posterFrame.addEventListener(PosterFrame.LOADED, function(event:Event) {
            evaluatePreInitStages();
        });
        addChild(posterFrame);
    }

    private function showPlayPanel():void {
        //Play / resume / preview button
        var playButton:PlayStartButton = new PlayStartButton(PlayStartButton.PLAY);
        playButton.addEventListener(PlayStartButton.PROCEED, function(event:Event) {
            evaluatePreInitStages();
        });
        addChild(playButton);
    }

    private function showGuidancePanel():void {
        if (_playerInitParams.guidance) {
            var guidancePanel = new GuidancePanel(
                    _playerInitParams.guidanceWarning,
                    _playerInitParams.guidanceExplanation,
                    _playerInitParams.guidanceConfirmationMessage,
                    _playerInitParams.guidanceParentalControlsUrl,
                    _playerInitParams.guidanceFindOutMoreLink
                    );

            guidancePanel.addEventListener(GuidancePanel.GUIDANCE_ACCEPTED, function(event:Event) {
                evaluatePreInitStages();
            });

            guidancePanel.addEventListener(GuidancePanel.GUIDANCE_DECLINED, function(event:Event) {
                resetPreInitStages(); // sends the user back to stage 1
                evaluatePreInitStages();
            });

            addChild(guidancePanel);
        }
        else {
            evaluatePreInitStages();
        }
    }

    private function attemptPlaybackStart():void {
        requestProgrammeData();
    }

    private function requestProgrammeData():void {
        logger.debug("requesting programme data: " + params.videoPlayerInfo);

        var request:ServiceRequest = new ServiceRequest(params.videoPlayerInfo);
        request.successCallback = onSuccessFromVideoInfo;
        request.failCallback = onFailFromVideoInfo;
        request.submit();
    }

    private function onSuccessFromVideoInfo(programmeData:Object):void {
        logger.debug("received programme data for programme: " + + programmeData.programme.programmeId);
        var resource:StreamingURLResource = createMediaResource(programmeData);
        loadVideo(resource);
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

    private function createMediaResource(programmeData:Object):StreamingURLResource {
        logger.debug("creating media resource");
        return new DynamicStream(programmeData);
    }

    private function onFailFromVideoInfo():void {
        logger.debug("failed to retrieve programme data");
        // TODO: set the error ('programme not playing') panel as the main content
        // Note that this is the function that will be called when VideoPlayerInfo throws an exception.
        // VideoPlayerInfo will not return inconsistent or partial state.

        // TODO: This should be removed once the new video player info service is up and running
        var resource:StreamingURLResource = createMediaResource(new MockData().videoPlayerInfo);
        loadVideo(resource);
    }

    /**
     * Is this the best place for this?
     */
    private function registerServices() {
        logger.debug("registering services");
        var provider:ObjectProvider = ObjectProvider.getInstance();
        provider.register(ResumeService, new ResumeServiceImpl());
    }

    public function get videoPlayer():SeeSawPlayer {
        return _videoPlayer;
    }

    public function set videoPlayer(value:SeeSawPlayer):void {
        _videoPlayer = value;
    }

    public function get params():Object {
        return _params;
    }

    public function set params(value:Object):void {
        _params = value;
    }
}
}