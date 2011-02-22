/*
 * The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *   The Initial Developer of the Original Code is Arqiva Ltd.
 *   Portions created by Arqiva Limited are Copyright (C) 2010, 2011 Arqiva Limited.
 *   Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe
 * 	Systems Incorporated.
 *   All Rights Reserved.
 *
 *   Contributor(s):  Adobe Systems Incorporated
 */

package com.seesaw.player.batcheventservices.events {

public class ViewEvent {

    private var transactionItemId:int;
    private var _serverTimeStamp:int;
    private var _userId:int;
    private var _anonymousUserId:int;
    private var sectionCount:int;
    private var mainAssetId:int;

    public function ViewEvent(transactionItemId:int, serverTimeStamp:int, sectionCount:int, mainAssetId:int, userId:int, anonymousUserId:int) {
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

    public function get anonymousUserId():int {
        return _anonymousUserId;
    }

    public function get getAnonymousUserId():int {
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