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

package com.seesaw.player.ads.events {
import flash.events.Event;

public class AuditudeEvent extends Event {
    public static const INIT_COMPLETE:String = "initComplete";
    public static const INIT_ERROR:String = "initError";
    public static const PREROLL_COMPLETE:String = "prerollComplete";
    public static const POSTROLL_COMPLETE:String = "postrollComplete";
    public static const AD_START:String = "adStart";
    public static const AD_END:String = "adEnd";
    public static const CLICK_THRU:String = "clickThru";
    public static const VOLUME_CHANGE:String = "volumeChange";
    public static const MODULE_READY:String = "moduleReady";
    public static const ADMAP_READY:String = "adMapReady";
    public static const JSON_READY:String = "jsonReady";
    public static const HEARTBEAT:String = "mediaHeartbeat";
    public static const MEDIA_COMPLETE:String = "mediaComplete";
    public static const MEDIA_READY:String = "mediaReady";
    public static const MEDIA_DISCONNECT:String = "mediaDisconnect";
    public static const MEDIA_RESTART:String = "mediaRestart";
    public static const AD_PROGRESS:String = "adProgress";
    public static const AVAILABILITIES_FAILED:String = "availabilitiesFailed";
    public static const AD_BREAK_START:String = "adBreakStart";
    public static const AD_BREAK_COMPLETE:String = "adBreakComplete";

    public var data:Object;

    public function AuditudeEvent(type:String, _data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);

        data = _data;
    }

}
}
