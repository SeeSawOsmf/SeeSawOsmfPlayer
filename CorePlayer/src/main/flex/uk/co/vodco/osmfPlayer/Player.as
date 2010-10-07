package uk.co.vodco.osmfPlayer {
import com.seesaw.player.logging.CommonsOsmfLoggerFactory;
import com.seesaw.player.logging.TraceAndArthropodLoggerFactory;

import flash.display.Sprite;
import flash.external.ExternalInterface;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.logging.Log;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.URLResource;
import org.osmf.metadata.Metadata;

import uk.co.vodco.osmfPlayer.ui.VersionedContextMenu;

/**
 * Wrapper for player
 *
 * This class responsibilities are
 * - Getting details of what to play from context
 * - Showing the 'screens' of the application and transitioning between them (if this gets big it should be delegated)
 * - Global features (e.g. right click menu)
 * - Initialising logging
 *
 * All playback, logic etc should reside in other sprites
 *
 * Note this project deliberately does not us the mx. packages to improve performance
 *
 * We are using 'DEFINES' for width, height and version. These are set in the pom.xml
 *
 */
[SWF(width=PLAYER::Width, height=PLAYER::Height)]
public class Player extends Sprite {

    private static const PLAYER_WIDTH:int = PLAYER::Width;
    private static const PLAYER_HEIGHT:int = PLAYER::Height;
    private static const PARTNER_ID:String = "partnerID";
    private static const DEFAULT_PARTNER_ID:String = "Seesaw";
    private static const PROGRAMME_ID:String = "programmeID";
    
 // private static const VIDEO_URL:String = "http://mediapm.edgesuite.net/osmf/content/test/logo_animated.flv";
 /// private static const VIDEO_URL:String = "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short";
    private static const VIDEO_URL:String = "rtmp://cp67126.edgefcs.net/ondemand/mp4:mediapm/osmf/content/test/sample1_700kbps.f4v";

   ///  private static const VIDEO_URL:String = " http://mediapm.edgesuite.net/ovp/content/demo/smil/elephants_dream.smil";

//private static const VIDEO_URL:String = "rtmpe://cdn-flash-red-dev.vodco.co.uk/a2703/e5/test/ccp/p/LOW_RES/test/test_asset.mp4";
 ///  private static const VIDEO_URL:String = "rtmpe://cdn-flash-red-dev.vodco.co.uk/a2703/e5/test/ccp/p/LOW_RES/test/test_asset.mp4?s=1286205263&e=1286248763&h=82ea5041fdd8731c393e17d2ea1e7801";
 // private static const VIDEO_URL:String = "rtmp://almer.rtmphost.com/osmfplayer/mp4:sample5.mp4";

    private static var loggerSetup:* = (LoggerFactory.loggerFactory = new TraceAndArthropodLoggerFactory());
    private static var osmfLoggerSetup:* = (Log.loggerFactory = new CommonsOsmfLoggerFactory());

    private var logger:ILogger = LoggerFactory.getClassLogger(Player);
    
    private var versionedContextMenu:VersionedContextMenu;

    private static const PLAYER_NAMESPACE:String = "http://www.seesaw.com/player/";

    public function Player()
    {
        logger.info("Initialising Player at {0} x {1}", PLAYER_WIDTH, PLAYER_HEIGHT);

        versionedContextMenu = new VersionedContextMenu(this);

        var content:MediaResourceBase = configure();

        setupGlobalExternalInterface();

        loadVideo(content);
    }

    private function setupGlobalExternalInterface():void {
        if (ExternalInterface.available){
            ExternalInterface.addCallback("url", onSetUrl);
        }
        
    }

    private function onSetUrl(url:String):void {
        logger.info("URL Set To:{0}", url);
    }

    private var _videoPlayer:VideoPlayer;

    private function loadVideo(content:MediaResourceBase):void {
        if (_videoPlayer){
            // TODO verify is this is enough to let it all be GC'd (it may be as nothing will have a reference...)
            removeChild(_videoPlayer)
            _videoPlayer = null;
        }

        _videoPlayer = new VideoPlayer(content, PLAYER_WIDTH, PLAYER_HEIGHT);
        addChild(_videoPlayer);


 

    }

    private function configure():MediaResourceBase {
        
        var parameters:Object = this.root.loaderInfo.parameters;
        var partnerId:Metadata = new Metadata();
        var programmeId:Metadata = new Metadata();
        var key:String;
        var urlResource:MediaResourceBase;
        
            for (key in parameters) {
                logger.info("Parameter: {0}, Value {1}", key, parameters[key]);
            }


  
        if (parameters[PARTNER_ID] != null) {
            partnerId.addValue(PARTNER_ID, parameters[PARTNER_ID]);
        }else{
            partnerId.addValue(PARTNER_ID, DEFAULT_PARTNER_ID);
        }

        if(parameters[PROGRAMME_ID] != null){
            programmeId.addValue(PROGRAMME_ID, parameters[PROGRAMME_ID]);

        }else{
                programmeId.addValue(PROGRAMME_ID, 999999999999999);
          ///  return  urlResource = new URLResource(VIDEO_URL);
        }
        
        urlResource = new URLResource(VIDEO_URL);
        urlResource.addMetadataValue(PLAYER_NAMESPACE, partnerId);
        urlResource.addMetadataValue(PLAYER_NAMESPACE, programmeId);
        
        return urlResource;
    }

}
}