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
import org.osmf.traits.TraitEventDispatcher;

public class BufferManager extends ProxyElement {

    private static const UPDATE_INTERVAL:uint = 100;

    private var logger:ILogger = LoggerFactory.getClassLogger(BufferManager);

    private var timer:Timer;
    private var initialBufferTime:Number;
    private var expandedBufferTime:Number;

    public function BufferManager(initialBufferTime:Number, expandedBufferTime:Number, element:MediaElement) {
        super(element);

        if (initialBufferTime > expandedBufferTime)
            throw new ArgumentError("initialBufferTime > expandedBufferTime");

        this.initialBufferTime = initialBufferTime;
        this.expandedBufferTime = expandedBufferTime;

        var dispatcher:TraitEventDispatcher = new TraitEventDispatcher();
        dispatcher.media = element;

        element.addEventListener(MediaElementEvent.TRAIT_ADD, processTraitAdd);
        dispatcher.addEventListener(BufferEvent.BUFFERING_CHANGE, processBufferingChange);
        dispatcher.addEventListener(SeekEvent.SEEKING_CHANGE, processSeekingChange);
        dispatcher.addEventListener(PlayEvent.PLAY_STATE_CHANGE, processPlayStateChange);

        timer = new Timer(UPDATE_INTERVAL);
        timer.repeatCount = expandedBufferTime;
        timer.addEventListener(TimerEvent.TIMER, onTimer);
    }

    private function processTraitAdd(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.BUFFER) {
            // As soon as we can buffer, set the initial buffer time.
            var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
            bufferTrait.bufferTime = initialBufferTime;
        }
    }

    private function processBufferingChange(event:BufferEvent):void {
        // As soon as we stop buffering, make sure our buffer time is
        // set to the maximum.
        var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
        if (event.buffering == false) {
            timer.start();
        } else {
            bufferTrait.bufferTime = initialBufferTime;
        }
    }

    private function onTimer(event:TimerEvent = null):void {
        var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
        if (bufferTrait) {
            if (bufferTrait.bufferLength > 5) {
                bufferTrait.bufferTime += 1;
            } else if (bufferTrait.bufferLength < 5) {
                timer.stop();
                bufferTrait.bufferTime = initialBufferTime;
            }
        }
    }

    private function processSeekingChange(event:SeekEvent):void {
        var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
        if (bufferTrait) {
            timer.reset();
            bufferTrait.bufferTime = initialBufferTime;
        }
    }

    private function processPlayStateChange(event:PlayEvent):void {
        // Whenever we pause, reset our buffer time to the minimum so that
        // playback starts quickly after the unpause.
        if (event.playState == PlayState.PAUSED) {
            var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
            if(bufferTrait)
                bufferTrait.bufferTime = initialBufferTime;
        }
    }
}
}