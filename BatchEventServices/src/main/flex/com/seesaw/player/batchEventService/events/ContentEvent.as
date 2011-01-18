package com.seesaw.player.batchEventService.events {

public class ContentEvent {

    private var _isPopupInteractive:Boolean;
    private var _mainAssetId:int;
    private var _eventOccured:Date
    private var _isOverlayInteractive:Boolean;
    private var _contentViewingSequenceNumber:int;
    private var _contentEventId:int;
    private var _campaignId:int;
    private var _mainContentTimer:int; //I think this is cumulative duration count
    private var _userEventId:int;
    private var _contentDuration:int;
    private var _sectionType:String;
    private var _currentAdBreakSequenceNumber:int;
    private var _contentUrl:String;

    public function ContentEvent(isPopupInteractive:Boolean, mainAssetId:int, eventOccured:Date, isOverlayInteractive:Boolean, contentViewingSequenceNumber:int, contentEventId:int, campaignId:int, mainContentTimer:int, userEventId:int, contentDuration:int, sectionType:String, currentAdBreakSequenceNumber:int, contentUrl:String) {
        _isPopupInteractive = isPopupInteractive;
        _mainAssetId = mainAssetId;
        _eventOccured = eventOccured;
        _isOverlayInteractive = isOverlayInteractive;
        _contentViewingSequenceNumber = contentViewingSequenceNumber;
        _contentEventId = contentEventId;
        _campaignId = campaignId;
        _mainContentTimer = mainContentTimer;
        _userEventId = userEventId;
        _contentDuration = contentDuration;
        _sectionType = sectionType;
        _currentAdBreakSequenceNumber = currentAdBreakSequenceNumber;
        _contentUrl = contentUrl;
    }

    public function get isPopupInteractive():Boolean {
        return _isPopupInteractive;
    }

    public function set isPopupInteractive(value:Boolean):void {
        _isPopupInteractive = value;
    }

    public function get mainAssetId():int {
        return _mainAssetId;
    }

    public function set mainAssetId(value:int):void {
        _mainAssetId = value;
    }

    public function get eventOccured():Date {
        return _eventOccured;
    }

    public function set eventOccured(value:Date):void {
        _eventOccured = value;
    }

    public function get isOverlayInteractive():Boolean {
        return _isOverlayInteractive;
    }

    public function set isOverlayInteractive(value:Boolean):void {
        _isOverlayInteractive = value;
    }

    public function get contentViewingSequenceNumber():int {
        return _contentViewingSequenceNumber;
    }

    public function set contentViewingSequenceNumber(value:int):void {
        _contentViewingSequenceNumber = value;
    }

    public function get contentEventId():int {
        return _contentEventId;
    }

    public function set contentEventId(value:int):void {
        _contentEventId = value;
    }

    public function get campaignId():int {
        return _campaignId;
    }

    public function set campaignId(value:int):void {
        _campaignId = value;
    }

    public function get mainContentTimer():int {
        return _mainContentTimer;
    }

    public function set mainContentTimer(value:int):void {
        _mainContentTimer = value;
    }

    public function get userEventId():int {
        return _userEventId;
    }

    public function set userEventId(value:int):void {
        _userEventId = value;
    }

    public function get contentDuration():int {
        return _contentDuration;
    }

    public function set contentDuration(value:int):void {
        _contentDuration = value;
    }

    public function get sectionType():String {
        return _sectionType;
    }

    public function set sectionType(value:String):void {
        _sectionType = value;
    }

    public function get currentAdBreakSequenceNumber():int {
        return _currentAdBreakSequenceNumber;
    }

    public function set currentAdBreakSequenceNumber(value:int):void {
        _currentAdBreakSequenceNumber = value;
    }

    public function get contentUrl():String {
        return _contentUrl;
    }

    public function set contentUrl(value:String):void {
        _contentUrl = value;
    }

    public function get getIsPopupInteractive():Boolean {
        return isPopupInteractive;
    }

    public function get getMainAssetId():int {
        return mainAssetId;
    }

    public function get getEventOccured():Date {
        return new Date();
    }

    public function get getIsOverlayInteractive():Boolean {
        return isOverlayInteractive;
    }

    public function get getContentViewingSequenceNumber():int {
        return contentViewingSequenceNumber;
    }

    public function get getContentEventId():int {
        return contentEventId;
    }

    public function get getCampaignId():int {
        return campaignId;
    }

    public function get getMainContentTimer():int {
        return mainContentTimer;
    }

    public function get getUserEventId():int {
        return userEventId;
    }

    public function get getContentDuration():int {
        return contentDuration;
    }

    public function get getSectionType():String {
        return sectionType;
    }

    public function get getCurrentAdBreakSequenceNumber():int {
        return currentAdBreakSequenceNumber;
    }

    public function get getContentUrl():String {
        return contentUrl;
    }
}
}