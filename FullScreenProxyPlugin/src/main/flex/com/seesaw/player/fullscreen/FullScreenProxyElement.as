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
package com.seesaw.player.fullscreen {
import com.seesaw.player.traits.FullScreenTrait;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.media.MediaElement;

public class FullScreenProxyElement extends ProxyElement {

    private var logger:ILogger = LoggerFactory.getClassLogger(FullScreenProxyElement);
    public static const ID:String = "com.seesaw.player.traitAdded";

    public function FullScreenProxyElement(proxiedElement:MediaElement = null) {

        super(proxiedElement);
    }

    override protected function setupTraits():void {
        logger.debug("setupTraits");
        addTrait(FullScreenTrait.FULL_SCREEN, new FullScreenTrait());
        super.setupTraits();
    }

}
}