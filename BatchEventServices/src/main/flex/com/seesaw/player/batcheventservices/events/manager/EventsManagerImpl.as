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

package com.seesaw.player.batcheventservices.events.manager {
import com.adobe.serialization.json.JSON;
import com.seesaw.player.batcheventservices.events.BatchEvent;
import com.seesaw.player.batcheventservices.events.ContentEvent;
import com.seesaw.player.batcheventservices.events.CumulativeDurationEvent;
import com.seesaw.player.batcheventservices.events.UserEvent;
import com.seesaw.player.batcheventservices.events.ViewEvent;
import com.seesaw.player.batcheventservices.services.LogAllFlushData;
import com.seesaw.player.utils.AjaxRequestType;
import com.seesaw.player.utils.ServiceRequest;
import com.seesaw.player.utils.SynchronousHTTPService;

import flash.net.URLVariables;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;

public class EventsManagerImpl implements EventsManager {
    private var logger:ILogger = LoggerFactory.getClassLogger(EventsManagerImpl);
    private var batchEventId:int = 0;
    private var userEventId:int = 0;

    private var userEventCount:int = 0;
    private var contentEventCount:int = 0;

    private var view:ViewEvent;
    private var userEvents:Array;
    private var contentEvents:Array;

    private var stashedUserEvents:Array;
    private var stashedContentEvents:Array;

    private var batchEventURL:String;
    private var cumlativeDurationURL:String;

    private var flushing:Boolean = false;
    private var allowEvent:Boolean = true;
    private var maxIsFlushing:Boolean = false;

    public function EventsManagerImpl(view:ViewEvent, previewMode:String, batchUrl:String, cumulativeUrl:String) {
        this.view = view;
        userEvents = new Array();
        contentEvents = new Array();
        if (previewMode == "true") {
            allowEvent = false;
        }
        batchEventURL = batchUrl;
        cumlativeDurationURL = cumulativeUrl;
    }

    private function onFailed():void {
        for each(var unstashedContentEvent:ContentEvent in stashedContentEvents) {
            contentEventCount++;
            contentEvents.push(unstashedContentEvent);
        }

        for each(var unstashedUserEvent:UserEvent in stashedUserEvents) {
            userEventCount++;
            contentEvents.push(unstashedUserEvent);
        }

        stashedUserEvents = [];
        stashedContentEvents = [];
    }

    private function onSuccess(response:Object):void {
        stashedUserEvents = userEvents;
        stashedContentEvents = contentEvents;
        maxIsFlushing = flushing = false;
    }


    public function addUserEvent(userEvent:UserEvent):void {
        if (userEvent) {
            userEventCount++;
            userEvents.push(userEvent);
            logUserEvent(userEvent);
            if (userEventCount >= 10) {
                if (!maxIsFlushing) {
                    maxIsFlushing = true;
                    flushAll();
                }
            }
        }
    }

    public function addContentEvent(contentEvent:ContentEvent):void {
        contentEventCount++;
        contentEvents.push(contentEvent);
        logContentEvent(contentEvent);
        if (contentEventCount >= 10) {
            if (!maxIsFlushing) {
                maxIsFlushing = true;
                flushAll();
            }
        }
    }

    private function logContentEvent(contentEvent:ContentEvent):void {
        logger.debug("-----------------------------------------------------------------");
        logger.debug("CONTENT EVENTS --- contentEventId: {0} -- currentAdBreakSequenceNumber: {1} -- contentViewingSequenceNumber: {2}  --  eventOccured: {3}  -- getSectionType: {4}  -- userEventId: {5} -- CVD: {6}",
               contentEvent.contentEventId,contentEvent.currentAdBreakSequenceNumber, contentEvent.contentViewingSequenceNumber, contentEvent.eventOccured, contentEvent.getSectionType, contentEvent.userEventId, contentEvent.getMainContentTimer);
        logger.debug("-----------------------------------------------------------------");
    }


    private function logUserEvent(userEvent:UserEvent):void {
        logger.debug("-----------------------------------------------------------------");
        logger.debug("USER EVENTS ----  EventType: {0}  -- Event Occured: {2}  -- userEventId: {3}  -- CVD: {1}", userEvent.getEventType, userEvent.getCulmulativeViewDuration, userEvent.getEventOccured, userEvent.getUserEventId)
        logger.debug(" -----------------------------------------------------------------");
    }

    public function flushAll():void {

        if (allowEvent && !flushing) {

            flushing = true;

            var eventsArray:Array = new Array(4);
            eventsArray[0] = view;
            eventsArray[1] = userEvents;
            eventsArray[2] = contentEvents;
            eventsArray[3] = new BatchEvent(userEventCount, incrementAndGetBatchEventId(), contentEventCount);

            stashedUserEvents = userEvents;
            stashedContentEvents = contentEvents;

            wipeEventRecords();

            var logAllFlushData:LogAllFlushData = new LogAllFlushData();
            logAllFlushData.logEvents(eventsArray);

            var request:ServiceRequest = new ServiceRequest(batchEventURL, onSuccess, onFailed);
            var post_data:URLVariables = new URLVariables();
            post_data.data = JSON.encode(eventsArray);
            request.submit(post_data);

        } else if (!allowEvent) {
            wipeEventRecords();
        }
    }


    private function wipeEventRecords():void {
        userEvents = [];
        contentEvents = [];
        userEventCount = 0;
        contentEventCount = 0;
    }

    public function flushExitEvent():void {
        if (allowEvent) {

            var eventsArray:Array = new Array(4);
            eventsArray[0] = view;
            eventsArray[1] = userEvents;
            eventsArray[2] = contentEvents;
            eventsArray[3] = new BatchEvent(userEventCount, incrementAndGetBatchEventId(), contentEventCount);

            var post_data:URLVariables = new URLVariables();
            post_data.data = JSON.encode(eventsArray);

            var paramStr:String = "";
            paramStr = "data=" + String(encodeURIComponent(post_data.data));

            var request:SynchronousHTTPService = new SynchronousHTTPService(batchEventURL + "&" + paramStr);
            request.requestType = AjaxRequestType.POST;
            request.async = false;
            request.send();
        }
    }

    private function incrementAndGetBatchEventId():int {
        batchEventId++;
        return batchEventId;
    }

    public function flushCumulativeDuration(cumulativeDuration:CumulativeDurationEvent):void {
        if (allowEvent) {
            var request:ServiceRequest = new ServiceRequest(cumlativeDurationURL, onCumulativeDurationSuccess, onCumulativeDurationFailed);
            var post_data:URLVariables = new URLVariables();
            post_data.data = JSON.encode(cumulativeDuration);
            request.submit(post_data);
        }
    }

    // There's no actual response sent as an argument for ServiceRequest failHandlers...
    private function onCumulativeDurationFailed(response:Object = null):void {
        trace("onCumulativeDurationFailed");
    }

    private function onCumulativeDurationSuccess(response:Object):void {
        trace("onCumulativeDurationSuccess");
    }
}
}
