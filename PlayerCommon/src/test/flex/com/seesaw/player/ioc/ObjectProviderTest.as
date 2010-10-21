package com.seesaw.player.ioc {
import com.seesaw.player.impl.services.ResumeServiceImpl;
import com.seesaw.player.services.ResumeService;

import org.flexunit.assertThat;
import org.hamcrest.object.notNullValue;

public class ObjectProviderTest {

    [Test]
    public function canGetObjectInstance():void {
        ObjectProvider.getInstance().register(ResumeService, new ResumeServiceImpl());
        var service:ResumeService = ObjectProvider.getInstance().getObject(ResumeService) as ResumeService;
        assertThat(service, notNullValue());
    }
}
}