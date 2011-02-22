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
 *   All Rights Reserved.
 *
 *   Contributor(s):
 */

package com.seesaw.player.ads.auditude {
import com.auditude.ads.osmf.constants.AuditudeOSMFConstants;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;

public class AdProxyPluginInfo extends PluginInfo {

    private static var logger:ILogger = LoggerFactory.getClassLogger(AdProxyPluginInfo);

    public static const ID:String = "com.seesaw.player.ads.Auditude";

    public function AdProxyPluginInfo() {
        logger.debug("AdProxyPluginInfo()");

        var item:MediaFactoryItem = new MediaFactoryItem(
                ID,
                canHandleResourceFunction,
                mediaElementCreationFunction,
                MediaFactoryItemType.PROXY);

        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
        items.push(item);

        super(items);
    }

    private static function canHandleResourceFunction(resource:MediaResourceBase):Boolean {
        var canHandle:Boolean = resource && resource.getMetadataValue(AuditudeOSMFConstants.AUDITUDE_METADATA_NAMESPACE) != null;
        logger.debug("can handle this resource: {0} = {1}", resource, canHandle);
        return canHandle;
    }

    private static function mediaElementCreationFunction():MediaElement {
        return new AdProxy();
    }

}
}
