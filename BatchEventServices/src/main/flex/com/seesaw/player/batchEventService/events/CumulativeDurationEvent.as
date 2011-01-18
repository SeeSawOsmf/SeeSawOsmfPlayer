/**
 * Created by IntelliJ IDEA.
 * User: usaimbi
 * Date: 13/01/11
 * Time: 11:27
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.batchEventService.events {
public class CumulativeDurationEvent {

    private var _programmeId:int;
    private var _transactionItemId:int;

    public function CumulativeDurationEvent( programmeId:int , transactionItemId:int ) {
        this._programmeId = programmeId;
        this._transactionItemId = transactionItemId;
    }

    public function get programmeId():int {
        return _programmeId;
    }

    public function get transactionItemId():int {
        return _transactionItemId;
    }
}
}
