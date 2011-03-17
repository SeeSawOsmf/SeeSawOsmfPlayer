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
import com.seesaw.player.controls.ControlBarConstants;

import flash.events.Event;
import flash.external.ExternalInterface;

import flash.utils.getQualifiedClassName;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.PlayEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;

public class PlayPauseButtonBase extends ButtonWidget {

    private var logger:ILogger = LoggerFactory.getClassLogger(PlayPauseButtonBase);

    private var _requiredTraits:Vector.<String> = new Vector.<String>;

    private var metadata:Metadata;
    protected var playTrait:PlayTrait

    public function PlayPauseButtonBase() {
        logger.debug("PlayPauseButtonBase()");
        _requiredTraits[0] = MediaTraitType.PLAY;
        this.setupExternalInterface();
        buttonMode = true;
    }

    private function setupExternalInterface():void {
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("playPause", this.playPause);
        }
    }

    public function playPause():void {
        if (playTrait.playState == PlayState.PLAYING) {
            playTrait.pause();
        }
        else {
            playTrait.play();
        }
    }

    public function updateMetadata():void {
        metadata.addValue(ControlBarConstants.USER_CLICK_STATE, playTrait.playState);
    }

    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function onMediaElementTraitAdd(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.PLAY) {
            playTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
            playTrait.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
            playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
            updateVisibility();
        }
    }

    override protected function onMediaElementTraitRemove(event:MediaElementEvent):void {
        if (playTrait && event.traitType == MediaTraitType.PLAY) {
            playTrait.removeEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
            playTrait.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
            playTrait = null;
            updateVisibility();
        }
    }

    override protected function processMediaElementChange(oldMediaElement:MediaElement):void {
        metadata = media.getMetadata(ControlBarConstants.CONTROL_BAR_METADATA);
        if (metadata == null) {
            metadata = new Metadata();
            media.addMetadata(ControlBarConstants.CONTROL_BAR_METADATA, metadata);
        }
    }

    override protected function processRequiredTraitsAvailable(element:MediaElement):void {
        updateVisibility();
    }

    override protected function processRequiredTraitsUnavailable(element:MediaElement):void {
        updateVisibility();
    }

    protected function visibilityDeterminingEventHandler(event:Event = null):void {
        updateVisibility();
    }

    /**
     * Override this in a base class.
     */
    protected function updateVisibility():void {
        visible = false;
    }

    protected function get paused():Boolean {
        return playTrait && playTrait.playState == PlayState.PAUSED;
    }

    protected function get playing():Boolean {
        return playTrait && playTrait.playState == PlayState.PLAYING;
    }
}
}