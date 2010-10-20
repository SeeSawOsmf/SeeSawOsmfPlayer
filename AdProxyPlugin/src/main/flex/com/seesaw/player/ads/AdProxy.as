package com.seesaw.player.ads {
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.Timer;

import org.osmf.elements.ProxyElement;
import org.osmf.events.DisplayObjectEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.DisplayObjectTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.TimeTrait;

public class AdProxy extends ProxyElement {

    public function AdProxy(proxiedElement:MediaElement = null) {
        super(proxiedElement);

        displayObject = new Sprite();

        var format:TextFormat = new TextFormat("Verdana", 16, 0xffffff);
        format.align = TextFormatAlign.CENTER;
        format.font = "Verdana";

        label = new TextField();
        label.defaultTextFormat = format;

        displayObject.addChild(label);
        outerViewable = new AdProxyDisplayObjectTrait(displayObject);

        var traitsToBlock:Vector.<String> = new Vector.<String>();
        traitsToBlock[0] = MediaTraitType.SEEK;
        traitsToBlock[1] = MediaTraitType.TIME;

        blockedTraits = traitsToBlock;

        var timer:Timer = new Timer(5000);
        timer.addEventListener(TimerEvent.TIMER, onTimerTick);
        timer.start();
    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            super.proxiedElement = proxiedElement;
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onProxiedTraitsChange);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onProxiedTraitsChange);
        }
    }

    private function onProxiedTraitsChange(event:MediaElementEvent):void {
        if (event.type == MediaElementEvent.TRAIT_ADD) {
            if (event.traitType == MediaTraitType.DISPLAY_OBJECT) {
                innerViewable = DisplayObjectTrait(proxiedElement.getTrait(event.traitType));
                if (_innerViewable) {
                    addTrait(MediaTraitType.DISPLAY_OBJECT, outerViewable);
                }
            }
        }
        else {
            if (event.traitType == MediaTraitType.DISPLAY_OBJECT) {
                innerViewable = null;
                removeTrait(MediaTraitType.DISPLAY_OBJECT);
            }
        }
    }

    private function set innerViewable(value:DisplayObjectTrait):void {
        if (_innerViewable != value) {
            if (_innerViewable) {
                _innerViewable.removeEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onInnerDisplayObjectChange);
                _innerViewable.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onInnerMediaSizeChange);
            }

            _innerViewable = value;

            if (_innerViewable) {
                _innerViewable.addEventListener(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, onInnerDisplayObjectChange);
                _innerViewable.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onInnerMediaSizeChange);
            }

            updateView();
        }
    }

    private function onInnerDisplayObjectChange(event:DisplayObjectEvent):void {
        updateView();
    }

    private function onInnerMediaSizeChange(event:DisplayObjectEvent):void {
        outerViewable.setSize(event.newWidth, event.newHeight);

        label.width = event.newWidth;
    }

    private function updateView():void {
        if (_innerViewable == null
                || _innerViewable.displayObject == null
                || displayObject.contains(_innerViewable.displayObject) == false
                ) {
            if (displayObject.numChildren == 2) {
                displayObject.removeChildAt(0);
            }
            label.visible = false;
        }

        if (_innerViewable != null
                && _innerViewable.displayObject != null
                && displayObject.contains(_innerViewable.displayObject) == false
                ) {
            displayObject.addChildAt(_innerViewable.displayObject, 0);
            label.visible = true;
        }

    }

    private function onTimerTick(event:TimerEvent):void {
        var labelText:String = "";
        if (proxiedElement != null) {
            var timeTrait:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;
            var playTrait:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;

             if(playTrait) {
                if(playTrait.playState == PlayState.PLAYING) {
                    playTrait.pause();
                    labelText = "[ Advertisement ]";
                }
                else if(playTrait.playState == PlayState.PAUSED)  {
                    playTrait.play();
                    labelText = "";
                }
            }
        }
        label.text = labelText;
    }

    private var _innerViewable:DisplayObjectTrait;
    private var outerViewable:AdProxyDisplayObjectTrait;
    private var displayObject:Sprite;
    private var label:TextField;
}
}