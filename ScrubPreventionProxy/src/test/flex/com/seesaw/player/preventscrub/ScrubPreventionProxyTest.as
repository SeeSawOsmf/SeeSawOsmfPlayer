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

package com.seesaw.player.preventscrub {
import com.seesaw.player.ads.AdBreak;
import com.seesaw.player.ads.AdMetadata;

import org.flexunit.assertThat;
import org.hamcrest.object.equalTo;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.SeekTrait;

public class ScrubPreventionProxyTest {

    private var media:MockMediaElement;
    private var mockTimeTrait:MockTimeTrait;
    private var mockSeekTrait:SeekTrait;
    private var adMetadata:AdMetadata;

    private var scrubPrevention:ScrubPreventionProxy;

    [Before]
    public function init():void {
        media = new MockMediaElement();
        mockTimeTrait = new MockTimeTrait(0, 100);
        mockSeekTrait = new SeekTrait(mockTimeTrait);

        adMetadata = new AdMetadata();
        adMetadata.adBreaks = new Vector.<AdBreak>();
        adMetadata.adBreaks.push(new AdBreak(10));
    }

    [Test]
    public function proxiesSeekTraitWhenAdMetadataAlreadyAdded() {
        media.addMockTrait(mockTimeTrait);
        media.addMockTrait(mockSeekTrait);

        media.addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);

        scrubPrevention = new ScrubPreventionProxy(media);

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(true));
    }

    [Test]
    public function proxiesSeekTraitAfterAdMetadataAdded():void {
        media.addMockTrait(mockTimeTrait);
        media.addMockTrait(mockSeekTrait);

        scrubPrevention = new ScrubPreventionProxy(media);

        // No ad metadata set so seek trait is not proxied
        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(false));

        media.addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(true));
    }

    [Test]
    public function unProxiesSeekTraitWhenAdMetadataRemoved():void {
        media.addMockTrait(mockTimeTrait);
        media.addMockTrait(mockSeekTrait);

        scrubPrevention = new ScrubPreventionProxy(media);
        media.addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(true));

        media.removeMetadata(AdMetadata.AD_NAMESPACE);

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(false));
    }

    [Test]
    public function unProxiesSeekTraitWhenAdBreaksRemoved():void {
        media.addMockTrait(mockTimeTrait);
        media.addMockTrait(mockSeekTrait);

        scrubPrevention = new ScrubPreventionProxy(media);
        media.addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(true));

        adMetadata.adBreaks = null;

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(false));
    }

    [Test]
    public function proxiesSeekTraitWhenAdBreaksAdded():void {
        media.addMockTrait(mockTimeTrait);
        media.addMockTrait(mockSeekTrait);

        scrubPrevention = new ScrubPreventionProxy(media);
        adMetadata.adBreaks = null;
        media.addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);

        // No ad metadata set so seek trait is not proxied
        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(false));

        adMetadata.adBreaks = new Vector.<AdBreak>();
        adMetadata.adBreaks.push(new AdBreak(25));

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(true));
    }
}
}