/*****************************************************
 *
 *  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 *****************************************************
 *  The contents of this file are subject to the Mozilla Public License
 *  Version 1.1 (the "License"); you may not use this file except in
 *  compliance with the License. You may obtain a copy of the License at
 *  http://www.mozilla.org/MPL/
 *
 *  Software distributed under the License is distributed on an "AS IS"
 *  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *  License for the specific language governing rights and limitations
 *  under the License.
 *
 *
 *  The Initial Developer of the Original Code is Adobe Systems Incorporated.
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 *  Incorporated. All Rights Reserved.
 *
 *****************************************************/
package com.seesaw.player.traits {
import com.seesaw.player.events.FullScreenEvent;

import org.osmf.traits.MediaTraitBase;

[Event(name="fullscreenChange", type="com.seesaw.player.events.FullScreenEvent")]

public class FullScreenTrait extends MediaTraitBase {

    private var _fullscreen:Boolean;

    public static const FULL_SCREEN:String = "fullscreen";

    public function FullScreenTrait() {
        super(FULL_SCREEN);
    }

    public function get fullscreen():Boolean {
        return _fullscreen;
    }

    public function set fullscreen(value:Boolean):void {
        _fullscreen = value;
        dispatchEvent(new FullScreenEvent(value));
    }
}
}