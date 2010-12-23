package com.seesaw.player.batchEventService.events {
import flash.events.Event;
import flash.events.EventDispatcher;

import org.osmf.events.LoadEvent;
import org.osmf.events.LoaderEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitType;

public class ViewEvent extends EventDispatcher {
    
    private var _viewId:int;
    private var transactionItemId:int;
    private var serverTimeStamp:int;
    private var sectionCount:int;
    private var mainAssetId:int;
    private var _proxiedElement:MediaElement;

    public function ViewEvent(viewId:int, transactionItemId:int, serverTimeStamp:int, sectionCount:int, mainAssetId:int) {

        this._viewId = viewId;
        this.transactionItemId = transactionItemId;
        this.serverTimeStamp = serverTimeStamp;
        this.sectionCount = sectionCount;
        this.mainAssetId = mainAssetId;

    }

    public function get getServerTimeStamp():Number {
        return serverTimeStamp;
    }

    public function get getMainAssetId():int {
        return mainAssetId;
    }

    public function get getTransactionItemId():Number {
        return transactionItemId;
    }

    public function get getTransmitOccurred():Date {
        return new Date();
    }

    public function get getSectionCount():int {
        return sectionCount;
    }

       public function get viewId():int {
        return _viewId;
    }
    public function set proxiedElement(value:MediaElement):void {
        _proxiedElement = value;
        _proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
        _proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
        _proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
        _proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
    }

    private function onTraitAdd(event:MediaElementEvent):void {
        updateTraitListeners(event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        updateTraitListeners(event.traitType, false);
    }
     
        private function updateTraitListeners(traitType:String, add:Boolean):void {
        switch (traitType) {
            case MediaTraitType.LOAD:
                changeListeners(add, traitType, LoaderEvent.LOAD_STATE_CHANGE, onLoadStateChange);
                break;
        
        }
    }

    private function onLoadStateChange(event:LoadEvent):void {
        if(event.loadState == "ready"){
          dispatchEvent(new Event(EventTypes.FIRE_VIEW_EVENT));
          _proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
          _proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
          changeListeners(false, MediaTraitType.LOAD, LoaderEvent.LOAD_STATE_CHANGE, onLoadStateChange);
          _proxiedElement = null;
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
    
}
}