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
import com.seesaw.player.controls.ControlBarMetadata;

import flash.events.Event;
import flash.external.ExternalInterface;

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

      override public function set media(value:MediaElement):void {

          super.media = value;

          if (media) {
              metadata = media.getMetadata(ControlBarMetadata.CONTROL_BAR_METADATA);
              if (metadata == null) {
                  metadata = new Metadata();
                  media.addMetadata(ControlBarMetadata.CONTROL_BAR_METADATA, metadata);
              }
          }
      }


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
        if(playTrait.playState == PlayState.PLAYING) {
            playTrait.pause();
        }
        else {
            playTrait.play();
        }

    }

    public function updateMetadata():void{
         metadata.addValue(ControlBarMetadata.USER_CLICK_STATE, playTrait.playState);
    }

    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function onMediaElementTraitAdd(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.PLAY) {
            var trait:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
            trait.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
            trait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
        }
        updateVisibility();
    }

    override protected function onMediaElementTraitRemove(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.PLAY) {
            var trait:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
            trait.removeEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
            trait.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
        }
        updateVisibility();
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

    public function get playTrait():PlayTrait {
        return media.getTrait(MediaTraitType.PLAY) as PlayTrait;
    }
}
}