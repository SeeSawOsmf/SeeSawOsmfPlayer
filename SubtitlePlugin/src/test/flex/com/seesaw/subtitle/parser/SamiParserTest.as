package com.seesaw.subtitle.parser {
import com.seesaw.subtitle.sami.SAMIParser;

import org.hamcrest.assertThat;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.notNullValue;

public class SAMIParserTest {

    [Test]
    public function canParseSAMI() {
        var parser:CaptionParser = new SAMIParser();
        var captions:Vector.<CaptionSync> = parser.parse(VALID_SAMI);

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