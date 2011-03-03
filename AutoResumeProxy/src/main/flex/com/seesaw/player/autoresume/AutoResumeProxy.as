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

package com.seesaw.player.autoresume {
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.ads.AdState;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.services.ResumeService;

import flash.events.TimerEvent;
import flash.utils.Timer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MetadataEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
import org.osmf.events.TimeEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class AutoResumeProxy extends ProxyElement {

    private static const AD_BREAK_OFFSET = 0.1;
    private static const TIMER_UPDATE_INTERVAL:int = 30000;

    private var logger:ILogger = LoggerFactory.getClassLogger(AutoResumeProxy);

    private var seekTrait:SeekTrait;
    private var playTrait:PlayTrait;
    private var timeTrait:TimeTrait;
    private var requestedSeekPoint:Number;
    private var resumeService:ResumeService;
    private var timer:Timer;
    private var contentHasEnded:Boolean = false;

    public function AutoResumeProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);

        var provider:ObjectProvider = ObjectProvider.getInstance();
        resumeService = provider.getObject(ResumeService);

        if (resumeService == null) {
            throw ArgumentError("no resume service implementation provided");
        }

        timer = new Timer(TIMER_UPDATE_INTERVAL);
        timer.addEventListener(TimerEvent.TIMER, onTimerTick);
    }

    public override function set proxiedElement(element:MediaElement):void {
        if (element) {
            if (proxiedElement) {
                removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
                removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
                removeEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
                removeEventListener(MediaElementEvent.METADATA_REMOVE, onMetadataRemove);
            }

            super.proxiedElement = element;

            addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
            addEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
            addEventListener(MediaElementEvent.METADATA_REMOVE, onMetadataRemove);

            var adMetadata:AdMetadata = getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
            if (adMetadata) {
                setupAdEventListener(adMetadata, true);
            }
        }
    }

    private function getAdBreakAtTime(time:Number):AdBreak {
        var adBreak:AdBreak = null;
        var adMetadata:AdMetadata = getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
        if (!isNaN(time) && adMetadata) {
            adBreak = adMetadata.getAdBreakWithTime(time);
        }
        return adBreak;
    }

    private function setupAdEventListener(metadata:Metadata, add:Boolean):void {
        if (add) {
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onAdMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onAdMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_REMOVE, onAdMetadataChange);
        }
        else {
            metadata.removeEventListener(MetadataEvent.VALUE_ADD, onAdMetadataChange);
            metadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onAdMetadataChange);
            metadata.removeEventListener(MetadataEvent.VALUE_REMOVE, onAdMetadataChange);
        }
    }

    private function onMetadataRemove(event:MediaElementEvent):void {
        if (event.namespaceURL == AdMetadata.AD_NAMESPACE) {
            setupAdEventListener(event.metadata, false);
        }
    }

    private function onMetadataAdd(event:MediaElementEvent):void {
        if (event.namespaceURL == AdMetadata.AD_NAMESPACE) {
            setupAdEventListener(event.metadata, true);
        }
    }

    private function onAdMetadataChange(event:MetadataEvent):void {
        if (event.key == AdMetadata.AD_STATE) {
            if (timeTrait) {
                logger.debug("adState: {0}", event.value);
                if (event.value == AdState.AD_BREAK_COMPLETE)
                    writeResumePosition(timeTrait.currentTime + AD_BREAK_OFFSET);
            }
        }
    }

    private function onDurationChange(event:TimeEvent):void {
        if (!timer.running) {
            timer.start();
        }
    }

    private function onSeekingChange(event:SeekEvent):void {
        if (!event.seeking) {
            // Don't write a resume point after we've made a seek request ourselves.
            if (isNaN(requestedSeekPoint))
                writeResumePosition(event.time);

            requestedSeekPoint = NaN;
        }
    }

    private function onComplete(event:TimeEvent):void {
        /*Due to the seek timer stangeness in OSMF we would get the seekChanges after the asset has completed/STOP etc..
        so lets remove the listener the write the resume cookie as 0*/
        changeListeners(false, MediaTraitType.SEEK, SeekEvent.SEEKING_CHANGE, onSeekingChange);
        resumeService.writeResumeCookie(0);
    }

    private function onPlayStateChanged(event:PlayEvent):void {
        switch (event.playState) {
            case PlayState.PAUSED:
                timer.stop();
                break;
            case PlayState.PLAYING:
                timer.start();
                break;
            case PlayState.STOPPED:
                timer.stop();
                // reset the resume point to the start
                resumeService.writeResumeCookie(0);
                break;
        }
    }

    private function seekToResumePosition():void {
        var resume:Number = resumeService.getResumeCookie();
        if (resume > 0 && seekTrait && seekTrait.canSeekTo(resume)) {
            logger.debug("seeking to resume point at: {0}", resume);
            seekTrait.seek(resume);
            requestedSeekPoint = resume;
        }
    }

    private function onTimerTick(event:TimerEvent = null):void {
        logger.debug("onTimerTick");
        if (timeTrait && playTrait && playTrait.playState == PlayState.PLAYING) {
            // if the video is playing attempt to write at TIMER_UPDATE_INTERVAL intervals
            writeResumePosition(timeTrait.currentTime);
        }
    }

    private function writeResumePosition(time:Number):void {
        var timeToWrite:Number = time;

        // Don't write resume points exactly on ad breaks since the resume points have to be
        // offset from ad breaks a little depending on whether the break has been seen or not
        var adBreak:AdBreak = getAdBreakAtTime(time);
        if (adBreak) {
            timeToWrite = adBreak.startTime + (adBreak.complete ? AD_BREAK_OFFSET : -AD_BREAK_OFFSET);
            logger.debug("ad break at requested resume point {0}: complete = {1}", time, adBreak.complete);
        }

        if (seekTrait && seekTrait.canSeekTo(timeToWrite)) {
            logger.debug("recording resume point: requested = {0}, written = {1}", time, timeToWrite);
           resumeService.writeResumeCookie(timeToWrite);
        }
    }

    private function onTraitAdd(event:MediaElementEvent):void {
        updateTraitListeners(event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        updateTraitListeners(event.traitType, false);
    }

    private function updateTraitListeners(traitType:String, add:Boolean):void {
        switch (traitType) {
            case MediaTraitType.SEEK:
                changeListeners(add, traitType, SeekEvent.SEEKING_CHANGE, onSeekingChange);
                seekTrait = getTrait(MediaTraitType.SEEK) as SeekTrait;
                seekToResumePosition();
                break;
            case MediaTraitType.PLAY:
                changeListeners(add, traitType, PlayEvent.PLAY_STATE_CHANGE, onPlayStateChanged);
                playTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
                break;
            case MediaTraitType.TIME:
                changeListeners(add, traitType, TimeEvent.COMPLETE, onComplete);
                changeListeners(add, traitType, TimeEvent.DURATION_CHANGE, onDurationChange);
                timeTrait = getTrait(MediaTraitType.TIME) as TimeTrait;
                break;
        }
    }

    private function changeListeners(add:Boolean, traitType:String, event:String, listener:Function):void {
        if (add) {
            getTrait(traitType).addEventListener(event, listener);
        }
        else if (hasTrait(traitType)) {
            getTrait(traitType).removeEventListener(event, listener);
        }
    }
}
}
