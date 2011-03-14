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

    private var captionSet:Boolean = false;
    private var captionFormatted:Boolean = false;

    private var logger:ILogger = LoggerFactory.getClassLogger(CaptionDisplayObject);

    public function CaptionDisplayObject(layoutMetadata:LayoutMetadata = null) {
        super(layoutMetadata);

        captionField = new TextField();
        captionField.htmlText = "";
        captionField.multiline = true;
        captionField.wordWrap = true;

        var format:TextFormat = new TextFormat();
        format.align = TextFormatAlign.CENTER;
        format.size = 16;
        format.font = 'Arial';
        captionField.defaultTextFormat = format;

        var outline:GlowFilter = new GlowFilter(0x000000, 1.0, 2.0, 2.0, 10);
        outline.quality = BitmapFilterQuality.MEDIUM;

        captionField.filters = [outline];

        applyStandardTextSize();

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
        format.size = 23;
        format.font = 'Arial';
        captionField.defaultTextFormat = format;
        captionField.htmlText = captionValue;
        captionField.selectable = false;
    }

    override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean = true):void {
        super.layout(availableWidth, availableHeight, deep);

        logger.debug("CALL TO SUBTITLE LAYOUT")

        logger.debug("CAPTION SET: " + captionSet + " - CAPTION: " + captionField.htmlText);

        logger.debug("availableWidth: " + availableWidth + " captionFieldWidth: " + captionField.width);

        //we check the captionField.html to make sure the subtitles have arrived - this prevents random resizing during stings etc
        if (captionSet == true) {
            if (availableWidth != captionField.width) {

                var goLarge:Boolean = availableWidth > captionField.width;

                logger.debug("GO LARGE CALCULATION = " + goLarge);

                captionField.width = availableWidth;
                captionField.height = availableHeight;

                if (captionFormatted == true) {
                    if (goLarge) {
                        applyLargeTextSize();
                        logger.debug("APPLY LARGE SIZE");
                    } else {
                        applyStandardTextSize();
                        logger.debug("APPLY STANDARD SIZE");
                    }
                } else {
                    applyStandardTextSize();
                    captionFormatted = true;
                    logger.debug("CAPTION FORMATTED");
                }

            }
        } else {
            //ensure the width of the captionField is the full available width
            captionField.width = availableWidth;
            applyStandardTextSize();
            logger.debug("CAPTION NOT YET SET - APPLY STANDARD SIZE");
        }
    }


    private function positionSubtitles(event:Event):void {
        event.target.y = height - (event.target.height + 27);
    }

    public function set text(value:String):void {
        if (captionField) {
            captionField.htmlText = captionValue = value;
            captionSet = true;
            logger.debug("CAPTION SET");
        }
    }
}
}