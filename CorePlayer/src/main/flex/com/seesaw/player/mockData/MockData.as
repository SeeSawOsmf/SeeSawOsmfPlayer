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

    public function get playerInit():Object {

        var playerInitData:Object = {
            "programmeId":10001,
            "videoPlayerInfoUrl":"http://localhost:8080/player.videoplayerinfo:getvideoplayerinfo?t:ac=TV:COMEDY/p/41001001001/No-Series-programmes-programme-1"
        }
        return playerInitData;
    }

    public function get videoPlayerInfo():Object {

        var videoPlayerInfoData:Object = {
            "programmeId":10001,
            "scheme":"rtmpe",
            "cdnPath":"cdn-flash-red-dev.vodco.co.uk/a2703",
            "lowResAssetType":["mp4"],
            "lowResAssetPath":["e5/test/ccp/p/LOW_RES/test/test_asset.mp4?s=1286540710&e=1286584210&h=0a882c290f40c11b48435e35861f9c49"]
        }
        return videoPlayerInfoData;
    }
}
}