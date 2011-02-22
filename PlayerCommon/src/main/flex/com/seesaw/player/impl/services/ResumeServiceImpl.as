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
package com.seesaw.player.impl.services {
import com.hurlant.crypto.symmetric.TripleDESKey;
import com.hurlant.util.Hex;
import com.seesaw.player.services.ResumeService;

import flash.events.NetStatusEvent;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;
import flash.utils.ByteArray;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;

public class ResumeServiceImpl implements ResumeService {

    private var logger:ILogger = LoggerFactory.getClassLogger(ResumeServiceImpl);

    private var _programmeId:String = "default";
    private var tripleDESKey:TripleDESKey;
    private static const ENCRYTION_KEY:String = "this%is%the%new%static%encryption%key%";
    private static const SHARED_OBJECT_LOCAL:String = "Seesaw-Player";
    private var localSharedObject:SharedObject;

    public function ResumeServiceImpl() {
        tripleDESKey = new TripleDESKey(Hex.toArray(ENCRYTION_KEY));
        localSharedObject = SharedObject.getLocal(SHARED_OBJECT_LOCAL);
    }

    public function get programmeId():String {
        return _programmeId;
    }

    public function set programmeId(value:String):void {
        _programmeId = value;
    }

    public function getResumeCookie():Number {
        var cookie:Number = 0;
        if (localSharedObject.data[programmeId] && localSharedObject.data[programmeId].savedValue) {
            cookie = Number(getDecryptedValue(localSharedObject.data[programmeId].savedValue));
        }
        return cookie;
    }

    public function writeResumeCookie(currentTime:Number):void {
        if (!localSharedObject.data[programmeId]) localSharedObject.data[programmeId] = {};
        localSharedObject.data[programmeId].savedValue = getEncryptedValue(String(currentTime));

        var flushStatus:String = null;
        try {
            flushStatus = localSharedObject.flush(10000);
        } catch (error:Error) {
            logger.error("could not write SharedObject to disk: " + error.message);
        }

        if (flushStatus != null) {
            switch (flushStatus) {
                case SharedObjectFlushStatus.PENDING:
                    logger.debug("Requesting permission to save object..");
                    localSharedObject.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
                    break;
                case SharedObjectFlushStatus.FLUSHED:
                    logger.debug("Value flushed to disk.");
                    break;
            }
        }
    }

    private function onFlushStatus(event:NetStatusEvent):void {
        logger.debug("User closed permission dialog...");
        switch (event.info.code) {
            case "SharedObject.Flush.Success":
                logger.debug("User granted permission -- value saved.");
                break;
            case "SharedObject.Flush.Failed":
                logger.debug("User denied permission -- value not saved.");
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
