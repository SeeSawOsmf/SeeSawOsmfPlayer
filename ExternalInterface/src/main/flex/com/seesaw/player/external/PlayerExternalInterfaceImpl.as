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

package com.seesaw.player.external {
import flash.external.ExternalInterface;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;

public class PlayerExternalInterfaceImpl implements PlayerExternalInterface {

    private var logger:ILogger = LoggerFactory.getClassLogger(PlayerExternalInterfaceImpl);

    public function get available():Boolean {
        return ExternalInterface.available;
    }

    public function callLightsDown():void {
        call(ExternalInterfaceConstants.LIGHTS_DOWN);
    }

    public function callLightsUp():void {
        call(ExternalInterfaceConstants.LIGHTS_DOWN);
    }

    public function addGetGuidanceCallback(callback:Function):void {
        addCallback(ExternalInterfaceConstants.GET_GUIDANCE, callback);
    }

    public function addGetCurrentItemTitleCallback(callback:Function):void {
        addCallback(ExternalInterfaceConstants.GET_CURRENT_ITEM_TITLE, callback);
    }

    public function addGetCurrentItemDurationCallback(callback:Function):void {
        addCallback(ExternalInterfaceConstants.GET_CURRENT_ITEM_DURATION, callback);
    }

    public function addHideDogCallback(callback:Function):void {
        addCallback(ExternalInterfaceConstants.SHOW_DOG, callback);
    }

    public function addShowDogCallback(callback:Function):void {
        addCallback(ExternalInterfaceConstants.HIDE_DOG, callback);
    }

    private function addCallback(name:String, callback:Function):void {
        if (available) {
            logger.debug("adding callback {0}", name);
            ExternalInterface.addCallback(name, callback);
        }
    }

    private function call(name:String) {
        if (available) {
            logger.debug("calling {0}", name);
            ExternalInterface.call(name);
        }
    }
}
}