package com.seesaw.player {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.containers.MediaContainer;

public class SeeSawMediaContainer extends MediaContainer {

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawMediaContainer);

    public function SeeSawMediaContainer() {
        logger.debug("created media container");
    }
}
}