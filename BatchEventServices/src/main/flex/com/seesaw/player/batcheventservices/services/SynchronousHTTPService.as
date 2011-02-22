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

package com.seesaw.player.batcheventservices.services {
import flash.external.ExternalInterface;

public class SynchronousHTTPService {
    private var _url:String = "";
    private var _async:Boolean = false;
    private var _responseText:String;
    private var _requestType:AjaxRequestType;

    public function SynchronousHTTPService(url:String) {
        this._url = url;
    }

    public function get async():Boolean {
        return this._async;
    }

    public function set async(value:Boolean):void {
        this._async = value;
    }

    public function get responseText():String {
        return this._responseText;
    }

    public function get requestType():AjaxRequestType {
        return this._requestType;
    }

    public function set requestType(value:AjaxRequestType):void {
        this._requestType = value;
    }

    public function send(data:String = null):String {
        var sendingData:String = sendingData(data);
        this._responseText = ExternalInterface.call(sendingData);
        return this._responseText;
    }

    private function sendingData(data:String = null):String {
        if (ExternalInterface.available) {
            var data:String = "function()" +
                    "{" +
                    "var xmlHttp;" +
                    "try" +
                    "{" +
                    " xmlHttp = new ActiveXObject('Msxml2.XMLHTTP');" +
                    "}" +
                    "catch(e)" +
                    "{" +
                    "try" +
                    "{" +
                    "xmlHttp=new ActiveXObject('Microsoft.XMLHTTP');" +
                    "}" +
                    "catch(oc)" +
                    "{" +
                    "xmlHttp=null;" +
                    "}" +
                    "}" +
                    "if(!xmlHttp && typeof XMLHttpRequest != 'undefined')" +
                    "{" +
                    "xmlHttp=new XMLHttpRequest();" +
                    "}" +
                    "try" +
                    "{" +
                    "xmlHttp.open('" + requestType.toString() + "','" + _url + "'," + async + ");" +
                    "xmlHttp.send(" + data + ");" +
                    "return xmlHttp.responseText;" +
                    "}" +
                    "catch(x){}" +
                    "}";
            trace(data);

            return data;
        }
        else {
            throw new Error("This browser is not supported.");
        }
    }
}
}