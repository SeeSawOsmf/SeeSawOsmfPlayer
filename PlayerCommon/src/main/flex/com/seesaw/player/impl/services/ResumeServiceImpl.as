/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *    The contents of this file are subject to the Mozilla Public License
 *    Version 1.1 (the "License"); you may not use this file except in
 *    compliance with the License. You may obtain a copy of the
 *    License athttp://www.mozilla.org/MPL/
 *
 *    Software distributed under the License is distributed on an "AS IS"
 *    basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *    License for the specific language governing rights and limitations
 *    under the License.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 */
package com.seesaw.player.impl.services {
import com.hurlant.crypto.symmetric.TripleDESKey;
import com.hurlant.util.Hex;
import com.seesaw.player.services.ResumeService;

import flash.events.NetStatusEvent;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;
import flash.utils.ByteArray;

public class ResumeServiceImpl implements ResumeService {
    private var tripleDESKey:TripleDESKey;
    private static const ENCRYTION_KEY:String = "this%is%the%new%static%encryption%key%";
    private static const SHARED_OBJECT_LOCAL:String = "Seesaw-Player";
    private var localSharedObject:SharedObject;

    public function ResumeServiceImpl() {
        tripleDESKey = new TripleDESKey(Hex.toArray(ENCRYTION_KEY));
        localSharedObject = SharedObject.getLocal(SHARED_OBJECT_LOCAL);

    }

    public function getResumeCookie():Number {
        var cookie:Number = 0;
        if (localSharedObject.data.savedValue) {
            cookie = Number(getDecryptedValue(localSharedObject.data.savedValue));
        }
        return cookie;
    }

    public function writeResumeCookie(currentTime:Number):void {


        localSharedObject.data.savedValue = getEncryptedValue(String(currentTime));

        var flushStatus:String = null;
        try {
            flushStatus = localSharedObject.flush(10000);
        } catch (error:Error) {
            trace("Error...Could not write SharedObject to disk\n");
        }
        if (flushStatus != null) {
            switch (flushStatus) {
                case SharedObjectFlushStatus.PENDING:
                    trace("Requesting permission to save object...\n");
                    localSharedObject.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
                    break;
                case SharedObjectFlushStatus.FLUSHED:
                    trace("Value flushed to disk.\n");
                    break;
            }
        }

    }

    private function onFlushStatus(event:NetStatusEvent):void {
        trace("User closed permission dialog...\n");
        switch (event.info.code) {
            case "SharedObject.Flush.Success":
                trace("User granted permission -- value saved.\n");
                break;
            case "SharedObject.Flush.Failed":
                trace("User denied permission -- value not saved.\n");
                break;
        }
        localSharedObject.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
    }

    public function getEncryptedValue(value:String):String {
        var data:ByteArray = Hex.toArray(Hex.fromString(value));
        tripleDESKey.encrypt(data);
        var encryptedValue:String = Hex.fromArray(data);

        return encryptedValue;
    }

    public function getDecryptedValue(value:String):String {
        var data:ByteArray = Hex.toArray(value);
        tripleDESKey.decrypt(data);
        var decryptedValue:String = data.readUTFBytes(data.length);

        return decryptedValue;
    }
}
}