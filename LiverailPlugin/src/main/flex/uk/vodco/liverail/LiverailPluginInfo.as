/*
 * * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *  *
 *  *   The contents of this file are subject to the Mozilla Public License
 *  *   Version 1.1 (the "License"); you may not use this file except in
 *  *   compliance with the License. You may obtain a copy of the License at
 *  *   http://www.mozilla.org/MPL/
 *  *
 *  *   Software distributed under the License is distributed on an "AS IS"
 *  *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *  *   License for the specific language governing rights and limitations
 *  *   under the License.
 *  *
 *  *
 *  *   The Initial Developer of the Original Code is ioko365 Ltd.
 *  *   Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *  *   Incorporated. All Rights Reserved.
 */

package uk.vodco.liverail {
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactoryItem;
import org.osmf.media.MediaFactoryItemType;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfo;

public class LiverailPluginInfo extends PluginInfo {
    public function LiverailPluginInfo() {
        var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
        items.push(mediaFactoryItem);

        super(items, mediaElementCreationNotificationFunction);
    }

    public static function get mediaFactoryItem():MediaFactoryItem {
        return _mediaFactoryItem;
    }

    private static function canHandleResourceFunction(resource:MediaResourceBase):Boolean {
        return true;
    }

    private static function mediaElementCreationFunction():MediaElement {

        return new LiverailElement();
    }

    private static var _mediaFactoryItem:MediaFactoryItem
            = new MediaFactoryItem
            (ID
                    , canHandleResourceFunction
                    , mediaElementCreationFunction
                    , MediaFactoryItemType.PROXY
                    );

    public static const ID:String = "uk.vodco.liverail.LiverailPluginInfo";
    public static const NS_SETTINGS:String = "http://www.seesaw.com/liverail/settings";
    public static const NS_TARGET:String = "http://www.seesaw.com/liverail/target";

}
}