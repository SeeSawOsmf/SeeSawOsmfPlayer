/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *    The contents of this file are subject to the Mozilla Public License
 *    Version 1.1 (the "License"); you may not use this file except in
 *    compliance with the License. You may obtain a copy of the
 *    License athttp://www.mozilla.org/MPL/
 *
 *    Software distributed under the License is distributed on an "AS IS"
 *    basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *    License for the specific language governing rights and limitations
 *    under the License.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 */

package com.seesaw.player.loaders.captioning {
import com.seesaw.player.parsers.captioning.CaptionDocument;
import com.seesaw.player.parsers.captioning.CaptionParser;
import com.seesaw.player.traits.captioning.CaptionLoadTrait;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.events.LoaderEvent;
import org.osmf.events.MediaErrorEvent;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.URLResource;
import org.osmf.traits.LoadState;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.LoaderBase;
import org.osmf.utils.HTTPLoadTrait;
import org.osmf.utils.HTTPLoader;

public class CaptionLoader extends LoaderBase {

    private var logger:ILogger = LoggerFactory.getClassLogger(CaptionLoader);

    private var httpLoader:HTTPLoader;

    private var parser:CaptionParser;

    public function CaptionLoader(parser:CaptionParser, httpLoader:HTTPLoader = null) {
        super();
        if (parser == null) {
            throw ArgumentError("provide a caption parser");
        }
        this.parser = parser;
        this.httpLoader = httpLoader != null ? httpLoader : new HTTPLoader();
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

        // Create a temporary LoadTrait for this purpose, so that our main
        // LoadTrait doesn't reflect any of the state changes from the
        // loading of the URL, and so that we can catch any errors.
        var httpLoadTrait:HTTPLoadTrait = new HTTPLoadTrait(httpLoader, loadTrait.resource);

        httpLoadTrait.addEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);

        logger.debug("Downloading document at " + URLResource(httpLoadTrait.resource).url);

        httpLoader.load(httpLoadTrait);

        function onHTTPLoaderStateChange(event:LoaderEvent):void {
            if (event.newState == LoadState.READY) {
                // This is a terminal state, so remove all listeners.
                httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
                httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);

                var captioningDocument:CaptionDocument;

                try {
                    captioningDocument = parser.parse(httpLoadTrait.urlLoader.data.toString());
                }
                catch(e:Error) {
                    logger.debug("Error parsing captioning document: " + e.errorID + "-" + e.message);
                    updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
                }

                CaptionLoadTrait(loadTrait).document = captioningDocument;
                updateLoadTrait(loadTrait, LoadState.READY);

            }
            else if (event.newState == LoadState.LOAD_ERROR) {
                // This is a terminal state, so remove the listener.  But
                // don't remove the error event listener, as that will be
                // removed when the error event for this failure is
                // dispatched.
                httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);

                logger.debug("Error loading captioning document");

                updateLoadTrait(loadTrait, event.newState);
            }
        }

        function onLoadError(event:MediaErrorEvent):void {
            // Only remove this listener, as there will be a corresponding
            // event for the load failure.
            httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);

            loadTrait.dispatchEvent(event.clone());
        }
    }
}
}