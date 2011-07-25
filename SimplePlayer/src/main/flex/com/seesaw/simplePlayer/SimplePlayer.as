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
 *   The Initial Developer of the Original Code is ioko365 Ltd.
 *   Portions created by Arqiva Limited are Copyright (C) 2010, 2011 Arqiva Limited.
 *   Portions created by ioko365 Limited are Copyright (C) 2011 ioko365 Limited.
 *   Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe
 * 	Systems Incorporated.
 *   All Rights Reserved.
 *
 *   Contributor(s):  Adobe Systems Incorporated, Arqiva Limited
 */

package com.seesaw.simplePlayer {
import com.seesaw.player.Player;
import com.seesaw.player.namespaces.contentinfo;
import com.seesaw.player.namespaces.smil;

import flash.display.LoaderInfo;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.chrome.widgets.URLInput;

/**
 * Takes from FlashVars and overides
 *  - Title: title
 *  - Video URL: url
 *  - Picture URL: picture
 *  - Dog URL: dog
 *
 *
 */
[SWF(width=PLAYER::Width, height=PLAYER::Height, backgroundColor="#000000")]
public class SimplePlayer extends Player {
    use namespace contentinfo;
    use namespace smil;


    private var logger:ILogger = LoggerFactory.getClassLogger(SimplePlayer);


    [Embed(source="/contentInfo.xml", mimeType="application/octet-stream")]
    private static const CONTENT_INFO:Class;

    [Embed(source="/userInfo.xml", mimeType="application/octet-stream")]
    private static const USER_INFO:Class;

    [Embed(source="/videoinfo.xml", mimeType="application/octet-stream")]
    private static const VIDEO_INFO:Class;

    private var _loaderParams:Object = LoaderInfo(root.loaderInfo).parameters;

    override protected function initialisePlayer():void {

        logger.debug("Started SimplePlayer init");

        var userInfo:XML = new XML(new USER_INFO);
        var contentInfo:XML = new XML(new CONTENT_INFO);

        logger.debug(contentInfo.programmeTitle);


        if (_loaderParams.title) {
            contentInfo.programmeTitle[0] = _loaderParams.title;
        }
        if (_loaderParams.picture) {
            contentInfo.largeImageUrl[0] = _loaderParams.picture;
        }
        if (_loaderParams.dog) {
            contentInfo.dogImage[0] = _loaderParams.dog;
        }

        logger.debug("Content info enhanced");
        logger.debug(contentInfo.toXMLString());

        processUserInit(userInfo);
        processPlayerInit(contentInfo);
    }

    override protected function requestProgrammeData(videoInfoUrl:String):void {

        logger.debug("SimplePlayer providing Video Info")


        var videoInfo:XML = new XML(new VIDEO_INFO);
        if (_loaderParams.url) {
            videoInfo.smil[0].body[0].seq[0].video[0].@src = _loaderParams.url;
        }


        processVideoInit(videoInfo);
    }
}
}