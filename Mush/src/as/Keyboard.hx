import BitArray;
import flash.events.KeyboardEvent;

/**
 * ...
 * @author de
 */

 typedef KeyHdl =
 {
	k: Int,
	proc:Int->Void,
	msg:String,
 }

class Keyboard
{
	var keyArray : BitArray;
	var lastKeyArray : BitArray;
	
	public var downHandlers : IntHash<KeyHdl>;
	public var releasedHandlers : IntHash<KeyHdl>;
	
	public dynamic function enabled() : Bool
	{
		return true;
	}
	
	public function new ()
	{
		keyArray = new BitArray();
		lastKeyArray = new BitArray();
		downHandlers = new IntHash();
		releasedHandlers = new IntHash();
	}
	
	//int codes are in flash.ui.Keyboard
	public function addDownHandler( v:Int, proc:Int->Void, msg: String )
		downHandlers.set( v, { k:v, proc:proc, msg:msg } );
	
	
	public function addReleasedHandler( v:Int, proc:Int->Void, msg: String )
		releasedHandlers.set( v, { k:v, proc:proc, msg:msg } );
	
	
	public function init( parent : flash.display.DisplayObjectContainer)
	{
		parent.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
		parent.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		return this;
	}
	
	function dispatch()
	{
		for(x in downHandlers)
			if( isDown(x.k) ) x.proc( x.k );
		
		for(x in releasedHandlers)
			if( isReleased(x.k) ) x.proc( x.k );
	}
	
	public function flush()
	{
		dispatch();
 		lastKeyArray.copy(keyArray);
	}
	
	public inline function isDown( kc )
	{
		return keyArray.get( kc );
	}
	
	function onKeyDown(e: flash.events.KeyboardEvent)
	{
		keyArray.set( e.keyCode , true );
	}
	
	function onKeyUp(e: flash.events.KeyboardEvent)
	{
		keyArray.set( e.keyCode , false);
	}
	
	public inline function wasDown(kc)
	{
		return lastKeyArray.get(kc);
	}
	
	public inline function isReleased(kc)
	{
		return wasDown( kc ) && !isDown( kc);
	}
}