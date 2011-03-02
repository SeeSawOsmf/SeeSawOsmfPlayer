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
 * User: ibhana
 * Date: 27/01/11
 * Time: 13:48

 */
package com.seesaw.player.smil {
import com.seesaw.player.PlayerConstants;

import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;
import org.osmf.metadata.Metadata;

public class SMILContentCapabilitiesPluginInfo extends PluginInfo {

    private var mediaFactory:MediaFactory;

    public function SMILContentCapabilitiesPluginInfo() {
        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();

        items.push(new MediaFactoryItem("com.seesaw.player.smil.SMILContentCapabilitiesPluginInfo.AdCapabilitiesProxy",
                canHandleAdContent, createAdHandlerProxy, MediaFactoryItemType.PROXY));

        items.push(new MediaFactoryItem("com.seesaw.player.smil.SMILContentCapabilitiesPluginInfo.MainContentElement",
                canHandleMainContent, createMainContentElement, MediaFactoryItemType.STANDARD));

        super(items);
    }

    override public function initializePlugin(resource:MediaResourceBase):void {
        mediaFactory = resource.getMetadataValue(PluginInfo.PLUGIN_MEDIAFACTORY_NAMESPACE) as MediaFactory;
    }

    private function canHandleAdContent(resource:MediaResourceBase):Boolean {
        var canHandle:Boolean = false;
        var metadata:Metadata = resource.getMetadataValue(SMILConstants.SMIL_NAMESPACE) as Metadata;
        if (metadata) {
            var contentType:String = metadata.getValue(PlayerConstants.CONTENT_TYPE) as String;
            canHandle = contentType == PlayerConstants.AD_CONTENT_ID || contentType == PlayerConstants.STING_CONTENT_ID;
        }
        return canHandle;
    }

    private function canHandleMainContent(resource:MediaResourceBase):Boolean {
        var canHandle:Boolean = false;
        var metadata:Metadata = resource.getMetadataValue(SMILConstants.SMIL_NAMESPACE) as Metadata;
        if (metadata) {
            var smilDoc:XML = metadata.getValue(SMILConstants.SMIL_DOCUMENT) as XML;
            canHandle = smilDoc != null;
        }
        return canHandle;
    }

    private function createAdHandlerProxy():MediaElement {
        return new AdCapabilitiesProxy();
    }

    private function createMainContentElement():MediaElement {
        return new MainContentElement(mediaFactory);
    }
}
}
