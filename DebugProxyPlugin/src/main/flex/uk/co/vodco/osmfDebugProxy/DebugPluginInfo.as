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

package uk.co.vodco.osmfDebugProxy {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;

public class DebugPluginInfo extends PluginInfo {
    private static var logger:ILogger = LoggerFactory.getClassLogger(DebugPluginInfo);


    public function DebugPluginInfo() {
        logger.debug("Initialising debug plugin");

        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
        items.push(mediaFactoryItem);

        super(items, mediaElementCreationNotificationFunction);
    }

    public static function get mediaFactoryItem():MediaFactoryItem {
        return _mediaFactoryItem;
    }

    private static function canHandleResourceFunction(resource:MediaResourceBase):Boolean {
        return true;
    }

    private static function mediaElementCreationFunction():MediaElement {
        logger.debug("Constructing debug proxy");
        return new DebugProxyElement();
    }

    private static var _mediaFactoryItem:MediaFactoryItem
            = new MediaFactoryItem
            (ID
                    , canHandleResourceFunction
                    , mediaElementCreationFunction
                    , MediaFactoryItemType.PROXY
                    );

    public static const ID:String = "uk.co.vodco.osmfDebugProxy.DebugPluginInfo";
}

}