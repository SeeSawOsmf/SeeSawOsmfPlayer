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
 * Date: 11/02/11
 * Time: 08:36
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.smil {
import flash.events.Event;

import org.osmf.media.MediaElement;

public class SMILParserEvent extends Event {

    public static const MEDIA_ELEMENT_CREATED:String = "mediaElementCreated";

    private var _mediaElement:MediaElement;

    private var _elementType:String;

    private var _contentType:String;

    public function SMILParserEvent(type:String, mediaElement:MediaElement, elementType:String, contentType:String = null) {
        super(type, false, false);
        _mediaElement = mediaElement;
        _elementType = elementType;
        _contentType = contentType;
    }

    public function get mediaElement():MediaElement {
        return _mediaElement;
    }

    public function get elementType():String {
        return _elementType;
    }

    public function get contentType():String {
        return _contentType;
    }
}
}
