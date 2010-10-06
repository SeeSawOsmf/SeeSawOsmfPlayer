package uk.co.vodco.osmfPlayer {
import flash.display.Sprite;

import org.osmf.containers.MediaContainer;
import org.osmf.events.*;
import org.osmf.media.DefaultMediaFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaPlayer;
import org.osmf.media.MediaPlayerState;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfoResource;
import org.osmf.media.URLResource;
import org.osmf.smil.SMILPluginInfo;
import org.osmf.traits.MediaTraitType;
import org.osmf.utils.*;

public class SMILExample extends Sprite {



            private static const SMIL_TEST1:String 		= "http://mediapm.edgesuite.net/ovp/content/demo/smil/elephants_dream.smil";
            private static const SMIL_TEST2:String		= "http://www.streamflashhd.com/video/train.smil";
              // NON-DYNAMIC PROGRESSIVE
            private static const PROGRESSIVE_FLV:String = "http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv";
              // NON-DYNAMIC STREAMING
            private static const STREAMING_F4V:String	= "rtmp://cp67126.edgefcs.net/ondemand/mp4:mediapm/osmf/content/test/sample1_700kbps.f4v";

           private var smilFiles:Array = [ SMIL_TEST1, SMIL_TEST2, PROGRESSIVE_FLV, STREAMING_F4V ];



			private var _mediaPlayerState:String = "Not Loaded";


			private var _isAutoSwitchable:Boolean = true;


			private var _autoSwitchBtnLabel:String = "Manual";

    private static const DEFAULT_PROGRESS_DELAY:uint = 100;

			private var isDynamicStream:Boolean = false;

			private static const forceReference:SMILPluginInfo = null;

			private var sliderDragging:Boolean;
			private var waitForSeek:Boolean;
			private var currentDebugLineNo:int;
            private var mediaFactory:DefaultMediaFactory;
			private var mediaElement:MediaElement;
			private var mediaPlayer:MediaPlayer;
            private var container:MediaContainer = new MediaContainer();
    public function SMILExample() {

         super();



                mediaFactory = new DefaultMediaFactory();
				mediaPlayer = new MediaPlayer();

        		mediaPlayer.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);
				mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
				mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
				mediaPlayer.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
				mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE, onPlayingChange);
				mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.IS_DYNAMIC_STREAM_CHANGE, onIsDynamicStreamChange);
				mediaPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onStateChange);
				mediaPlayer.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);

				mediaPlayer.currentTimeUpdateInterval = DEFAULT_PROGRESS_DELAY;

				sliderDragging = false;
				waitForSeek = false;



                mediaPlayer.autoPlay = true;

                SMILPluginInfo;
				loadPlugin("org.osmf.smil.SMILPluginInfo");


    }
private function loadMedia(url:String):void
			{
				clear();

				var resource:URLResource = new URLResource(url);

				mediaElement = mediaFactory.createMediaElement(resource);
				setupMediaElementListeners();
				setMediaElement(mediaElement);

			}

			private function setMediaElement(value:MediaElement):void
			{
				if (mediaPlayer.media != null)
				{
					container.removeMediaElement(mediaPlayer.media);
				}

				if (value != null)
				{
					container.addMediaElement(value);
				}

				mediaPlayer.media = value;

			}

			private function setupMediaElementListeners(add:Boolean=true):void
			{
				if (mediaElement == null)
				{
					return;
				}

				if (add)
				{
					// Listen for traits to be added, so we can adjust the UI. For example, enable the seek bar
					// when the seekable trait is added
					mediaElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
					mediaElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
					mediaElement.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
				}
				else
				{
					mediaElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
					mediaElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
					mediaElement.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
				}
			}

   			private function onTraitAdd(event:MediaElementEvent):void
   			{
   				switch (event.traitType)
   				{
   					case MediaTraitType.SEEK:

   						break;
   				}
   			}

   			private function onTraitRemove(event:MediaElementEvent):void
   			{
   				switch (event.traitType)
   				{
   					case MediaTraitType.SEEK:

   						break;
   				}
   			}

			private function loadPlugin(source:String):void
			{
				var pluginResource:MediaResourceBase;

				if (source.substr(0, 4) == "http" || source.substr(0, 4) == "file")
				{
					// This is a URL, create a URLResource
					pluginResource = new URLResource(source);
				}
				else
				{
					// Assume this is a class

                    var SMILPlugin:SMILPluginInfo = new SMILPluginInfo();
			///var pluginInfoRef:Class = flash.utils.getDefinitionByName(source) as Class;
					pluginResource = new PluginInfoResource(SMILPlugin);
				}

				loadPluginFromResource(pluginResource);
			}

			private function loadPluginFromResource(pluginResource:MediaResourceBase):void
			{
				mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, onPluginLoaded);
				mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, onPluginLoadFailed);
				mediaFactory.loadPlugin(pluginResource);
			}

			private function onPluginLoaded(event:MediaFactoryEvent):void
			{
				trace("Plugin LOADED!");

                loadMedia("http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv");

			}

			private function onPluginLoadFailed(event:MediaFactoryEvent):void
			{
				trace("Plugin LOAD FAILED!");
			}

			private function onPlayingChange(event:MediaPlayerCapabilityChangeEvent):void
			{
				if (event.type == MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE)
				{
					enableControls(event.enabled);
				}
			}

			private function enableControls(enable:Boolean):void
			{

			}

   			private function onIsDynamicStreamChange(event:MediaPlayerCapabilityChangeEvent):void
   			{
   				isDynamicStream = event.enabled;
   				if (event.enabled)
   				{
   					var streamMsg:String = "Current streaming profile index: " + mediaPlayer.currentDynamicStreamIndex + " of " + mediaPlayer.maxAllowedDynamicStreamIndex;
					debug(streamMsg);

					mediaPlayer.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onSwitchingChange);
					updateSwitchingControls();
				}
   			}

 			private function onStateChange(event:MediaPlayerStateChangeEvent):void
			{
				debug("onStateChange() - state=" + event.state);

				switch (event.state)
				{
					case MediaPlayerState.READY:
						_mediaPlayerState = "Ready";
						break;
					case MediaPlayerState.PLAYBACK_ERROR:
						_mediaPlayerState = "Error";
						break;
				}
			}

			private function onSwitchingChange(event:DynamicStreamEvent):void
			{
				var msg:String = "Switching change "
				var showCurrentIndex:Boolean = false;

				if (event.switching)
				{
					msg += "REQUESTED";
				}
				else
				{
					msg += "COMPLETE";
					showCurrentIndex = true;
				}

				debug(msg);

				if (showCurrentIndex)
				{
					var streamMsg:String = "Current streaming profile index: " + mediaPlayer.currentDynamicStreamIndex + " of " + mediaPlayer.maxAllowedDynamicStreamIndex;
					debug(streamMsg);

					streamMsg = "Current bitrate = " + mediaPlayer.getBitrateForDynamicStreamIndex(mediaPlayer.currentDynamicStreamIndex) + "kbps";
					debug(streamMsg);
				}

				updateSwitchingControls();
			}

			private function updateSwitchingControls():void
			{
				// Disable if a switch is pending or the video is not switchable
				if (mediaPlayer.isDynamicStream == false || mediaPlayer.dynamicStreamSwitching)
				{

				}
				else if (!mediaPlayer.autoDynamicStreamSwitch)
				{
				//	autoSwitchBtn.enabled = true;
					//switchUpBtn.enabled = (mediaPlayer.currentDynamicStreamIndex == mediaPlayer.maxAllowedDynamicStreamIndex) ? false : true;
				//	switchDownBtn.enabled = (mediaPlayer.currentDynamicStreamIndex  == 0) ? false : true;
				}
				else
				{
				//	autoSwitchBtn.enabled = true;
				//	switchUpBtn.enabled = false;
				//	switchDownBtn.enabled = false;
				}
			}

			private function debug(...args):void
			{
				var lineNo:int = currentDebugLineNo++;

			}

			private function autoScroll():void
			{

			}

			private function clearDebugText():void
			{

				currentDebugLineNo = 0;
			}

			private function clear(eraseDebugTxt:Boolean=true):void
			{
				if (eraseDebugTxt)
				{
					clearDebugText();
				}

			}

			private function unload():void
			{
				setupMediaElementListeners(false);
				mediaPlayer.media = null;

				clear(false);
			}

			private function onMediaSizeChange(event:DisplayObjectEvent):void
			{
				var width:int = event.newWidth;
				var height:int = event.newHeight;


			}

			private function onDurationChange(event:TimeEvent):void
			{
				trace(event.time);
				trace(TimeUtil.formatAsTimeCode(event.time));
			}

			private function onCurrentTimeChange(event:TimeEvent):void
			{
				if (mediaPlayer.temporal && !sliderDragging && !waitForSeek)
				{

				}
			}

			private function onSeekingChange(event:SeekEvent):void
			{
				if (event.seeking == false)
				{
					waitForSeek = false;
					updateSwitchingControls();
				}
			}

   			private function toggleDragging(state:Boolean):void
   			{
   				sliderDragging = state;
   				if (!state)
   				{
   					waitForSeek = true;
   					if (mediaPlayer.canSeek)
   					{
   				///		mediaPlayer.seek(seekBar.value);
   					}
   				}
   			}

   			private function onMediaError(event:MediaErrorEvent):void
   			{

   			}

			private function onSwitchUp():void
			{
				if (mediaPlayer.isDynamicStream && !mediaPlayer.autoDynamicStreamSwitch && !mediaPlayer.dynamicStreamSwitching)
				{
					if (mediaPlayer.currentDynamicStreamIndex < mediaPlayer.maxAllowedDynamicStreamIndex)
					{
						mediaPlayer.switchDynamicStreamIndex(mediaPlayer.currentDynamicStreamIndex + 1);
					}
				}
			}

			private function onSwitchDown():void
			{
				if (mediaPlayer.isDynamicStream && !mediaPlayer.autoDynamicStreamSwitch && !mediaPlayer.dynamicStreamSwitching)
				{
					if (mediaPlayer.currentDynamicStreamIndex > 0)
					{
						mediaPlayer.switchDynamicStreamIndex(mediaPlayer.currentDynamicStreamIndex - 1);
					}
				}
			}

			private function onAutoSwitchable():void
			{
				if (mediaPlayer.isDynamicStream)
				{
					this._isAutoSwitchable = !this._isAutoSwitchable;
					mediaPlayer.autoDynamicStreamSwitch = this._isAutoSwitchable;
					debug("Setting auto switch mode to " + this._isAutoSwitchable);

					_autoSwitchBtnLabel = (_isAutoSwitchable ? "Manual" : "Auto");
					updateSwitchingControls();
				}
			}

			private function onClickPlayBtn():void
			{
				if (mediaPlayer.playing && mediaPlayer.canPause)
				{
				///	playBtn.label = "Play";
					mediaPlayer.pause();
				}
				else if (mediaPlayer.paused && mediaPlayer.canPlay)
				{
				//	playBtn.label = "Pause";
					mediaPlayer.play();
				}
			}

			private function showControls(show:Boolean=true):void
			{
			///	mainContainer.visible = mainContainer.includeInLayout = show;
			}

}

}