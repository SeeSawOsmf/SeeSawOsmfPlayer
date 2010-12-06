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

package com.seesaw.player.panels {
import com.seesaw.player.ui.StyledTextField;

import flash.display.Sprite;
import flash.events.Event;
import flash.system.Security;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFormat;

public class GeoBlockPanel extends Sprite {

    //Geo block message string passed into the constructor
    private var guidanceWarning:String;

    //css
    private var css:StyleSheet;

    /*Constructor
     * Takes: warning:String - the guidance warning that appears at the top of the panel
     *
     */
    public function GeoBlockPanel(warning:String) {

        //set the private variables
        this.guidanceWarning = "<p>We're sorry...</p><br /><p>You need to be located in the UK to watch programmes on SeeSaw. This is because we haven't been given permission by the programme makers and rights holders to show the content outside of the UK.</p><br /><p>If you're located in the UK and think that you've received this message in error, there may be a problem with your Internet Service Provider (ISP). <font color='#00A88E'><a href='/help'>Find out more</a></font>.</p>";

        Security.allowDomain("*");
        super();

        //Build the css
        this.buildCSS();

        //Build the panel and add it to the GuidancePanel MovieClip
        addChild(this.buildPanel());

        this.addEventListener(Event.ADDED_TO_STAGE, this.positionPanel);

    }

    private function positionPanel(event:Event):void {
        this.x = (stage.stageWidth / 2) - (this.width / 2);
        this.y = (stage.stageHeight / 2) - (this.height / 2);
    }

    private function buildCSS():void {
        this.css = new StyleSheet;

        var htmlLink:Object = new Object();
        htmlLink.color = "#00A88E";

        var paragraph:Object = new Object();
        paragraph.color = "#FFFFFF";

        this.css.setStyle('p', paragraph);
        this.css.setStyle('a', htmlLink);
    }

    private function buildPanel():Sprite {
        var panel:Sprite = new Sprite();

        panel.addChild(this.buildPanelBG());

        var contentContainer:Sprite = this.buildContentContainer();
        contentContainer.addChild(this.buildWarning());

        panel.addChild(contentContainer);

        return panel;

    }

    private function buildPanelBG():Sprite {
        var panelBG:Sprite = new Sprite();

        with (panelBG.graphics) {
            beginFill(0xA51B29, 0.7);
            drawRoundRect(0, 0, 300, 250, 10);
            endFill();
        }

        return panelBG;
    }

    private function buildContentContainer():Sprite {
        var contentContainer:Sprite = new Sprite();
        //the x and y of this container are the equivalent to padding in CSS
        contentContainer.x = 20;
        contentContainer.y = 20;
        return contentContainer;
    }

    private function buildWarning():TextField {
        var warningLabel = new StyledTextField();
        warningLabel.width = 260;
        warningLabel.height = 230;
        warningLabel.multiline = true;
        warningLabel.wordWrap = true;
        warningLabel.htmlText = this.guidanceWarning;
        //warningLabel.styleSheet = this.css;
        warningLabel.y = 0;

        this.applyWarningFormat(warningLabel);
        //var formattedWarningLabel:TextField = this.applyWarningFormat(warningLabel);

        return warningLabel;
    }

    private function applyWarningFormat(textToFormat:TextField):TextField {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 12;
        textFormat.color = 0xFFFFFF;
        textFormat.align = "left";
        textFormat.leading = 3;

        textToFormat.setTextFormat(textFormat);

        return textToFormat;

    }

    private function applyDefaultFormat(textToFormat:TextField) {
        var textFormat:TextFormat = new TextFormat();
        textFormat.color = 0x00A88E;

        textToFormat.setTextFormat(textFormat);
    }

}
 
}