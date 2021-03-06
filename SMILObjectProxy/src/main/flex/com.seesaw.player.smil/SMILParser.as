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

/**
 * Created by IntelliJ IDEA.
 * User: ibhana
 * Date: 11/02/11
 * Time: 08:36

 */
package com.seesaw.player.smil {
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.namespaces.smil;
import com.seesaw.player.services.ResumeService;

import flash.events.EventDispatcher;

import org.osmf.elements.ParallelElement;
import org.osmf.elements.SerialElement;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.MediaType;
import org.osmf.media.URLResource;
import org.osmf.metadata.Metadata;
import org.osmf.net.DynamicStreamingItem;
import org.osmf.net.DynamicStreamingResource;
import org.osmf.net.StreamType;

/**
 * The input smil document is in a the standard format but we need to parse the elements out in a particular way
 * so the ads and main content can be added to separate media containers.
 */
public class SMILParser extends EventDispatcher {

    use namespace smil;

    private var smilDocument:XML;
    private var factory:MediaFactory;
    private var originalResource:MediaResourceBase;

    private var ignoreContent:Vector.<String> = new Vector.<String>();

    public function SMILParser(smilDocument:XML, originalResource:MediaResourceBase, factory:MediaFactory) {
        this.smilDocument = smilDocument;
        this.factory = factory;
        this.originalResource = originalResource;
    }

    private function parseChild(child:XML):MediaElement {
        var element:MediaElement = null;
        switch (child.name().localName) {
            case "par":
                element = parsePar(child);
                break;
            case "seq":
                element = parseSeq(child);
                break;
            case "video":
                element = parseVideo(child);
                break;
            case "switch":
                element = parseSwitch(child);
                break;
            case "img":
                element = parseImage(child);
                break;
        }
        return element;
    }

    private function parseSeq(seq:XML):SerialElement {
        var serial:SerialElement = new SerialElement();
        for each (var child:XML in seq.*) {
            var mediaElement:MediaElement = parseChild(child);
            serial.addChild(mediaElement);
        }
        return serial;
    }

    private function parsePar(par:XML):ParallelElement {
        var parallel:ParallelElement = new ParallelElement();
        for each (var child:XML in par.*) {
            var mediaElement:MediaElement = parseChild(child);
            parallel.addChild(mediaElement);
        }
        return parallel;
    }

    private function parseSwitch(swit:XML):MediaElement {
        var hostURL:String = smilDocument.head.meta[0].@base;

        var dsr:DynamicStreamingResource = null;
        var streamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();

        var lastSwitchItem:XML = null;
        var contentType:String = null;
        var element:MediaElement = null;

        for each (var video:XML in swit.video) {
            var dsi:DynamicStreamingItem = new DynamicStreamingItem(video.@src, video.@["system-bitrate"] / 1000);
            streamItems.push(dsi);
            lastSwitchItem = video;
            contentType = lastSwitchItem..meta.(@name == SMILConstants.CONTENT_TYPE).@content;
        }

        if (streamItems.length > 0) {
            dsr = new DynamicStreamingResource(hostURL);
            dsr.streamItems = streamItems;
            dsr.streamType = StreamType.LIVE_OR_RECORDED;
        }

        if (dsr && !isIgnoredContent(contentType)) {
            element = createVideo(dsr, contentType, getMetadata(video));
        }
        return element;
    }

    private function parseVideo(video:XML):MediaElement {
        var src:String = video.@src;
        var contentType:String = video..meta.(@name == SMILConstants.CONTENT_TYPE).@content;
        var element:MediaElement = null;
        if (src && !isIgnoredContent(contentType)) {
            element = createVideo(new URLResource(src), contentType, getMetadata(video));
        }
        return element;
    }

    private function parseImage(image:XML):MediaElement {
        var src:String = image.@src;
        var contentType:String = image..meta.(@name == SMILConstants.CONTENT_TYPE).@content;
        var element:MediaElement = null;
        if (src && !isIgnoredContent(contentType)) {
            var metadata:Metadata = getMetadata(image);
            var resource:URLResource = new URLResource(src);
            resource.addMetadataValue(SMILConstants.SMIL_NAMESPACE, metadata);

            element = factory.createMediaElement(resource);

            if (element) {
                element.addMetadata(SMILConstants.SMIL_NAMESPACE, metadata);

                dispatchEvent(
                        new SMILParserEvent(
                                SMILParserEvent.MEDIA_ELEMENT_CREATED,
                                element,
                                MediaType.IMAGE, contentType));
            }
        }
        return element;
    }

    public function parseMainContent():MediaElement {
        var mainElement:MediaElement = null;
        for each (var child:XML in smilDocument.body.seq.*) {
            if (child.name().localName == "video") {
                var contentType:String = child..meta.(@name == SMILConstants.CONTENT_TYPE).@content;
                if (contentType == "mainContent") {
                    mainElement = parseChild(child);
                }
            }
            else {
                for each (var video:XML in child..video) {
                    var contentType:String = video..meta.(@name == SMILConstants.CONTENT_TYPE).@content;
                    if (contentType == "mainContent") {
                        mainElement = parseChild(child);
                        break;
                    }
                }
            }
            if (mainElement) break;
            var clipContentType:String = child..meta.(@name == SMILConstants.CONTENT_TYPE).@content;
            if (clipContentType == "clip") {
                mainElement = parseChild(child);
                break;
            }
            if (mainElement) break;
        }
        return mainElement;
    }

    public function parseAdBreaks():Vector.<AdBreak> {
        var provider:ObjectProvider = ObjectProvider.getInstance();
        var resumeService:ResumeService = provider.getObject(ResumeService);
        var resumePoint:Number = resumeService ? resumeService.getResumeCookie() : 0;

        var adBreaks:Vector.<AdBreak> = new Vector.<AdBreak>();
        var adBreak:AdBreak = null;
        var adStart:int = 0;
        for each (var video:XML in smilDocument.body..video) {
            var contentType:String = video..meta.(@name == SMILConstants.CONTENT_TYPE).@content;
            if (contentType == "advert" || contentType == "sting") {
                if (!adBreak || adBreak.startTime != adStart) {
                    adBreak = new AdBreak();
                    adBreak.adPlaylist = new SerialElement();
                    adBreak.startTime = adStart;
                    adBreak.complete = adStart < resumePoint;
                    adBreaks.push(adBreak);
                }
                if (adBreak) {
                    var mediaElement:MediaElement = parseVideo(video);
                    if (mediaElement) {
                        adBreak.adPlaylist.addChild(mediaElement);
                    }
                }
            }
            else if (contentType == "mainContent") {
                if (video.@clipEnd) {
                    // the start time of the next ad break
                    adStart = parseInt(video.@clipEnd);
                }
            }
        }
        return adBreaks;
    }

    private function createVideo(resource:MediaResourceBase, contentType:String, metadata:Metadata):MediaElement {
        if (originalResource && contentType == "mainContent") {
            // copy the resource metadata to the video element so that proxies are triggered
            populateMetdataFromResource(originalResource, resource);
        }

        resource.addMetadataValue(SMILConstants.SMIL_NAMESPACE, metadata);

        var mediaElement:MediaElement = factory.createMediaElement(resource);

        if (mediaElement) {
            mediaElement.addMetadata(SMILConstants.SMIL_NAMESPACE, metadata);

            dispatchEvent(
                    new SMILParserEvent(
                            SMILParserEvent.MEDIA_ELEMENT_CREATED,
                            mediaElement,
                            MediaType.VIDEO, contentType));
        }
        return mediaElement;
    }

    private function populateMetdataFromResource(originalResource:MediaResourceBase, mediaResource:MediaResourceBase):void {
        // Make sure we transfer any resource metadata from the original resource
        for each (var metadataNS:String in originalResource.metadataNamespaceURLs) {
            var metadata:Object = originalResource.getMetadataValue(metadataNS);
            mediaResource.addMetadataValue(metadataNS, metadata);
        }
    }

    private function getMetadata(node:XML):Metadata {
        var metadata:Metadata = new Metadata();

        for each (var meta:XML in node..meta) {
            if (meta.@name && meta.@content) {
                metadata.addValue(meta.@name, String(meta.@content));
            }
        }

        return metadata;
    }

    public static function getHeadMetaValue(smilDocument:XML, key:String):String {
        var value:String = null;
        for each (var meta:XML in smilDocument.head..meta) {
            if (meta.@name == key) {
                value = meta.@content;
                break;
            }
        }
        return value;
    }

    public function isIgnoredContent(type:String):Boolean {
        return ignoreContent.indexOf(type, 0) >= 0;
    }

    public function addIgnoredContentType(type:String):void {
        var index:Number = ignoreContent.indexOf(type, 0);
        if (index < 0) {
            ignoreContent.push(type);
        }
    }

    public function removeIgnoredContentType(type:String):void {
        var index:Number = ignoreContent.indexOf(type, 0);
        if (index >= 0) {
            ignoreContent.splice(index, 1);
        }
    }
}
}
