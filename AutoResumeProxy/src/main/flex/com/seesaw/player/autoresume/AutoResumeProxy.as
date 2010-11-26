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

package com.seesaw.player.autoresume {
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.services.ResumeService;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
import org.osmf.events.TimeEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class AutoResumeProxy extends ProxyElement {

    private static const TIMER_UPDATE_INTERVAL:int = 30000;
    private static const MIN_INTERVAL_BETWEEN_WRITE = 5;

    private var logger:ILogger = LoggerFactory.getClassLogger(AutoResumeProxy);

    private var seekTrait:SeekTrait;
    private var playTrait:PlayTrait;
    private var timeTrait:TimeTrait;

    private var resumeService:ResumeService;

    private var currentPositionTimer:Timer;
    private var seeking:Boolean;
    private var lastResume:Number = 0.0;
    private var seekTime:Number = 0.0;

    public function AutoResumeProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);

        var provider:ObjectProvider = ObjectProvider.getInstance();
        resumeService = provider.getObject(ResumeService);

        if (resumeService == null) {
            throw ArgumentError("no resume service implementation provided");
        }

        currentPositionTimer = new Timer(TIMER_UPDATE_INTERVAL);
        currentPositionTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            super.proxiedElement = proxiedElement;

            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
        }
    }

    private function onDurationChange(event:TimeEvent):void {
        if (!currentPositionTimer.running) {
            currentPositionTimer.start();
        }
    }

    private function onSeekingChange(event:SeekEvent):void {
        seeking = event.seeking;
        seekTime = event.time;
    }

    private function onComplete(event:TimeEvent):void {
        resumeService.writeResumeCookie(0.0);
    }

    private function onPlayStateChanged(event:PlayEvent):void {
        switch (event.playState) {
            case PlayState.PAUSED:
                currentPositionTimer.stop();
                if (!seeking) {
                    // if the user has simply paused but this pause is not triggered by a seek
                    // then write a resume cookie
                    writeResumePosition();
                }
                break;
            case PlayState.PLAYING:
                if (seeking) {
                    // we have reached the end of a seek and the video is playing again
                    // so write a resume cookie at this point
                    writeResumePosition();
                }
                seeking = false;
                currentPositionTimer.start();
                break;
            case PlayState.STOPPED:
                currentPositionTimer.stop();
                // reset the resume point to the start
                resumeService.writeResumeCookie(0.0);
                break;
        }
    }

    private function seekToResumePosition():void {
        var resume:Number = resumeService.getResumeCookie();
        if (seekTrait && seekTrait.canSeekTo(resume)) {
            seekTrait.seek(resume);
            lastResume = resume;
        }
    }

    private function onTimerTick(event:Event = null):void {
        if (playTrait && playTrait.playState == PlayState.PLAYING) {
            // if the video is playing attempt to write at TIMER_UPDATE_INTERVAL intervals
            writeResumePosition();
        }
    }

    private function writeResumePosition():void {
        if (timeTrait && seekTrait && seekTrait.canSeekTo(timeTrait.currentTime)) {
            // there should be at least MIN_INTERVAL_BETWEEN_WRITE seconds difference between the new resume point 
            // and the old
            if (Math.abs(timeTrait.currentTime - lastResume) > MIN_INTERVAL_BETWEEN_WRITE) {
                var time:Number = seeking ? seekTime : timeTrait.currentTime;
                if (time > 0) {
                    logger.debug("recording resume point at: " + time);
                    resumeService.writeResumeCookie(time);
                    lastResume = time;
                }
            }
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