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