package ;

/**
 * Frame Timer
 * Like haxe.Timer.delay() but frame based
 *
 */

class FTimer
{
	
	public static var timer = 0;
	public static var actions = new List<{func:Void->Void,delay:Int}>();
	
	
	/**
	 * Delay
	 * @param	func	Function to call
	 * @param	delay	Delay in frames
	 */
	public static function delay(func:Void->Void,delay:Int) {
		actions.push( { func:func, delay:timer+delay } );
	}
	
	
	public static function update() {
		timer++;
		for(a in actions) {
			if(timer > a.delay) {
				a.func();
				actions.remove(a);
			}
		}
		
	}
	
	public static function clear() {
		actions.clear();
		timer = 0;
	}
	
	
}