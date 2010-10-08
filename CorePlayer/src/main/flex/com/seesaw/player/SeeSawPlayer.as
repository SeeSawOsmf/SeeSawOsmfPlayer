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
import com.seesaw.player.components.ControlBarComponent;
import com.seesaw.player.logging.CommonsOsmfLoggerFactory;
import com.seesaw.player.logging.TraceAndArthropodLoggerFactory;

import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.containers.MediaContainer;
import org.osmf.elements.ParallelElement;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.layout.LayoutMetadata;
import org.osmf.logging.Log;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaPlayer;
import org.osmf.media.URLResource;

[SWF(width=640, height=400)]
public class SeeSawPlayer extends Sprite {

    private static var loggerSetup:* = (LoggerFactory.loggerFactory = new TraceAndArthropodLoggerFactory());
    private static var osmfLoggerSetup:* = (Log.loggerFactory = new CommonsOsmfLoggerFactory());

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawPlayer);

    private var mediaFactory:MediaFactory;
    private var mediaPlayer:MediaPlayer;
    private var mediaContainer:MediaContainer;
    private var rootElement:ParallelElement;
    private var controlBar:ControlBarComponent;

    public function SeeSawPlayer() {
        super();

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    public function initialise(parameters:Object, stage:Stage = null):void {
        logger.debug("initialising player");

        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        initialiseMediaPlayer();
        createComponents();
    }

    private function initialiseMediaPlayer():void {
        logger.debug("initialising media player");

        mediaFactory = new SeeSawMediaFactory();
        mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
        mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadError);

        mediaPlayer = new SeeSawMediaPlayer();
        mediaPlayer.media = createRootElement();

        mediaContainer = new MediaContainer();
        mediaContainer.addMediaElement(rootElement);
        addChild(mediaContainer);
    }

    private function createComponents():void {
        logger.debug("creating components");

        controlBar = new ControlBarComponent(this);
        mediaFactory.loadPlugin(controlBar.info);
    }

    private function createRootElement():MediaElement {
        logger.debug("creating root element");

        rootElement = new ParallelElement();

        rootElement.addChild(createVideoElement());

        var rootElementLayout:LayoutMetadata = new LayoutMetadata();
        rootElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, rootElementLayout);

        rootElementLayout.width = stage.stageWidth;
        rootElementLayout.height = stage.stageHeight;

        return rootElement;
    }

    private function createVideoElement():MediaElement {
        logger.debug("creating video element");

        var video:MediaElement = mediaFactory.createMediaElement(new URLResource(VIDEO_URL));
        return video;
    }

    // Event Handlers

    private function onAddedToStage(event:Event):void {
        logger.debug("added to stage");

        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        initialise(loaderInfo.parameters, stage);
    }

    private function onPluginLoaded(event:MediaFactoryEvent):void {
        logger.debug("plugin loaded");

        controlBar.pluginLoaded(event);
    }

    private function onPluginLoadError(event:MediaFactoryEvent):void {
        logger.debug("plugin error");

        controlBar.pluginLoadError(event);
    }

    public function get factory():MediaFactory {
        return mediaFactory;
    }

    public function get element():ParallelElement {
        return rootElement;
    }

    // TODO: this must come from initialiser
    private static const VIDEO_URL:String
            = "rtmp://cp67126.edgefcs.net/ondemand/mp4:mediapm/osmf/content/test/sample1_700kbps.f4v";
}
}