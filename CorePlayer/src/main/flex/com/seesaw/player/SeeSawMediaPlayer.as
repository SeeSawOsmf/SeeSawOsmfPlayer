package com.seesaw.player {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.events.MediaErrorEvent;
import org.osmf.media.MediaPlayer;

public class SeeSawMediaPlayer extends MediaPlayer {

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawMediaContainer);

    public function SeeSawMediaPlayer() {
        addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError)
    }

    private function onMediaError(event:MediaErrorEvent):void {
        logger.error("media error: " + event);
    }
}
}