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
package com.seesaw.player.controls {
import com.seesaw.player.controls.widget.AdInfoLink;
import com.seesaw.player.controls.widget.ControlBar;
import com.seesaw.player.controls.widget.FullScreen;
import com.seesaw.player.controls.widget.LightsDownButton;
import com.seesaw.player.controls.widget.Padding;
import com.seesaw.player.controls.widget.PauseButton;
import com.seesaw.player.controls.widget.PlayButton;
import com.seesaw.player.controls.widget.ScrubBar;
import com.seesaw.player.controls.widget.SubtitlesButton;
import com.seesaw.player.controls.widget.Volume;
import com.seesaw.player.controls.widget.VolumeScrubBar;

import flash.utils.Dictionary;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.chrome.assets.AssetsManager;
import org.osmf.chrome.configuration.LayoutAttributesParser;
import org.osmf.chrome.configuration.WidgetsParser;
import org.osmf.chrome.widgets.Widget;
import org.osmf.events.MediaElementEvent;
import org.osmf.layout.LayoutMetadata;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaResourceBase;
import org.osmf.metadata.Metadata;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.MediaTraitType;

public class ControlBarElement extends MediaElement {
    private var logger:ILogger = LoggerFactory.getClassLogger(ControlBarElement);
    // Embedded assets (see configuration.xml for their assignments):
    //

    [Embed(source="/configuration.xml", mimeType="application/octet-stream")]
    private static const CONFIGURATION_XML:Class;

    [Embed(source="/Standard0755.swf#Standard0755")]
    private static const DEFAULT_FONT:Class;

    [Embed(source="/backDrop.png")]
    private static const BACKDROP:Class;

    [Embed(source="/blank.png")]
    private static const PAUSE_DISABLED:Class;

    [Embed(source="/pause.png")]
    private static const PAUSE_UP:Class;

    [Embed(source="/pauseOver.png")]
    private static const PAUSE_DOWN:Class;

    [Embed(source="/stop_disabled.png")]
    private static const STOP_DISABLED:Class;

    [Embed(source="/stop_up.png")]
    private static const STOP_UP:Class;

    [Embed(source="/stop_down.png")]
    private static const STOP_DOWN:Class;

    [Embed(source="/blank.png")]
    private static const PLAY_DISABLED:Class;

    [Embed(source="/play.png")]
    private static const PLAY_UP:Class;

    [Embed(source="/playOver.png")]
    private static const PLAY_DOWN:Class;

    [Embed(source="/scrubber_disabled.png")]
    private static const SCRUBBER_DISABLED:Class;

    [Embed(source="/scrubberButton.png")]
    private static const SCRUBBER_UP:Class;

    [Embed(source="/scrubberButton.png")]
    private static const SCRUBBER_DOWN:Class;

    [Embed(source="/scrubBarTrail.png")]
    private static const TRACK_TRAIL:Class;

    [Embed(source="/scrubBarTrack.png")]
    private static const SCRUB_BAR_TRACK:Class;

    [Embed(source="/volume.png")]
    private static const VOLUME_UP:Class;

    [Embed(source="/volumeOff.png")]
    private static const VOLUME_DISABLED:Class;

    // Public interface
    //
    public function ControlBarElement():void {
    }

    public function set target(value:MediaElement):void {
        logger.debug("adding target reference: " + target);
        if (value != null) {
            if (target) {
                target.removeEventListener(MediaElementEvent.TRAIT_ADD, onMediaTraitsChange);
                target.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaTraitsChange);
            }

            _target = value;

            target.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaTraitsChange);
            target.addEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaTraitsChange);

            controlBar.media = target;
        }
    }

    private function onMediaTraitsChange(event:MediaElementEvent):void {
        if (event.type == MediaElementEvent.TRAIT_ADD) {
            // Wait for the target element to display before displaying the control bar
            if (event.traitType == MediaTraitType.DISPLAY_OBJECT) {
                if (controlBar && !hasTrait(MediaTraitType.DISPLAY_OBJECT)) {
                    viewable = new DisplayObjectTrait(controlBar, controlBar.measuredWidth, controlBar.measuredHeight);
                    addTrait(MediaTraitType.DISPLAY_OBJECT, viewable);
                    controlBar.measure();
                }
            }
        } else {
            if (event.traitType == MediaTraitType.DISPLAY_OBJECT) {
                // Remove the control bar if the target element is removed
                if (controlBar) {
                    removeTrait(MediaTraitType.DISPLAY_OBJECT);
                }
            }
        }
    }

    // Overrides
    //

    override public function set resource(value:MediaResourceBase):void {
        logger.debug("setting resource: " + value);

        // Right after the media factory has instantiated us, it will set the
        // resource that it used to do so. We look the NS_CONTROL_BAR_SETTINGS
        // namespaced metadata, and retain it as our settings record
        // (containing only one field: "ID" that tells us the ID of the media
        // element that we should be controlling):
        if (value != null) {
            settings = value.getMetadataValue(ControlBarPlugin.NS_SETTINGS) as Metadata;
        }

        super.resource = value;
    }

    override protected function setupTraits():void {
        // Setup a control bar using the ChromeLibrary:
        setupControlBar();

        // Use the control bar's layout metadata as the element's layout metadata:
        var layoutMetadata:LayoutMetadata = new LayoutMetadata();
        LayoutAttributesParser.parse(controlBar.configuration, layoutMetadata);
        addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);

        super.setupTraits();
    }

    // Internals
    //

    private function setupControlBar():void {
        logger.debug("setupControlBar");

        addSeesawWidgets();

        try {
            var configuration:XML = XML(new CONFIGURATION_XML());

            var assetsManager:AssetsManager = new AssetsManager();
            assetsManager.addConfigurationAssets(configuration);
            assetsManager.load();

            var widgetsParser:WidgetsParser = new WidgetsParser();

            widgetsParser.parse(configuration.widgets.*, assetsManager);
            controlBar = widgetsParser.getWidget("controlBar");
        }
        catch (error:Error) {
            trace("WARNING: failed setting up control bar:", error.message);
        }
    }


    // IMPORTANT
    // We need to define the custom wigdets and instantiate the super class
    // So these can be registered to the chrome library

    private function addSeesawWidgets():void {
        logger.debug("adding widgets");
        customWidgetList["com.seesaw.player.controls.widget.scrubbar"] = ScrubBar;
        customWidgetList["com.seesaw.player.controls.widget.playbutton"] = PlayButton;
        customWidgetList["com.seesaw.player.controls.widget.pausebutton"] = PauseButton;
        customWidgetList["com.seesaw.player.controls.widget.adinfolink"] = AdInfoLink;
        customWidgetList["com.seesaw.player.controls.widget.lightsdownbutton"] = LightsDownButton;
        customWidgetList["com.seesaw.player.controls.widget.subtitlesbutton"] = SubtitlesButton;
        customWidgetList["com.seesaw.player.controls.widget.padding"] = Padding;
        customWidgetList["com.seesaw.player.controls.widget.fullscreen"] = FullScreen;
        customWidgetList["com.seesaw.player.controls.widget.volume"] = Volume;
        customWidgetList["com.seesaw.player.controls.widget.volumescrubbar"] = VolumeScrubBar;
        customWidgetList["com.seesaw.player.controls.widget.controlbar"] = ControlBar;
        //   customWidgetList["com.seesaw.player.controls.widget.lights"] = Lights;
        //   customWidgetList["com.seesaw.player.controls.widget.subtitles"] = SubTitles;
        //   customWidgetList["com.seesaw.player.controls.widget.tooltips"] = ToolTips;
        //   customWidgetList["com.seesaw.player.controls.widget.adblip"] = AdBlip;
        //   customWidgetList["com.seesaw.player.controls.widget.streamsense"] = StreamSense;
    }

    private var settings:Metadata;

    private var _target:MediaElement;
    private var controlBar:Widget;
    private var viewable:DisplayObjectTrait;

    private var customWidgetList:Dictionary = new Dictionary();

    /* static */

    private static const ID:String = "ID";

    public function get target():MediaElement {
        return _target;
    }
}
}
