package entities;
import anim.FrameManager;
import api.AKApi;
import Data;
import entities.Entity;
import entities.WarningShot;
import events.EventManager;
import events.GameEvent;
import flash.display.Bitmap;
import flash.display.BitmapData;
import Road;
import utils.IntPoint;

/**
 * ...
 * @author 01101101
 */

class Shooter extends Entity {
	
	var xTarget:Int;
	public var yTarget:Int;
	public var yEndTarget:Int;
	public var direction:Int;
	var isShooting:Bool;
	var hasShot:Bool;
	
	var moving:Bool;
	public var group:Int;
	
	var state:State;
	
	var life:Int;
	
	public function new (yy:Int, dir:Int = 0, moving:Bool = false, group:Int = 1) {
		//trace(name + " spawned");
		life = 0;
		
		super(OT.OShooter);
		
		version = 2;
		this.moving = moving;
		if (this.moving) {
			//version = 1;
			yy = 0;
		}
		
		layer = Level.HELICO_DEPTH;
		
		this.group = group;
		
		state = Coming;
		
		needGroundType = true;
		
		if (yy == 2 || yy == 10) {// triple top & bottom
			direction = 1;
		} else if (yy == 6) {// triple center
			direction = -1;
		} else {
			if (dir != 1 && dir != -1)	direction = Game.RAND.random(2) * 2 - 1;
			else						direction = dir;
		}
		if (this.moving)	direction = -1;
		xTarget = (direction == 1) ? -40 : Game.SIZE.width - w - 64;
		
		colliding = false;
		
		yTarget = (yy - 1) * Game.TILE_SIZE;
		hasShot = false;
	}
	
	override public function setAddBmp (bd:BitmapData, ?p:IntPoint) {
		super.setAddBmp(bd, p);
		if (bmpAdd != null)	bmpAdd.alpha = 0.5;
	}
	
	public function init (yt:Float) {
		yTarget += Std.int(yt);
		yEndTarget = yTarget - Game.SIZE.height;
		//trace(name + " / " + yTarget);
	}
	
	override public function update (?ground:GroundType) :Void {
		super.update(ground);
		
		life++;
		
		if (bmp.y == 1 || bmp.y == -1)		bmp.y = 0;
		else								bmp.y = Std.random(2) * 2 - 1;
		
		// x movement - Stay on edge of screen
		if (state != State.Dead) vx = (xTarget - getScreenPos().x);
		
		switch (state) {
			case Coming:
				if (Math.abs(yTarget - y) < 100) {
					if (moving && Player.instance != null && Level.instance != null && Level.instance.roadB != null) {
						var pp = Player.instance.y + Player.instance.h / 2 + Level.instance.container.y;
						if (pp < Game.SIZE.height / 3)				yTarget = -32;
						else if (pp > Game.SIZE.height / 3 * 2)		yTarget = Game.SIZE.height - 100;
						else										yTarget = Std.int(Game.SIZE.height / 2);
						yTarget = Std.int(yTarget - Level.instance.container.y);
					}
					state = Arriving;
				}
				else {
					if (y < yTarget)	vy = Math.min(Game.SPEED, (yTarget - y) * 0.2);
					else				vy = Math.max(-Game.SPEED, (yTarget - y) * 0.2);
				}
			case Arriving:
				if (y != yTarget) {
					if (Math.abs(yTarget - y) < 2)	vy = yTarget - y;
					else {
						if (y < yTarget)	vy = Math.min(Game.SPEED, (yTarget - y) * 0.2);
						else				vy = Math.max(-Game.SPEED, (yTarget - y) * 0.2);
					}
				}
				else {
					var e = new WarningShot(direction, moving);
					EM.instance.dispatchEvent(new GameEvent(GE.SPAWN_ENTITY, new SpawnData(e, { _shooter:this } )));
					state = Waiting;
				}
			case Shooting:
				if (moving) {
					if (Player.instance.y > y)	vy = 1.4 * Game.RATIO;//TODO adjust shooting duration and distance to avoid impossible situation
					else						vy = -1.4 * Game.RATIO;
				}
			case Leaving:
				if (y != yTarget) {
					if (Math.abs(yTarget - y) < 2)
					{
						vy = yTarget - y;
					}
					else {
						if (y < yTarget)	vy = Math.min(Game.SPEED, (yTarget - y) * 0.2);
						else				vy = Math.max(-Game.SPEED, (yTarget - y) * 0.2);
					}
				}
				else {
					//#if tuning trace(name + " killed -> " + life); #end
					EM.instance.dispatchEvent(new GameEvent(GE.KILL_ENTITY, this));
				}
			case Dead:
				vx = 0;
				vy = Game.SPEED;
			case Waiting:
				vy = 0;
		}
		
	}
	
	public function cancel()
	{
		yTarget = yEndTarget;
		state = Leaving;
		
		setIsShooting(false);
	}
	
	public function setIsShooting (v:Bool = true) {
		//#if tuning trace('setIsShooting ' + name + " " + v); #end
		
		if (isShooting == v)	return;
		
		isShooting = v;
		
		if (state == Waiting && v) {
			state = Shooting;
		}
		else if (state == Shooting && !v) {
			yTarget = yEndTarget;
			state = Leaving;
			//trace('no longer shooting ' + name);
		}
		else if ( !v ) {
			yTarget = yEndTarget;
			state = Leaving;
			//trace('no longer shooting ' + name);
		}
	}
	
	static public function simulateTime () :Int {
		var f = 0;
		var ty = 0;
		var tyTarget = 1220;
		while (ty < tyTarget) {
			ty += Game.SPEED;
			f++;
		}
		tyTarget -= Game.SIZE.height;
		while (ty > tyTarget) {
			ty -= Game.SPEED;
			f++;
		}
		f += Std.int((WarningShot.DURATION + Shot.DURATION) / Game.RATIO);
		return f;
	}
	
	override public function selfDestruct (time:Int = 20, dir:Int = 0) :Void {
		super.selfDestruct(time, dir);
		state = Dead;
		vx = 0;
		vy = Game.SPEED;
	}
	
	override private function getFrameName () :FrameChange {
		var ss = "hovercraft2_";
		
		var s = "";
		//s = Std.string(AnimState.Idle).toLowerCase();
		//#if !standalone
		//s = s.substring(0, s.length - 1);
		//#end
		s = "idle";
		var n = 0;
		if (currentFrameName != null) {
			var os = currentFrameName.split("_").pop();
			n = Std.parseInt(os.substring(os.length - 1, os.length));
			os = os.substring(0, os.length - 1);
			if (s == os) {
				n += 1;// Look for an n+1 animation frame
				var fi = FM.getFrameInfo(ss + os + "" + n, Game.SHEET_SPRITES);
				if (fi == null) { // if frame name doesn't exist with n+1, revert back to 0
					n = 0;
				}
			}
			else n = 0;
		}
		s += Std.string(n);
		s = ss + s;
		
		return { name:s, flipped:(direction==1) };
		
		//if (!isOD)	return { name:s, flipped:false };
		//else		return { name:s, flipped:f };
	}
	
}

private enum State {
	Coming;
	Arriving;
	Waiting;
	Shooting;
	Leaving;
	Dead;
}








