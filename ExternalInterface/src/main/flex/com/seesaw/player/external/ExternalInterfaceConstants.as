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

package com.seesaw.player.external {
public class ExternalInterfaceConstants {
    public static const RELOAD:String = "function(){location.reload(true)}";

    public static const LIGHTS_DOWN:String = "VODCO.ads.player.onPlayerLightsDown";
    public static const LIGHTS_UP:String = "VODCO.ads.player.onPlayerLightsUp";

    public static const GET_GUIDANCE:String = "getGuidance";
    public static const GET_CURRENT_ITEM_TITLE:String = "getCurrentItemTitle";
    public static const GET_CURRENT_ITEM_DURATION:String = "getCurrentItemDuration";

    public static const GET_ENTITLEMENT:String = "getEntitlement";

    public static const SHOW_DOG:String = "showDog";
    public static const HIDE_DOG:String = "hideDog";

    public static const SET_PLAYLIST:String = "setPlaylist";

    public static const SET_SWF_INIT:String = "VODCO.ads.player.setSWFInit";

    public static const BAYNOTE_VIDEO_TRACKER:String = "VODCO.ads.player.baynoteVideoTrack";
}
}
