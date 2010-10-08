/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *   The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *
 *   The Initial Developer of the Original Code is ioko365 Ltd.
 *   Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *   Incorporated. All Rights Reserved.
 */

package com.seesaw.player {
import org.flexunit.assertThat;
import org.hamcrest.object.notNullValue;
import org.osmf.media.URLResource;

public class SeeSawPlayerTest {

    private static const VIDEO_URL:String
            = "rtmp://cp67126.edgefcs.net/ondemand/mp4:mediapm/osmf/content/test/sample1_700kbps.f4v";

    private static const PLAYER_WIDTH:int = 600;
    private static const PLAYER_HEIGHT:int = 400;

    [Test]
    public function playerCanInitialise():void {
        var player:SeeSawPlayer = new SeeSawPlayer(new URLResource(VIDEO_URL), PLAYER_WIDTH, PLAYER_HEIGHT);
        assertThat(player, notNullValue());
    }
}
}