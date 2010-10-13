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
package com.seesaw.proxyplugin {
import flash.system.Security;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;
import org.osmf.metadata.Metadata;

public class ProxyPlugin extends PluginInfo {
    private var logger:ILogger = LoggerFactory.getClassLogger(ProxyPlugin);

    /**
     * Constructor
     */
    public function ProxyPlugin() {
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
                            , MediaFactoryItemType.PROXY
                            );

            var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
            items.push(item);

            _pluginInfo = new PluginInfo(items, mediaElementCreationNotificationCallback);
        }

        return _pluginInfo;
    }

    // Internals
    //

    public static const ID:String = "com.seesaw.proxy";
    public static const NS_SETTINGS:String = "seesaw/proxy/settings";
    public static const NS_TARGET:String = "seesaw/proxy/target";

    private var _pluginInfo:PluginInfo;
    private var defaultElement:DefaultProxyElement;
    private var targetElement:MediaElement;


    private function canHandleResourceCallback(resource:MediaResourceBase):Boolean {
        var result:Boolean;

        if (resource != null) {
            var settings:Metadata
                    = resource.getMetadataValue(NS_SETTINGS) as Metadata;

            result = settings != null;
        }

        return result;
    }

    private function mediaElementCreationCallback():MediaElement {

        /* callback associated with every media Element */
        return null;

    }

    private function mediaElementCreationNotificationCallback(target:MediaElement):void {

        this.targetElement = target;
        defaultElement = new DefaultProxyElement();
        updateProxy();
    }

    private function updateProxy():void {
        if (defaultElement != null && targetElement != null && defaultElement != targetElement) {

            defaultElement.proxiedElement = targetElement;
        }
    }
}
}