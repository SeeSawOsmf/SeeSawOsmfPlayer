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

package com.seesaw.player.ads {
import flash.geom.Rectangle;

import org.osmf.layout.LayoutTargetSprite;

public class LiverailDisplayObject extends LayoutTargetSprite {

    private var _adManager:*;

    public function LiverailDisplayObject(adManager:* = null) {
        _adManager = adManager;
    }

    override public function layout(availableWidth:Number, availableHeight:Number, deep:Boolean = true):void {
        super.layout(availableWidth, availableHeight, deep);
        if (_adManager) {
            _adManager.setSize(new Rectangle(0, 0, availableWidth, availableHeight));
        }
    }

    public function get adManager():* {
        return _adManager;
    }

    public function set adManager(value:*):void {
        _adManager = value;
        if (_adManager) {
            addChild(_adManager);
        }
    }
}
}