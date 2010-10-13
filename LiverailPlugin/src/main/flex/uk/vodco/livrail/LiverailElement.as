package uk.vodco.livrail {
import flash.system.Security;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ParallelElement;
import org.osmf.elements.SWFElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.SeekEvent;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.URLResource;
import org.osmf.metadata.Metadata;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.SeekTrait;

public class LiverailElement extends ParallelElement {


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
    }


    public function addReference(target:MediaElement):void {
        if (this.target == null) {
            this.target = target;
            processTarget();
            createLiverail();
            setupTraits();
        }
    }

    private function processTarget():void {
        if (target != null && settings != null) {
            // We use the NS_TARGET namespaced metadata in order
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
        // resource that it used to do so. We look the NS_SETTINGS
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

        var traitType:String

        if (target != null) {
            // Clear our old listeners.
            target.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            target.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

            for each (traitType in target.traitTypes) {
                processTrait(traitType, false);
            }
        }


        if (target != null) {
            // Listen for traits being added and removed.
            target.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            target.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

            for each (traitType in target.traitTypes) {
                processTrait(traitType, true);
            }
        }

        super.setupTraits();


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

                break;

            case MediaTraitType.SEEK:
                toggleSeekListeners(added);
                break;

            case MediaTraitType.TIME:

                break;

        }
        logger.debug(traitType);
    }


    private function toggleSeekListeners(added:Boolean):void {
        var seek:SeekTrait = target.getTrait(MediaTraitType.SEEK) as SeekTrait;

        if (seek) {
            seek.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
        } else {
            seek.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
        }
    }

    private function onSeekingChange(event:SeekEvent):void {
        logger.debug("On Seek Change:{0}", event.seeking);
    }

    public function createLiverail():void {


        var liverailPath:String = "http://www.swftools.org/flash/mv_zoom1.swf";
        // var liverailPath:String = "http://vox-static.liverail.com/swf/v4/skins/adplayerskin_1.swf";
        var urlResource:URLResource = new URLResource(liverailPath)
        element = new ParallelElement();
        element.addChild(new SWFElement(urlResource));

        addChild(element);
    }

    // Internals
    //


    private var settings:Metadata;

    private var target:MediaElement;


    public var element:ParallelElement;
    /* static */

    private static const ID:String = "LIVERAIL_ID";
}
}