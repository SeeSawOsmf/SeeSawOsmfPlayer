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

package com.seesaw.player.captioning.sami {
import com.seesaw.player.PlayerConstants;
import com.seesaw.player.loaders.captioning.CaptionLoader;
import com.seesaw.player.parsers.captioning.CaptionSync;
import com.seesaw.player.traits.captioning.CaptionLoadTrait;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MetadataEvent;
import org.osmf.events.TimelineMetadataEvent;
import org.osmf.layout.HorizontalAlign;
import org.osmf.layout.LayoutMetadata;
import org.osmf.layout.VerticalAlign;
import org.osmf.media.LoadableElementBase;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.URLResource;
import org.osmf.metadata.CuePoint;
import org.osmf.metadata.CuePointType;
import org.osmf.metadata.Metadata;
import org.osmf.metadata.TimelineMetadata;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.LoaderBase;
import org.osmf.traits.MediaTraitType;

public class SAMIElement extends LoadableElementBase {

    private var logger:ILogger = LoggerFactory.getClassLogger(SAMIElement);

    private var loadTrait:CaptionLoadTrait;
    private var _target:MediaElement;
    private var displayTrait:DisplayObjectTrait;
    private var userMetadata:Metadata;
    private var userEventMetadata:Metadata;

    public function SAMIElement(resource:URLResource = null, loader:CaptionLoader = null) {
        if (loader == null) {
            loader = new CaptionLoader(new SAMIParser());
        }
        super(resource, loader);
    }

    override protected function createLoadTrait(resource:MediaResourceBase, loader:LoaderBase):LoadTrait {
        return new CaptionLoadTrait(loader, resource);
    }

    override protected function processUnloadingState():void {
        removeTrait(MediaTraitType.DISPLAY_OBJECT);
    }

    override protected function processLoadingState():void {
        super.processLoadingState();
    }

    override protected function processReadyState():void {
        loadTrait = getTrait(MediaTraitType.LOAD) as CaptionLoadTrait;

        userMetadata = getMetadata(PlayerConstants.USEREVENTS_METADATA_NAMESPACE) as Metadata;
        if (userMetadata) {
            userMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, userMetaChanged);
            userMetadata.addEventListener(MetadataEvent.VALUE_ADD, userMetaChanged);
            userMetadata.addEventListener(MediaElementEvent.METADATA_ADD, userMetaChanged);
        }

        if (target) {
            var timelineMetadata:TimelineMetadata = getMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE) as TimelineMetadata;
            if (timelineMetadata == null) {
                timelineMetadata = new TimelineMetadata(target);
                addMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE, timelineMetadata);
            }

            for each (var caption:CaptionSync in loadTrait.document.captions) {
                var marker:CuePoint = new CuePoint(CuePointType.EVENT, caption.time, "sami",
                        caption.display, SAMIParser.CAPTION_INTERVAL);
                timelineMetadata.addMarker(marker);
            }

            timelineMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, onCuePoint);
        }

    }

    private function userMetaChanged(event:MetadataEvent):void {
        if (event.key == "fullScreen" && event.type != MetadataEvent.VALUE_ADD) {
            var captionDisplayObject:CaptionDisplayObject = displayTrait.displayObject as CaptionDisplayObject;
            captionDisplayObject.fullScreenMode = event.value;
        }
    }

    private function onMediaTraitsChange(event:MediaElementEvent):void {
        checkDisplayState();
    }

    private function checkDisplayState():void {
        if (!hasTrait(MediaTraitType.DISPLAY_OBJECT) &&
                target.hasTrait(MediaTraitType.PLAY) && target.hasTrait(MediaTraitType.TIME)) {
            logger.debug("adding display object trait");
            var captionDisplayObject:CaptionDisplayObject = new CaptionDisplayObject();
            // Captions are invisible by default. Obtain the DisplayObjectTrait to make visible
            captionDisplayObject.visible = false;
            displayTrait = new DisplayObjectTrait(captionDisplayObject);
            addTrait(MediaTraitType.DISPLAY_OBJECT, displayTrait);

            var layout:LayoutMetadata = new LayoutMetadata();
            addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);

            layout.height = 150;
            layout.horizontalAlign = HorizontalAlign.CENTER;
            layout.verticalAlign = VerticalAlign.BOTTOM;
            layout.index = 10;

        }
        else if (hasTrait(MediaTraitType.DISPLAY_OBJECT) && !target.hasTrait(MediaTraitType.TIME)) {
            logger.debug("removing display object trait");
            removeTrait(MediaTraitType.DISPLAY_OBJECT);
            displayTrait = null;
        }
    }

    private function onCuePoint(event:TimelineMetadataEvent):void {
        var cuePoint:CuePoint = event.marker as CuePoint;
        if (cuePoint && displayTrait && cuePoint.name == "sami") {
            var captionDisplayObject:CaptionDisplayObject = displayTrait.displayObject as CaptionDisplayObject;
            var caption:String = cuePoint.parameters as String;
            captionDisplayObject.text = caption;
            logger.debug("caption: time = {0}, duration = {1}", cuePoint.time, cuePoint.duration);
        }
    }

    public function set target(value:MediaElement):void {
        if (_target) {
            _target.removeEventListener(MediaElementEvent.TRAIT_ADD, onMediaTraitsChange);
            _target.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaTraitsChange);
        }
        _target = value;
        if (_target) {
            _target.addEventListener(MediaElementEvent.TRAIT_ADD, onMediaTraitsChange);
            _target.addEventListener(MediaElementEvent.TRAIT_REMOVE, onMediaTraitsChange);
        }
    }

    public function get target():MediaElement {
        return _target;
    }
}
}
