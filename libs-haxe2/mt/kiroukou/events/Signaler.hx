package mt.kiroukou.events;

/**
 * @usage
 * @:as3signal( flash.event.Event.ENTER_FRAME, monClip )  	function onFrame() {}
 * 															function onFrame(e:flash.event.Event) {}
 * 															function onFrame(s:mt.kiroukou.event.Signal) {}
 * 															function onFrame(s:mt.kiroukou.event.Signal, e:flash.event.Event) {}
 * @:signal public function clickSignal( target:Dynamic, positionX:Int, positionY:int ) {}
 *
 */

@:autoBuild(mt.kiroukou.events.macros.SignalBuilder.build()) interface Signaler {}
