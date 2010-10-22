package com.seesaw.player.posterFrame {
import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.text.TextFormat;

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