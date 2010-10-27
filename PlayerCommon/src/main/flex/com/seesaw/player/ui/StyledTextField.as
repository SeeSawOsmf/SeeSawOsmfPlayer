package com.seesaw.player.ui {
import flash.text.TextField;
import flash.text.TextFormat;

public class StyledTextField extends TextField {

    public function StyledTextField():void {
        //Instantiate the TextFormat
        var format:TextFormat = new TextFormat();

        //Add text styles here...
        format.font = "Arial";
        format.color = 0x00A78D;

        //apply the styles to the TextField
        defaultTextFormat = format;
    }
    
}

}