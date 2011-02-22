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

package com.seesaw.player.captioning.sami {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;
import org.osmf.media.URLResource;
import org.osmf.metadata.Metadata;
import org.osmf.utils.URL;

public class SAMIPluginInfo extends PluginInfo {

    public static const NS_TARGET_ELEMENT:String = "http://www.seesaw.com/sami/1.0/target";

    private var logger:ILogger = LoggerFactory.getClassLogger(SAMIPluginInfo);

    private var samiElement:SAMIElement;
    private var targetElement:MediaElement;

    public function SAMIPluginInfo() {
        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();

        var item:MediaFactoryItem = new MediaFactoryItem("com.seesaw.player.captioning.sami.SAMIPluginInfo",
                canHandleResource, createSAMIElement);
        items.push(item);

        super(items, mediaElementCreationNotificationCallback);
    }

    private function canHandleResource(resource:MediaResourceBase):Boolean {
        var canHandle:Boolean = false;

        if (resource is URLResource) {
            var urlResource:URLResource = URLResource(resource);
            var url:URL = new URL(urlResource.url);
            canHandle = (url.path.search(/\.smi$|\.smil$/i) != -1);
        }

        logger.debug("canHandleResource: {0} {1}", resource, canHandle);
        return canHandle;
    }

    private function createSAMIElement():MediaElement {
        logger.debug("creating SAMIElement");
        samiElement = new SAMIElement();
        updateMediaTarget();
        return samiElement;
    }

    private function mediaElementCreationNotificationCallback(element:MediaElement):void {
        var targetMetadata:Metadata = element.getMetadata(SAMIPluginInfo.NS_TARGET_ELEMENT);
        if (targetMetadata) {
            targetElement = element;
            updateMediaTarget();
        }
    }

    private function updateMediaTarget():void {
        if (samiElement && targetElement && targetElement != samiElement) {
            logger.debug("setting media target: {0}", targetElement);
            samiElement.target = targetElement;
        }
    }
}
}