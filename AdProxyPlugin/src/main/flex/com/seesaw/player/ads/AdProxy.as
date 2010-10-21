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

package com.seesaw.player.ads {
import com.seesaw.player.ads.events.LiveRailEvent;

import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.Security;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.Timer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.elements.SWFElement;
import org.osmf.events.DisplayObjectEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.TimeTrait;

public class AdProxy extends ProxyElement {


    private var logger:ILogger = LoggerFactory.getClassLogger(AdProxy);

    private var liveRailElement:SWFElement;
    private var _adManager:*;
    private var liverailLoader:Loader;
    public static var TYPE:String = "LIVERAIL_INTERFACE";


    private var modLoaded:Boolean = false;

    private var liveRailModuleLocation:String;


    public var contentInfo:XML;

    private var liveRailAdMap:String = "in::0;in::832.04;in::1818.36;in::100%";

    private var liveRailTags:String = "sourceId_BBCWORLDWIDE,firstPresentationBrand_BBC,minimumAge_18,catchup_false,TVDRAMACONTEMPORARYBRITISH,TVDRAMA,duration_less_than_1_hour";


    private var videoId:String;


    private var config:Object;


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
    private var liverailConfig:LiverailConfig;

    public function AdProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);

        Security.allowDomain("*");

        displayObject = new Sprite();

        var format:TextFormat = new TextFormat("Verdana", 16, 0xffffff);
        format.align = TextFormatAlign.CENTER;
        format.font = "Verdana";

        label = new TextField();
        label.defaultTextFormat = format;

        displayObject.addChild(label);
        outerViewable = new AdProxyDisplayObjectTrait(displayObject);

        var traitsToBlock:Vector.<String> = new Vector.<String>();
        traitsToBlock[0] = MediaTraitType.SEEK;
        //   traitsToBlock[1] = MediaTraitType.TIME;

        blockedTraits = traitsToBlock;

        var timer:Timer = new Timer(5000);
        timer.addEventListener(TimerEvent.TIMER, onTimerTick);
        timer.start();
    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        try {
            if (proxiedElement && (proxiedElement.resource.getMetadataValue("contentId") != null)) {

                super.proxiedElement = proxiedElement;

                proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onProxiedTraitsChange);
                proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onProxiedTraitsChange);
                //   var value:* = proxiedElement.resource.getMetadataValue("contentInfo");
                //  blockedTraits = new Vector.<String>();    todo use this to clear the blockedtraits list...
                createLiverail();

            }
        } catch(e:Error) {

        }
    }


    private function createLiverail():void {

        var liverailPath:String = "http://vox-static.liverail.com/swf/v4/admanager.swf";
        var urlResource:URLRequest = new URLRequest(liverailPath);

        liverailLoader = new Loader();
        //	liverailLoader.width = this.width;
        //	liverailLoader.height = this.height;
        liverailLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
        liverailLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        liverailLoader.load(urlResource);
        displayObject.addChild(liverailLoader);
    }


    private function onLoadComplete(event:Event):void {

        _adManager = liverailLoader.content;
        displayObject.addChild(_adManager);

        setupAdManager();
    }

    private function onLoadError(e:IOErrorEvent):void {

    }

    private function setupAdManager():void {

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

        liverailConfig = new LiverailConfig();
        adManager.initAds(liverailConfig.config);

    }

    public function get adManager():* {
        return _adManager;
    }


    private function onLiveRailInitComplete(e:Event):void {
        adManager.setSize(new Rectangle(0, 0, 300, 200));
    }

    private function onProxiedTraitsChange(event:MediaElementEvent):void {
        if (event.type == MediaElementEvent.TRAIT_ADD) {
            if (event.traitType == MediaTraitType.DISPLAY_OBJECT) {
                innerViewable = DisplayObjectTrait(proxiedElement.getTrait(event.traitType));
                if (_innerViewable) {
                    addTrait(MediaTraitType.DISPLAY_OBJECT, outerViewable);
                }
            }
        }
        else {
            if (event.traitType == MediaTraitType.DISPLAY_OBJECT) {
                innerViewable = null;
                removeTrait(MediaTraitType.DISPLAY_OBJECT);
            }
        }
    }

    private function set innerViewable(value:DisplayObjectTrait):void {
        if (_innerViewable != value) {
            if (_innerViewable) {
                _innerViewable.removeEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onInnerDisplayObjectChange);
                _innerViewable.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onInnerMediaSizeChange);
            }

            _innerViewable = value;

            if (_innerViewable) {
                _innerViewable.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onInnerDisplayObjectChange);
                _innerViewable.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onInnerMediaSizeChange);
            }

            updateView();
        }
    }

    private function onInnerDisplayObjectChange(event:DisplayObjectEvent):void {
        updateView();
    }

    private function onInnerMediaSizeChange(event:DisplayObjectEvent):void {
        outerViewable.setSize(event.newWidth, event.newHeight);

        label.width = event.newWidth;
    }

    private function updateView():void {
        if (_innerViewable == null
                || _innerViewable.displayObject == null
                || displayObject.contains(_innerViewable.displayObject) == false
                ) {
            if (displayObject.numChildren == 2) {
                displayObject.removeChildAt(0);
            }
            label.visible = false;
        }

        if (_innerViewable != null
                && _innerViewable.displayObject != null
                && displayObject.contains(_innerViewable.displayObject) == false
                ) {
            displayObject.addChildAt(_innerViewable.displayObject, 0);
            label.visible = true;
        }

    }

    private function onTimerTick(event:TimerEvent):void {
        var labelText:String = "";
        if (proxiedElement != null) {
            var timeTrait:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;
            var playTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;

            if (playTrait) {
                if (playTrait.playState == PlayState.PLAYING) {
                    playTrait.pause();
                    labelText = "[ Advertisement ]" + timeTrait.currentTime;
                }
                else if (playTrait.playState == PlayState.PAUSED) {
                    playTrait.play();
                    labelText = "";
                }
            }
        }
        label.text = labelText;
    }

    private var _innerViewable:DisplayObjectTrait;
    private var outerViewable:AdProxyDisplayObjectTrait;
    private var displayObject:Sprite;
    private var label:TextField;
}
}