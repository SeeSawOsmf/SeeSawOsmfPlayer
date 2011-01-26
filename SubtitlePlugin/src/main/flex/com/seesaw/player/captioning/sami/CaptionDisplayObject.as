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
import flash.events.Event;
import flash.filters.BitmapFilterQuality;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import org.osmf.layout.LayoutMetadata;
import org.osmf.layout.LayoutTargetSprite;

public class CaptionDisplayObject extends LayoutTargetSprite {

    private var captionField:TextField;

    public function CaptionDisplayObject(layoutMetadata:LayoutMetadata = null) {
        super(layoutMetadata);

        captionField = new TextField();
        captionField.htmlText = "";
        captionField.multiline = true;
        //captionField.autoSize = TextFieldAutoSize.CENTER;

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

    override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean = true):void {
        super.layout(availableWidth, availableHeight, deep);
        captionField.width = availableWidth;
        captionField.height = availableHeight;
    }

    private function positionSubtitles(event:Event):void {
        event.target.y = height - (event.target.height + 27);
    }

    public function set text(value:String):void {
        if (captionField) {
            captionField.htmlText = value;
        }
    }
}
}