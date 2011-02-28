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

package com.seesaw.player.autoresume {
import com.seesaw.player.ioc.ObjectProvider;
import com.seesaw.player.services.ResumeService;

import org.hamcrest.assertThat;
import org.hamcrest.object.equalTo;
import org.osmf.events.SeekEvent;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.SeekTrait;
import org.osmf.utils.DynamicMediaElement;
import org.osmf.utils.DynamicTimeTrait;

public class AutoResumeProxyTest {

    private var resumeService:MockResumeService = new MockResumeService();
    private var seekTime:Number;

    public function AutoResumeProxyTest() {
    }

    [Before]
    public function beforeEveryTest():void {
        ObjectProvider.getInstance().register(ResumeService, resumeService);
    }

    [Test]
    public function canSeekToResumePosition():void {
        var media:DynamicMediaElement = new DynamicMediaElement(null, null, null, true);
        var autoResumeProxy:AutoResumeProxy = new AutoResumeProxy(media);

        var timeTrait:DynamicTimeTrait = new DynamicTimeTrait();
        timeTrait.currentTime = 0;
        timeTrait.duration = 100;

        var seekTrait:SeekTrait = new SeekTrait(timeTrait);

        seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);

        media.doAddTrait(MediaTraitType.TIME, timeTrait);

        resumeService.cookieToReturn = 50;
        media.doAddTrait(MediaTraitType.SEEK, seekTrait);

        assertThat(seekTime, equalTo(50));
    }

    private function onSeekingChange(event:SeekEvent):void {
        seekTime = event.time;
    }
}
}
