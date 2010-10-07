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
import com.seesaw.player.logging.CommonsOsmfLoggerFactory;
import com.seesaw.player.logging.TraceAndArthropodLoggerFactory;

import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.logging.Log;

import org.osmf.containers.MediaContainer;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaPlayer;
import org.osmf.media.URLResource;

public class SeeSawPlayer extends Sprite {

    private static var loggerSetup:* = (LoggerFactory.loggerFactory = new TraceAndArthropodLoggerFactory());
    private static var osmfLoggerSetup:* = (Log.loggerFactory = new CommonsOsmfLoggerFactory());

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawPlayer);

    private var mediaFactory:MediaFactory;
    private var mediaElement:MediaElement;
    private var mediaPlayer:MediaPlayer;
    private var mediaContainer:MediaContainer;

    public function SeeSawPlayer() {
        super();

        logger.debug("HELLO!")
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    public function initialise(parameters:Object, stage:Stage = null):void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        mediaFactory = new SeeSawMediaFactory();
        mediaElement = mediaFactory.createMediaElement(new URLResource(VIDEO_URL));
        mediaPlayer = new SeeSawMediaPlayer();
        mediaPlayer.media = mediaElement;

        initialiseContainer();
    }

    private function initialiseContainer():void {
        mediaContainer = new MediaContainer();
        mediaContainer.addMediaElement(mediaElement);
        addChild(mediaContainer);
    }

    private function onAddedToStage(event:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        initialise(loaderInfo.parameters, stage);
    }

    // TODO: this must come from initialiser
    private static const VIDEO_URL:String
            = "rtmp://cp67126.edgefcs.net/ondemand/mp4:mediapm/osmf/content/test/sample1_700kbps.f4v";
}
}