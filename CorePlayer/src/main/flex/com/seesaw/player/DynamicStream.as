package com.seesaw.player {
import org.osmf.net.DynamicStreamingItem;
import org.osmf.net.DynamicStreamingResource;

public class DynamicStream {

    private var dynResource:DynamicStreamingResource;

    public function DynamicStream() {

        dynResource = new DynamicStreamingResource("rtmpe://cdn-flash-red-dev.vodco.co.uk/a2703");

        dynResource.streamItems = Vector.<DynamicStreamingItem>(
                [     new DynamicStreamingItem("mp4:e5/test/ccp/p/LOW_RES/test/test_asset.mp4", 408, 768, 428)
                    , new DynamicStreamingItem("mp4:e5/test/ccp/p/LOW_RES/test/test_asset.mp4", 608, 768, 428)
                    , new DynamicStreamingItem("mp4:e5/test/ccp/p/LOW_RES/test/test_asset.mp4", 908, 1024, 522)
                    , new DynamicStreamingItem("mp4:e5/test/ccp/p/LOW_RES/test/test_asset.mp4", 1308, 1024, 522)
                    , new DynamicStreamingItem("mp4:e5/test/ccp/p/LOW_RES/test/test_asset.mp4", 1708, 1280, 720)
                ]);

    }

    public function get DynamicResource():DynamicStreamingResource {

        return dynResource;
    }
}
}