package com.seesaw.player.batchEventService.events.maps {
public class UserEventMap {

	private var culmulativeViewDuration:int;
		private var eventType:String;
		private var eventOccured:Date;
		private var userEventId:int;

    
    public function UserEventMap(culmulativeViewDuration:int,
			eventType:String, userEventCounter:int) {

            this.eventType = eventType;
			this.culmulativeViewDuration = culmulativeViewDuration;
			this.eventOccured = new Date();
			this.userEventId = userEventCounter;
    }

    		public function get getUserEventId():Number{
			return userEventId
		}


		public function get getEventOccured():Date{
			return eventOccured;
		}

		public function get getCulmulativeViewDuration():int{
			return culmulativeViewDuration;
		}

		public function get getEventType():String{
			return eventType;
		}

}
}