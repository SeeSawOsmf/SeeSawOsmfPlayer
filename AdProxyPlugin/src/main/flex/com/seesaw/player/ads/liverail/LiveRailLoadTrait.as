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

package com.seesaw.player.ads.liverail {
import org.osmf.media.MediaResourceBase;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.LoaderBase;

public class LiveRailLoadTrait extends LoadTrait {

    private var _adManager:*;

    public function LiveRailLoadTrait(loader:LoaderBase, resource:MediaResourceBase) {
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
