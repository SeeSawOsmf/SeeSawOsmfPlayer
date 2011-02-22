/*
 * The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *   The Initial Developer of the Original Code is Arqiva Ltd.
 *   Portions created by Arqiva Limited are Copyright (C) 2010, 2011 Arqiva Limited.
 *   Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe
 * 	Systems Incorporated.
 *   All Rights Reserved.
 *
 *   Contributor(s):  Adobe Systems Incorporated
 */

/**
 * Created by IntelliJ IDEA.
 * User: ibhana
 * Date: 10/02/11
 * Time: 09:19
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player {
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.controls.ControlBarPlugin;
import com.seesaw.player.external.PlayerExternalInterface;
import com.seesaw.player.external.PlayerExternalInterfaceImpl;
import com.seesaw.player.impl.services.ResumeServiceImpl;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.logging.CommonsOsmfLoggerFactory;
import com.seesaw.player.logging.TraceAndArthropodLoggerFactory;
import com.seesaw.player.services.ResumeService;

import flash.display.Sprite;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.containers.MediaContainer;
import org.osmf.elements.SerialElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MediaPlayerStateChangeEvent;
import org.osmf.events.TimeEvent;
import org.osmf.events.TimelineMetadataEvent;
import org.osmf.layout.VerticalAlign;
import org.osmf.logging.Log;
import org.osmf.media.*;
import org.osmf.metadata.CuePoint;
import org.osmf.metadata.CuePointType;
import org.osmf.metadata.Metadata;
import org.osmf.metadata.TimelineMetadata;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.TimeTrait;

[SWF(width="640", height="400", backgroundColor="0x000000",frameRate="25")]
public class SimplePlayer extends Sprite {

    /**
     * This player has been created as a concept for playing the ad playlist in a separate player
     */
    public function SimplePlayer() {
        super();

        var provider:ObjectProvider = ObjectProvider.getInstance();
        provider.register(ResumeService, new ResumeServiceImpl());
        provider.register(PlayerExternalInterface, new PlayerExternalInterfaceImpl());


        adBreaks = new Vector.<AdBreak>;
        adBreaks.push(new AdBreak(10));
        adBreaks.push(new AdBreak(20));

        mediaFactory = new DefaultMediaFactory();

        mainMediaPlayer = new MediaPlayer();

        adMediaPlayer = new MediaPlayer();
        adMediaPlayer.autoPlay = false;

        mainContainer = new MediaContainer();
        mainContainer.layoutMetadata.percentWidth = 100;
        mainContainer.layoutMetadata.percentHeight = 100;

        adContainer = new MediaContainer();
        adContainer.layoutMetadata.percentWidth = 100;
        adContainer.layoutMetadata.percentHeight = 100;

        controlbarContainer = new MediaContainer();
        controlbarContainer.layoutMetadata.percentWidth = 100;
        controlbarContainer.layoutMetadata.percentHeight = 100;
        controlbarContainer.layoutMetadata.verticalAlign = VerticalAlign.BOTTOM;

        serialAdPlaylist = new SerialElement();
        var adElement:MediaElement = mediaFactory.createMediaElement(
                new URLResource("rtmp://cp53221.edgefcs.net/ondemand/mp4:h264/eng-izor002-020-SD.mp4"));
        adElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
        serialAdPlaylist.addChild(adElement);
        adElement = mediaFactory.createMediaElement(
                new URLResource("rtmp://cp53221.edgefcs.net/ondemand/mp4:h264/Seesaw_Recycling.mp4"));
        adElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
        serialAdPlaylist.addChild(adElement);

        adContainer.addMediaElement(serialAdPlaylist);
        adMediaPlayer.media = serialAdPlaylist;

        mainContentElement = mediaFactory.createMediaElement(new URLResource(MAIN_CONTENT));

        setupAdBreaks(mainContentElement, adBreaks);
        mainContainer.addMediaElement(mainContentElement);

        mainMediaPlayer.media = mainContentElement;

        mainMediaPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, function(event:MediaPlayerStateChangeEvent):void {
            logger.debug("main: " + event.state);
        });

        adMediaPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, function(event:MediaPlayerStateChangeEvent):void {
            logger.debug("ad: " + event.state);
        });

        createControlBarElement();

        addChild(adContainer);
        addChild(mainContainer);
        addChild(controlbarContainer);
    }

    private function onTraitAdd(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.TIME) {
            var element:MediaElement = event.target as MediaElement;
            var timeTrait:TimeTrait = element.getTrait(MediaTraitType.TIME) as TimeTrait;
            timeTrait.addEventListener(TimeEvent.COMPLETE, function(event:TimeEvent):void {
                adBreakCompleted();
            });
        }
    }

    private function setupAdBreaks(element:MediaElement, adBreaks:Vector.<AdBreak>):void {
        var timelineMetadata:TimelineMetadata = element.getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
        if (timelineMetadata == null) {
            timelineMetadata = new TimelineMetadata(element);
            element.addMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE, timelineMetadata);
        }

        for each (var adBreak:AdBreak in adBreaks) {
            timelineMetadata.addMarker(new CuePoint(CuePointType.EVENT, adBreak.startTime, "adBreakStart", adBreak));
        }

        timelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onCuePoint);
    }

    private function onCuePoint(event:TimelineMetadataEvent):void {
        logger.debug("triggering cue point: {0}", event.marker.time);
        if (mainMediaPlayer.canPause) {
            mainMediaPlayer.pause();
        }
        if (adMediaPlayer.canPlay) {
            adMediaPlayer.play();
        }
        mainContainer.visible = false;
        adContainer.visible = true;
    }

    private function adBreakCompleted():void {
        logger.debug("ad break complete");
        if (adMediaPlayer.canPause) {
            adMediaPlayer.pause();
        }
        if (mainMediaPlayer.canPlay) {
            mainMediaPlayer.play();
        }
        mainContainer.visible = true;
        adContainer.visible = false;
    }

    private function createControlBarElement():void {
        logger.debug("adding control bar media element to container");

        var controlBarTarget:Metadata = new Metadata();
        controlBarTarget.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);
        mainContentElement.addMetadata(ControlBarPlugin.NS_TARGET, controlBarTarget);

        logger.debug("loading control bar plugin");
        mediaFactory.loadPlugin(new PluginInfoResource(new ControlBarPlugin().pluginInfo));

        var controlBarSettings:Metadata = new Metadata();
        controlBarSettings.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);

        var resource:MediaResourceBase = new MediaResourceBase();
        resource.addMetadataValue(ControlBarPlugin.NS_SETTINGS, controlBarSettings);

        logger.debug("creating control bar media element");
        var controlBarElement:MediaElement = mediaFactory.createMediaElement(resource);

        controlbarContainer.addMediaElement(controlBarElement);
    }

    private var serialAdPlaylist:SerialElement;
    private var mainContentElement:MediaElement
    private var mediaFactory:MediaFactory;
    private var mainMediaPlayer:MediaPlayer;
    private var adMediaPlayer:MediaPlayer;
    private var mainContainer:MediaContainer;
    private var adContainer:MediaContainer;
    private var controlbarContainer:MediaContainer;

    private var adBreaks:Vector.<AdBreak>;

    private static const MAIN_CONTENT:String = "rtmpe://cdn-flash-blue-dev.vodco.co.uk/a2703/mp4:e4/test/ccp/p/STD_RES/" +
            "00000418/41805.mp4?s=1296224433&amp;e=1296225183&amp;h=a61d40407278eaa0528fbeb2939b8aaa";

    private static var loggerSetup:* = (LoggerFactory.loggerFactory = new TraceAndArthropodLoggerFactory());
    private static var osmfLoggerSetup:* = (Log.loggerFactory = new CommonsOsmfLoggerFactory());

    private var logger:ILogger = LoggerFactory.getClassLogger(SimplePlayer);

}
}
