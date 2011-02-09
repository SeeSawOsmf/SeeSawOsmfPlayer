/**
 * Created by IntelliJ IDEA.
 * User: bmeade
 * Date: 08/02/11
 * Time: 15:52
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.batcheventservices{
import com.seesaw.player.impl.services.ResumeServiceImpl;
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.services.ResumeService;

public class BatchEventServiceTest {

    [Test]
    public function BatchEventServiceTest() {
        var provider:ObjectProvider = ObjectProvider.getInstance();
        provider.register(ResumeService, new ResumeServiceImpl());


        var _resumeService = provider.getObject(ResumeService);



    }
}

}