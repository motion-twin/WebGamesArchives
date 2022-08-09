package entities;
import anim.FrameManager;
import api.AKApi;
import Data;
import entities.Entity;
import events.EventManager;
import events.GameEvent;
import mt.gx.time.FTimer;
import Road;
import ui.Fx;
import utils.IntPoint;

/**
 * ...
 * @author 01101101
 */

using Lambda;
class Dropper extends Entity {
	
	static public var X_SPEED_MOD:Float = 0.2;
	
	var direction:Int;
	var rapid:Bool;
	
	var xTarget:Float;
	var yTarget:Int;
	var yEndTarget:Int;
	
	var duration:Int;
	var key:String;
	
	var state:State;
	
	public function new (v:UInt = 0, dir:Int = 1, rapid:Bool = false) {
		super(OT.ODropper);
		
		this.direction = dir;
		this.rapid = rapid;
		
		state = Coming;
		
		version = (this.rapid) ? 0 : 1;
		
		colliding = true;
		
		duration = Std.int(100 / Game.RATIO);
		
		yTarget = -100;
		xTarget = v * Game.TILE_SIZE;
		
		if (version == 0)	repeatFrame = 2;
		else				repeatFrame = 1;
	}
	
	public function init (yt:Float, ?xStart:Float, ?xEnd:Float) {
		//x = xStart;
		//xTarget = xEnd;
		yTarget = Std.int(yt) + 20;
		yEndTarget = yTarget - h - 90;
	}
	
	override public function update (?ground:GroundType) :Void {
		if (state != Dead) {
			if (y != yTarget) {
				if (Math.abs(yTarget - y) < 2) {
					vy = yTarget - y;
				} else {
					if (state == Dropping) {
						vy = -1.5;
					} else {
						if (y < yTarget)	vy = Math.min(Game.SPEED, (yTarget - y) * 0.2);
						else				vy = Math.max( -Game.SPEED * 0.5, (yTarget - y) * 0.2);
					}
				}
			}
			else {
				vy = 0;
				switch (state) {
					case Coming:
						yTarget -= 40;
						//xTarget += x * direction;
						state = Dropping;
					case Dropping:
						if (rapid) {
							rapidDrop();
							FTimer.delay(allowDrop, Std.int(30 / Game.RATIO));
						} else {
							drop();
							if (Level.instance.level < 5)		FTimer.delay(allowDrop, Std.int(35 / Game.RATIO));
							else if (Level.instance.level < 7)	FTimer.delay(allowDrop, Std.int(25 / Game.RATIO));
							else								FTimer.delay(allowDrop, Std.int(15 / Game.RATIO));
						}
						state = Waiting;
					case Waiting:
						if (x != xTarget) {
							if (Math.abs(xTarget - x) < 2) {
								vx = xTarget - x;
							} else {
								if (x < xTarget)	vx = Math.min(Game.SPEED * X_SPEED_MOD, (xTarget - x) * 0.2);
								else				vx = Math.max( -Game.SPEED * X_SPEED_MOD, (xTarget - x) * 0.2);
							}
						}
						else {
							vx = 0;
							state = Leaving;
						}
					case Leaving:
						if (yTarget == yEndTarget) {
							EM.instance.dispatchEvent(new GameEvent(GE.KILL_ENTITY, this));
						} else {
							yTarget = yEndTarget;
						}
					default:
				}
			}
		}
		super.update();
	}
	
	function allowDrop () {
		if (state == Waiting)	state = Dropping;
	}
	
	function drop () {
		var e = new Drop();
		e.x = x + (w - e.w) / 2;
		e.y = y + h;
		if (!Fx.noFx())		Fx.instance.mineSmoke(e.x + e.w / 2, e.y + e.h / 2);
		EM.instance.dispatchEvent(new GameEvent(GE.SPAWN_ENTITY, e));
	}
	
	function rapidDrop () {
		for (i in 1...4)	FTimer.delay(drop, Std.int(4 / Game.RATIO * i));
	}
	
	override public function loseControl (duration:Int) {
		//
	}
	
	override public function selfDestruct (time:Int = 20, dir:Int = 0) :Void {
		super.selfDestruct(time, dir);
		state = Dead;
		vx = 0;
		vy = Game.SPEED;
	}
	
	static public function simulateTime (tw:Int) :Int {
		var f = 0;
		var tx = 0.0;
		while (tx < tw) {
			if (tw - tx < 2) {
				tx = tw;
			} else {
				tx += Math.min(Game.SPEED * X_SPEED_MOD, (tw - tx) * 0.2);
			}
			f++;
		}
		return f;
	}
	
	override function getFrameName () :FrameChange {
		
		var name = data.name + Std.string(version);
		
		if (repeatCount < repeatFrame) {
			repeatCount++;
			if (currentFrameName == null)	name = name + "IdleC0";
			else							name = currentFrameName;
			return { name:name, flipped:false };
		}
		else {
			repeatCount = 0;
			
			var anim = "Idle";
			if (state != Coming)	anim = "Open";
			
			var view = "C";
			if (vx > 0)			view = "R";
			else if (vx < 0)	view = "L";
			
			name = name + anim + view;
			
			var frame = 0;
			if (currentFrameName != null) {
				frame = Std.parseInt(currentFrameName.substring(currentFrameName.length - 1));
				frame++;
				var info = FM.getFrameInfo(name + Std.string(frame), Game.SHEET_SPRITES);
				if (info == null) {
					if (loop)	frame = 0;
					else {
						while (FM.getFrameInfo(name + Std.string(frame), Game.SHEET_SPRITES) == null && frame > 0)
							frame--;
					}
				}
			}
			name = name + Std.string(frame);
			//trace(name);
			return { name:name, flipped:false };
		}
	}
	
}

private enum State {
	Coming;
	Dropping;
	Waiting;
	Leaving;
	Dead;
}









