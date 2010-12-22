package com.seesaw.player.batchEventService.events {
public class ViewEvent {
    private var viewId:int;
    private var transactionItemId:int;
    private var serverTimeStamp:int;
    private var sectionCount:int;
    private var mainAssetId:int;
    
    public function ViewEvent(viewId:int, transactionItemId:int, serverTimeStamp:int, sectionCount:int, mainAssetId:int ) {

        this.viewId = viewId;
        this.transactionItemId = transactionItemId;
     	this.serverTimeStamp = serverTimeStamp;
		this.sectionCount = sectionCount;
        this.mainAssetId = mainAssetId;
        
    }
}
}