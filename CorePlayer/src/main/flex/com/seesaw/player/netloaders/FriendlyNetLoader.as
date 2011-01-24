/**
 * Created by IntelliJ IDEA.
 * User: bmeade
 * Date: 18/01/11
 * Time: 12:24
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.netloaders {
import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.NetStream;

import org.osmf.media.URLResource;
import org.osmf.net.NetClient;
import org.osmf.net.NetConnectionFactory;
import org.osmf.net.NetLoader;

public class FriendlyNetLoader  extends NetLoader {
    public function FriendlyNetLoader() {
    		super(new NetConnectionFactory());
		}

	    /**
	     * @inheritDoc
	     **/
	    override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream
	    {
			var ns:NetStream = new NetStream(connection);
			ns.client = new NetClient();
			connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamNetStatusEvent);
			return ns;
	    }

	    // Internals
	    //

	    private function onNetStreamNetStatusEvent(event:NetStatusEvent):void
	    {
	     dispatchEvent(new NetStatusEvent(event.type, true, true, event.info) );
	    }
	}
}