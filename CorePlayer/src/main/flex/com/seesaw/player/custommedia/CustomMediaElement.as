package com.seesaw.player.custommedia {
import flash.utils.Dictionary;

import org.osmf.events.MediaElementEvent;
import org.osmf.events.MediaErrorEvent;
import org.osmf.media.MediaElement;
import org.osmf.media.MediaResourceBase;
import org.osmf.traits.MediaTraitBase;
import org.osmf.utils.OSMFStrings;

public class CustomMediaElement extends MediaElement {
    public function CustomMediaElement() {
        super();
    }

    override protected function addTrait(type:String, instance:MediaTraitBase):void {
        if (type == null || instance == null || type != instance.traitType) {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
        }

        // If there's a trait resolver for this type, then add the trait
        // to the resolver:
        var traitResolver:CustomMediaTraitResolver = traitResolvers[type];
        if (traitResolver != null) {
            traitResolver.addTrait(instance);
        }
        else {
            setLocalTrait(type, instance);
        }
    }

    private function setLocalTrait(type:String, instance:MediaTraitBase):MediaTraitBase {
        var result:MediaTraitBase = traits[type];
        if (instance == null) {
            // We're processing a trait removal:
            if (result != null) {
                // Stop listening for errors:
                result.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);

                // Dispose of any resources:
                result.dispose();

                // Signal removal is about to occur:
                dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_REMOVE, false, false, type));

                _traitTypes.splice(_traitTypes.indexOf(type), 1);
                delete traits[type];
            }
        }
        else {
            // We're processing a trait addition:
            if (result == null) {
                traits[type] = result = instance;
                _traitTypes.push(type);

                // Listen for errors:
                result.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);

                // Signal addition:
                dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_ADD, false, false, type));
            }
            else if (result != instance) {
                throw new ArgumentError(OSMFStrings.getString(OSMFStrings.TRAIT_INSTANCE_ALREADY_ADDED));
            }
        }

        return result;
    }

    private function onMediaError(event:MediaErrorEvent):void {
        dispatchEvent(event.clone());
    }

    override public function get resource():MediaResourceBase {
        return _resource;
    }

    override public function set resource(value:MediaResourceBase):void {
        _resource = value;
    }

    private var _traitTypes:Vector.<String> = new Vector.<String>();
    private var traits:Dictionary = new Dictionary();
    private var traitResolvers:Dictionary = new Dictionary();

    private var _resource:MediaResourceBase;
}
}