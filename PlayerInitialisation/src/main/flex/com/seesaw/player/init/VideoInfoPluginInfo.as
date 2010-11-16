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

package com.seesaw.player.init {
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;

public class VideoInfoPluginInfo extends PluginInfo {

    private var mediaFactory:MediaFactory;

    public function VideoInfoPluginInfo() {
        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();

        var item:MediaFactoryItem = new MediaFactoryItem("com.seesaw.player.init.VideoInfoPluginInfo",
                new VideoInfoLoader().canHandleResource, createMainVideoElement);
        items.push(item);

        super(items);
    }

    private function createMainVideoElement():MediaElement {
        return new MainVideoElement(null, new VideoInfoLoader(mediaFactory));
    }

    override public function initializePlugin(resource:MediaResourceBase):void {
        mediaFactory = resource.getMetadataValue(PluginInfo.PLUGIN_MEDIAFACTORY_NAMESPACE) as MediaFactory;
    }
}
}