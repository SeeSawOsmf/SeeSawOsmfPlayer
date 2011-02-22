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
package com.seesaw.player.buffering {
import flash.events.TimerEvent;
import flash.utils.Timer;

import org.osmf.elements.ProxyElement;
import org.osmf.events.BufferEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.BufferTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.TraitEventDispatcher;

/**
 * Proxy class which sets the IBufferable.bufferTime property to
 * an initial value when the IBufferable trait is available, and
 * an expanded value when the proxied MediaElement first exits
 * the buffer state.
 **/
public class BufferManager extends ProxyElement {
    private var timer:Timer = new Timer(100);
    private var bufferTrait:BufferTrait;

    public function BufferManager(initialBufferTime:Number, expandedBufferTime:Number, wrappedElement:MediaElement) {
        super(wrappedElement);

        this.initialBufferTime = initialBufferTime;
        this.expandedBufferTime = expandedBufferTime;

        var dispatcher:TraitEventDispatcher = new TraitEventDispatcher();
        dispatcher.media = wrappedElement;


        timer.addEventListener(TimerEvent.TIMER, onTimer);
        timer.start();
        wrappedElement.addEventListener(MediaElementEvent.TRAIT_ADD, processTraitAdd);
        dispatcher.addEventListener(BufferEvent.BUFFERING_CHANGE, processBufferingChange, false, 100);
        dispatcher.addEventListener(SeekEvent.SEEKING_CHANGE, processSeekingChange);
        dispatcher.addEventListener(PlayEvent.PLAY_STATE_CHANGE, processPlayStateChange);

    }

    private function processTraitAdd(traitType:String):void {
        if (traitType == MediaTraitType.BUFFER) {
            // As soon as we can buffer, set the initial buffer time.
            bufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
            bufferTrait.bufferTime = initialBufferTime;
        }
    }

    private function processBufferingChange(event:BufferEvent):void {
        // As soon as we stop buffering, make sure our buffer time is
        // set to the maximum.
        bufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;

        if (event.buffering == false) {

            onTimer();
            //  bufferTrait.bufferTime = expandedBufferTime;

        } else {
            bufferTrait.bufferTime = initialBufferTime;
            timer.start();

        }
    }

    private function onTimer(event:TimerEvent = null):void {
        if (bufferTrait) {
            trace(bufferTrait.bufferLength);
            if (bufferTrait.bufferLength < 1.5) {
                bufferTrait.bufferTime = initialBufferTime;
            }
            bufferTrait.bufferTime += 1;

            if (bufferTrait.bufferTime > expandedBufferTime) {
                timer.stop();
            }
        }
    }

    private function processSeekingChange(event:SeekEvent):void {
        // Whenever we seek, reset our buffer time to the minimum so that
        // playback starts quickly after the seek.
        if (event.seeking == true) {
            var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
            bufferTrait.bufferTime = initialBufferTime;
        }
    }

    private function processPlayStateChange(event:PlayEvent):void {
        // Whenever we pause, reset our buffer time to the minimum so that
        // playback starts quickly after the unpause.
        if (event.playState == PlayState.PAUSED) {
            var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
            bufferTrait.bufferTime = initialBufferTime;
        }
    }

    private var initialBufferTime:Number;
    private var expandedBufferTime:Number;
}
}