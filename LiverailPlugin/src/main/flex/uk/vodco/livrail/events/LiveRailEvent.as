package uk.vodco.livrail.events {
import flash.events.Event;

public class LiveRailEvent extends Event {
    public static const INIT_COMPLETE:String = "initComplete";
    public static const INIT_ERROR:String = "initError";
    public static const PREROLL_COMPLETE:String = "prerollComplete";
    public static const POSTROLL_COMPLETE:String = "postrollComplete";
    public static const AD_START:String = "adStart";
    public static const AD_END:String = "adEnd";
    public static const CLICK_THRU:String = "clickThru";
    public static const VOLUME_CHANGE:String = "volumeChange";
    public static const MODULE_READY:String = "moduleReady";
    public static const ADMAP_READY:String = "adMapReady";
    public static const JSON_READY:String = "jsonReady";
    public static const HEARTBEAT:String = "mediaHeartbeat";
    public static const MEDIA_COMPLETE:String = "mediaComplete";
    public static const MEDIA_READY:String = "mediaReady";
    public static const MEDIA_DISCONNECT:String = "mediaDisconnect";
    public static const MEDIA_RESTART:String = "mediaRestart";
    public static const AD_PROGRESS:String = "adProgress";
    public static const AVAILABILITIES_FAILED:String = "availabilitiesFailed";
    public static const AD_BREAK_START:String = "adBreakStart";
    public static const AD_BREAK_COMPLETE:String = "adBreakComplete";

    public var data:Object;

    public function LiveRailEvent(type:String, _data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);

        data = _data;
    }

}
}