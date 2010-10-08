package com.seesaw.player.components {
import org.osmf.events.MediaFactoryEvent;

public interface ComponentLifecycle {
    function pluginLoaded(event:MediaFactoryEvent):void;

    function pluginLoadError(event:MediaFactoryEvent):void;
}
}