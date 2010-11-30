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
import com.seesaw.player.ui.PlayerToolTip;
import com.seesaw.player.ui.StyledTextField;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.system.Security;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

public class ParentalControlsPanel extends Sprite {

    public static const PARENTAL_CHECK_PASSED = "PARENTAL_CHECK_PASSED";
    public static const PARENTAL_CHECK_FAILED = "PARENTAL_CHECK_FAILED";

    private var toolTip:PlayerToolTip;

    //Guidance warning string passed into the constructor
    private var guidanceWarning:String;
    private var guidanceExplanation:String;
    private var confirmationMessage:String;
    private var moreAboutParentalControlsLink:String;
    private var turnOffParentalControlsLink:String;

    private var forgotPasswordButton:Sprite = new Sprite();
    private var acceptButton:Sprite = new Sprite();
    private var declineButton:Sprite = new Sprite();
    private var parentalControlsButton:Sprite = new Sprite();
    private var turnOffControlsButton:Sprite = new Sprite();

    //Password logic related
    private var parentalControlPasswordInput = new TextField();
    private var passwordError = new StyledTextField();
    private var passwordEntryBG = new Sprite();
    private var passwordEntryErrorBG = new Sprite();
    private var hashedPassword:String;
    private var enteredPassword:String;

    //Embed images
    [Embed(source="resources/acceptButton_up.png")]
    private var acceptImageUpEmbed:Class;
    private var acceptImageUp:Bitmap = new acceptImageUpEmbed();
    [Embed(source="resources/acceptButton_over.png")]
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
    public function ParentalControlsPanel(password:String, warning:String, explanation:String, confirmationMessage:String, moreAboutParentalControlsLink:String, turnOffParentalControlsLink:String) {

        //set the private variables
        this.hashedPassword = password;
        this.guidanceWarning = warning;
        this.guidanceExplanation = explanation;
        this.confirmationMessage = confirmationMessage;
        this.moreAboutParentalControlsLink = moreAboutParentalControlsLink;
        this.turnOffParentalControlsLink = turnOffParentalControlsLink;

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
        var acceptToolTip = new PlayerToolTip(this.acceptButton, "Enter");
        stage.addChild(acceptToolTip);
        var cancelToolTip = new PlayerToolTip(this.declineButton, "Cancel");
        stage.addChild(cancelToolTip);
        var forgotPasswordToolTip = new PlayerToolTip(this.forgotPasswordButton, "Forgot password?");
        stage.addChild(forgotPasswordToolTip);
        var findOutMoreToolTip = new PlayerToolTip(this.turnOffControlsButton, "Turn off Parental Controls");
        stage.addChild(findOutMoreToolTip);
        var parentalControlsToolTip = new PlayerToolTip(this.parentalControlsButton, "More about Parental Controls");
        stage.addChild(parentalControlsToolTip);
    }

    private function checkPassword():void {
        if (this.hashedPassword == this.enteredPassword) {
            this.visible = false;
            this.dispatchEvent(new Event(PARENTAL_CHECK_PASSED));
        } else {
            this.showErrorState();
        }
    }

    private function showErrorState():void {
        this.passwordError.visible = true;
        this.passwordEntryErrorBG.visible = true;
        this.parentalControlPasswordInput.text = "";
        this.passwordEntryBG.visible = false;
    }

    private function hideErrorState():void {
        this.passwordError.visible = false;
        this.passwordEntryBG.visible = true;
        this.passwordEntryErrorBG.visible = false;
    }

    //Panel build function
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
        contentContainer.addChild(this.buildTitle());
        contentContainer.addChild(this.buildWarning());
        contentContainer.addChild(this.buildWarningIcon());
        contentContainer.addChild(this.buildExplanation());
        contentContainer.addChild(this.buildConfirmationMessage());
        contentContainer.addChild(this.buildEnterMessage());
        contentContainer.addChild(this.buildPasswordLabel());
        contentContainer.addChild(this.buildPasswordEntryBG());
        contentContainer.addChild(this.buildPasswordEntryErrorBG());
        contentContainer.addChild(this.buildPasswordEntry());
        contentContainer.addChild(this.buildPasswordError());
        contentContainer.addChild(this.buildForgotPasswordLink());
        contentContainer.addChild(this.buildAcceptButton("Enter"));
        contentContainer.addChild(this.buildDeclineButton("Cancel"));
        contentContainer.addChild(this.buildParentalControlsLink());
        contentContainer.addChild(this.buildTurnOffControlsLink());
        panel.addChild(contentContainer);

        return panel;

    }

    private function buildPanelBG():Sprite {
        var panelBG:Sprite = new Sprite();

        with (panelBG.graphics) {
            lineStyle(1, 0x000000);
            beginFill(0x000000, 0.8);
            drawRoundRect(0, 0, 525, 353, 10);
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

    private function buildTitle():TextField {
        var titleLabel = new StyledTextField();
        titleLabel.width = 500;
        titleLabel.htmlText = 'Parental Controls';
        titleLabel.y = 0;
        var formattedWarningLabel:TextField = this.applyTitleFormat(titleLabel);

        return titleLabel;
    }

    private function buildWarning():TextField {
        var warningLabel = new StyledTextField();
        warningLabel.width = 500;
        warningLabel.htmlText = this.guidanceWarning;
        warningLabel.y = 32;
        var formattedWarningLabel:TextField = this.applyWarningFormat(warningLabel);

        return warningLabel;
    }

    private function buildWarningIcon():Sprite {
        var warningIconHolder = new Sprite();
        warningIconHolder.addChild(this.guidanceCircle);
        warningIconHolder.x = -26;
        warningIconHolder.y = 31;
        return warningIconHolder;
    }

    private function buildExplanation():TextField {

        var explanationLabel = new StyledTextField();
        explanationLabel.width = 500;
        explanationLabel.htmlText = this.guidanceExplanation;
        explanationLabel.y = 66;
        var formattedWarningLabel:TextField = this.applyInfoFormat(explanationLabel);

        return explanationLabel;
    }

    private function buildEnterMessage():TextField {

        var explanationLabel = new StyledTextField();
        explanationLabel.width = 500;
        explanationLabel.htmlText = 'Please enter your Parental Control password to continue.';
        explanationLabel.y = 100;
        var formattedWarningLabel:TextField = this.applyInfoFormat(explanationLabel);

        return explanationLabel;
    }

    private function buildPasswordLabel():TextField {

        var passwordLabel = new StyledTextField();
        passwordLabel.width = 500;
        passwordLabel.htmlText = "Enter password";
        passwordLabel.y = 135;
        var formattedWarningLabel:TextField = this.applyInfoFormat(passwordLabel);

        return passwordLabel;
    }

    private function buildPasswordEntryBG():Sprite {

        with (this.passwordEntryBG.graphics) {
            beginFill(0xFFFFFF);
            drawRoundRect(0, 0, 100, 20, 6);
            endFill();
        }

        this.passwordEntryBG.x = 113;
        this.passwordEntryBG.y = 135;

        return this.passwordEntryBG;
    }

    private function buildPasswordEntryErrorBG():Sprite {

        with (this.passwordEntryErrorBG.graphics) {
            lineStyle(2, 0xFF0000);
            beginFill(0xFFFFFF);
            drawRoundRect(0, 0, 100, 20, 6);
            endFill();
        }

        this.passwordEntryErrorBG.x = 113;
        this.passwordEntryErrorBG.y = 135;

        this.passwordEntryErrorBG.visible = false;

        return this.passwordEntryErrorBG;
    }

    private function buildPasswordEntry():TextField {

        this.parentalControlPasswordInput.name = "passwordEntry";
        this.parentalControlPasswordInput.autoSize = TextFieldAutoSize.NONE;
        this.parentalControlPasswordInput.selectable = true;
        this.parentalControlPasswordInput.displayAsPassword = true;
        this.parentalControlPasswordInput.maxChars = 12;
        this.parentalControlPasswordInput.height = 22;
        this.parentalControlPasswordInput.width = 100;
        this.parentalControlPasswordInput.type = TextFieldType.INPUT;

        this.parentalControlPasswordInput.x = 114;
        this.parentalControlPasswordInput.y = 136;

        return this.parentalControlPasswordInput;
    }

    private function buildPasswordError():TextField {

        this.passwordError.width = 222;
        this.passwordError.htmlText = "Invalid password. Please try again.";
        this.passwordError.x = 223;
        this.passwordError.y = 135;
        this.passwordError.visible = false;
        var formattedWarningLabel:TextField = this.applyErrorFormat(this.passwordError);

        return this.passwordError;
    }

    private function buildForgotPasswordLink():Sprite {



        //setup the hand cursor
        forgotPasswordButton.useHandCursor = true;
        forgotPasswordButton.buttonMode = true;
        forgotPasswordButton.mouseChildren = false;

        //build the label
        var forgotPasswordLabel = new StyledTextField();
        forgotPasswordLabel.text = "Forgot password?";
        forgotPasswordLabel.x = 0;
        forgotPasswordLabel.y = 0;
        forgotPasswordLabel.height = 18;
        forgotPasswordLabel.width = 94;
        var formattedButtonLabel:TextField = this.applyInfoFormat(forgotPasswordLabel);
        this.applyDefaultFormat(formattedButtonLabel);
        this.applySmallFormat(formattedButtonLabel);

        //add the label to the button
        forgotPasswordButton.addChild(formattedButtonLabel);

        forgotPasswordButton.addEventListener(MouseEvent.MOUSE_OVER, this.onLinkMouseOver);
        forgotPasswordButton.addEventListener(MouseEvent.MOUSE_OUT, this.onLinkMouseOut);
        forgotPasswordButton.addEventListener(MouseEvent.CLICK, this.onParentalControlClick);

        //position the button
        forgotPasswordButton.y = 165;
        forgotPasswordButton.x = 0;

        return forgotPasswordButton;
    }

    private function buildConfirmationMessage():TextField {

        var confirmationLabel = new StyledTextField();
        confirmationLabel.width = 500;
        confirmationLabel.htmlText = this.confirmationMessage;
        confirmationLabel.y = 67;
        var formattedWarningLabel:TextField = this.applyInfoFormat(confirmationLabel);

        confirmationLabel.styleSheet = this.css;

        return confirmationLabel;
    }

    private function applyTitleFormat(textToFormat:TextField):TextField {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 16;
        textFormat.color = 0xFFFFFF;
        textFormat.align = "left";

        textToFormat.setTextFormat(textFormat);

        return textToFormat;

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
        textFormat.size = 14;
        textFormat.color = 0xFFFFFF;
        textFormat.align = "left";

        textToFormat.setTextFormat(textFormat);

        return textToFormat;

    }

    private function applyErrorFormat(textToFormat:TextField):TextField {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 14;
        textFormat.color = 0xFF0000;
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
        acceptButton.useHandCursor = true;
        acceptButton.buttonMode = true;
        acceptButton.mouseChildren = false;

        acceptButton.addChild(this.acceptImageUp);

        acceptButton.addEventListener(MouseEvent.MOUSE_OVER, this.onAcceptMouseOver);
        acceptButton.addEventListener(MouseEvent.MOUSE_OUT, this.onAcceptMouseOut);
        acceptButton.addEventListener(MouseEvent.CLICK, this.onAcceptClick);

        //position the button
        acceptButton.y = 201;
        acceptButton.height = 40;
        acceptButton.width = 100;

        return acceptButton;
    }

    private function onAcceptMouseOver(event:MouseEvent):void {
        event.currentTarget.removeChild(this.acceptImageUp);
        event.currentTarget.addChild(this.acceptImageOver);

    }

    private function onAcceptMouseOut(event:MouseEvent):void {
        event.currentTarget.removeChild(this.acceptImageOver);
        event.currentTarget.addChild(this.acceptImageUp);
    }

    private function onAcceptClick(event:MouseEvent):void {
        this.enteredPassword = this.parentalControlPasswordInput.text;
        this.checkPassword();
    }

    private function buildDeclineButton(label:String):Sprite {

        //setup the hand cursor
        declineButton.useHandCursor = true;
        declineButton.buttonMode = true;
        declineButton.mouseChildren = false;

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
        declineButton.addChild(formattedButtonLabel);

        declineButton.addEventListener(MouseEvent.MOUSE_OVER, this.onLinkMouseOver);
        declineButton.addEventListener(MouseEvent.MOUSE_OUT, this.onLinkMouseOut);
        declineButton.addEventListener(MouseEvent.CLICK, this.onDeclineClick);

        //position the button
        declineButton.y = 197;
        declineButton.x = 109;

        return declineButton;
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

    private function onDeclineClick(event:MouseEvent):void {
        this.visible = false;
        this.dispatchEvent(new Event(PARENTAL_CHECK_FAILED));
    }

    private function buildParentalControlsLink():Sprite {

        //setup the hand cursor
        parentalControlsButton.useHandCursor = true;
        parentalControlsButton.buttonMode = true;
        parentalControlsButton.mouseChildren = false;

        //build the label
        var parentalControlsLabel = new StyledTextField();
        parentalControlsLabel.text = "More about Parental Controls";
        parentalControlsLabel.x = 0;
        parentalControlsLabel.y = 0;
        parentalControlsLabel.height = 18;
        parentalControlsLabel.width = 143;
        var formattedButtonLabel:TextField = this.applyInfoFormat(parentalControlsLabel);
        this.applyDefaultFormat(formattedButtonLabel);
        this.applySmallFormat(formattedButtonLabel);

        //add the label to the button
        parentalControlsButton.addChild(formattedButtonLabel);

        parentalControlsButton.addEventListener(MouseEvent.MOUSE_OVER, this.onLinkMouseOver);
        parentalControlsButton.addEventListener(MouseEvent.MOUSE_OUT, this.onLinkMouseOut);
        parentalControlsButton.addEventListener(MouseEvent.CLICK, this.onParentalControlClick);

        //position the button
        parentalControlsButton.y = 270;
        parentalControlsButton.x = 0;

        return parentalControlsButton;
    }

    private function onParentalControlClick(event:Event):void {
        var request:URLRequest = new URLRequest(this.moreAboutParentalControlsLink);
        try {
            navigateToURL(request);
        } catch (e:Error) {
            trace("Error occurred!");
        }

    }

    private function buildTurnOffControlsLink():Sprite {

        //setup the hand cursor
        turnOffControlsButton.useHandCursor = true;
        turnOffControlsButton.buttonMode = true;
        turnOffControlsButton.mouseChildren = false;

        //build the label
        var turnOffControlsLabel = new StyledTextField();
        turnOffControlsLabel.text = "Turn off Parental Controls";
        turnOffControlsLabel.x = 0;
        turnOffControlsLabel.y = 0;
        turnOffControlsLabel.height = 18;
        turnOffControlsLabel.width = 130;
        var formattedButtonLabel:TextField = this.applyInfoFormat(turnOffControlsLabel);
        this.applyDefaultFormat(formattedButtonLabel);
        this.applySmallFormat(formattedButtonLabel);

        //add the label to the button
        turnOffControlsButton.addChild(formattedButtonLabel);

        turnOffControlsButton.addEventListener(MouseEvent.MOUSE_OVER, this.onLinkMouseOver);
        turnOffControlsButton.addEventListener(MouseEvent.MOUSE_OUT, this.onLinkMouseOut);
        turnOffControlsButton.addEventListener(MouseEvent.CLICK, this.onFindOutMoreClick);

        //position the button
        turnOffControlsButton.y = 270;
        turnOffControlsButton.x = 157;

        return turnOffControlsButton;
    }

    private function onFindOutMoreClick(event:Event):void {
        var request:URLRequest = new URLRequest(this.turnOffParentalControlsLink);
        try {
            navigateToURL(request);
        } catch (e:Error) {
            trace("Error occurred!");
        }

    }

}

}