/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the
 * License athttp://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 */

package com.seesaw.player.preloader {
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.utils.ByteArray;

public class Preloader extends Sprite {

    [ Embed("/assets/loading.swf", mimeType="application/octet-stream") ]
    private var loaderAsset:Class;
    private var loader:Loader;

    public function Preloader() {
        loader = new Loader();
        loader.cacheAsBitmap = true;
        loader.loadBytes(new loaderAsset() as ByteArray);
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSwfLoaded);
        loader.visible = false;
        addChild(loader);
    }

    private function onSwfLoaded(e:Event):void {
        if(stage) {
            loader.x = stage.stageWidth / 2 - loader.contentLoaderInfo.width / 2;
            loader.y = stage.stageHeight / 2 - loader.contentLoaderInfo.height / 2;
        }
        loader.visible = true;
    }
}
}