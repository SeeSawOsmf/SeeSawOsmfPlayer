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
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;

public class DefaultProxyPluginInfo extends PluginInfo {

    private static var logger:ILogger = LoggerFactory.getClassLogger(DefaultProxyPluginInfo);

    public static const ID:String = "com.seesaw.proxyplugin.DefaultProxyPlugin";

    public function DefaultProxyPluginInfo() {
        logger.debug("DefaultProxyPluginInfo()");

        var item:MediaFactoryItem = new MediaFactoryItem(
                ID,
                canHandleResourceFunction,
                mediaElementCreationFunction,
                MediaFactoryItemType.PROXY);

        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
        items.push(item);

        super(items);
    }

    private static function canHandleResourceFunction(resource:MediaResourceBase):Boolean {
        logger.debug("can handle this resource: " + resource);
        return true;
    }

    private static function mediaElementCreationFunction():MediaElement {
        logger.debug("constructing proxy element");
        return new DefaultProxyElement();
    }
}
}