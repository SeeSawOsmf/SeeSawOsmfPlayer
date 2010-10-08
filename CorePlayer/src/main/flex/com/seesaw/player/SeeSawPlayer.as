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

import flash.display.Sprite;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.containers.MediaContainer;
import org.osmf.elements.ParallelElement;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.layout.LayoutMetadata;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaPlayer;
import org.osmf.media.MediaResourceBase;

public class SeeSawPlayer extends Sprite {

    private static const PLAYER_WIDTH:int = PLAYER::Width;
    private static const PLAYER_HEIGHT:int = PLAYER::Height;

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawPlayer);

    private var mediaFactory:MediaFactory;
    private var mediaPlayer:MediaPlayer;
    private var mediaContainer:MediaContainer;
    private var rootElement:ParallelElement;
    private var controlBar:ControlBarComponent;
    private var mainContent:MediaResourceBase;

    private var playerWidth:int;
    private var playerHeight:int;

    public function SeeSawPlayer(mainContent:MediaResourceBase, width:int, height:int) {
        logger.debug("creating player");

        this.mainContent = mainContent;
        playerWidth = width;
        playerHeight = height;

        initialisePlayer();
        createComponents();
    }

    private function initialisePlayer():void {
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

        rootElementLayout.width = playerWidth;
        rootElementLayout.height = playerHeight;

        return rootElement;
    }

    private function createVideoElement():MediaElement {
        logger.debug("creating video element");
        var video:MediaElement = mediaFactory.createMediaElement(mainContent);
        return video;
    }

    // Event Handlers

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
}
}