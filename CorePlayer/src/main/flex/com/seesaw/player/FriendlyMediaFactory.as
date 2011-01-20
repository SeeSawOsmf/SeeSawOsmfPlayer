/**
 * Created by IntelliJ IDEA.
 * User: bmeade
 * Date: 18/01/11
 * Time: 12:00
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player {
import com.seesaw.player.netloaders.FriendlyNetLoader;
import com.seesaw.player.netloaders.FriendlyRTMPDynamicStreamingNetLoader;

import flash.events.NetStatusEvent;

import org.osmf.elements.AudioElement;
import org.osmf.elements.F4MElement;
import org.osmf.elements.F4MLoader;
import org.osmf.elements.ImageElement;
import org.osmf.elements.ImageLoader;
import org.osmf.elements.SWFElement;
import org.osmf.elements.SWFLoader;
import org.osmf.elements.SoundLoader;
import org.osmf.elements.VideoElement;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaFactoryItem;
import org.osmf.net.MulticastNetLoader;
import org.osmf.net.dvr.DVRCastNetLoader;
import org.osmf.net.httpstreaming.HTTPStreamingNetLoader;

public class FriendlyMediaFactory extends MediaFactory {
    public function FriendlyMediaFactory() {

  		super();


	    init();

        rtmpStreamingNetLoader.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamNetStatusEvent);
        netLoader.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamNetStatusEvent);
		}

		// Internals
		//

		private function init():void
		{
			f4mLoader = new F4MLoader(this);
			addItem
				( new MediaFactoryItem
					( "org.osmf.elements.f4m"
					, f4mLoader.canHandleResource
					, function():MediaElement
						{
							return new F4MElement(null, f4mLoader);
						}
					)
				);

			dvrCastLoader = new DVRCastNetLoader();
			addItem
				( new MediaFactoryItem
					( "org.osmf.elements.video.dvr.dvrcast"
					, dvrCastLoader.canHandleResource
					, function():MediaElement
						{
							return new VideoElement(null, dvrCastLoader);
						}
					)
				);


			{
			httpStreamingNetLoader = new HTTPStreamingNetLoader();
			addItem
				( new MediaFactoryItem
					( "org.osmf.elements.video.httpstreaming"
					, httpStreamingNetLoader.canHandleResource
					, function():MediaElement
						{
							return new VideoElement(null, httpStreamingNetLoader);
						}
					)
				);

			multicastLoader = new MulticastNetLoader();
			addItem
				( new MediaFactoryItem
					( "org.osmf.elements.video.rtmfp.multicast"
					, multicastLoader.canHandleResource
					, function():MediaElement
						{
							return new VideoElement(null, multicastLoader);
						}
					)
				);
			}

			rtmpStreamingNetLoader = new FriendlyRTMPDynamicStreamingNetLoader();
			addItem
				( new MediaFactoryItem
					( "org.osmf.elements.video.rtmpdynamicStreaming"
					, rtmpStreamingNetLoader.canHandleResource
					, function():MediaElement
						{
							return new VideoElement(null, rtmpStreamingNetLoader);
						}
					)
				);

			netLoader = new FriendlyNetLoader();
			addItem
				( new MediaFactoryItem
					( "org.osmf.elements.video"
					, netLoader.canHandleResource
					, function():MediaElement
						{
							return new VideoElement(null, netLoader);
						}
					)
				);

			soundLoader = new SoundLoader();
			addItem
				( new MediaFactoryItem
					( "org.osmf.elements.audio"
					, soundLoader.canHandleResource
					, function():MediaElement
						{
							return new AudioElement(null, soundLoader);
						}
					)
				);

			addItem
				( new MediaFactoryItem
					( "org.osmf.elements.audio.streaming"
					, netLoader.canHandleResource
					, function():MediaElement
						{
							return new AudioElement(null, netLoader);
						}
					)
				);

			imageLoader = new ImageLoader();
			addItem
				( new MediaFactoryItem
					( "org.osmf.elements.image"
					, imageLoader.canHandleResource
					, function():MediaElement
						{
							return new ImageElement(null, imageLoader);
						}
					)
				);

			swfLoader = new SWFLoader();
			addItem
				( new MediaFactoryItem
					( "org.osmf.elements.swf"
					, swfLoader.canHandleResource
					, function():MediaElement
						{
							return new SWFElement(null, swfLoader);
						}
					)
				);
		}



		private var rtmpStreamingNetLoader:FriendlyRTMPDynamicStreamingNetLoader;
		private var f4mLoader:F4MLoader;
		private var dvrCastLoader:DVRCastNetLoader;
		private var netLoader:FriendlyNetLoader;
		private var imageLoader:ImageLoader;
		private var swfLoader:SWFLoader;
		private var soundLoader:SoundLoader;

		{
			private var httpStreamingNetLoader:HTTPStreamingNetLoader;
			private var multicastLoader:MulticastNetLoader;
		}

     private function onNetStreamNetStatusEvent(event:NetStatusEvent):void {

         dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, event.info.code));

     }
}
}
