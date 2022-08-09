package anim;
import haxe.Public;

/**
 * ...
 * @author 01101101
 */

class Animation implements Public
{
	
	var name:String;
	var spritesheet:String;
	var frames (default, null):Array<AnimFrame>;
	var fps:Int;
	var looping:Bool;
	
	/**
	 * @param	n	name
	 * @param	?s	spritesheet
	 */
	function new (n:String, ?s:String) {
		name = n;
		spritesheet = s;
		frames = new Array<AnimFrame>();
		fps = 12;
		looping = false;
	}
	
	function addFrame (f:AnimFrame) :Void {
		frames.push(f);
	}
	
}