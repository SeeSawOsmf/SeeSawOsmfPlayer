/**
 * Created by IntelliJ IDEA.
 * User: usaimbi
 * Date: 12/01/11
 * Time: 17:18
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.batcheventservices.events.manager {
import com.seesaw.player.batcheventservices.events.ContentEvent;
import com.seesaw.player.batcheventservices.events.CumulativeDurationEvent;
import com.seesaw.player.batcheventservices.events.UserEvent;

public interface EventsManager {

    function addUserEvent( userEvent:UserEvent ):void;
    function addContentEvent( contentEvent:ContentEvent ):void;
    function flushAll():void;
    function flushCumulativeDuration( cumulativeDuration:CumulativeDurationEvent ):void;
}
}
