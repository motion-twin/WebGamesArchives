package mt.signal;

/**
 * @usage
 * @:as3signal( flash.event.Event.ENTER_FRAME, monClip )  	function onFrame() {}
 * 															function onFrame(e:flash.event.Event) {}
 * 															function onFrame(s:mt.signal.Signal) {}
 * 															function onFrame(s:mt.signal.Signal, e:flash.event.Event) {}
 * @:signal public function clickSignal( target:Dynamic, positionX:Int, positionY:int ) {}
 *
 */

@:autoBuild(mt.signal.macros.SignalBuilder.build()) interface Signaler {}
