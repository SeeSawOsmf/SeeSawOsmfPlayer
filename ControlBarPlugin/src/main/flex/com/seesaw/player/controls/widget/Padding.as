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
import com.seesaw.player.ui.StyledTextField;

import controls.seesaw.widget.interfaces.IWidget;

import flash.text.TextField;
import flash.text.TextFormat;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.chrome.widgets.ButtonWidget;
import org.osmf.traits.MediaTraitType;

public class Padding extends ButtonWidget implements IWidget {

    private static const QUALIFIED_NAME:String = "com.seesaw.player.controls.widget.FullScreen";
    private static const PADDING_HTML:String = "<span></span>";

    private var logger:ILogger = LoggerFactory.getClassLogger(FullScreen);
    private var _requiredTraits:Vector.<String> = new Vector.<String>;

    private var paddingLabel:TextField;

    public function Padding() {
        _requiredTraits[0] = MediaTraitType.DISPLAY_OBJECT;

        paddingLabel = new StyledTextField();
        paddingLabel.htmlText = PADDING_HTML;
        paddingLabel.width = 25;
        formatLabelFont();

        addChild(paddingLabel);
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }

    private function formatLabelFont():void {
        var textFormat:TextFormat = new TextFormat();
        textFormat.leftMargin = 40;
        paddingLabel.setTextFormat(textFormat);
    }
}
}