package com.seesaw.player.ui {
import flash.text.TextField;
import flash.text.TextFormat;

public class DefaultTextFormat extends TextFormat {

    private var textToFormat:TextField;

    public function DefaultTextFormat(text:TextField):void {
        this.textToFormat = text;
    }

    public function applyFontFace():void {

        var fontfaceFormat:TextFormat = new TextFormat();
        fontfaceFormat.font = "Arial";

        this.textToFormat.setTextFormat(fontfaceFormat);
    }

    public function applyThemeColor():void {

        var themeColorFormat:TextFormat = new TextFormat();
        themeColorFormat.color = 0x00A78D;

        this.textToFormat.setTextFormat(themeColorFormat);
    }
    
}

}