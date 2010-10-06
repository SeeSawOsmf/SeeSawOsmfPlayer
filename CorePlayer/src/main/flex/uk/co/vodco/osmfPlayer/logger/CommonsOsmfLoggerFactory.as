package uk.co.vodco.osmfPlayer.logger {
import org.osmf.logging.Logger;
import org.osmf.logging.LoggerFactory;

public class CommonsOsmfLoggerFactory extends LoggerFactory {
    public function CommonsOsmfLoggerFactory() {

    }

    override public function getLogger(category:String):Logger {
        return new CommonsOsmfLogger(category);
    }
}
}