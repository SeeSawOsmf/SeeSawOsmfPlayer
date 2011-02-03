/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
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
 * Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 */

package com.seesaw.player.ads {
import org.osmf.metadata.Metadata;

public class AdMetadata extends Metadata {

    public static const AD_NAMESPACE:String = "http://www.seesaw.com/player/ads/1.0";
    public static const AD_STATE:String = "adState";
    public static const AD_BREAKS:String = "adBreaks";
    public static const CLICK_THRU:String = "clickThru";
    public static const LR_AD_TYPE:String = "liverail";
    public static const SECTION_COUNT:String = "sectionCount";
    public static const AUDITUDE_AD_TYPE:String = "auditude";
    public static const CHANNEL_4_AD_TYPE:String = "channel4";
    public static const TRACK_BACK:String = "trackback";

    public function get adState():* {
        return getValue(AdMetadata.AD_STATE);
    }

    public function set adState(adState:*):void {
        addValue(AdMetadata.AD_STATE, adState);
    }

    public function get adBreaks():Vector.<AdBreak> {
        return getValue(AdMetadata.AD_BREAKS) as Vector.<AdBreak>;
    }

    public function set adBreaks(adBreaks:Vector.<AdBreak>):void {
        addValue(AdMetadata.AD_BREAKS, adBreaks);
    }

    public function get clickThru():String {
        return getValue(AdMetadata.CLICK_THRU);
    }

    public function set clickThru(clickThru:String):void {
        addValue(AdMetadata.CLICK_THRU, clickThru);
    }


    public function get adMode():Boolean {
        return adState != AdState.AD_BREAK_COMPLETE;
    }
}
}