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
public class BatchEvent {

    private var userEventCount:int;
    private var batchEventId:int;
    private var contentEventCount:int;

    public function BatchEvent(userEventCount:int, batchEventId:int, contentEventCount:int) {
        this.userEventCount = userEventCount;
        this.batchEventId = batchEventId;
        this.contentEventCount = contentEventCount;
    }

    public function get getuserEventCount():int {
        return userEventCount;
    }

    public function get getBatchEventId():int {
        return batchEventId;
    }

    public function get geteventOccured():Date {
        return new Date();
    }

    public function get getcontentEventCount():int {
        return contentEventCount;
    }
}
}