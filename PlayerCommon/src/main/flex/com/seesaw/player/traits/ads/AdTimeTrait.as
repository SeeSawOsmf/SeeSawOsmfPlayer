/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
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
 * Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 */

package com.seesaw.player.traits.ads {
import flash.events.TimerEvent;
import flash.utils.Timer;

import org.osmf.traits.TimeTrait;

public class AdTimeTrait extends TimeTrait {

    private var counter:uint;

    public function AdTimeTrait(duration:Number = NaN) {
        super(duration);
        if (duration) {
            var timer:Timer = new Timer(1000, duration);
            timer.addEventListener(TimerEvent.TIMER, onTimerTick);
            timer.start();
        }
    }

    private function onTimerTick(event:TimerEvent):void {
        setCurrentTime(counter++);
    }
}
}