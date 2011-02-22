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

package com.seesaw.player.panels {
import com.seesaw.player.ui.StyledTextField;

import flash.display.Sprite;
import flash.events.Event;
import flash.system.Security;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFormat;

public class NotAvailablePanel extends Sprite {

    //Geo block message string passed into the constructor
    private var notAvailableWarning:String;

    //css
    private var css:StyleSheet;

    /*Constructor
     * Takes: warning:String - the guidance warning that appears at the top of the panel
     *
     */
    public function NotAvailablePanel() {

        //set the private variables
        this.notAvailableWarning = "<p><font color='#FFFFFF'>Programme not playing. Try again later.</font></p>";
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

        panel.addChild(contentContainer);

        return panel;

    }

    private function buildPanelBG():Sprite {
        var panelBG:Sprite = new Sprite();

        with (panelBG.graphics) {
            beginFill(0xA51B29, 0.7);
            drawRoundRect(0, 0, 300, 50, 10);
            endFill();
        }

        return panelBG;
    }

    private function buildContentContainer():Sprite {
        var contentContainer:Sprite = new Sprite();
        //the x and y of this container are the equivalent to padding in CSS
        contentContainer.x = 20;
        contentContainer.y = 16;

        return contentContainer;
    }

    private function buildWarning():TextField {
        var warningLabel = new TextField();
        warningLabel.width = 260;
        warningLabel.height = 30;
        warningLabel.multiline = true;
        warningLabel.wordWrap = true;
        warningLabel.htmlText = this.notAvailableWarning;
        //warningLabel.styleSheet = this.css;
        warningLabel.y = 0;

        this.applyWarningFormat(warningLabel);
        //var formattedWarningLabel:TextField = this.applyWarningFormat(warningLabel);

        return warningLabel;
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