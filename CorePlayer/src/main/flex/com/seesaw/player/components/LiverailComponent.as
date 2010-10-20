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

package com.seesaw.player.components {
import com.seesaw.player.PlayerConstants;

import org.as3commons.logging.ILogger;
import org.as3commons.logging.LoggerFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaResourceBase;
import org.osmf.media.PluginInfoResource;
import org.osmf.metadata.Metadata;

import uk.vodco.liverail.LiverailPlugin;

public class LiverailComponent implements MediaComponent {

    private var logger:ILogger = LoggerFactory.getClassLogger(LiverailComponent);

    public function get info():PluginInfoResource {
        return new PluginInfoResource(new LiverailPlugin());
    }

    public function createMediaElement(factory:MediaFactory, target:MediaElement):MediaElement {
        logger.debug("creating Liverail");

        var pluginTarget:Metadata = new Metadata();
        pluginTarget.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);
        target.addMetadata(LiverailPlugin.NS_TARGET, pluginTarget);

        factory.loadPlugin(this.info);

        var pluginSettings:Metadata = new Metadata();
        pluginSettings.addValue(PlayerConstants.ID, PlayerConstants.MAIN_CONTENT_ID);

        var resource:MediaResourceBase = new MediaResourceBase();
        resource.addMetadataValue(LiverailPlugin.NS_SETTINGS, pluginSettings);

        var pluginElement:MediaElement = factory.createMediaElement(resource);

        return pluginElement;
    }
}
}