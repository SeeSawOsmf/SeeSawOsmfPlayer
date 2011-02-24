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

package com.seesaw.player {
public class PlayerConstants {
    public static const ID:String = "ID";
    public static const METADATA_NAMESPACE:String = "http://www.seesaw.com/player/1.0";
    public static const USEREVENTS_METADATA_NAMESPACE:String = "http://www.seesaw.com/userevents/1.0";
    public static const SMIL_METADATA_NS:String = "http://www.w3.org/ns/SMIL/metadata";
    public static const CONTROL_BAR_METADATA:String = "http://www.osmf.org/samples/controlbar/metadata";
    public static const CONTENT_INFO:String = "contentInfo";
    public static const USER_INFO:String = "userInfo";
    public static const CONTENT_ID:String = "contentId";
    public static const VIDEO_INFO:String = "videoInfo";
    public static const CONTENT_TYPE:String = "contentType";
    public static const SUBTITLE_LOCATION:String = "subtitleLocation";
    public static const DESTROY:String = "destroyPlayer";

    public static const MAIN_CONTENT_ID:String = "mainContent";
    public static const AD_CONTENT_ID:String = "advert";
    public static const STING_CONTENT_ID:String = "sting";
    public static const DOG_CONTENT_ID:String = "dogImage";

    public static const MAIN_CONTENT_DURATION:String = "mainContentDuration";

    public static const PROCEED_BUTTON_NAME:String = "PlayerStartButton.proceedButton";
    public static const GUIDANCE_PANEL_ACCEPT_BUTTON_NAME:String = "GuidancePanel.acceptButton";
    public static const GUIDANCE_PANEL_CANCEL_BUTTON_NAME:String = "GuidancePanel.cancelButton";

    public static const MIN_BUFFER_SIZE_SECONDS:Number = 0.05;
    public static const MAX_BUFFER_SIZE_SECONDS:Number = 40;
}
}