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
package com.seesaw.player.controls {
import flash.display.Sprite;
import flash.system.Security;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;
import org.osmf.metadata.Metadata;

public class ControlBarPlugin extends Sprite {
    private var logger:ILogger = LoggerFactory.getClassLogger(ControlBarPlugin);

    /**
     * Constructor
     */
    public function ControlBarPlugin() {
        // Allow any SWF that loads this SWF to access objects and
        // variables in this SWF.
        Security.allowDomain("*");

        super();
    }

    /**
     * Gives the player the PluginInfo.
     */
    public function get pluginInfo():PluginInfo {
        if (_pluginInfo == null) {
            var item:MediaFactoryItem
                    = new MediaFactoryItem
                    (ID
                            , canHandleResourceCallback
                            , mediaElementCreationCallback
                            );

            var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
            items.push(item);

            _pluginInfo = new PluginInfo(items);
        }

        return _pluginInfo;
    }

    // Internals
    //

    public static const ID:String = "com.seesaw.player.controls.ControlBarPlugin";

    private var _pluginInfo:PluginInfo;

    private function canHandleResourceCallback(resource:MediaResourceBase):Boolean {
        var result:Boolean;

        if (resource != null) {
            var settings:Metadata = resource.getMetadataValue(ControlBarConstants.CONTROL_BAR_SETTINGS) as Metadata;

            result = settings != null;
        }

        if (result) {
            logger.debug("handling resource: {0}", resource);
        }

        return result;
    }

    private function mediaElementCreationCallback():MediaElement {
        return new ControlBarElement();
    }
}
}
