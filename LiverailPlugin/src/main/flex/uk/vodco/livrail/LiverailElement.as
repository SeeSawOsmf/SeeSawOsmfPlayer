package uk.vodco.livrail {
import flash.system.Security;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ParallelElement;
import org.osmf.elements.ProxyElement;
import org.osmf.elements.SWFElement;
import org.osmf.events.DisplayObjectEvent;
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.SeekEvent;
import org.osmf.media.MediaElement;
import org.osmf.media.URLResource;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.SeekTrait;

public class LiverailElement extends ProxyElement {


    public static var TYPE:String = "LIVERAIL_INTERFACE";


    private var modLoaded:Boolean = false;

    private var liveRailModuleLocation:String;

    private var _adManager:*;

    public var contentInfo:XML;

    private var liveRailAdMap:String = "";

    private var liveRailTags:String = "";


    private var videoId:String;


    private var liveRailConfig:Object;


    public var contentObject:Object;

    public var adPlaying:Boolean = false;

    public var currentAdCount:int = 0;

    public var adSlots:int = 0;

    private var availabilities:Array = [];

    private var _adPositions:Array = [];

    private var _totalAdPositions:Array = [];

    private var adsEncountered:Array = [];

    private var ageRating:int;

    public var genres:Array;
    public var liverailVersion:String;
    public var liverailPublisherId:String;
    public var programmeId:Number;

    //use a small offset to go back so that we show an ad when resuming at it, instead of skipping it by mistake
    private var _seekOffset:Number = 0.5;
    private var LR_AdvertsArray:Array;
    private var logger:ILogger = LoggerFactory.getClassLogger(LiverailElement);

    public function LiverailElement() {
        logger.debug("Initialising LiverailElement");
        Security.allowDomain("vox-static.liverail.com");
        var liverailPath:String = "http://vox-static.liverail.com/swf/v4/skins/adplayerskin_1.swf";
        var urlResource:URLResource = new URLResource(liverailPath)
        var element:ParallelElement = new SWFElement(urlResource) as ParallelElement;

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

            case MediaTraitType.DISPLAY_OBJECT:
                toggleDisplayListeners(added);
                break;

        }
    }


    private function toggleDisplayListeners(added:Boolean):void {
        var display:DisplayObjectTrait = proxiedElement.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;

        if (display) {
            display.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onDisplayObjectChange);
            display.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
        } else {
            display.removeEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onDisplayObjectChange);
            display.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
        }
    }

    private function onMediaSizeChange(event:DisplayObjectEvent):void {
        trace("On Media Size Change old:{0}x{1} new:{2}x{3}", event.oldHeight, event.oldWidth, event.newHeight, event.newWidth);
    }

    private function onDisplayObjectChange(event:DisplayObjectEvent):void {
        trace("On Display Object Change old:{0} new:{1}", event.oldDisplayObject, event.newDisplayObject)
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
        trace("Load onBytesTotal change:{0}", event.bytes);
    }

    private function onLoadableStateChange(event:LoadEvent):void {
        trace("Load state change:{0}", event.loadState);
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
        trace("On Seek Change:{0}", event.seeking);
    }


    /* static */

    private static const ID:String = "LIVERAIL_ID";
}
}