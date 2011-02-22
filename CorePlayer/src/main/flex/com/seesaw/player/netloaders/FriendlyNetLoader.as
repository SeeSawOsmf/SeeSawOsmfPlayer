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

public class FriendlyNetLoader extends NetLoader {
    public function FriendlyNetLoader() {
        super(new NetConnectionFactory());
    }

    /**
     * @inheritDoc
     **/
    override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream {
        var ns:NetStream = new NetStream(connection);
        ns.client = new NetClient();
        connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamNetStatusEvent);
        return ns;
    }

    // Internals
    //

    private function onNetStreamNetStatusEvent(event:NetStatusEvent):void {
        dispatchEvent(new NetStatusEvent(event.type, true, true, event.info));
    }
}
}