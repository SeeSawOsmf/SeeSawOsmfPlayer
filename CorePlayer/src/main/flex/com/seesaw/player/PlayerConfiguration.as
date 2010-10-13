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

package com.seesaw.player {
import org.osmf.containers.MediaContainer;
import org.osmf.media.DefaultMediaFactory;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaPlayer;
import org.osmf.media.MediaPlayerSprite;
import org.osmf.media.MediaResourceBase;

public class PlayerConfiguration {

    private var _factory:MediaFactory;
    private var _player:MediaPlayer;
    private var _container:MediaContainer;
    private var _element:MediaElement;
    private var _playerSprite:MediaPlayerSprite;

    private var _width:int;
    private var _height:int;
    private var _resource:MediaResourceBase;

    public function PlayerConfiguration(playerWidth:int, playerHeight:int, mediaResource:MediaResourceBase) {
        player = new MediaPlayer();
        container = new MediaContainer();
        container.name = "seesawContainer";
        width = playerWidth;
        height = playerHeight;
        resource = mediaResource;
    }

    public function set resource(value:MediaResourceBase):void {
        _resource = value;
        element = factory.createMediaElement(resource);
    }

    public function get resource():MediaResourceBase {
        return _resource;
    }

    public function get factory():MediaFactory {
        if (_factory == null) {
            _factory = constructFactory();
        }
        return _factory;
    }

    /**
     * Override this to construct a different factory instance.
     * @return the factory
     */
    protected function constructFactory():MediaFactory {
        return new DefaultMediaFactory();
    }

    public function get width():int {
        return _width;
    }

    public function set width(value:int):void {
        _width = value;
    }

    public function get height():int {
        return _height;
    }

    public function set height(value:int):void {
        _height = value;
    }

    public function get player():MediaPlayer {
        return _player;
    }

    public function set player(value:MediaPlayer):void {
        _player = value;
    }

    public function get container():MediaContainer {
        return _container;
    }

    public function set container(value:MediaContainer):void {
        _container = value;
    }

    public function get playerSprite():MediaPlayerSprite {
        return _playerSprite;
    }

    public function get element():MediaElement {
        return _element;
    }

    public function set element(value:MediaElement):void {
        _element = value;
    }
}
}