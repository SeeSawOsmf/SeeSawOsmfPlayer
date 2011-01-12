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

import flash.display.Sprite;
import flash.events.Event;
import flash.system.Security;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFormat;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;

public class BufferingPanel extends Sprite {

    private var logger:ILogger = LoggerFactory.getClassLogger(BufferingPanel);

    private var bufferingMessage:String;
    private var findOutWhyLink:String;

    //css
    private var css:StyleSheet;

    /*Constructor
     * Takes: warning:String - the guidance warning that appears at the top of the panel
     *
     */
    public function BufferingPanel() {

        //set the private variables
        this.bufferingMessage = "<p><font color='#FFFFFF'>Your internet connection speed is too slow.</font></p>";
        this.findOutWhyLink = "<font color='#00A88E'><a href='/help'>Find out why</a></font>.";

        Security.allowDomain("*");
        super();

        //Build the css
        this.buildCSS();

        this.addEventListener(Event.ADDED_TO_STAGE, this.positionPanel);

        //set the visibility of the panel to false initially, this will be set to true when buffering occurs
        this.visible = false;

        addChild(this.buildPanel());

    }

    private function positionPanel(event:Event):void {
        this.x = (stage.stageWidth / 2) - (this.width / 2);
        this.y = (stage.stageHeight / 2) - (this.height / 2);
    }

    private function buildCSS():void {
        this.css = new StyleSheet;

        var htmlLink:Object = new Object();
        htmlLink.color = "#00A88E";
        htmlLink.fontSize = 12;

        var paragraph:Object = new Object();
        paragraph.color = "#FFFFFF";
        paragraph.fontSize = 12;

        this.css.setStyle('p', paragraph);
        this.css.setStyle('a', htmlLink);
    }

    private function buildPanel():Sprite {
        var panel:Sprite = new Sprite();

        panel.addChild(this.buildPanelBG());

        var contentContainer:Sprite = this.buildContentContainer();
        contentContainer.addChild(this.buildWarning());
        contentContainer.addChild(this.buildFindOutMoreLink());

        panel.addChild(contentContainer);

        return panel;

    }

    private function buildPanelBG():Sprite {
        var panelBG:Sprite = new Sprite();

        with (panelBG.graphics) {
            beginFill(0x000000, 0.7);
            drawRect(0, 0, 672, 378);
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
        var warningLabel = new TextField();
        warningLabel.width = 260;
        warningLabel.height = 230;
        warningLabel.multiline = true;
        warningLabel.wordWrap = true;
        warningLabel.htmlText = this.bufferingMessage;

        warningLabel.y = 0;

        this.applyWarningFormat(warningLabel);

        return warningLabel;
    }

    private function buildFindOutMoreLink():TextField {
        var findOutMoreLink = new TextField();
        findOutMoreLink.width = 90;
        findOutMoreLink.height = 20;
        findOutMoreLink.wordWrap = true;
        findOutMoreLink.htmlText = this.findOutWhyLink;
        findOutMoreLink.x = 34;
        findOutMoreLink.y = 187;

        this.applyLinkFormat(findOutMoreLink);
        //var formattedWarningLabel:TextField = this.applyWarningFormat(warningLabel);

        return findOutMoreLink;
    }

    private function applyWarningFormat(textToFormat:TextField):TextField {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 12;
        textFormat.font = "Arial";
        textFormat.color = 0xFFFFFF;
        textFormat.align = "left";
        textFormat.leading = 3;

        textToFormat.setTextFormat(textFormat);

        return textToFormat;

    }

    private function applyLinkFormat(textToFormat:TextField):TextField {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 12;
        textFormat.font = "Arial";
        textFormat.color = 0x00A88E;
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