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
 * Date: 04/02/11
 * Time: 10:09
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.smil {
import com.seesaw.player.PlayerConstants;

import org.osmf.elements.ProxyElement;
import org.osmf.elements.VideoElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.traits.MediaTraitType;

public class MainContentHandlerProxy extends ProxyElement {

    public function MainContentHandlerProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);
    }

    override public function set proxiedElement(value:MediaElement):void {
        if (proxiedElement) {
            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
        }

        super.proxiedElement = value;

        if (proxiedElement) {
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
        }
    }

    private function onTraitAdd(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.TIME) {
            if (event.target is VideoElement) {
                var defaultDuration:Number = (event.target as VideoElement).defaultDuration;
                if (!isNaN(defaultDuration) && defaultDuration > 0) {
                    var metadata:Metadata = getMetadata(PlayerConstants.METADATA_NAMESPACE);
                    if (metadata == null) {
                        metadata = new Metadata();
                        addMetadata(PlayerConstants.METADATA_NAMESPACE, metadata);
                    }
                    metadata.addValue(PlayerConstants.MAIN_CONTENT_DURATION, defaultDuration);
                }
            }
        }
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.TIME) {
            var metadata:Metadata = getMetadata(PlayerConstants.METADATA_NAMESPACE);
            if (metadata) {
                metadata.removeValue(PlayerConstants.MAIN_CONTENT_DURATION);
            }
        }
    }
}
}
