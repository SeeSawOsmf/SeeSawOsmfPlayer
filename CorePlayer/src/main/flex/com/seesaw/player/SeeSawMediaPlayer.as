package com.seesaw.player {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.events.PlayEvent;
import org.osmf.media.MediaPlayer;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayTrait;

public class SeeSawMediaPlayer extends MediaPlayer {

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawMediaContainer);

    public function SeeSawMediaPlayer() {
        logger.debug("created media player");


        addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
    }

    private function onPlayStateChange(event:PlayEvent):void {
        logger.debug("onPlayStateChange");
        var playable:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
        logger.debug("play trait: " + playable);
    }
}
}