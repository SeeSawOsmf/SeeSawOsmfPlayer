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
import com.seesaw.player.events.BandwidthEvent;
import com.seesaw.player.events.QoSManagerEvent;

import flash.events.NetStatusEvent;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.BufferEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.net.NetStreamCodes;
import org.osmf.traits.BufferTrait;
import org.osmf.traits.DynamicStreamTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.TraitEventDispatcher;

public class QoSManagerProxy extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(QoSManagerProxy);

    public function QoSManagerProxy(initialBufferTime:Number, expandedBufferTime:Number, wrappedElement:MediaElement, factory:MediaFactory) {
        super(wrappedElement);

        this.initialBufferTime = initialBufferTime;
        this.expandedBufferTime = expandedBufferTime;

        factory.addEventListener(BandwidthEvent.BANDWITH_STATUS, onBandwidthStatus);
        factory.addEventListener(NetStatusEvent.NET_STATUS, netStatusChanged);

        var dispatcher:TraitEventDispatcher = new TraitEventDispatcher();
        dispatcher.media = wrappedElement;

        wrappedElement.addEventListener(MediaElementEvent.TRAIT_ADD, processTraitAdd);
        dispatcher.addEventListener(BufferEvent.BUFFERING_CHANGE, processBufferingChange);
        dispatcher.addEventListener(SeekEvent.SEEKING_CHANGE, processSeekingChange);
        dispatcher.addEventListener(PlayEvent.PLAY_STATE_CHANGE, processPlayStateChange);
    }

    private function processTraitAdd(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.BUFFER) {
            // As soon as we can buffer, set the initial buffer time.
            var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
            bufferTrait.bufferTime = initialBufferTime;
        }
    }

    private function onBandwidthStatus(event:BandwidthEvent):void {
        _sufficientBandwidth = event.sufficientBandwidth;
        logger.debug("CONNECTION TOO SLOW: {0}", !_sufficientBandwidth);

        if (!_sufficientBandwidth) {
            var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;

            // TODO: we may need to set the buffer time to the expanded value here

            // If this comes in while we are buffering set the expanded time and notify
            if(bufferTrait && bufferTrait.buffering && bufferTrait.bufferTime - bufferTrait.bufferLength > 5) {
                dispatchEvent(new QoSManagerEvent(QoSManagerEvent.CONNECTION_STATUS,
                        false, false, true, bufferTrait.bufferTime, bufferTrait.bufferLength));
            }
        }
    }

    private function processBufferingChange(event:BufferEvent = null):void {
        var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
        var oldTime:Number = bufferTrait.bufferTime;

        if (sufficientBandwidth) {
            // If the bandwidth is ok and we're buffering again increase the initial buffer
            bufferTrait.bufferTime = bufferTrait.buffering ? initialBufferTime : expandedBufferTime;
            // Connection is never too slow in this case so ensure the message gets through
            dispatchEvent(new QoSManagerEvent(QoSManagerEvent.CONNECTION_STATUS,
                    false, false, false, bufferTrait.bufferTime, bufferTrait.bufferLength));
        }
        else {
            bufferTrait.bufferTime = expandedBufferTime;

            // Connection is too slow but we only want to show the message while the video has stopped/buffering
            if (bufferTrait.buffering) {
                dispatchEvent(new QoSManagerEvent(QoSManagerEvent.CONNECTION_STATUS,
                        false, false, true, bufferTrait.bufferTime, bufferTrait.bufferLength));
            } else {
                dispatchEvent(new QoSManagerEvent(QoSManagerEvent.CONNECTION_STATUS,
                        false, false, false, bufferTrait.bufferTime, bufferTrait.bufferLength));
            }
        }

        logger.debug("buffering: {0}, new time = {1}, old time = {2}",
                bufferTrait.buffering, bufferTrait.bufferTime, oldTime);
    }

    private function processSeekingChange(event:SeekEvent):void {
        // Whenever we seek, reset our buffer time to the minimum so that
        // playback starts quickly after the seek.
        if (event.seeking == true) {
            var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
            bufferTrait.bufferTime = sufficientBandwidth ? initialBufferTime : expandedBufferTime;
        }
    }

    private function processPlayStateChange(event:PlayEvent):void {
        // Whenever we pause, reset our buffer time to the minimum so that
        // playback starts quickly after the unpause.
        if (event.playState == PlayState.PAUSED) {
            var bufferTrait:BufferTrait = getTrait(MediaTraitType.BUFFER) as BufferTrait;
            bufferTrait.bufferTime = sufficientBandwidth ? initialBufferTime : expandedBufferTime;
        }
    }

    // Annoyingly osmf will not always notify us of the buffer being full in the case of HTTP streaming so
    // we need to go under it
    private function netStatusChanged(event:NetStatusEvent):void {
        if (event.info == NetStreamCodes.NETSTREAM_BUFFER_FULL) {
            processBufferingChange();
        }
    }

    public function get sufficientBandwidth():Boolean {
        return _sufficientBandwidth;
    }

    private var _sufficientBandwidth:Boolean = true;
    private var initialBufferTime:Number;
    private var expandedBufferTime:Number;
}
}
