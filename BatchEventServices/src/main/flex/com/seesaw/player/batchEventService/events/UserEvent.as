package com.seesaw.player.batchEventService.events {
import com.seesaw.player.batchEventService.events.maps.UserEventMap;

import flash.events.Event;
import flash.events.EventDispatcher;

import org.osmf.events.MediaElementEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
import org.osmf.events.TimeEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class UserEvent extends EventDispatcher {

    private var _storedEvents:Array;
    private var _proxiedElement:MediaElement;
    private var userEventMap:UserEventMap;
    private var _userEventCounter:int;
    private var _viewId:int;

    private var seekTrait:SeekTrait;
    private var playTrait:PlayTrait;
    private var timeTrait:TimeTrait;
    private var seeking:Boolean;
    private var seekTime:Number;

    
    public function UserEvent() {
        _storedEvents = new Array();
    }


    private function addEvent() {

        _userEventCounter++;
        dispatchEvent(new Event(EventTypes.USER_EVENT_FIRED));
        
        userEventMap = new UserEventMap();
        _storedEvents.push(userEventMap);

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
        _proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
        _proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
        _proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
        _proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
    }

      private function onDurationChange(event:TimeEvent):void {

    }

    private function onSeekingChange(event:SeekEvent):void {
        seeking = event.seeking;
        seekTime = event.time;
    }

    private function onComplete(event:TimeEvent):void {

    }

    private function onPlayStateChanged(event:PlayEvent):void {
        switch (event.playState) {
            case PlayState.PAUSED:

                trace("paused");
                break;
            case PlayState.PLAYING:
              
                break;
            case PlayState.STOPPED:

                break;
        }
    }



    private function onTraitAdd(event:MediaElementEvent):void {
        updateTraitListeners(event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        updateTraitListeners(event.traitType, false);
    }

    private function updateTraitListeners(traitType:String, add:Boolean):void {
        switch (traitType) {
            case MediaTraitType.SEEK:
                changeListeners(add, traitType, SeekEvent.SEEKING_CHANGE, onSeekingChange);
                seekTrait = _proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
                break;
            case MediaTraitType.PLAY:
                changeListeners(add, traitType, PlayEvent.PLAY_STATE_CHANGE, onPlayStateChanged);
                playTrait = _proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
                break;
            case MediaTraitType.TIME:
                changeListeners(add, traitType, TimeEvent.COMPLETE, onComplete);
                changeListeners(add, traitType, TimeEvent.DURATION_CHANGE, onDurationChange);
                timeTrait = _proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;
                break;
        }
    }

    private function changeListeners(add:Boolean, traitType:String, event:String, listener:Function):void {
        if (add) {
            _proxiedElement.getTrait(traitType).addEventListener(event, listener);
        }
        else if (_proxiedElement.hasTrait(traitType)) {
            _proxiedElement.getTrait(traitType).removeEventListener(event, listener);
        }
    }

    public function set viewId(value:int):void {
        _viewId = value;
    }

    public function get viewId():int {
        return _viewId;
    }

    public function get userEventCounter():int {
        return _userEventCounter;
    }
}
}