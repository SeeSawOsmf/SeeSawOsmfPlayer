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
 * Time: 13:37
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.smil {
import com.seesaw.player.ads.AdMetadata;

import org.osmf.elements.ProxyElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.smil.SMILConstants;
import org.osmf.traits.MediaTraitType;

public class AdHandlerProxy extends ProxyElement {

    public function AdHandlerProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);
        var traitsToBlock:Vector.<String> = new Vector.<String>();
        traitsToBlock[0] = MediaTraitType.TIME;
        traitsToBlock[1] = MediaTraitType.SEEK;
        blockedTraits = traitsToBlock;
    }

    override public function set proxiedElement(value:MediaElement):void {
        if (proxiedElement) {
            proxiedElement.removeEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
        }

        super.proxiedElement = value;

        if (proxiedElement) {
            proxiedElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetadataAdd);
        }
    }

    private function onMetadataAdd(event:MediaElementEvent):void {
        if (event.namespaceURL == AdMetadata.AD_NAMESPACE) {
           trace();
        }
    }
}
}
