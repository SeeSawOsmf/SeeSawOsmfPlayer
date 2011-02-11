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
 * Date: 28/01/11
 * Time: 16:07
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.smil {
import org.osmf.elements.ProxyElement;
import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitType;

public class StingCapabilitiesProxy extends ProxyElement {

    public function StingCapabilitiesProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);
        var traitsToBlock:Vector.<String> = new Vector.<String>();
        traitsToBlock[0] = MediaTraitType.TIME;
        traitsToBlock[1] = MediaTraitType.SEEK;
        blockedTraits = traitsToBlock;
    }
}
}
