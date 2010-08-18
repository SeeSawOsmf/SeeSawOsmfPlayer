package uk.co.vodco.osmfPlayer {
import flash.display.Graphics;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.MouseEvent;

import flash.external.ExternalInterface;
import flash.media.Video;
import flash.system.Security;
import flash.ui.ContextMenu;

import mx.containers.ControlBar;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.containers.MediaContainer;
import org.osmf.elements.ParallelElement;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.layout.HorizontalAlign;
import org.osmf.layout.LayoutMetadata;
import org.osmf.layout.VerticalAlign;
import org.osmf.logging.Log;
import org.osmf.media.DefaultMediaFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaPlayer;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfoResource;
import org.osmf.media.URLResource;
import org.osmf.metadata.Metadata;

import uk.co.vodco.osmfPlayer.logger.TraceAndArthropodLoggerFactory;
import uk.co.vodco.osmfPlayer.logger.CommonsOsmfLoggerFactory;
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
    private static const PARAM_URL:String = "url";
    private static const PARAM_PROGRAMME:String = "programme";
    private static const VIDEO_URL:String = "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short";

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
        var key:String;
        for (key in parameters) {
            logger.info("Parameter: {0}, Value {1}", key, parameters[key]);
        }

        var urlResource:MediaResourceBase;

        if (parameters[PARAM_URL]) {
            urlResource = new URLResource(parameters[PARAM_URL]);
        } else if (parameters[PARAM_PROGRAMME]) {
            // TODO this would be replaced with a ProgrammeResource so our own plugin can resolve what to do about it
            urlResource = new URLResource(VIDEO_URL);
            // Sample of how to add metadata
            var programmeId:Metadata = new Metadata();
            programmeId.addValue("ProgrammeID", 1);
            urlResource.addMetadataValue(PLAYER_NAMESPACE, programmeId);
        } else {
            urlResource = new URLResource(VIDEO_URL);
        }
        return urlResource;
    }


}
}