/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the
 * License athttp://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 */

package com.seesaw.player.captioning.sami {
import com.seesaw.player.loaders.captioning.CaptionLoader;
import com.seesaw.player.parsers.captioning.CaptionSync;
import com.seesaw.player.traits.captioning.CaptionLoadTrait;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.TimelineMetadataEvent;
import org.osmf.media.LoadableElementBase;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.URLResource;
import org.osmf.metadata.CuePoint;
import org.osmf.metadata.CuePointType;
import org.osmf.metadata.TimelineMetadata;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.LoaderBase;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;

public class SAMIElement extends LoadableElementBase {

    private var logger:ILogger = LoggerFactory.getClassLogger(SAMIElement);

    private var loadTrait:CaptionLoadTrait;
    private var _target:MediaElement;
    private var displayTrait:DisplayObjectTrait;

    public function SAMIElement(resource:URLResource = null, loader:CaptionLoader = null) {
        if (loader == null) {
            loader = new CaptionLoader(new SAMIParser());
        }
        super(resource, loader);
    }

    override protected function createLoadTrait(resource:MediaResourceBase, loader:LoaderBase):LoadTrait {
        return new CaptionLoadTrait(loader, resource);
    }

    override protected function processUnloadingState():void {
        removeTrait(MediaTraitType.DISPLAY_OBJECT);
    }

    override protected function processLoadingState():void {
        super.processLoadingState();
    }

    override protected function processReadyState():void {
        loadTrait = getTrait(MediaTraitType.LOAD) as CaptionLoadTrait;

        if (target) {
            var timelineMetadata:TimelineMetadata = target.getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;

            if (timelineMetadata == null) {
                timelineMetadata = new TimelineMetadata(target);
                target.addMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE, timelineMetadata);
            }

            for each (var caption:CaptionSync in loadTrait.document.captions) {
                var marker:CuePoint = new CuePoint(CuePointType.EVENT, caption.time, "sami",
                        caption.display, SAMIParser.CAPTION_INTERVAL);
                timelineMetadata.addMarker(marker);
            }

            timelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onCuePoint);
        }
    }

    private function onMediaTraitsChange(event:MediaElementEvent):void {
        // link the caption display trait to that of the video
        if (event.type == MediaElementEvent.TRAIT_ADD) {
            if (event.traitType == MediaTraitType.DISPLAY_OBJECT) {
                addDisplayTrait();
            }
            else if (event.traitType == MediaTraitType.PLAY) {
                var playTrait:PlayTrait = target.getTrait(MediaTraitType.PLAY) as PlayTrait;
                playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
            }
        } else {
            if (event.traitType == MediaTraitType.DISPLAY_OBJECT || event.traitType == MediaTraitType.PLAY) {
                removeDisplayTrait();
            }
        }
    }

    private function onPlayStateChange(event:PlayEvent):void {
        if(event.playState == PlayState.STOPPED) {
            removeDisplayTrait();
        }
    }

    private function addDisplayTrait():void {
        if (!hasTrait(MediaTraitType.DISPLAY_OBJECT)) {
            logger.debug("adding display object trait for sami captions");
            var captionDisplayObject:CaptionDisplayObject = new CaptionDisplayObject();
            // Captions are invisible by default. Obtain the DisplayObjectTrait to make visible
            captionDisplayObject.visible = false;
            displayTrait = new DisplayObjectTrait(captionDisplayObject);
            addTrait(MediaTraitType.DISPLAY_OBJECT, displayTrait);
        }
    }

    private function removeDisplayTrait():void {
        logger.debug("removing display object trait for sami captions");
        removeTrait(MediaTraitType.DISPLAY_OBJECT);
        displayTrait = null;
    }

    private function onCuePoint(event:TimelineMetadataEvent):void {
        var cuePoint:CuePoint = event.marker as CuePoint;
        if (cuePoint && displayTrait) {
            var captionDisplayObject:CaptionDisplayObject = displayTrait.displayObject as CaptionDisplayObject;
            var caption:String = cuePoint.parameters as String;
            captionDisplayObject.text = caption;
            logger.debug("caption: time = {0}, duration = {1}", cuePoint.time, cuePoint.duration);
        }
    }

    public function set target(value:MediaElement):void {
        if (_target) {
            _target.removeEventListener(MediaElementEvent.TRAIT_ADD, onMediaTraitsChange);
            _target.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaTraitsChange);
        }
        _target = value;
        if (_target) {
            _target.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaTraitsChange);
            _target.addEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaTraitsChange);
        }
    }

    public function get target():MediaElement {
        return _target;
    }
}
}
