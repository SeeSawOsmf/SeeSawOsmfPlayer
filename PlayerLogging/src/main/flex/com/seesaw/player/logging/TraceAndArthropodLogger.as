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

package com.seesaw.player.logging {
import com.carlcalderon.arthropod.Debug;

import org.as3commons.logging.LogLevel;
import org.as3commons.logging.impl.AbstractLogger;
import org.as3commons.logging.util.MessageUtil;

/**
 * A commons logging logger that traces and feeds to Arthopod
 */
public class TraceAndArthropodLogger extends AbstractLogger {

    private var _level:int;
    private var _colour:uint = 0xFFFFFF;

    public function TraceAndArthropodLogger(name:String) {
        super(name);

        var colours:Vector.<ColourMap> = new Vector.<ColourMap>;

        colours.push(new ColourMap("uk.vodco.liverail", Debug.RED));


        for each (var map:ColourMap in colours) {
            if (name.search(map.category) == 0) {
                _colour = map.colour;
            }
        }

    }

    public function set level(value:int):void {
        _level = value;
    }

    override protected function log(level:uint, message:String, params:Array):void {
        if (level >= this._level) {
            //var message:String = "";

            var msg:String = "";

            // add datetime
            msg += (new Date()).toString() + " " + LogLevel.toString(level) + " - ";

            // add name and params
            msg += name + " - " + MessageUtil.toString(message, params);

            // trace the message
            trace(msg);

            // And to Arthorpod
            var logColour:uint
            if (!_colour) {
                switch (level) {
                    case LogLevel.ERROR:
                        logColour = 0xCC0000;
                        break;

                    case LogLevel.WARN:
                        logColour = 0xCCCC00;
                        break;

                    default:
                        logColour = 0xFEFEFE;
                }
            } else {
                logColour = _colour;
            }


            switch (level) {
                case LogLevel.ERROR:
                    Debug.log(msg, logColour);
                    break;

                case LogLevel.WARN:
                    Debug.log(msg, logColour);
                    break;

                default:
                    Debug.log(msg, logColour);
            }
        }
    }

    /**
     * @inheritDoc
     */
    override public function get debugEnabled():Boolean {
        return (_level <= LogLevel.DEBUG);
    }

    /**
     * @inheritDoc
     */
    override public function get infoEnabled():Boolean {
        return (_level <= LogLevel.INFO);
    }

    /**
     * @inheritDoc
     */
    override public function get warnEnabled():Boolean {
        return (_level <= LogLevel.WARN);
    }

    /**
     * @inheritDoc
     */
    override public function get errorEnabled():Boolean {
        return (_level <= LogLevel.ERROR);
    }

    /**
     * @inheritDoc
     */
    override public function get fatalEnabled():Boolean {
        return (_level <= LogLevel.FATAL);
    }
}

}
