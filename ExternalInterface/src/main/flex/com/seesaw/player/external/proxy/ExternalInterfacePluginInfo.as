/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the
 * License athttp://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 * Incorporated. All Rights Reserved.
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

    public function ExternalInterfacePluginInfo() {
        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();

        var item:MediaFactoryItem = new MediaFactoryItem(
                "com.seesaw.player.external.proxy.ExternalInterfacePluginInfo",
                canHandleResourceFunction,
                lightsDownProxyCreationFunction,
                MediaFactoryItemType.PROXY);
        items.push(item);

        super(items);
    }

    private static function canHandleResourceFunction(resource:MediaResourceBase):Boolean {
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