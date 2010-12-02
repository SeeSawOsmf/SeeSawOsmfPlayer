/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *    The contents of this file are subject to the Mozilla Public License
 *    Version 1.1 (the "License"); you may not use this file except in
 *    compliance with the License. You may obtain a copy of the
 *    License athttp://www.mozilla.org/MPL/
 *
 *    Software distributed under the License is distributed on an "AS IS"
 *    basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *    License for the specific language governing rights and limitations
 *    under the License.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 */

package com.seesaw.player.preventscrub {
import com.seesaw.player.PlayerConstants;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;
import org.osmf.metadata.Metadata;

public class ScrubPreventionProxyPluginInfo extends PluginInfo {

    private static var logger:ILogger = LoggerFactory.getClassLogger(ScrubPreventionProxyPluginInfo);

    public static const ID:String = "com.seesaw.player.preventscrub.ScrubPreventionProxyTest";
    private static var scrubPreventionProxy:SimpleScrubPrevention;

    public function ScrubPreventionProxyPluginInfo() {
        logger.debug("com.seesaw.player.preventscrub.ScrubPreventionProxyPluginInfo()");

        var item:MediaFactoryItem = new MediaFactoryItem(
                ID,
                canHandleResourceFunction,
                mediaElementCreationFunction,
                MediaFactoryItemType.PROXY);

        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
        items.push(item);

        super(items, mediaElementCreationNotificationCallback);
    }

    private static function canHandleResourceFunction(resource:MediaResourceBase):Boolean {
        logger.debug("can handle this resource: " + resource);
        var result:Boolean;

        if (resource != null) {
            var settings:Metadata = resource.getMetadataValue(PlayerConstants.CONTENT_ID) as Metadata;
            result = settings != null;
        }

        return result;
    }

    private static function mediaElementCreationFunction():MediaElement {
        logger.debug("constructing proxy element");

        scrubPreventionProxy = new SimpleScrubPrevention();

        return scrubPreventionProxy;
    }

    private function mediaElementCreationNotificationCallback(target:MediaElement):void {
        logger.debug("mediaElementCreationNotificationCallback: " + target);


    }
}
}