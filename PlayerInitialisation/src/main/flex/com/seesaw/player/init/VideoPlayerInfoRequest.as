package com.seesaw.player.init {
public class VideoPlayerInfoRequest extends ServiceRequestBase {

    private static const VIDEO_PLAYER_INFO:String = "videoplayerinfo";

    private var _programmeId:int;

    public function VideoPlayerInfoRequest(baseUrl:String, programmeId:int) {
        super(baseUrl);
        _programmeId = programmeId;
    }

    public override function submit():void {
        // TODO: do something with the parameter PAID
        load(baseUrl + "/" + VIDEO_PLAYER_INFO + "/" + programmeId + "/PAID");
    }

    public function get programmeId():int {
        return _programmeId;
    }

    public function set programmeId(value:int):void {
        _programmeId = value;
    }
}
}