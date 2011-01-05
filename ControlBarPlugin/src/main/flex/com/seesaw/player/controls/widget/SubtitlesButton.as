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

package com.seesaw.player.controls.widget {
import com.seesaw.player.controls.ControlBarMetadata;
import com.seesaw.player.ui.PlayerToolTip;
import com.seesaw.player.ui.StyledTextField;

import controls.seesaw.widget.interfaces.IWidget;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.chrome.widgets.ButtonWidget;
import org.osmf.events.MediaElementEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.CuePoint;
import org.osmf.metadata.Metadata;
import org.osmf.metadata.TimelineMetadata;
import org.osmf.traits.MediaTraitType;

public class SubtitlesButton extends ButtonWidget implements IWidget {

    private var logger:ILogger = LoggerFactory.getClassLogger(SubtitlesButton);

    private var subtitlesOn:Boolean;
    private var subtitlesLabel:TextField;

    private var toolTip:PlayerToolTip;

    /* static */
    private static const QUALIFIED_NAME:String = "com.seesaw.player.controls.widget.SubtitlesButton";

    private static const _requiredTraits:Vector.<String> = new Vector.<String>;
    _requiredTraits[0] = MediaTraitType.PLAY;

    private var metadata:Metadata;

    override public function set media(value:MediaElement):void {

        if(media) {
            media.removeEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
            media.removeEventListener(MediaElementEvent.METADATA_REMOVE, onMetadataRemove);
        }

        super.media = value;

        if (media) {
            metadata = media.getMetadata(ControlBarMetadata.CONTROL_BAR_METADATA);
            if (metadata == null) {
                metadata = new Metadata();
                media.addMetadata(ControlBarMetadata.CONTROL_BAR_METADATA, metadata);
            }

            // Show the button if there is timeline metadata or after timeline metadata is added
            var timelineMetadata:TimelineMetadata = media.getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
            if (timelineMetadata == null) {
                media.addEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
            }
            else {
                visible = true;
            }

            media.addEventListener(MediaElementEvent.METADATA_REMOVE, onMetadataRemove);

            metadata.addValue(ControlBarMetadata.SUBTITLES_VISIBLE, false);
        }
    }

    private function onMetadataAdd(event:MediaElementEvent):void {
        if (event.namespaceURL == CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) {
            visible = true;
        }
    }

    private function onMetadataRemove(event:MediaElementEvent):void {
        if (event.namespaceURL == CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) {
            visible = false;
        }
    }

    public function SubtitlesButton() {
        logger.debug("Subtitles Constructor");
        subtitlesLabel = new StyledTextField();
        subtitlesLabel.text = "Subtitles are off";
        subtitlesLabel.width = 90;
        this.toolTip = new PlayerToolTip(this, "Subtitles are off");
        this.formatLabelFont();

        this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);

        addChild(subtitlesLabel);
    }

    private function onAddedToStage(event:Event) {
        stage.addChild(this.toolTip);
        logger.debug("X POS: " + this.x + " WIDTH: " + this.width);
    }

    private function formatLabelFont():void {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 12;
        textFormat.color = 0x00A78D;
        textFormat.align = "right";
        this.subtitlesLabel.setTextFormat(textFormat);
    }


    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function onMouseClick(event:MouseEvent):void {
        logger.debug("X POS: " + this.x + " WIDTH: " + this.width);
        if (this.subtitlesOn == false) {
            subtitlesLabel.text = "Subtitles are on";
            this.toolTip.updateToolTip("Subtitles are on");
            this.subtitlesOn = true;
        } else {
            subtitlesLabel.text = "Subtitles are off";
            this.toolTip.updateToolTip("Subtitles are off");
            this.subtitlesOn = false;
        }
        metadata.addValue(ControlBarMetadata.SUBTITLES_VISIBLE, subtitlesOn);
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }
}
}