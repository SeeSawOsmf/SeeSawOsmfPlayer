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

/**
 * Created by IntelliJ IDEA.
 * User: bmeade
 * Date: 18/01/11
 * Time: 12:48

 */
package com.seesaw.player.netloaders {
import com.seesaw.player.PlayerConstants;

import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.NetStream;

import org.osmf.media.URLResource;
import org.osmf.net.DynamicStreamingResource;
import org.osmf.net.NetClient;
import org.osmf.net.NetStreamSwitchManager;
import org.osmf.net.NetStreamSwitchManagerBase;
import org.osmf.net.SwitchingRuleBase;
import org.osmf.net.rtmpstreaming.DroppedFramesRule;
import org.osmf.net.rtmpstreaming.InsufficientBandwidthRule;
import org.osmf.net.rtmpstreaming.InsufficientBufferRule;
import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;
import org.osmf.net.rtmpstreaming.SufficientBandwidthRule;

public class FriendlyRTMPDynamicStreamingNetLoader extends RTMPDynamicStreamingNetLoader {
    public function FriendlyRTMPDynamicStreamingNetLoader() {
    }

    override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream {
        var ns:NetStream = new NetStream(connection);
        ns.client = new NetClient();

        connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamNetStatusEvent);
        ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamNetStatusEvent);

        return ns;
    }


    override protected function createNetStreamSwitchManager(connection:NetConnection, netStream:NetStream, dsResource:DynamicStreamingResource):NetStreamSwitchManagerBase {
        if (dsResource != null) {
            var metrics:RTMPNetStreamMetrics = new RTMPNetStreamMetrics(netStream);
            return new NetStreamSwitchManager(connection, netStream, dsResource, metrics, getDefaultSwitchingRules(metrics));
        }
        return null;
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
