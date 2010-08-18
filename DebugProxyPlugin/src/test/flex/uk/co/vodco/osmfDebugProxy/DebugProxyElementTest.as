package uk.co.vodco.osmfDebugProxy {
import org.hamcrest.assertThat;
import org.hamcrest.object.notNullValue;

public class DebugProxyElementTest {
    [Test]
    public function playerCanInitialise():void {

        var debugProxy:DebugProxyElement = new DebugProxyElement();

        assertThat(debugProxy, notNullValue());

    }
}
}