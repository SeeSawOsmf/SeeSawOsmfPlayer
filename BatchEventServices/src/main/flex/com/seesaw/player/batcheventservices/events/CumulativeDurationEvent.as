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
public class CumulativeDurationEvent {

    private var _programmeId:int;
    private var _transactionItemId:Number;

    public function CumulativeDurationEvent(programmeId:int, transactionItemId:Number) {
        this._programmeId = programmeId;
        this._transactionItemId = transactionItemId;
    }

    public function get programmeId():int {
        return _programmeId;
    }

    public function get transactionItemId():Number {
        return _transactionItemId;
    }
}
}
