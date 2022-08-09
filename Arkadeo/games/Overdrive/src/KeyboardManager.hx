package ;
import flash.display.Stage;
import flash.events.KeyboardEvent;

/**
 * ...
 * @author 01101101
 */

typedef CBObject = {
	var param:Dynamic;
	var call:Dynamic;
	var once:Bool;
}

class KeyboardManager
{
	
	private static var stage:Stage;
	private static var keys:Hash<Bool>;
	private static var callbacks:Hash<CBObject>;
	
	public function new () { }
	
	static public function init (s:Stage) :Void {
		stage = s;
		keys = new Hash<Bool>();
		callbacks = new Hash<CBObject>();
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
	}
	
	private static function keyDownHandler (e:KeyboardEvent) :Void {
		var k:String = Std.string(e.keyCode);
		// Check for callback
		if (callbacks.exists(k)) {
			var o:CBObject = callbacks.get(k);
			// Call it
			if (o.param != null)	o.call(o.param);
			else						o.call();
			// Delete callback once fired (if needed)
			if (o.once)	deleteCallback(e.keyCode);
		}
		// Store the key state
		keys.set(k, true);
	}
	
	private static function keyUpHandler (e:KeyboardEvent) :Void {
		var k:String = Std.string(e.keyCode);
		keys.remove(k);
	}
	
	static public function isDown (kc:Int) :Bool {
		var k:String = Std.string(kc);
		return keys.get(k);
	}
	
	/**
	 * @param	kc			keycode
	 * @param	cb			callback
	 * @param	?p		callback param
	 * @param	f	fire once only
	 */
	static public function setCallback (kc:Int, cb:Dynamic, ?p:Dynamic, f:Bool = false) :Void {
		var o:CBObject = { call:cb, param:p, once:f };
		// Store the callback
		var k:String = Std.string(kc);
		callbacks.set(k, o);
	}
	
	static public function deleteCallback (kc:Int) :Void {
		// Delete the callback
		var k:String = Std.string(kc);
		callbacks.remove(k);
	}

}