package com.seesaw.subtitle.sami {
import com.seesaw.subtitle.parser.CaptionParser;
import com.seesaw.subtitle.parser.CaptionSync;
import com.seesaw.subtitle.sami.SAMIParser;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;

import org.osmf.elements.ParallelElement;
import org.osmf.elements.proxyClasses.LoadFromDocumentLoadTrait;
import org.osmf.events.MediaError;
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
import org.osmf.utils.URL;

public class SAMILoader extends LoaderBase {

    private var factory:MediaFactory;

    public function SAMILoader(mediaFactory:MediaFactory = null) {
        super();

        factory = mediaFactory;

        if (factory == null) {
            factory = new DefaultMediaFactory();
        }
    }

    override public function canHandleResource(resource:MediaResourceBase):Boolean {
        var canHandle:Boolean = false;

        if (resource is URLResource) {
            var urlResource:URLResource = URLResource(resource);
            var url:URL = new URL(urlResource.url);
            canHandle = (url.path.search(/\.smi$|\.smil$/i) != -1);
        }

        return canHandle;
    }

    override protected function executeLoad(loadTrait:LoadTrait):void {
        updateLoadTrait(loadTrait, LoadState.LOADING);

        var urlLoader:URLLoader = new URLLoader(new URLRequest(URLResource(loadTrait.resource).url));
        setupListeners();

        function setupListeners(add:Boolean = true):void {
            if (add) {
                urlLoader.addEventListener(Event.COMPLETE, onComplete);
                urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
                urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
            }
            else {
                urlLoader.removeEventListener(Event.COMPLETE, onComplete);
                urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
                urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
            }
        }

        function onError(event:ErrorEvent):void {
            setupListeners(false);
            updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
            loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(0, event.text)));
        }

        function onComplete(event:Event):void {
            setupListeners(false);

            try {
                var parser:CaptionParser = createParser();
                var captions:Vector.<CaptionSync> = parser.parse(event.target.data);
                finishLoad(loadTrait, captions);
            }
            catch (parseError:Error) {
                updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
                loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(parseError.errorID, parseError.message)));
            }
        }
    }

    private function finishLoad(loadTrait:LoadTrait, captions:Vector.<CaptionSync>):void {
        // Listen for created elements so that we can add the "derived" resource metadata
        // to them.  Use a high priority so that we can add the metadata before clients
        // get the event.
        factory.addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onMediaElementCreate, false, int.MAX_VALUE);

        var loadedElement:MediaElement = new ParallelElement();
        factory.removeEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE, onMediaElementCreate);

        if (loadedElement == null) {
            updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
        }
        else {
            var elementLoadTrait:LoadFromDocumentLoadTrait = loadTrait as LoadFromDocumentLoadTrait;
            if (elementLoadTrait) {
                elementLoadTrait.mediaElement = loadedElement;
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

    protected function createParser():CaptionParser {
        return new SAMIParser();
    }
}
}