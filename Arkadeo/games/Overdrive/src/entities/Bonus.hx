package entities;
import anim.FrameManager;
import api.AKApi;
import api.AKProtocol;
import Data;
import events.EventManager;
import events.GameEvent;
import flash.display.BitmapData;
import flash.events.DataEvent;
import flash.geom.Point;
import mt.gx.MathEx;
import Road;
import ui.Fx;
import ui.Hint;

/**
 * ...
 * @author 01101101
 */

class Bonus extends Entity {
	
	static var BASE_DURATION:Int = 60;
	
	public var hint:Hint;
	public var variant:Int;
	public var igpt:Token;
	
	//var xTarget:Float;
	var yTarget:Float;
	var origin:Point;
	var duration:Int;
	
	public function new (type:OT, ?igpt:Token) {
		super(type);
		
		w = 48;
		h = 48;
		
		useCustomBD = true;
		bmp.bitmapData = new BitmapData(w, h, true, 0x00FF00FF);
		
		this.igpt = igpt;
		
		var fname = switch (type) {
			case OT.OArmor:	"bonus_repair";
			case OT.OKado:	"cadeau_" + this.igpt.frame;
			default:		"bonus_od";
		}
		Game.TAP.x = 8;
		Game.TAP.y = 8;
		FM.copyFrame(bmp.bitmapData, fname, Game.SHEET_ROAD, Game.TAP);
		
		bmp.filters = [ new flash.filters.GlowFilter(0xFFFFFF, 1, 4, 4, 6) ];
		
		vy = Game.SPEED;
		
		yTarget = Game.SIZE.height * 0.2 + Game.sign() * Game.RAND.random(60);
		duration = -1;
		
		EM.instance.addEventListener(GE.KILL_BONUSES, GEHandler);
	}
	
	private function GEHandler (e:GameEvent) :Void {
		if (e.data == type) {
			//trace("killed " + name);
			kill();
		}
	}
	
	public function setOrigin (p:Point) {
		origin = p.clone();
		origin.y = yTarget;
		//xTarget = origin.x;
	}
	
	override public function update (?ground:GroundType) {
		
		if (duration > 0) {
			duration--;
			if (duration < 20) {
				//alpha = duration / 10;
				visible = (Math.floor(duration / 2) % 2 == 0);
			} else {
				Fx.instance.shine(center.x, center.y, vy, duration / Std.int(BASE_DURATION * Game.RATIO));
			}
			if (duration == 0) {
				kill();
			}
		} else if (getScreenPos().y > -50 && getScreenPos().y < Game.SIZE.height) {
			Fx.instance.shine(center.x, center.y, vy);
		}
		
		if (duration == -1 && Math.abs(yTarget - getScreenPos().y) < 5) {
			vy = 0;
			duration = Std.int(BASE_DURATION * Game.RATIO);
			if (origin != null)	yTarget = origin.y + Game.RAND.random(10) * Game.sign();
		} else if (Math.abs(yTarget - getScreenPos().y) < 5) {
			if (origin != null)	yTarget = origin.y + Game.RAND.random(10) * Game.sign();
		} else {
			vy = (yTarget - getScreenPos().y) * 0.15;
			vy = Math.min(Game.SPEED, vy);
		}
		
		/*if (origin != null) {
			if (Math.abs(xTarget - getScreenPos().x) < 5) {
				xTarget = origin.x + Game.RAND.random(10) * Game.sign();
			} else {
				vx = (xTarget - getScreenPos().x) * 0.15;
				vx = Math.min(Game.SPEED, vx);
			}
		}*/
		
		super.update(ground);
		
		if (hint != null)	hint.update();
		
		if (getScreenPos().y > 0 && hint != null) {
			hint.alpha *= 0.9;
			if (hint.alpha < 0.1) {
				if (hint.parent != null)	hint.parent.removeChild(hint);
				Level.instance.hints.remove(hint);
				hint = null;
			}
		}
	}
	
	public function use (?player:Player) {
		// Apply effect
		switch (type) {
			case OT.OArmor:
				player.heal();
			case OT.OOverdrive:
				if (!player.isOD) {
					player.overdrive += Std.int(Player.MAXIMUM_OVERDRIVE / 3);
					if (player.overdrive < Player.MAXIMUM_OVERDRIVE) {
						var xx = Game.SIZE.width / 2 - Level.instance.container.x;
						var yy = Game.SIZE.height / 2 - Level.instance.container.y - 24;
						Fx.instance.text(Std.string(Std.int(player.overdriveRatio * 100)) + "% OVERDRIVE", Game.COL_BLUE, 60, xx, yy);
					}
				}
			case OT.OKado:
				AKApi.takePrizeTokens(igpt);
				if (igpt.frame == 1)		Fx.instance.heal(center.x, center.y, 0xCCFFCC, 0x80FF80);
				else if (igpt.frame == 2)	Fx.instance.heal(center.x, center.y, 0xFFD8CC, 0xFFD880);
				else if (igpt.frame == 3)	Fx.instance.heal(center.x, center.y, 0xCCFFFF, 0x80FFFF);
				else if (igpt.frame == 4)	Fx.instance.heal(center.x, center.y, 0xFFCCFF, 0xFF80FF);
			default:
				//trace("no effect for " + type);
		}
		// Kill all others
		if (type != OT.OKado) {
			EM.instance.removeEventListener(GE.KILL_BONUSES, GEHandler);
			EM.instance.dispatchEvent(new GameEvent(GE.KILL_BONUSES, type));
		}
		// Kill
		kill();
	}
	
	function kill () {
		// Remove hint
		if (hint != null && hint.parent != null)	hint.parent.removeChild(hint);
		Level.instance.hints.remove(hint);
		hint = null;
		// Kill entity
		EM.instance.dispatchEvent(new GameEvent(GE.KILL_ENTITY, this));
	}
	
}

typedef Token = SecureInGamePrizeTokens;






