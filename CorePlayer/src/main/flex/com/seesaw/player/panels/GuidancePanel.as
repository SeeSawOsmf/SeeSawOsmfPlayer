package com.seesaw.player.panels {
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
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
    private var guidanceExplanation:String;
    private var confirmationMessage:String;
    private var parentalControlsSetupLink:String;
    private var findOutMoreLink:String;

    //Embed images
    [Embed(source="resources/acceptButton_up.png")]
    private var acceptImageUpEmbed:Class;
    private var acceptImageUp:Bitmap = new acceptImageUpEmbed();
    [Embed(source="resources/acceptButton_over.png")]
    private var acceptImageOverEmbed:Class;
    private var acceptImageOver:Bitmap = new acceptImageOverEmbed();

    //css
    private var css:StyleSheet;

    /*Constructor
    * Takes: warning:String - the guidance warning that appears at the top of the panel
    *
    */
    public function GuidancePanel(warning:String, explanation:String, confirmationMessage:String, parentalControlsSetup:String, findOutMore:String) {

        //set the private variables
        this.guidanceWarning = warning;
        this.guidanceExplanation = explanation;
        this.confirmationMessage = confirmationMessage;
        this.parentalControlsSetupLink = parentalControlsSetup;
        this.findOutMoreLink = findOutMore;

        Security.allowDomain("*");
        super();

        //Build the css
        this.buildCSS();

        //Build the panel and add it to the GuidancePanel MovieClip
        addChild(this.buildPanel());

        this.addEventListener(Event.ADDED_TO_STAGE, this.positionPanel);

    }

    private function positionPanel(event:Event):void {
        this.x = (stage.stageWidth/2) - (this.width / 2);
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
        contentContainer.addChild(this.buildExplanation());
        contentContainer.addChild(this.buildConfirmationMessage());
        contentContainer.addChild(this.buildAcceptButton("Accept"));
        contentContainer.addChild(this.buildDeclineButton("Decline"));
        contentContainer.addChild(this.buildParentalControlsLink());
        contentContainer.addChild(this.buildFindOutMoreLink());

        panel.addChild(contentContainer);

        return panel;

    }

    private function buildPanelBG():Sprite {
        var panelBG:Sprite = new Sprite();

        with (panelBG.graphics) {
            lineStyle(1, 0x000000);
            beginFill(0x000000, 0.8);
            drawRoundRect(0, 0, 600, 300, 10);
            endFill();
        }

        return panelBG;
    }

    private function buildContentContainer():Sprite {
        var contentContainer:Sprite = new Sprite();
        //the x and y of this container are the equivalent to padding in CSS
        contentContainer.x = 30;
        contentContainer.y = 30;
        return contentContainer;
    }

    private function buildWarning():TextField {
        var warningLabel = new TextField();
        warningLabel.width = 540;
        warningLabel.htmlText = this.guidanceWarning;
        warningLabel.y = 0;
        var formattedWarningLabel:TextField = this.applyWarningFormat(warningLabel);

        return warningLabel;
    }

    private function buildExplanation():TextField {

        var explanationLabel = new TextField();
        explanationLabel.width = 540;
        explanationLabel.htmlText = this.guidanceExplanation;
        explanationLabel.y = 40;
        var formattedWarningLabel:TextField = this.applyInfoFormat(explanationLabel);

        return explanationLabel;
    }

    private function buildConfirmationMessage():TextField {

        var confirmationLabel = new TextField();
        confirmationLabel.width = 540;
        confirmationLabel.htmlText = this.confirmationMessage;
        confirmationLabel.y = 80;
        var formattedWarningLabel:TextField = this.applyInfoFormat(confirmationLabel);

        confirmationLabel.styleSheet = this.css;

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
        textFormat.size = 14;
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

    private function applyHoverFormat(textToFormat:TextField) {
        var textFormat:TextFormat = new TextFormat();
        textFormat.color = 0xFFFFFF;

        textToFormat.setTextFormat(textFormat);
    }

    private function buildAcceptButton(label:String):Sprite {
        var acceptButton:Sprite = new Sprite();

        //setup the hand cursor
        acceptButton.useHandCursor = true;
        acceptButton.buttonMode = true;
        acceptButton.mouseChildren = false;

        //build the label
        /*var buttonLabel = new TextField();
        buttonLabel.text = label;
        buttonLabel.x = 25;
        buttonLabel.y = 15;
        var formattedButtonLabel:TextField = this.applyInfoFormat(buttonLabel);

        //add the label to the button
        acceptButton.addChild(formattedButtonLabel);*/

        acceptButton.addChild(this.acceptImageUp);

        acceptButton.addEventListener(MouseEvent.MOUSE_OVER, this.onAcceptMouseOver);
        acceptButton.addEventListener(MouseEvent.MOUSE_OUT, this.onAcceptMouseOut);
        acceptButton.addEventListener(MouseEvent.CLICK, this.onAcceptClick);

        //position the button
        acceptButton.y = 130;
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
        this.visible = false;
        this.dispatchEvent(new Event(GUIDANCE_ACCEPTED));
    }

    private function buildDeclineButton(label:String):Sprite {
        var declineButton:Sprite = new Sprite();

        //setup the hand cursor
        declineButton.useHandCursor = true;
        declineButton.buttonMode = true;
        declineButton.mouseChildren = false;

        //build the label
        var buttonLabel = new TextField();
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
        declineButton.y = 125;
        declineButton.x = 120;

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
        this.dispatchEvent(new Event(GUIDANCE_DECLINED));
    }

    private function buildParentalControlsLink():Sprite {

        var parentalControlsButton:Sprite = new Sprite();

        //setup the hand cursor
        parentalControlsButton.useHandCursor = true;
        parentalControlsButton.buttonMode = true;
        parentalControlsButton.mouseChildren = false;

        //build the label
        var parentalControlsLabel = new TextField();
        parentalControlsLabel.text = "Set up Parental Controls";
        parentalControlsLabel.x = 0;
        parentalControlsLabel.y = 0;
        parentalControlsLabel.height = 18;
        parentalControlsLabel.width = 140;
        var formattedButtonLabel:TextField = this.applyInfoFormat(parentalControlsLabel);
        this.applyDefaultFormat(formattedButtonLabel);

        //add the label to the button
        parentalControlsButton.addChild(formattedButtonLabel);

        parentalControlsButton.addEventListener(MouseEvent.MOUSE_OVER, this.onLinkMouseOver);
        parentalControlsButton.addEventListener(MouseEvent.MOUSE_OUT, this.onLinkMouseOut);
        parentalControlsButton.addEventListener(MouseEvent.CLICK, this.onParentalControlClick);

        //position the button
        parentalControlsButton.y = 200;
        parentalControlsButton.x = 0;

        return parentalControlsButton;
    }

    private function onParentalControlClick(event:Event):void {
        var request:URLRequest = new URLRequest(this.parentalControlsSetupLink);
        try {
            navigateToURL(request);
        } catch (e:Error) {
            trace("Error occurred!");
        }

    }

    private function buildFindOutMoreLink():Sprite {

        var findOutMoreButton:Sprite = new Sprite();

        //setup the hand cursor
        findOutMoreButton.useHandCursor = true;
        findOutMoreButton.buttonMode = true;
        findOutMoreButton.mouseChildren = false;

        //build the label
        var findOutMoreLabel = new TextField();
        findOutMoreLabel.text = "Find out more";
        findOutMoreLabel.x = 0;
        findOutMoreLabel.y = 0;
        findOutMoreLabel.height = 18;
        findOutMoreLabel.width = 85;
        var formattedButtonLabel:TextField = this.applyInfoFormat(findOutMoreLabel);
        this.applyDefaultFormat(formattedButtonLabel);

        //add the label to the button
        findOutMoreButton.addChild(formattedButtonLabel);

        findOutMoreButton.addEventListener(MouseEvent.MOUSE_OVER, this.onLinkMouseOver);
        findOutMoreButton.addEventListener(MouseEvent.MOUSE_OUT, this.onLinkMouseOut);
        findOutMoreButton.addEventListener(MouseEvent.CLICK, this.onFindOutMoreClick);

        //position the button
        findOutMoreButton.y = 200;
        findOutMoreButton.x = 170;

        return findOutMoreButton;
    }

    private function onFindOutMoreClick(event:Event):void {
        var request:URLRequest = new URLRequest(this.findOutMoreLink);
        try {
            navigateToURL(request);
        } catch (e:Error) {
            trace("Error occurred!");
        }

    }
    
}

}