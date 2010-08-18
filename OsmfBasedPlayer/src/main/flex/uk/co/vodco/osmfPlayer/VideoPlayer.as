package uk.co.vodco.osmfPlayer {
import com.carlcalderon.arthropod.Debug;

import flash.display.Sprite;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.containers.MediaContainer;
import org.osmf.elements.ParallelElement;
import org.osmf.events.MediaFactoryEvent;
import org.osmf.layout.HorizontalAlign;
import org.osmf.layout.LayoutMetadata;
import org.osmf.layout.VerticalAlign;
import org.osmf.media.DefaultMediaFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaPlayer;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfoResource;
import org.osmf.metadata.Metadata;

import uk.co.vodco.osmfDebugProxy.DebugPluginInfo;

/**
 * This is the main player object and it is responsible for the video player.
 *
 * We must keep seperation of concerns intact. This class should only
 * - Register and initialise plugins
 * - Pass media into the media factory for playback
 *
 * @see Player for the wrapper that holds this and items not directly related to playback.
 *
 *
 */
public class VideoPlayer extends Sprite {

    private var mediaFactory:MediaFactory;
    private var mediaPlayer:MediaPlayer;
    private var mediaContainer:MediaContainer;
    private var rootElement:ParallelElement;

    private static const ID:String = "ID";

    private static const VIDEO_URL:String = "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short";

    private static const MAINCONTENT_ID:String = "mainContent";


    private var logger:ILogger = LoggerFactory.getClassLogger(VideoPlayer);

    public function VideoPlayer(mainContent:MediaResourceBase, width:int, height:int)
    {
        logger.info("Initialising Video Player to play");

        mediaFactory = new DefaultMediaFactory();

        // Add event listeners to the plug-in manager so we'll get
        // a heads-up when the control bar plug-in finishes loading:
        mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
        mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadError);

        // Load our 'normal' plugins here - control bar is a bit special
        // TODO review if Adobe's sample way of initialising the control bar is a 'good' idea
        mediaFactory.loadPlugin(new PluginInfoResource(new DebugPluginInfo()));


        // As we are going to have controls we have a parallel elements
        // One item is the video
        // The other item (added once the plugin loads) is the control bar
        rootElement = createParallelElement(width, height);
        rootElement.addChild(constructVideoElement(mainContent));

        // Load our control bar plugin here
        // The control bar will 'bind' to whatever controls the main content based on metadata
        var controlBarPlugin:ControlBarPlugin = new ControlBarPlugin();
        var controlBarPluginInfo:PluginInfoResource = new PluginInfoResource(controlBarPlugin.pluginInfo);
        mediaFactory.loadPlugin(controlBarPluginInfo);


        // Set a player up to control the wrapper element
        mediaPlayer = new MediaPlayer();
        mediaPlayer.media = rootElement;
        mediaPlayer.autoPlay = false;

        // Display the wrapper element
        mediaContainer = new MediaContainer();
        mediaContainer.addMediaElement(rootElement);
        addChild(mediaContainer);


    }

    private function onPluginLoaded(event:MediaFactoryEvent):void
    {
        logger.info("Plugin loaded");

        // A plugin loaded successfully.
        // Depending on which one we may do post initialisation
        if (event.resource is PluginInfoResource) {
            // We can now construct a control
            // bar media element, and add it as a child to the root parallel
            // element:
            var pluginInfo:PluginInfoResource = PluginInfoResource(event.resource);

            if (pluginInfo.pluginInfo.numMediaFactoryItems > 0) {
                logger.info("Plugin media factory(0).id {0}", pluginInfo.pluginInfo.getMediaFactoryItemAt(0).id)
                if (pluginInfo.pluginInfo.getMediaFactoryItemAt(0).id == ControlBarPlugin.ID) {
                    rootElement.addChild(constructControlBarElement());
                }
            }
        }
    }

    private function onPluginLoadError(event:MediaFactoryEvent):void
    {
        logger.error("ERROR: the control bar plugin failed to load.");
    }


    private function createParallelElement(width:int, height:int):ParallelElement {
        var _rootElement:ParallelElement = new ParallelElement();
        var rootElementLayout:LayoutMetadata = new LayoutMetadata();
        _rootElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, rootElementLayout);
        rootElementLayout.width = width;
        rootElementLayout.height = height;
        return _rootElement;
    }

    private function constructVideoElement(maincontent:MediaResourceBase):MediaElement
    {
        // Construct a metadata object that we can append to the video's collection
        // of metadata. The control bar plug-in will use the metadata to identify
        // the video element as its target:
        var controlBarTarget:Metadata = new Metadata();
        controlBarTarget.addValue(ID, "mainContent");

        // Construct a video element:
        var video:MediaElement = mediaFactory.createMediaElement(maincontent);

        // Add the metadata to the video's metadata:
        video.addMetadata(ControlBarPlugin.NS_CONTROL_BAR_TARGET, controlBarTarget);

        return video;
    }

    private function constructControlBarElement():MediaElement
    {
        // Construct a metadata object that we'll send to the media factory on
        // requesting a control bar element to be instantiated. The factory
        // will use it to parameterize the element. Specifically, the ID field
        // will tell the plug-in what the ID of the content it should control
        // is:
        var controlBarSettings:Metadata = new Metadata();
        controlBarSettings.addValue(ID, MAINCONTENT_ID);

        // Add the metadata to an otherwise empty media resource object:
        var resource:MediaResourceBase = new MediaResourceBase();
        resource.addMetadataValue(ControlBarPlugin.NS_CONTROL_BAR_SETTINGS, controlBarSettings);

        // Request the media factory to construct a control bar element. The
        // factory will infer a control bar element is requested by inspecting
        // the resource's metadata (and encountering a metadata object of namespace
        // NS_CONTROL_BAR_SETTINGS there):
        var controlBar:MediaElement = mediaFactory.createMediaElement(resource);

        // Set some layout properties on the control bar. Specifically, have it
        // appear at the bottom of the parallel element, horizontally centererd:
        var layout:LayoutMetadata = controlBar.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
        if (layout == null)
        {
            layout = new LayoutMetadata();
            controlBar.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
        }
        layout.verticalAlign = VerticalAlign.BOTTOM;
        layout.horizontalAlign = HorizontalAlign.CENTER;

        // Make sure that the element shows over the video: element's with a
        // higher order number set are placed higher in the display list:
        layout.index = 1;

        return controlBar;
    }
}
}