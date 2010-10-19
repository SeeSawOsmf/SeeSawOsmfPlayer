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
package {
import controls.seesaw.widget.*;

import flash.utils.Dictionary;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.chrome.assets.AssetsManager;
import org.osmf.chrome.configuration.LayoutAttributesParser;
import org.osmf.chrome.configuration.WidgetsParser;
import org.osmf.chrome.widgets.Widget;
import org.osmf.layout.LayoutMetadata;
import org.osmf.media.MediaElement;
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

    private var _target:MediaElement;
    private var controlBar:Widget;
    private var viewable:DisplayObjectTrait;

    private var customWidgetList:Dictionary = new Dictionary();

    override protected function setupTraits():void {
        logger.debug("setupTraits");

        // Setup a control bar using the ChromeLibrary:
        setupControlBar();

        // Use the control bar's layout metadata as the element's layout metadata:
        var layoutMetadata:LayoutMetadata = new LayoutMetadata();
        LayoutAttributesParser.parse(controlBar.configuration, layoutMetadata);
        addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);

        // Signal that this media element is viewable: create a DisplayObjectTrait.
        // Assign controlBar (which is a Sprite) to be our view's displayObject.
        // Additionally, use its current width and height for the trait's mediaWidth
        // and mediaHeight properties:
        viewable = new DisplayObjectTrait(controlBar, controlBar.measuredWidth, controlBar.measuredHeight);
        // Add the trait:
        addTrait(MediaTraitType.DISPLAY_OBJECT, viewable);

        controlBar.measure();

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
        logger.debug("ADD WIDGETS");
        customWidgetList["controls.seesaw.widget.scrubbar"] = ScrubBar;
        customWidgetList["controls.seesaw.widget.playbutton"] = PlayButton;
        customWidgetList["controls.seesaw.widget.pausebutton"] = PauseButton;
        customWidgetList["controls.seesaw.widget.subtitlesbutton"] = SubtitlesButton;
        customWidgetList["controls.seesaw.widget.fullscreen"] = FullScreen;
        customWidgetList["controls.seesaw.widget.volume"] = Volume;
        customWidgetList["controls.seesaw.widget.volumescrubbar"] = VolumeScrubBar;
        //   customWidgetList["controls.seesaw.widget.lights"] = Lights;
        //   customWidgetList["controls.seesaw.widget.subtitles"] = SubTitles;
        //   customWidgetList["controls.seesaw.widget.tooltips"] = ToolTips;
        //   customWidgetList["controls.seesaw.widget.adblip"] = AdBlip;
        //   customWidgetList["controls.seesaw.widget.streamsense"] = StreamSense;
    }

    public function get target():MediaElement {
        return _target;
    }

    public function set target(value:MediaElement):void {
        _target = value;
        controlBar.media = target;
    }
}
}