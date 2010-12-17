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

package uk.co.vodco.osmfDebugProxy {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.AudioEvent;
import org.osmf.events.BufferEvent;
import org.osmf.events.DRMEvent;
import org.osmf.events.DisplayObjectEvent;
import org.osmf.events.DynamicStreamEvent;
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
import org.osmf.events.TimeEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.AudioTrait;
import org.osmf.traits.BufferTrait;
import org.osmf.traits.DRMTrait;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.DynamicStreamTrait;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class DebugProxyElement extends ProxyElement {
    private var logger:ILogger = LoggerFactory.getClassLogger(DebugProxyElement);

    public function DebugProxyElement() {

        logger.debug("Initialising Proxy Element");
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


    // Internals
    //

    private function onTraitAdd(event:MediaElementEvent):void {
        processTrait(event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        processTrait(event.traitType, false);
    }

    private function processTrait(traitType:String, added:Boolean):void {
        switch (traitType) {
            case MediaTraitType.AUDIO:
                toggleAudioListeners(added);
                break;
            case MediaTraitType.LOAD:
                toggleLoadListeners(added);
                break;
            case MediaTraitType.BUFFER:
                toggleBufferListeners(added);
                break;
            case MediaTraitType.PLAY:
                togglePlayListeners(added);
                break;
            case MediaTraitType.SEEK:
                toggleSeekListeners(added);
                break;
            case MediaTraitType.TIME:
                toggleTimeListeners(added);
                break;
            case MediaTraitType.DISPLAY_OBJECT:
                toggleDisplayListeners(added);
                break;
            case MediaTraitType.DRM:
                toggleDrmListeners(added);
                break;
            case MediaTraitType.DYNAMIC_STREAM:
                toggleDynamicStreamListeners(added);
                break;
        }
    }

    private function toggleDynamicStreamListeners(added:Boolean):void {
        var dynamicStream:DynamicStreamTrait = proxiedElement.getTrait(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait;

        if (dynamicStream) {
            dynamicStream.addEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, onAutoSwitchChange);
            dynamicStream.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onSwitchingChange);
        } else {
            dynamicStream.removeEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, onAutoSwitchChange);
            dynamicStream.removeEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onSwitchingChange);

        }
    }

    private function onSwitchingChange(event:DynamicStreamEvent):void {
        var trait:DynamicStreamTrait = getTrait(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait;
        if (trait && trait.switching) {
            logger.debug("Switching dynamic stream: bitrate = {0}", trait.getBitrateForIndex(trait.currentIndex));
        }
    }

    private function onAutoSwitchChange(event:DynamicStreamEvent):void {
        logger.debug("On Auto Switch Change: {0}", event.autoSwitch);
    }

    private function toggleDrmListeners(added:Boolean):void {
        var drm:DRMTrait = proxiedElement.getTrait(MediaTraitType.DRM) as DRMTrait;

        if (drm) {
            drm.addEventListener(DRMEvent.DRM_STATE_CHANGE, onDrmStateChange);
        } else {
            drm.removeEventListener(DRMEvent.DRM_STATE_CHANGE, onDrmStateChange);
        }
    }

    private function onDrmStateChange(event:DRMEvent):void {
        logger.debug("On DRM Stage Change:{0}", event.drmState);
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
        logger.debug("On Media Size Change old:{0}x{1} new:{2}x{3}", event.oldHeight, event.oldWidth, event.newHeight, event.newWidth);
    }

    private function onDisplayObjectChange(event:DisplayObjectEvent):void {
        logger.debug("On Display Object Change old:{0} new:{1}", event.oldDisplayObject, event.newDisplayObject)
    }

    private function toggleAudioListeners(added:Boolean):void {
        var audible:AudioTrait = proxiedElement.getTrait(MediaTraitType.AUDIO) as AudioTrait;
        if (audible) {
            if (added) {
                audible.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
                audible.addEventListener(AudioEvent.MUTED_CHANGE, onMutedChange);
            }
            else {
                audible.removeEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
                audible.removeEventListener(AudioEvent.MUTED_CHANGE, onMutedChange);
            }
        }
    }

    private function onMutedChange(event:AudioEvent):void {
        logger.debug("Mute change: {0}", event.muted);
    }

    private function onVolumeChange(event:AudioEvent):void {
        logger.debug("Volume Change: {0}", event.volume);
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
        logger.debug("Load onBytesTotal change:{0}", event.bytes);
    }

    private function onLoadableStateChange(event:LoadEvent):void {
        logger.debug("Load state change:{0}", event.loadState);
    }

    private function toggleBufferListeners(added:Boolean):void {
        var buffer:BufferTrait = proxiedElement.getTrait(MediaTraitType.BUFFER) as BufferTrait;
        if (buffer) {
            if (added) {
                buffer.addEventListener(BufferEvent.BUFFER_TIME_CHANGE, onBufferTimeChange);
                buffer.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
            }
            else {
                buffer.removeEventListener(BufferEvent.BUFFER_TIME_CHANGE, onBufferTimeChange);
                buffer.removeEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
            }
        }
    }

    private function onBufferingChange(event:BufferEvent):void {
        logger.debug("On Buffering Change:{0}", event.buffering);
    }

    private function onBufferTimeChange(event:BufferEvent):void {
        logger.debug("On Buffer Time Change:{0}", event.bufferTime);
    }

    private function togglePlayListeners(added:Boolean):void {
        var playable:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playable) {
            if (added) {
                playable.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
                playable.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, onCanPauseChange);
            }
            else {
                playable.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
                playable.removeEventListener(PlayEvent.CAN_PAUSE_CHANGE, onCanPauseChange);
            }
        }
    }

    private function onCanPauseChange(event:PlayEvent):void {
        logger.debug("Can Pause Change:{0}", event.canPause);
    }

    private function onPlayStateChange(event:PlayEvent):void {
        logger.debug("Play State Change:{0}", event.playState);
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
        //   logger.debug("On Seek Change:{0}", event.seeking);
    }

    private function toggleTimeListeners(added:Boolean):void {
        var time:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;

        if (time) {
            time.addEventListener(TimeEvent.COMPLETE, onComplete);
            time.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
            time.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
        } else {
            time.removeEventListener(TimeEvent.COMPLETE, onComplete);
            time.removeEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
            time.removeEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
        }
    }

    private function onDurationChange(event:TimeEvent):void {
        logger.debug("On Duration Change:{0}", event.target.duration);
    }

    private function onCurrentTimeChange(event:TimeEvent):void {
        logger.debug("On Current Time Change:{0}", event.time);
    }

    private function onComplete(event:TimeEvent):void {
        logger.debug("On Complete");
    }

}
}