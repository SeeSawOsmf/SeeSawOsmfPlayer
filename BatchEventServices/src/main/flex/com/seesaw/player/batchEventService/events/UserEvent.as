/**
 * Created by IntelliJ IDEA.
 * User: usaimbi
 * Date: 10/01/11
 * Time: 18:09
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.batchEventService.events {

public class UserEvent {

    private var userEventId:int;
    private var cumulativeViewDuration:int;
    private var eventType:String;
    private var _programmeId:int;

    public function UserEvent( userEventId:int, cumulativeViewDuration:int, eventType:String, programmeId:int ) {
        this._programmeId = programmeId;
        this.userEventId = userEventId;
        this.cumulativeViewDuration = cumulativeViewDuration;
        this.eventType = eventType;
    }

    public function get getUserEventId():int {
        return userEventId;
    }

    public function get getCulmulativeViewDuration():int {
        return cumulativeViewDuration;
    }

    public function get getEventType():String {
        return eventType;
    }

    public function get getEventOccured():Date {
        return new Date();
    }

    public function get getProgrammeId():int {
        return _programmeId;
    }
}
}
