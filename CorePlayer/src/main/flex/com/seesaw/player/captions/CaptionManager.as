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
import com.seesaw.player.controls.ControlBarMetadata;

import flash.display.Sprite;
import flash.events.Event;
import flash.filters.BitmapFilterQuality;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.TimelineMetadataEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.CuePoint;
import org.osmf.metadata.MetadataWatcher;
import org.osmf.metadata.TimelineMetadata;

public class CaptionManager extends Sprite {

    private var logger:ILogger = LoggerFactory.getClassLogger(CaptionManager);

    private var _captionMetadata:TimelineMetadata;
    private var _captionField:TextField;
    private var _autoHideWatcher:MetadataWatcher;
    private var _media:MediaElement;
    private var _hidden:Boolean;

    public function CaptionManager(mediaElement:MediaElement) {

        _media = mediaElement;
        _captionMetadata = mediaElement.getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;

        if (_captionMetadata == null) {
            mediaElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
        }
        else {
            processTimelineMetadata(mediaElement);
        }
        setupControlBarWatcher();
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
            //logger.debug("cuePoint.time=" + cuePoint.time + ", value = " + cuePoint.parameters);
            _captionField.htmlText = cuePoint.parameters as String;
            _captionField.dispatchEvent(new Event('REPOSITION'));
        }
    }

    private function setupControlBarWatcher():void {
        if (_autoHideWatcher) {
            _autoHideWatcher.unwatch();
            _autoHideWatcher = null;
        }

        if (_media != null) {
            _autoHideWatcher
                    = new MetadataWatcher
                    (_media.metadata
                            , ControlBarMetadata.CONTROL_BAR_METADATA
                            , ControlBarMetadata.CONTROL_BAR_HIDDEN
                            , controlBarHiddenChangeCallback
                            );
            _autoHideWatcher.watch();
        }
    }

    private function controlBarHiddenChangeCallback(value:Boolean):void {
        logger.debug("control bar hidden: " + value);
        _hidden = value;
    }

    private function createCaptions():void {
        if (_captionField == null) {

            _captionField = new TextField();
            _captionField.width = stage.stageWidth;
            _captionField.htmlText = "";
            _captionField.multiline = true;
            _captionField.autoSize = TextFieldAutoSize.CENTER;

            var format:TextFormat = new TextFormat();
            format.align = TextFormatAlign.CENTER;
            format.size = 16;
            format.font = 'Arial';
            _captionField.defaultTextFormat = format;

            var outline:GlowFilter = new GlowFilter(0x000000, 1.0, 2.0, 2.0, 10);

            outline.quality = BitmapFilterQuality.MEDIUM;

            _captionField.filters = [outline];

            _captionField.addEventListener(Event.ADDED_TO_STAGE, this.positionSubtitles);
            _captionField.addEventListener("REPOSITION", this.positionSubtitles);

            addChild(_captionField);
        }
    }

    private function positionSubtitles(event:Event):void {
        event.target.y = stage.stageHeight - (event.target.height + 27);
    }
}
}