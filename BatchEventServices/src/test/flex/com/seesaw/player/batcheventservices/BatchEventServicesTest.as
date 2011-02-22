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
 * User: bmeade
 * Date: 08/02/11
 * Time: 15:52
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.batcheventservices {
import org.flexunit.assertThat;
import org.hamcrest.object.notNullValue;
import org.osmf.media.MediaElement;

public class BatchEventServicesTest {

    private var testMediaElement:MediaElement = new MediaElement();
    private var batchEvent:BatchEventServices;


    [Test (expects="ArgumentError")]
    public function TestConstructor() {
        batchEvent = BatchEventServicesCase();
        assertThat(batchEvent, notNullValue());

        batchEvent.proxiedElement = testMediaElement;
    }

    private function BatchEventServicesCase():BatchEventServices {
        return new BatchEventServices();
    }

    [After]
    public function TestProxy():void {
        /////  assertThat(batchEvent.proxiedElement, notNullValue());     Wait to add a mockMediaElement..
    }

}

}