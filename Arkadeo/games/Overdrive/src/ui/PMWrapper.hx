package ui;
import mt.gx.MathEx;

/**
 * ...
 * @author 01101101
 */

class PMWrapper extends gfx.ProgressMap {
	
	public function new () {
		super();
		gotoAndStop(1);
	}
	
	public function setProgress (v:Float = 0) {
		v = MathEx.clamp(v, 0, 1);
		gotoAndStop(Std.int(totalFrames * v));
	}
	
}