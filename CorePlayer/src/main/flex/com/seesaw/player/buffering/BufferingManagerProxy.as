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
import org.osmf.traits.PlayTrait;
import org.osmf.traits.TraitEventDispatcher;

/**
 * Proxy class which sets the IBufferable.bufferTime property to
 * an initial value when the IBufferable trait is available, and
 * an expanded value when the proxied MediaElement first exits
 * the buffer state.
 **/
public class BufferingManagerProxy extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(BufferingManagerProxy);

    /**
     * The buffer behavior depends on whether the buffer time is set on a publishing stream or a subscribing stream.
     * For a publishing stream, bufferTime specifies how long the outgoing buffer can grow before the application starts
     * dropping frames. On a high-speed connection, buffer time is not a concern; data is sent almost as quickly as the
     * application can buffer it. On a slow connection, however, there can be a significant difference between how fast
     * the application buffers the data and how fast it is sent to the client. For a subscribing stream, bufferTime
     * specifies how long to buffer incoming data before starting to display the stream.
     */
    public function BufferingManagerProxy(initialBufferTime:Number, minExpandedBufferTime:Number,
                                          expandedBufferTime:Number, wrappedElement:MediaElement) {
        super(wrappedElement);

        this.initialBufferTime = initialBufferTime;
        this.expandedBufferTime = expandedBufferTime;
        this.minExpandedBufferTime = minExpandedBufferTime;

        logTimer = new Timer(4000);
        logTimer.addEventListener(TimerEvent.TIMER, onLogTimerEvent);

        var dispatcher:TraitEventDispatcher = new TraitEventDispatcher();
        dispatcher.media = wrappedElement;

        wrappedElement.addEventListener(MediaElementEvent.TRAIT_ADD, processTraitAdd);
        wrappedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, processTraitRemove);

        dispatcher.addEventListener(BufferEvent.BUFFERING_CHANGE, processBufferingChange);
        dispatcher.addEventListener(SeekEvent.SEEKING_CHANGE, processSeekingChange);
        dispatcher.addEventListener(PlayEvent.PLAY_STATE_CHANGE, processPlayStateChange);
    }

    private function onLogTimerEvent(event:TimerEvent):void {
        var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
        if (bufferTrait) {
            logger.debug("buffer state: length = {0}, time = {1}, buffering = {2}",
                    bufferTrait.bufferLength, bufferTrait.bufferTime, bufferTrait.buffering)
        }
    }

    private function processTraitAdd(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.BUFFER) {
            if (logger.debugEnabled) {
                logTimer.start();
            }

            // As soon as we can buffer, set the initial buffer time.
            bufferTime = initialBufferTime;
        }
    }

    private function processTraitRemove(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.BUFFER) {
            logTimer.reset();
        }
    }

    private function processBufferingChange(event:BufferEvent):void {
        var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
        if (!bufferTrait.buffering && playState == PlayState.PLAYING) {
            bufferTime = expandedBufferTime;
        }
    }

    private function processSeekingChange(event:SeekEvent):void {
        // Whenever we seek, reset our buffer time to the minimum so that
        // playback starts quickly after the seek.
        if(event.seeking) {
            // seek 0 seems to require more buffering so that play doesn't stagger
            if(event.time == 0) {
                bufferTime = minExpandedBufferTime;
            }
            else {
                bufferTime = initialBufferTime;
            }
        }
    }

    private function set bufferTime(time:Number):void {
        var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
        if (bufferTrait) {
            bufferTrait.bufferTime = time;
            logger.debug("buffer time set {0}", time);
        }
    }

    private function processPlayStateChange(event:PlayEvent):void {
        // Whenever we pause, reset our buffer time to the minimum so that
        // playback starts quickly after the unpause.
        if (event.playState == PlayState.PAUSED) {
            bufferTime = initialBufferTime;
        }
    }

    private function get playState():String {
        var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playTrait) {
            return playTrait.playState;
        }
        return null;
    }

    private var initialBufferTime:Number;
    private var expandedBufferTime:Number;
    private var minExpandedBufferTime:Number;
    private var logTimer:Timer;
}
}
