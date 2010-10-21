package com.seesaw.player.ads {
import flash.display.DisplayObject;

import org.osmf.traits.DisplayObjectTrait;

public class AdProxyDisplayObjectTrait extends DisplayObjectTrait {
    public function AdProxyDisplayObjectTrait(displayObject:DisplayObject, mediaWidth:Number = 0, mediaHeight:Number = 0) {
        super(displayObject, mediaWidth, mediaHeight);
    }

    public function setSize(width:Number, height:Number):void {
        setMediaSize(width, height);
    }
}
}