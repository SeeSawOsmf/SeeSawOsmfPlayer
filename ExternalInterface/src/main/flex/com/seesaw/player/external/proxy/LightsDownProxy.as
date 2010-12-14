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

package com.seesaw.player.external.proxy {
import com.seesaw.player.external.*;

import com.seesaw.player.ioc.ObjectProvider;

import flash.external.ExternalInterface;

import org.osmf.events.PlayEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.TimeTrait;

public class LightsDownProxy extends ExternalInterfaceProxyBase {

    private var lightsDown:Boolean = false;
    private var xi:PlayerExternalInterface;

    public function LightsDownProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);
        xi = ObjectProvider.getInstance().getObject(PlayerExternalInterface);
    }

    protected override function updateTraitListeners(element:MediaElement, traitType:String, add:Boolean):void {
        switch (traitType) {
            case MediaTraitType.PLAY:
                changeListeners(element, add, traitType, PlayEvent.PLAY_STATE_CHANGE, onPlayStateChanged);
                break;
        }
    }

    private function onPlayStateChanged(event:PlayEvent):void {
        var timeTrait:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;
        if (event.playState == PlayState.PLAYING && !this.lightsDown) {
            if (xi.available) {
                xi.callLightsDown();
                this.lightsDown = true;
            }
        }
        if (event.playState == PlayState.PAUSED && (timeTrait.currentTime != timeTrait.duration)) {
            if (ExternalInterface.available) {
                xi.callLightsUp();
                this.lightsDown = false;
            }
        }
    }
}
}