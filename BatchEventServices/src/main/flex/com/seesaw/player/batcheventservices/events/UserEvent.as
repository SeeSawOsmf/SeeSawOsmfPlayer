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

public class UserEvent {

    private var userEventId:int;
    private var cumulativeViewDuration:int;
    private var eventType:String;
    private var _programmeId:int;
    private var eventOccured:Date;

    public function UserEvent(userEventId:int, cumulativeViewDuration:int, eventType:String, programmeId:int) {
        this._programmeId = programmeId;
        this.userEventId = userEventId;
        this.cumulativeViewDuration = cumulativeViewDuration;
        this.eventType = eventType;
        this.eventOccured = new Date();
    }

    public function get getUserEventId():int {
        return userEventId;
    }

    public function get getCulmulativeViewDuration():int {
        return cumulativeViewDuration;
    }

    public function get getEventType():String {
        return eventType;
    }

    public function get getEventOccured():Date {
        return eventOccured;
    }

    public function get getProgrammeId():int {
        return _programmeId;
    }
}
}
