package com.seesaw.player.batchEventService.events {
import com.seesaw.player.batchEventService.events.maps.ContentEventMap;

import flash.events.*;

import org.osmf.media.MediaElement;

public class ContentEvent extends EventDispatcher {

    private var _storedEvents:Array;
    private var _proxiedElement:MediaElement;
    private var contentEventMap:ContentEventMap;
    private var _userEventCounter:int;
    private var _viewId:int;
    
    public function ContentEvent() {
        _storedEvents = new Array();
    }

    private function addEvent() {

       contentEventMap = new ContentEventMap(null, null, null, null, null, null, null, null, null, userEventCounter, null, null);
        _storedEvents.push(contentEventMap);

        if (_storedEvents.length >= 10) {

            dispatchEvent(new Event(EventTypes.MAX_REACHED));

        }

    }

    public function get storedEvents():Array {

        var eventData:Array = _storedEvents;
        _storedEvents = null;
        _storedEvents = new Array();
        return eventData;

    }

    public function set proxiedElement(value:MediaElement):void {
        _proxiedElement = value;
    }

    public function get viewId():int {
        return _viewId;
    }

    public function set viewId(value:int):void {
        _viewId = value;
    }

    public function set userEventCounter(value:int):void {
        _userEventCounter = value;
    }

    public function get userEventCounter():int {
        return _userEventCounter;
    }
}
}