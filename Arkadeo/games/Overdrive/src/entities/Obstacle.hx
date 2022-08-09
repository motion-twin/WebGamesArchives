package entities;
import Data;
import events.EventManager;
import events.GameEvent;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.SharedObjectFlushStatus;
import Road;
import utils.IntPoint;

/**
 * ...
 * @author 01101101
 */

class Obstacle extends Entity {
	
	var xTarget:Int;
	var xOrigin:Float;
	public var behaviour:Behaviour;
	var reference:Obstacle;
	var refOffset:IntPoint;
	var isAvoiding:Bool;
	public var canAvoid:Bool;
	var overheat:Int;
	public var monster:Bool;
	
	public function new (type:OT) {
		super(type);
		
		if (data.boss && Game.RAND.random(4) == 0)	version = 666;
		else										version = Game.RAND.random(data.versions);
		//else										version = Std.random(data.versions);
		
		//vy = Game.SPEED *  (1 - Game.RAND.random(5) / 10);
		vy = switch (type) {
			case OT.OSportCar:
				Game.SPEED * 0.2;
			case OT.OSons, OT.OBikeLine:
				Game.SPEED * 0.4;
			case OT.OHarley, OT.OHarleyV ,OT.OMonster :
				Game.SPEED * 0.3;
			case OT.ODelorean:
				Game.SPEED * 0.1;
			case OT.OBus, OT.OLimo:
				Game.SPEED * 0.5;
			case OT.OLightCar :
				Game.SPEED * 0.3;
			case OT.OTrio:
				Game.SPEED * 0.6;
			case OT.OTruck, OT.OTruckTwo, OT.OTruckFour, OT.OTruckSix:
				Game.SPEED * 0.45;
			case OT.OLoner:
				Game.SPEED * 0.7;
			default:
				Game.SPEED;
		}
		setOffset(new IntPoint( -Std.int(w / 2), -Std.int(w / 2)));
		
		xOrigin = 0;
		xTarget = 0;
		behaviour = Behaviour.Leader;
		refOffset = new IntPoint();
		monster = switch (type) {
			case OT.OMonster, OT.OLimo:	true;
			default:			false;
		}
		canAvoid = switch (type) {
			case OT.OMonster, OT.OLimo:	false;
			default:			true;
		}
		isAvoiding = false;
		overheat = 0;
		needGroundType = true;
	}
	
	public function setOrigin (x:Float) {
		xOrigin = x;
		if (behaviour != Behaviour.Crosser)	xTarget = Std.int(xOrigin + Game.rand(10, 30, true));
	}
	
	public function setBehaviour (b:Behaviour, ?r:Obstacle, ?ro:IntPoint) {
		behaviour = b;
		if (r != null)	reference = r;
		if (ro != null)	refOffset = ro.clone();
	}
	
	public function avoid (x:Float) {
		if (!canAvoid || isAvoiding)	return;
		xTarget = Std.int(x);
		xOrigin = xTarget;
		isAvoiding = true;
		//showAnchor();
	}
	
	override public function update (?ground:GroundType) :Void {
		super.update();
		
		if (offset.x != 0 && offset.x != -Std.int(w / 2)) {
			setOffset(new IntPoint(-Std.int(w/2), -Std.int(w/2)));
		}
		
		/*if (health > 0 && ground == GroundType.Sand) {
			overheat++;
			if (overheat >= 20)	selfDestruct();
			return;
		}
		else if (ground != GroundType.Sand && overheat > 0)	overheat--;*/
		if (ground == GroundType.Sand) {
			var d = 1;
			if (x < Level.instance.roadB.width / 2)	
			xTarget += 10 * d;
			xOrigin = xTarget;
		}
		
		if (health > 0 && spinning == 0) {
			switch (behaviour) {
				case Behaviour.Leader:
					if (xTarget != 0 && Math.abs(xTarget - x) < 2)	x = xTarget;
					if ((xTarget == 0 || xTarget == x) && Game.RAND.random(8) == 0) {
						var tmpX = Std.int(xOrigin + Game.rand(5, 20, true));
						if (Level.instance.getColliding(this, Std.int(tmpX * 1.2 - x)).length == 0) {
							xTarget = tmpX;
							isAvoiding = false;
							//showAnchor(false);
						}
					}
				case Behaviour.Follower:
					if (reference != null && !isAvoiding) {
						if (Game.RAND.random(4) == 0)
							xTarget = Std.int(reference.x + refOffset.x);
						else {
							var tmpX = Std.int(reference.x + refOffset.x + Game.rand(0, 5, true));
							xTarget = tmpX;
						}
					}
				case Behaviour.Crosser:
					
			}
			if (!isAvoiding) {
				if (x < xTarget)	vx = Math.min(Game.SPEED * 0.3, (xTarget - x) * 0.1);
				else				vx = Math.max( -Game.SPEED * 0.3, (xTarget - x) * 0.1);
			} else {
				if (x < xTarget)	vx = Math.min(Game.SPEED * 0.3, (xTarget - x) * 0.3);
				else				vx = Math.max( -Game.SPEED * 0.3, (xTarget - x) * 0.3);
			}
		}
		else if (spinning == 0) vx *= 0.8;
		//vr *= 0.8;
	}
	
}

enum Behaviour {
	Leader;
	Follower;
	Crosser;
}










