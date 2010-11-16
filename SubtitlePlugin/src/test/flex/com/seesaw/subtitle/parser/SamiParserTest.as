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

package com.seesaw.subtitle.parser {
import com.seesaw.player.captioning.sami.SAMIParser;
import com.seesaw.player.parsers.captioning.CaptionDocument;
import com.seesaw.player.parsers.captioning.CaptionParser;
import com.seesaw.player.parsers.captioning.CaptionSync;

import org.hamcrest.assertThat;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.notNullValue;

public class SAMIParserTest {

    [Test]
    public function canParseSAMI() {
        var parser:CaptionParser = new SAMIParser();
        var captionDoc:CaptionDocument = parser.parse(VALID_SAMI);
        var captions:Vector.<CaptionSync> = captionDoc.captions;

        assertThat(captions, notNullValue());
        assertThat(captions.length, equalTo(3));

        var caption:CaptionSync = captions.pop();
        assertThat(caption.time, equalTo(4.44));
        assertThat(caption.display, equalTo("<P class=\"ENCC\"><font color=\"#FFFF00\"> in the Mediterranean sun. </font></P>"));

        caption = captions.pop();
        assertThat(caption.time, equalTo(1.04));
        assertThat(caption.display, equalTo("<P class=\"ENCC\"><font color=\"#FFFF00\"> Welcome to the Coach Trip - </font><br><font color=\"#FFFF00\"> seven couples on a 30-day tour </font></P>"));

        caption = captions.pop();
        assertThat(caption.time, equalTo(0.0));
        assertThat(caption.display, equalTo("<P class=\"ENCC\">&nbsp;</P>"));
    }

    private static const VALID_SAMI:String =
            '<SAMI>' +
                    '<Head>' +
                    '<STYLE TYPE=\"text/css+\">' +
                    '<!--' +
                    '.ENCC {Name:English; lang: en-US; SAMI_Type: CC;}' +
                    '-->' +
                    '</Style>' +
                    '</Head>' +
                    '<BODY>' +
                    '<Sync Start=\"0\"><P class=\"ENCC\">&nbsp;</P></Sync>' +
                    '<Sync Start=\"1040\"><P class=\"ENCC\"><span style=color:yellow;> Welcome to the Coach Trip - </span><br><span style=color:yellow;> seven couples on a 30-day tour </span></P></Sync>' +
                    '<Sync Start=\"4440\"><P class=\"ENCC\"><span style=color:yellow;> in the Mediterranean sun. </span></P></Sync>' +
                    '</Body>' +
                    '</SAMI>';
}
}