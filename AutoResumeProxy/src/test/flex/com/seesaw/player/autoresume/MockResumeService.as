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

package com.seesaw.player.autoresume {
import com.seesaw.player.services.ResumeService;

public class MockResumeService implements ResumeService {

    private var _cookieWritten:Number;
    private var _cookieToReturn:Number;

    public function MockResumeService() {
    }

    public function get programmeId():String {
        return null;
    }

    public function set programmeId(value:String):void {
    }

    public function getResumeCookie():Number {
        return cookieToReturn;
    }

    public function writeResumeCookie(currentTime:Number):void {
        cookieWritten = currentTime;
    }

    public function get resumable():Boolean {
        return true;
    }

    public function get cookieWritten():Number {
        return _cookieWritten;
    }

    public function set cookieWritten(value:Number):void {
        _cookieWritten = value;
    }

    public function get cookieToReturn():Number {
        return _cookieToReturn;
    }

    public function set cookieToReturn(value:Number):void {
        _cookieToReturn = value;
    }

    public function getEncryptedValue(value:String):String {
        return null;
    }

    public function getDecryptedValue(value:String):String {
        return null;
    }
}
}