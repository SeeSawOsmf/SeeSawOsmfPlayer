/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *   The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *
 *   The Initial Developer of the Original Code is ioko365 Ltd.
 *   Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *   Incorporated. All Rights Reserved.
 */

package com.seesaw.player {
import com.seesaw.player.components.resourceBase.SeeSawMediaResource;
import com.seesaw.player.init.VideoPlayerInfoRequest;
import com.seesaw.player.init.ServiceRequestBase;
import com.seesaw.player.logging.CommonsOsmfLoggerFactory;
import com.seesaw.player.logging.TraceAndArthropodLoggerFactory;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.NetStatusEvent;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.logging.Log;
import org.osmf.media.MediaResourceBase;

[SWF(width=PLAYER::Width, height=PLAYER::Height)]
public class Player extends Sprite {

    private static const PLAYER_WIDTH:int = PLAYER::Width;
    private static const PLAYER_HEIGHT:int = PLAYER::Height;

    private static var loggerSetup:* = (LoggerFactory.loggerFactory = new TraceAndArthropodLoggerFactory());
    private static var osmfLoggerSetup:* = (Log.loggerFactory = new CommonsOsmfLoggerFactory());

    private var logger:ILogger = LoggerFactory.getClassLogger(Player);

    private var videoPlayer:SeeSawPlayer;

    public function Player() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event):void {
        logger.debug("added to stage");
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        requestProgrammeData();
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

    private function createMediaResource(programmeData:Object):MediaResourceBase {
        logger.debug("creating media: " + programmeData.lowResUrl);
        var seeSawMediaResource:SeeSawMediaResource = new SeeSawMediaResource();
        var mediaResource:MediaResourceBase = seeSawMediaResource.newResourceBase(this.loaderInfo.parameters, programmeData.lowResUrl);
        return mediaResource;
    }

    private function requestProgrammeData():void {
        logger.debug("requesting programme data: " + this.loaderInfo.parameters["programmeID"]);

        //TODO: these values should come from params
        var request:ServiceRequestBase = new VideoPlayerInfoRequest("http://kgd-red-test-zxtm01.dev.vodco.co.uk", 25149);
        request.successCallback = onSuccess;
        request.failCallback = onFail;
        request.submit();
    }

    private function onSuccess(programmeData:Object):void {
        logger.debug("received programme data");
        var resource:MediaResourceBase = createMediaResource(programmeData);
        loadVideo(resource);
    }

    private function onFail():void {
        logger.debug("failed to retrieve programme data");
    }
}
}