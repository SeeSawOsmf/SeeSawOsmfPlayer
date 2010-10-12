/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *   The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *
 *   The Initial Developer of the Original Code is ioko365 Ltd.
 *   Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *   Incorporated. All Rights Reserved.
 */

package com.seesaw.player {
import org.osmf.net.DynamicStreamingItem;
import org.osmf.net.DynamicStreamingResource;

public class DynamicStream extends DynamicStreamingResource {

    private var dynResource:DynamicStreamingResource;

    public function DynamicStream(videoPlayerInfo:Object) {
        super("rtmpe://cdn-flash-red-dev.vodco.co.uk/a2703");

        // TODO: read out of videoPlayerInfo when the service has been implemented to return the correct values.
        streamItems = Vector.<DynamicStreamingItem>(
                [     new DynamicStreamingItem("mp4:e5/test/ccp/p/LOW_RES/test/test_asset.mp4", 408, 768, 428)
                    , new DynamicStreamingItem("mp4:e5/test/ccp/p/LOW_RES/test/test_asset.mp4", 608, 768, 428)
                    , new DynamicStreamingItem("mp4:e5/test/ccp/p/LOW_RES/test/test_asset.mp4", 908, 1024, 522)
                    , new DynamicStreamingItem("mp4:e5/test/ccp/p/LOW_RES/test/test_asset.mp4", 1308, 1024, 522)
                    , new DynamicStreamingItem("mp4:e5/test/ccp/p/LOW_RES/test/test_asset.mp4", 1708, 1280, 720)
                ]);

        //  TODO: add metadata from video player info to the resource
        // dynResource.addMetadataValue(PLAYER_NAMESPACE, partnerId);
    }
}
}