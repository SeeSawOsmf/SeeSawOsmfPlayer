package com.seesaw.subtitle.parser {
import com.seesaw.player.captioning.sami.SAMIPluginInfo;

import flash.display.Sprite;

import org.hamcrest.assertThat;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.notNullValue;
import org.osmf.media.DefaultMediaFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.PluginInfoResource;
import org.osmf.media.URLResource;
import org.osmf.traits.LoadState;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;

public class SAMIPluginTest {

    private static const RESOURCE_URL = "http://kgd-blue-test-zxtm01.dev.vodco.co.uk/s/ccp/00000025/2540.smi";

    [Test]
    public function canLoadSAMI() {

    }
}
}