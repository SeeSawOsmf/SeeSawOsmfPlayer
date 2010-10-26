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

    public static function get playerInit():Object {
        var playerInitData:Object = {
            "timestamp":1288026360828,
            "guidance":{
                "guidance":"guidance",
                "explanation":"This programme isn't suitable for younger viewers",
                "warning":"Strong language and adult humour"},
            "programme":{
                "svod":false,
                "genres":"\"TV:ENTERTAINMENT:OTHER_ENTERTAINMENT\", \"TV:COMEDY:SKETCH_SHOWS\", \"TV:ENTERTAINMENT:FAMILY_ENTERTAINMENT\"",
                "rollupAgeRating":"16",
                "displayMode":"series",
                "smallImageUrl":"http://kgd-red-dev-zxtm01.dev.vodco.co.uk/i/ccp/programs/Small.jpg",
                "filmAgeRating":"U",
                "formattedTitle":"South Park programme 2: South Park programme 2",
                "titleExt":"South Park programme 2",
                "tvAgeRating":"16",
                "episodeNumber":2,
                "petiteImageUrl":"http://kgd-red-dev-zxtm01.dev.vodco.co.uk/i/ccp/programs/Petite.jpg",
                "id":12001018002,
                "title":"South Park programme 2",
                "duration":1800,
                "avod":true,
                "programmeType":"TV",
                "tvod":false,
                "largeImageUrl":"http://kgd-red-dev-zxtm01.dev.vodco.co.uk/i/ccp/programs/Large.jpg",
                "synopsis":"South Park programme 2"},
            "parentalControls":{
                "parentalControlsPageURL":"/Parental_Controls",
                "termsAndConditionsLinkURL":"",
                "helpSectionLinkURL":"",
                "lostPinLinkURL":"",
                "whatsThisLinkURL":""},
            "videoPlayerInfoUrl":"http://localhost:8080/player.playerinitialisation:videoinfo?t:ac=TV:ENTERTAINMENT/p/12001018002/South-Park-programme-2",
            "unavailablePageUrl":"/unavailable"};

        return playerInitData;
    }

    public static function get videoInfo():Object {
        var videoPlayerInfoData:Object = {
            "timestamp":1288026611892,
            "assets":{
                "low":{
                    "height":288,
                    "cdn":"rtmpe://cdn-flash-red-dev.vodco.co.uk/a2703",
                    "width":512,
                    "quality":1,
                    "path":"e5/dev/ccp/p/LOW_RES/testing/big_buck_bunny_1080p_h264.mp4?s=1288026581&e=1288027331&h=06c0ddb776936627c999682029c49a12",
                    "bitrate":500,
                    "type":"mp4"}},
            "geoblocked":"false",
            "programmeId":12001018002,
            "contentInfo": contentInfo};

        return videoPlayerInfoData;
    }
}
}