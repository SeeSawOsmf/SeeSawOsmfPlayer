package com.seesaw.player.components {
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.PluginInfoResource;

public interface MediaComponent {
    function get info():PluginInfoResource;
    function createMediaElement(factory:MediaFactory, target:MediaElement):MediaElement;
}
}