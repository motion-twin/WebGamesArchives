package anim;
import haxe.Public;

/**
 * ...
 * @author 01101101
 */

class AnimFrame implements Public
{
	
	var name:String;
	var x:Int;
	var y:Int;
	var flipped:Bool;
	
	/**
	 * @param	n		name
	 * @param	?xPos	x
	 * @param	?yPos	y
	 * @param	?f		flipped
	 */
	function new (n:String, ?xPos:Int = 0, ?yPos:Int = 0, ?f:Bool = false) {
		name = n;
		x = xPos;
		y = yPos;
		flipped = f;
	}
	
}