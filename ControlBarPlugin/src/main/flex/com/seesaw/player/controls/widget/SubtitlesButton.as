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

package com.seesaw.player.controls.widget {
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.ads.AdState;
import com.seesaw.player.controls.ControlBarConstants;
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
import org.osmf.events.MetadataEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.traits.MediaTraitType;

public class SubtitlesButton extends ButtonWidget implements IWidget {

    private var logger:ILogger = LoggerFactory.getClassLogger(SubtitlesButton);

    private var subtitlesOn:Boolean;
    private var subtitlesLabel:TextField;

    private var mouseOverLabel:Boolean = false;

    private var toolTip:PlayerToolTip;

    /* static */
    private static const QUALIFIED_NAME:String = "com.seesaw.player.controls.widget.SubtitlesButton";

    private static const _requiredTraits:Vector.<String> = new Vector.<String>;
    _requiredTraits[0] = MediaTraitType.TIME;
    _requiredTraits[1] = MediaTraitType.PLAY;

    private var metadata:Metadata;

    public function SubtitlesButton() {
        subtitlesLabel = new StyledTextField();
        subtitlesLabel.text = "Subtitles are off";
        subtitlesLabel.width = 90;
        this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        this.toolTip = new PlayerToolTip(this, "Subtitles are off");

        this.formatLabelFont();

        this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);

        addChild(subtitlesLabel);

        this.subtitlesLabel.visible = false;
    }

    override protected function processMediaElementChange(oldMediaElement:MediaElement):void {
        if (media) {
            metadata = media.getMetadata(ControlBarConstants.CONTROL_BAR_METADATA);
            if (metadata == null) {
                metadata = new Metadata();
                media.addMetadata(ControlBarConstants.CONTROL_BAR_METADATA, metadata);
            }

            var adMetadata:AdMetadata = media.getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
            if (adMetadata) {
                adMetadata.addEventListener(MetadataEvent.VALUE_ADD, onAdMetadataChange);
                adMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, onAdMetadataChange);
                adMetadata.addEventListener(MetadataEvent.VALUE_REMOVE, onAdMetadataChange);
            }
        }
    }

    private function updateVisibility(event:MetadataEvent):void {
        if (event.key == ControlBarConstants.SUBTITLE_BUTTON_ENABLED) {
            ///   visible = event.value;
        }

    }

    private function onAdMetadataChange(event:MetadataEvent):void {
        if (metadata.getValue(ControlBarConstants.SUBTITLE_BUTTON_ENABLED)) {
            if (event.key == AdMetadata.AD_STATE && event.value == AdState.AD_BREAK_COMPLETE) {
                this.subtitlesLabel.visible = true
            } else if (event.key == AdMetadata.AD_STATE && event.value == AdState.AD_BREAK_START) {
                this.subtitlesLabel.visible = false;
            }
        }
    }


    override protected function processRequiredTraitsAvailable(element:MediaElement):void {
        // FIXME: this is not working as expected
        // doEnabledCheck();
    }

    private function onMouseOver(event:MouseEvent):void {
        if (this.mouseOverLabel == false) {
            this.mouseOverLabel = true;
            formatLabelHoverFont();
        }
    }

    private function onMouseOut(event:MouseEvent):void {
        if (this.mouseOverLabel == true) {
            this.mouseOverLabel = false;
            formatLabelFont();
        }
    }

    private function onAddedToStage(event:Event) {
        stage.addChild(this.toolTip);
    }

    private function formatLabelFont():void {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 11;
        textFormat.color = 0x00A78D;
        textFormat.align = "right";
        this.subtitlesLabel.setTextFormat(textFormat);
    }

    private function formatLabelHoverFont():void {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 11;
        textFormat.color = 0xFFFFFF;
        this.subtitlesLabel.setTextFormat(textFormat);
    }

    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function onMouseClick(event:MouseEvent):void {
        if (this.subtitlesOn == false) {
            subtitlesLabel.text = "Subtitles are on";
            this.toolTip.updateToolTip("Subtitles are on");
            if (this.mouseOverLabel == true) {
                this.formatLabelHoverFont();
            }
            this.subtitlesOn = true;
        } else {
            subtitlesLabel.text = "Subtitles are off";
            this.toolTip.updateToolTip("Subtitles are off");
            if (this.mouseOverLabel == true) {
                this.formatLabelHoverFont();
            }
            this.subtitlesOn = false;
        }
        metadata.addValue(ControlBarConstants.SUBTITLES_VISIBLE, subtitlesOn);
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }
}
}
