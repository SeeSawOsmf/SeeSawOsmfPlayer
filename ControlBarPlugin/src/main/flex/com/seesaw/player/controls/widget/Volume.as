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
import com.seesaw.player.PlayerConstants;
import com.seesaw.player.ui.PlayerToolTip;
import com.seesaw.player.utils.CookieHelper;

import controls.seesaw.widget.interfaces.IWidget;

import flash.events.Event;
import flash.events.MouseEvent;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.events.AudioEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.AudioTrait;
import org.osmf.traits.MediaTraitType;

public class Volume extends ButtonWidget implements IWidget {
    private var logger:ILogger = LoggerFactory.getClassLogger(Volume);

    private var toolTip:PlayerToolTip;

    [Embed(source="/volume.png")]
    private static const VOLUME_UP:Class;

    [Embed(source="/volumeOff.png")]
    private static const VOLUME_DISABLED:Class;

    /* static */
    private static const QUALIFIED_NAME:String = "com.seesaw.player.controls.widget.Volume";
    private static const _requiredTraits:Vector.<String> = new Vector.<String>;
    _requiredTraits[0] = MediaTraitType.AUDIO;

    private var cookie:CookieHelper;
    private var audible:AudioTrait;
    private var mutedVolume:Number;


    public function Volume() {
        cookie = new CookieHelper(PlayerConstants.PLAYER_VOLUME_COOKIE);
        this.toolTip = new PlayerToolTip(this, "Sound on");
        logger.debug("Volume - tooltip = Sound on");
        this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
    }

    private function onAddedToStage(event:Event) {
        stage.addChild(this.toolTip);
    }

    override public function set media(value:MediaElement):void {
        super.media = value;
    }

    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function processRequiredTraitsAvailable(element:MediaElement):void {
        visible = true;

        audible = element.getTrait(MediaTraitType.AUDIO) as AudioTrait;
        if (audible) {
            audible.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
            if (cookie.localSharedObject.data.volume == null)
                cookie.localSharedObject.data.volume = PlayerConstants.DEFAULT_VOLUME;

            audible.volume = cookie.localSharedObject.data.volume;
        }
    }

    override protected function onMediaElementTraitAdd(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.AUDIO) {
            audible = media.getTrait(MediaTraitType.AUDIO) as AudioTrait;
            if (audible) {
                audible.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
                if (cookie.localSharedObject.data.volume == null)
                    cookie.localSharedObject.data.volume = PlayerConstants.DEFAULT_VOLUME;

                audible.volume = cookie.localSharedObject.data.volume;
            }
        }
    }

    override protected function onMediaElementTraitRemove(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.AUDIO) {
            audible.removeEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
        }
    }

    override protected function processRequiredTraitsUnavailable(element:MediaElement):void {
        visible = false;
        if (audible) {
            audible.removeEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
            audible = null;
        }
        cookie.flush();
    }

    override protected function processMediaElementChange(oldMediaElement:MediaElement):void {
        if (oldMediaElement) {
            audible = media.getTrait(MediaTraitType.AUDIO) as AudioTrait;
            if (audible) {
                audible.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
                if (cookie.localSharedObject.data.volume == null)
                    cookie.localSharedObject.data.volume = PlayerConstants.DEFAULT_VOLUME;

                audible.volume = cookie.localSharedObject.data.volume;
            }
        }
    }

    override protected function onMouseClick(event:MouseEvent):void {
        toggleMuteState();
        super.processEnabledChange();
        super.onMouseOver();
    }

    private function toggleMuteState():void {
        logger.debug("toggleMuteState: " + audible.volume);
        if (audible.volume != 0) {
            mutedVolume = audible.volume;
            audible.volume = 0;
            cookie.localSharedObject.data.volume = audible.volume;
            enabled = false;
            logger.debug("toggleMuteState - tooltip = Sound on");
            this.toolTip.updateToolTip("Sound on");
        } else {
            audible.volume = mutedVolume;
            cookie.localSharedObject.data.volume = audible.volume;
            enabled = true;
            logger.debug("toggleMuteState - tooltip = Sound off");
            this.toolTip.updateToolTip("Sound off");
        }
    }

    override protected function onMouseClick_internal(event:MouseEvent):void {
        onMouseClick(event);
    }

    protected function onVolumeChange(event:AudioEvent = null):void {
        cookie.localSharedObject.data.volume = audible.volume;
        if (audible.volume < 0.05) {
            enabled = false;
            logger.debug("onVolumeChange - tooltip = Sound on");
            this.toolTip.updateToolTip("Sound on");
        } else {
            enabled = true;
            logger.debug("onVolumeChange - tooltip = Sound off");
            this.toolTip.updateToolTip("Sound off");
        }

        super.processEnabledChange();
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }
}
}
