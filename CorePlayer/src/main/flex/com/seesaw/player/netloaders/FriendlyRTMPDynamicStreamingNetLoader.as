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
import com.seesaw.player.PlayerConstants;
import com.seesaw.player.events.BandwidthEvent;
import com.seesaw.player.netloaders.switchingrules.BandwidthTooLowRule;
import com.seesaw.player.utils.DynamicStreamingUtils;

import flash.events.NetStatusEvent;
import flash.events.TimerEvent;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.utils.Timer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.media.URLResource;
import org.osmf.net.DynamicStreamingResource;
import org.osmf.net.NetStreamSwitchManager;
import org.osmf.net.NetStreamSwitchManagerBase;
import org.osmf.net.SwitchingRuleBase;
import org.osmf.net.rtmpstreaming.DroppedFramesRule;
import org.osmf.net.rtmpstreaming.InsufficientBandwidthRule;
import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;
import org.osmf.net.rtmpstreaming.SufficientBandwidthRule;

public class FriendlyRTMPDynamicStreamingNetLoader extends RTMPDynamicStreamingNetLoader {

    private var logger:ILogger = LoggerFactory.getClassLogger(FriendlyRTMPDynamicStreamingNetLoader);

    private var rtmpMetrics:RTMPNetStreamMetrics;
    private var inInsufficientBandwidthState:Boolean;
    private var metricsTimer:Timer;

    public function FriendlyRTMPDynamicStreamingNetLoader() {
        metricsTimer = new Timer(1000);
        metricsTimer.addEventListener(TimerEvent.TIMER, onMetricsTimerEvent);
    }

    override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream {
        var netStream:NetStream = super.createNetStream(connection, resource);
        netStream.maxPauseBufferTime = PlayerConstants.PAUSE_BUFFER_TIME;

        connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamNetStatusEvent);
        netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamNetStatusEvent);

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
            logger.debug("bitrate: {0}", measuredBitrate);
            var requiredBitrate:Number = DynamicStreamingUtils.lowestBitrate(rtmpMetrics.resource.streamItems) * 1.15;
            var sufficientBandwidth:Boolean = measuredBitrate >= requiredBitrate;
            if (!sufficientBandwidth && !inInsufficientBandwidthState) {
                dispatchEvent(new BandwidthEvent(BandwidthEvent.BANDWITH_STATUS, false, false,
                        sufficientBandwidth, measuredBitrate, requiredBitrate));
                inInsufficientBandwidthState = true;
            }
            else if (sufficientBandwidth && inInsufficientBandwidthState) {
                dispatchEvent(new BandwidthEvent(BandwidthEvent.BANDWITH_STATUS, false, false,
                        sufficientBandwidth, measuredBitrate, requiredBitrate));
                inInsufficientBandwidthState = false;
            }
        }
    }

    private function getDefaultSwitchingRules(metrics:RTMPNetStreamMetrics):Vector.<SwitchingRuleBase> {
        var rules:Vector.<SwitchingRuleBase> = new Vector.<SwitchingRuleBase>();
        rules.push(new SufficientBandwidthRule(metrics));
        rules.push(new InsufficientBandwidthRule(metrics));
        rules.push(new BandwidthTooLowRule(metrics));
        rules.push(new DroppedFramesRule(metrics));
        // this rule switches all the way to the bottom which is not what we want
//        switchingrules.push(new InsufficientBufferRule(metrics, PlayerConstants.SHORT_BUFFER_TIME));
        return rules;
    }

// Internals
    //

    private function onNetStreamNetStatusEvent(event:NetStatusEvent):void {
        dispatchEvent(new NetStatusEvent(event.type, true, true, event.info));
    }
}
}
