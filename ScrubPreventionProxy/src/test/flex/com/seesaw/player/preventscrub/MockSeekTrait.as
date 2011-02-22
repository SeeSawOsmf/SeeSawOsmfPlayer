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
 * Time: 14:43

 */
package com.seesaw.player.preventscrub {
import org.osmf.traits.SeekTrait;
import org.osmf.traits.TimeTrait;

public class MockSeekTrait extends SeekTrait {

    private var _finalSeekPoint:Number;

    public function MockSeekTrait(time:TimeTrait) {
        super(time);
    }

    override protected function seekingChangeEnd(time:Number):void {
        super.seekingChangeEnd(time);
        _finalSeekPoint = time;
    }

    public function get finalSeekPoint():Number {
        return _finalSeekPoint;
    }

    public function set finalSeekPoint(value:Number):void {
        _finalSeekPoint = value;
    }
}
}
