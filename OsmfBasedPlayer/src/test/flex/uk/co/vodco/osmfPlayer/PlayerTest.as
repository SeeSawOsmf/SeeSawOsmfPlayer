package uk.co.vodco.osmfPlayer {
import org.flexunit.assertThat;
import org.hamcrest.object.notNullValue;

public class PlayerTest
{
    [Test]
    public function playerCanInitialise():void{

        var player:Player = new Player();

        assertThat(player,notNullValue());

    }

    
}
}