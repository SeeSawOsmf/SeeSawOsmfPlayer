/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *    The contents of this file are subject to the Mozilla Public License
 *    Version 1.1 (the "License"); you may not use this file except in
 *    compliance with the License. You may obtain a copy of the
 *    License athttp://www.mozilla.org/MPL/
 *
 *    Software distributed under the License is distributed on an "AS IS"
 *    basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *    License for the specific language governing rights and limitations
 *    under the License.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 */

package uk.vodco.liverail {
import flash.display.Loader;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.system.Security;

import mx.controls.SWFLoader;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ParallelElement;
import org.osmf.elements.SWFElement;
import org.osmf.events.LoaderEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.SeekEvent;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.URLResource;
import org.osmf.metadata.Metadata;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.SeekTrait;

import uk.vodco.liverail.events.LiveRailEvent;

public class LiverailElement extends ParallelElement {


    public static var TYPE:String = "LIVERAIL_INTERFACE";


    private var modLoaded:Boolean = false;

    private var liveRailModuleLocation:String;

    private var _adManager:*;

    public var contentInfo:XML;

    private var liveRailAdMap:String = "in::0;in::832.04;in::1818.36;in::100%";

    private var liveRailTags:String = "sourceId_BBCWORLDWIDE,firstPresentationBrand_BBC,minimumAge_18,catchup_false,TVDRAMACONTEMPORARYBRITISH,TVDRAMA,duration_less_than_1_hour";


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
            resource = target.resource;
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
            setupTraits();
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
        //   var liverailPath:String = "http://vox-static.liverail.com/swf/v4/skins/adplayerskin_1.swf";
        var urlResource:URLResource = new URLResource(liverailPath)
        var loader:SWFLoader = new SWFLoader();

        load(urlResource as String);
        var liveRailElement:SWFElement = new SWFElement(urlResource);
        _adManager = liveRailElement;
        element.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onLoadComplete);

        element.addChild(_adManager);
        addChild(element);

        modLoaded = true;

        setupAdManager();
    }

    public function load(val:String):void {

        Security.allowDomain("vox-static.liverail.com");
        //	pollLoader.start();

        /*	liveRailModuleLocation = val;
         lrl = new Loader();
         //	lrl.width = this.width;
         //	lrl.height = this.height;
         lrl.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
         //	lrl.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
         lrl.load( new URLRequest(liveRailModuleLocation) );
         addChild(lrl as SWFElement);
         */
    }

    private function onLoadComplete(e:Event):void {
        modLoaded = true;
        _adManager = lrl.content;
        addChild(adManager);
    }

    private function setupAdManager():void {
        if (modLoaded) {
            adManager.addEventListener(LiveRailEvent.INIT_COMPLETE, onLiveRailInitComplete);
            /*adManager.addEventListener(LiveRailEvent.INIT_ERROR, onLiveRailInitError);

             adManager.addEventListener(LiveRailEvent.PREROLL_COMPLETE, onLiveRailPrerollComplete);
             adManager.addEventListener(LiveRailEvent.POSTROLL_COMPLETE, onLiveRailPostrollComplete);

             adManager.addEventListener(LiveRailEvent.AD_START, onLiveRailAdStart);
             adManager.addEventListener(LiveRailEvent.AD_END, onLiveRailAdEnd);

             adManager.addEventListener(LiveRailEvent.CLICK_THRU, onLiveRailClickThru);
             adManager.addEventListener(LiveRailEvent.VOLUME_CHANGE, onLiveRailVolumeChange);

             adManager.addEventListener(LiveRailEvent.AD_PROGRESS,onAdProgress);

             adManager.addEventListener(LiveRailEvent.AD_BREAK_START, adbreakStart);

             adManager.addEventListener(LiveRailEvent.AD_BREAK_COMPLETE, adbreakComplete);
             */
            liveRailConfig = new Object();

            // set to true if you are using Junction or false if you are using AdServer
            liveRailConfig["LR_USE_JUNCTION"] = false;

            // the Junction or the AdServer Publisher ID, located on the Account page of the Publisher;
            liveRailConfig["LR_PUBLISHER_ID"] = liverailPublisherId;
            //once we migrate to next platform version
            liveRailConfig["LR_VERSION"] = liverailVersion;

            //Partner ID maps to CP id
            liveRailConfig["LR_PARTNERS"] = contentObject.mediaObject.partnerId;

            // a unique code identifying the video played by your Flash player;
            liveRailConfig["LR_VIDEO_ID"] = programmeId;

            liveRailConfig["LR_LAYOUT_LINEAR_PAUSEONCLICKTHRU"] = false;
            liveRailConfig["LR_LAYOUT_SKIN_ID"] = 1;

            // ADMAP (optional param)
            // admap string is: [ad-type]:[timings(start-time,end-time)];
            // for more details on how to generate the ADMAP please see "Run-time Parameters Specification" pdf document
            liveRailConfig["LR_ADMAP"] = liveRailAdMap;

            liveRailConfig["LR_TAGS"] = liveRailTags;

            //For now we will set the sting and ident (bumpers) param to default, causing LiveRail to use the defaults
            //stored in their system. Once we are ready to specify these, then this can be changed.
            var defaultValue:String = "default";

            liveRailConfig["LR_BUMPER_PREROLL_PRE_HIGH"] = defaultValue;
            liveRailConfig["LR_BUMPER_PREROLL_POST_HIGH"] = defaultValue;
            liveRailConfig["LR_BUMPER_PREROLL_PRE_MED"] = defaultValue;
            liveRailConfig["LR_BUMPER_PREROLL_POST_MED"] = defaultValue;
            liveRailConfig["LR_BUMPER_PREROLL_PRE_LOW"] = defaultValue;
            liveRailConfig["LR_BUMPER_PREROLL_POST_LOW"] = defaultValue;
            liveRailConfig["LR_BUMPER_PREROLL_ADONLY"] = defaultValue;

            liveRailConfig["LR_BUMPER_MIDROLL_PRE_HIGH"] = defaultValue;
            liveRailConfig["LR_BUMPER_MIDROLL_POST_HIGH"] = defaultValue;
            liveRailConfig["LR_BUMPER_MIDROLL_PRE_MED"] = defaultValue;
            liveRailConfig["LR_BUMPER_MIDROLL_POST_MED"] = defaultValue;
            liveRailConfig["LR_BUMPER_MIDROLL_PRE_LOW"] = defaultValue;
            liveRailConfig["LR_BUMPER_MIDROLL_POST_LOW"] = defaultValue;
            liveRailConfig["LR_BUMPER_MIDROLL_ADONLY"] = defaultValue;

            liveRailConfig["LR_BUMPER_POSTROLL_PRE_HIGH"] = defaultValue;
            liveRailConfig["LR_BUMPER_POSTROLL_POST_HIGH"] = defaultValue;
            liveRailConfig["LR_BUMPER_POSTROLL_PRE_MED"] = defaultValue;
            liveRailConfig["LR_BUMPER_POSTROLL_POST_MED"] = defaultValue;
            liveRailConfig["LR_BUMPER_POSTROLL_PRE_LOW"] = defaultValue;
            liveRailConfig["LR_BUMPER_POSTROLL_POST_LOW"] = defaultValue;
            liveRailConfig["LR_BUMPER_POSTROLL_ADONLY"] = defaultValue;

            ////	liveRailConfig["LR_ALLOWDUPLICATES"] = 1;


            //	liveRailConfig["LR_BITRATE"] = 	media !=null && media.quality != null ? media.quality : "medium";
            //StatusService.info("Setting LiveRail ad bitrate to "+liveRailConfig["LR_BITRATE"]);

            adManager.initAds(liveRailConfig);
            // comma separated list of keywords describing the content verticals
            //	pollLoader.stop();

        } else {
            //	pollLoader.reset();
            //	pollLoader.start();
        }
    }

    public function get adManager():* {
        return _adManager;
    }

    private function onLiveRailInitComplete(e:Event):void {
        var eo:Object = e as Object;

        ///	LR_AdvertsArray = e.currentTarget._adModel._adPovider.adResult.ads;  Liverail advert results array. this is however not accessable...

        adManager.setSize(new Rectangle(0, 0, 300, 200));
        ///dispatchEvent( new LiveRailEvent(LiveRailEvent.INIT_COMPLETE,eo.data));
    }

    // Internals
    //


    private var settings:Metadata;

    private var target:MediaElement;

    private var lrl:Loader;

    public var element:ParallelElement = new ParallelElement();
    /* static */

    private static const ID:String = "ID";
}
}