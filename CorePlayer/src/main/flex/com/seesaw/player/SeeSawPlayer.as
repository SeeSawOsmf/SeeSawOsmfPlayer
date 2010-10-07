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
import com.seesaw.player.components.ControlBarBuilder;

import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;

import org.osmf.containers.MediaContainer;
import org.osmf.elements.ParallelElement;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.layout.LayoutMetadata;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaPlayer;
import org.osmf.media.URLResource;

[SWF(width=640, height=400)]
public class SeeSawPlayer extends Sprite {

    private var rootElement:ParallelElement;
    private var mediaFactory:MediaFactory;
    private var mediaPlayer:MediaPlayer;
    private var mediaContainer:MediaContainer;

    private var builders:Vector.<MediaElementBuilder>;

    public function SeeSawPlayer() {
        super();

        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    public function initialise(parameters:Object, stage:Stage = null):void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

        mediaFactory = new SeeSawMediaFactory();

        initialiseMediaPlayer();

        addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
        addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadError);
    }

    private function initialiseMediaPlayer():void {
        mediaPlayer = new SeeSawMediaPlayer();
        mediaPlayer.media = createRootElement();

        mediaContainer = new MediaContainer();
        mediaContainer.addMediaElement(rootElement);
        addChild(mediaContainer);
    }

    private function createRootElement():MediaElement {
        rootElement = new ParallelElement();

        rootElement.addChild(createVideoElement());

        var rootElementLayout:LayoutMetadata = new LayoutMetadata();
        rootElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, rootElementLayout);

        rootElementLayout.width = stage.stageWidth;
        rootElementLayout.height = stage.stageHeight;

        return rootElement;
    }

    private function createVideoElement():MediaElement {
        var video:MediaElement = mediaFactory.createMediaElement(new URLResource(VIDEO_URL));
        for (var builder in builders) {
            builder.applyMetadataToElement(video);
        }

        return video;
    }

    private function createPluginBuilders() {
        builders = new Vector.<MediaElementBuilder>();
        builders.push(new ControlBarBuilder(mediaFactory));
    }

    // Event Handlers

    private function onAddedToStage(event:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        initialise(loaderInfo.parameters, stage);
    }

    private function onPluginLoaded(event:MediaFactoryEvent):void {
        for (var builder in builders) {
            if (builder.isSourceOf(event)) {
                var mediaElement:MediaElement = builder.newInstance(PlayerConstants.MAIN_CONTENT_ID);
                if (mediaElement != null) {
                    rootElement.addChild(mediaElement);
                }
            }
        }
    }

    private function onPluginLoadError(event:MediaFactoryEvent):void {
    }

    // TODO: this must come from initialiser
    private static const VIDEO_URL:String
            = "rtmp://cp67126.edgefcs.net/ondemand/mp4:mediapm/osmf/content/test/sample1_700kbps.f4v";
}
}