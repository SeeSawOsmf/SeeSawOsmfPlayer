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
package org.osmf.smil.model {
/**
 * Represents a meta tag in a SMIL document.
 */
public class SMILMetaElement extends SMILElement {
    /**
     * Constructor.
     */
    public function SMILMetaElement() {
        super(SMILElementType.META);
    }

    /**
     * The <code>base</code> attribute value if
     * found with the tag in the SMIL file.
     */
    public function get base():String {
        return _base;
    }

    public function set base(value:String):void {
        _base = value;
    }

    public function get name():String {
        return _name;
    }

    public function set name(value:String):void {
        _name = value;
    }

    public function get content():String {
        return _content;
    }

    public function set content(value:String):void {
        _content = value;
    }

    private var _base:String;
    private var _name:String;
    private var _content:String;
}
}
