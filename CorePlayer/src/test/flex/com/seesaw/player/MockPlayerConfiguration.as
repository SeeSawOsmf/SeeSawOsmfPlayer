package com.seesaw.player {
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaResourceBase;

public class MockPlayerConfiguration extends PlayerConfiguration {

    public function MockPlayerConfiguration(playerWidth:int, playerHeight:int, mediaResource:MediaResourceBase) {
        super(playerWidth, playerHeight, mediaResource);
    }


    override protected function constructFactory():MediaFactory {
        return new MockMediaFactory();
    }
}
}