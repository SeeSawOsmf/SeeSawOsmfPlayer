package com.seesaw.player.batchEventService.events {
public class BatchEvent {

    private var userEventCount:int;
    private var batchEventId:int;
    private var contentEventCount:int;

    public function BatchEvent(userEventCount:int, batchEventId:int,contentEventCount:int) {
        this.userEventCount = userEventCount;
        this.batchEventId = batchEventId;
        this.contentEventCount = contentEventCount;
    }

    public function get getuserEventCount():int {
        return userEventCount;
    }

    public function get getBatchEventId():int {
        return batchEventId;
    }

    public function get geteventOccured():Date {
        return new Date();
    }

    public function get getcontentEventCount():int {
        return contentEventCount;
    }
}
}