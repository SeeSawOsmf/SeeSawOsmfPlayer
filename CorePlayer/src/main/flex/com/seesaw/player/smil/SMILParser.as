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

import org.osmf.elements.ParallelElement;
import org.osmf.elements.SerialElement;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.URLResource;
import org.osmf.metadata.Metadata;
import org.osmf.net.DynamicStreamingItem;
import org.osmf.net.DynamicStreamingResource;
import org.osmf.net.StreamType;

public class SMILParser extends EventDispatcher {

    // TODO: put these into a constant class in PlayerCommon
    public static const SMIL_NAMESPACE = "http://www.seesaw.com/player/api/smil";
    public static const CONTENT_TYPE = "contentType";

    use namespace smil;

    private var smilDocument:XML;

    private var factory:MediaFactory;

    private var _adBreaks:Vector.<AdBreak> = new Vector.<AdBreak>();

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

    private function parseSeq(seq:XML):void {
        var serial:SerialElement = new SerialElement();

        dispatchEvent(
                new SMILParserEvent(
                        SMILParserEvent.MEDIA_ELEMENT_CREATED,
                        serial,
                        SMILElementType.SERIAL));

        for each (var child:XML in seq.*) {
            parseChild(child);
        }
    }

    private function parsePar(par:XML):void {
        var parallel:ParallelElement = new ParallelElement();

        dispatchEvent(
                new SMILParserEvent(
                        SMILParserEvent.MEDIA_ELEMENT_CREATED,
                        parallel,
                        SMILElementType.PARALLEL));

        for each (var child:XML in par.*) {
            parseChild(child);
        }
    }

    private function parseSwitch(swit:XML):void {
        var hostURL:String = smilDocument.head.meta[0].@base;

        var dsr:DynamicStreamingResource = null;
        var streamItems:Vector.<DynamicStreamingItem> = new Vector.<DynamicStreamingItem>();

        var lastSwitchItem:XML = null;
        for each (var video:XML in swit.video) {
            var dsi:DynamicStreamingItem = new DynamicStreamingItem(video.@src, video.@["system-bitrate"] / 1000);
            streamItems.push(dsi);
            lastSwitchItem = video;
        }

        if (streamItems.length > 0) {
            dsr = new DynamicStreamingResource(hostURL);
            if (lastSwitchItem) {
                var clipBegin:int = lastSwitchItem.@clipBegin;
                var clipEnd:int = lastSwitchItem.clipEnd;

                if (!isNaN(clipBegin) && clipBegin > -1 && !isNaN(clipEnd) && clipEnd > 0) {
                    dsr.clipStartTime = clipBegin;
                    dsr.clipEndTime = clipEnd;
                }
            }

            dsr.streamItems = streamItems;
            dsr.streamType = StreamType.LIVE_OR_RECORDED;
        }

        if (dsr) {
            var element:MediaElement = factory.createMediaElement(dsr);

            var contentType:String = lastSwitchItem..meta.(@name == CONTENT_TYPE).@content;

            var metadata:Metadata = new Metadata();
            metadata.addValue(CONTENT_TYPE, contentType);
            element.addMetadata(SMIL_NAMESPACE, metadata);

            metadata = new Metadata();
            metadata.addValue(AdMetadata.AD_BREAKS, adBreaks);
            element.addMetadata(AdMetadata.AD_NAMESPACE, metadata);

            dispatchEvent(
                    new SMILParserEvent(
                            SMILParserEvent.MEDIA_ELEMENT_CREATED,
                            element,
                            SMILElementType.VIDEO));
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
        }
    }

    private function parseVideo(video:XML):void {
        var src:String = video.@src;
        var contentType:String = video..meta.(@name == CONTENT_TYPE).@content;

        if (src) {
            var element:MediaElement = factory.createMediaElement(new URLResource(src));

            var metadata:Metadata = new Metadata();
            metadata.addValue(CONTENT_TYPE, contentType);
            element.addMetadata(SMIL_NAMESPACE, metadata);

            metadata = new Metadata();
            metadata.addValue(AdMetadata.AD_BREAKS, adBreaks);
            element.addMetadata(AdMetadata.AD_NAMESPACE, metadata);

            dispatchEvent(
                    new SMILParserEvent(
                            SMILParserEvent.MEDIA_ELEMENT_CREATED,
                            element,
                            SMILElementType.VIDEO, contentType));
        }
    }

    private function generateAdBreaks():void {
        for each (var video:XML in smilDocument.body..video) {
            if (video.@clipBegin) {
                var clipStart:int = parseInt(video.@clipBegin);
                if (clipStart > 0) {
                    var adBreak:AdBreak = new AdBreak();
                    adBreak.startTime = clipStart;
                    adBreaks.push(adBreak);
                }
            }
        }
    }

    public function get adBreaks():Vector.<AdBreak> {
        return _adBreaks;
    }
}
}
