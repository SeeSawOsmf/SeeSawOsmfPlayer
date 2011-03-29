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
 * Date: 29/03/11
 * Time: 14:55
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.netloaders.switchingrules {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.net.SwitchingRuleBase;
import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;

public class BandwidthTooLowRule extends SwitchingRuleBase {

    private var logger:ILogger = LoggerFactory.getClassLogger(BandwidthTooLowRule);

    private var bitrateMultiplier:Number;

    public function BandwidthTooLowRule(metrics:RTMPNetStreamMetrics, bitrateMultiplier:Number = 1.15) {
        super(metrics);

        this.bitrateMultiplier = bitrateMultiplier;
    }

    override public function getNewIndex():int {
        var newIndex:int = -1;
        if (rtmpMetrics.currentIndex > 0 && rtmpMetrics.averageMaxBytesPerSecond != 0) {
            if (rtmpMetrics.averageMaxBytesPerSecond * 8 / 1024 < rtmpMetrics.resource.streamItems[0].bitrate * bitrateMultiplier) {
                logger.debug("insufficient bandwidth, switching to {0}KBps", rtmpMetrics.resource.streamItems[0].bitrate);
                return 0;
            }
        }
        return newIndex;
    }

    private function get rtmpMetrics():RTMPNetStreamMetrics {
        return metrics as RTMPNetStreamMetrics;
    }
}
}
