package uk.co.vodco.osmfPlayer.logger {
import org.as3commons.logging.ILogger;
import org.as3commons.logging.ILoggerFactory;

public class TraceAndArthropodLoggerFactory  implements ILoggerFactory{
    public function TraceAndArthropodLoggerFactory(){
    }


    public function getLogger(name:String):ILogger {
        return new TraceAndArthorpodLogger(name);
        
    }
}
}