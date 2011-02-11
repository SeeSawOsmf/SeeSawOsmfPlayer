/*
 * Copyright 2011 ioko365 Ltd.  All Rights Reserved.
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
 * Portions created by ioko365 Ltd are Copyright (C) 2011 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2011 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 */

/**
 * Created by IntelliJ IDEA.
 * User: ibhana
 * Date: 11/02/11
 * Time: 08:36
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.smil {
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.namespaces.smil;

import flash.events.EventDispatcher;

import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaType;
import org.osmf.media.URLResource;
import org.osmf.metadata.Metadata;
import org.osmf.net.DynamicStreamingItem;
import org.osmf.net.DynamicStreamingResource;
import org.osmf.net.StreamType;

/**
 * This parser does not build a heirarchy of element. It only notifies the listener when it creates video and image
 * elements and it is up to the listener to add them to serial or parallel compositions depending on contentType.
 */
public class SMILParser extends EventDispatcher {

    use namespace smil;

    private var smilDocument:XML;
    private var factory:MediaFactory;

    private var _adBreaks:Vector.<AdBreak> = new Vector.<AdBreak>();
    private var ignoreContent:Vector.<String> = new Vector.<String>();

    public function SMILParser(smilDocument:XML, factory:MediaFactory) {
        this.smilDocument = smilDocument;
        this.factory = factory;
    }

    public function parse() {
        generateAdBreaks();

        for each (var child:XML in smilDocument.body.*) {
            parseChild(child);
        }
    }

    private function parseChild(child:XML):void {
        switch (child.name().localName) {
            case "par":
                parsePar(child);
                break;
            case "seq":
                parseSeq(child);
                break;
            case "video":
                parseVideo(child);
                break;
            case "switch":
                parseSwitch(child);
                break;
            case "img":
                parseImage(child);
                break;
        }
    }

    private function parseSeq(seq:XML):void {
        for each (var child:XML in seq.*) {
            parseChild(child);
        }
    }

    private function parsePar(par:XML):void {
        for each (var child:XML in par.*) {
            parseChild(child);
        }
    }

    private function parseSwitch(swit:XML):void {
        var hostURL:String = smilDocument.head.meta[0].@base;

        var dsr:DynamicStreamingResource = null;
        var streamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();

        var lastSwitchItem:XML = null;
        var contentType:String = null;
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
            var metadata:Metadata = getMetadata(video);
            dsr.addMetadataValue(SMILConstants.SMIL_NAMESPACE, metadata);

            var element:MediaElement = factory.createMediaElement(dsr);

            if (element) {
                element.addMetadata(SMILConstants.SMIL_NAMESPACE, metadata);

                var adMetadata:AdMetadata = new AdMetadata();
                adMetadata.adBreaks = adBreaks;
                element.addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);

                dispatchEvent(
                        new SMILParserEvent(
                                SMILParserEvent.MEDIA_ELEMENT_CREATED,
                                element,
                                MediaType.VIDEO, contentType));
            }
        }
    }

    private function parseVideo(video:XML):void {
        var src:String = video.@src;
        var contentType:String = video..meta.(@name == SMILConstants.CONTENT_TYPE).@content;

        if (src && !isIgnoredContent(contentType)) {
            var metadata:Metadata = getMetadata(video);
            var resource:URLResource = new URLResource(src);
            resource.addMetadataValue(SMILConstants.SMIL_NAMESPACE, metadata);

            var element:MediaElement = factory.createMediaElement(resource);

            if (element) {
                element.addMetadata(SMILConstants.SMIL_NAMESPACE, metadata);

                var adMetadata:AdMetadata = new AdMetadata();
                adMetadata.adBreaks = adBreaks;
                element.addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);

                dispatchEvent(
                        new SMILParserEvent(
                                SMILParserEvent.MEDIA_ELEMENT_CREATED,
                                element,
                                MediaType.VIDEO, contentType));
            }
        }
    }

    private function parseImage(image:XML):void {
        var src:String = image.@src;
        var contentType:String = image..meta.(@name == SMILConstants.CONTENT_TYPE).@content;

        if (src && !isIgnoredContent(contentType)) {
            var metadata:Metadata = getMetadata(image);
            var resource:URLResource = new URLResource(src);
            resource.addMetadataValue(SMILConstants.SMIL_NAMESPACE, metadata);

            var element:MediaElement = factory.createMediaElement(resource);

            if (element) {
                element.addMetadata(SMILConstants.SMIL_NAMESPACE, metadata);

                dispatchEvent(
                        new SMILParserEvent(
                                SMILParserEvent.MEDIA_ELEMENT_CREATED,
                                element,
                                MediaType.IMAGE, contentType));
            }
        }
    }

    private function generateAdBreaks():void {
        var index:int = 0;
        var prerollAdded:Boolean = false;
        for each (var video:XML in smilDocument.body..video) {
            if (video.@clipBegin) {
                if (index > 0 && !prerollAdded) {
                    // add a pre-roll break
                    var adBreak:AdBreak = new AdBreak();
                    adBreak.startTime = 0;
                    adBreaks.push(adBreak);
                    prerollAdded = true;
                }
                var clipStart:int = parseInt(video.@clipBegin);
                if (clipStart > 0) {
                    var adBreak:AdBreak = new AdBreak();
                    adBreak.startTime = clipStart;
                    adBreaks.push(adBreak);
                }
            }
            index++;
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

    public function getHeadMetaValue(key:String):String {
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

    public function get adBreaks():Vector.<AdBreak> {
        return _adBreaks;
    }
}
}
