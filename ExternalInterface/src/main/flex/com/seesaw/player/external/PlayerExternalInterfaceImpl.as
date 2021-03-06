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
        call(ExternalInterfaceConstants.LIGHTS_UP);
    }

    public function callSWFInit():void {
        call(ExternalInterfaceConstants.SET_SWF_INIT, true);
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

    public function addGetEntitlementCallback(callback:Function):void {
        addCallback(ExternalInterfaceConstants.GET_ENTITLEMENT, callback);
    }

    public function addHideDogCallback(callback:Function):void {
        addCallback(ExternalInterfaceConstants.SHOW_DOG, callback);
    }

    public function addShowDogCallback(callback:Function):void {
        addCallback(ExternalInterfaceConstants.HIDE_DOG, callback);
    }

    public function addSetPlaylistCallback(callback:Function):void {
        addCallback(ExternalInterfaceConstants.SET_PLAYLIST, callback);
    }

    private function addCallback(name:String, callback:Function):void {
        if (available) {
            logger.debug("adding callback {0}", name);
            ExternalInterface.addCallback(name, callback);
        }
    }

    public function baynoteVideoTrack():void {
        call(ExternalInterfaceConstants.BAYNOTE_VIDEO_TRACKER);
    }

    private function call(...args) {
        if (available) {
            logger.debug("calling {0}", args[0].toString());
            ExternalInterface.call.apply(null, args);
        }
    }

    public function reload():void {
        call(ExternalInterfaceConstants.RELOAD);
    }
}
}
