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
import com.seesaw.player.ui.PlayerToolTip;
import com.seesaw.player.ui.StyledTextField;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.external.ExternalInterface;
import flash.system.Security;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFormat;

public class OverUsePanel extends Sprite {

    public static const NO_ADS = "NO_ADS";

    public static const OVERUSE_ACCEPTED = "OVERUSE_ACCEPTED";
    public static const OVERUSE_REJECTED = "OVERUSE_REJECTED";

    //Guidance warning string passed into the constructor
    private var errorType:String;
    private var termsAndConditionsLinkURL:String;

    private var title:String;
    private var text:String;

    private var nonStopTitle:String = "<b>We're sorry...</b><br>You've exceeded your maximum daily viewing allowance for NonStop.";
    private var nonStopText:String = "Your NonStop subscription is for individual use only. " +
            "This means you can watch programmes without adverts for a maximum of 24 hours a day. See our " +
            "<a href='event:" + termsAndConditionsLinkURL + "'><font color=\"#00A88E\">Terms and Conditions.</font></a>" +
            "<br>" +
            "<br>" +
            "Would you like to continue watching programmes with adverts?";

    private var subsTitle:String = "<b>We're sorry...</b><br>You've now exceeded the maximum daily viewing allowance for this Pack.";

    private var subsText:String = "Your subscription is for individual use only. This means you can watch programmes" +
            " in this Pack for a maximum of 24 hours a day. See our " +
            "<a href='event:" + termsAndConditionsLinkURL + "'><font color=\"#00A88E\">Terms and Conditions.</font></a>" +
            "<br>";

    //components which need tooltips
    private var acceptButton:Sprite = new Sprite();
    private var cancelButton:Sprite = new Sprite();
    private var okButton:Sprite = new Sprite();

    //Embed images
    [Embed(source="resources/accept_up.png")]
    private var acceptImageUpEmbed:Class;
    private var acceptImageUp:Bitmap = new acceptImageUpEmbed();
    [Embed(source="resources/accept_over.png")]
    private var acceptImageOverEmbed:Class;
    private var acceptImageOver:Bitmap = new acceptImageOverEmbed();

    [Embed(source="resources/ok_up.png")]
    private var okImageUpEmbed:Class;
    private var okImageUp:Bitmap = new okImageUpEmbed();
    [Embed(source="resources/ok_over.png")]
    private var okImageOverEmbed:Class;
    private var okImageOver:Bitmap = new okImageOverEmbed();

    [Embed(source="resources/warning_icon.png")]
    private var warningIconEmbed:Class;
    private var warningIcon:Bitmap = new warningIconEmbed();

    //css
    private var css:StyleSheet;

    /*Constructor
     * Takes: warning:String - the guidance warning that appears at the top of the panel
     *
     */
    public function OverUsePanel(errorType:String, termsAndConditionsLinkURL:String) {

        this.acceptButton.name = PlayerConstants.GUIDANCE_PANEL_ACCEPT_BUTTON_NAME;
        this.cancelButton.name = PlayerConstants.GUIDANCE_PANEL_CANCEL_BUTTON_NAME;

        //set the private variables
        this.errorType = errorType;
        this.termsAndConditionsLinkURL = termsAndConditionsLinkURL;

        this.setupMessaging();

        Security.allowDomain("*");
        super();

        //Build the css
        this.buildCSS();

        //Build the panel and add it to the GuidancePanel MovieClip
        addChild(this.buildPanel());

        this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);

    }

    private function onAddedToStage(event:Event):void {
        this.positionPanel(event);
        this.setupToolTips();
    }

    private function setupMessaging():void {
        //If the error type is "NO_ADS" show no ads messaging, otherwise show pack messaging
        if (this.errorType == NO_ADS) {
            this.title = this.nonStopTitle;
            this.text = this.nonStopText;
        } else {
            this.title = this.subsTitle;
            this.text = this.subsText;
        }
    }

    private function setupToolTips():void {
        if (this.errorType == NO_ADS) {
            var acceptToolTip = new PlayerToolTip(this.acceptButton, "Accept");
            stage.addChild(acceptToolTip);
            var cancelToolTip = new PlayerToolTip(this.cancelButton, "Cancel");
            stage.addChild(cancelToolTip);
        } else {
            var okToolTip = new PlayerToolTip(this.okButton, "Ok");
            stage.addChild(okToolTip);
        }
    }

    private function positionPanel(event:Event):void {
        this.x = (stage.stageWidth / 2) - (this.width / 2);
        this.y = (stage.stageHeight / 2) - (this.height / 2);
    }

    private function buildCSS():void {
        this.css = new StyleSheet;

        var htmlLink:Object = new Object();
        htmlLink.color = "#00A88E";

        this.css.setStyle('a', htmlLink);
    }

    private function buildPanel():Sprite {
        var panel:Sprite = new Sprite();

        panel.addChild(this.buildPanelBG());

        var contentContainer:Sprite = this.buildContentContainer();
        contentContainer.addChild(this.buildWarning());
        contentContainer.addChild(this.buildWarningIcon());
        contentContainer.addChild(this.buildExplanation());
        if (this.errorType == NO_ADS) {
            contentContainer.addChild(this.buildAcceptButton("Accept"));
            contentContainer.addChild(this.buildDeclineButton("Decline"));
        } else {
            contentContainer.addChild(this.buildOkButton("Ok"));
        }
        panel.addChild(contentContainer);

        return panel;

    }

    private function buildPanelBG():Sprite {
        var panelBG:Sprite = new Sprite();

        with (panelBG.graphics) {
            beginFill(0x000000, 0.8);
            drawRoundRect(0, 0, 525, 253, 10);
            endFill();
        }

        return panelBG;
    }

    private function buildContentContainer():Sprite {
        var contentContainer:Sprite = new Sprite();
        //the x and y of this container are the equivalent to padding in CSS
        contentContainer.x = 39;
        contentContainer.y = 10;
        return contentContainer;
    }

    private function buildWarning():TextField {
        var warningLabel = new StyledTextField();
        warningLabel.width = 445;
        warningLabel.wordWrap = true;
        warningLabel.htmlText = this.title;
        warningLabel.multiline = true;
        warningLabel.wordWrap = true;
        warningLabel.y = 0;
        warningLabel.x = 15;
        var formattedWarningLabel:TextField = this.applyWarningFormat(warningLabel);

        return warningLabel;
    }

    private function buildWarningIcon():Sprite {
        var warningIconHolder = new Sprite();
        warningIconHolder.addChild(this.warningIcon);
        warningIconHolder.x = -23;
        warningIconHolder.y = -1;
        return warningIconHolder;
    }

    private function buildExplanation():TextField {

        var explanationLabel = new StyledTextField();
        explanationLabel.width = 460;
        explanationLabel.wordWrap = true;
        explanationLabel.multiline = true;
        explanationLabel.htmlText = this.text;
        explanationLabel.y = 75;
        var formattedWarningLabel:TextField = this.applyInfoFormat(explanationLabel);

        return explanationLabel;
    }

    private function applyWarningFormat(textToFormat:TextField):TextField {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 15;
        textFormat.leading = 4;
        textFormat.color = 0xF15925;
        textFormat.align = "left";

        textToFormat.setTextFormat(textFormat);

        return textToFormat;

    }

    private function applyInfoFormat(textToFormat:TextField):TextField {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 12;
        textFormat.leading = 4;
        textFormat.color = 0xFFFFFF;
        textFormat.align = "left";

        textToFormat.setTextFormat(textFormat);

        return textToFormat;

    }

    private function applyDefaultFormat(textToFormat:TextField) {
        var textFormat:TextFormat = new TextFormat();
        textFormat.color = 0x00A88E;

        textToFormat.setTextFormat(textFormat);
    }

    private function applySmallFormat(textToFormat:TextField) {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 11;

        textToFormat.setTextFormat(textFormat);
    }

    private function applyHoverFormat(textToFormat:TextField) {
        var textFormat:TextFormat = new TextFormat();
        textFormat.color = 0xFFFFFF;

        textToFormat.setTextFormat(textFormat);
    }

    private function buildAcceptButton(label:String):Sprite {

        //setup the hand cursor
        this.acceptButton.useHandCursor = true;
        this.acceptButton.buttonMode = true;
        this.acceptButton.mouseChildren = false;

        this.acceptButton.addChild(this.acceptImageUp);

        this.acceptButton.addEventListener(MouseEvent.MOUSE_OVER, this.onAcceptMouseOver);
        this.acceptButton.addEventListener(MouseEvent.MOUSE_OUT, this.onAcceptMouseOut);
        this.acceptButton.addEventListener(MouseEvent.CLICK, this.onAcceptClick);
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("acceptGuidance", this.onAcceptClick);
        }

        //position the button
        this.acceptButton.x = -5;
        this.acceptButton.y = 184;
        this.acceptButton.height = 48;
        this.acceptButton.width = 108;

        return this.acceptButton;
    }

    private function onAcceptMouseOver(event:MouseEvent):void {
        event.currentTarget.removeChild(this.acceptImageUp);
        event.currentTarget.addChild(this.acceptImageOver);

    }

    private function onAcceptMouseOut(event:MouseEvent):void {
        event.currentTarget.removeChild(this.acceptImageOver);
        event.currentTarget.addChild(this.acceptImageUp);
    }

    private function onAcceptClick(event:MouseEvent = null):void {
        this.visible = false;
        this.dispatchEvent(new Event(OVERUSE_ACCEPTED));
    }

    private function buildDeclineButton(label:String):Sprite {

        //setup the hand cursor
        this.cancelButton.useHandCursor = true;
        this.cancelButton.buttonMode = true;
        this.cancelButton.mouseChildren = false;

        //build the label
        var buttonLabel = new StyledTextField();
        buttonLabel.text = label;
        buttonLabel.x = 25;
        buttonLabel.y = 15;
        buttonLabel.height = 18;
        buttonLabel.width = 50;
        var formattedButtonLabel:TextField = this.applyInfoFormat(buttonLabel);
        this.applyDefaultFormat(formattedButtonLabel);

        //add the label to the button
        this.cancelButton.addChild(formattedButtonLabel);

        this.cancelButton.addEventListener(MouseEvent.MOUSE_OVER, this.onLinkMouseOver);
        this.cancelButton.addEventListener(MouseEvent.MOUSE_OUT, this.onLinkMouseOut);
        this.cancelButton.addEventListener(MouseEvent.CLICK, this.onDeclineClick);
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("rejectGuidance", this.onDeclineClick);
        }

        //position the button
        this.cancelButton.y = 182;
        this.cancelButton.x = 109;

        return this.cancelButton;
    }

    private function onLinkMouseOver(event:MouseEvent):void {
        if (event.currentTarget.getChildAt(0)) {
            this.applyHoverFormat(event.currentTarget.getChildAt(0));
        }
    }

    private function onLinkMouseOut(event:MouseEvent):void {
        if (event.currentTarget.getChildAt(0)) {
            this.applyDefaultFormat(event.currentTarget.getChildAt(0));
        }
    }

    private function onDeclineClick(event:MouseEvent = null):void {
        this.visible = false;
        this.dispatchEvent(new Event(OVERUSE_REJECTED));
    }

    private function buildOkButton(label:String):Sprite {

        //setup the hand cursor
        this.okButton.useHandCursor = true;
        this.okButton.buttonMode = true;
        this.okButton.mouseChildren = false;

        this.okButton.addChild(this.okImageUp);

        this.okButton.addEventListener(MouseEvent.MOUSE_OVER, this.onOkMouseOver);
        this.okButton.addEventListener(MouseEvent.MOUSE_OUT, this.onOkMouseOut);
        this.okButton.addEventListener(MouseEvent.CLICK, this.onOkClick);
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("acceptGuidance", this.onOkClick);
        }

        //position the button
        this.okButton.x = -5;
        this.okButton.y = 184;
        this.okButton.height = 48;
        this.okButton.width = 108;

        return this.okButton;
    }

    private function onOkMouseOver(event:MouseEvent):void {
        event.currentTarget.removeChild(this.okImageUp);
        event.currentTarget.addChild(this.okImageOver);

    }

    private function onOkMouseOut(event:MouseEvent):void {
        event.currentTarget.removeChild(this.okImageOver);
        event.currentTarget.addChild(this.okImageUp);
    }

    private function onOkClick(event:MouseEvent = null):void {
        this.visible = false;
        this.dispatchEvent(new Event(OVERUSE_REJECTED));
    }

    public function getAcceptButton():Sprite {
        return acceptButton;
    }

    public function getCancelButton():Sprite {
        return cancelButton;
    }

    public function getOkButton():Sprite {
        return okButton;
    }

}

}