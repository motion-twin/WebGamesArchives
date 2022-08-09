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

class BulletImpact extends Entity {
	
	public var direction:Int;
	
	var life:Int;
	
	public function new (dir:Int = 1) {
		super(OT.OBulletImpact);
		
		w = 32;
		h = 16;
		
		layer = Level.FX_DEPTH;
		
		vy = Game.SPEED / 4;
		
		colliding = false;
		
		direction = dir;
		
		sheetName = Game.SHEET_ROAD;
		loop = false;
		repeatCount = 1;
		
		//life = 2;
	}
	
	/*override public function update (?ground:GroundType) {
		super.update(ground);
		if (life > 0) {
			life--;
			if (life == 0)	colliding = false;
		}
	}*/
	
	override private function getFrameName () :FrameChange {
		var s:String = currentFrameName;
		var n:Int = 0;
		
		if (repeatCount > 0) {
			repeatCount--;
			if (s == null)	s = "bulletImpact0";
			return { name:s, flipped:false };
		}
		
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
			s = "bulletImpact";
		}
		s += Std.string(n);
		
		if (n == 1 || n == 2)	repeatCount = 1;
		else					repeatCount = 0;
		
		var flipped:Bool = (direction == -1) ? true : false;
		return { name:s, flipped:flipped };
	}
	
}
