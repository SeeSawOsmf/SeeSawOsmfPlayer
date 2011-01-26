/**
 * Created by IntelliJ IDEA.
 * User: usaimbi
 * Date: 12/01/11
 * Time: 17:19
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.batchEventService.events.manager {
import com.adobe.serialization.json.JSON;
import com.seesaw.player.batchEventService.events.BatchEvent;
import com.seesaw.player.batchEventService.events.ContentEvent;
import com.seesaw.player.batchEventService.events.CumulativeDurationEvent;
import com.seesaw.player.batchEventService.events.UserEvent;
import com.seesaw.player.batchEventService.events.ViewEvent;
import com.seesaw.player.utils.ServiceRequest;

import flash.net.URLVariables;

public class EventsManagerImpl implements EventsManager {

    private var batchEventId:int = 0;
    private var userEventId:int = 0;

    private var userEventCount:int = 0;
    private var contentEventCount:int = 0;

    private var view:ViewEvent;
    private var userEvents:Array;
    private var contentEvents:Array;

    // TODO Upkar - remove hardcoded URLS
    private var batchEventURL:String = "http://localhost:8080/player.videoplayer:registerbatchevent?t:ac=TV:COMEDY/b/8542/Nathan-Barley";
    private var cumlativeDurationURL:String = "http://localhost:8080/player.videoplayer:playIntervalEvent?t:ac=TV:COMEDY/b/8542/Nathan-Barley";

    private var flushing:Boolean = false;
    private var allowEvent:Boolean = true;

    public function EventsManagerImpl(view:ViewEvent, availabilityType:String, batchUrl:String, cumulativeUrl:String) {
        this.view = view;
        userEvents = new Array();
        contentEvents = new Array();
        if (availabilityType == "PREVIEW") {
            allowEvent = false;
        }
    }

    private function onFailed():void {
        trace("onFailed")
    }

    private function onSuccess(response:Object):void {
        userEvents = [];
        contentEvents = [];
        userEventCount = 0;
        contentEventCount = 0;
        flushing = false;
    }


    public function addUserEvent(userEvent:UserEvent):void {
        userEventCount++;
        userEvents.push(userEvent);
        if (userEventCount >= 10) {
            flushAll();
        }
    }

    public function addContentEvent(contentEvent:ContentEvent):void {
        contentEventCount++;
        contentEvents.push(contentEvent);
        if (contentEventCount >= 10) {
            flushAll();
        }
    }

    public function flushAll():void {

        if (allowEvent) {

            flushing = true;

            var eventsArray:Array = new Array(4);
            eventsArray[0] = view;
            eventsArray[1] = userEvents;
            eventsArray[2] = contentEvents;
            eventsArray[3] = new BatchEvent(userEventCount, incrementAndGetBatchEventId(), contentEventCount);

            var request:ServiceRequest = new ServiceRequest(batchEventURL, onSuccess, onFailed);
            var post_data:URLVariables = new URLVariables();
            post_data.data = JSON.encode(eventsArray);
            request.submit(post_data);
        }else{
            userEvents = [];
            contentEvents = [];
            userEventCount = 0;
            contentEventCount = 0;
        }
    }

    private function incrementAndGetBatchEventId():int {
        batchEventId++;
        return batchEventId;
    }

    public function flushCumulativeDuration(cumulativeDuration:CumulativeDurationEvent):void {
        var request:ServiceRequest = new ServiceRequest(cumlativeDurationURL, onCumulativeDurationSuccess, onCumulativeDurationFailed);
        var post_data:URLVariables = new URLVariables();
        post_data.data = JSON.encode(cumulativeDuration);
        request.submit(post_data);
        flushAll();
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
