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
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.external.PlayerExternalInterface;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.ui.PlayerToolTip;
import com.seesaw.player.ui.StyledTextField;

import controls.seesaw.widget.interfaces.IWidget;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.text.TextField;
import flash.text.TextFormat;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.chrome.widgets.ButtonWidget;
import org.osmf.events.MetadataEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayTrait;

public class AdInfoLink extends ButtonWidget implements IWidget {

    private var logger:ILogger = LoggerFactory.getClassLogger(AdInfoLink);

    private var xi:PlayerExternalInterface;

    private const DEFAULT_CAPTION:String = "Click for more information";

    private var adInfoLabel:TextField;

    private var toolTip:PlayerToolTip;

    private var interactiveAdvertisingUrl:String;
    private var interactiveAdvertisingCaption:String;

    /* static */
    private static const QUALIFIED_NAME:String = "com.seesaw.player.controls.widget.AdInfoLink";

    private static const _requiredTraits:Vector.<String> = new Vector.<String>;
    _requiredTraits[0] = MediaTraitType.PLAY;

    public function AdInfoLink() {

        //SET THE STRING BELOW TO THE INTERACTIVE AD CAPTION...
        this.interactiveAdvertisingCaption = null;

        adInfoLabel = new StyledTextField();

        var linkCaption:String;

        if (interactiveAdvertisingCaption) {
            linkCaption = interactiveAdvertisingCaption;
        } else {
            linkCaption = DEFAULT_CAPTION;
        }

        adInfoLabel.text = linkCaption;

        xi = ObjectProvider.getInstance().getObject(PlayerExternalInterface);
        logger.debug("XI IS: " + xi.available);

        this.toolTip = new PlayerToolTip(this, linkCaption);
        this.formatLabelFont();

        this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);

        this.visible = false;

        this.useHandCursor = true;
        this.mouseChildren = false;
        this.buttonMode = true;

        addChild(adInfoLabel);
    }

    override protected function processRequiredTraitsAvailable(element:MediaElement):void {
        updateFromAdMetadata();
    }

    override protected function processMediaElementChange(oldMediaElement:MediaElement):void {
        if (oldMediaElement) {
            oldMediaElement.removeEventListener(MetadataEvent.VALUE_ADD, onAdInfoMetadataChange);
            oldMediaElement.removeEventListener(MetadataEvent.VALUE_CHANGE, onAdInfoMetadataChange);
            oldMediaElement.removeEventListener(MetadataEvent.VALUE_REMOVE, onAdInfoMetadataChange);
        }
        media.metadata.addEventListener(MetadataEvent.VALUE_ADD, onAdInfoMetadataChange);
        media.metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onAdInfoMetadataChange);
        media.metadata.addEventListener(MetadataEvent.VALUE_REMOVE, onAdInfoMetadataChange);
        updateFromAdMetadata();
    }

    private function onAdInfoMetadataChange(event:MetadataEvent) {
        if (event.key == AdMetadata.AD_NAMESPACE) {
            updateFromAdMetadata();
        }
    }

    private function updateFromAdMetadata():void {
        var adMetadata:AdMetadata = media.getMetadata(AdMetadata.AD_NAMESPACE) as AdMetadata;
        if (adMetadata) {
            interactiveAdvertisingUrl = adMetadata.clickThru;
            if(interactiveAdvertisingUrl) {
                visible = true;
                logger.debug("set url: {0}", interactiveAdvertisingUrl);
            }
        }
        else {
            visible = false;
        }
    }

    override protected function onMouseClick(event:MouseEvent):void {
        var request:URLRequest = new URLRequest(this.interactiveAdvertisingUrl);
        try {
            navigateToURL(request);
            pause();
        } catch (e:Error) {
            trace("Error occurred!");
        }
    }

    private function pause():void {
        var playTrait:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playTrait) {
            playTrait.pause();
        }
    }

    private function onAddedToStage(event:Event) {
        stage.addChild(this.toolTip);
    }

    private function formatLabelFont():void {
        var textFormat:TextFormat = new TextFormat();
        textFormat.size = 11;
        textFormat.color = 0x999999;
        textFormat.align = "left";
        this.adInfoLabel.setTextFormat(textFormat);
    }

    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    public function get classDefinition():String {
        return QUALIFIED_NAME;
    }
}
}