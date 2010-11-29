package com.seesaw.player.ui {
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.text.TextField;

import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import flash.utils.Timer;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;

public class PlayerToolTip extends Sprite {

    private var logger:ILogger = LoggerFactory.getClassLogger(PlayerToolTip);
    private var toolTipText:String;
    private var toolTipTextField:TextField = new StyledTextField;
    private var toolTipBG:Sprite = new Sprite;
    private var toolTipTimer:Timer = new Timer(1200);

    public function PlayerToolTip(element:Sprite, toolTipText:String) {

        this.toolTipBG.visible = false;
        this.toolTipTextField.visible = false;

        this.toolTipText = toolTipText;

        addChild(this.buildToolTip());

        element.addEventListener(MouseEvent.MOUSE_OUT, this.hideToolTip);
        element.addEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove);
        element.addEventListener(MouseEvent.CLICK, this.handleMouseClick);

        this.toolTipTimer.addEventListener(TimerEvent.TIMER, this.triggerToolTip);

    }

    public function getToolTip():TextField {
        return this.toolTipTextField;
    }

    private function buildToolTip():Sprite {
        
        this.toolTipTextField.text = this.toolTipText;
        this.toolTipTextField.autoSize = TextFieldAutoSize.LEFT;

        this.styleToolTip(this.toolTipTextField);

        this.toolTipTextField.visible = false;

        this.toolTipBG = this.buildToolTipBG();

        this.toolTipBG.addChild(this.toolTipTextField);
        this.toolTipTextField.visible = true;

        return this.toolTipBG;
    }

    private function buildToolTipBG() {

        this.drawToolTipBG();

        return this.toolTipBG;
    }

    private function drawToolTipBG() {

        this.toolTipBG.graphics.clear();
        
        with (this.toolTipBG.graphics) {
            beginFill(0xFFFFFF, 0.6);
            drawRoundRect(0, 0, this.toolTipTextField.width, this.toolTipTextField.height, 6);
            endFill();
        }
        
    }

    private function styleToolTip(textToFormat:TextField):void {

        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 10;
        textFormat.color = 0x000000;
        textFormat.align = "left";
        textFormat.leftMargin = textFormat.rightMargin = 6;

        textToFormat.height = 20;

        textToFormat.setTextFormat(textFormat);

    }

    private function positionToolTip(x, y):void {
        if ((this.toolTipBG.width + stage.mouseX) > stage.stageWidth) {
            this.toolTipBG.x = (stage.stageWidth - this.toolTipBG.width) - 5;
        } else {
            this.toolTipBG.x = x;
        }

        if ((this.toolTipBG.height + y) > stage.stageHeight) {
            var offset:Number = this.toolTipBG.height + 30;
            this.toolTipBG.y = y - offset;
        } else {
            this.toolTipBG.y = y;
        }
    }

    public function updateToolTip(newText:String):void {
        this.toolTipTextField.text = newText;
        this.styleToolTip(this.toolTipTextField);
        this.drawToolTipBG();
    }

    private function handleMouseMove(event:MouseEvent):void {
        this.toolTipBG.visible = false;
        this.toolTipTimer.start();
    }

    private function handleMouseClick(event:MouseEvent):void {
        this.toolTipBG.visible = false;
        this.toolTipTimer.start();
    }

    private function hideToolTip(event:MouseEvent):void {
        this.toolTipBG.visible = false;
        this.toolTipTimer.stop();
    }

    private function triggerToolTip(event:TimerEvent):void {
        this.positionToolTip(stage.mouseX, stage.mouseY + 19);
        this.toolTipBG.visible = true;
        this.toolTipTimer.stop();
    }
}
}