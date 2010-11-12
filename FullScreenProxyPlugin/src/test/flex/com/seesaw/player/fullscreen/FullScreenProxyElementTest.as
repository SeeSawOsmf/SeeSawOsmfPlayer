/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *    The contents of this file are subject to the Mozilla Public License
 *    Version 1.1 (the "License"); you may not use this file except in
 *    compliance with the License. You may obtain a copy of the
 *    License athttp://www.mozilla.org/MPL/
 *
 *    Software distributed under the License is distributed on an "AS IS"
 *    basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *    License for the specific language governing rights and limitations
 *    under the License.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 *
 *    The Initial Developer of the Original Code is ioko365 Ltd.
 *    Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *    Incorporated. All Rights Reserved.
 */

package com.seesaw.player.fullscreen {
import com.seesaw.player.traits.fullscreen.FullScreenTrait;

import flash.display.Sprite;

import org.flexunit.asserts.assertNotNull;
import org.flexunit.asserts.assertTrue;
import org.osmf.media.DefaultMediaFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfoResource;

public class FullScreenProxyElementTest extends Sprite {

    [Test]
    public function testFullScreenTraitAvailable():void {
        var factory:MediaFactory = new DefaultMediaFactory();
        factory.loadPlugin(new PluginInfoResource(new MockMediaPluginInfo()));
        factory.loadPlugin(new PluginInfoResource(new FullScreenProxyPluginInfo()));

        var resource:MediaResourceBase = new MediaResourceBase();
        var element:MediaElement = factory.createMediaElement(resource);
        assertNotNull(element);

        assertTrue(element.hasTrait(FullScreenTrait.FULL_SCREEN));
    }
}
}