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

package com.seesaw.player {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.metadata.Metadata;
import org.osmf.net.DynamicStreamingItem;
import org.osmf.net.DynamicStreamingResource;

public class DynamicStream extends DynamicStreamingResource {

    private var logger:ILogger = LoggerFactory.getClassLogger(DynamicStream);

    private static const PROGRAMME_ID:String = "programmeID";
    private static const CONTENT_INFO:String = "contentInfo";
    private static const CONTENT_ID:String = "contentId";


    public function DynamicStream(params:Object) {
        super(params.scheme + "://" + params.cdnPath);

        logger.debug("scheme: " + params.scheme);
        logger.debug("cdn: " + params.cdnPath);
        logger.debug("low res asset: " + params.lowResAssetPath);

        streamItems = Vector.<DynamicStreamingItem>(
                [
                    new DynamicStreamingItem(params.lowResAssetType + ":" + params.lowResAssetPath, 408, 768, 428)
                ]);

        logger.debug("created " + streamItems.length + " stream item(s)");

        //  TODO: add metadata from video player info to the resource

        var metaSettings:Metadata = new Metadata();
        metaSettings.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);  // Use this to check the resource is the mainContent for the plugins

        addMetadataValue(CONTENT_ID, metaSettings);

        addMetadataValue(PROGRAMME_ID, params.programmeId);
        addMetadataValue(CONTENT_INFO, params.contentInfo)
    }
}
}