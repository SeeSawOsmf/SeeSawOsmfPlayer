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

package com.seesaw.player.preventscrub {
import com.seesaw.player.PlayerConstants;

import org.osmf.elements.ProxyElement;
import org.osmf.events.MetadataEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.smil.SMILConstants;
import org.osmf.traits.MediaTraitType;

public class SimpleScrubPrevention extends ProxyElement {

    public function SimpleScrubPrevention(proxiedElement:MediaElement = null) {
        super(proxiedElement);
    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            super.proxiedElement = proxiedElement;

            var metadata:Metadata = getMetadata(SMILConstants.SMIL_METADATA_NS);
            if (metadata == null) {
                metadata = new Metadata();
                addMetadata(SMILConstants.SMIL_METADATA_NS, metadata);
            }
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onMetadataChange);
        }
    }

    private function onMetadataChange(event:MetadataEvent):void {
        if (event.key == PlayerConstants.CONTENT_TYPE && (event.value == PlayerConstants.AD_CONTENT_ID
                || event.value == PlayerConstants.STING_CONTENT_ID)) {
            var traitsToBlock:Vector.<String> = new Vector.<String>();
            traitsToBlock[0] = MediaTraitType.SEEK;
            blockedTraits = traitsToBlock;
        }
        else if (event.key == PlayerConstants.CONTENT_TYPE && event.value == PlayerConstants.MAIN_CONTENT_ID) {
            var traitsToBlock:Vector.<String> = new Vector.<String>();
            blockedTraits = traitsToBlock;
        }
    }
}
}