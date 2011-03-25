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

package com.seesaw.player.netloaders {
import com.seesaw.player.events.BandwidthEvent;

import flash.events.NetStatusEvent;
import flash.events.TimerEvent;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.utils.Timer;

import org.osmf.media.URLResource;
import org.osmf.net.DynamicStreamingItem;
import org.osmf.net.DynamicStreamingResource;
import org.osmf.net.NetClient;
import org.osmf.net.NetStreamSwitchManager;
import org.osmf.net.NetStreamSwitchManagerBase;
import org.osmf.net.SwitchingRuleBase;
import org.osmf.net.rtmpstreaming.DroppedFramesRule;
import org.osmf.net.rtmpstreaming.InsufficientBandwidthRule;
import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;
import org.osmf.net.rtmpstreaming.SufficientBandwidthRule;

public class FriendlyRTMPDynamicStreamingNetLoader extends RTMPDynamicStreamingNetLoader {

    private var rtmpMetrics:RTMPNetStreamMetrics;
    private var inInsufficientBandwidthState:Boolean;
    private var metricsTimer:Timer;

    public function FriendlyRTMPDynamicStreamingNetLoader() {
    }

    override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream {
        var netStream:NetStream = new NetStream(connection);

        var netClient:NetClient = new NetClient();
        netStream.client = netClient;

        connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamNetStatusEvent);
        netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamNetStatusEvent);

        metricsTimer = new Timer(1000);
        metricsTimer.addEventListener(TimerEvent.TIMER, onMetricsTimerEvent);

        return netStream;
    }

    override protected function createNetStreamSwitchManager(connection:NetConnection, netStream:NetStream, dsResource:DynamicStreamingResource):NetStreamSwitchManagerBase {
        if (dsResource != null) {
            rtmpMetrics = new RTMPNetStreamMetrics(netStream);
            metricsTimer.start();
            return new NetStreamSwitchManager(connection, netStream, dsResource, rtmpMetrics, getDefaultSwitchingRules(rtmpMetrics));
        }
        return null;
    }

    private function onMetricsTimerEvent(event:TimerEvent):void {
        var measuredBitrate:Number = rtmpMetrics.averageMaxBytesPerSecond * 8 / 1024;
        if (measuredBitrate > 0) {
            var requiredBitrate:Number = getLowestSupportedBitrate();
            var insufficientBandwidth:Boolean = measuredBitrate < requiredBitrate;
            if (insufficientBandwidth && !inInsufficientBandwidthState) {
                dispatchEvent(new BandwidthEvent(BandwidthEvent.BANDWITH_STATUS, false, false, measuredBitrate, requiredBitrate));
                inInsufficientBandwidthState = true;
            }
            else if (!insufficientBandwidth && inInsufficientBandwidthState) {
                dispatchEvent(new BandwidthEvent(BandwidthEvent.BANDWITH_STATUS, false, false, measuredBitrate, requiredBitrate));
                inInsufficientBandwidthState = false;
            }
        }
    }

    private function getLowestSupportedBitrate():Number {
        var bitrate:Number = Number.MAX_VALUE;
        for each(var item:DynamicStreamingItem in rtmpMetrics.resource.streamItems) {
            if (item.bitrate < bitrate)
                bitrate = item.bitrate;
        }
        return bitrate;
    }

    private function getDefaultSwitchingRules(metrics:RTMPNetStreamMetrics):Vector.<SwitchingRuleBase> {
        var rules:Vector.<SwitchingRuleBase> = new Vector.<SwitchingRuleBase>();
        rules.push(new SufficientBandwidthRule(metrics));
        rules.push(new InsufficientBandwidthRule(metrics));
        rules.push(new DroppedFramesRule(metrics));
        // We grow the buffer dynamically from a very small size which seems to conflict with this rule
//        rules.push(new InsufficientBufferRule(metrics, PlayerConstants.MIN_BUFFER_SIZE_SECONDS));
        return rules;
    }

// Internals
    //

    private function onNetStreamNetStatusEvent(event:NetStatusEvent):void {
        dispatchEvent(new NetStatusEvent(event.type, true, true, event.info));
    }
}
}
