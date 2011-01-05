package com.seesaw.player.batchEventService {
import com.seesaw.player.PlayerConstants;
import com.seesaw.player.batchEventService.events.BatchEvent;
import com.seesaw.player.batchEventService.events.ContentEvent;
import com.seesaw.player.batchEventService.events.CumulativeViewEvent;
import com.seesaw.player.batchEventService.events.EventTypes;
import com.seesaw.player.batchEventService.events.UserEvent;
import com.seesaw.player.batchEventService.events.ViewEvent;
import com.seesaw.player.batchEventService.services.HTTPServiceRequest;
import com.seesaw.player.namespaces.contentinfo;

import flash.events.Event;

import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.elements.ProxyElement;
import org.osmf.media.MediaElement;
import org.osmf.metadata.Metadata;

public class BatchEventService extends ProxyElement {

    use namespace contentinfo;

    private var logger:ILogger = LoggerFactory.getClassLogger(BatchEventService);


    private var userEvent:UserEvent;
    private var viewEvent:ViewEvent;
    private var contentEvent:ContentEvent;
    private var cumulativeViewEvent:CumulativeViewEvent;

    private var batchEvent:BatchEvent;
    private var service:HTTPServiceRequest;
    private var batchContainer:Object;
    private var destinationURL:String;

    private var viewId:int;
    private var transactionItemId:int;
    private var serverTimeStamp:int;
    private var mainAssetId:int;
    private var sectionCount:int;


    public function BatchEventService(proxiedElement:MediaElement = null) {
        super(proxiedElement);
    }

    public override function set proxiedElement(proxiedElement:MediaElement):void {
        if (proxiedElement) {
            super.proxiedElement = proxiedElement;

            contentEvent = new ContentEvent();
            userEvent = new UserEvent();
            cumulativeViewEvent = new CumulativeViewEvent();
            batchEvent = new BatchEvent();


            var infoData:Metadata = resource.getMetadataValue(PlayerConstants.METADATA_NAMESPACE) as Metadata;

            if (infoData) {

                //// viewId = userEvent.viewId = contentEvent.viewId = infoData.getValue("videoInfo").viewId;
                var newINT:Number =  int(new Date());
                viewId = userEvent.viewId = contentEvent.viewId = newINT;


                transactionItemId = infoData.getValue("videoInfo").transactionItemId;
                serverTimeStamp = infoData.getValue("videoInfo").serverTimeStamp;
                mainAssetId = infoData.getValue("videoInfo").mainAssetID;
                destinationURL = infoData.getValue("contentInfo").batchEventService;
                sectionCount = infoData.getValue("videoInfo").sectionCount;

                userEvent.proxiedElement = proxiedElement;
                contentEvent.proxiedElement = proxiedElement;
                contentEvent.addEventListener(EventTypes.USER_EVENT_FIRED, updateContentUserEvtCount)
                /*cumulativeViewEvent*/

                viewEvent = new ViewEvent(viewId, transactionItemId, serverTimeStamp, sectionCount, mainAssetId);
                viewEvent.proxiedElement = proxiedElement;
                viewEvent.addEventListener(EventTypes.FIRE_VIEW_EVENT, fireView);
            }

        }
    }

    private function updateContentUserEvtCount(event:Event):void {
        contentEvent.userEventCounter++;
    }


    private function fireView(event:Event):void {
        batchContainer = [viewEvent];
        service = new HTTPServiceRequest(batchContainer, destinationURL, onSuccess, onFailed, false);
        viewEvent.removeEventListener(EventTypes.FIRE_VIEW_EVENT, fireView);
        viewEvent = null;
        batchContainer = [];
    }

    private function fireService(event:Event):void {
        batchContainer = [viewEvent, userEvent.storedEvents, contentEvent.storedEvents];
        service = new HTTPServiceRequest(batchContainer, destinationURL, onSuccess, onFailed, false);
        batchContainer = [];
    }

    private function onSuccess(event:ResultEvent):void {
        trace("success");
    }

    private function onFailed(event:FaultEvent):void {
        trace("fail");
    }
}
}