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
package org.osmf.smil.media
{
import org.osmf.elements.CompositeElement;
import org.osmf.elements.ParallelElement;
import org.osmf.elements.ProxyElement;
import org.osmf.elements.SerialElement;
import org.osmf.elements.VideoElement;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.events.SerialElementEvent;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.MediaType;
import org.osmf.media.URLResource;
import org.osmf.metadata.Metadata;
import org.osmf.net.DynamicStreamingItem;
import org.osmf.net.DynamicStreamingResource;
import org.osmf.net.StreamType;
import org.osmf.net.StreamingURLResource;
import org.osmf.smil.SMILConstants;
import org.osmf.smil.model.SMILDocument;
import org.osmf.smil.model.SMILElement;
import org.osmf.smil.model.SMILElementType;
import org.osmf.smil.model.SMILMediaElement;
import org.osmf.smil.model.SMILMetaElement;

CONFIG::LOGGING
	{
    import org.osmf.logging.Log;
    import org.osmf.logging.Logger;
}

	/**
	 * A utility class for creating MediaElements from a <code>SMILDocument</code>.
	 */
	public class SMILMediaGenerator
	{
		/**
		 * Creates the relevant MediaElement from the SMILDocument.
		 *
		 * @param resource The original resource that was given to the load trait.
		 * This resource might be a URLto a SMIL document, for example, and may
		 * contain metadata we need to retain.
		 * @param smilDocument The SMILDocument to use for media creation.
		 * @returns A new MediaElement based on the information found in the SMILDocument.
		 */
		public function createMediaElement(resource:MediaResourceBase, smilDocument:SMILDocument, factory:MediaFactory):MediaElement
		{
			this.factory = factory;

			CONFIG::LOGGING
			{
				traceElements(smilDocument);
			}

			var mediaElement:MediaElement;

			for (var i:int = 0; i < smilDocument.numElements; i++)
			{
				var smilElement:SMILElement = smilDocument.getElementAt(i);
				mediaElement = internalCreateMediaElement(resource, null, smilDocument, smilElement);
			}

			return mediaElement;
		}

		/**
		 * Recursive function to create a media element and all of it's children.
		 */
		private function internalCreateMediaElement(originalResource:MediaResourceBase, parentMediaElement:MediaElement,
													smilDocument:SMILDocument, smilElement:SMILElement):MediaElement
		{
			var mediaResource:MediaResourceBase = null;

			var mediaElement:MediaElement;

			switch (smilElement.type)
			{
				case SMILElementType.SWITCH:
					mediaResource = createDynamicStreamingResource(smilElement, smilDocument);
					break;
				case SMILElementType.PARALLEL:
					var parallelElement:ParallelElement = new ParallelElement();
					mediaElement = parallelElement;
					break;
				case SMILElementType.SEQUENCE:
					var serialElement:SerialElement = new SerialElement();
                    serialElement.addEventListener(SerialElementEvent.CURRENT_CHILD_CHANGE, function(event:SerialElementEvent) {
                        var serialElement:SerialElement = event.currentTarget as SerialElement;
                        var index:int = serialElement.getChildIndex(event.currentChild) - 1;
                        if(index >= 0) {
                            var childElem:MediaElement = serialElement.getChildAt(index);
                            var metadata:Metadata = childElem.getMetadata(SMILConstants.SMIL_METADATA_NS);
                            if(metadata && metadata.getValue("contentType") == "advert" ||
                                    metadata.getValue("contentType") == "sting") {
                                serialElement.removeChild(childElem);
                            }
                        }
                     });
                    mediaElement = serialElement;
					break;
				case SMILElementType.VIDEO:
					var resource:StreamingURLResource = new StreamingURLResource((smilElement as SMILMediaElement).src);
					resource.mediaType = MediaType.VIDEO;
                    populateResourceMetadataFromSMIL(resource, smilElement);

					var videoElement:MediaElement = factory.createMediaElement(resource);

                    populateMetadataFromSMIL(videoElement, smilElement);

					var smilVideoElement:SMILMediaElement = smilElement as SMILMediaElement;

					if (!isNaN(smilVideoElement.clipBegin) && smilVideoElement.clipBegin > -1 &&
					    !isNaN(smilVideoElement.clipEnd) && smilVideoElement.clipEnd > 0)
					{
						resource.clipStartTime = smilVideoElement.clipBegin;
						resource.clipEndTime = smilVideoElement.clipEnd;
					}

					var duration:Number = (smilElement as SMILMediaElement).duration;
					setVideoDuration(duration, videoElement);

					(parentMediaElement as CompositeElement).addChild(videoElement);
					break;
				case SMILElementType.IMAGE:
					var imageResource:URLResource = new URLResource((smilElement as SMILMediaElement).src);
					imageResource.mediaType = MediaType.IMAGE;

					var imageElement:MediaElement = factory.createMediaElement(imageResource);

                    populateMetadataFromSMIL(imageElement, smilElement);

					/*var dur:Number = (smilElement as SMILMediaElement).duration;
					if (!isNaN(dur) && dur > 0) {
						imageElement = new DurationElement(dur, imageElement);
					}*/

					if (parentMediaElement is CompositeElement) {
						(parentMediaElement as CompositeElement).addChild(imageElement);
					}
					break;
				case SMILElementType.AUDIO:
					var audioResource:URLResource = new URLResource((smilElement as SMILMediaElement).src);
					audioResource.mediaType = MediaType.AUDIO;

					var audioElement:MediaElement = factory.createMediaElement(audioResource);

                    populateMetadataFromSMIL(audioElement, smilElement);

					(parentMediaElement as CompositeElement).addChild(audioElement);
					break;
			}

			if (mediaElement != null)
			{
				for (var i:int = 0; i < smilElement.numChildren; i++)
				{
					var childElement:SMILElement = smilElement.getChildAt(i);
					internalCreateMediaElement(originalResource, mediaElement, smilDocument, childElement);
				}

				// Fix for FM-931, make sure we support nested elements
				if (parentMediaElement is CompositeElement)
				{
					(parentMediaElement as CompositeElement).addChild(mediaElement);
				}
			}
			else if (mediaResource != null)
			{
                mediaResource.mediaType = MediaType.VIDEO;
                populateResourceMetadataFromSMIL(mediaResource, smilElement);

                var switchVideoElement:SMILMediaElement = null;
                for (var i:int = 0; i < smilElement.numChildren; i++)
                {
                    var smilElement:SMILElement = smilElement.getChildAt(i);
                    if (smilElement.type == SMILElementType.VIDEO)
                    {
                        switchVideoElement = smilElement as SMILMediaElement;
                        break;
                    }
                }

                var defaultDuration:Number = switchVideoElement ? switchVideoElement.duration : NaN;
                var onCreate:Function = function(event:MediaFactoryEvent)
                {
                   setVideoDuration(defaultDuration, event.mediaElement);
                }

                factory.addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onCreate);
				mediaElement = factory.createMediaElement(mediaResource);
                factory.removeEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onCreate);

                populateMetadataFromSMIL(mediaElement, smilElement);

				if (parentMediaElement is CompositeElement)
				{
					(parentMediaElement as CompositeElement).addChild(mediaElement);
				}
			}

			return mediaElement;
		}

        private function setVideoDuration(duration:Number, videoElement:MediaElement):void
        {
            if (!isNaN(duration) && duration > 0)
            {
                if (videoElement is VideoElement)
                {
                    (videoElement as VideoElement).defaultDuration = duration;
                }
                else if (videoElement is ProxyElement)
                {
                    // Try to find the proxied video element (fix for FM-1020)
                    var tempMediaElement:MediaElement = videoElement;
                    while (tempMediaElement is ProxyElement)
                    {
                        tempMediaElement = (tempMediaElement as ProxyElement).proxiedElement;
                    }

                    if (tempMediaElement != null && tempMediaElement is VideoElement)
                    {
                        (tempMediaElement as VideoElement).defaultDuration = duration;
                    }
                }
            }
        }

        private function populateMetdataFromResource(originalResource:MediaResourceBase, mediaResource:MediaResourceBase):void
        {
            // Make sure we transfer any resource metadata from the original resource
            for each (var metadataNS:String in originalResource.metadataNamespaceURLs)
            {
                var metadata:Object = originalResource.getMetadataValue(metadataNS);
                mediaResource.addMetadataValue(metadataNS, metadata);
            }
        }

        private function populateResourceMetadataFromSMIL(media:MediaResourceBase, smilElement:SMILElement):void
        {
            var metadata:Metadata = media.getMetadataValue(SMILConstants.SMIL_CONTENT_NS) as Metadata;
            if(metadata == null)
            {
                metadata = new Metadata();
                media.addMetadataValue(SMILConstants.SMIL_CONTENT_NS, metadata);
            }

            for(var i:uint = 0; i < smilElement.numChildren; i++)
            {
                var child:SMILElement = smilElement.getChildAt(i);
                if(child is SMILMetaElement)
                {
                    var smilMeta:SMILMetaElement = child as SMILMetaElement;
                    if(smilMeta.name && smilMeta.content)
                    {
                        metadata.addValue(smilMeta.name, smilMeta.content);
                    }
                }
            }
        }

        private function populateMetadataFromSMIL(media:MediaElement, smilElement:SMILElement):void
        {
            var metadata:Metadata = new Metadata();

            for(var i:uint = 0; i < smilElement.numChildren; i++)
            {
                var child:SMILElement = smilElement.getChildAt(i);
                if(child is SMILMetaElement)
                {
                    var smilMeta:SMILMetaElement = child as SMILMetaElement;
                    if(smilMeta.name && smilMeta.content)
                    {
                        metadata.addValue(smilMeta.name, smilMeta.content);
                    }
                }
            }

            media.addMetadata(SMILConstants.SMIL_METADATA_NS, metadata);
        }

		private function createDynamicStreamingResource(switchElement:SMILElement, smilDocument:SMILDocument):MediaResourceBase
		{
			var dsr:DynamicStreamingResource = null;
			var hostURL:String;

			for (var i:int = 0; i < smilDocument.numElements; i++)
			{
				var smilElement:SMILElement = smilDocument.getElementAt(i);
				switch (smilElement.type)
				{
					case SMILElementType.META:
						hostURL = (smilElement as SMILMetaElement).base;
						if (hostURL)
						{
							dsr = createDynamicStreamingItems(switchElement, hostURL);
						}
						break;
				}
			}

			return dsr;
		}

		private function createDynamicStreamingItems(switchElement:SMILElement, hostURL:String):DynamicStreamingResource
		{
			var dsr:DynamicStreamingResource = null;
			var streamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();

            var videoElement:SMILMediaElement = null;

			for (var i:int = 0; i < switchElement.numChildren; i++)
			{
				var smilElement:SMILElement = switchElement.getChildAt(i);
				if (smilElement.type == SMILElementType.VIDEO)
				{
					videoElement = smilElement as SMILMediaElement;

					// We need to divide the bitrate by 1000 because the DynamicStreamingItem class
					// requires the bitrate in kilobits per second.
					var dsi:DynamicStreamingItem = new DynamicStreamingItem(videoElement.src, videoElement.bitrate/1000);
					streamItems.push(dsi);
				}
			}

			if (streamItems.length)
			{
				dsr = new DynamicStreamingResource(hostURL);
                if (!isNaN(videoElement.clipBegin) && videoElement.clipBegin > -1 &&
                    !isNaN(videoElement.clipEnd) && videoElement.clipEnd > 0) {
                    dsr.clipStartTime = videoElement.clipBegin;
                    dsr.clipEndTime = videoElement.clipEnd;
                }

				dsr.streamItems = streamItems;
				dsr.streamType = StreamType.LIVE_OR_RECORDED;
			}

			return dsr;
		}


		private function traceElements(smilDocument:SMILDocument):void
		{
			CONFIG::LOGGING
			{
				debugLog(">>> SMILMediaGenerator.traceElements()  ");

				for (var i:int = 0; i < smilDocument.numElements; i++)
				{
					var smilElement:SMILElement = smilDocument.getElementAt(i);
					traceElement(smilElement)
				}

				function traceElement(e:SMILElement, level:int=0):void
				{
					var levelMarker:String = "*";

					for (var j:int = 0; j < level; j++)
					{
						levelMarker += "*";
					}

					debugLog(levelMarker + e.type);
					level++;

					for (var k:int = 0; k < e.numChildren; k++)
					{
						traceElement(e.getChildAt(k), level);
					}

					level--;
				}
			}
		}

		private function debugLog(msg:String):void
		{
			CONFIG::LOGGING
			{
				if (logger != null)
				{
					logger.debug(msg);
				}
			}
		}

		CONFIG::LOGGING
		{
			private static const logger:Logger = Log.getLogger("org.osmf.smil.media.SMILMediaGenerator");
		}

		private var factory:MediaFactory;
	}
}
