/*
 * The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *   The Initial Developer of the Original Code is Arqiva Ltd.
 *   Portions created by Arqiva Limited are Copyright (C) 2010, 2011 Arqiva Limited.
 *   Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe
 * 	Systems Incorporated.
 *   All Rights Reserved.
 *
 *   Contributor(s):  Adobe Systems Incorporated
 */

/**
 * Created by IntelliJ IDEA.
 * User: ibhana
 * Date: 08/02/11
 * Time: 17:30

 */
package com.seesaw.player.preventscrub {
import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitBase;

public class MockMediaElement extends MediaElement {

    public function MockMediaElement() {
    }

    public function addMockTrait(trait:MediaTraitBase):void {
        addTrait(trait.traitType, trait);
    }

    public function mockRemoveTrait(type:String):void {
        removeTrait(type);
    }
}
}
