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

package com.seesaw.player {
import org.flexunit.assertThat;
import org.hamcrest.object.notNullValue;
import org.osmf.net.StreamingURLResource;

public class SeeSawPlayerTest {

    private static const VIDEO_URL:String
            = "rtmp://cp67126.edgefcs.net/ondemand/mp4:mediapm/osmf/content/test/sample1_700kbps.f4v";

    private static const PLAYER_WIDTH:int = 600;
    private static const PLAYER_HEIGHT:int = 400;

    [Test]
    public function playerCanInitialise():void {
//        var config:PlayerConfiguration = new PlayerConfiguration(PLAYER_WIDTH, PLAYER_HEIGHT, new StreamingURLResource(VIDEO_URL));
//        var player:SeeSawPlayer = new SeeSawPlayer(config);
//        assertThat(player, notNullValue());
    }
}
}