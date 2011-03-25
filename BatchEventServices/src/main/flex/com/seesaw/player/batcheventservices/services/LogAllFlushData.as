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
package com.seesaw.player.batcheventservices.services {
import com.seesaw.player.batcheventservices.events.ContentEvent;
import com.seesaw.player.batcheventservices.events.UserEvent;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;

public class LogAllFlushData {

    private var logger:ILogger = LoggerFactory.getClassLogger(LogAllFlushData);


    public function LogAllFlushData() {
    }

    public function logEvents(eventsArray:Array):void {

        logger.debug(" -----------------------------------------------------------------")
        logger.debug("FLUSHING EVENTS")
        logger.debug(" -----------------------------------------------------------------")
        for each(var contentEvent:ContentEvent in eventsArray[2]) {
            logger.debug("CONTENT EVENTS --- contentEventId: {0} -- currentAdBreakSequenceNumber: {1} -- contentViewingSequenceNumber: {2}  --  eventOccured: {3}  -- getSectionType: {4}  -- userEventId: {5}",
                    contentEvent.contentEventId, contentEvent.currentAdBreakSequenceNumber, contentEvent.contentViewingSequenceNumber, contentEvent.eventOccured, contentEvent.getSectionType, contentEvent.userEventId);
            logger.debug("-----------------------------------------------------------------")
        }

        for each(var userEvent:UserEvent in eventsArray[1]) {
            logger.debug("USER EVENTS ----  EventType: {0}  -- CVD: {1}  -- Event Occured: {2}  -- userEventId: {3}", userEvent.getEventType, userEvent.getCulmulativeViewDuration, userEvent.getEventOccured, userEvent.getUserEventId)
            logger.debug("-----------------------------------------------------------------")
        }

    }

}
}