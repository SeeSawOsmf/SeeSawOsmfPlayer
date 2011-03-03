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
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.system.Security;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFormat;

public class GuidancePanel extends Sprite {

    public static const GUIDANCE_ACCEPTED = "GUIDANCE_ACCEPTED";
    public static const GUIDANCE_DECLINED = "GUIDANCE_DECLINED";

    //Guidance warning string passed into the constructor
    private var guidanceWarning:String;
    private var assetType:String;
    private var age:String;
    private var parentalControlsSetupLink:String;
    private var findOutMoreLink:String;
    private var termsURL:String;

    private var urlPathPortion:String;

    public static const COOKIE_PATH_NAME_PORTION:String = "window.location.pathname.toString";

    private var assetWarning:String = "This %TYPE_TOKEN% isn't suitable for younger viewers.<br/><br/>";
    private var ageMessage:String = "Please confirm you are aged %AGE_TOKEN% or older " +
            "and accept our <a href=\"%TERMSURL%\"><font color=\"#00A88E\">Terms and Conditions.</font></a>";

    //components which need tooltips
    private var acceptButton:Sprite = new Sprite();
    private var cancelButton:Sprite = new Sprite();
    private var parentalControlsButton:Sprite = new Sprite();
    private var findOutMoreButton:Sprite = new Sprite();
    private var warningLabel:StyledTextField = new StyledTextField();

    //layout info
    private var yFill:Number = 0;

    //Embed images
    [Embed(source="resources/accept_up.png")]
    private var acceptImageUpEmbed:Class;
    private var acceptImageUp:Bitmap = new acceptImageUpEmbed();
    [Embed(source="resources/accept_over.png")]
    private var acceptImageOverEmbed:Class;
    private var acceptImageOver:Bitmap = new acceptImageOverEmbed();
    [Embed(source="resources/Gcircle.png")]
    private var guidanceCircleEmbed:Class;
    private var guidanceCircle:Bitmap = new guidanceCircleEmbed();

    //css
    private var css:StyleSheet;

    /*Constructor
     * Takes: warning:String - the guidance warning that appears at the top of the panel
     *
     */
    public function GuidancePanel(warning:String, assetType:String, age:String, parentalControlsSetup:String, findOutMore:String, termsURL:String) {

        this.acceptButton.name = PlayerConstants.GUIDANCE_PANEL_ACCEPT_BUTTON_NAME;
        this.cancelButton.name = PlayerConstants.GUIDANCE_PANEL_CANCEL_BUTTON_NAME;

        //set the private variables
        this.guidanceWarning = warning;
        this.assetType = assetType;
        this.age = age;
        this.parentalControlsSetupLink = parentalControlsSetup;
        this.findOutMoreLink = findOutMore;
        this.termsURL = termsURL;

        if (ExternalInterface.available) {
            this.urlPathPortion = ExternalInterface.call(COOKIE_PATH_NAME_PORTION);
        }

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

    private function setupToolTips():void {
        var acceptToolTip = new PlayerToolTip(this.acceptButton, "Accept");
        stage.addChild(acceptToolTip);
        var cancelToolTip = new PlayerToolTip(this.cancelButton, "Decline");
        stage.addChild(cancelToolTip);
        var findOutMoreToolTip = new PlayerToolTip(this.findOutMoreButton, "Find out more");
        stage.addChild(findOutMoreToolTip);
        var parentalControlsToolTip = new PlayerToolTip(this.parentalControlsButton, "Set up Parental Controls");
        stage.addChild(parentalControlsToolTip);
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

        var contentContainer:Sprite = this.buildContentContainer();
        contentContainer.addChild(this.buildWarning());
        contentContainer.addChild(this.buildWarningIcon());
        contentContainer.addChild(this.buildExplanation());
        contentContainer.addChild(this.buildConfirmationMessage());
        contentContainer.addChild(this.buildActions());

        panel.addChild(this.buildPanelBG());

        panel.addChild(contentContainer);

        return panel;

    }

    private function buildPanelBG():Sprite {
        var panelBG:Sprite = new Sprite();

        with (panelBG.graphics) {
            beginFill(0x000000, 0.8);
            drawRoundRect(0, 0, 525, (this.yFill + 60), 10);
            endFill();
        }

        return panelBG;
    }

    private function buildContentContainer():Sprite {
        var contentContainer:Sprite = new Sprite();
        //the x and y of this container are the equivalent to padding in CSS
        contentContainer.x = 39;
        contentContainer.y = 32;
        return contentContainer;
    }

    private function buildWarning():TextField {
        this.warningLabel.width = 460;
        this.warningLabel.htmlText = this.guidanceWarning;
        this.warningLabel.wordWrap = true;
        this.warningLabel.multiline = true;
        this.warningLabel.y = 0;
        var formattedWarningLabel:TextField = this.applyWarningFormat(this.warningLabel);

        this.yFill += this.warningLabel.height;

        return this.warningLabel;
    }

    private function buildWarningIcon():Sprite {
        var warningIconHolder = new Sprite();
        warningIconHolder.addChild(this.guidanceCircle);
        warningIconHolder.x = -23;
        warningIconHolder.y = -1;
        return warningIconHolder;
    }

    private function buildExplanation():TextField {

        var explanationLabel = new StyledTextField();
        explanationLabel.width = 500;
        explanationLabel.wordWrap = true;
        explanationLabel.htmlText = this.assetWarning.replace("%TYPE_TOKEN%", this.assetType);

        this.yFill += 15;

        explanationLabel.y = this.yFill;
        var formattedWarningLabel:TextField = this.applyInfoFormat(explanationLabel)

        this.yFill += explanationLabel.height;

        return explanationLabel;
    }

    private function buildConfirmationMessage():TextField {

        var confirmationLabel = new StyledTextField();
        confirmationLabel.width = 500;
        confirmationLabel.wordWrap = true;
        confirmationLabel.htmlText = this.ageMessage.replace("%TYPE_TOKEN%", this.assetType).replace("%AGE_TOKEN%", this.age).replace("%TERMSURL%", this.termsURL);

        this.yFill += 15;

        confirmationLabel.y = this.yFill;
        var formattedWarningLabel:TextField = this.applyInfoFormat(confirmationLabel);

        confirmationLabel.styleSheet = this.css;

        this.yFill += confirmationLabel.height;

        return confirmationLabel;
    }

    private function applyWarningFormat(textToFormat:TextField):TextField {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 16;
        textFormat.color = 0xF15925;
        textFormat.align = "left";

        textToFormat.setTextFormat(textFormat);

        return textToFormat;

    }

    private function applyInfoFormat(textToFormat:TextField):TextField {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 12;
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

        //build the label
        /*var buttonLabel = new TextField();
         buttonLabel.text = label;
         buttonLabel.x = 25;
         buttonLabel.y = 15;
         var formattedButtonLabel:TextField = this.applyInfoFormat(buttonLabel);

         //add the label to the button
         acceptButton.addChild(formattedButtonLabel);*/

        this.acceptButton.addChild(this.acceptImageUp);

        this.acceptButton.addEventListener(MouseEvent.MOUSE_OVER, this.onAcceptMouseOver);
        this.acceptButton.addEventListener(MouseEvent.MOUSE_OUT, this.onAcceptMouseOut);
        this.acceptButton.addEventListener(MouseEvent.CLICK, this.onAcceptClick);
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("acceptGuidance", this.onAcceptClick);
        }

        //position the button
        this.acceptButton.x = -5;
        this.acceptButton.y = 0;
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
        this.dispatchEvent(new Event(GUIDANCE_ACCEPTED));
    }

    private function buildActions():Sprite {
        var actionsContainer:Sprite = new Sprite();

        actionsContainer.addChild(this.buildAcceptButton("Accept"));
        actionsContainer.addChild(this.buildDeclineButton("Decline"));
        actionsContainer.addChild(this.buildParentalControlsLink());
        actionsContainer.addChild(this.buildFindOutMoreLink());

        this.yFill += 15;
        actionsContainer.y = this.yFill;

        this.yFill += actionsContainer.height;

        return actionsContainer;
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
        this.cancelButton.y = 0;
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
        this.dispatchEvent(new Event(GUIDANCE_DECLINED));
    }

    private function buildParentalControlsLink():Sprite {

        //setup the hand cursor
        this.parentalControlsButton.useHandCursor = true;
        this.parentalControlsButton.buttonMode = true;
        this.parentalControlsButton.mouseChildren = false;

        //build the label
        var parentalControlsLabel = new StyledTextField();
        parentalControlsLabel.text = "Set up Parental Controls";
        parentalControlsLabel.x = 0;
        parentalControlsLabel.y = 0;
        parentalControlsLabel.height = 18;
        parentalControlsLabel.width = 140;
        var formattedButtonLabel:TextField = this.applyInfoFormat(parentalControlsLabel);
        this.applyDefaultFormat(formattedButtonLabel);
        this.applySmallFormat(formattedButtonLabel);

        //add the label to the button
        this.parentalControlsButton.addChild(formattedButtonLabel);

        this.parentalControlsButton.addEventListener(MouseEvent.MOUSE_OVER, this.onLinkMouseOver);
        this.parentalControlsButton.addEventListener(MouseEvent.MOUSE_OUT, this.onLinkMouseOut);
        this.parentalControlsButton.addEventListener(MouseEvent.CLICK, this.onParentalControlClick);

        //position the button
        this.parentalControlsButton.y = 73;
        this.parentalControlsButton.x = 0;

        return this.parentalControlsButton;
    }

    private function onParentalControlClick(event:Event):void {
        var request:URLRequest = new URLRequest(this.parentalControlsSetupLink + this.urlPathPortion);
        try {
            navigateToURL(request, "_self");
        } catch (e:Error) {
            trace("Error occurred!");
        }

    }

    private function buildFindOutMoreLink():Sprite {

        //setup the hand cursor
        this.findOutMoreButton.useHandCursor = true;
        this.findOutMoreButton.buttonMode = true;
        this.findOutMoreButton.mouseChildren = false;

        //build the label
        var findOutMoreLabel = new StyledTextField();
        findOutMoreLabel.text = "Find out more";
        findOutMoreLabel.x = 0;
        findOutMoreLabel.y = 0;
        findOutMoreLabel.height = 18;
        findOutMoreLabel.width = 85;
        var formattedButtonLabel:TextField = this.applyInfoFormat(findOutMoreLabel);
        this.applyDefaultFormat(formattedButtonLabel);
        this.applySmallFormat(formattedButtonLabel);

        //add the label to the button
        this.findOutMoreButton.addChild(formattedButtonLabel);

        this.findOutMoreButton.addEventListener(MouseEvent.MOUSE_OVER, this.onLinkMouseOver);
        this.findOutMoreButton.addEventListener(MouseEvent.MOUSE_OUT, this.onLinkMouseOut);
        this.findOutMoreButton.addEventListener(MouseEvent.CLICK, this.onFindOutMoreClick);

        //position the button
        this.findOutMoreButton.y = 73;
        this.findOutMoreButton.x = 147;

        return this.findOutMoreButton;
    }

    private function onFindOutMoreClick(event:Event):void {
        var request:URLRequest = new URLRequest(this.findOutMoreLink);
        try {
            navigateToURL(request, "_self");
        } catch (e:Error) {
            trace("Error occurred!");
        }

    }

    public function getAcceptButton():Sprite {
        return acceptButton;
    }

    public function getCancelButton():Sprite {
        return cancelButton;
    }

}

}