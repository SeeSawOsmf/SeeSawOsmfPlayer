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
            logger.debug("\n")
            logger.debug(" ---------------------CONTENT EVENT---------------------------")
            logger.debug("contentEventId: {0}", contentEvent.contentEventId);
            logger.debug("currentAdBreakSequenceNumber: {0}", contentEvent.currentAdBreakSequenceNumber);
            logger.debug("contentViewingSequenceNumber: {0}", contentEvent.contentViewingSequenceNumber);
            logger.debug("eventOccured: {0}", contentEvent.eventOccured);
            logger.debug("getSectionType: {0}", contentEvent.getSectionType);
            logger.debug("userEventId: {0}", contentEvent.userEventId);
            logger.debug(" --------------------------------------------------------------")
            logger.debug("\n")
        }

        for each(var userEvent:UserEvent in eventsArray[1]) {
            logger.debug("\n")
            logger.debug(" ---------------------USER EVENT-------------------------------")
            logger.debug("EventType: {0}", userEvent.getEventType);
            logger.debug("CVD: {0}", userEvent.getCulmulativeViewDuration);
            logger.debug("Event Occured: {0}", userEvent.getEventOccured);
            logger.debug("userEventId: {0}", userEvent.getUserEventId);
            logger.debug(" ---------------------------------------------------------------")
            logger.debug("\n")
        }
        logger.debug("\n")
        logger.debug("\n")
        logger.debug("\n")

    }
}
}
