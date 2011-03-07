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
 * Date: 07/03/11
 * Time: 09:13
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.utils {
import flash.utils.getQualifiedClassName;

import org.as3commons.logging.ILogger;
import org.osmf.elements.CompositeElement;
import org.osmf.elements.ProxyElement;
import org.osmf.events.LoadEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.LoadState;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;

public class LoggerUtils {

    public static function logWhenLoaded(logger:ILogger, mediaElement:MediaElement):void {
        var loadTrait:LoadTrait = mediaElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
        if (loadTrait) {
            if (loadTrait.loadState == LoadState.READY) {
                logger.debug("media loaded: {0} ", elementToString(mediaElement));
            }
            else {
                function onLoadChange(event:LoadEvent):void {
                    loadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadChange);
                    logger.debug("media loaded: {0} ", elementToString(mediaElement));
                }

                loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadChange);
            }
        }
    }

    public static function elementToString(element:MediaElement):String {
        if (!element) return "?";
        var message:String = getQualifiedClassName(element);
        if (element is ProxyElement) {
            message += "(Proxy) -> " + elementToString(ProxyElement(element).proxiedElement);
        }
        else if (element is CompositeElement) {
            var compositeElement:CompositeElement = CompositeElement(element);
            message += " [";
            for (var i:uint = 0; i < compositeElement.numChildren; i++) {
                var child:MediaElement = compositeElement.getChildAt(i);
                message += i + ": " + elementToString(child);
                if (i < compositeElement.numChildren - 1) message += ", ";
            }
            message += "]";
        }
        return message;
    }

    public function LoggerUtils() {
        throw new Error("Instantiable");
    }
}
}
