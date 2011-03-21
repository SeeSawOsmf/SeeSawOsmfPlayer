/*
 * Copyright 2011 ioko365 Ltd.  All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the
 * License athttp://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2011 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2011 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 */
package com.seesaw.player.buffering {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.BufferEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.BufferTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.TraitEventDispatcher;

/**
 * Proxy class which sets the IBufferable.bufferTime property to
 * an initial value when the IBufferable trait is available, and
 * an expanded value when the proxied MediaElement first exits
 * the buffer state.
 **/
public class DualThresholdBufferingProxyElement extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(DualThresholdBufferingProxyElement);

    public function DualThresholdBufferingProxyElement(initialBufferTime:Number, expandedBufferTime:Number, wrappedElement:MediaElement) {
        super(wrappedElement);

        this.initialBufferTime = initialBufferTime;
        this.expandedBufferTime = expandedBufferTime;

        var dispatcher:TraitEventDispatcher = new TraitEventDispatcher();
        dispatcher.media = wrappedElement;

        wrappedElement.addEventListener(MediaElementEvent.TRAIT_ADD, processTraitAdd);
        dispatcher.addEventListener(BufferEvent.BUFFERING_CHANGE, processBufferingChange);
        dispatcher.addEventListener(SeekEvent.SEEKING_CHANGE, processSeekingChange);
        dispatcher.addEventListener(PlayEvent.PLAY_STATE_CHANGE, processPlayStateChange);
    }

    private function processTraitAdd(traitType:String):void {
        if (traitType == MediaTraitType.BUFFER) {
            // As soon as we can buffer, set the initial buffer time.
            var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
            bufferTrait.bufferTime = initialBufferTime;
            logger.debug("processTraitAdd: initial buffer time set {0}", initialBufferTime);
        }
    }

    private function processBufferingChange(event:BufferEvent):void {
        // As soon as we stop buffering, make sure our buffer time is
        // set to the maximum.
        if (event.buffering == false) {
            // only expand the buffer while playing
            var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
            if (playTrait && playTrait.playState == PlayState.PLAYING) {
                var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
                bufferTrait.bufferTime = expandedBufferTime;
                logger.debug("processBufferingChange: expanded buffer time set {0}", expandedBufferTime);
            }
        }
    }

    private function processSeekingChange(event:SeekEvent):void {
        // Whenever we seek, reset our buffer time to the minimum so that
        // playback starts quickly after the seek.
        var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
        if(bufferTrait) {
            bufferTrait.bufferTime = initialBufferTime;
            logger.debug("processSeekingChange: initial buffer time set {0}", initialBufferTime);
        }
    }

    private function processPlayStateChange(event:PlayEvent):void {
        // Whenever we pause, reset our buffer time to the minimum so that
        // playback starts quickly after the unpause.
        if (event.playState == PlayState.PAUSED) {
            var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
            if(bufferTrait) {
                bufferTrait.bufferTime = initialBufferTime;
                logger.debug("processPlayStateChange: initial buffer time set {0}", initialBufferTime);
            }
        }
    }

    private var initialBufferTime:Number;
    private var expandedBufferTime:Number;
}
}
