package uk.vodco.livrail {
import flash.system.Security;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ParallelElement;
import org.osmf.elements.SWFElement;
import org.osmf.layout.LayoutMetadata;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.URLResource;
import org.osmf.metadata.Metadata;
import org.osmf.traits.DisplayObjectTrait;

public class LiverailElement extends MediaElement {


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


    public function addReference(target:MediaElement):void {
        if (this.target == null) {
            this.target = target;
            processTarget();

        }
    }

    private function processTarget():void {
        if (target != null && settings != null) {
            // We use the NS_CONTROL_BAR_TARGET namespaced metadata in order
            // to find out if the instantiated element is the element that our
            // control bar should control:
            var targetMetadata:Metadata = target.getMetadata(LiverailPlugin.NS_TARGET);
            if (targetMetadata) {
                if (targetMetadata.getValue(ID) != null
                        && targetMetadata.getValue(ID) == settings.getValue(ID)
                        ) {

                }
            }
        }
    }

    // Overrides
    //

    override public function set resource(value:MediaResourceBase):void {
        // Right after the media factory has instantiated us, it will set the
        // resource that it used to do so. We look the NS_CONTROL_BAR_SETTINGS
        // namespaced metadata, and retain it as our settings record
        // (containing only one field: "ID" that tells us the ID of the media
        // element that we should be controlling):
        if (value != null) {
            settings
                    = value.getMetadataValue(LiverailPlugin.NS_SETTINGS) as Metadata;

            processTarget();
        }

        super.resource = value;
    }

    override protected function setupTraits():void {

        // Use the control bar's layout metadata as the element's layout metadata:
        var layoutMetadata:LayoutMetadata = new LayoutMetadata();
        addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);


        // Signal that this media element is viewable: create a DisplayObjectTrait.
        // Assign controlBar (which is a Sprite) to be our view's displayObject.
        // Additionally, use its current width and height for the trait's mediaWidth
        // and mediaHeight properties:
        // viewable = new DisplayObjectTrait(controlBar, controlBar.measuredWidth, controlBar.measuredHeight);
        // Add the trait:
        //  addTrait(MediaTraitType.DISPLAY_OBJECT, viewable);


        super.setupTraits();
    }

    // Internals
    //


    private var settings:Metadata;

    private var target:MediaElement;

    private var viewable:DisplayObjectTrait;


    /* static */

    private static const ID:String = "ID";
}
}
/*  override public function set proxiedElement(value:MediaElement):void {
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

 private function onTimerTick(event:Event = null):void {
 var temporal:TimeTrait = proxiedElement ? proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait : null;
 if (temporal != null) {

 //	var position:Number = isNaN(seekToTime) ? temporal.currentTime : seekToTime;
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
 trace("On Seek Change:{0}", event.seeking);
 }

 private function onTimeChange(event:TimeEvent):void {
 logger.debug("Time Change:  ", event.time);
 }



 private static const ID:String = "LIVERAIL_ID";
 }
 }

 */