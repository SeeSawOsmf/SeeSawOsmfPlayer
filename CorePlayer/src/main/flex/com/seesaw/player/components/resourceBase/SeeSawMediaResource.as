/*
 * Copyright 2010 ioko365 Ltd.  All Rights Reserved.
 *
 *   The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *
 *   The Initial Developer of the Original Code is ioko365 Ltd.
 *   Portions created by ioko365 Ltd are Copyright (C) 2010 ioko365 Ltd
 *   Incorporated. All Rights Reserved.
 */


package com.seesaw.player.components.resourceBase {
import org.osmf.media.MediaResourceBase;
import org.osmf.media.URLResource;
import org.osmf.metadata.Metadata;

public class SeeSawMediaResource extends MediaResourceBase implements IMediaResourceBase {

    private static const PARTNER_ID:String = "partnerID";
    private static const DEFAULT_PARTNER_ID:String = "Seesaw";
    private static const PROGRAMME_ID:String = "programmeID";

    private static const PLAYER_NAMESPACE:String = "http://www.seesaw.com/player/";


    public function SeeSawMediaResource() {
        super();
    }

    public function newResourceBase(obj:Object, videoUrl:String = null):MediaResourceBase {


        var parameters:Object = obj;
        var partnerId:Metadata = new Metadata();
        var programmeId:Metadata = new Metadata();

        var urlResource:MediaResourceBase;

        if (parameters[PARTNER_ID] != null) {
            partnerId.addValue(PARTNER_ID, parameters[PARTNER_ID]);
        } else {
            partnerId.addValue(PARTNER_ID, DEFAULT_PARTNER_ID);
        }

        if (parameters[PROGRAMME_ID] != null) {
            programmeId.addValue(PROGRAMME_ID, parameters[PROGRAMME_ID]);

        } else {
            programmeId.addValue(PROGRAMME_ID, 999999999999999);
            ///  return  urlResource = new URLResource(VIDEO_URL);     todo this should return a fall back url. or propagate the player to fall over
        }

        urlResource = new URLResource(videoUrl);
        urlResource.addMetadataValue(PLAYER_NAMESPACE, partnerId);
        urlResource.addMetadataValue(PLAYER_NAMESPACE, programmeId);

        return urlResource;
    }

}
}