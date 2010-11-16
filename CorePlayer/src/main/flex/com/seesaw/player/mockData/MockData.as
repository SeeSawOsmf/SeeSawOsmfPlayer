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

package com.seesaw.player.mockData {
public class MockData {

    public static function get contentInfo():XML {
        var contentInfoBBC:XML = new XML('<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>' +
                '<ns2:contentInfo xmlns:ns2=\"http:\/\/www.vodco.co.uk\/sherbet\/advertising\/v1.6\">' +
                '<primaryGenre>TV:COMEDY:SATIRE<\/primaryGenre>' +
                '<sourceId>BBC_WORLDWIDE<\/sourceId>' +
                '<firstPresentationBrand>BBC<\/firstPresentationBrand>' +
                '<brandId>fc40414b-6cef-4690-9042-a8a9b9880cc6<\/brandId>' +
                '<brandTitle>The Thick of It<\/brandTitle>' +
                '<seriesId>25142<\/seriesId>' +
                '<seriesTitle>The Thick of It<\/seriesTitle>' +
                '<programmeId>ABDB188B-01<\/programmeId>' +
                '<programmeTitle>Episode 1<\/programmeTitle>' +
                '<tvAgeRating>16<\/tvAgeRating>' +
                '<duration>1754<\/duration>' +
                '<adRule>ALWAYS<\/adRule>' +
                '<catchup>false<\/catchup>' +
                '<loggingSheet><break>' +
                '<breakOffset>00:12:48.52<\/breakOffset>' +
                '<resumeOffset>00:12:49.08<\/resumeOffset>' +
                '<data>RSTRCT=NONE<\/data>' +
                '<\/break>' +
                '<\/loggingSheet>' +
                '<\/ns2:contentInfo>');

        var contentInfoFive:XML = new XML('<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>' +
                '<ns2:contentInfo xmlns:ns2=\"http:\/\/www.vodco.co.uk\/sherbet\/advertising\/v1.6\">' +
                '<primaryGenre>TV:DRAMA:SOAPS<\/primaryGenre>' +
                '<sourceId>C5<\/sourceId>' +
                '<firstPresentationBrand>Demand FIVE<\/firstPresentationBrand>' +
                '<brandId>Neighbours<\/brandId>' +
                '<brandTitle>Neighbours<\/brandTitle>' +
                '<seriesId>14945<\/seriesId>' +
                '<seriesTitle>Neighbours<\/seriesTitle>' +
                '<programmeId>ecf9bcf8-7632-4179-aff6-545e635285bb<\/programmeId>' +
                '<programmeTitle>Neighbours<\/programmeTitle>' +
                '<tvAgeRating>0<\/tvAgeRating>' +
                '<duration>3600<\/duration>' +
                '<adRule>ALWAYS<\/adRule>' +
                '<catchup>true<\/catchup>' +
                '<loggingSheet>' +
                '<break>' +
                '<breakOffset>00:02:00.01<\/breakOffset>' +
                '<resumeOffset>00:02:00.01<\/resumeOffset>' +
                '<\/break>' +
                '<\/loggingSheet>' +
                '<\/ns2:contentInfo>');

        return contentInfoBBC;

    }


    public static function get smil():XML {
        var xml:XML = new XML('<smil><head><meta base="rtmpe://cdn-flash-red-dev.vodco.co.uk/a2703" /></head>' +
                '<body><seq>' +
                '<switch>' +
                '<video src="mp4:e5/INTERNAL/sintel-2048-stereo_500kbs.mp4" system-bitrate="500000" width="512" clipEnd="60s" dur="60s"/>' +
                '<video src="mp4:e5/INTERNAL/sintel-2048-stereo_796kbs.mp4" system-bitrate="800000" width="720"  clipEnd="60s" dur="60s"/>' +
                '<video src="mp4:e5/INTERNAL/sintel-2048-stereo_1500kbs.mp4" system-bitrate="1500000" width="1080"  clipEnd="60s" dur="60s"/>' +
                '</switch>' +
                '<seq>' +
                '<par> ' +
                '<video region="content" src="http://mediapm.edgesuite.net/strobe/content/test/SpaceAloneHD_sounas_640_500_short.flv" />  ' +
                '</par>' +
                '<video region="content" src="http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv" />  ' +
                '<video region="content" src="http://mediapm.edgesuite.net/strobe/content/test/elephants_dream_768x428_24_short.flv" />   ' +
                '</seq></seq>' +
                '</body>' +
                '</smil>');

        return xml;


    }
}
}