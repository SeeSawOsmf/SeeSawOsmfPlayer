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

package com.seesaw.player.captioning.sami {
import flash.events.Event;
import flash.filters.BitmapFilterQuality;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.layout.LayoutMetadata;
import org.osmf.layout.LayoutTargetSprite;

public class CaptionDisplayObject extends LayoutTargetSprite {

    private var captionField:TextField;

    private var captionValue:String = "";

    private var logger:ILogger = LoggerFactory.getClassLogger(CaptionDisplayObject);

    public function CaptionDisplayObject(layoutMetadata:LayoutMetadata = null) {
        super(layoutMetadata);

        captionField = new TextField();
        captionField.htmlText = "";
        captionField.multiline = true;
        captionField.wordWrap = true;
        captionField.selectable = false;

        var format:TextFormat = new TextFormat();
        format.align = TextFormatAlign.CENTER;
        format.size = 16;
        format.font = 'Arial';
        captionField.defaultTextFormat = format;

        var outline:GlowFilter = new GlowFilter(0x000000, 1.0, 2.0, 2.0, 10);
        outline.quality = BitmapFilterQuality.MEDIUM;

        captionField.filters = [outline];
        addChild(captionField);
    }

    private function applyStandardTextSize():void {
        var format:TextFormat = new TextFormat();
        format.align = TextFormatAlign.CENTER;
        format.size = 16;
        format.font = 'Arial';
        captionField.defaultTextFormat = format;
        captionField.htmlText = captionValue;
        captionField.selectable = false;
    }

    private function applyLargeTextSize():void {
        var format:TextFormat = new TextFormat();
        format.align = TextFormatAlign.CENTER;
        format.size = 43;
        format.font = 'Arial';
        captionField.defaultTextFormat = format;
        captionField.htmlText = captionValue;
        captionField.selectable = false;
    }

    override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean = true):void {
        // needs rounding for some reason
        var roundedWidth:int = Math.round(width);
        var roundedAvailableWidth:int = Math.round(availableWidth);

        // we are only interested in changing width
        var changed:Boolean = roundedAvailableWidth != roundedWidth;

        // check that we have expanded by a minimum of 100 pixels before enlarging
        var expanded:Boolean = roundedAvailableWidth > roundedWidth && roundedAvailableWidth - roundedWidth > 100 && roundedWidth != 100;

        logger.debug("roundedAvailableWidth: " + roundedAvailableWidth);
        logger.debug("roundedWidth: " + roundedWidth);
        logger.debug("roundedAvailableWidth - roundedWidth: " + (roundedAvailableWidth - roundedWidth));

        super.layout(availableWidth, availableHeight, deep);

        captionField.width = availableWidth;
        captionField.height = availableHeight;

        if (expanded) {
            logger.debug("applying expanded size");
            logger.debug("height: " + this.height);
            captionField.y = 10;
            applyLargeTextSize();
        }
        else if (changed) {
            logger.debug("applying standard size");
            logger.debug("height: " + this.height);
            captionField.y = 80;
            applyStandardTextSize();
        }
    }

    private function positionSubtitles(event:Event):void {
        event.target.y = height - (event.target.height + 27);
    }

    public function set text(value:String):void {
        if (captionField) {
            captionField.htmlText = captionValue = value;
        }
    }
}
}