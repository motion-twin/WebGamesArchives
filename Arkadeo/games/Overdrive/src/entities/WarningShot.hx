package entities;
import Data;
import events.EventManager;
import events.GameEvent;
import flash.display.BitmapData;
//import flash.filters.GlowFilter;
import Road;

/**
 * ...
 * @author 01101101
 */

class WarningShot extends Entity {
	
	static public var DURATION:Int = 30;
	
	public var shooter:Shooter;
	var shooterMoving:Bool;
	
	var direction:Int;
	var duration:Int;
	
	public function new (dir:Int, shooterMoving:Bool) {
		super(OT.OWarningShot);
		
		this.shooterMoving = shooterMoving;
		
		direction = dir;
		w = 650;
		h = 1;
		
		scaleX = direction;
		
		duration = Std.int(DURATION / Game.RATIO);
		colliding = false;
		
		useCustomBD = true;
		if (shooterMoving) {
			bmp.bitmapData = new BitmapData(w, h, false, 0xFF9999FF);
			//bmp.filters = [new GlowFilter(0x0000FF, 1, 0, 4)];
		} else {
			bmp.bitmapData = new BitmapData(w, h, false, 0xFFFF9999);
			//bmp.filters = [new GlowFilter(0xFF0000, 1, 0, 4)];
		}
		
		EM.instance.addEventListener(GE.CANCEL_SHOT, cancelShotHandler);
	}
	
	public override function destroy() {
		super.destroy();
		EM.instance.removeEventListener(GE.CANCEL_SHOT, cancelShotHandler);
	}
	
	private function cancelShotHandler (e:GameEvent) {
		#if tuning trace("cancelShotHandler"); #end
		if (e.data != null) {
			if (e.data == shooter)	
				cancel();
		} else {
			cancel();
		}
	}
	
	public function cancel () {
		if (shooter != null) shooter.cancel();
		EM.instance.dispatchEvent(new GameEvent(GE.KILL_ENTITY, this));
	}
	
	override public function setParams (p:Dynamic) {
		if (Reflect.hasField(p, "_shooter"))	shooter = Reflect.getProperty(p, "_shooter");
	}
	
	public override function update (?ground:GroundType) :Void {
		super.update();
		
		if (shooter != null) {
			x = (direction == 1) ? shooter.x + shooter.w - 32 : shooter.x + 32;
			y = shooter.y + 60;
		}
		
		if (duration > 0) {
			duration--;
			alpha = (5 + Std.random(5)) / 10;
		}
		if (duration == 0) {
			duration--;
			EM.instance.dispatchEvent(new GameEvent(GE.KILL_ENTITY, this));
			var e = new Shot(direction, shooterMoving/*, this*/);
			EM.instance.dispatchEvent(new GameEvent(GE.SPAWN_ENTITY, new SpawnData(e, { _shooter:shooter } )));
		}
	}
	
}










