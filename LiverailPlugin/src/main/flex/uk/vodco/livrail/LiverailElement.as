package uk.vodco.livrail {
import flash.system.Security;

import mx.controls.SWFLoader;

import org.osmf.elements.ParallelElement;
import org.osmf.elements.SWFElement;
import org.osmf.media.MediaElement;
import org.osmf.media.URLResource;

public class LiverailElement extends MediaElement {


    	public static var TYPE:String = "LIVERAIL_INTERFACE";


		private var modLoaded:Boolean = false;

		private var liveRailModuleLocation:String;

		private var _adManager:*;

		public var contentInfo:XML;

		private var liveRailAdMap:String = "";

		private var liveRailTags:String = "";


		private var videoId:String;


		private var liveRailConfig:Object;


		public var contentObject:Object;

		public var adPlaying:Boolean = false;

		public var currentAdCount:int = 0;

		public var adSlots:int=0;


		private var availabilities:Array = [];

		private var _adPositions:Array = [];

		private var _totalAdPositions:Array = [];

		private var adsEncountered:Array = [];

		private var ageRating:int;

		public var genres:Array;
		public var liverailVersion:String;
		public var liverailPublisherId:String;
		public var programmeId:Number;

		//use a small offset to go back so that we show an ad when resuming at it, instead of skipping it by mistake
		private var _seekOffset:Number = 0.5;
		private var LR_AdvertsArray:Array;

    public function LiverailElement() {

      Security.allowDomain("vox-static.liverail.com");
       var liverailPath:String = "http://vox-static.liverail.com/swf/v4/skins/adplayerskin_1.swf";
       var urlResource:URLResource = new URLResource(liverailPath)
       var element:ParallelElement = new SWFElement(urlResource) as ParallelElement;
        super();
    }
}
}