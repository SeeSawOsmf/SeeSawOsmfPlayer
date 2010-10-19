package com.seesaw.player.fullscreen {
import com.seesaw.player.traits.FullScreenTrait;

import flash.display.Sprite;

import org.flexunit.asserts.assertNotNull;
import org.flexunit.asserts.assertTrue;
import org.osmf.media.DefaultMediaFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfoResource;

public class FullScreenProxyElementTest extends Sprite {

    [Test]
    public function testFullScreenTraitAvailable():void {
        var factory:MediaFactory = new DefaultMediaFactory();
        factory.loadPlugin(new PluginInfoResource(new MockMediaPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new FullScreenProxyPluginInfo()));

        var resource:MediaResourceBase = new MediaResourceBase();
        var element:MediaElement = factory.createMediaElement(resource);
        assertNotNull(element);

        assertTrue(element.hasTrait(FullScreenTrait.FULL_SCREEN));
    }
}
}