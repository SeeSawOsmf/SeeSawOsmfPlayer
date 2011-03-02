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

package com.seesaw.player.batcheventservices.events.maps {
import mx.formatters.DateFormatter;

public class ContentEventMap {

    private static var contentEventCounter:int = 0;

    /** THe last user event that occured */
    private var userEventId:Number;

    /**The content event Id is the content viewing sequence number*/
    private var contentEventId:int;

    /** The date time the event occured according to the client clock */
    private var eventOccured:Date;

    /** This is the offset from the start the playlist presuming the content was played straight through
     * NOTE this can change for an URL if you seek passed a referenced ad and then rewind before the ad
     * That is OK */
    private var contentViewingSequenceNumber:int;

    /** In milliseconds */
    private var mainContentTimer:int;

    /** The SectionType of the item */
    private var sectionType:String;

    /** The offset of this event within the current ad break. Undefined if maincontent */
    private var currentAdBreakSequenceNumber:Number;

    /** The url of the content */
    private var contentUrl:String;

    private var isPopupInteractive:Boolean;

    private var isOverlayInteractive:Boolean;

    private var mainAssetId:String;

    /**
     * Liverail Campaign ID
     */
    private var campaignId:String;

    /**
     * The duration of this item in milli's. If not known enter -1
     */
    private var contentDuration:int;

    private var dtFrmt:DateFormatter = new DateFormatter();


    public function ContentEventMap(mainAssetId:String, contentViewingSequenceNumber:int, mainContentTimer:int, sectionType:String, contentUrl:String, isPopupInteractive:Boolean, isOverlayInteractive:Boolean, contentDuration:int, currentAdBreakSequenceNumber:Number, ueid:Number = 0, campaignId:String = null, contentEventId:int = 0) {
        dtFrmt.formatString = "DD/MM/YYYY J:NN:SS";

        this.eventOccured = new Date();

        this.contentViewingSequenceNumber = contentViewingSequenceNumber;
        this.mainContentTimer = mainContentTimer;
        this.sectionType = sectionType;
        this.contentUrl = contentUrl;
        this.isPopupInteractive = isPopupInteractive;
        this.isOverlayInteractive = isOverlayInteractive;
        this.contentDuration = contentDuration;
        this.currentAdBreakSequenceNumber = currentAdBreakSequenceNumber;
        this.campaignId = campaignId;
        this.mainAssetId = mainAssetId;
        this.userEventId = ueid;
        this.contentEventId = contentEventId;


    }

    /**
     * Set the number of user interaction.
     */
    public function setUserEventId(userId:Number):Number {
        userEventId = userId;
        return userEventId;
    }

    /**
     * Gets the number of user interaction.
     */
    public function get getUserEventId():Number {
        return userEventId;
    }

    /**
     * Gets the number of content events.
     */
    public function get getContentEventId():Number {
        return contentEventId;
    }

    /**
     * Sets the number of content events.
     */

    public function setId(id:int):int {
        contentEventId = id;
        return contentEventId;
    }

    /**
     *The date time this occured according to the client clock
     */
    public function get getEventOccured():Date {
        return eventOccured;
    }


    /**
     * The total number of content and adverts watched
     */
    public function get getContentViewingSequenceNumber():int {

        return contentViewingSequenceNumber;
    }

    /**
     * The total number of content and adverts watched
     */
    public function get getCurrentAdBreakSequenceNumber():int {
        if (sectionType == "MainContent") {
            currentAdBreakSequenceNumber = 0;
        }
        return currentAdBreakSequenceNumber;
    }

    /**
     * Total time spent watching content and adverts
     */
    public function get getMainContentTimer():int {
        return mainContentTimer;
    }

    /**
     * Returns type of content being watch. Either Adbreak or main content
     */
    public function get getSectionType():String {
        return sectionType;
    }

    public function get getContentUrl():String {
        return contentUrl;
    }

    /**
     * below two functions returns where the users has interacted with a pop-up or an overlay.
     */
    public function get getIsPopupInteractive():Boolean {
        return isPopupInteractive;
    }

    public function get getIsOverlayInteractive():Boolean {
        return isOverlayInteractive;
    }

    public function get getCampaignId():String {
        return campaignId;
    }

    public function get getContentDuration():int {
        return contentDuration;
    }

    public function get getMainAssetId():String {
        return mainAssetId;
    }
}
}