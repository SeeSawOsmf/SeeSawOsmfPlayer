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

package com.seesaw.player.autoresume {
import flash.display.Sprite;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.SeekTrait;

public class AutoResumeProxy extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(AutoResumeProxy);
    private var outerViewable:DisplayObjectTrait;
    private var displayObject:Sprite;

    public function AutoResumeProxy() {

    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            super.proxiedElement = proxiedElement;

            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

        }
    }

    override protected function setupTraits():void {
        logger.debug("setupTraits");
        addLocalTraits();
        super.setupTraits();

    }


    private function processTrait(traitType:String, added:Boolean):void {
        logger.debug(" --------- traitType -----------" + traitType);

        switch (traitType) {
            case MediaTraitType.LOAD:
                toggleLoadListeners(added);
                break;
            case MediaTraitType.SEEK:
                toggleSeekListeners(added);
                break;
            case MediaTraitType.PLAY:
                togglePlayListeners(added);
                break;
        }
    }


    private function togglePlayListeners(added:Boolean):void {
        var playable:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playable) {
            blockedTraits = new Vector.<String>();
            playable.play();
            if (added) {
                playable.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
                playable.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, onCanPauseChange);
            }
            else {
                playable.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
                playable.removeEventListener(PlayEvent.CAN_PAUSE_CHANGE, onCanPauseChange);
            }
        }
    }

    private function toggleSeekListeners(added:Boolean):void {
        var seek:SeekTrait = proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;

        seek.seek(resource.getMetadataValue("autoResume") as Number);

        if (seek) {
            seek.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
        } else {
            seek.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
        }
    }

    private function toggleLoadListeners(added:Boolean):void {
        var loadable:LoadTrait = proxiedElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
        if (loadable) {
            if (added) {
                loadable.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadableStateChange);

            }
            else {
                loadable.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadableStateChange);
            }
        }
    }

    private function onLoadableStateChange(event:LoadEvent):void {
        var playTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;

        if (playTrait) {
            var resume:Number = resource.getMetadataValue("autoResume") as Number;
            if (resume == 0) {
                blockedTraits = new Vector.<String>();
                if (playTrait.playState) {

                    playTrait.play();
                }

            }

        }
    }

    private function onCanPauseChange(event:PlayEvent):void {
        //   logger.debug("Can Pause Change:{0}", event.canPause);
    }

    private function onPlayStateChange(event:PlayEvent):void {
        //   logger.debug("Play State Change:{0}", event.playState);
    }

    private function onSeekingChange(event:SeekEvent):void {
        logger.debug("On Seek Change:{0}", event.time);
    }


    private function onTraitAdd(event:MediaElementEvent):void {
        processTrait(event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        processTrait(event.traitType, false);
    }

    private function addLocalTraits():void {

    }

    private function removeLocalTraits():void {

    }


}
}