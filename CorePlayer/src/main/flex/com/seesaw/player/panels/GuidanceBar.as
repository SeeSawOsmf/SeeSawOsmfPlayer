package com.seesaw.player.panels {
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.system.Security;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFormat;
import com.seesaw.player.ui.StyledTextField;

public class GuidanceBar extends Sprite {

    //Guidance warning string passed into the constructor
    private var guidanceWarning:String;

    private var panelBG:Sprite;

    //css
    private var css:StyleSheet;

    [Embed(source="resources/Gcircle.png")]
    private var guidanceCircleEmbed:Class;
    private var guidanceCircle:Bitmap = new guidanceCircleEmbed();

    /*Constructor
    * Takes: warning:String - the guidance warning that appears at the top of the panel
    *
    */
    public function GuidanceBar(warning:String) {

        //set the private variables
        this.guidanceWarning = warning;

        Security.allowDomain("*");
        super();

        //Build the panel and add it to the GuidancePanel MovieClip
        addChild(this.buildPanel());

        this.addEventListener(Event.ADDED_TO_STAGE, this.positionPanel);

    }

    private function positionPanel(event:Event):void {
        this.y = stage.stageHeight - this.height;
        this.width = stage.stageWidth;
    }

    private function buildPanel():Sprite {
        var panel:Sprite = new Sprite();
        
        panel.addChild(this.buildPanelBG());

        var contentContainer:Sprite = this.buildContentContainer();
        contentContainer.addChild(this.buildGuidanceLabel());
        contentContainer.addChild(this.buildWarning());
        contentContainer.addChild(this.buildWarningIcon());

        panel.addChild(contentContainer);

        return panel;

    }

    private function buildPanelBG():Sprite {

        this.panelBG = new Sprite();

        with (this.panelBG.graphics) {
            beginFill(0xFF0000, 0.6);
            drawRoundRect(0, 0, 550, 38, 0);
            endFill();
        }

        return this.panelBG;
    }

    private function buildContentContainer():Sprite {
        var contentContainer:Sprite = new Sprite();
        //the x and y of this container are the equivalent to padding in CSS
        contentContainer.x = 10;
        contentContainer.y = 5;
        return contentContainer;
    }

    private function buildGuidanceLabel():TextField {
        var guidanceLabel = new StyledTextField();
        guidanceLabel.height = 15;
        guidanceLabel.width = 540;
        guidanceLabel.htmlText = "Guidance:";
        guidanceLabel.y = 0;
        this.applyWarningFormat(guidanceLabel);

        return guidanceLabel;
    }

    private function buildWarning():TextField {
        var warningLabel = new StyledTextField();
        warningLabel.height = 18;
        warningLabel.width = 540;
        warningLabel.htmlText = this.guidanceWarning;
        warningLabel.y = 11;
        this.applyWarningFormat(warningLabel);

        return warningLabel;
    }

    private function buildWarningIcon():Sprite {
        var warningIconHolder = new Sprite();
        warningIconHolder.addChild(this.guidanceCircle);
        warningIconHolder.x = 510;
        warningIconHolder.y = 4;
        return warningIconHolder;
    }

    private function applyWarningFormat(textToFormat:TextField):TextField {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 11;
        textFormat.color = 0xFFFFFF;
        textFormat.align = "left";

        textToFormat.setTextFormat(textFormat);

        return textToFormat;
    }

}

}