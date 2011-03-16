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

package com.seesaw.player.ads {
import org.osmf.metadata.Metadata;

public class AdMetadata extends Metadata {

    public static const AD_NAMESPACE:String = "http://www.seesaw.com/player/ads/1.0";
    public static const AD_STATE:String = "adState";
    public static const AD_MODE:String = "adMode";
    public static const AD_BREAK_CUE:String = "adBreak";
    public static const AD_BREAKS:String = "adBreaks";
    public static const CLICK_THRU:String = "clickThru";
    public static const LR_AD_TYPE:String = "liverail";
    public static const SECTION_COUNT:String = "sectionCount";
    public static const AUDITUDE_AD_TYPE:String = "auditude";
    public static const CHANNEL_4_AD_TYPE:String = "channel4";
    public static const TRACK_BACK:String = "trackback";
    public static const POPUP_AD_URL:String = "popupAdvertisingUrl";
    public static const CURRENT_AD_BREAK:String = "currentAdBreak";

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

    public function get adMode():String {
        return getValue(AdMetadata.AD_MODE);
    }

    public function set adMode(mode:String):void {
        addValue(AdMetadata.AD_MODE, mode);
    }

    public function set currentAdBreak(adBreak:AdBreak):void {
        addValue(CURRENT_AD_BREAK, adBreak);
    }

    public function get currentAdBreak():AdBreak {
        return getValue(CURRENT_AD_BREAK);
    }

    public function getAdBreakWithTime(time:Number):AdBreak {
        var result:AdBreak = null;
        if (adBreaks && !isNaN(time)) {
            for each (var breakItem:AdBreak in adBreaks) {
                if (breakItem.startTime == time) {
                    result = breakItem;
                    break;
                }
            }
        }
        return result;
    }
}
}