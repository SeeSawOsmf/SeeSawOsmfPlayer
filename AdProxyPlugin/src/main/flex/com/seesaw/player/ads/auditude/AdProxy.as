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
import com.seesaw.player.PlayerConstants;
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.ads.AdMode;
import com.seesaw.player.ads.AdState;
import com.seesaw.player.ads.AuditudeConstants;

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

    private var playerMetadata:Metadata;
    private var currentAdBreak:AdBreak;

    public function AdProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);
        Security.allowDomain("sandbox.auditude.com");
    }

    public override function set proxiedElement(value:MediaElement):void {
        if (value) {
            logger.debug("proxiedElement: " + value);

            if (proxiedElement) {
                proxiedElement.removeEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
                proxiedElement.removeEventListener(MediaElementEvent.METADATA_REMOVE, onMetadataRemove);
            }

            super.proxiedElement = value;

            playerMetadata = proxiedElement.resource.getMetadataValue(PlayerConstants.METADATA_NAMESPACE) as Metadata;

            proxiedElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
            proxiedElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onMetadataRemove);
        }
    }

    private function onMetadataRemove(event:MediaElementEvent):void {
        if (event.namespaceURL == AuditudeConstants.SETTINGS_NAMESPACE) {
            event.metadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onSettingsChange);
            event.metadata.removeEventListener(MetadataEvent.VALUE_ADD, onSettingsChange);
        }
    }

    private function onMetadataAdd(event:MediaElementEvent):void {
        if (event.namespaceURL == AuditudeConstants.SETTINGS_NAMESPACE) {
            event.metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onSettingsChange);
            event.metadata.addEventListener(MetadataEvent.VALUE_ADD, onSettingsChange);
        }
    }

    private function onSettingsChange(event:MetadataEvent):void {
        if (event.key == AuditudeConstants.PLUGIN_INSTANCE) {
            logger.debug("Got plugin instance: " + event.key);
            var auditude:AuditudePlugin = event.value;
            auditude.addEventListener(AdPluginEvent.INIT_COMPLETE, onAuditudeInit);
            auditude.addEventListener(AdPluginEvent.BREAK_BEGIN, onBreakBegin);
            auditude.addEventListener(AdPluginEvent.BREAK_END, onBreakEnd);

            auditude.addEventListener(AdClickThroughEvent.AD_CLICK, onAdClickThrough);
            auditude.addEventListener(LinearAdEvent.AD_BEGIN, onLinearAdBegin);
            auditude.addEventListener(LinearAdEvent.AD_END, onLinearAdEnd);
            auditude.addEventListener(NonLinearAdEvent.AD_BEGIN, onNonLinearAdBegin);
            auditude.addEventListener(NonLinearAdEvent.AD_END, onNonLinearAdEnd);

            auditude.addEventListener(AdPluginEvent.PAUSE_PLAYBACK, triggerPause);
            auditude.addEventListener(AdPluginEvent.RESUME_PLAYBACK, triggerPlay)
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
                logger.debug("ad break created at {0}s", startTimeValue);
            }
        }
        adMetadata.adBreaks = metadataAdBreaks;

        // section count need to occur before we start the adContent. as this is required for the first view to be registered.
        playerMetadata.addValue(AdMetadata.SECTION_COUNT, metadataAdBreaks.length);
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

        // Is this the best way to get the breakTime
        currentAdBreak = adMetadata.getAdBreakWithTime(event.data.breakTime);

        adMetadata.adState = AdState.AD_BREAK_START;
        adMetadata.adMode = AdMode.AD;
        setTraitsToBlock(MediaTraitType.SEEK, MediaTraitType.TIME);
    }

    private function onBreakEnd(event:AdPluginEvent):void {
        logger.debug("AD BREAK END");
        adMetadata.adState = AdState.AD_BREAK_COMPLETE;
        adMetadata.adMode = AdMode.MAIN_CONTENT;

        if (currentAdBreak) {
            // This dispatches an event that seeks to the user's final seek point
            currentAdBreak.complete = true;
        }

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
