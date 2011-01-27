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
 * Date: 27/01/11
 * Time: 13:37
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.smil {
import org.osmf.elements.ProxyElement;
import org.osmf.media.MediaElement;
import org.osmf.net.ModifiableTimeTrait;
import org.osmf.traits.MediaTraitType;

public class SMILAdHandlerProxy extends ProxyElement {

    private var timeTrait:ModifiableTimeTrait;

    public function SMILAdHandlerProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);
        setTraitsToBlock(MediaTraitType.TIME, MediaTraitType.SEEK);
    }

    override public function set proxiedElement(value:MediaElement):void {
        if (value) {
            super.proxiedElement = value;
        }
    }


    private function setTraitsToBlock(...traitTypes):void {
        var traitsToBlock:Vector.<String> = new Vector.<String>();
        for (var i:int = 0; i < traitTypes.length; i++) {
            traitsToBlock[i] = traitTypes[i];
        }
        blockedTraits = traitsToBlock;
    }
}
}
