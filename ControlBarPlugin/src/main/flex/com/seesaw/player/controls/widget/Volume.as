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

package com.seesaw.player.controls.widget {
import com.seesaw.player.utils.CookieHelper;

import controls.seesaw.widget.interfaces.IWidget;

import flash.events.MouseEvent;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.events.AudioEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.AudioTrait;
import org.osmf.traits.MediaTraitType;

public class Volume extends ButtonWidget implements IWidget {
    private var logger:ILogger = LoggerFactory.getClassLogger(Volume);

    public static const PLAYER_VOLUME_COOKIE:String = "seesaw.player.volume";

    /* static */
    private static const QUALIFIED_NAME:String = "com.seesaw.player.controls.widget.Volume";
    private static const _requiredTraits:Vector.<String> = new Vector.<String>;
    _requiredTraits[0] = MediaTraitType.AUDIO;

    private var cookie:CookieHelper;
    private var audible:AudioTrait;

    public function Volume() {
        cookie = new CookieHelper(PLAYER_VOLUME_COOKIE);
    }

    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function processRequiredTraitsAvailable(element:MediaElement):void {
        visible = true;
        audible = element.getTrait(MediaTraitType.AUDIO) as AudioTrait;
        audible.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
        audible.volume = cookie.localSharedObject.data.volume;
    }

    override protected function processRequiredTraitsUnavailable(element:MediaElement):void {
        visible = false;
        if (audible) {
            audible.removeEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
            audible = null;
        }
        cookie.flush();
    }

    override protected function onMouseClick(event:MouseEvent):void {
        toggleMuteState();
        super.processEnabledChange();
    }

    private function toggleMuteState():void {
        logger.debug("toggleMuteState: " + audible.volume);
        if (audible.volume != 0) {
            cookie.localSharedObject.data.volume = audible.volume;
            audible.volume = 0;
            enabled = false;
        } else {
            audible.volume = cookie.localSharedObject.data.volume;
            enabled = true;
        }
    }

    override protected function onMouseClick_internal(event:MouseEvent):void {
        onMouseClick(event);
    }

    protected function onVolumeChange(event:AudioEvent = null):void {
        cookie.localSharedObject.data.volume = audible.volume;
        if (audible.volume < 0.05) {
            enabled = false;
        } else {
            enabled = true;
        }

        super.processEnabledChange();
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }
}
}
