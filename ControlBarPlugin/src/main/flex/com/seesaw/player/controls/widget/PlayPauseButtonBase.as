package com.seesaw.player.controls.widget {
import com.seesaw.player.controls.ControlBarMetadata;

import flash.events.Event;
import flash.external.ExternalInterface;

import org.osmf.events.MediaElementEvent;
import org.osmf.events.PlayEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;

public class PlayPauseButtonBase extends ButtonWidget {

    private var _requiredTraits:Vector.<String> = new Vector.<String>;

    private var metadata:Metadata;

    override public function set media(value:MediaElement):void {

        super.media = value;

        if (media) {
            metadata = media.getMetadata(ControlBarMetadata.CONTROL_BAR_METADATA);
            if (metadata == null) {
                metadata = new Metadata();
                media.addMetadata(ControlBarMetadata.CONTROL_BAR_METADATA, metadata);
            }
        }
    }

    public function PlayPauseButtonBase() {
        _requiredTraits[0] = MediaTraitType.PLAY;
        this.setupExternalInterface();
    }

    private function setupExternalInterface():void {
        if (ExternalInterface.available) {
            ExternalInterface.addCallback("playPause", this.playPause);
        }
    }

    private function playPause():void {
        if (playTrait.playState == PlayState.PLAYING) {
            playTrait.pause();
        }
        else {
            playTrait.play();
        }
    }

    public function updateMetadata():void {
        metadata.addValue(ControlBarMetadata.USER_CLICK_STATE, playTrait.playState);
    }

    override protected function get requiredTraits():Vector.<String> {
        return _requiredTraits;
    }

    override protected function onMediaElementTraitAdd(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.PLAY) {
            var trait:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
            trait.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
            trait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
        }
        updateVisibility();
    }

    override protected function onMediaElementTraitRemove(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.PLAY) {
            var trait:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
            trait.removeEventListener(PlayEvent.CAN_PAUSE_CHANGE, visibilityDeterminingEventHandler);
            trait.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, visibilityDeterminingEventHandler);
        }
        updateVisibility();
    }

    override protected function processRequiredTraitsAvailable(element:MediaElement):void {
        updateVisibility();
    }

    override protected function processRequiredTraitsUnavailable(element:MediaElement):void {
        updateVisibility();
    }

    protected function visibilityDeterminingEventHandler(event:Event = null):void {
        updateVisibility();
    }

    /**
     * Override this in a base class.
     */
    protected function updateVisibility():void {
        visible = false;
    }

    protected function get paused():Boolean {
        return playTrait && playTrait.playState == PlayState.PAUSED;
    }

    protected function get playing():Boolean {
        return playTrait && playTrait.playState == PlayState.PLAYING;
    }

    public function get playTrait():PlayTrait {
        return media.getTrait(MediaTraitType.PLAY) as PlayTrait;
    }
}
}