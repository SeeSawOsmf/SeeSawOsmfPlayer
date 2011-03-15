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
        if (stage) {
            loader.x = stage.stageWidth / 2 - loader.contentLoaderInfo.width / 2;
            loader.y = stage.stageHeight / 2 - loader.contentLoaderInfo.height / 2;
        }
        loader.visible = true;
         dispatchEvent(new Event("preloaderLoaded"));
    }
}
}