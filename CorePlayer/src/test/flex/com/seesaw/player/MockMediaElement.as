package com.seesaw.player {
import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitBase;

public class MockMediaElement extends MediaElement {
    public function MockMediaElement() {
        super();
    }

    public function addSomeTrait(trait:MediaTraitBase):void {
        addTrait(trait.traitType, trait);
    }

    public function removeSomeTrait(traitType:String):void {
        removeTrait(traitType);
    }
}
}