package com.seesaw.player.batchEventService {
import com.adobe.serialization.json.JSON;
import com.seesaw.player.PlayerConstants;
import com.seesaw.player.ads.AdMetadata;
import com.seesaw.player.batchEventService.events.EventTypes;
import com.seesaw.player.batchEventService.events.UserEvent;
import com.seesaw.player.batchEventService.events.UserEventTypes;
import com.seesaw.player.batchEventService.services.HTTPServiceRequest;
import com.seesaw.player.batchEventService.services.ServiceRequest;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.namespaces.contentinfo;

import com.seesaw.player.services.ResumeService;

import com.seesaw.player.traits.ads.AdTrait;

import com.seesaw.player.traits.ads.AdTraitType;

import flash.events.FullScreenEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import flash.utils.getTimer;

import mx.rpc.AsyncToken;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

import mx.rpc.http.HTTPService;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.BufferEvent;
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MetadataEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
import org.osmf.events.TimeEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.traits.BufferTrait;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class BatchEventService extends ProxyElement {

    use namespace contentinfo;

    private var events:Array;

    private static const CUMULATIVE_DURATION_COUNTER_TIMER_DELAY_INTERVAL = 500;

    private var logger:ILogger = LoggerFactory.getClassLogger(BatchEventService);

    private var resumeService;ResumeService;

    private var cumulativeDurationTimer:Timer;

    private var cumulativeDurationCount:Number;
    private var timer:Timer;

    private var seeking:Boolean

    private var viewId:Number;
    private var transactionItemId:int;
    private var serverTimeStamp:int;
    private var mainAssetId:int;
    private var sectionCount:int;

    private var subtitlesVisible:Boolean;
    private var fullScreen:Boolean;

    private var previousPlayState:String;
    private var currentPlayState:String;

    private var destinationURL:String;

    private var inAds:Boolean;

    public function BatchEventService(proxiedElement:MediaElement = null) {
        super(proxiedElement);
        events = new Array();
        var provider:ObjectProvider = ObjectProvider.getInstance();
        // we can get whether it's an auto resume or auto play from the resume service
        resumeService = provider.getObject(ResumeService);
        if (resumeService == null) {
           throw ArgumentError("no resume service implementation provided");
        }
    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {

            trace( "################# initialising batch event service with proxy ####################" + proxiedElement  );
            super.proxiedElement = proxiedElement;
            var traitType:String

            if (proxiedElement != null) {
                // Clear our old listeners.
                removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
                removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
                removeEventListener(MediaElementEvent.METADATA_ADD, onMetaDataAdd);
                removeEventListener(MediaElementEvent.METADATA_REMOVE, onMetaDataRemove);

                for each (traitType in proxiedElement.traitTypes) {
                    processTrait(traitType, false);
                }
            }

            if (proxiedElement != null) {
                // Listen for traits being added and removed.
                addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
                addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
                addEventListener(MediaElementEvent.METADATA_ADD, onMetaDataAdd);

                for each (traitType in proxiedElement.traitTypes) {
                    processTrait(traitType, true);
                }
            }

            // a frequency of less than 20 milliseconds is not recommended.
            timer = new Timer(CUMULATIVE_DURATION_COUNTER_TIMER_DELAY_INTERVAL,0);
            timer.addEventListener( TimerEvent.TIMER , incrementCumulativeDurationCounter);
            timer.start();

            cumulativeDurationCount = 0;
            cumulativeDurationTimer = new Timer(5000,0);
            cumulativeDurationTimer.addEventListener(TimerEvent.TIMER, onTimerTick);
            cumulativeDurationTimer.start();

            var infoData:Metadata = resource.getMetadataValue(PlayerConstants.METADATA_NAMESPACE) as Metadata;

            if (infoData) {
                var newINT:Number =  int(new Date());
                viewId = newINT;

                destinationURL = infoData.getValue("contentInfo").batchEventService;


                var number:Number = resumeService.getResumeCookie();
                if ( number == 0 ) {
                    events.push(   )
                    UserEventTypes.AUTO_PLAY
                } else {
                    UserEventTypes.AUTO_RESUME
                }
            }

        }
    }

    private function incrementCumulativeDurationCounter(event:TimerEvent):void {
        cumulativeDurationCount += CUMULATIVE_DURATION_COUNTER_TIMER_DELAY_INTERVAL;
    }

    private function onMetaDataRemove(event:MediaElementEvent):void {trace ( "############################################## batchEventService onMetaDataAdd ##############################################: "+event.namespaceURL );
         if (event.namespaceURL == "http://www.osmf.org/samples/controlbar/metadata") {
            var metadata:Metadata = event.target.getMetadata("http://www.osmf.org/samples/controlbar/metadata");
            metadata.removeEventListener(MetadataEvent.VALUE_CHANGE, onControlBarMetadataChange);
            metadata.removeEventListener(MetadataEvent.VALUE_ADD, onControlBarMetadataChange);
        } else if ( event.namespaceURL == "http://www.seesaw.com/player/ads/1.0" ) {
            var metadata:Metadata = event.target.getMetadata( "http://www.seesaw.com/player/ads/1.0" );
            metadata.removeEventListener( MetadataEvent.VALUE_ADD, onAdsMetaDataAdd ) ;
            metadata.removeEventListener( MetadataEvent.VALUE_CHANGE, onAdsMetaDataChange);
        }
    }

    private function onMetaDataAdd(event:MediaElementEvent):void {
        trace ( "############################################## batchEventService onMetaDataAdd ##############################################: "+event.namespaceURL );
         if (event.namespaceURL == "http://www.osmf.org/samples/controlbar/metadata") {
            var metadata:Metadata = event.target.getMetadata("http://www.osmf.org/samples/controlbar/metadata");
            metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onControlBarMetadataChange);
            metadata.addEventListener(MetadataEvent.VALUE_ADD, onControlBarMetadataChange);
        } else if ( event.namespaceURL == "http://www.seesaw.com/player/ads/1.0" ) {
            var metadata:Metadata = event.target.getMetadata( "http://www.seesaw.com/player/ads/1.0" );
            metadata.addEventListener( MetadataEvent.VALUE_ADD, onAdsMetaDataAdd ) ;
            metadata.addEventListener( MetadataEvent.VALUE_CHANGE, onAdsMetaDataChange);
        }
    }

    private function onAdsMetaDataChange(event:MetadataEvent):void {
        if ( event.key == "adState") {
            if ( event.value == "stopped" ) {
                inAds = false;
            }
        }
        trace ( "######################## onAdsMetaDataChange ################## " + event.key + ", " + event.value );
    }

    private function onAdsMetaDataAdd(event:MetadataEvent):void {
        if ( event.key == "adState" ) {
            if ( event.value == "started" ) {
                inAds = true;
            }
        }
        trace ( "######################## onAdsMetaDataAdd ###################### " + event.key + ", " + event.value );
    }

    // listen for events related to control bar
    private function onControlBarMetadataChange(event:MetadataEvent):void {

        trace( "onControlBarMetadataChange: "+event.key + ", " + event.value );
        if ( event.key == "subtitlesVisible" ) {
            trace ( "setting subtitlesVisible to " + event.value );
            subtitlesVisible = event.value;
        } else if ( event.key == "fullScreen" ) {
            trace ( "setting fullScreen to " + event.value );
            fullScreen = event.value;

        }
    }


    private function onTimerTick(event:TimerEvent):void {
        trace( "The cumulative view duration in milliseconds so far is: "+ cumulativeDurationCount );
        var date:Date = new Date();
        var userEvent:UserEvent = new UserEvent(viewId, 2, cumulativeDurationCount, UserEventTypes.CUMULATIVE_DURATION, date);
        var request:ServiceRequest = new ServiceRequest(destinationURL, onSuccess, onFailed);
        request.submit();
    }




    private function onSuccess(event:ResultEvent):void {
        trace("success");
    }

    private function onFailed(event:FaultEvent):void {
        trace("fail");
    }


    private function onBufferingChange(event:BufferEvent):void {
        UserEventTypes.BUFFERING;
        logger.debug("**** BatchEventService:{0} onBufferingChange **** ", event.buffering);
    }

    private function onBufferTimeChange(event:BufferEvent):void {

        logger.debug("**** BatchEventService onBufferTimeChange:{0}", event.bufferTime);
    }

     private function processTrait(traitType:String, added:Boolean):void {
        switch (traitType) {
            case MediaTraitType.LOAD:
                toggleLoadListeners(added);
                break;
            case MediaTraitType.BUFFER:
                toggleBufferListeners(added);
                break;
            case MediaTraitType.SEEK:
                toggleSeekListeners(added);
                break;
            case MediaTraitType.TIME:
                toggleTimeListeners(added);
                break;
            case MediaTraitType.PLAY:
                togglePlayListeners(added);
                break;
            default:
                trace( "######################## Trait type not processed " + traitType + " ##########################" )
                break;
        }
    }

    private function togglePlayListeners(added:Boolean):void {
        var playable:PlayTrait = proxiedElement.getTrait(MediaTraitType.PLAY) as PlayTrait;
        if (playable) {
            if (added) {
                playable.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
                playable.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, onCanPauseChange);
            }
            else {
                playable.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
                playable.removeEventListener(PlayEvent.CAN_PAUSE_CHANGE, onCanPauseChange);
            }
        }
    }

    private function onCanPauseChange(event:PlayEvent):void {
        logger.debug("Can Pause Change:{0}", event.canPause);
    }

    private function onPlayStateChange(event:PlayEvent):void {
        switch (event.playState) {
            case PlayState.PAUSED:
                timer.stop();
                trace("paused");
                break;
            case PlayState.PLAYING:
                initialiseCumulativeDurationTimer();
                trace("playing");
                break;
            case PlayState.STOPPED:
                timer.stop();
                trace("stopped");
                break;
        }
         trace( "onPlayStateChange" + event.playState );
    }

    private function initialiseCumulativeDurationTimer():void {
//        timer = null;
//        timer = new Timer(CUMULATIVE_DURATION_COUNTER_TIMER_DELAY_INTERVAL, 0);
//        timer.addEventListener(TimerEvent.TIMER, incrementCumulativeDurationCounter);
        timer.start();
    }

    private function onTraitAdd(event:MediaElementEvent):void {
        processTrait(event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        processTrait(event.traitType, false);
    }

     private function toggleBufferListeners(added:Boolean):void {
        var buffer:BufferTrait = proxiedElement.getTrait(MediaTraitType.BUFFER) as BufferTrait;
        if (buffer) {
            if (added) {
                buffer.addEventListener(BufferEvent.BUFFER_TIME_CHANGE, onBufferTimeChange);
                buffer.addEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
            }
            else {
                buffer.removeEventListener(BufferEvent.BUFFER_TIME_CHANGE, onBufferTimeChange);
                buffer.removeEventListener(BufferEvent.BUFFERING_CHANGE, onBufferingChange);
            }
        }
    }

    private function toggleLoadListeners(added:Boolean):void {
        var loadable:LoadTrait = proxiedElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
        if (loadable) {
            if (added) {
                loadable.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadableStateChange);
                loadable.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);

            }
            else {
                loadable.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadableStateChange);
                loadable.removeEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);
            }
        }
    }

    private function onBytesTotalChange(event:LoadEvent):void {
        logger.debug("Load onBytesTotal change:{0}", event.bytes);
    }

    private function onLoadableStateChange(event:LoadEvent):void {
        logger.debug("Load state change:{0}", event.loadState);
    }

    private function toggleSeekListeners(added:Boolean):void {
        var seek:SeekTrait = proxiedElement.getTrait(MediaTraitType.SEEK) as SeekTrait;

        if (seek) {
            seek.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
        } else {
            seek.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
        }
    }

    private function onSeekingChange(event:SeekEvent):void {
        if ( event.seeking ) {
            if (!seeking) {
                timer.stop();
                seeking = event.seeking;
            }
        } else {
            seeking = event.seeking;
        }
        logger.debug("On Seek Change:{0}", event.seeking);
    }

    private function toggleTimeListeners(added:Boolean):void {
        var time:TimeTrait = proxiedElement.getTrait(MediaTraitType.TIME) as TimeTrait;

        if (time) {
            time.addEventListener(TimeEvent.COMPLETE, onComplete);
            time.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
            time.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
        } else {
            time.removeEventListener(TimeEvent.COMPLETE, onComplete);
            time.removeEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
            time.removeEventListener(TimeEvent.DURATION_CHANGE, onDurationChange);
        }
    }

    private function onDurationChange(event:TimeEvent):void {
        logger.debug("On Duration Change:{0}", event.target.duration);
    }

    private function onCurrentTimeChange(event:TimeEvent):void {
        logger.debug("On Current Time Change:{0}", event.time);
    }

    private function onComplete(event:TimeEvent):void {
        UserEventTypes.END;
        logger.debug("On Complete");
    }
}
}