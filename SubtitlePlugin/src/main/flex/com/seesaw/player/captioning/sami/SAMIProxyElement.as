package com.seesaw.player.captioning.sami {
import com.seesaw.player.loaders.captioning.CaptionLoader;
import com.seesaw.player.parsers.captioning.CaptionSync;
import com.seesaw.player.traits.captioning.CaptionLoadTrait;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.LoadEvent;
import org.osmf.media.MediaElement;
import org.osmf.media.URLResource;
import org.osmf.metadata.CuePoint;
import org.osmf.metadata.CuePointType;
import org.osmf.metadata.Metadata;
import org.osmf.metadata.TimelineMarker;
import org.osmf.metadata.TimelineMetadata;
import org.osmf.traits.LoadState;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;

public class SAMIProxyElement extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(SAMIProxyElement);

    private var loadTrait:CaptionLoadTrait;

    public function SAMIProxyElement(proxiedElement:MediaElement = null) {
        super(proxiedElement);
    }

    override public function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            super.proxiedElement = proxiedElement;

            var metadata:Metadata = proxiedElement.resource.getMetadataValue(SAMIPluginInfo.METADATA_NAMESPACE) as Metadata;

            if (metadata && metadata.getValue(SAMIPluginInfo.METADATA_KEY_URI)) {
                loadTrait = new CaptionLoadTrait(new CaptionLoader(new SAMIParser()),
                        new URLResource(metadata.getValue(SAMIPluginInfo.METADATA_KEY_URI)));

                // MAX_VALUE ensures that our handler gets called first
                loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange, false, int.MAX_VALUE);

                addTrait(MediaTraitType.LOAD, loadTrait);
            }
        }
    }

    private function onLoadStateChange(event:LoadEvent):void {
        if (event.loadState == LoadState.READY) {
            var timelineMetadata:TimelineMetadata = proxiedElement.getMetadata(SAMIPluginInfo.METADATA_NAMESPACE) as TimelineMetadata;

            if (timelineMetadata == null) {
                timelineMetadata = new TimelineMetadata(proxiedElement);
                proxiedElement.addMetadata(CuePoint.DYNAMIC_CUEPOINTS_NAMESPACE, timelineMetadata);
            }

            for each (var caption:CaptionSync in loadTrait.document.captions) {
                var marker:CuePoint = new CuePoint(CuePointType.EVENT, caption.time, "sami",
                        caption.display, SAMIParser.CAPTION_INTERVAL);
                timelineMetadata.addMarker(marker);
            }

            cleanUp();
        }
        else if (event.loadState == LoadState.LOAD_ERROR) {
            cleanUp();
        }
    }

    private function cleanUp():void {
        // Our work is done, remove the custom LoadTrait.  This will
        // expose the base LoadTrait, which we can then use to do
        // the actual load.
        removeTrait(MediaTraitType.LOAD);

        var loadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
        if (loadTrait != null && loadTrait.loadState == LoadState.UNINITIALIZED) {
            loadTrait.load();
        }
    }
}
}