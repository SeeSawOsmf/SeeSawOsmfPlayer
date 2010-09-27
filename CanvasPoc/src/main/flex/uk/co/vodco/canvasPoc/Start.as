/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *   The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *
 *   The Initial Developer of the Original Code is ioko365 Ltd.
 *   Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *   Incorporated. All Rights Reserved.
 */

package uk.co.vodco.canvasPoc {
import flash.display.Sprite;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;


[SWF(width=1280, height=720)]
public class Start extends Sprite {

    private var logger:ILogger = LoggerFactory.getClassLogger(Start);


    public function Start() {

        var textField:TextField = new TextField();
        textField.text = "Hello World";
        textField.autoSize = TextFieldAutoSize.LEFT;
        textField.visible = true;
        textField.textColor = 0xFF0000;
        addChild(textField);

    }
}
}