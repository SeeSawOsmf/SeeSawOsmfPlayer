package uk.co.vodco.osmfPlayer.logger {

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.logging.Logger;

/**
 * An OSMF logger that feeds to commons logging
 */
public class CommonsOsmfLogger extends Logger {

    private var logger:ILogger;

    public function CommonsOsmfLogger(name:String) {
        super(name);
        logger = LoggerFactory.getLogger(name);
    }

    override public function debug(message:String, ...rest):void
    {
        logger.debug(message, rest);
    }

    override public function info(message:String, ...rest):void
    {
        logger.info(message,rest);
    }

    override public function warn(message:String, ...rest):void
    {
        logger.warn(message,rest);
    }

    override public function error(message:String, ...rest):void
    {
        logger.error(message,rest);
    }

    override public function fatal(message:String, ...rest):void
    {
        logger.fatal(message,rest);
    }
}
}
