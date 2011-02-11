/*
 * Copyright 2011 ioko365 Ltd.  All Rights Reserved.
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
 * Portions created by ioko365 Ltd are Copyright (C) 2011 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2011 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 */

/**
 * Created by IntelliJ IDEA.
 * User: ibhana
 * Date: 27/01/11
 * Time: 13:48
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.smil {
import com.seesaw.player.PlayerConstants;

import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;
import org.osmf.metadata.Metadata;
import org.osmf.smil.SMILConstants;

public class SMILContentCapabilitiesPluginInfo extends PluginInfo {

    public function SMILContentCapabilitiesPluginInfo() {
        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();

        items.push(new MediaFactoryItem("com.seesaw.player.smil.SMILContentCapabilitiesPluginInfo.AdHandlerProxy",
                canHandleAdContent, createAdHandlerProxy, MediaFactoryItemType.PROXY));

        items.push(new MediaFactoryItem("com.seesaw.player.smil.SMILContentCapabilitiesPluginInfo.StingHandlerProxy",
                canHandleStingContent, createStingHandlerProxy, MediaFactoryItemType.PROXY));

        items.push(new MediaFactoryItem("com.seesaw.player.smil.SMILContentCapabilitiesPluginInfo.MainContentHandlerProxy",
                canHandleMainContent, createMainContentHandlerProxy, MediaFactoryItemType.PROXY));

        super(items);
    }

    private function canHandleAdContent(resource:MediaResourceBase):Boolean {
        var metadata:Metadata = resource.getMetadataValue(SMILConstants.SMIL_CONTENT_NS) as Metadata;
        return metadata != null && metadata.getValue(PlayerConstants.CONTENT_TYPE) == PlayerConstants.AD_CONTENT_ID;
    }

    private function canHandleStingContent(resource:MediaResourceBase):Boolean {
        var metadata:Metadata = resource.getMetadataValue(SMILConstants.SMIL_CONTENT_NS) as Metadata;
        return metadata != null && metadata.getValue(PlayerConstants.CONTENT_TYPE) == PlayerConstants.STING_CONTENT_ID;
    }

    private function canHandleMainContent(resource:MediaResourceBase):Boolean {
        var metadata:Metadata = resource.getMetadataValue(SMILConstants.SMIL_CONTENT_NS) as Metadata;
        return metadata != null && metadata.getValue(PlayerConstants.CONTENT_TYPE) == PlayerConstants.MAIN_CONTENT_ID;
    }

    private function createAdHandlerProxy():MediaElement {
        return new AdCapabilitiesProxy();
    }

    private function createStingHandlerProxy():MediaElement {
        return new StingCapabilitiesProxy();
    }

    private function createMainContentHandlerProxy():MediaElement {
        return new MainContentCapabilitiesProxy();
    }
}
}
