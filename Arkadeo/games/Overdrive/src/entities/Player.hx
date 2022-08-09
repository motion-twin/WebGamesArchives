package entities;
import anim.FrameManager;
import api.AKApi;
import Data;
import entities.Entity;
import events.EventManager;
import events.GameEvent;
import flash.filters.GlowFilter;
import Game;
import mt.gx.Dice;
import mt.gx.MathEx;
import mt.gx.time.FTimer;
import Road;
import RoadEngine;
import ui.Fx;
import utils.IntPoint;

/**
 * ...
 * @author 01101101
 */

class Player extends Entity {
	
	static public var MAXIMUM_OVERDRIVE:Int = 440;
	static public var MAXIMUM_OVERHEAT:Int = 300;
	static public var BASE_OH:Int = 7;
	static public var MAX_DRAG_SAND:Int = 10;
	
	static public var instance:Player;
	
	public var overdrive:Int;
	public var isOD:Bool;
	public var overheat(default, null):Int;
	
	public var speedRatio(getSpeedRatio, null):Float;
	public var overheatRatio(getOHRatio, null):Float;
	public var overdriveRatio(getODRatio, null):Float;
	
	public var forceOH:Int;
	//public var unlockKey:UInt;
	public var grindSide:Int;
	public var dragSand:Int;
	
	public var scoreMod:Float;
	
	public function new () {
		super(OT.PlayerCar);
		
		maxHealth = 2;
		
		overdrive = 0;
		isOD = false;
		//#if tuning 
		//isOD = true;
		//#end
		overheat = MAXIMUM_OVERHEAT;
		
		scoreMod = 1;
		
		forceOH = 0;
		//unlockKey = 0;
		grindSide = 0;
		
		instance = this;
		
		setOffset(new IntPoint( -16, -16));
		
		//showAnchor();
	}
	
	override public function update (?ground:GroundType) :Void {
		super.update();
		
		var xx = Game.SIZE.width / 2 - Level.instance.container.x;
		var yy = Game.SIZE.height / 2 - Level.instance.container.y;
		
		if (overdrive >= MAXIMUM_OVERDRIVE)	overdrive = MAXIMUM_OVERDRIVE;
		if (!isOD && overdrive >= MAXIMUM_OVERDRIVE / 3) {
			if (bmp.filters.length == 0)	
				Fx.instance.text("OVERDRIVE READY", Game.COL_BLUE, 48, xx, yy - 65);
				
			var s = 5 + Std.random(10);
			bmp.filters = [new GlowFilter(Game.COL_BLUE, 0.2 + Std.random(4) / 10, s, s)];
			
		}/* else if(overdrive < MAXIMUM_OVERDRIVE / 3) {
			bmp.filters = [];
		}*/
		
		if (isOD) {
			if (!AKApi.isLowQuality()) {
				Fx.instance.ghostEyes(center.x, bottomRight.y - 8);
				if (Dice.percent(33)) Fx.instance.isOD(center.x, center.y);
			}
			overdrive -= 3;
			
			var step = 30;
			var stepTxt = -1;
			var odStep = Std.int(overdrive / 3);
			
			if (odStep == step * 3)			stepTxt = 3;
			else if (odStep == step * 2)	stepTxt = 2;
			else if (odStep == step)		stepTxt = 1;
			if (stepTxt != -1)	Fx.instance.text(Std.string(stepTxt), Game.COL_BLUE, 80, xx, yy - 40);
			
			if (overdrive <= 0) {
				stopOD();
				Fx.instance.text("0", Game.COL_BLUE, 80, xx, yy - 40);
			}
		}
		
		if ((health == 1 || ground == GroundType.Sand) && !isOD) {
			if (shakeOffset.x == 1 || shakeOffset.x == -1)	shakeOffset.x = -shakeOffset.x;
			else											shakeOffset.x = Game.RAND.random(2) * 2 - 1;
			if (health == 1)	Fx.instance.smoke(x, y - 8, 0x333333);
			if (ground == GroundType.Sand) {
				if (shakeOffset.y == 1 || shakeOffset.y == -1)	shakeOffset.y = 0;
				else											shakeOffset.y = Game.RAND.random(2) * 2 - 1;
			}
		} else {
			shakeOffset.x = shakeOffset.y = 0;
		}
		
		if (overheat < MAXIMUM_OVERHEAT) {
			overheat += 1;
			overheat = MathEx.mini(overheat, MAXIMUM_OVERHEAT);
		}
		
		if (forceOH > 0) {
			//if (!isOD)	doOverheat();
			doOverheat();
			forceOH--;
			Fx.instance.grind(x, y + 8, 0xFFCC00, grindSide);
		}
		
		if (dragSand > 0) {
			if (dragSand < MAX_DRAG_SAND) {
				var isSand = Std.is(RoadEngine.sandBM, SandBMb);
				
				if((dragSand&3)==0){
					Fx.instance.sandTex(x - 12, bottomRight.y, 1, 1, isSand);
					Fx.instance.sandTex(x + 12, bottomRight.y, -1, 1, isSand);
				}
				
				if (dragSand % 5 == 0 && isSand )
					Level.me.paintEntityDirect( "sand_" + (Std.random(4) + 1), center.x, center.y);
			}
			dragSand--;
		}
		
		//if (AKApi.getGameMode() == GM_LEAGUE) {
			var sm = 0.5;
			var col:UInt = Game.COL_RED;
			if (getScreenPos().y < Game.SIZE.height * 0.33) {
				sm = 2.0;
				col = Game.COL_GREEN;
				Fx.instance.speedLines(2);
				if (!isOD && overdrive < MAXIMUM_OVERDRIVE) {
					overdrive++;
					if (!Fx.noFx())	Fx.instance.emitDark(center.x, center.y, 1);
				}
			}
			else if (getScreenPos().y < Game.SIZE.height * 0.66) {
				sm = 1.5;
				col = Game.COL_YELLOW;
				Fx.instance.speedLines(1);
			}
			else if (getScreenPos().y < Game.SIZE.height * 0.85) {
				sm = 1.0;
				col = Game.COL_YELLOW;
			}
			if (AKApi.getGameMode() == GM_LEAGUE && scoreMod != sm) {
				scoreMod = sm;
				Fx.instance.text("x" + sm, col, Std.int(18 + 10 * sm), center.x, topLeft.y);
			}
		//}
		
		if (spinning == 0)	vx *= 0.65;//0.65
		if (Math.abs(vx) < 0.05)	vx = 0;
		if (Level.instance.endingGame) {
			if (vy >= 0)	vy = -5;
			else			vy *= 1.05;
		}
		else vy *= 0.65;//0.65
		if (Math.abs(vy) < 0.05)	vy = 0;
	}
	
	override function onCtrlUnlock () {
		super.onCtrlUnlock();
		if (grindSide != 0) {
			vx = 5 * -grindSide;
		}
		grindSide = 0;
	}
	
	override public function loseControl (duration:Int) {
		if (isOD)	duration = Std.int(duration * 0.5);
		super.loseControl(duration);
	}
	
	public function hit () {
		if (protection > 0 || isOD)	return;
		health--;
		protection = 30;
		
		Fx.instance.smokeExplosion(center.x, center.y);
		Fx.instance.paint(center.x, center.y);
		
		var e = new Explosion(1);
		e.x = center.x - e.w / 2;
		e.y = center.y - e.h / 2;
		e.vx = vx;
		e.vy = vy;
		var sd = new SpawnData(e, { _adaptY:false } );
		EM.instance.dispatchEvent(new GameEvent(GE.SPAWN_ENTITY, sd));
		
		if (health == 0) {
			ctrlLock = 99999;
			protection = 99999;
			FTimer.delay(gameOver, 30);
			for (i in 1...4)	FTimer.delay(explode, 7 * i);
		}
	}
	
	function explode () {
		var e = new Explosion(1);
		e.x = center.x - e.w / 2 + Game.randStd(5, 25, true);
		e.y = center.y - e.h / 2 + Game.randStd(5, 25, true);
		e.vx = vx;
		e.vy = vy;
		var sd = new SpawnData(e, { _adaptY:false } );
		EM.instance.dispatchEvent(new GameEvent(GE.SPAWN_ENTITY, sd));
	}
	
	function gameOver () {
		//trace(Game.DBGCNT / Game.DBGTCK);
		Level.instance.gameIsOver = true;
		//trace(Game.STACK);
		AKApi.gameOver(false);
	}
	
	public function heal () {
		if (health > 1)	return;
		health++;
		Fx.instance.heal(center.x, center.y);
	}
	
	public function doOverheat (amount:Int = -1) {
		//if (isOD)	return;
		if (amount == -1)	amount = BASE_OH + 1;//to cancel the +1 in update
		overheat -= amount;
		overheat = MathEx.maxi(overheat, 0);
		if (overheat == 0) {
			//trace("MAXIMUM_OVERHEAT");
			overheat = MAXIMUM_OVERHEAT;
			if (!isOD) {
				hit();
				if (grindSide != 0) {
					vx = 10 * -grindSide;
				}
				grindSide = 0;
			}
			else stopOD();
		}
	}
	
	public function doGrind (duration:Int, side:Int) {
		//doOverheat(BASE_OH * 3);// Initial shock
		ctrlLock = duration;
		grindSide = side;
		if (protection == 0)	forceOH = duration;
		//if (side == -1)	unlockKey = K.RIGHT;
		//else			unlockKey = K.LEFT;
	}
	
	public function startOD (?force:Bool = false) {
		if (!force && overdrive < MAXIMUM_OVERDRIVE / 3)	return;
		bmp.filters = [];
		isOD = true;
		var xx = Game.SIZE.width / 2 - Level.instance.container.x;
		var yy = Game.SIZE.height / 2 - Level.instance.container.y;
		if (overdrive == MAXIMUM_OVERDRIVE)
			Fx.instance.text("MAXIMUM", Game.COL_BLUE, 130, xx, yy - 110);
		Fx.instance.text("OVERDRIVE", Game.COL_BLUE, 120, xx, yy);
		Fx.instance.nova(center.x, center.y);
		//if (health < maxHealth)	health = maxHealth;
	}
	
	function stopOD () {
		//#if tuning 
		//	return;
		//#end
		
		isOD = false;
		overdrive = 0;
		//Game.RATIO -= 0.5;
		//Game.SPEED = Std.int(Game.BASE_SPEED * Game.RATIO);
	}
	
	override private function getFrameName () :FrameChange {
		var ss = "car0_";
		if (health <= 1)	ss = "car1_";
		if (isOD)	ss = "ghost0_";
		
		var s = "";
		var r = MathEx.ratio(vx, 0, Game.SPEED * 0.5);
		var f = r > 0;
		if (!isOD)	r = Math.round(r * data.sideFrames);
		else		r = Math.round(r * data.sideFrames);
		if (Math.abs(r) > 0) {
			r = Math.abs(r) - 1;
			//s = Std.string(AnimState.Side).toLowerCase();
			s = "side";
			//#if !standalone
			//s = s.substring(0, s.length - 1);
			//#end
			s += Math.abs(r);
			
			//if (isOD)	trace(r + " / " + f + " / " + data.sideFrames + " / " + data.flippable);
			
			// If not flippable
			if (!data.flippable) {
				if (type == OT.Bike || type == OT.OHarley)	s += (f) ? "_l" : "_r";
				else										s += (f) ? "_r" : "_l";
			}
		}
		else {
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
					var fi = FM.getFrameInfo(ss + os + n, Game.SHEET_SPRITES);
					if (fi == null) { // if frame name doesn't exist with n+1, revert back to 0
						n = 0;
					}
				}
				else n = 0;
			}
			s += Std.string(n);
		}
		s = ss + s;
		
		if (!isOD)	return { name:s, flipped:false };
		else		return { name:s, flipped:f };
	}
	
	override function getData () :AnimData {
		if (!isOD)	return Data.vehicles.get(Std.string(type));
		else		return Data.vehicles.get(Std.string(OT.Ghost));
	}
	
	function getSpeedRatio () :Float {
		//var r = MathEx.ratio(vy, -Std.int(Game.SPEED * 0.5), Std.int(Game.SPEED * 0.5));
		var r = MathEx.ratio(vy / 0.65, 0, Std.int(Game.SPEED * 0.5));
		return r;
	}
	
	function getOHRatio () :Float {
		return (1 - MathEx.ratio(overheat, 0, MAXIMUM_OVERHEAT));
	}
	
	function getODRatio () :Float {
		return MathEx.ratio(overdrive, 0, MAXIMUM_OVERDRIVE);
	}
	
}










