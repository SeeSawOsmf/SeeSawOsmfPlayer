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
import com.seesaw.player.buttons.PlayResumePreviewButton;
import com.seesaw.player.init.ServiceRequest;
import com.seesaw.player.logging.CommonsOsmfLoggerFactory;
import com.seesaw.player.logging.TraceAndArthropodLoggerFactory;
import com.seesaw.player.mockData.MockData;

import com.seesaw.player.panels.GuidancePanel;

import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.logging.Log;
import org.osmf.media.MediaResourceBase;

[SWF(width=PLAYER::Width, height=PLAYER::Height)]
public class Player extends Sprite {

    private static const PLAYER_WIDTH:int = PLAYER::Width;
    private static const PLAYER_HEIGHT:int = PLAYER::Height;

    //constants for the button types
    private const PLAY:String = "play";
    private const PLAY_SUBSCRIBED:String = "playSubscribed";
    private const PREVIEW:String = "preview";
    private const RESUME:String = "resume";

    private static var loggerSetup:* = (LoggerFactory.loggerFactory = new TraceAndArthropodLoggerFactory());
    private static var osmfLoggerSetup:* = (Log.loggerFactory = new CommonsOsmfLoggerFactory());

    private var logger:ILogger = LoggerFactory.getClassLogger(Player);

    private var _videoPlayer:SeeSawPlayer;
    private var _params:Object;

    public function Player() {
        super();

        logger.debug("created new player");

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

        //Play / resume / preview button
        var playButton = new PlayResumePreviewButton(PLAY);
        playButton.addEventListener("PROCEED", function(event:Event) {
            requestProgrammeData();
        });

        addChild(playButton);

        //GUIDANCE PANEL
        /*
        var guidancePanel = new GuidancePanel("Strong language and adult humour", "This programme isn't suitable for younger viewers", "Please confirm you are aged 18 or older and accept our <a href=\"http://www.seesaw.com/TermsAndConditions\">Terms and Conditions</a>", "http://www.seesaw.com/ParentalControls/TV/Comedy/p-32181-The-Camping-Trip", "http://www.seesaw.com/watchingtv/aboutparentalcontrols");
        guidancePanel.addEventListener("GUIDANCE_ACCEPTED", function(event:Event) {
            requestProgrammeData();
        });
        //guidancePanel.addEventListener("GUIDANCE_DECLINED", this.videoNo);

        addChild(guidancePanel);*/


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

    private function requestProgrammeData():void {
        logger.debug("requesting programme data: " + params.videoPlayerInfo);

        var request:ServiceRequest = new ServiceRequest(params.videoPlayerInfo);
        request.successCallback = onSuccessFromVideoInfo;
        request.failCallback = onFailFromVideoInfo;
        request.submit();
    }

    private function onSuccessFromVideoInfo(programmeData:Object):void {
        logger.debug("received programme data for programme: " + + programmeData.programme.programmeId);
        var resource:MediaResourceBase = createMediaResource(programmeData);
        loadVideo(resource);
    }

    private function createMediaResource(programmeData:Object):MediaResourceBase {
        logger.debug("creating media resource");
        return new DynamicStream(programmeData);
    }

    private function onFailFromVideoInfo():void {
        logger.debug("failed to retrieve programme data");
        // TODO: set the error ('programme not playing') panel as the main content
        // Note that this is the function that will be called when VideoPlayerInfo throws an exception.
        // VideoPlayerInfo will not return inconsistent or partial state.

        // TODO: This should be removed once the new video player info service is up and running
        var resource:MediaResourceBase = createMediaResource(new MockData().videoPlayerInfo);
        loadVideo(resource);
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