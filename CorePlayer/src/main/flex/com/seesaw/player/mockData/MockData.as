package com.seesaw.player.mockData {
public class MockData {

    private var videoPlayerInfoData:Object;

    public function MockData() {
    }

    public function get videoPlayerInfo():Object {

        videoPlayerInfoData = {
            "validTransaction":["true"],
            "serverTimeStamp":[1286541010215],
            "stdResAssetId":[6715],
            "lowResUrl":["rtmpe://cdn-flash-red-dev.vodco.co.uk/a2703/e5/test/ccp/p/LOW_RES/test/test_asset.mp4?s=1286540710&e=1286584210&h=0a882c290f40c11b48435e35861f9c49"],
            "partnerId":["SHERBET"],
            "lowResAssetId":[6714],
            "logDRM":["true"],
            "subtitleLocation":[""],
            "stdResUrl":["rtmpe://cdn-flash-red-dev.vodco.co.uk/a2703/e5/test/ccp/p/LOW_RES/test/test_asset.mp4?s=1286540710&e=1286584210&h=0a882c290f40c11b48435e35861f9c49"],
            "highResUrl":["rtmpe://cdn-flash-red-dev.vodco.co.uk/a2703/e5/test/ccp/p/LOW_RES/test/test_asset.mp4?s=1286540710&e=1286584210&h=0a882c290f40c11b48435e35861f9c49"],
            "offerType":["AVOD"],
            "geoBlocked":["false"],
            "grossUsageReached":["false"],
            "playlist":[null],
            "anonymousUserId":[5151618],
            "highResAssetId":[6716],
            "transactionItemId":["5151821"]
        }
        return videoPlayerInfoData;
    }
}
}