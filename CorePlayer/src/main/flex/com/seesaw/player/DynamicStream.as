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

package com.seesaw.player {
import com.seesaw.player.namespaces.contentinfo;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.net.DynamicStreamingItem;
import org.osmf.net.DynamicStreamingResource;

public class DynamicStream extends DynamicStreamingResource {

    use namespace contentinfo;

    private var logger:ILogger = LoggerFactory.getClassLogger(DynamicStream);

    public function DynamicStream(videoInfo:XML) {
        super(videoInfo.cdnPath);

        logger.debug("using cdn: " + videoInfo.cdnPath);

        var items:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();
        for each (var asset:XML in videoInfo.asset) {
            logger.debug("creating streaming item: " + asset.type + ":" + asset.path);
            items.push(new DynamicStreamingItem(asset.type + ":" + asset.path, asset.bitrate, asset.width, asset.height));
        }

        streamItems = items;

        logger.debug("created " + streamItems.length + " streaming item(s)");
    }
}
}