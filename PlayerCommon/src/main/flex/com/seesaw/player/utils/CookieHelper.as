/*
 * Copyright 2011 ioko365 Ltd.  All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the
 * License athttp://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2011 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2011 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 */

/**
 * Created by IntelliJ IDEA.
 * User: ibhana
 * Date: 03/03/11
 * Time: 09:48
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.utils {
import flash.events.NetStatusEvent;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;

public class CookieHelper {

    private var logger:ILogger = LoggerFactory.getClassLogger(CookieHelper);

    private var _localSharedObject:SharedObject;

    public function CookieHelper(id:String) {
        _localSharedObject = SharedObject.getLocal(id);
    }

    public function flush():void {
        var flushStatus:String = null;
        try {
            flushStatus = localSharedObject.flush(10000);
        } catch (error:Error) {
            logger.error("could not write SharedObject to disk: {0}", error.message);
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

    public function get localSharedObject():SharedObject {
        return _localSharedObject;
    }
}
}
