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

package com.seesaw.player.ads.liverail {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.SWFLoader;
import org.osmf.elements.loaderClasses.LoaderLoadTrait;
import org.osmf.events.LoaderEvent;
import org.osmf.events.MediaErrorEvent;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.URLResource;
import org.osmf.traits.LoadState;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.LoaderBase;

public class Loader extends LoaderBase {

    private var logger:ILogger = LoggerFactory.getClassLogger(Loader);

    private var swfLoader:LoaderBase;

    public function Loader(loader:LoaderBase = null) {
        super();
        this.swfLoader = loader != null ? loader : new SWFLoader();
    }

    override public function canHandleResource(resource:MediaResourceBase):Boolean {
        return swfLoader.canHandleResource(resource);
    }

    override protected function executeUnload(loadTrait:LoadTrait):void {
        updateLoadTrait(loadTrait, LoadState.UNLOADING);
        updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
    }

    override protected function executeLoad(loadTrait:LoadTrait):void {
        updateLoadTrait(loadTrait, LoadState.LOADING);

        swfLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);

        // Create a temporary LoadTrait for this purpose, so that our main
        // LoadTrait doesn't reflect any of the state changes from the
        // loading of the URL, and so that we can catch any errors.
        var loaderLoadTrait:LoaderLoadTrait = new LoaderLoadTrait(swfLoader, loadTrait.resource);

        loaderLoadTrait.addEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);

        logger.debug("Downloading document at " + URLResource(loadTrait.resource).url);

        swfLoader.load(loaderLoadTrait);

        function onHTTPLoaderStateChange(event:LoaderEvent):void {
            if (event.newState == LoadState.READY) {
                // This is a terminal state, so remove all listeners.
                swfLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);
                loaderLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);

                try {
                    LiveRailLoadTrait(loadTrait).adManager = loaderLoadTrait.loader.content;
                    updateLoadTrait(loadTrait, LoadState.READY);
                }
                catch(e:Error) {
                    logger.debug("Error loading content: " + e.errorID + "-" + e.message);
                    updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
                }
            }
            else if (event.newState == LoadState.LOAD_ERROR) {
                // This is a terminal state, so remove the listener.  But
                // don't remove the error event listener, as that will be
                // removed when the error event for this failure is
                // dispatched.
                swfLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE, onHTTPLoaderStateChange);

                logger.debug("Error loading captioning document");

                updateLoadTrait(loadTrait, event.newState);
            }
        }

        function onLoadError(event:MediaErrorEvent):void {
            // Only remove this listener, as there will be a corresponding
            // event for the load failure.
            loaderLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onLoadError);

            loadTrait.dispatchEvent(event.clone());
        }
    }
}
}
