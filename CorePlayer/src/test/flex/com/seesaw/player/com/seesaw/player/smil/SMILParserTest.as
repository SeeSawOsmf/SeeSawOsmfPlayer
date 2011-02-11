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
package com.seesaw.player.com.seesaw.player.smil {
import com.seesaw.player.smil.SMILParser;
import com.seesaw.player.smil.SMILParserEvent;

import org.flexunit.asserts.assertEquals;
import org.hamcrest.assertThat;
import org.hamcrest.object.equalTo;
import org.osmf.elements.ParallelElement;
import org.osmf.elements.SerialElement;
import org.osmf.media.DefaultMediaFactory;
import org.osmf.media.MediaType;

public class SMILParserTest {

    private var parser:SMILParser;
    private var serialPlaylist:SerialElement;
    private var mainContent:ParallelElement;

    [Before]
    public function runBeforeAllTests() {
        parser = new SMILParser(smil, new DefaultMediaFactory());
        serialPlaylist = new SerialElement();
        mainContent = new ParallelElement();
    }

    [Test]
    public function testParse():void {
        parser.addEventListener(SMILParserEvent.MEDIA_ELEMENT_CREATED, function(event:SMILParserEvent):void {
            if (event.mediaType == MediaType.VIDEO && event.contentType == "advert") {
                serialPlaylist.addChild(event.mediaElement);
            }
            else if (event.mediaType == MediaType.VIDEO && event.contentType == "mainContent") {
                mainContent.addChild(event.mediaElement);
                parser.addIgnoredContentType("mainContent");
            }
            else if (event.mediaType == MediaType.IMAGE && event.contentType == "dogImage") {
                mainContent.addChild(event.mediaElement);
                parser.addIgnoredContentType("dogImage");
            }
        });
        parser.parse();
        assertThat(mainContent.numChildren, equalTo(2));
        assertThat(serialPlaylist.numChildren, equalTo(2));
    }

    public function SMILParserTest() {
    }

    private var smil:XML = new XML("<smil>" +
            "<head>" +
            "<meta base=\"rtmpe://cdn-flash-blue-dev.vodco.co.uk/a2703\"/>" +
            "<meta content=\"http://kgd-blue-test-zxtm01.dev.vodco.co.uk/s/ccp/00000002/298.smi\"" +
            "name=\"subtitleLocation\"/>" +
            "</head>" +
            "<body>" +
            "<seq>" +
            "<video src=\"rtmp://cp53221.edgefcs.net/ondemand/mp4:h264/Seesaw_Recycling.mp4\">" +
            "<metadata>" +
            "<meta content=\"advert\" name=\"contentType\"/>" +
            "<meta content=\"http://seesaw.stage.vodco.co.uk/cp/c4/RealMedia/ads/adstream_lx.ads/kprod.channel4.com/channel4/channel4/tv/comedy/alternative/35925/35925/001/L18/12116635505/x13/4OD/SS_IDENT_Feb10_x90/2362406/553249624b3079475550554142667248\" " +
            "name=\"trackback\"/>" +
            "</metadata>" +
            "</video>" +
            "<par>" +
            "<switch>" +
            "<video src=\"rtmpe://cdn-flash-blue-dev.vodco.co.uk/a2703/mp4:e4/test/ccp/p/STD_RES/00000418/41805.mp4?s=1296224433&amp;e=1296225183&amp;h=a61d40407278eaa0528fbeb2939b8aaa\" " +
            "system-bitrate=\"844000\" dur=\"852\" clipEnd=\"300\" clipBegin=\"0\">" +
            "<metadata>" +
            "<meta content=\"mainContent\" name=\"contentType\"/>" +
            "</metadata>" +
            "</video>" +
            "</switch>" +
            "<img src=\"http://kgd-blue-test-preview-zxtm01.dev.vodco.co.uk/i/cms/images/presentationBrand/CHANNEL4_DOG.png\">" +
            "<metadata>" +
            "<meta content=\"dogImage\" name=\"contentType\"/>" +
            "</metadata>" +
            "</img>" +
            "</par>" +
            "<video src=\"rtmp://cp53221.edgefcs.net/ondemand/mp4:h264/eng-izor002-020-SD.mp4\">" +
            "<metadata>" +
            "<meta content=\"advert\" name=\"contentType\"/>" +
            "<meta content=\"http://seesaw.stage.vodco.co.uk/cp/c4/RealMedia/ads/adstream_lx.ads/kprod.channel4.com/channel4/channel4/tv/comedy/alternative/35925/35925/001/L64/11583353263/x12/4OD/UNIVERSAL_MUSIC_011111_13647_2/2701060/553249624b3079475550554142667248\" " +
            "name=\"trackback\"/>" +
            "<meta content=\"http://realmedia.channel4.com/5c/kprod.channel4.com/channel4/channel4/tv/comedy/alternative/35925/35925/001/L64/1583353263/x60/4OD/UNIVERSAL_MUSIC_011111_13647_2/UNIVERSAL_MUSIC_011111_13647_1.html/553249624b3079475550554142667248\" " +
            "name=\"popupAdvertisingUrl\"/>" +
            "</metadata>" +
            "</video>" +
            "<par>" +
            "<video src=\"rtmpe://cdn-flash-blue-dev.vodco.co.uk/a2703/mp4:e4/test/ccp/p/STD_RES/00000418/41805.mp4?s=1296224433&amp;e=1296225183&amp;h=a61d40407278eaa0528fbeb2939b8aaa\" " +
            "system-bitrate=\"844000\" dur=\"852\" clipEnd=\"852\" clipBegin=\"300\">" +
            "<metadata>" +
            "<meta content=\"mainContent\" name=\"contentType\"/>" +
            "</metadata>" +
            "</video>" +
            "<img src=\"http://kgd-blue-test-preview-zxtm01.dev.vodco.co.uk/i/cms/images/presentationBrand/CHANNEL4_DOG.png\">" +
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
