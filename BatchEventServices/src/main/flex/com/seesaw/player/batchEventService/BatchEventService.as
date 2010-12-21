package com.seesaw.player.batchEventService {
import com.seesaw.player.batchEventService.events.BatchEvent;
import com.seesaw.player.batchEventService.events.ContentEvent;
import com.seesaw.player.batchEventService.events.ViewEvent;
import com.seesaw.player.batchEventService.services.HTTPServiceRequest;
import com.seesaw.player.namespaces.contentinfo;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.events.MediaElementEvent;
import org.osmf.events.MetadataEvent;
import org.osmf.events.PlayEvent;
import org.osmf.events.SeekEvent;
import org.osmf.events.TimeEvent;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.PlayState;
import org.osmf.traits.PlayTrait;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class BatchEventService extends ProxyElement {

    use namespace contentinfo;
    
    private var logger:ILogger = LoggerFactory.getClassLogger(BatchEventService);

    private var seekTrait:SeekTrait;
    private var playTrait:PlayTrait;
    private var timeTrait:TimeTrait;
    private var seeking:Boolean;
    private var seekTime:Number;

    private var viewEvent:ViewEvent;
    private var contentEvent:ContentEvent;
    private var batchEvent:BatchEvent;
    private var service:HTTPServiceRequest;
    private var batchContainer:Object;
    private var destinationURL:String;
    
    private var viewId:int;
    private var transactionItemId:int;
    private var serverTimeStamp:int;
    private var mainAssetId:int;

    public function BatchEventService(proxiedElement:MediaElement = null) {
        super(proxiedElement);
    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            super.proxiedElement = proxiedElement;

            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

            proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);

           var metadata:Metadata = getMetadata("http://www.seesaw.com/api/contentinfo/v1.0");

           var infoData:XML = resource.getMetadataValue("videoInfo") as XML;
              

            viewId =  infoData.viewId
            transactionItemId =   infoData.transactionItemId;
            serverTimeStamp =   infoData.serverTimeStamp;
            mainAssetId =     infoData.mainAssetID;
            destinationURL =   infoData.batchEventService;

            
          // metadata.addEventListener(MetadataEvent.VALUE_CHANGE, onMetadataChange);
          //  metadata.addEventListener(MetadataEvent.VALUE_ADD, onMetadataChange);

       //     var settings:Metadata = resource.getMetadataValue(PlayerConstants.CONTENT_ID) as Metadata;

       //    trace( settings );
        }
    }

    private function onMetadataChange(event:MetadataEvent):void {
          if (event.key == "adMap" && (event.value >=0 ))
          {
            viewEvent = new ViewEvent(viewId, transactionItemId, serverTimeStamp, event.value, mainAssetId );

         //   contentEvent = new ContentEvent();
     //   batchEvent = new BatchEvent();
     //   service = new HTTPServiceRequest(batchContainer, destinationURL, null, null, null);
     /*   event.key
        event.value*/
        }
    }

    private function onDurationChange(event:TimeEvent):void {
       
    }

    private function onSeekingChange(event:SeekEvent):void {
        seeking = event.seeking;
        seekTime = event.time;
    }

    private function onComplete(event:TimeEvent):void {
       
    }

    private function onPlayStateChanged(event:PlayEvent):void {
        switch (event.playState) {
            case PlayState.PAUSED:
              

                break;
            case PlayState.PLAYING:
                logger.debug("playing");
                break;
            case PlayState.STOPPED:
              
                break;
        }
    }



    private function onTraitAdd(event:MediaElementEvent):void {
        updateTraitListeners(event.traitType, true);
    }

    private function onTraitRemove(event:MediaElementEvent):void {
        updateTraitListeners(event.traitType, false);
    }

    private function updateTraitListeners(traitType:String, add:Boolean):void {
        switch (traitType) {
            case MediaTraitType.SEEK:
                changeListeners(add, traitType, SeekEvent.SEEKING_CHANGE, onSeekingChange);
                seekTrait = getTrait(MediaTraitType.SEEK) as SeekTrait;
                break;
            case MediaTraitType.PLAY:
                changeListeners(add, traitType, PlayEvent.PLAY_STATE_CHANGE, onPlayStateChanged);
                playTrait = getTrait(MediaTraitType.PLAY) as PlayTrait;
                break;
            case MediaTraitType.TIME:
                changeListeners(add, traitType, TimeEvent.COMPLETE, onComplete);
                changeListeners(add, traitType, TimeEvent.DURATION_CHANGE, onDurationChange);
                timeTrait = getTrait(MediaTraitType.TIME) as TimeTrait;
                break;
        }
    }

    private function changeListeners(add:Boolean, traitType:String, event:String, listener:Function):void {
        if (add) {
            getTrait(traitType).addEventListener(event, listener);
        }
        else if (hasTrait(traitType)) {
            getTrait(traitType).removeEventListener(event, listener);
        }
    }
}
}