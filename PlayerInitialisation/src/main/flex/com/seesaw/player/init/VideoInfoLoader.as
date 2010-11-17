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

package com.seesaw.player.init {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.proxyClasses.LoadFromDocumentLoadTrait;
import org.osmf.events.LoaderEvent;
import org.osmf.events.MediaErrorEvent;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.media.DefaultMediaFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.URLResource;
import org.osmf.metadata.MetadataNamespaces;
import org.osmf.traits.LoadState;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.LoaderBase;
import org.osmf.utils.HTTPLoadTrait;
import org.osmf.utils.HTTPLoader;

public class VideoInfoLoader extends LoaderBase {

    private var logger:ILogger = LoggerFactory.getClassLogger(VideoInfoLoader);

    private var factory:MediaFactory;
    private var httpLoader:HTTPLoader;

    public function VideoInfoLoader(mediaFactory:MediaFactory = null, httpLoader:HTTPLoader = null) {
        this.httpLoader = httpLoader != null ? httpLoader : new HTTPLoader();
        this.factory = mediaFactory != null ? mediaFactory : new DefaultMediaFactory();
    }

    override public function canHandleResource(resource:MediaResourceBase):Boolean {
        return httpLoader.canHandleResource(resource);
    }

    override protected function executeUnload(loadTrait:LoadTrait):void {
        updateLoadTrait(loadTrait, LoadState.UNLOADING);
        updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
    }

    override protected function executeLoad(loadTrait:LoadTrait):void {
        updateLoadTrait(loadTrait, LoadState.LOADING);

        httpLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);

        var httpLoadTrait:HTTPLoadTrait = new HTTPLoadTrait(httpLoader, loadTrait.resource);
        httpLoadTrait.addEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);

        logger.debug("Downloading document at " + URLResource(httpLoadTrait.resource).url);
        httpLoader.load(httpLoadTrait);

        function onHTTPLoaderStateChange(event:LoaderEvent):void {
            if (event.newState == LoadState.READY) {
                // This is a terminal state, so remove all listeners.
                httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
                httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);

                try {
                    var videoInfo:XML = new XML(httpLoadTrait.urlLoader.data);
                    videoInfo.ignoreWhitespace = true;
                    finishLoad(loadTrait, videoInfo);
                }
                catch(e:Error) {
                    logger.debug("Error parsing captioning document: " + e.errorID + "-" + e.message);
                    updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
                }
            }
            else if (event.newState == LoadState.LOAD_ERROR) {
                httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
                logger.debug("Error loading captioning document");
                updateLoadTrait(loadTrait, event.newState);
            }
        }

        function onLoadError(event:MediaErrorEvent):void {
            httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);
            loadTrait.dispatchEvent(event.clone());
        }
    }

    private function finishLoad(loadTrait:LoadTrait, videoInfo:XML):void {
        factory.addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onMediaElementCreate, false, int.MAX_VALUE);

        var resource:DynamicStream = new DynamicStream(videoInfo);
        var videoElement:MediaElement = factory.createMediaElement(resource);

        factory.removeEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onMediaElementCreate);

        if (videoElement == null) {
            updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
        }
        else {
            var elementLoadTrait:LoadFromDocumentLoadTrait = loadTrait as LoadFromDocumentLoadTrait;
            if (elementLoadTrait) {
                elementLoadTrait.mediaElement = videoElement;
            }

            updateLoadTrait(loadTrait, LoadState.READY);
        }

        function onMediaElementCreate(event:MediaFactoryEvent):void {
            var derivedResource:MediaResourceBase = event.mediaElement.resource;
            if (derivedResource != null) {
                derivedResource.addMetadataValue(MetadataNamespaces.DERIVED_RESOURCE_METADATA, loadTrait.resource);
            }
        }
    }
}
}