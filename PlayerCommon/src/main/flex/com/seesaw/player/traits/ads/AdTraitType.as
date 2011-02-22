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

package com.seesaw.player.traits.ads {

/**
 * AdTraitType is the enumeration of all possible media trait types.
 *
 */
public final class AdTraitType {

    public static const LOAD:String = "load";

    public static const AD_PLAY:String = "adPlay";

    public static const SEEK:String = "seek";

    public static const TIME:String = "time";

    public static const PLAY_PAUSE:String = "playPause";

    public static const ALL_TYPES:Vector.<String> = Vector.<String>
            ([ PLAY_PAUSE
                , LOAD
                , AD_PLAY
                , SEEK
                , TIME
            ]);
}
}