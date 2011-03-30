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

/**
 * Created by IntelliJ IDEA.
 * User: ibhana
 * Date: 30/03/11
 * Time: 08:32
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player {
import com.seesaw.player.buffering.QoSManagerProxy;
import com.seesaw.player.events.BandwidthEvent;
import com.seesaw.player.events.QoSManagerEvent;

import org.hamcrest.assertThat;
import org.hamcrest.object.equalTo;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayTrait;
import org.osmf.utils.DynamicBufferTrait;
import org.osmf.utils.DynamicMediaElement;
import org.osmf.utils.DynamicPlayTrait;
import org.osmf.utils.DynamicSeekTrait;
import org.osmf.utils.DynamicTimeTrait;

public class QosManagerProxyTest {

    private static const SHORT_BUFFER:Number = 0.5;
    private static const LONG_BUFFER:Number = 30;

    private var element:DynamicMediaElement;
    private var factory:MockMediaFactory;
    private var qosManager:QoSManagerProxy;
    private var bufferTrait:DynamicBufferTrait;
    private var seekTrait:DynamicSeekTrait;
    private var timeTrait:DynamicTimeTrait;
    private var playTrait:DynamicPlayTrait;

    [Before]
    public function runBeforeAllTests():void {
        factory = new MockMediaFactory();

        element = new DynamicMediaElement();

        bufferTrait = new DynamicBufferTrait();
        bufferTrait.bufferTime = SHORT_BUFFER;
        bufferTrait.bufferLength = 0;
        element.doAddTrait(MediaTraitType.BUFFER, bufferTrait);

        timeTrait = new DynamicTimeTrait();
        timeTrait.currentTime = 0;
        timeTrait.duration = 100;
        element.doAddTrait(MediaTraitType.TIME, timeTrait);

        seekTrait = new DynamicSeekTrait(timeTrait);
        element.doAddTrait(MediaTraitType.SEEK, seekTrait);

        playTrait = new DynamicPlayTrait();
        element.doAddTrait(MediaTraitType.PLAY, playTrait);

        qosManager = new QoSManagerProxy(SHORT_BUFFER, LONG_BUFFER, element, factory);
    }

    [Test]
    public function longBufferSetOnSlowConnection():void {
        doBandwidthLow();

        // go into buffering state
        bufferTrait.buffering = true;

        assertThat(bufferTrait.bufferTime, equalTo(LONG_BUFFER));
    }

    [Test]
    public function shortBufferSetOnGoodConnection():void {
        doBandwidthOk();

        // go into buffering state
        bufferTrait.buffering = true;

        assertThat(bufferTrait.bufferTime, equalTo(SHORT_BUFFER));
    }

    [Test]
    public function shortBufferAfterSeekOnGoodConnection():void {
        doBandwidthOk();

        seekTrait.seek(50);

        assertThat(bufferTrait.bufferTime, equalTo(SHORT_BUFFER));
    }

    [Test]
    public function longBufferAfterSeekOnSlowConnection():void {
        doBandwidthLow();

        seekTrait.seek(50);

        assertThat(bufferTrait.bufferTime, equalTo(LONG_BUFFER));
    }

    [Test]
    public function shortBufferAfterPauseOnGoodConnection():void {
        doBandwidthOk();

        playTrait.pause();

        assertThat(bufferTrait.bufferTime, equalTo(SHORT_BUFFER));
    }

    [Test]
    public function longBufferAfterPauseOnSlowConnection():void {
        doBandwidthLow();

        playTrait.pause();

        assertThat(bufferTrait.bufferTime, equalTo(LONG_BUFFER));
    }

    [Test]
    public function notifiesWhenConnectionIsTooSlowWhenBuffering():void {
        var connectionTooSlow:Boolean = false;

        function onConnectionStatus(e:QoSManagerEvent):void {
            connectionTooSlow = e.connectionTooSlow;
        }

        qosManager.addEventListener(QoSManagerEvent.CONNECTION_STATUS, onConnectionStatus);

        doBandwidthLow();

        // this will increase the buffer to the long size
        bufferTrait.buffering = true;

        assertThat(connectionTooSlow, equalTo(true));
        assertThat(bufferTrait.bufferTime, equalTo(LONG_BUFFER));

        qosManager.removeEventListener(QoSManagerEvent.CONNECTION_STATUS, onConnectionStatus);
    }

    [Test]
    public function notifiesWhenConnectionIsTooSlowDuringBuffering():void {
        var connectionTooSlow:Boolean = false;

        function onConnectionStatus(e:QoSManagerEvent):void {
            connectionTooSlow = e.connectionTooSlow;
        }

        qosManager.addEventListener(QoSManagerEvent.CONNECTION_STATUS, onConnectionStatus);

        bufferTrait.bufferTime = SHORT_BUFFER;
        bufferTrait.bufferLength = 0;

        // this will increase the buffer to the long size
        bufferTrait.buffering = true;

        doBandwidthLow();

        assertThat(connectionTooSlow, equalTo(true));
        assertThat(bufferTrait.bufferTime, equalTo(LONG_BUFFER));

        qosManager.removeEventListener(QoSManagerEvent.CONNECTION_STATUS, onConnectionStatus);
    }

    private function doBandwidthOk():void {
        factory.dispatchEvent(new BandwidthEvent(BandwidthEvent.BANDWITH_STATUS, false, false,
                true, 600, 500));
    }

    private function doBandwidthLow():void {
        factory.dispatchEvent(new BandwidthEvent(BandwidthEvent.BANDWITH_STATUS, false, false,
                false, 490, 500));
    }

    public function QosManagerProxyTest() {
    }
}
}
