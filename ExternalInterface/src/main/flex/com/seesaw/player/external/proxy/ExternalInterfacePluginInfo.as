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

package com.seesaw.player.external.proxy {
import com.seesaw.player.PlayerConstants;

import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;
import org.osmf.metadata.Metadata;

public class ExternalInterfacePluginInfo extends PluginInfo {

    private static const ID:String = "com.seesaw.player.external.proxy.ExternalInterfacePluginInfo";

    public function ExternalInterfacePluginInfo() {
        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();

        var item:MediaFactoryItem = new MediaFactoryItem(
                ID,
                canHandleLightsDownResourceFunction,
                lightsDownProxyCreationFunction,
                MediaFactoryItemType.PROXY);
        items.push(item);

        super(items);
    }

    private static function canHandleLightsDownResourceFunction(resource:MediaResourceBase):Boolean {
        var result:Boolean;

        if (resource != null) {
            var settings:Metadata = resource.getMetadataValue(PlayerConstants.CONTENT_ID) as Metadata;
            result = settings != null;
        }

        return result;
    }

    private static function lightsDownProxyCreationFunction():MediaElement {
        return new LightsDownProxy();
    }

}
}