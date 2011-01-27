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

package com.seesaw.player.ads.auditude {
import com.auditude.ads.AuditudePlugin;
import com.auditude.ads.event.AdClickThroughEvent;
import com.auditude.ads.event.AdPluginEvent;
import com.auditude.ads.event.LinearAdEvent;
import com.auditude.ads.event.NonLinearAdEvent;
import com.auditude.ads.osmf.constants.AuditudeOSMFConstants;
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.ads.AdState;
import com.seesaw.player.ads.AuditudeConstants;
import com.seesaw.player.traits.ads.AdTimeTrait;

import flash.system.Security;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MetadataEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayTrait;

// These three are from PlayerCommon, not here
public class AdProxy extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(AdProxy);

    private var config:Configuration;
    private var resumePosition:int;
    private var adTimeTrait:AdTimeTrait;

    public function AdProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);
        Security.allowDomain("sandbox.auditude.com");
    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            logger.debug("proxiedElement: " + proxiedElement);
            super.proxiedElement = proxiedElement;

            proxiedElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetaDataAdd);
            proxiedElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onMetaDataRemove);

            logger.debug("SET PROXIEDELEMENT");
            logger.debug(getSetting(AuditudeConstants.PLUGIN_INSTANCE));

            var metadata:Metadata = proxiedElement.resource.getMetadataValue(AuditudeOSMFConstants.AUDITUDE_METADATA_NAMESPACE) as Metadata;
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetaDataChange);
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onMetaDataChange);

            //config = getSetting(AuditudeConstants.CONFIG_OBJECT) as Configuration;
            resumePosition = getSetting(AuditudeConstants.RESUME_POSITION) as int;
        }
    }

    private function onMetaDataRemove(event:MediaElementEvent):void {
        if (event.namespaceURL == AuditudeOSMFConstants.AUDITUDE_METADATA_NAMESPACE) {
            logger.debug("AUDITUDE METADATA REMOVED");
        }
    }

    private function onMetaDataAdd(event:MediaElementEvent):void {
        if (event.namespaceURL == AuditudeOSMFConstants.AUDITUDE_METADATA_NAMESPACE) {
            logger.debug("AUDITUDE METADATA REMOVED");
        }
    }

    private function onMetaDataChange(event:MetadataEvent):void {
        logger.debug("METADATA CHANGED: " + event.key);
        if (event.key == AuditudeConstants.PLUGIN_INSTANCE) {
            var _auditude:AuditudePlugin = event.value;
            _auditude.addEventListener(AdPluginEvent.BREAK_BEGIN, onBreakBegin);
            _auditude.addEventListener(AdPluginEvent.BREAK_END, onBreakEnd);

            _auditude.addEventListener(AdClickThroughEvent.AD_CLICK, onAdClickThrough);
            _auditude.addEventListener(LinearAdEvent.AD_BEGIN, onLinearAdBegin);
            _auditude.addEventListener(LinearAdEvent.AD_END, onLinearAdEnd);
            _auditude.addEventListener(NonLinearAdEvent.AD_BEGIN, onNonLinearAdBegin);
            _auditude.addEventListener(NonLinearAdEvent.AD_END, onNonLinearAdEnd);
        }
    }

    // TODO: Implement this for auditude
    private function setAdBreaks():void {
        // get these from somewhere!
        var adMap:Object = {} //ev.data.adMap;
        var adBreaks:Array = []; //adMap.adBreaks;

        var metadataAdBreaks:Vector.<AdBreak> = new Vector.<AdBreak>(adBreaks.length, true);

        for (var i:uint = 0; i < adBreaks.length; i++) {
            var adBreak:Object = adBreaks[i];

            //total number of ads in this ad-break
            var queueAdsTotal:uint = adBreak.queueAdsTotal;

            //total duration of ad-break in seconds
            //sometimes duration is not available for 3rd party ads such as VPAID
            //when duration cannot be computed, this value remains zero
            var queueDuration:Number = adBreak.queueDuration;

            // (queueAdsTotal > 0)
            var hasAds:Boolean = adBreak.hasAds;

            //start time passed in the LR_ADMAP param: "0", "768.52" and "100%", all values are String
            var startTimeString:String = adBreak.startTimeString;

            //start time value converted to Number: 0, 768.52, 100
            var startTimeValue:Number = adBreak.startTimeValue;

            //specifies whether the startTimeValue is Percent (true) or  seconds (false)
            var startTimeIsPercent:Boolean = adBreak.startTimeIsPercent;

            // sets the ad breaks as metadata on the element
            var metadataAdBreak:AdBreak = new AdBreak();
            metadataAdBreak.queueAdsTotal = queueAdsTotal;
            metadataAdBreak.queueDuration = queueDuration;
            metadataAdBreak.startTime = startTimeValue;
            metadataAdBreak.startTimeIsPercent = startTimeIsPercent;

            metadataAdBreaks[i] = metadataAdBreak;
        }

        adMetadata.adBreaks = metadataAdBreaks;
    }

    private function getSetting(key:String):* {
        var metadata:Metadata = proxiedElement.resource.getMetadataValue(AuditudeOSMFConstants.AUDITUDE_METADATA_NAMESPACE) as Metadata;
        return metadata ? metadata.getValue(key) : null;
    }

    private function setTraitsToBlock(...traitTypes):void {
        var traitsToBlock:Vector.<String> = new Vector.<String>();
        for (var i:int = 0; i < traitTypes.length; i++) {
            traitsToBlock[i] = traitTypes[i];
        }
        blockedTraits = traitsToBlock;
    }

    private function pause() {
        var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playTrait) {
            // pauses the main content or the ads depending on the current adtrait
            playTrait.pause();
        }
    }

    private function stop() {
        var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playTrait) {
            // stops the main content
            playTrait.stop();
        }
    }

    private function play() {
        var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playTrait) {
            // plays the main content or the ads depending on the current adtrait
            playTrait.play();
        }
    }

    private function get adMetadata():AdMetadata {
        var adMetadata:AdMetadata = getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
        if (adMetadata == null) {
            adMetadata = new AdMetadata();
            addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);
        }
        return adMetadata;
    }

    // Auditude Event Handlers

    private function onBreakBegin(event:AdPluginEvent):void {
        logger.debug("AD BREAK BEGIN");
        adMetadata.adState = AdState.STARTED;
    }

    private function onBreakEnd(event:AdPluginEvent):void {
        logger.debug("AD BREAK END");
        adMetadata.adState = AdState.STOPPED;
    }

    private function onLinearAdBegin(event:LinearAdEvent):void {
    }

    private function onLinearAdEnd(event:LinearAdEvent):void {
    }

    private function onNonLinearAdBegin(event:NonLinearAdEvent):void {
    }

    private function onNonLinearAdEnd(event:NonLinearAdEvent):void {
    }

    private function onAdClickThrough(event:AdClickThroughEvent):void {
        pause();
    }


}
}