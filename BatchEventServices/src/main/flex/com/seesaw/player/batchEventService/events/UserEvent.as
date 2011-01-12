/**
 * Created by IntelliJ IDEA.
 * User: usaimbi
 * Date: 10/01/11
 * Time: 18:09
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.batchEventService.events {

public class UserEvent {

    private var viewId;Number;
    private var userEventId:int;
    private var cumulativeViewDuration:int;
    private var eventType:String;
    private var eventOccurred:Date;

    public function UserEvent( viewId:Number, userEventId:int, cumulativeViewDuration:int, eventType:String, eventOccurred:Date  ) {
        this.viewId = viewId;
        this.userEventId = userEventId;
        this.cumulativeViewDuration = cumulativeViewDuration;
        this.eventType = eventType;
        this.eventOccurred = eventOccurred;
    }
}
}
