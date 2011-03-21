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

package uk.co.vodco.osmfDebugProxy {
import flash.utils.getQualifiedClassName;

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
import org.osmf.events.MetadataEvent;
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
    private var proxiedElementName:String;

    public function DebugProxyElement(proxiedElement:MediaElement = null) {
        super(proxiedElement);
        logger.debug("Initialising Proxy Element");
    }

    override public function set proxiedElement(value:MediaElement):void {
        var traitType:String

        if (proxiedElement) {
            // Clear our old listeners.
            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
            proxiedElement.removeEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
            proxiedElement.removeEventListener(MediaElementEvent.METADATA_ADD, onMetadataRemove);

            for each (traitType in value.traitTypes) {
                processTrait(traitType, false);
            }
        }

        super.proxiedElement = value;

        if (proxiedElement) {
            proxiedElementName = getQualifiedClassName(proxiedElement);
            logger.debug("proxying element: {0}", proxiedElementName)

            // Listen for traits being added and removed.
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
            proxiedElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
            proxiedElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetadataRemove);

            for each (traitType in value.traitTypes) {
                processTrait(traitType, true);
            }
        }
    }

    private function onMetadataRemove(event:MediaElementEvent):void {
        logger.debug("{0}: metadata remove: {1}", proxiedElementName, event.namespaceURL);
        event.metadata.removeEventListener(MetadataEvent.VALUE_ADD, onMetadataValueAdd);
        event.metadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onMetadataValueChange);
        event.metadata.removeEventListener(MetadataEvent.VALUE_REMOVE, onMetadataValueRemove);
    }

    private function onMetadataAdd(event:MediaElementEvent):void {
        logger.debug("{0}: metadata add: {1}", proxiedElementName, event.namespaceURL);
        event.metadata.addEventListener(MetadataEvent.VALUE_ADD, onMetadataValueAdd);
        event.metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataValueChange);
        event.metadata.addEventListener(MetadataEvent.VALUE_REMOVE, onMetadataValueRemove);
    }

    private function onMetadataValueAdd(event:MetadataEvent):void {
        logger.debug("{0}: metadata value add: {1}", proxiedElementName, event.key, event.value);
    }

    private function onMetadataValueChange(event:MetadataEvent):void {
        logger.debug("{0}: metadata value change: {1}", proxiedElementName, event.key, event.value);
    }

    private function onMetadataValueRemove(event:MetadataEvent):void {
        logger.debug("{0}: metadata value remove: {1}", proxiedElementName, event.key, event.value);
    }

    private function onTraitAdd(event:MediaElementEvent):void {
        logger.debug("{0}: trait add: {1} - {2}", proxiedElementName,
                event.traitType, getQualifiedClassName(getTrait(event.traitType)));
        processTrait(event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        logger.debug("{0}: trait remove: {1} - {2}", proxiedElementName,
                event.traitType, getQualifiedClassName(getTrait(event.traitType)));
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
            if (added) {
                dynamicStream.addEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, onAutoSwitchChange);
                dynamicStream.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onSwitchingChange);
            } else {
                dynamicStream.removeEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, onAutoSwitchChange);
                dynamicStream.removeEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onSwitchingChange);
            }
        }
    }

    private function onSwitchingChange(event:DynamicStreamEvent):void {
        var trait:DynamicStreamTrait = proxiedElement.getTrait(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait;
        if (trait) {
            if (trait.switching) {
                logger.debug("{0}: Switching dynamic stream from bitrate = {1}",
                        proxiedElementName, trait.getBitrateForIndex(trait.currentIndex));
            }
            else {
                logger.debug("{0}: Completed dynamic stream switch to bitrate = {1}",
                        proxiedElementName, trait.getBitrateForIndex(trait.currentIndex));
            }
        }
    }

    private function onAutoSwitchChange(event:DynamicStreamEvent):void {
        logger.debug("{0}: Auto Switch Change: {1}", proxiedElementName, event.autoSwitch);
    }

    private function toggleDrmListeners(added:Boolean):void {
        var drm:DRMTrait = proxiedElement.getTrait(MediaTraitType.DRM) as DRMTrait;

        if (drm) {
            if (added) {
                drm.addEventListener(DRMEvent.DRM_STATE_CHANGE, onDrmStateChange);
            } else {
                drm.removeEventListener(DRMEvent.DRM_STATE_CHANGE, onDrmStateChange);
            }
        }
    }

    private function onDrmStateChange(event:DRMEvent):void {
        logger.debug("{0}: DRM Stage Change: {1}", proxiedElementName, event.drmState);
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
        logger.debug("{0}: Media Size Change old: {1}x{2} new: {3}x{4}",
                proxiedElementName, event.oldHeight, event.oldWidth, event.newHeight, event.newWidth);
    }

    private function onDisplayObjectChange(event:DisplayObjectEvent):void {
        logger.debug("{0}: Display Object Change old: {1} new: {2}",
                proxiedElementName, event.oldDisplayObject, event.newDisplayObject)
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
        logger.debug("{0}: Mute change: {1}", proxiedElementName, event.muted);
    }

    private function onVolumeChange(event:AudioEvent):void {
        logger.debug("{0}: Volume Change: {1}", proxiedElementName, event.volume);
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
        logger.debug("{0}: Load onBytesTotal change: {1}", proxiedElementName, event.bytes);
    }

    private function onLoadableStateChange(event:LoadEvent):void {
        logger.debug("{0}: Load state change: {1}", proxiedElementName, event.loadState);
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
        logger.debug("{0}: Buffering Change: Buffering: {1}, Time: {2}, Length: {3}",
                proxiedElementName, event.buffering, event.bufferTime, event.currentTarget.bufferLength);
    }

    private function onBufferTimeChange(event:BufferEvent):void {
        logger.debug("{0}: Buffer Time Change: Buffering: {1}, Time: {2}, Length: {3}",
                proxiedElementName, event.buffering, event.bufferTime, event.currentTarget.bufferLength);
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
        logger.debug("{0}: Can Pause Change: {1}", proxiedElementName, event.canPause);
    }

    private function onPlayStateChange(event:PlayEvent):void {
        logger.debug("{0}: Play State Change: {1} - {2}",
                proxiedElementName, event.playState, getQualifiedClassName(getTrait(MediaTraitType.PLAY)));
    }

    private function toggleSeekListeners(added:Boolean):void {
        var seek:SeekTrait = proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;

        if (seek) {
            if (added) {
                seek.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
            } else {
                seek.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
            }
        }
    }

    private function onSeekingChange(event:SeekEvent):void {
        logger.debug("{0}: Seek Change: seeking = {1}, time = {2}", proxiedElementName, event.seeking, event.time);
    }

    private function toggleTimeListeners(added:Boolean):void {
        var time:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;

        if (time) {
            if (added) {
                time.addEventListener(TimeEvent.COMPLETE, onComplete);
                time.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
                time.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
            } else {
                time.removeEventListener(TimeEvent.COMPLETE, onComplete);
                time.removeEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
                time.removeEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
            }
        }
    }

    private function onDurationChange(event:TimeEvent):void {
        logger.debug("{0}: Duration Change: {1}", proxiedElementName, event.target.duration);
    }

    private function onCurrentTimeChange(event:TimeEvent):void {
        logger.debug("{0}: Current Time Change: {1}", proxiedElementName, event.time);
    }

    private function onComplete(event:TimeEvent):void {
        logger.debug("{0}: Complete", proxiedElementName);
    }

}
}