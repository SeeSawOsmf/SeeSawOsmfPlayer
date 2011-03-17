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
import com.seesaw.player.PlayerConstants;
import com.seesaw.player.preloader.Preloader;

import flash.display.Sprite;
import flash.events.Event;
import flash.system.Security;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.Timer;

import org.osmf.containers.MediaContainer;
import org.osmf.layout.HorizontalAlign;
import org.osmf.layout.LayoutMetadata;
import org.osmf.layout.ScaleMode;
import org.osmf.layout.VerticalAlign;
import org.osmf.media.MediaElement;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.MediaTraitType;

public class BufferingPanel extends MediaElement {
    private const PANEL_WIDTH:Number = 260;
    private const PANEL_HEIGHT:Number = 110;

    private var parentContainer:MediaContainer;
    private var panel:Sprite;
    private var bufferingMessage:String;
    private var findOutWhyLink:String;
    private var preloader:Preloader;
    private var tooSlowTimer:Timer;

    private var _displayTrait:DisplayObjectTrait;

    //css
    private var css:StyleSheet;

    /*Constructor
     * Takes: warning:String - the guidance warning that appears at the top of the panel
     *
     */
    public function BufferingPanel(container:MediaContainer) {
        parentContainer = container;

        //set the private variables
        bufferingMessage = "<p><font color='#FFFFFF'>Your internet connection speed is too slow.</font></p>";
        findOutWhyLink = "<font color='#00A88E'><a href='/help'>Find out why</a></font>.";

        Security.allowDomain("*");
        super();

        //Build the css
        buildCSS();
        buildPanel();

        tooSlowTimer = new Timer(2500, 1);
        tooSlowTimer.addEventListener("timerComplete", showTooSlowMessage);

        _displayTrait = new DisplayObjectTrait(panel, PANEL_WIDTH, PANEL_HEIGHT);
        addTrait(MediaTraitType.DISPLAY_OBJECT, _displayTrait);

        var layoutMetadata:LayoutMetadata = new LayoutMetadata();
        layoutMetadata.scaleMode = ScaleMode.NONE;
        layoutMetadata.percentHeight = layoutMetadata.percentWidth = 100;
        layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
        layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;

        addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);

        hide();
    }

    public function show():void {
        tooSlowTimer.reset();
        tooSlowTimer.start();
    }

    public function hide():void {
        parentContainer.layoutMetadata.includeInLayout = false;
        panel.visible = false;
        tooSlowTimer.stop();
        hideTooSlowMessage();
    }


    public function playerResize(width:Number, height:Number):void {
        var metadata:LayoutMetadata = getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
        if (metadata) {
            metadata.x = width;
            metadata.y = height;
        }
    }

    private function showTooSlowMessage(event:Event):void {

        parentContainer.backgroundAlpha = 0.8;
        parentContainer.layoutMetadata.includeInLayout = true;
        panel.visible = true;
        dispatchEvent(new Event(PlayerConstants.BUFFER_MESSAGE_SHOW));
    }

    private function hideTooSlowMessage():void {
        parentContainer.backgroundAlpha = 0.0;
        dispatchEvent(new Event(PlayerConstants.BUFFER_MESSAGE_HIDE));
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
        panel = new Sprite();

        preloader = new Preloader();
        panel.addEventListener(Event.ADDED_TO_STAGE, positionPreloader);
        panel.addChild(preloader);

        panel.addChild(buildWarning);
        panel.addChild(buildFindOutMoreLink);

        return panel;
    }

    private function positionPreloader(event:Event):void {
        preloader.x = (PANEL_WIDTH / 2) - (preloader.width / 2);

    }

    private function get buildWarning():TextField {
        var warningLabel = new TextField();
        warningLabel.width = PANEL_WIDTH;
        warningLabel.height = 20;
        warningLabel.multiline = true;
        warningLabel.wordWrap = true;
        warningLabel.htmlText = bufferingMessage;
        warningLabel.selectable = false;
        warningLabel.y = 70;

        this.applyWarningFormat(warningLabel);

        return warningLabel;
    }

    private function get buildFindOutMoreLink():TextField {
        var findOutMoreLink = new TextField();
        findOutMoreLink.width = PANEL_WIDTH;
        findOutMoreLink.height = 20;
        findOutMoreLink.wordWrap = true;
        findOutMoreLink.htmlText = findOutWhyLink;
        findOutMoreLink.y = 90;
        findOutMoreLink.selectable = false;

        this.applyLinkFormat(findOutMoreLink);
        //var formattedWarningLabel:TextField = this.applyWarningFormat(warningLabel);

        return findOutMoreLink;
    }

    private function applyWarningFormat(textToFormat:TextField):TextField {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 11;
        textFormat.font = "Arial";
        textFormat.color = 0xFFFFFF;
        textFormat.align = "center";
        textFormat.leading = 3;

        textToFormat.setTextFormat(textFormat);

        return textToFormat;

    }

    private function applyLinkFormat(textToFormat:TextField):TextField {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 11;
        textFormat.font = "Arial";
        textFormat.color = 0x00A88E;
        textFormat.align = "center";
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
