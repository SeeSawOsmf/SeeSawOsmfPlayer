package com.seesaw.proxyplugin {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.SeekEvent;
import org.osmf.events.TimeEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class DefaultProxyElement extends ProxyElement {


    private var logger:ILogger = LoggerFactory.getClassLogger(DefaultProxyElement);

    public function DefaultProxyElement() {
        logger.debug("Initialising DefaultProxyElement");
    }


    override public function set proxiedElement(value:MediaElement):void {
        super.proxiedElement = value;

        var traitType:String

        if (value != null) {
            // Clear our old listeners.
            value.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            value.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

            for each (traitType in value.traitTypes) {
                processTrait(traitType, false);
            }
        }


        if (value != null) {
            // Listen for traits being added and removed.
            value.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            value.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

            for each (traitType in value.traitTypes) {
                processTrait(traitType, true);
            }
        }


    }


    private function onTraitAdd(event:MediaElementEvent):void {
        processTrait(event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        processTrait(event.traitType, false);
    }

    private function processTrait(traitType:String, added:Boolean):void {
        switch (traitType) {

            case MediaTraitType.LOAD:
                toggleLoadListeners(added);
                break;

            case MediaTraitType.SEEK:
                toggleSeekListeners(added);
                break;

            case MediaTraitType.TIME:
                toggleTimeListeners(added);
                break;

        }
    }


    private function toggleLoadListeners(added:Boolean):void {
        var loadable:LoadTrait = proxiedElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
        if (loadable) {
            if (added) {
                loadable.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadableStateChange);
                loadable.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);

            }
            else {
                loadable.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadableStateChange);
                loadable.removeEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);
            }
        }
    }

    private function onBytesTotalChange(event:LoadEvent):void {
        logger.debug("Load onBytesTotal change:{0}", event.bytes);
    }

    private function onLoadableStateChange(event:LoadEvent):void {
        logger.debug("Load state change:{0}", event.loadState);
    }


    private function toggleTimeListeners(added:Boolean):void {
        var time:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;

        if (time) {
            time.addEventListener(TimeEvent.DURATION_CHANGE, onTimeChange);
        } else {
            time.removeEventListener(TimeEvent.DURATION_CHANGE, onTimeChange);
        }
    }


    private function toggleSeekListeners(added:Boolean):void {
        var seek:SeekTrait = proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;

        if (seek) {
            seek.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
        } else {
            seek.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
        }
    }

    private function onSeekingChange(event:SeekEvent):void {
        logger.debug("On Seek Change:{0}", event.seeking);
        var time:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;
        logger.debug(String(time.currentTime));
    }

    private function onTimeChange(event:TimeEvent):void {
        logger.debug("Time Change:  ", event.time);
    }

    /* static */

    private static const ID:String = "DEFAULT_PROXY_ID";
}
}