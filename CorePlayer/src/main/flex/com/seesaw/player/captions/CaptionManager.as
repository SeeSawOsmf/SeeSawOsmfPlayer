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

package com.seesaw.player.captions {
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.TimelineMetadataEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.CuePoint;
import org.osmf.metadata.TimelineMetadata;

public class CaptionManager extends Sprite {

    private var logger:ILogger = LoggerFactory.getClassLogger(CaptionManager);

    private var _captionMetadata:TimelineMetadata;

    private var _captionField:TextField;

    public function CaptionManager(mediaElement:MediaElement) {

        _captionMetadata = mediaElement.getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;

        if (_captionMetadata == null) {
            mediaElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
        }
        else {
            processTimelineMetadata(mediaElement);
        }
    }

    private function onMetadataAdd(event:MediaElementEvent):void {
        if (event.namespaceURL == CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) {
            processTimelineMetadata(event.target as MediaElement);
        }
    }

    private function processTimelineMetadata(mediaElement:MediaElement):void {
        if (_captionMetadata == null) {
            createCaptions();
            _captionMetadata = mediaElement.getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
            _captionMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onCuePoint);
        }
    }

    private function onCuePoint(event:TimelineMetadataEvent):void {
        var cuePoint:CuePoint = event.marker as CuePoint;
        if (cuePoint) {
            logger.debug("cuePoint.time=" + cuePoint.time + ", value = " + cuePoint.parameters);
            _captionField.htmlText = cuePoint.parameters as String;
        }
    }

    private function createCaptions():void {
        if (_captionField == null) {
            var captionSprite:Sprite = new Sprite();

            _captionField = new TextField();
            _captionField.width = stage.width;
            _captionField.htmlText = "";
            _captionField.y = stage.height - 25;

            var format:TextFormat = new TextFormat();
            format.align = TextFormatAlign.CENTER;
            _captionField.defaultTextFormat = format;

            captionSprite.addChild(_captionField);
            addChild(captionSprite);
        }
    }
}
}