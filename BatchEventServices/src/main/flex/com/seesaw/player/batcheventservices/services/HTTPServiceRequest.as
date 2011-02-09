package com.seesaw.player.batcheventservices.services {
import com.adobe.serialization.json.JSON;

import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;

public class HTTPServiceRequest {
    
    private var _batchContainer:Object;
    private var _destinationURL:String;
    private var service:HTTPService;
    private var _successHandler:Function;
    private var _failHandler:Function;

    public function HTTPServiceRequest(batchContainer:Object, destinationURL:String, successHandler:Function, failHandler:Function, exitHandler:Boolean ) {

        if (batchContainer == null) {
            throw ArgumentError("a batchContainer is required");
        }
        
        if (destinationURL == null) {
            throw ArgumentError("a destinationURL is required");
        }

        _batchContainer = batchContainer;
        _destinationURL = destinationURL;
        _successHandler = successHandler;
        _failHandler = failHandler;
        
        sendService(exitHandler);
    }

    private function sendService(exitEvent:Boolean):void {

        var container:String = JSON.encode(_batchContainer);
		var theBatch:Object=new Object();
        
			theBatch.data=container;
        
			service = new HTTPService();

			service.url = _destinationURL;
			service.method="POST";
			service.resultFormat="text";
		
				service.addEventListener(ResultEvent.RESULT, _successHandler);
				service.addEventListener(FaultEvent.FAULT, _failHandler);



			if(exitEvent)
			{

				var paramStr:String = "";

				var url:String = _destinationURL;
				var urlParams:Array = url.split('?');
				url = urlParams[0];

				paramStr = "data="+ String(encodeURIComponent(theBatch.data));

				if(urlParams.length > 1)
				{
					paramStr = urlParams[1] + "&" + paramStr;
				}

				var syncReq:SynchronousHTTPService = new SynchronousHTTPService(_destinationURL + "?" + paramStr);
				syncReq.requestType = AjaxRequestType.POST;
				syncReq.async = false;
				syncReq.send();
			}
			else
			{
				service.send(theBatch);
			}
    }
}
}