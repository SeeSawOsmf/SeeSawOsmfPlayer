package com.seesaw.player.batcheventservices.events {

public class ViewEvent {

    private var transactionItemId:int;
    private var _serverTimeStamp:Number;
    private var _userId:int;
    private var _anonymousUserId:uint;
    private var sectionCount:int;
    private var mainAssetId:int;

    public function ViewEvent(transactionItemId:int, serverTimeStamp:Number, sectionCount:int, mainAssetId:int, userId:int, anonymousUserId:Number) {
        this._userId = userId;
        this._anonymousUserId = anonymousUserId;
        this.transactionItemId = transactionItemId;
        this._serverTimeStamp = serverTimeStamp;
        this.sectionCount = sectionCount;
        this.mainAssetId = mainAssetId;
    }

    public function get serverTimeStamp():int {
        return _serverTimeStamp;
    }

    public function get getServerTimeStamp():Number {
        return _serverTimeStamp;
    }

    public function get getMainAssetId():int {
        return mainAssetId;
    }

    public function get getTransactionItemId():int {
        return transactionItemId;
    }

    public function get getTransmitOccurred():Date {
        return new Date();
    }

    public function get getSectionCount():int {
        return sectionCount;
    }

    public function get anonymousUserId():Number {
        return _anonymousUserId;
    }

    public function get getAnonymousUserId():Number{
        return _anonymousUserId;
    }

    public function get getUserId():int {
        return _userId;
    }

    public function get userId():int {
        return _userId;
    }
}
}