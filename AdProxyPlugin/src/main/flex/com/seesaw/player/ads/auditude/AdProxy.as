/*
 * The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *   The Initial Developer of the Original Code is Arqiva Ltd.
 *   Portions created by Arqiva Limited are Copyright (C) 2010, 2011 Arqiva Limited.
 *   Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe
 * 	Systems Incorporated.
 *   All Rights Reserved.
 *
 *   Contributor(s):  Adobe Systems Incorporated
 */


package com.seesaw.player.ads.auditude {
import com.auditude.ads.AuditudePlugin;
import com.auditude.ads.event.AdClickThroughEvent;
import com.auditude.ads.event.AdPluginEvent;
import com.auditude.ads.event.LinearAdEvent;
import com.auditude.ads.event.NonLinearAdEvent;
import com.auditude.ads.osmf.constants.AuditudeOSMFConstants;
import com.seesaw.player.PlayerConstants;
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.ads.AdMode;
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
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayTrait;

// These three are from PlayerCommon, not here
public class AdProxy extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(AdProxy);

    private var config:Configuration;
    private var adTimeTrait:AdTimeTrait;
    private var playerMetadata:Metadata;
    private var adBreakCount:int;

    public function AdProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);
        Security.allowDomain("sandbox.auditude.com");
    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            logger.debug("proxiedElement: " + proxiedElement);
            super.proxiedElement = proxiedElement;

            playerMetadata = proxiedElement.resource.getMetadataValue(PlayerConstants.METADATA_NAMESPACE) as Metadata;

            proxiedElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetaDataAdd);
            proxiedElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onMetaDataRemove);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdded);
            logger.debug("SET PROXIEDELEMENT");
            logger.debug(getSetting(AuditudeConstants.PLUGIN_INSTANCE));
            var metadata:Metadata = proxiedElement.resource.getMetadataValue(AuditudeOSMFConstants.AUDITUDE_METADATA_NAMESPACE) as Metadata;
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetaDataChange);
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onMetaDataChange);

        }
    }

    private function onAuditudeInit(event:AdPluginEvent):void {

        var metadataAdBreaks:Vector.<AdBreak> = new Vector.<AdBreak>();
        var adBreaks:Array = event.data.breaks;


        for (var i:uint = 0; i < adBreaks.length; i++) {
            var adBreak:Object = adBreaks[i];

            //total number of ads in this ad-break
            var queueAdsTotal:uint = 0; //TODO Currently not available

            //total duration of ad-break in seconds
            //sometimes duration is not available for 3rd party ads such as VPAID
            //when duration cannot be computed, this value remains zero
            var queueDuration:Number = 0;  //TODO Currently not available

            var hasAds:Boolean = adBreak.isEmpty ? true : true;

            //start time value converted to Number: 0, 768.52, 100
            var startTimeValue:Number = adBreak.startTime;

            //specifies whether the startTimeValue is Percent (true) or  seconds (false)
            var startTimeIsPercent:Boolean = false;

            // sets the ad breaks as metadata on the element
            var metadataAdBreak:AdBreak = new AdBreak();
            metadataAdBreak.queueAdsTotal = queueAdsTotal;
            metadataAdBreak.queueDuration = queueDuration;
            metadataAdBreak.startTime = startTimeValue;
            metadataAdBreak.startTimeIsPercent = startTimeIsPercent;

            // Dont add the break if it has no ads, eg no content to play, so we don't want a blip for this item
            if (hasAds) {
                metadataAdBreaks[i] = metadataAdBreak;
            }
        }
        adMetadata.adBreaks = metadataAdBreaks;

        // section count need to occur before we start the adContent. as this is required for the first view to be registered.
        playerMetadata.addValue(AdMetadata.SECTION_COUNT, metadataAdBreaks.length);

    }

    private function onTraitAdded(event:MediaElementEvent):void {
        var traitType:String;
        for each (traitType in event.target.traitTypes) {
            processTrait(traitType, true);
        }
    }

    private function processTrait(traitType:String, added:Boolean):void {
        switch (traitType) {
            case MediaTraitType.LOAD:
                toggleLoadListeners(added);
                break;
        }
    }

    private function toggleLoadListeners(added:Boolean):void {
        var loadable:LoadTrait = proxiedElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
        trace(loadable)
    }

    private function onMetaDataRemove(event:MediaElementEvent):void {
        if (event.namespaceURL == AuditudeOSMFConstants.AUDITUDE_METADATA_NAMESPACE) {
            logger.debug("AUDITUDE METADATA REMOVED");
        }
    }

    private function onMetaDataAdd(event:MediaElementEvent):void {
        if (event.namespaceURL == AuditudeOSMFConstants.AUDITUDE_METADATA_NAMESPACE) {
            trace(event);
        }
    }

    private function onMetaDataChange(event:MetadataEvent):void {
        logger.debug("METADATA CHANGED: " + event.key);
        if (event.key == AuditudeConstants.PLUGIN_INSTANCE) {
            var _auditude:AuditudePlugin = event.value;
            _auditude.addEventListener(AdPluginEvent.INIT_COMPLETE, onAuditudeInit);
            _auditude.addEventListener(AdPluginEvent.BREAK_BEGIN, onBreakBegin);
            _auditude.addEventListener(AdPluginEvent.BREAK_END, onBreakEnd);

            _auditude.addEventListener(AdClickThroughEvent.AD_CLICK, onAdClickThrough);
            _auditude.addEventListener(LinearAdEvent.AD_BEGIN, onLinearAdBegin);
            _auditude.addEventListener(LinearAdEvent.AD_END, onLinearAdEnd);
            _auditude.addEventListener(NonLinearAdEvent.AD_BEGIN, onNonLinearAdBegin);
            _auditude.addEventListener(NonLinearAdEvent.AD_END, onNonLinearAdEnd);

            _auditude.addEventListener(AdPluginEvent.PAUSE_PLAYBACK, triggerPause);
            _auditude.addEventListener(AdPluginEvent.RESUME_PLAYBACK, triggerPlay)
        }
    }

    private function triggerPause(event:AdPluginEvent):void {
        var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playTrait) {
            // pauses the main content or the ads depending on the current adtrait
            playTrait.pause();
        }
    }

    private function triggerPlay(event:AdPluginEvent):void {
        var playTrait:PlayTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playTrait) {
            // pauses the main content or the ads depending on the current adtrait
            playTrait.play();
        }
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

        adBreakCount++;
        // Perhaps this is needed for mid-rolls
        //pause();

        // mask the existing play trait so we get the play state changes here
        adMetadata.adState = AdState.AD_BREAK_START;
        adMetadata.adMode = AdMode.AD;
        setTraitsToBlock(MediaTraitType.SEEK, MediaTraitType.TIME);
    }

    private function onBreakEnd(event:AdPluginEvent):void {
        logger.debug("AD BREAK END");
        adMetadata.adState = AdState.AD_BREAK_COMPLETE;
        adMetadata.adMode = AdMode.MAIN_CONTENT;
//        adMetadata.markNextUnseenAdBreakAsSeen();
        setTraitsToBlock();
    }

    private function onLinearAdBegin(event:LinearAdEvent):void {
        logger.debug("AD BEGIN");
        processAdStateMeta(AdState.STARTED, event);

    }

    private function onLinearAdEnd(event:LinearAdEvent):void {
        logger.debug("AD END");
        processAdStateMeta(AdState.STOPPED, event);
    }

    private function onNonLinearAdBegin(event:NonLinearAdEvent):void {
        logger.debug("AD BEGIN");
        processAdStateMeta(AdState.STARTED, event);
    }

    private function onNonLinearAdEnd(event:NonLinearAdEvent):void {
        logger.debug("AD END");
        processAdStateMeta(AdState.STOPPED, event);
    }

    private function onAdClickThrough(event:AdClickThroughEvent):void {
        adMetadata.clickThru = event.click.url;
        pause();
    }

    private function processAdStateMeta(state:String, event:*):void {
        var dataObject:Object = new Object();
        dataObject["state"] = state;
        dataObject["contentUrl"] = event.asset.url;
        dataObject["campaignId"] = event.asset.customData.campaign_id;
        dataObject["creativeId"] = event.asset.creativeType;
        adMetadata.adState = dataObject;
    }

}
}
