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
import com.seesaw.player.ads.AdMetadata;

import org.flexunit.assertThat;
import org.hamcrest.object.equalTo;
import org.osmf.traits.MediaTraitType;
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class ScrubPreventionProxyTest {

    private var timeTrait:TimeTrait;
    private var media:MockMediaElement;
    private var adMetadata:AdMetadata;
    private var seekTrait:SeekTrait;
    private var scrubPrevention:ScrubPreventionProxy;

    [Before]
    public function runBeforeEveryTest():void {
        media = new MockMediaElement();
        timeTrait = new TimeTrait(100);
        seekTrait = new SeekTrait(timeTrait);

        media.addMockTrait(seekTrait);
        media.addMockTrait(timeTrait);

        adMetadata = new AdMetadata();
        adMetadata.adBreaks = new Vector.<AdBreak>();
        adMetadata.adBreaks.push(new AdBreak(10));
    }

    [Test]
    public function proxiesSeekTraitWhenAdMetadataAlreadyAdded():void {
        media.addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);

        scrubPrevention = new ScrubPreventionProxy(media);

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(true));
    }

    [Test]
    public function proxiesSeekTraitAfterAdMetadataAdded():void {
        scrubPrevention = new ScrubPreventionProxy(media);

        // No ad metadata set so seek trait is not proxied
        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(false));

        media.addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(true));
    }

    [Test]
    public function unProxiesSeekTraitWhenAdMetadataRemoved():void {
        scrubPrevention = new ScrubPreventionProxy(media);
        media.addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(true));

        media.removeMetadata(AdMetadata.AD_NAMESPACE);

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(false));
    }

    [Test]
    public function unProxiesSeekTraitWhenAdBreaksRemoved():void {
        scrubPrevention = new ScrubPreventionProxy(media);
        media.addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(true));

        adMetadata.adBreaks = null;

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(false));
    }

    [Test]
    public function proxiesSeekTraitWhenAdBreaksAdded():void {
        scrubPrevention = new ScrubPreventionProxy(media);
        adMetadata.adBreaks = null;
        media.addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);

        // No ad metadata set so seek trait is not proxied
        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(false));

        adMetadata.adBreaks = new Vector.<AdBreak>();
        adMetadata.adBreaks.push(new AdBreak(25));

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(true));
    }

    [Test]
    public function proxiesSeekTraitWhenTraitRemovedAndReAdded():void {
        scrubPrevention = new ScrubPreventionProxy(media);
        media.addMetadata(AdMetadata.AD_NAMESPACE, adMetadata);

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(true));

        media.mockRemoveTrait(MediaTraitType.SEEK);

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK), equalTo(null));

        media.addMockTrait(seekTrait);

        assertThat(scrubPrevention.getTrait(MediaTraitType.SEEK) is AdBreakTriggeringSeekTrait, equalTo(true));
    }
}
}