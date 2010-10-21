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
package com.seesaw.player.ioc {
import flash.errors.IllegalOperationError;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

public class ObjectProvider {

    public static function getInstance():ObjectProvider
    {
        instance ||= new ObjectProvider(ConstructorLock);
        return instance;
    }

    public function ObjectProvider(lock:Class = null):void {
        if (lock != ConstructorLock) {
            throw new IllegalOperationError("ObjectProvider is a singleton: use getInstance to obtain a reference.");
        }
        _objects = new Dictionary();
    }

    public function getObject(kind:Class):* {
        return _objects[getQualifiedClassName(kind)];
    }

    public function register(kind:Class, instance:*):void {
        _objects[getQualifiedClassName(kind)] = instance;
    }

    private static var instance:ObjectProvider;

    private var _objects:Dictionary;
}
}

class ConstructorLock {};