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

package com.seesaw.player.preventscrub {
import com.seesaw.player.ads.AdMetadata;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MetadataEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class ScrubPreventionProxy extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(ScrubPreventionProxy);

    private var adBlockingSeekTrait:AdBreakTriggeringSeekTrait;

    public function ScrubPreventionProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);
    }

    public override function set proxiedElement(value:MediaElement):void {
        if (value) {
            if (proxiedElement) {
                proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
                proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
                proxiedElement.removeEventListener(MediaElementEvent.METADATA_ADD, onMetaDataAdd);
                proxiedElement.removeEventListener(MediaElementEvent.METADATA_REMOVE, onMetaDataRemove);
            }

            super.proxiedElement = value;

            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
            proxiedElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetaDataAdd);
            proxiedElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onMetaDataRemove);

            var adMetadata:AdMetadata = proxiedElement.getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
            if (adMetadata) {
                adMetadata.addEventListener(MetadataEvent.VALUE_ADD, onAdsMetaDataAdd);
                adMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, onAdsMetaDataChange);
                adMetadata.addEventListener(MetadataEvent.VALUE_REMOVE, onAdsMetaDataRemove);
                addBlockingSeekTrait();
            }
        }
    }

    private function onMetaDataAdd(event:MediaElementEvent):void {
        if (event.namespaceURL == AdMetadata.AD_NAMESPACE) {
            var adMetadata:AdMetadata = proxiedElement.getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
            adMetadata.addEventListener(MetadataEvent.VALUE_ADD, onAdsMetaDataAdd);
            adMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, onAdsMetaDataChange);
            adMetadata.addEventListener(MetadataEvent.VALUE_REMOVE, onAdsMetaDataRemove);
            addBlockingSeekTrait();
        }
    }

    private function onMetaDataRemove(event:MediaElementEvent):void {
        if (event.namespaceURL == AdMetadata.AD_NAMESPACE) {
            removeBlockingSeekTrait();
        }
    }

    private function onAdsMetaDataAdd(event:MetadataEvent):void {
        if (event.key == AdMetadata.AD_BREAKS) {
            addBlockingSeekTrait();
        }
    }

    private function onAdsMetaDataChange(event:MetadataEvent):void {
        if (event.key == AdMetadata.AD_BREAKS) {
            removeBlockingSeekTrait();
            addBlockingSeekTrait();
        }
    }

    private function onAdsMetaDataRemove(event:MetadataEvent):void {
        if (event.key == AdMetadata.AD_BREAKS) {
            removeBlockingSeekTrait();
        }
    }

    private function toggleSeekListeners(added:Boolean):void {
        if (added) {
            addBlockingSeekTrait();
        } else {
            removeBlockingSeekTrait();
        }
    }

    private function removeBlockingSeekTrait():void {
        if (adBlockingSeekTrait) {
            logger.debug("removing blocking seek trait for ad breaks");
            removeTrait(MediaTraitType.SEEK);
            adBlockingSeekTrait = null;
        }
    }

    private function addBlockingSeekTrait():void {
        if (!adBlockingSeekTrait) {
            var timeTrait:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;
            var seekTrait:SeekTrait = proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
            if (seekTrait && timeTrait) {
                var adMetadata:AdMetadata = proxiedElement.getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
                if (adMetadata && adMetadata.adBreaks) {
                    logger.debug("adding blocking seek trait for {0} ad breaks", adMetadata.adBreaks.length);
                    adBlockingSeekTrait = new AdBreakTriggeringSeekTrait(timeTrait, seekTrait, adMetadata.adBreaks);
                    addTrait(MediaTraitType.SEEK, adBlockingSeekTrait);
                }
            }
        }
    }

    private function onTraitAdd(event:MediaElementEvent):void {
        processTrait(event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        processTrait(event.traitType, false);
    }

    private function processTrait(traitType:String, added:Boolean):void {
        switch (traitType) {
            case MediaTraitType.SEEK:
                toggleSeekListeners(added);
                break;
        }
    }
}
}