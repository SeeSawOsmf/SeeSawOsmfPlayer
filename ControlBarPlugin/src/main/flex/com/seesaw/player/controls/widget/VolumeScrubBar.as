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
package com.seesaw.player.controls.widget {
import com.seesaw.player.ui.PlayerToolTip;

import controls.seesaw.widget.interfaces.IWidget;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.chrome.assets.AssetsManager;
import org.osmf.chrome.assets.FontAsset;
import org.osmf.chrome.events.ScrubberEvent;
import org.osmf.chrome.widgets.*;
import org.osmf.events.AudioEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.AudioTrait;
import org.osmf.traits.MediaTraitType;

public class VolumeScrubBar extends Widget implements IWidget {

    private var logger:ILogger = LoggerFactory.getClassLogger(VolumeScrubBar);

    private var volumeDisplay:Number;

    private var defaultVolume:Number = 6;

    public static const EXTERNAL_GET_COOKIE_FUNCTION_NAME:String = "SEESAW.Utils.getCookie";
    public static const EXTERNAL_SET_COOKIE_FUNCTION_NAME:String = "SEESAW.Utils.setCookie";
    public static const PLAYER_VOLUME_COOKIE:String = "seesaw.player.volume";

    public function VolumeScrubBar() {
        scrubBarClickArea = new Sprite();
        scrubBarClickArea.addEventListener(MouseEvent.MOUSE_DOWN, onTrackMouseDown);
        addChild(scrubBarClickArea);
        super();
    }

    // Overrides
    //

    override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean = true):void {
        if (lastWidth != availableWidth || lastHeight != availableHeight) {
            lastWidth = availableWidth;
            lastHeight = availableHeight;


            scrubBarWidth = Math.max(10, maxWidth);


            scrubBarTrack.y = Math.round(( scrubBarTrack.height) / 2)
            scrubBarTrack.width = scrubBarWidth;

            scrubberStart = scrubBarTrack.x - Math.round(scrubber.width / 2);
            scrubberEnd = scrubberStart + scrubBarWidth;

            scrubber.range = scrubBarWidth;
            scrubber.y = scrubBarTrack.y - (scrubber.height / 2) + 3;
            scrubber.origin = scrubberStart;

            scrubBarClickArea.x = scrubBarTrack.x;
            scrubBarClickArea.y = scrubBarTrack.y;
            scrubBarClickArea.graphics.clear();
            scrubBarClickArea.graphics.beginFill(0xFFFFFF, 0);
            scrubBarClickArea.graphics.drawRect(0, 0, scrubBarWidth, scrubber.height);
            scrubBarClickArea.graphics.endFill();

        }
    }


    override public function configure(xml:XML, assetManager:AssetsManager):void {
        super.configure(xml, assetManager);

        maxWidth = Number(xml.@width || 10);
        var fontId:String = xml.@font || "defaultFont";
        var fontAsset:FontAsset = assetManager.getAsset(fontId) as FontAsset;


        scrubBarTrack = assetManager.getDisplayObject(xml.@track) || new Sprite();
        addChild(scrubBarTrack);

        scrubber
                = new Scrubber
                (assetManager.getDisplayObject(xml.@scrubberUp) || new Sprite()
                        , assetManager.getDisplayObject(xml.@scrubberDown) || new Sprite()
                        , assetManager.getDisplayObject(xml.@scrubberDisabled) || new Sprite()
                        );

        this.toolTip = new PlayerToolTip(scrubber, "Volume: ");

        scrubber.enabled = false;
        scrubber.addEventListener(ScrubberEvent.SCRUB_START, onScrubberStart);
        scrubber.addEventListener(ScrubberEvent.SCRUB_UPDATE, onScrubberUpdate);
        scrubber.addEventListener(ScrubberEvent.SCRUB_END, onScrubberEnd);
        scrubber.addEventListener(Event.ADDED_TO_STAGE, this.scrubberAddedToStage);
        addChild(scrubber);


        measure();

        updateState();

    }

    private function scrubberAddedToStage(event:Event) {
        stage.addChild(this.toolTip);
        if (ExternalInterface.available) {
            this.checkCookieVolume();
            ExternalInterface.addCallback("getVolume", this.getVolume);
            ExternalInterface.addCallback("setVolume", this.setVolume);
        }
    }

    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function processRequiredTraitsAvailable(media:MediaElement):void {
        updateState();
        audible = media.getTrait(MediaTraitType.AUDIO) as AudioTrait;
        if (audible) {
            audible.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
        }
        if (audible.volume) {
            onVolumeChange();
        }
    }

    private function getVolume():Number {
        return this.volumeDisplay;
    }

    private function checkCookieVolume():void {
        var tmpVol:*;
        tmpVol = ExternalInterface.call(EXTERNAL_GET_COOKIE_FUNCTION_NAME, PLAYER_VOLUME_COOKIE);
        if (tmpVol != "" && tmpVol != null) {
            logger.debug("VALUE OF VOLUME COOKIE: " + tmpVol);
            setVolume(tmpVol);
        } else {
            setVolume(defaultVolume);
        }
    }

    private function setCookieVolume():void {
        if (ExternalInterface.available) {
            logger.debug("SET VOLUME COOKIE TO: " + (audible.volume * 10));
            ExternalInterface.call(EXTERNAL_SET_COOKIE_FUNCTION_NAME, PLAYER_VOLUME_COOKIE, (audible.volume * 10), false, "/");
        }
    }

    private function setVolume(newVolumeDisplay:Number):void {
        if (audible) {
            audible.volume = newVolumeDisplay / 10;

            if (audible.volume < 0.05) {
                audible.volume = 0;
                logger.debug('MUTE');
            }

            this.setCookieVolume();

            logger.debug('New audible.volume: ' + audible.volume);
        }
        //this.volumeDisplay = newVolumeDisplay;
    }

    override protected function processRequiredTraitsUnavailable(media:MediaElement):void {
        updateState();
    }

    override protected function onMediaElementTraitAdd(event:MediaElementEvent):void {
        updateState();
    }

    override protected function onMediaElementTraitRemove(event:MediaElementEvent):void {
        updateState();
    }

    // Internals
    //

    private function updateState():void {
        visible = media != null;
        scrubber.enabled = visible;
    }


    private function onScrubberStart(event:ScrubberEvent):void {

    }

    private function onScrubberUpdate(event:ScrubberEvent = null):void {

        audible = media.getTrait(MediaTraitType.AUDIO) as AudioTrait;

        var percentage:Number = ((scrubber.x - scrubberStart) / scrubBarWidth);

        audible.volume = Math.min(percentage, percentage);
        if (audible.volume < 0.05) {
            audible.volume = 0;
            logger.debug('MUTE');
        }
        logger.debug("New Volume: audible.volume : " + audible.volume);
        this.volumeDisplay = Math.round(audible.volume * 12);

        this.setCookieVolume();
    }


    private function onScrubberEnd(event:ScrubberEvent):void {
        onScrubberUpdate();


    }

    private function onTrackMouseDown(event:MouseEvent):void {
        scrubber.start();
    }


    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }

    protected function onVolumeChange(event:AudioEvent = null):void {
        scrubber.x = audible.volume * scrubBarWidth - scrubber.width / 2;
        this.volumeDisplay = Math.round(audible.volume * 12);
        this.toolTip.updateToolTip("Volume: " + this.volumeDisplay);
    }


    private var scrubber:Scrubber;
    private var scrubBarClickArea:Sprite;

    private var scrubberStart:Number;
    private var scrubberEnd:Number;

    private var maxWidth:Number;


    private var scrubBarTrack:DisplayObject;


    private var lastWidth:Number;
    private var lastHeight:Number;

    private var seekToTime:Number;

    private var toolTip:PlayerToolTip;

    private var scrubBarWidth:Number;
    /* static */

    protected var audible:AudioTrait;

    private static const QUALIFIED_NAME:String = "com.seesaw.player.controls.widget.VolumeScrubBar";
    private static const CURRENT_POSITION_UPDATE_INTERVAL:int = 100;
    private static const _requiredTraits:Vector.<String> = new Vector.<String>;
    _requiredTraits[0] = MediaTraitType.AUDIO;

}
}