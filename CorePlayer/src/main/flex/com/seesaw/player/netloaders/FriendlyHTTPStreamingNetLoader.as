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
 * Date: 25/03/11
 * Time: 15:20
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.netloaders {
import com.seesaw.player.PlayerConstants;
import com.seesaw.player.events.BandwidthEvent;
import com.seesaw.player.utils.DynamicStreamingUtils;

import flash.events.NetStatusEvent;
import flash.events.TimerEvent;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.utils.Timer;

import org.osmf.media.URLResource;
import org.osmf.net.DynamicStreamingResource;
import org.osmf.net.NetStreamSwitchManager;
import org.osmf.net.NetStreamSwitchManagerBase;
import org.osmf.net.SwitchingRuleBase;
import org.osmf.net.httpstreaming.DownloadRatioRule;
import org.osmf.net.httpstreaming.HTTPNetStream;
import org.osmf.net.httpstreaming.HTTPNetStreamMetrics;
import org.osmf.net.httpstreaming.HTTPStreamingNetLoader;
import org.osmf.net.rtmpstreaming.DroppedFramesRule;

public class FriendlyHTTPStreamingNetLoader extends HTTPStreamingNetLoader {

    private var httpMetrics:HTTPNetStreamMetrics;
    private var inInsufficientBandwidthState:Boolean;
    private var metricsTimer:Timer;

    public function FriendlyHTTPStreamingNetLoader() {
        super();

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
        // Only generate the switching manager if the resource is truly
        // switchable.
        if (dsResource != null) {
            httpMetrics = new HTTPNetStreamMetrics(netStream as HTTPNetStream);
            httpMetrics.resource = dsResource;
            metricsTimer.start();
            return new NetStreamSwitchManager(connection, netStream, dsResource, httpMetrics, getDefaultSwitchingRules(httpMetrics));
        }
        return null;
    }

    private function getDefaultSwitchingRules(metrics:HTTPNetStreamMetrics):Vector.<SwitchingRuleBase> {
        var rules:Vector.<SwitchingRuleBase> = new Vector.<SwitchingRuleBase>();
        rules.push(new DownloadRatioRule(metrics));
        rules.push(new DroppedFramesRule(metrics));
        return rules;
    }

    private function onMetricsTimerEvent(event:TimerEvent):void {
        var requiredBitrate:Number = DynamicStreamingUtils.lowestBitrate(httpMetrics.resource.streamItems);
        var downloadRatio:Number = httpMetrics.downloadRatio;
        if (downloadRatio > 0) {
            var sufficientBandwidth:Boolean = downloadRatio > 1.0;
            if (!sufficientBandwidth && !inInsufficientBandwidthState) {
                dispatchEvent(new BandwidthEvent(BandwidthEvent.BANDWITH_STATUS,
                        false, false, sufficientBandwidth, NaN, requiredBitrate, downloadRatio));
                inInsufficientBandwidthState = true;
            }
            else if (sufficientBandwidth && inInsufficientBandwidthState) {
                dispatchEvent(new BandwidthEvent(BandwidthEvent.BANDWITH_STATUS,
                        false, false, sufficientBandwidth, NaN, requiredBitrate, downloadRatio));
                inInsufficientBandwidthState = false;
            }
        }
    }

    private function onNetStreamNetStatusEvent(event:NetStatusEvent):void {
        dispatchEvent(new NetStatusEvent(event.type, true, true, event.info));
    }
}
}
