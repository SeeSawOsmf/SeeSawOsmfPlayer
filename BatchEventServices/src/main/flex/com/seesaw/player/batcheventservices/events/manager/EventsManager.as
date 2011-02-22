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
 * User: usaimbi
 * Date: 12/01/11
 * Time: 17:18
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.batcheventservices.events.manager {
import com.seesaw.player.batcheventservices.events.ContentEvent;
import com.seesaw.player.batcheventservices.events.CumulativeDurationEvent;
import com.seesaw.player.batcheventservices.events.UserEvent;

public interface EventsManager {

    function addUserEvent(userEvent:UserEvent):void;

    function addContentEvent(contentEvent:ContentEvent):void;

    function flushAll():void;

    function flushCumulativeDuration(cumulativeDuration:CumulativeDurationEvent):void;
}
}
