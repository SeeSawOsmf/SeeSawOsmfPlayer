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

package com.seesaw.player.ads.auditude {
import org.osmf.media.MediaResourceBase;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.LoaderBase;

public class AuditudeLoadTrait extends LoadTrait {

    private var _adManager:*;

    public function AuditudeLoadTrait(loader:LoaderBase, resource:MediaResourceBase) {
        super(loader, resource);
    }

    public function get adManager():* {
        return _adManager;
    }

    public function set adManager(value:*):void {
        _adManager = value;
    }
}
}
