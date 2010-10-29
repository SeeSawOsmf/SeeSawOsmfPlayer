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
import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.system.Security;

public class PosterFrame extends Sprite {

    // the event to listen for
    public static const LOADED = "LOADED";

    private var posterFrameURL:String;

    private var loadedImage:Loader;

    /*Constructor
     * Takes: warning:String - the guidance warning that appears at the top of the panel
     *
     */
    public function PosterFrame(posterFrameURL:String) {

        this.posterFrameURL = posterFrameURL;

        Security.allowDomain("*");
        super();

        //Build the poster frame
        this.loadedImage = this.buildPosterFrame();

        addChild(this.loadedImage);

        this.loadedImage.contentLoaderInfo.addEventListener(Event.COMPLETE, this.sizePosterFrame);

    }

    private function buildPosterFrame():Loader {
        //get the image url
        var url:String = this.posterFrameURL;

        //loaderContext to prevent the cross domain issues...
        var loaderContext = new LoaderContext(true);

        var pictLdr:Loader = new Loader();
        var pictURL:String = this.posterFrameURL;

        var pictURLReq:URLRequest = new URLRequest(pictURL);
        pictLdr.load(pictURLReq, loaderContext);

        return pictLdr;

    }

    private function processImage(event:Event):void {

        var targetLoader:Loader = Loader(event.target.loader);
        targetLoader.width = 700;
        targetLoader.scaleY = targetLoader.scaleX;

    }

    private function sizePosterFrame(event:Event):void {

        var image:Bitmap = Bitmap(event.currentTarget.content);
        image.width = stage.stageWidth;
        image.height = stage.stageHeight;
        image.smoothing = true;
        this.dispatchEvent(new Event(LOADED));

    }

}

}