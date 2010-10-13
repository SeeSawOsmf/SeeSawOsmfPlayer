package com.seesaw.player {
import flash.events.Event;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.containers.MediaContainer;

public class SeeSawMediaContainer extends MediaContainer {

    private var logger:ILogger = LoggerFactory.getClassLogger(SeeSawMediaContainer);

    public function SeeSawMediaContainer() {
        logger.debug("created media container");
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Event):void {
        logger.debug("added to stage");
        stage.addEventListener(Event.RESIZE, onStageResize);
    }

    private function onStageResize(event:Event = null):void {
        logger.debug("onStageResize: " + event);
        width = stage.stageWidth;
        height = stage.stageHeight;
    }
}
}