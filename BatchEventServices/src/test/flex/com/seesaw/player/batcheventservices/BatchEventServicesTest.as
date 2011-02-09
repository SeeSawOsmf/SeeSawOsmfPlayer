/**
 * Created by IntelliJ IDEA.
 * User: bmeade
 * Date: 08/02/11
 * Time: 15:52
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.batcheventservices{
import org.flexunit.assertThat;
import org.hamcrest.object.notNullValue;
import org.osmf.media.MediaElement;

public class BatchEventServicesTest {

    private var testMediaElement:MediaElement = new MediaElement();
    private var batchEvent:BatchEventServices;


    [Test (expects="ArgumentError")]
    public function TestConstructor() {
       batchEvent =  BatchEventServicesCase();
       assertThat(batchEvent, notNullValue());

        batchEvent.proxiedElement =  testMediaElement;
    }

    private function BatchEventServicesCase():BatchEventServices {
        return new  BatchEventServices();
    }

    [After]
   public function TestProxy():void {
     /////  assertThat(batchEvent.proxiedElement, notNullValue());     Wait to add a mockMediaElement..
    }

}

}