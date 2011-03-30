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

        colours.push(new ColourMap("com.seesaw.player.ads", 0x07ff13));
        colours.push(new ColourMap("uk.co.vodco.osmfDebugProxy", 0xfdb3f7));
        colours.push(new ColourMap("com.seesaw.player.control", 0xfffc00));
        colours.push(new ColourMap("com.seesaw.player.scrubPrevention", 0xadf8ff));
        colours.push(new ColourMap("com.seesaw.player.autoresume", 0xff0000));
        colours.push(new ColourMap("com.seesaw.player.batcheventservices.events.manager", 0x00eaff));
        colours.push(new ColourMap("com.seesaw.player.batcheventservices.services", 0x8ef6ff));

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
