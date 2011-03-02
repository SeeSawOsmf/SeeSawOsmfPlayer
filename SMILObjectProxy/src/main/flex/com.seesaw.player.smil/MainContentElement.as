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

package com.seesaw.player.smil {
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.ads.AdMetadata;

import org.osmf.elements.ParallelElement;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaResourceBase;
import org.osmf.metadata.CuePoint;
import org.osmf.metadata.CuePointType;
import org.osmf.metadata.Metadata;
import org.osmf.metadata.TimelineMetadata;

public class MainContentElement extends ParallelElement {

    private var factory:MediaFactory;
    private var _resource:MediaResourceBase;

    public function MainContentElement(factory:MediaFactory) {
        super();
        this.factory = factory;
    }

    override public function set resource(value:MediaResourceBase):void {
        if (value && numChildren == 0) {
            var metadata:Metadata = value.getMetadataValue(SMILConstants.SMIL_NAMESPACE) as Metadata;
            if (metadata) {
                var smilDocument:XML = metadata.getValue(SMILConstants.SMIL_DOCUMENT) as XML;
                if (smilDocument) {
                    var parser:SMILParser = new SMILParser(smilDocument, null, factory);
                    var mediaElement:MediaElement = parser.parseMainContent();

                    var adBreaks:Vector.<AdBreak> = parser.parseAdBreaks();
                    var adMetadata:AdMetadata = new AdMetadata();
                    adMetadata.adBreaks = adBreaks;
                    addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);

                    setupAdBreaks(mediaElement, adBreaks);

                    addChild(mediaElement);
                }
            }
            _resource = value;
        }
    }

    private function setupAdBreaks(element:MediaElement, adBreaks:Vector.<AdBreak>):void {
        var timelineMetadata:TimelineMetadata = element.getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
        if (timelineMetadata == null) {
            timelineMetadata = new TimelineMetadata(element);
            element.addMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE, timelineMetadata);
        }

        for each (var adBreak:AdBreak in adBreaks) {
            if(!adBreak.complete)
                timelineMetadata.addMarker(
                        new CuePoint(CuePointType.EVENT, adBreak.startTime, AdMetadata.AD_BREAK_CUE, adBreak));
        }
    }

    override public function get resource():MediaResourceBase {
        return _resource;
    }
}
}
