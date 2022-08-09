package entities;
import anim.FrameManager;
import Data;
import entities.Entity;
import events.EventManager;
import events.GameEvent;
import Road;

/**
 * ...
 * @author 01101101
 */

class Explosion extends Entity {
	
	var size:Int;
	
	public function new (size:Int = 0) {
		super(OT.OExplosion);
		
		this.size = size;
		
		if (this.size == 1)	w = h = 64;
		else				w = h = 32;
		
		layer = Level.FX_DEPTH;
		
		colliding = false;
		sheetName = Game.SHEET_ROAD;
		loop = false;
		
		repeatFrame = 1;
	}
	
	override public function update (?ground:GroundType) {
		super.update(ground);
		
		vx *= 0.8;
		vy *= 0.8;
	}
	
	override private function getFrameName () :FrameChange {
		var s:String = currentFrameName;
		var n:Int = 0;
		
		if (repeatCount < repeatFrame) {
			repeatCount++;
			if (s == null)	s = (size == 0) ? "fxBoomLight_0" : "fxBoom_0";
			return { name:s, flipped:false };
		}
		
		repeatCount = 0;
		
		if (s != null) {
			n = Std.parseInt(s.substring(s.length - 1, s.length));
			s = s.substring(0, s.length - 1);
			
			n += 1;// Look for an n+1 animation frame
			var fi = FM.getFrameInfo(s + "" + n, Game.SHEET_SPRITES);
			if (fi == null) { // if frame name doesn't exist with n+1, revert back to 0
				if (loop)	n = 0;
				else		EM.instance.dispatchEvent(new GameEvent(GE.KILL_ENTITY, this));
			}
		}
		else {
			s = (size == 0) ? "fxBoomLight_" : "fxBoom_";
		}
		s += Std.string(n);
		
		return { name:s, flipped:false };
	}
}










