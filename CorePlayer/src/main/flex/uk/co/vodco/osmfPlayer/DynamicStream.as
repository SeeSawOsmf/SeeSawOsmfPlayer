package uk.co.vodco.osmfPlayer {


  import org.osmf.net.DynamicStreamingItem;
  import org.osmf.net.DynamicStreamingResource;

public class DynamicStream  {

   private var dynResource:DynamicStreamingResource;
    public function DynamicStream(){

          // rtmpe://cdn-flash-red-dev.vodco.co.uk/a2703/e5/test/ccp/p/LOW_RES/test/test_asset.mp4


        dynResource = new DynamicStreamingResource("rtmpe://cdn-flash-red-dev.vodco.co.uk/a2703");

            dynResource.streamItems = Vector.<DynamicStreamingItem>(
                [     new DynamicStreamingItem("mp4:e5/test/ccp/p/LOW_RES/test/test_asset.mp4", 408, 768, 428)
                    , new DynamicStreamingItem("mp4:e5/test/ccp/p/LOW_RES/test/test_asset.mp4", 608, 768, 428)
                    , new DynamicStreamingItem("mp4:e5/test/ccp/p/LOW_RES/test/test_asset.mp4", 908, 1024, 522)
                    , new DynamicStreamingItem("mp4:e5/test/ccp/p/LOW_RES/test/test_asset.mp4", 1308, 1024, 522)
                    , new DynamicStreamingItem("mp4:e5/test/ccp/p/LOW_RES/test/test_asset.mp4", 1708, 1280, 720)
                ]);
        
        /*    dynResource = new DynamicStreamingResource("rtmp://cp67126.edgefcs.net/ondemand");

            dynResource.streamItems = Vector.<DynamicStreamingItem>(
                [     new DynamicStreamingItem("mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_768x428_24.0fps_408kbps.mp4", 408, 768, 428)
                    , new DynamicStreamingItem("mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_768x428_24.0fps_608kbps.mp4", 608, 768, 428)
                    , new DynamicStreamingItem("mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_1024x522_24.0fps_908kbps.mp4", 908, 1024, 522)
                    , new DynamicStreamingItem("mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_1024x522_24.0fps_1308kbps.mp4", 1308, 1024, 522)
                    , new DynamicStreamingItem("mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_1280x720_24.0fps_1708kbps.mp4", 1708, 1280, 720)
                ]);
           */
    }

    public function get DynamicResource():DynamicStreamingResource{

            return dynResource;
    }
}
}