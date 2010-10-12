/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *   The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *
 *   The Initial Developer of the Original Code is ioko365 Ltd.
 *   Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *   Incorporated. All Rights Reserved.
 */

package com.seesaw.player.init {
import com.seesaw.player.logging.CommonsOsmfLoggerFactory;
import com.seesaw.player.logging.TraceAndArthropodLoggerFactory;

import flash.display.Sprite;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.logging.Log;

public class PlayerInitialiser extends Sprite {

    private static var loggerSetup:* = (LoggerFactory.loggerFactory = new TraceAndArthropodLoggerFactory());
    private static var osmfLoggerSetup:* = (Log.loggerFactory = new CommonsOsmfLoggerFactory());

    private var logger:ILogger = LoggerFactory.getClassLogger(PlayerInitialiser);

    public function PlayerInitialiser() {
        var request:ServiceRequestBase = new VideoPlayerInfoRequest("http://kgd-red-test-zxtm01.dev.vodco.co.uk", 19657);
        request.successCallback = onSuccess;
        request.failCallback = onFail;
        request.submit();
    }

    private function onSuccess(result:Object):void {
        logger.debug("validTransaction " + result.validTransaction);
        logger.debug("serverTimeStamp " + result.serverTimeStamp);
        logger.debug("stdResAssetId " + result.stdResAssetId);
        logger.debug("lowResUrl" + result.lowResUrl);
        logger.debug("partnerId " + result.partnerId);
        logger.debug("lowResAssetId " + result.lowResAssetId);
        logger.debug("logDRM " + result.logDRM);
        logger.debug("subtitleLocation " + result.subtitleLocation);
        logger.debug("stdResUrl " + result.stdResUrl);
        logger.debug("highResUrl " + result.highResUrl);
        logger.debug("offerType " + result.offerType);
        logger.debug("geoBlocked " + result.geoBlocked);
        logger.debug("grossUsageReached " + result.grossUsageReached);
        logger.debug("playlist " + result.playlist);
        logger.debug("anonymousUserId " + result.anonymousUserId);
        logger.debug("highResAssetId " + result.highResAssetId);
        logger.debug("transactionItemId " + result.transactionItemId);
    }

    private function onFail():void {

    }

}
}