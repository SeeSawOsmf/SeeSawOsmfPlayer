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
 * User: ibhana
 * Date: 08/02/11
 * Time: 09:39
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.ads {
import flash.events.Event;

public class AdBreakEvent extends Event {

    public static const AD_BREAK_TRIGGERED:String = "adBreakTriggered";
    public static const AD_BREAK_COMPLETED:String = "adBreakCompleted";

    private var _adBreak:AdBreak;

    public function AdBreakEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, adBreak:AdBreak = null) {
        super(type, bubbles, cancelable);
        _adBreak = adBreak;
    }

    public function get adBreak():AdBreak {
        return _adBreak;
    }

    override public function clone():Event {
        return new AdBreakEvent(type, bubbles, cancelable, adBreak);
    }
}
}
