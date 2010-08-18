package uk.co.vodco.osmfPlayer.logger {
import com.carlcalderon.arthropod.Debug;

import org.as3commons.logging.LogLevel;
import org.as3commons.logging.impl.AbstractLogger;
import org.as3commons.logging.util.MessageUtil;

/**
 * A commons logging logger that traces and feeds to Arthopod
 */
public class TraceAndArthorpodLogger extends AbstractLogger {
    public function TraceAndArthorpodLogger(name:String) {

        super(name);

    }

    private var _level:int;


    public function set level(value:int):void {
        _level = value;
    }

    override protected function log(level:uint, message:String, params:Array):void {
        if (level >= this._level) {
            //var message:String = "";

            var msg:String = "";

            // add datetime
            msg += (new Date()).toString() + " " + LogLevel.toString(level) + " - ";

            // add name and params
            msg += name + " - " + MessageUtil.toString(message, params);

            // trace the message
            trace(msg);

            // And to Arthorpod
            switch (level) {
                case LogLevel.ERROR:
                    Debug.error(msg);
                    break;

                case LogLevel.WARN:
                    Debug.warning(msg);
                    break;

                default:
                    Debug.log(msg);
            }
        }
    }

    /**
     * @inheritDoc
     */
    override public function get debugEnabled():Boolean {
        return (_level <= LogLevel.DEBUG);
    }

    /**
     * @inheritDoc
     */
    override public function get infoEnabled():Boolean {
        return (_level <= LogLevel.INFO);
    }

    /**
     * @inheritDoc
     */
    override public function get warnEnabled():Boolean {
        return (_level <= LogLevel.WARN);
    }

    /**
     * @inheritDoc
     */
    override public function get errorEnabled():Boolean {
        return (_level <= LogLevel.ERROR);
    }

    /**
     * @inheritDoc
     */
    override public function get fatalEnabled():Boolean {
        return (_level <= LogLevel.FATAL);
    }
}
}