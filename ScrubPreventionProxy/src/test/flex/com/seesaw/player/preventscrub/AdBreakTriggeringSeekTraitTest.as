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

package com.seesaw.player.preventscrub {
import com.seesaw.player.ads.AdBreak;

import org.hamcrest.assertThat;
import org.hamcrest.object.equalTo;

public class AdBreakTriggeringSeekTraitTest {

    private var timeTrait:MockTimeTrait;
    private var innerSeekTrait:MockSeekTrait;
    private var adBreaks:Vector.<AdBreak>;
    private var seekTrait:AdBreakTriggeringSeekTrait;

    [Before]
    public function runBeforeEveryTest():void {
        timeTrait = new MockTimeTrait(0, 100);
        innerSeekTrait = new MockSeekTrait(timeTrait);
        adBreaks = createAdBreaks(25, 50, 75);
        seekTrait = new AdBreakTriggeringSeekTrait(timeTrait, innerSeekTrait, adBreaks);
    }

    [Test]
    public function canSeekAsNormal():void {
        assertThat(seekTrait.canSeekTo(0), equalTo(true));
        assertThat(seekTrait.canSeekTo(25), equalTo(true));
        assertThat(seekTrait.canSeekTo(50), equalTo(true));
        assertThat(seekTrait.canSeekTo(75), equalTo(true));
        assertThat(seekTrait.canSeekTo(100), equalTo(true));
    }


    [Test]
    public function testSeekTrait():void {
        timeTrait.mockDuration = 100;

        // see across all the breaks - 75s ad break is triggered
        timeTrait.mockCurrentTime = 0;
        seekTrait.seek(85);
        assertThat(innerSeekTrait.finalSeekPoint, equalTo(75));
        assertThat(adBreaks[2].seekPointAfterAdBreak, equalTo(85));
        adBreaks[2].complete = true;
        assertThat(innerSeekTrait.finalSeekPoint, equalTo(85));

        assertThat(adBreaks[2].complete, equalTo(true));
        assertThat(adBreaks[1].complete, equalTo(false));
        assertThat(adBreaks[0].complete, equalTo(false));

         // seek forward 10, but make sure no scrubPrevention is triggered
        timeTrait.mockCurrentTime = 85;
        seekTrait.seek(95);
        assertThat(innerSeekTrait.finalSeekPoint, equalTo(95));

        // seek back but not before the ad break at 50s - adBreak is triggered
        timeTrait.mockCurrentTime = 85;
        seekTrait.seek(55);
        assertThat(innerSeekTrait.finalSeekPoint, equalTo(50));

        assertThat(adBreaks[1].seekPointAfterAdBreak, equalTo(55));
        adBreaks[1].complete = true;
        assertThat(innerSeekTrait.finalSeekPoint, equalTo(55));


        assertThat(adBreaks[2].complete, equalTo(true));
        assertThat(adBreaks[1].complete, equalTo(true));
        assertThat(adBreaks[0].complete, equalTo(false));

        // seek back to 10 - no ad break is triggered
        timeTrait.mockCurrentTime = 55;
        seekTrait.seek(10);
        assertThat(innerSeekTrait.finalSeekPoint, equalTo(10));

        assertThat(adBreaks[2].complete, equalTo(true));
        assertThat(adBreaks[1].complete, equalTo(true));
        assertThat(adBreaks[0].complete, equalTo(false));

        // seek forward from 10 to 60
        timeTrait.mockCurrentTime = 10;
        seekTrait.seek(60);
        assertThat(innerSeekTrait.finalSeekPoint, equalTo(60));

        assertThat(adBreaks[2].complete, equalTo(true));
        assertThat(adBreaks[1].complete, equalTo(true));
        assertThat(adBreaks[0].complete, equalTo(false));

        // seek to exactly 25 from above - no ad break is triggered
        timeTrait.mockCurrentTime = 60;
        seekTrait.seek(25);
        assertThat(innerSeekTrait.finalSeekPoint, equalTo(25));

        assertThat(adBreaks[2].complete, equalTo(true));
        assertThat(adBreaks[1].complete, equalTo(true));
        assertThat(adBreaks[0].complete, equalTo(false));

        // seek to exactly 25 from below - ad break at 25s is triggered
        timeTrait.mockCurrentTime = 20;
        seekTrait.seek(25);
        assertThat(innerSeekTrait.finalSeekPoint, equalTo(25));
        assertThat(adBreaks[0].seekPointAfterAdBreak, equalTo(25));
        adBreaks[0].complete = true;
        assertThat(innerSeekTrait.finalSeekPoint, equalTo(25));

        assertThat(adBreaks[2].complete, equalTo(true));
        assertThat(adBreaks[1].complete, equalTo(true));
        assertThat(adBreaks[0].complete, equalTo(true));
    }

    private function createAdBreaks(...times):Vector.<AdBreak> {
        var adBreaks:Vector.<AdBreak> = new Vector.<AdBreak>;

        for (var i:int = 0; i < times.length; i++) {
            var adBreak:AdBreak = new AdBreak();
            adBreak.startTime = times[i];
            adBreaks.push(adBreak);
        }

        return adBreaks;
    }
}
}
