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

package com.seesaw.player.batcheventservices.events {
public class UserEventTypes {
    /** Occurs when the play starts the first time. Marks the start of this view */
    public static const AUTO_PLAY:String = "AUTO_PLAY";
    /** Occurs when the play starts in the auto resume mode*/
    public static const AUTO_RESUME:String = "AUTO_RESUME";
    /** Occurs when play occurs following a pause or a scrub */
    public static const PLAY:String = "PLAY";
    /** Occurs when a play is paused */
    public static const PAUSE:String = "PAUSE";
    /** Occurs on time seek using the scrub bar. This event fires at the time
     *  code you seeked from. A play will follow from the time you seeked to.*/
    public static const SCRUB:String = "SCRUB";
    /** Occurs on player exit */
    public static const EXIT:String = "EXIT";
    /** Occurs on play end (as end board is displayed). Marks end of this view. */
    public static const END:String = "END";
    /** Occurs when a users click the timeline. */
    public static const CLICK:String = "CLICK";
    /**WHEN CHANGING DEFINITION*/
    public static const STREAM_CHANGE:String = "STREAM_CHANGE";

    public static const DYNAMIC_STREAM_CHANGE:String = "DYNAMIC_STREAM_CHANGE";
    /** Occurs every GlobalStaticVariables.CUMULATIVE_DURATION_THRESHOLD of playback time */

    public static const CUMULATIVE_DURATION:String = "CUMULATIVE_DURATION";

    public static const ENTER_FULL_SCREEN:String = "ENTER_FULL_SCREEN";
    public static const EXIT_FULL_SCREEN:String = "EXIT_FULL_SCREEN";

    public static const CONNECTION_CLOSED:String = "CONNECTION_CLOSED";
    public static const CONNECTION_RESTART:String = "CONNECTION_RESTART";

    public static const BUFFERING:String = "BUFFERING";
    public static const SUBTITLES_ON:String = "SUBTITLES_ON";
    public static const SUBTITLES_OFF:String = "SUBTITLES_OFF";

     public static const USER_SCRUB_ACTIVATED:String = "userScrubActivated";
}
}