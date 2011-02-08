/**
 * Created by IntelliJ IDEA.
 * User: bmeade
 * Date: 08/02/11
 * Time: 15:52
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.batchEventService{
import com.seesaw.player.impl.services.ResumeServiceImpl;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.services.ResumeService;

import org.flexunit.assertThat;
import org.hamcrest.object.notNullValue;

public class BatchEventTest extends BatchEventService {

    [RunWith("org.flexunit.runners.Suite")]
    [Test]
    public function BatchEventTest() {
        var provider:ObjectProvider = ObjectProvider.getInstance();
        provider.register(ResumeService, new ResumeServiceImpl());


        var _resumeService = provider.getObject(ResumeService);


         if(resumeService){
            resumeService = _resumeService;
             assertThat(resumeService, notNullValue());
         }


        super();

    }
}

}