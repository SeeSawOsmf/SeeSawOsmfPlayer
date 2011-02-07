/**
 * Created by IntelliJ IDEA.
 * User: bmeade
 * Date: 07/02/11
 * Time: 16:41
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.asyncproxy {
import org.osmf.elements.ProxyElement;
import org.osmf.events.LoadEvent;
import org.osmf.events.MediaElementEvent;
import org.osmf.media.MediaElement;
import org.osmf.traits.LoadState;
import org.osmf.traits.LoadTrait;
import org.osmf.traits.MediaTraitType;

public class AsyncProxy extends ProxyElement {
    public function AsyncProxy() {
        super(proxiedElement);
    }

    /**
     * Override this method to define a custom asynchronous load trait.
     **/
    protected function createAsynchLoadingProxyLoadTrait():LoadTrait {
        return new AsynchLoadingProxyLoadTrait(super.getTrait(MediaTraitType.LOAD) as LoadTrait);
    }

    // Internals
    //

    /**
     * @private
     **/
    override protected function setupTraits():void {
        super.setupTraits();

        // First, block all traits but the LOAD trait from being exposed
        // to clients.  The reason for this is that the proxied element
        // will complete its load before we're ready to expose its state
        // to the outside world, so we block all the other traits so that
        // we can expose them when we're truly ready.
        var traitsToBlock:Vector.<String> = new Vector.<String>();
        traitsToBlock.push(MediaTraitType.AUDIO);
        traitsToBlock.push(MediaTraitType.BUFFER);
        traitsToBlock.push(MediaTraitType.DISPLAY_OBJECT);
        traitsToBlock.push(MediaTraitType.DRM);
        traitsToBlock.push(MediaTraitType.DVR);
        traitsToBlock.push(MediaTraitType.DYNAMIC_STREAM);
        traitsToBlock.push(MediaTraitType.PLAY);
        traitsToBlock.push(MediaTraitType.SEEK);
        traitsToBlock.push(MediaTraitType.TIME);
        super.blockedTraits = traitsToBlock;
    }

    /**
     * @private
     **/
    override public function set proxiedElement(value:MediaElement):void {
        super.proxiedElement = value;

        if (value != null) {
            if (value.hasTrait(MediaTraitType.LOAD)) {
                processNewLoadTrait();
            }
            else {
                // Wait for the LoadTrait to be added.
                value.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
            }
        }
    }

    private function onTraitAdd(event:MediaElementEvent):void {
        if (event.traitType == MediaTraitType.LOAD) {
            proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);

            processNewLoadTrait();
        }
    }

    private function processNewLoadTrait():void {
        // Override the LoadTrait with our own custom trait, which provides
        // hooks for executing asynchronous logic in conjunction with the
        // load of the proxied element.
        var asynchLoadTrait:LoadTrait = createAsynchLoadingProxyLoadTrait();
        addTrait(MediaTraitType.LOAD, asynchLoadTrait);

        // Make sure we're informed when the custom load trait signals that
        // it's ready, so that we can unblock the other traits.
        asynchLoadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
    }

    private function onLoadStateChange(event:LoadEvent):void {
        if (event.loadState == LoadState.READY) {
            // We're now ready to expose the proxied element to the outside
            // world, so we unblock all traits.
            super.blockedTraits = new Vector.<String>();
        }
    }
}
}