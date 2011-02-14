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
 * Time: 09:25
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player {
import com.seesaw.player.smil.*;
import com.seesaw.player.ads.AdBreak;

import org.hamcrest.assertThat;
import org.hamcrest.object.equalTo;
import org.osmf.elements.ImageElement;
import org.osmf.elements.ParallelElement;
import org.osmf.elements.SerialElement;
import org.osmf.elements.VideoElement;
import org.osmf.media.DefaultMediaFactory;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.URLResource;
import org.osmf.metadata.Metadata;

public class SMILParserTest {

    private var parser:SMILParser;

    [Before]
    public function runBeforeAllTests():void {
        parser = new SMILParser(smil, null, new DefaultMediaFactory());
    }

    [Test]
    public function canParseMainContent():void {
        var element:ParallelElement = parser.parseMainContent() as ParallelElement;
        var videoElement:VideoElement = element.getChildAt(0) as VideoElement;
        var metadata:Metadata = videoElement.getMetadata(SMILConstants.SMIL_NAMESPACE);
        assertThat(metadata.getValue("contentType"), equalTo("mainContent"));

        var imageElement:ImageElement = element.getChildAt(1) as ImageElement;
        var metadata:Metadata = imageElement.getMetadata(SMILConstants.SMIL_NAMESPACE);
        assertThat(metadata.getValue("contentType"), equalTo("dogImage"));
    }

    [Test]
    public function canParseAdBreaks():void {
        var adBreaks:Vector.<AdBreak> = parser.parseAdBreaks();
        assertThat(adBreaks.length, equalTo(2));

        assertThat(adBreaks[0].startTime, equalTo(0));

        var playlist:SerialElement = adBreaks[0].adPlaylist;
        assertThat(playlist.numChildren, equalTo(2));

        var resource:URLResource = playlist.getChildAt(0).resource as URLResource;
        assertThat(resource.url, equalTo("rtmp://seesaw.com/ad1.mp4"));

        var metadata:Metadata = playlist.getChildAt(0).getMetadata(SMILConstants.SMIL_NAMESPACE);
        assertThat(metadata.getValue("contentType"), equalTo("sting"));

        resource = playlist.getChildAt(1).resource as URLResource;
        assertThat(resource.url, equalTo("rtmp://seesaw.com/ad2.mp4"));

        metadata = playlist.getChildAt(1).getMetadata(SMILConstants.SMIL_NAMESPACE);
        assertThat(metadata.getValue("contentType"), equalTo("advert"));

        assertThat(adBreaks[1].startTime, equalTo(300));

        playlist = adBreaks[1].adPlaylist;
        assertThat(playlist.numChildren, equalTo(1));

        resource = playlist.getChildAt(0).resource as URLResource;
        assertThat(resource.url, equalTo("rtmp://seesaw.com/ad3.mp4"));

        metadata = playlist.getChildAt(0).getMetadata(SMILConstants.SMIL_NAMESPACE);
        assertThat(metadata.getValue("contentType"), equalTo("advert"));
    }

    public function SMILParserTest() {
    }

    // mock smil with fake urls
    private var smil:XML = new XML(
            "<smil>" +
                    "<head>" +
                    "<meta base=\"rtmpe://seesaw.com/origin\"/>" +
                    "</head>" +
                    "<body>" +
                    "<seq>" +
                    "<video src=\"rtmp://seesaw.com/ad1.mp4\">" +
                    "<metadata>" +
                    "<meta content=\"sting\" name=\"contentType\"/>" +
                    "</metadata>" +
                    "</video>" +
                    "<video src=\"rtmp://seesaw.com/ad2.mp4\">" +
                    "<metadata>" +
                    "<meta content=\"advert\" name=\"contentType\"/>" +
                    "<meta content=\"http://seesaw.com/click/ad2\" name=\"trackback\"/>" +
                    "</metadata>" +
                    "</video>" +
                    "<par>" +
                    "<switch>" +
                    "<video src=\"mp4:main_content.mp4\" system-bitrate=\"844000\" dur=\"852\" clipEnd=\"300\" clipBegin=\"0\">" +
                    "<metadata>" +
                    "<meta content=\"mainContent\" name=\"contentType\"/>" +
                    "</metadata>" +
                    "</video>" +
                    "</switch>" +
                    "<img src=\"http://seesaw.com/dog.png\">" +
                    "<metadata>" +
                    "<meta content=\"dogImage\" name=\"contentType\"/>" +
                    "</metadata>" +
                    "</img>" +
                    "</par>" +
                    "<video src=\"rtmp://seesaw.com/ad3.mp4\">" +
                    "<metadata>" +
                    "<meta content=\"advert\" name=\"contentType\"/>" +
                    "<meta content=\"http://seesaw.com/click/ad3\" name=\"trackback\"/>" +
                    "</metadata>" +
                    "</video>" +
                    "<par>" +
                    "<video src=\"mp4:main_content.mp4\" system-bitrate=\"844000\" dur=\"852\" clipEnd=\"852\" clipBegin=\"300\">" +
                    "<metadata>" +
                    "<meta content=\"mainContent\" name=\"contentType\"/>" +
                    "</metadata>" +
                    "</video>" +
                    "<img src=\"http://seesaw.com/dog.png\">" +
                    "<metadata>" +
                    "<meta content=\"dogImage\" name=\"contentType\"/>" +
                    "</metadata>" +
                    "</img>" +
                    "</par>" +
                    "</seq>" +
                    "</body>" +
                    "</smil>");
}
}
