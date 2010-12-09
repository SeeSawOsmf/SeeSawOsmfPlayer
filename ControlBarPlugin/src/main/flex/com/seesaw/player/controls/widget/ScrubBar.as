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

package
com.seesaw.player.controls.widget {
import com.seesaw.player.events.AdEvent;
import com.seesaw.player.traits.ads.AdState;
import com.seesaw.player.traits.ads.AdTrait;
import com.seesaw.player.traits.ads.AdTraitType;
import com.seesaw.player.ui.StyledTextField;

import controls.seesaw.widget.interfaces.IWidget;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.external.ExternalInterface;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.Timer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.chrome.assets.AssetsManager;
import org.osmf.chrome.assets.FontAsset;
import org.osmf.chrome.events.ScrubberEvent;
import org.osmf.chrome.widgets.Scrubber;
import org.osmf.chrome.widgets.Widget;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.SeekEvent;
import org.osmf.events.TimeEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class ScrubBar extends Widget implements IWidget {
    private var _adState:AdTrait;
    private var adMarkers:Array;
    private var markerContainer:Sprite;
    private var currentTimeInSeconds:Number = 0;
    private var logger:ILogger = LoggerFactory.getClassLogger(PlayPauseButtonBase);
    
    public function ScrubBar() {
        currentTime = new StyledTextField();
        addChild(currentTime);

        scrubBarClickArea = new Sprite();
        scrubBarClickArea.addEventListener(MouseEvent.MOUSE_DOWN, onTrackMouseDown);
        addChild(scrubBarClickArea);

        markerContainer = new Sprite();
        addChild(markerContainer);

        this.setupExternalInterface();
        
        super();
    }

    // Overrides
    //

    override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean = true):void {
        if (lastWidth != availableWidth || lastHeight != availableHeight) {
            lastWidth = availableWidth;
            lastHeight = availableHeight;

            currentTime.height
                    = timeFieldsHeight;

            currentTime.width
                    = timeFieldsWidth;

            currentTime.x = availableWidth - timeFieldsWidth;

            var scrubBarWidth:Number = Math.max(10, availableWidth - ((timeFieldsWidth + timeFieldSpacing) * 2));

            scrubBarTrack.x = Math.round(timeFieldsWidth + timeFieldSpacing);
            scrubBarTrack.y = Math.round((timeFieldsHeight - scrubBarTrack.height) / 2)
            scrubBarTrack.width = scrubBarWidth;

            scrubBarTrail.y = scrubBarTrack.y;
            scrubBarTrail.x = scrubBarTrack.x;


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

            onTimerTick();
        }
    }


    override public function configure(xml:XML, assetManager:AssetsManager):void {
        super.configure(xml, assetManager);

        timeFieldsWidth = Number(xml.@timeFieldsWidth || 52);
        timeFieldsHeight = Number(xml.@timeFieldsHeight || 20);
        timeFieldSpacing = Number(xml.@timeFieldSpacing || 10);

        var fontId:String = xml.@font || "defaultFont";
        var fontAsset:FontAsset = assetManager.getAsset(fontId) as FontAsset;

        currentTime.defaultTextFormat = fontAsset.format;
        currentTime.selectable = false;
        currentTime.embedFonts = true;
        currentTime.alpha = 0.4;

        var format:TextFormat = fontAsset.format;
        format.align = TextFormatAlign.RIGHT;

        scrubBarTrack = assetManager.getDisplayObject(xml.@track) || new Sprite();
        addChild(scrubBarTrack);

        scrubBarTrail = assetManager.getDisplayObject(xml.@trackTrail) || new Sprite();
        addChild(scrubBarTrail);


        scrubber
                = new Scrubber
                (assetManager.getDisplayObject(xml.@scrubberUp) || new Sprite()
                        , assetManager.getDisplayObject(xml.@scrubberDown) || new Sprite()
                        , assetManager.getDisplayObject(xml.@scrubberDisabled) || new Sprite()
                        );

        // scrubber.enabled = false;
        scrubber.addEventListener(ScrubberEvent.SCRUB_START, onScrubberStart);
        scrubber.addEventListener(ScrubberEvent.SCRUB_UPDATE, onScrubberUpdate);
        scrubber.addEventListener(ScrubberEvent.SCRUB_END, onScrubberEnd);
        addChild(scrubber);

        currentPositionTimer = new Timer(CURRENT_POSITION_UPDATE_INTERVAL);
        currentPositionTimer.addEventListener(TimerEvent.TIMER, onTimerTick);

        measure();

        updateState();
    }

    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function processRequiredTraitsAvailable(media:MediaElement):void {
        updateState();
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

    override public function set media(value:MediaElement):void {
        if (media) {
            media.removeEventListener(MediaElementEvent.TRAIT_ADD, onMediaTraitsChange);
        }

        super.media = value;

        if (media) {
            media.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaTraitsChange);
        }
    }

    private function onMediaTraitsChange(event:MediaElementEvent):void {
        var target = event.target as MediaElement;
        if (event.traitType == MediaTraitType.TIME) {
            var timeTrait:TimeTrait = target.getTrait(MediaTraitType.TIME) as TimeTrait;
            timeTrait.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
        }
    }

    private function onDurationChange(event:TimeEvent):void {
        var timeTrait:TimeTrait = event.target as TimeTrait;
        positionOffset = timeTrait.currentTime;
    }

    // Internals
    //

    private function updateState():void {
        visible = media != null;
        scrubber.enabled = media ? media.hasTrait(MediaTraitType.SEEK) : false;

        adTrait = media ? media.getTrait(AdTraitType.AD_PLAY) as AdTrait : null;
        if (adTrait) {
            adTrait.addEventListener(AdEvent.AD_STATE_CHANGE, disableScrubber);
            adTrait.addEventListener(AdEvent.AD_MARKERS, adMarkerEvent);
        }

        updateTimerState();
    }

    private function adMarkerEvent(event:AdEvent):void {
        createAdMarkers(event.markers);
    }

    private function createAdMarkers(markers:Array):void {

        adMarkers = markers;

        removeAllChildren(markerContainer);

        for each (var value:Number in adMarkers) {
            var sprite:Sprite = new Sprite();
            sprite.graphics.beginFill(0xffffff);
            sprite.graphics.drawRect(scrubBarTrack.width * value + (scrubBarTrack.x) - 2, scrubBarTrack.y - 0.5, 6, 4);
            sprite.graphics.endFill();
            markerContainer.addChild(sprite);
        }
    }

    public function removeAllChildren(target:Sprite):void {
        while (target.numChildren)
            target.removeChildAt(0);
    }

    private function disableScrubber(event:AdEvent):void {
        if (adTrait.adState == AdState.STARTED) {
            visible = false;
        } else if (adTrait.adState == AdState.STOPPED) {
            visible = true;
        }
    }

    private function updateTimerState():void {
        var temporal:TimeTrait = media ? media.getTrait(MediaTraitType.TIME) as TimeTrait : null;
        if (temporal == null) {
            currentPositionTimer.stop();

            resetUI();
        }
        else {
            currentPositionTimer.start();
        }
    }

    private function onTimerTick(event:Event = null):void {
        // var seekTrait:SeekTrait = media ? media.getTrait(MediaTraitType.SEEK) as SeekTrait : null;
        // scrubber.visible = scrubBarTrail.visible = scrubBarTrack.visible = seekTrait != null;

        var temporal:TimeTrait = media ? media.getTrait(MediaTraitType.TIME) as TimeTrait : null;
        if (temporal != null) {
            var duration:Number = temporal.duration - positionOffset;
            var position:Number = temporal.currentTime - positionOffset;

            this.currentTimeInSeconds = position;

            currentTime.text
                    = prettyPrintSeconds(position) + " / " + prettyPrintSeconds(duration);

            var scrubberX:Number
                    = scrubberStart
                    + (    (scrubberEnd - scrubberStart)
                    * position
                    )
                    / duration
                    || scrubberStart; // defaul value if calc. returns NaN.

            scrubber.x = Math.min(scrubberEnd, Math.max(scrubberStart, scrubberX));
            scrubBarTrail.width = scrubber.x - scrubBarTrail.x + 4;
        }
        else {
            resetUI();
        }
    }

    private function prettyPrintSeconds(seconds:Number):String {
        seconds = Math.floor(isNaN(seconds) ? 0 : Math.max(0, seconds));
        return Math.floor(seconds / 3600)
                + ":"
                + (seconds % 3600 < 600 ? "0" : "")
                + Math.floor(seconds % 3600 / 60)
                + ":"
                + (seconds % 60 < 10 ? "0" : "") + seconds % 60;
    }

    private function onScrubberStart(event:ScrubberEvent):void {
        var playable:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playable) {
            preScrubPlayState = playable.playState;
            if (playable.canPause && playable.playState != PlayState.PAUSED) {
                playable.pause();
                currentPositionTimer.stop();
            }
        }
    }

    private function onScrubberUpdate(event:ScrubberEvent = null):void {
        var temporal:TimeTrait = media ? media.getTrait(MediaTraitType.TIME) as TimeTrait : null;
        var seekable:SeekTrait = media ? media.getTrait(MediaTraitType.SEEK) as SeekTrait : null;
        if (temporal && seekable) {

            var time:Number
                    = (temporal.duration * (scrubber.x - scrubberStart))
                    / scrubber.range;

            if (seekable.canSeekTo(time)) {
                seekable.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange)
                seekToTime = time;
                seekable.seek(time);
            }

        }
    }

    private function seekTo(targetTime:Number):void {
        var seekable:SeekTrait = media ? media.getTrait(MediaTraitType.SEEK) as SeekTrait : null;
        seekToTime = targetTime;
        seekable.seek(targetTime);
    }

    private function onSeekingChange(event:SeekEvent):void {
        var seekable:SeekTrait = event.target as SeekTrait;
        if (event.seeking == false) {
            seekable.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
            seekToTime = NaN;
            onTimerTick();
        }
    }

    private function onScrubberEnd(event:ScrubberEvent):void {
        onScrubberUpdate();

        if (preScrubPlayState) {
            var playable:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
            if (playable) {
                currentPositionTimer.start();
                if (playable.playState != preScrubPlayState) {
                    switch (preScrubPlayState) {
                        case PlayState.STOPPED:
                            playable.stop();
                            break;
                        case PlayState.PLAYING:
                            playable.play();
                            break;
                    }
                }
            }
        }
    }

    private function onTrackMouseDown(evenet:MouseEvent):void {
        scrubber.start();
    }

    private function resetUI():void {
        currentTime.text = "0:00:00";
        scrubber.x = scrubberStart;
        scrubBarTrail.width = scrubber.x - scrubBarTrail.x + 4;
    }

    private function setupExternalInterface():void {
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("getCurrentItemPosition", this.getCurrentItemPosition);
            ExternalInterface.addCallback("seekTo", this.seekTo);
        }
    }

    private function getCurrentItemPosition():Number {
        return this.currentTimeInSeconds;
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }

    private var positionOffset:Number;

    private var scrubber:Scrubber;
    private var scrubBarClickArea:Sprite;

    private var scrubberStart:Number;
    private var scrubberEnd:Number;

    private var timeFieldsWidth:Number;
    private var timeFieldsHeight:Number;
    private var timeFieldSpacing:Number;

    private var currentTime:TextField;

    private var currentPositionTimer:Timer;

    private var scrubBarTrack:DisplayObject;

    private var scrubBarTrail:DisplayObject;

    private var preScrubPlayState:String;

    private var lastWidth:Number;
    private var lastHeight:Number;

    private var seekToTime:Number;

    /* static */
    private static const QUALIFIED_NAME:String = "com.seesaw.player.controls.widget.ScrubBar";
    private static const CURRENT_POSITION_UPDATE_INTERVAL:int = 100;
    private static const _requiredTraits:Vector.<String> = new Vector.<String>;
    _requiredTraits[0] = MediaTraitType.TIME;
    _requiredTraits[1] = AdTraitType.AD_PLAY;

    public function get adTrait():AdTrait {
        return _adState;
    }

    public function set adTrait(value:AdTrait):void {
        _adState = value;
    }
}
}