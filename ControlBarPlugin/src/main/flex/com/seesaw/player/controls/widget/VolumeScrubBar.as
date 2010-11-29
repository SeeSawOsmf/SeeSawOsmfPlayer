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
package com.seesaw.player.controls.widget {
import com.seesaw.player.ui.PlayerToolTip;

import controls.seesaw.widget.interfaces.IWidget;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

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
        if (audible) {
            audible.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
        }
        var percentage:Number = ((scrubber.x - scrubberStart) / scrubBarWidth);

        audible.volume = Math.min(percentage, percentage);

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