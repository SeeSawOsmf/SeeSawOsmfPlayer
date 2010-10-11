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

package controls.seesaw.widget {
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

    public function Volume() {
        logger.debug("Volume constructor");
    }

    // Overrides
    //

    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function processRequiredTraitsAvailable(element:MediaElement):void {
        visible = true;
        audible = element.getTrait(MediaTraitType.AUDIO) as AudioTrait;
        if (audible) {
            audible.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
        }
        onVolumeChange();

    }

    override protected function processRequiredTraitsUnavailable(element:MediaElement):void {
        visible = false;
        if (audible) {
            audible.removeEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
            audible = null;
        }
    }

    override protected function onMouseClick(event:MouseEvent):void {
        if (audible.volume != 0) {
            storedVolume = audible.volume;
            audible.volume = Math.min(0, 0);
            enabled = false;
        } else {
            audible.volume = Math.min(1, storedVolume);
            trace(storedVolume)
            enabled = true;
        }
        super.processEnabledChange();
    }

    override protected function onMouseClick_internal(event:MouseEvent):void {
        onMouseClick(event);
    }

    // Internals
    //

    protected var audible:AudioTrait;
    private var storedVolume:Number;

    protected function onVolumeChange(event:AudioEvent = null):void {
        ///	enabled = audible ? audible.volume != 0 : false;
        if (audible.volume == 0) {
            enabled = false;
        } else {
            enabled = true;
        }

        super.processEnabledChange();


        //TODO external interface module needs to update the audio cookie
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }

    /* static */
    private static const QUALIFIED_NAME:String = "controls.seesaw.widget.Volume";
    private static const _requiredTraits:Vector.<String> = new Vector.<String>;
    _requiredTraits[0] = MediaTraitType.AUDIO;
}
}
