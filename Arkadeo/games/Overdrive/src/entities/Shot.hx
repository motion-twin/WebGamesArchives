package entities;
import api.AKApi;
import Data;
import events.EventManager;
import events.GameEvent;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.events.Event;
import mt.gx.MathEx;
import ui.Fx;
//import flash.filters.GlowFilter;
import Road;

/**
 * ...
 * @author 01101101
 */

class Shot extends Entity {
	
	static public var DURATION:Int = 50;
	
	public var shooter:Shooter;
	var shooterMoving:Bool;
	//var warningShot:WarningShot;
	
	public var direction:Int;
	var duration:Int;
	var maxDuration:Int;
	
	public function new (dir:Int, shooterMoving:Bool/*, warningShot:WarningShot*/) {
		super(OT.OShot);
		
		this.shooterMoving = shooterMoving;
		//this.warningShot = warningShot;
		
		direction = dir;
		w = 600;
		h = 1;
		//baseColor = color = 0xFFFFFF;
		
		//colliding = false;
		
		//scaleX = dir;
		scaleX = 0;
		duration = maxDuration = Std.int(DURATION / Game.RATIO);
		
		useCustomBD = true;
		//bmp.bitmapData = new BitmapData(w, h, true, 0x00FF00FF);
		/*if (shooterMoving) {
			bmp.bitmapData = new BitmapData(w, h, false, 0xFF9999FF);
			//bmp.filters = [new GlowFilter(0x0000FF, 1, 0, 4)];
		} else {
			bmp.bitmapData = new BitmapData(w, h, false, 0xFFFF9999);
			//bmp.filters = [new GlowFilter(0xFF0000, 1, 0, 4)];
		}*/
		
		EM.instance.addEventListener(GE.CANCEL_SHOT, cancelShotHandler);
	}
	
	private function cancelShotHandler (e:GameEvent) {
		if (e.data != null) {
			if (e.data == shooter)	cancel();
		} else {
			cancel();
		}
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
			shooter.setIsShooting();
			duration--;
			alpha = (5 + Std.random(5)) / 10;
			
			var r = 1 - MathEx.ratio(duration, 0, maxDuration);
			scaleX = r * direction;
			
			if (duration % 2 == 0) {
				var tx = x + w * r * direction;
				var e = new BulletImpact(direction);
				e.x = tx - e.w / 2;
				e.y = y - e.h / 2 + (Std.random(2) * 2 - 1) * 2;
				var sd = new SpawnData(e, { _adaptY:false } );
				EM.instance.dispatchEvent(new GameEvent(GE.SPAWN_ENTITY, sd));
				Level.me.paintEntityMul( "bulletHole" + Std.random(6), tx, y );
				//Fx.instance.bulletSmoke(tx, y);
				if (direction == 1)	Fx.instance.bulletTrail(x, y, w * r, direction);
				else				Fx.instance.bulletTrail(tx, y, w * r, direction);
			}
		}
		
		if (duration == 0) {
			if (shooter != null) {
				shooter.setIsShooting(false);
				//shooter.yTarget = shooter.yEndTarget;
			}
			//EM.instance.dispatchEvent(new GameEvent(GE.KILL_ENTITY, warningShot));
			EM.instance.dispatchEvent(new GameEvent(GE.KILL_ENTITY, this));
		}
	}
	
	public function cancel () {
		duration = 2;
		colliding = false;
		
		if (shooter != null) shooter.cancel();
	}
	
	override public function getKeys (xOffset:Int = 0, yOffset:Int = 0) :List<Int> {
		var l = new List<Int>();
		var cx, cy;
		
		for (i in 0...(Math.round(w / Game.GRID_SIZE))) {
			for (j in 0...(Math.ceil(h / Game.GRID_SIZE))) {
				cx = Math.round((x + xOffset) / Game.GRID_SIZE) + Math.round(i * scaleX);
				cy = Math.round((y + yOffset) / Game.GRID_SIZE) + j;
				l.add(cx | cy << Game.BIT_OFFSET);
			}
		}
		return l;
	}
	
}










