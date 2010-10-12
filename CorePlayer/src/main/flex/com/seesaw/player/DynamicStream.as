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

    private static const PROGRAMME_ID:String = "programmeID";

    public function DynamicStream(params:Object) {
        super(params.scheme + "://" + params.cdnPath);

        streamItems = Vector.<DynamicStreamingItem>(
        [
            new DynamicStreamingItem(params.lowResAssetType + ":" + params.lowResAssetPath, 408, 768, 428)
        ]);

        //  TODO: add metadata from video player info to the resource
        addMetadataValue(PROGRAMME_ID, params.programmeId);
    }
}
}