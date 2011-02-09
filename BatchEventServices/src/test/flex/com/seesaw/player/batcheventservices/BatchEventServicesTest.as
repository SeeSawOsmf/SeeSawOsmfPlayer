/**
 * Created by IntelliJ IDEA.
 * User: bmeade
 * Date: 08/02/11
 * Time: 15:52
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.batcheventservices{
import org.osmf.media.MediaElement;

public class BatchEventServicesTest extends BatchEventServices {

    private var testMediaElement:MediaElement;

    [Test(expects="no resume service implementation provided")]
    public function BatchEventServicesTest() {
       super();

       proxiedElement =  testMediaElement;
    }

     [Test]
     public override function set proxiedElement(value:MediaElement):void{

    }
}

}