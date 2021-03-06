/*
 * Copyright 2011 ioko365 Ltd.  All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the
 * License athttp://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2011 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 *
 * The Initial Developer of the Original Code is ioko365 Ltd.
 * Portions created by ioko365 Ltd are Copyright (C) 2011 ioko365 Ltd
 * Incorporated. All Rights Reserved.
 */

/**
 * Created by IntelliJ IDEA.
 * User: ibhana
 * Date: 24/02/11
 * Time: 11:10
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.ioc {
import com.seesaw.player.ads.AdBreak;

import org.hamcrest.assertThat;
import org.hamcrest.object.equalTo;
import org.osmf.elements.SerialElement;
import org.osmf.media.MediaElement;
import org.osmf.traits.MediaTraitType;
import org.osmf.utils.DynamicMediaElement;
import org.osmf.utils.DynamicTimeTrait;

public class AdBreakTest {

    [Test]
    public function canShowAdBlip():void {
        var adBreak:AdBreak = new AdBreak();
        adBreak.startTimeIsPercent = false;
        adBreak.complete = false;

        // can't show ad blip at 0
        adBreak.startTime = 0;
        assertThat(adBreak.canShowBlip, equalTo(false));

        // can show ad blip as long as not completed
        adBreak.startTime = 1;
        assertThat(adBreak.canShowBlip, equalTo(true));

        // can't show ad blip when completed
        adBreak.complete = true;
        assertThat(adBreak.canShowBlip, equalTo(false));

        adBreak.startTimeIsPercent = true;
        adBreak.complete = false;

        adBreak.startTime = 0;
        assertThat(adBreak.canShowBlip, equalTo(false));

        adBreak.startTime = 1;
        assertThat(adBreak.canShowBlip, equalTo(true));

        adBreak.startTime = 99;
        assertThat(adBreak.canShowBlip, equalTo(true));

        adBreak.startTime = 100;
        assertThat(adBreak.canShowBlip, equalTo(false));
    }

    [Test]
    public function serialAdsPlayable():void {
        var adBreak:AdBreak = new AdBreak();
        adBreak.startTime = 0;
        adBreak.startTimeIsPercent = false;
        adBreak.complete = false;

        // false by default
        assertThat(adBreak.canPlayAdPlaylist, equalTo(false));

        // false with empty playlist
        adBreak.adPlaylist = new SerialElement();
        assertThat(adBreak.canPlayAdPlaylist, equalTo(false));

        adBreak.adPlaylist.addChild(createMediaElementWithDuration(5));
        adBreak.adPlaylist.addChild(createMediaElementWithDuration(11));
        adBreak.adPlaylist.addChild(createMediaElementWithDuration(12));

        assertThat(adBreak.canPlayAdPlaylist, equalTo(true));
        assertThat(adBreak.queueAdsTotal, equalTo(3));
        assertThat(adBreak.adPlaylist.numChildren, equalTo(3));
        assertThat(adBreak.queueDuration, equalTo(28));
    }

    private function createMediaElementWithDuration(duration:int):MediaElement {
        var dynamicMediaElement:DynamicMediaElement = new DynamicMediaElement(null, null, null, true);
        var dynamicTimeTrait:DynamicTimeTrait = new DynamicTimeTrait();
        dynamicTimeTrait.currentTime = 0;
        dynamicTimeTrait.duration = duration;
        dynamicMediaElement.doAddTrait(MediaTraitType.TIME, dynamicTimeTrait);
        return dynamicMediaElement;
    }

    public function AdBreakTest() {
    }
}
}
