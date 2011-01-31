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

package com.seesaw.player.controls.widget {
import com.seesaw.player.external.ExternalInterfaceMetadata;
import com.seesaw.player.external.PlayerExternalInterface;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.ui.PlayerToolTip;
import com.seesaw.player.ui.StyledTextField;

import controls.seesaw.widget.interfaces.IWidget;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.text.TextField;
import flash.text.TextFormat;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.chrome.widgets.ButtonWidget;
import org.osmf.events.MetadataEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.traits.MediaTraitType;

public class LightsDownButton extends ButtonWidget implements IWidget {

    private var logger:ILogger = LoggerFactory.getClassLogger(LightsDownButton);

    private var xi:PlayerExternalInterface;

    private var lightsDownOn:Boolean = false;
    private var lightsDownLabel:TextField;

    private var mouseOverLabel:Boolean = false;

    private var toolTip:PlayerToolTip;

    private var metadata:Metadata;

    /* static */
    private static const QUALIFIED_NAME:String = "com.seesaw.player.controls.widget.SubtitlesButton";

    private static const _requiredTraits:Vector.<String> = new Vector.<String>;
    _requiredTraits[0] = MediaTraitType.PLAY;

    public function LightsDownButton() {
        logger.debug("Lights Down Constructor");
        lightsDownLabel = new StyledTextField();
        lightsDownLabel.text = "Turn lights up";
        this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

        xi = ObjectProvider.getInstance().getObject(PlayerExternalInterface);
        logger.debug("XI IS: " + xi.available);
        this.toolTip = new PlayerToolTip(this, "Turn lights up");
        this.formatLabelFont();

        this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);

        this.visible = false;

        addChild(lightsDownLabel);
    }

    private function setupExternalInterface():void {
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("updateLightsStatus", this.updateLightsStatus);
        }
    }

    private function onMouseOver (event:MouseEvent):void {
        if (this.mouseOverLabel == false) {
            this.mouseOverLabel = true;
            formatLabelHoverFont();
        }
    }

    private function onMouseOut (event:MouseEvent):void {
        if (this.mouseOverLabel == true) {
            this.mouseOverLabel = false;
            formatLabelFont();
        }
    }

    private function updateLightsStatus ():void {
        if (lightsDownOn) {
            this.turnLightsUp();
        } else {
            this.turnLightsDown();
        }
    }

    override public function set media(value:MediaElement):void {

        super.media = value;

        if (media) {
            this.metadata = media.getMetadata(ExternalInterfaceMetadata.EXTERNAL_INTERFACE_METADATA);
            if (metadata == null) {
                metadata = new Metadata();
                media.addMetadata(ExternalInterfaceMetadata.EXTERNAL_INTERFACE_METADATA, metadata);
            }

            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, lightsDownMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_ADD, lightsDownMetadataChange);
        }
    }

    private function lightsDownMetadataChange(event:MetadataEvent) {
        if (event.key == ExternalInterfaceMetadata.LIGHTS_DOWN) {
           var value:Boolean = event.value as Boolean;
           if (value == true) {
               this.turnLightsDown();
           } else {
               this.turnLightsUp();               
           }
           logger.debug("METADATA SAYS LIGHTS ARE: " + value);
        }
    }

    private function onAddedToStage(event:Event) {
        stage.addChild(this.toolTip);
        if (ExternalInterface.available) {
            this.setupExternalInterface();
            this.visible = true;
        }
    }

    private function formatLabelFont():void {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 11;
        textFormat.color = 0x00A78D;
        textFormat.align = "right";
        this.lightsDownLabel.setTextFormat(textFormat);
    }

    private function formatLabelHoverFont():void {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 11;
        textFormat.color = 0xFFFFFF;
        this.lightsDownLabel.setTextFormat(textFormat);
    }


    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function onMouseClick(event:MouseEvent):void {

        if (this.lightsDownOn == false) {
            this.turnLightsDown();
        } else {
            this.turnLightsUp();
        }
    }

    private function turnLightsDown():void {
        if (xi.available) {
            xi.callLightsDown();
            metadata.addValue(ExternalInterfaceMetadata.LIGHTS_DOWN, true);
        }
        lightsDownLabel.text = "Turn lights up";
        this.toolTip.updateToolTip("Turn lights up");
        this.formatLabelFont();
        if (this.mouseOverLabel == true) {
            this.formatLabelHoverFont();
        }
        this.lightsDownOn = true;
    }

    private function turnLightsUp():void {
        if (xi.available) {
            xi.callLightsUp();
            metadata.addValue(ExternalInterfaceMetadata.LIGHTS_DOWN, false);
        }
        lightsDownLabel.text = "Turn lights down";
        this.toolTip.updateToolTip("Turn lights down");
        this.formatLabelFont();
        if (this.mouseOverLabel == true) {
            this.formatLabelHoverFont();
        }
        this.lightsDownOn = false;
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }
}
}