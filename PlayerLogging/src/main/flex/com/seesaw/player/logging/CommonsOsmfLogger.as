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


package com.seesaw.player.logging {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.logging.Logger;

/**
 * An OSMF logger that feeds to commons logging
 */
public class CommonsOsmfLogger extends Logger {

    private var logger:ILogger;

    public function CommonsOsmfLogger(name:String) {
        super(name);
        logger = LoggerFactory.getLogger(name);
    }

    override public function debug(message:String, ...rest):void {
        logger.debug(message, rest);
    }

    override public function info(message:String, ...rest):void {
        logger.info(message, rest);
    }

    override public function warn(message:String, ...rest):void {
        logger.warn(message, rest);
    }

    override public function error(message:String, ...rest):void {
        logger.error(message, rest);
    }

    override public function fatal(message:String, ...rest):void {
        logger.fatal(message, rest);
    }
}

}
