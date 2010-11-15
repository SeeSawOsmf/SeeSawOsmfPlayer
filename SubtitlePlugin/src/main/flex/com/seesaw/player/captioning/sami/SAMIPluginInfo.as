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

package com.seesaw.player.captioning.sami {
import com.seesaw.player.logging.CommonsOsmfLoggerFactory;
import com.seesaw.player.logging.TraceAndArthropodLoggerFactory;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.logging.Log;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;
import org.osmf.metadata.Metadata;

public class SAMIPluginInfo extends PluginInfo {

    public static const METADATA_NAMESPACE:String = "http://www.seesaw.com/sami/1.0";
    public static const METADATA_KEY_URI:String = "uri";

    private static var loggerSetup:* = (LoggerFactory.loggerFactory = new TraceAndArthropodLoggerFactory());
    private static var osmfLoggerSetup:* = (Log.loggerFactory = new CommonsOsmfLoggerFactory());

    private var logger:ILogger = LoggerFactory.getClassLogger(SAMIPluginInfo);

    public function SAMIPluginInfo() {
        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();

        var item:MediaFactoryItem = new MediaFactoryItem("com.seesaw.player.captioning.sami.SAMIPluginInfo",
                canHandleResource, createSAMIProxyElement, MediaFactoryItemType.PROXY);
        items.push(item);

        super(items);
    }

    private function canHandleResource(resource:MediaResourceBase):Boolean {
        var canHandle:Boolean = false;

        if (resource != null) {
            var settings:Metadata = resource.getMetadataValue(METADATA_NAMESPACE) as Metadata;
            canHandle = settings != null;
        }

        return canHandle;
    }

    private function createSAMIProxyElement():MediaElement {
        return new SAMIProxyElement();
    }
}
}