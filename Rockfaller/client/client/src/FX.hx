package ;

import manager.SpecialManager;
import mt.deepnight.HParticle;
import mt.deepnight.slb.HSprite;
import mt.deepnight.slb.HSpriteBE;
import mt.gx.Dice;

import Common;

import process.Game;
import data.Settings;
import manager.SoundManager;

/**
 * ...
 * @author Tipyx
 */
class FX
{
	public static var TIME_END_MESSAGE		: Float			= 1.5;
	
	public static function FALL_PRTCL_ROCK() {
		var x = Std.random(Settings.STAGE_WIDTH);
		
		for (i in 0...mt.deepnight.Lib.irnd(3, 5)) {
			var part = mt.deepnight.HParticle.allocFromPool(Game.ME.poolOverGridFX, Settings.SLB_FX.getTile("mudPart" + ["Big", "Medium", "Small"][Std.random(3)]));
			part.setPos(Std.int(x + Std.random(Std.int(Settings.STAGE_SCALE * 200))),
						Std.int( -part.width));
			//part.dy = 5;
			part.gy = mt.deepnight.Lib.rnd(1, 3) * Settings.STAGE_SCALE;
			part.rotation = Std.random(314) / 100;
			part.life = 10 * Settings.FPS;
			part.scaleX = part.scaleY = Settings.STAGE_SCALE;
			part.onUpdate = function() {
				if (part.y > Settings.STAGE_HEIGHT)
					part.kill();
			}
		}
	}
	
	static function CLOUD_PATTERN(p:{arCloud:Array<HParticle>, cX:Float, cY:Float, z:Int}) {
		var rnd = mt.deepnight.Lib.rnd;
		var irnd = mt.deepnight.Lib.irnd;
		
		var part = HParticle.allocFromPool(Game.ME.poolPattern, Settings.SLB_FX.getTile("patternCloud", 0));
		var x = Rock.GET_POS(p.cX) + rnd(0, 0.35, true) * Rock.SIZE_OFFSET;
		var y = Rock.GET_POS(p.cY) + rnd(0, 0.35, true) * Rock.SIZE_OFFSET;
		part.setPos(x, y);
		part.dr = rnd(0, 0.02, true);
		part.life = irnd(1 * Settings.FPS, 2 * Settings.FPS);
		part.scale(rnd(0.7, 0.9) * Settings.STAGE_SCALE);
		part.fadeIn(rnd(0.3, 0.5), rnd(0.02, 0.04));
		part.fadeOutSpeed = 0.005;
		part.onKill = function() {
			p.arCloud.remove(part);
		}
		p.arCloud.push(part);
	}
	
	static var GENERAL_SHAKE		: mt.heaps.fx.Shake;
	
	public static function DO_GENERAL_SHAKE(strengthX:Float = 0, strenghtY:Float = 0) {
		if (GENERAL_SHAKE != null && !GENERAL_SHAKE.dead)
			GENERAL_SHAKE.kill();
		GENERAL_SHAKE = new mt.heaps.fx.Shake(Main.MAIN_SCENE, strengthX * Settings.STAGE_SCALE, strenghtY * Settings.STAGE_SCALE);
		GENERAL_SHAKE.fitPix = true;
	}
	
	public static function ROLL_OVER(arSel:Array<Rock>) {
		var game = Game.ME;
		var rnd = mt.deepnight.Lib.rnd;
		
		for (r in arSel) {
			switch (r.type) {
				case TypeRock.TRClassic(id) :
					for (i in 0...2) {
						var part = mt.deepnight.HParticle.allocFromPool(game.poolUnderGridAddFX, Settings.SLB_FX.getTile(id + "PartSmall"));
						part.setPos(game.cRocks.x + Rock.GET_POS(r.cX) + rnd(0, Rock.SIZE_OFFSET * 0.5, true), 
									game.cRocks.y + Rock.GET_POS(r.cY) + rnd(0, Rock.SIZE_OFFSET * 0.5, true));
						part.delay = Settings.FPS / 6;
						part.scaleX = part.scaleY = Settings.STAGE_SCALE;
						part.life = rnd(Settings.FPS / 4, Settings.FPS * 3 / 4);
						part.ds = -0.02;
						part.moveAng(3.14 / 2, rnd(2, 4) * Settings.STAGE_SCALE);
						part.gy = rnd(0.4, 0.8) * Settings.STAGE_SCALE;
					}
				case TypeRock.TRMagma, TypeRock.TRBubble, TypeRock.TRHole,
						TypeRock.TRFreeze, TypeRock.TRLoot, TypeRock.TRCog, 
						TypeRock.TRBlock, TypeRock.TRBonus, TypeRock.TRBlockBreakable, 
						TypeRock.TRBombCiv :
			}
		}
	}
	
	public static function GO_TO_OBJECTIVE(r:Rock, hs:h2d.Sprite, point:h2d.col.Point, cb:Void->Void) {
		var game = Game.ME;
		var rnd = mt.deepnight.Lib.rnd;
		
		var b = false;
		
		switch (r.type) {
			case TypeRock.TRClassic(id) :
				b = true;
			default :
		}
		
		if (b) {
			var id = r.ram.typeID;
			
			var p2 = Settings.SLB_FX.h_get(id + "PartSmallGlow");
			p2.filter = true;
			p2.setCenterRatio(0.5, 0.5);
			p2.scaleX = p2.scaleY = Settings.STAGE_SCALE * 2;
			p2.x = game.cRocks.x + Rock.GET_POS(r.cX);
			p2.y = game.cRocks.y + Rock.GET_POS(r.cY);
			p2.blendMode = Add;
			game.root.add(p2, Settings.DM_FX_UI);
			
			var p = Settings.SLB_FX.h_get(id + "Part");
			p.filter = true;
			p.setCenterRatio(0.5, 0.5);
			p.scaleX = p.scaleY = Settings.STAGE_SCALE;
			p.x = game.cRocks.x + Rock.GET_POS(r.cX);
			p.y = game.cRocks.y + Rock.GET_POS(r.cY);
			game.root.add(p, Settings.DM_FX_UI);
			
			var d = mt.deepnight.Lib.rnd(0.75, 1);
			
			game.tweener.create().to(d * Settings.FPS, p.x = point.x );
			var t = game.tweener.create().to(d * Settings.FPS , p.y = point.y);
			t.ease(mt.motion.Ease.easeInQuad);
			function onUpdate(e) {
				p2.x = p.x;
				p2.y = p.y;
				var part = mt.deepnight.HParticle.allocFromPool(game.poolOverGridFX, Settings.SLB_FX.getTile(id + "PartSmall"));
				part.scale(Settings.STAGE_SCALE * 0.5);
				part.setPos(p.x, p.y);
				part.life = rnd(Settings.FPS / 2, Settings.FPS);
				part.dx = mt.deepnight.Lib.rnd( -4, 4);
				part.dy = mt.deepnight.Lib.rnd( 0, 4);
			}
			function onComplete1() {
				cb();
				SoundManager.COLLECT_SFX();
				new mt.heaps.fx.Shake(hs, Std.int(10 * Settings.STAGE_SCALE), 0);
				t = game.tweener.create().to(0.2 * Settings.FPS, p2.alpha = 0, p.alpha = 0);
				t.onUpdate = null;
				function onComplete2() {
					p.dispose();
					p = null;
					p2.dispose();
					p2 = null;
				}
				t.onComplete = onComplete2;
			}
			t.onUpdate = onUpdate;
			t.onComplete = onComplete1;
		}
	}
	
	public static function GO_TO_ROCK(x:Float, y:Float, r:Rock, cb:Void->Void) {
		var game = Game.ME;
		var rnd = mt.deepnight.Lib.rnd;
		
		var b = true;
		
		for (i in 0...3) {
			var p = Settings.SLB_FX.h_get("goldPart");
			p.filter = true;
			p.setCenterRatio(0.5, 0.5);
			p.scaleX = p.scaleY = Settings.STAGE_SCALE * 2;
			p.blendMode = Add;
			p.x = x;
			p.y = y;
			game.root.add(p, Settings.DM_FX_UI);
			
			var d = 0.5;
			
			game.tweener.create().to(d * Settings.FPS, p.x = game.cRocks.x + Rock.GET_POS(r.cX));
			var t = game.tweener.create().to(d * Settings.FPS , p.y = game.cRocks.y + Rock.GET_POS(r.cY));
			t.ease(mt.motion.Ease.easeInQuad);
			function onUpdate(e) {
				var part = mt.deepnight.HParticle.allocFromPool(game.poolOverGridAddFX, Settings.SLB_FX.getTile("goldPart"));
				part.scale(Settings.STAGE_SCALE);
				part.setPos(p.x, p.y);
				part.life = rnd(Settings.FPS / 4, Settings.FPS / 2);
				part.dx = mt.deepnight.Lib.rnd( -4, 4);
				part.dy = mt.deepnight.Lib.rnd( 0, 4);
			}
			function onComplete1() {
				if (b) {
					cb();
					b = false;
				}
				t = game.tweener.create().to(0.2 * Settings.FPS, p.alpha = 0);
				t.onUpdate = null;
				function onComplete2() {
					p.dispose();
					p = null;					
				}
				t.onComplete = onComplete2;
			}
			t.onUpdate = onUpdate;
			t.onComplete = onComplete1;		
		}
	}
	
	public static function DESTROY_ROCK(r:Rock, delay:Bool, ?f:Void->Void) {
		var game = Game.ME;
		var rnd = mt.deepnight.Lib.rnd;
		
		function destRock() {
			if (f != null)
				f();
			
			var x = game.cRocks.x + Rock.GET_POS(r.cX);
			var y = game.cRocks.y + Rock.GET_POS(r.cY);
			
			FX_VANISH(r.cX, r.cY);
			
			for (i in 0...10) {
				var part;
				
				var n = r.ram.typeID + "Part" + (Std.random(2) == 0 ? "" : "Small");
				if (Settings.SLB_FX.exists(n))
					part = mt.deepnight.HParticle.allocFromPool(game.poolOverGridFX, Settings.SLB_FX.getTile(n));
				else
					part = mt.deepnight.HParticle.allocFromPool(game.poolOverGridFX, Settings.SLB_FX.getTile("starPart"));
				part.scaleX = part.scaleY = Settings.STAGE_SCALE;
				part.setPos(x, y);
				part.rotation = mt.MLib.toRad(Std.random(360)) * (Std.random(5) == 0 ? mt.gx.Dice.rollF(2, 3) : 1);
				part.life = Std.int(rnd(0.3, 0.7) * Settings.FPS);
				part.dr = mt.deepnight.Lib.sign() * Math.PI * 0.2;
				part.moveAng(mt.deepnight.Lib.rnd( -3.14, 0, false), rnd(15, 30) * Settings.STAGE_SCALE);
				if (Dice.percent(15)) {
					part.dx *= 2.0;
					part.dy *= 2.0;
				}
				
				part.gy = rnd(1.2, 2.8) * Settings.STAGE_SCALE;
				part.ds = -0.01 * Settings.STAGE_SCALE ;
				part.frictX = Dice.rollF(0.96,0.98);
			}			
		}
		
		if (delay)
			game.delayer.addFrameBased(destRock, Std.random(Std.int(Settings.FPS / 4)));			
		else
			destRock();
		
	}
	
	public static function FX_VANISH(cX:Int, cY:Int) {
		var game = Game.ME;
		var rnd = mt.deepnight.Lib.rnd;
		//trace(cX + " " + cY);
		var x = game.cRocks.x + Rock.GET_POS(cX);
		var y = game.cRocks.y + Rock.GET_POS(cY);
	
		var p = Settings.SLB_FX.hbe_getAndPlay(game.bmOverGridAddFX, "fxVanish2", 1, true);
		p.scaleX = p.scaleY = Settings.STAGE_SCALE * (2 + rnd(0, 0.1));
		p.alpha = 0.8;
		p.rotation = mt.gx.Dice.angle();
		p.setCenterRatio(0.5, 0.5);
		p.x = x + rnd(0, 10 * Settings.STAGE_SCALE, true);
		p.y = y + rnd(0, 10 * Settings.STAGE_SCALE, true);
	}
	
	public static function DESTROY_ICE(r:Rock) {
		var game = Game.ME;
		var rnd = mt.deepnight.Lib.rnd;
		
		SoundManager.ICE_EXPLODE_SFX();
		
		var x = game.cRocks.x + Rock.GET_POS(r.cX);
		var y = game.cRocks.y + Rock.GET_POS(r.cY);
		for (i in 0...15) {
			var part = mt.deepnight.HParticle.allocFromPool(game.poolOverGridFX, Settings.SLB_FX.getTile("icePart"));
			part.scaleX = part.scaleY = Settings.STAGE_SCALE;
			part.setPos(x, y);
			part.rotation = mt.MLib.toRad(Std.random(360));
			//part.dy = 1;
			part.life = Std.int(0.5 * Settings.FPS);
			part.moveAng(mt.deepnight.Lib.rnd(-3.14, 0, false), rnd(10, 20) * Settings.STAGE_SCALE);
			part.gy = 0.4 * Settings.STAGE_SCALE;
			part.frictX = 0.99;
		}
	}
	
	public static function DESTROY_BUBBLE(r:Rock) {
		var game = Game.ME;
		var rnd = mt.deepnight.Lib.rnd;
		
		SoundManager.BUBBLE_EXPLODE_SFX();
		
		var x = game.cRocks.x + Rock.GET_POS(r.cX);
		var y = game.cRocks.y + Rock.GET_POS(r.cY);
		for (i in 0...15) {
			var part = mt.deepnight.HParticle.allocFromPool(game.poolOverGridAddFX, Settings.SLB_FX.getTile("waterPartBig"));
			part.scaleX = part.scaleY = Settings.STAGE_SCALE;
			part.setPos(x, y);
			part.rotation = mt.MLib.toRad(Std.random(360));
			//part.dy = 1;
			part.life = Std.int(0.5 * Settings.FPS);
			part.moveAng(mt.deepnight.Lib.rnd(-3.14, 0, false), rnd(10, 20) * Settings.STAGE_SCALE);
			part.gy = 0.4 * Settings.STAGE_SCALE;
			part.frictX = 0.99;
		}
	}
	
	public static function DESTROY_GELAT(cX:Int, cY:Int) {
		var game = Game.ME;
		
		SoundManager.GOLD_EXPLODE_SFX();
		
		for (i in 0...15) {
			var n = "goldPart" + (Std.random(2) == 0 ? "" : "Small");
			var part = mt.deepnight.HParticle.allocFromPool(game.poolOverGridFX, Settings.SLB_FX.getTile(n));
			part.scaleX = part.scaleY = Settings.STAGE_SCALE;
			part.setPos(game.cRocks.x + Rock.GET_POS(cX), game.cRocks.y + Rock.GET_POS(cY));
			part.rotation = mt.MLib.toRad(Std.random(360));
			part.life = Std.int(0.5 * Settings.FPS);
			part.moveAng(mt.deepnight.Lib.rnd(-3.14, 0, false), 5 + Std.random(5));
			part.gy = 0.2 * Settings.STAGE_SCALE;
			part.frictX = 0.99;
		}
	}
	
	public static function DESTROY_LIFE(bm:h2d.SpriteBatch, pool:Array<HParticle>, s:HSprite) {
		var rnd = mt.deepnight.Lib.rnd;
		
		for (i in 0...5) {
			var n = "goldPart" + (Std.random(2) == 0 ? "" : "Small");
			var part = mt.deepnight.HParticle.allocFromPool(pool, Settings.SLB_FX.getTile(n));
			part.scaleX = part.scaleY = Settings.STAGE_SCALE;
			part.setPos(s.x + rnd(0, s.width * 0.5, true), s.y + rnd(0, s.height * 0.5, true));
			part.rotation = mt.MLib.toRad(Std.random(360));
			part.life = Std.int(rnd(0.4, 0.75) * Settings.FPS);
			part.moveAng(mt.deepnight.Lib.rnd(-3.14, 0, false), rnd(10, 20) * Settings.STAGE_SCALE);
			part.gy = 0.4 * Settings.STAGE_SCALE;
			part.frictX = 0.99;
		}
	}
	
	public static function BOMB(tb:TypeBonus, r:Rock, arRockToDestroy:Array<Rock>) {
		var game = Game.ME;
		
		var t1 = 0.1;
		//var t1 = 5;
		var t2 = 0.2;
		var t3 = 0.15;
		
		var cFX = new h2d.Sprite();
		cFX.x = Game.ME.cRocks.x + Rock.GET_POS(r.cX);
		cFX.y = Game.ME.cRocks.y + Rock.GET_POS(r.cY);
		game.root.add(cFX, Settings.DM_FX);
		
		function createMiniBomb(cX:Int, cY:Int, delay:Bool = true) {
			var hs = Settings.SLB_FX.hbe_getAndPlay(game.bmOverGridAddFX, "fxBombMini");
			hs.setCenterRatio(0.5, 0.5);
			hs.scale(Settings.STAGE_SCALE);
			hs.x = Game.ME.cRocks.x + Rock.GET_POS(cX);
			hs.y = Game.ME.cRocks.y + Rock.GET_POS(cY);
			var t = game.tweener.create();
			function onCompleteCreateMiniBomb() {
				hs.dispose();
				hs = null;
			}
			t.delay(delay ? Std.random(Std.int(Settings.FPS / 3)) : 20).to(0.3 * Settings.FPS, hs.alpha = 0).onComplete = onCompleteCreateMiniBomb;
		}
		
		function createEdge():HSprite {
			var hsEdge = Settings.SLB_FX.h_getAndPlay("fxBombEdge");
			hsEdge.blendMode = Add;
			hsEdge.filter = false;
			hsEdge.setCenterRatio(0.5, 0.5);
			hsEdge.scaleX = hsEdge.scaleY = Settings.STAGE_SCALE;
			cFX.addChild(hsEdge);
			
			return hsEdge;
		}
		
		function createLine():HSprite {
			var hsLine = Settings.SLB_FX.h_getAndPlay("fxBombCore");
			hsLine.blendMode = Add;
			hsLine.filter = false;
			hsLine.setCenterRatio(0.5, 0);
			hsLine.scaleX = hsLine.scaleY = Settings.STAGE_SCALE;
			cFX.addChild(hsLine);
			
			return hsLine;
		}
		
		function createBombX(cross:Bool = false) {
			var dist = Rock.SIZE_OFFSET;
			
			var cLeft = r.cX;
			var cRight = (Settings.GRID_WIDTH - r.cX - 1);
			cLeft -= 1;
			cRight -= 1;
			
			if (cross) {
				dist = Std.int(Math.sqrt(Rock.SIZE_OFFSET * Rock.SIZE_OFFSET * 2));
				cLeft = r.cX < r.cY ? r.cX : r.cY;
				cRight = (Settings.GRID_WIDTH - r.cX - 1) < (Settings.GRID_HEIGHT - r.cY - 1) ? (Settings.GRID_WIDTH - r.cX - 1) : (Settings.GRID_HEIGHT - r.cY - 1);
			}
			
			var lineLeft = createLine();
			lineLeft.rotation = -3.14 / 2;
			
			var edgeLeft = createEdge();
			edgeLeft.setCenterRatio(0.5, 1);
			edgeLeft.rotation = -3.14 / 2;
			var TLeft = game.tweener.create().to(t1 * Settings.FPS, edgeLeft.x = -cLeft * dist);
			function onUpdateTLeft(e) {
				edgeLeft.x = Std.int(edgeLeft.x);
				lineLeft.scaleY = (edgeLeft.x / Rock.SIZE_OFFSET) * Settings.STAGE_SCALE;
			}
			TLeft.onUpdate = onUpdateTLeft;
			TLeft.delay(t2 * Settings.FPS);
			TLeft = TLeft.to(t3 * Settings.FPS, edgeLeft.alpha = 0, lineLeft.alpha = 0);
			function onCompleteTLeft() {
				edgeLeft.dispose();
				edgeLeft = null;
				
				lineLeft.dispose();
				lineLeft = null;
			}
			TLeft.onComplete = onCompleteTLeft;
			
			var lineRight = createLine();
			lineRight.rotation = -3.14 / 2;
			
			var edgeRight = createEdge();
			edgeRight.setCenterRatio(0.5, 1);
			edgeRight.scaleX = -Settings.STAGE_SCALE;
			edgeRight.rotation = 3.14 / 2;
			var tRight = game.tweener.create().to(t1 * Settings.FPS, edgeRight.x = cRight * dist);
			function onUpdateTRight(e) {
				edgeRight.x = Std.int(edgeRight.x);
				lineRight.scaleY = (edgeRight.x / Rock.SIZE_OFFSET) * Settings.STAGE_SCALE;
			}
			tRight.onUpdate = onUpdateTRight;
			tRight.delay(t2 * Settings.FPS);
			tRight = tRight.to(t3 * Settings.FPS, edgeRight.alpha = 0, lineRight.alpha = 0);
			function onCompleteTRight() {
				edgeRight.dispose();
				edgeRight = null;
				
				lineRight.dispose();
				lineRight = null;				
			}
			tRight.onComplete = onCompleteTRight;
		}
		
		function createBombY(cross:Bool = false) {
			var dist = Rock.SIZE_OFFSET;
			
			var cTop = r.cY;
			var cDown = (Settings.GRID_HEIGHT - r.cY - 1);
			cTop -= 1;
			cDown -= 1;
			
			if (cross) {
				dist = Std.int(Math.sqrt(Rock.SIZE_OFFSET * Rock.SIZE_OFFSET * 2));
				cTop = (Settings.GRID_WIDTH - r.cX - 1) < r.cY ? (Settings.GRID_WIDTH - r.cX - 1) : r.cY;
				cDown = r.cX < (Settings.GRID_HEIGHT - r.cY - 1) ? r.cX : (Settings.GRID_HEIGHT - r.cY - 1);
			}
			
			var lineTop = createLine();
			var edgeTop = createEdge();
			edgeTop.setCenterRatio(0.5, 1);
			var tTop = game.tweener.create().to(t1 * Settings.FPS, edgeTop.y = -cTop * dist);
			function onUpdateTTop(e) {
				edgeTop.y = Std.int(edgeTop.y);
				lineTop.scaleY = (edgeTop.y / Rock.SIZE_OFFSET) * Settings.STAGE_SCALE;
			}
			tTop.onUpdate = onUpdateTTop;
			tTop.delay(t2 * Settings.FPS);
			tTop = tTop.to(t3 * Settings.FPS, edgeTop.alpha = 0, lineTop.alpha = 0);
			function onCompleteTTop() {
				edgeTop.dispose();
				edgeTop = null;
				
				lineTop.dispose();
				lineTop = null;
			}
			tTop.onComplete = onCompleteTTop;
			
			var lineBottom = createLine();
			var edgeBottom = createEdge();
			edgeBottom.setCenterRatio(0.5, 1);
			edgeBottom.scaleX = -Settings.STAGE_SCALE;
			edgeBottom.rotation = 3.14;
			var tBottom = game.tweener.create().to(t1 * Settings.FPS, edgeBottom.y = cDown * dist);
			function onUpdateTDown(e) {
				edgeBottom.y = Std.int(edgeBottom.y);
				lineBottom.scaleY = (edgeBottom.y / Rock.SIZE_OFFSET) * Settings.STAGE_SCALE;
			}
			tBottom.onUpdate = onUpdateTDown;
			tBottom.delay(t2 * Settings.FPS);
			tBottom = tBottom.to(t3 * Settings.FPS, edgeBottom.alpha = 0, lineBottom.alpha = 0);
			function onCompleteTDown() {
				edgeBottom.dispose();
				edgeBottom = null;
				
				lineBottom.dispose();
				lineBottom = null;
			}
			tBottom.onComplete = onCompleteTDown;
		}
			
		switch (tb) {
			case TypeBonus.TBBombVert :
				createBombY();
				DO_GENERAL_SHAKE(0, 10);
			case TypeBonus.TBBombHor :
				createBombX();
				DO_GENERAL_SHAKE(10, 0);
			case TypeBonus.TBBombPlus :
				if (Std.random(2) == 0)	DO_GENERAL_SHAKE(10, 0);
				else					DO_GENERAL_SHAKE(0, 10);
				createBombX();
				createBombY();
			case TypeBonus.TBBombCross :
				if (Std.random(2) == 0)	DO_GENERAL_SHAKE(10, 0);
				else					DO_GENERAL_SHAKE(0, 10);
				cFX.rotation = 3.14 / 4;
				createBombX(true);
				createBombY(true);
			case TypeBonus.TBColor :
				DO_GENERAL_SHAKE(10, 10);
				for (ro in arRockToDestroy) {
					createMiniBomb(ro.cX, ro.cY);
				}
			case TypeBonus.TBBombMini :
				DO_GENERAL_SHAKE(10, 10);
				createMiniBomb(r.cX - 1, r.cY, false);
				createMiniBomb(r.cX + 1, r.cY, false);
				createMiniBomb(r.cX, r.cY - 1, false);
				createMiniBomb(r.cX, r.cY + 1, false);
		}
	}
	
	public static function BOMB_END(tb:TypeBonus, r:Rock) {
		var game = Game.ME;
		
		var t1 = 0.1;
		//var t1 = 5;
		var t2 = 0.2;
		var t3 = 0.15;
		
		var x = Game.ME.cRocks.x + Rock.GET_POS(r.cX);
		var y = Game.ME.cRocks.y + Rock.GET_POS(r.cY);
		
		function createEdge():HSpriteBE {
			var hsEdge = Settings.SLB_FX.hbe_getAndPlay(game.bmOverGridAddFX, "fxBombEdge");
			hsEdge.setCenterRatio(0.5, 0.5);
			hsEdge.scaleX = hsEdge.scaleY = Settings.STAGE_SCALE;
			
			return hsEdge;
		}
		
		function createLine():HSpriteBE {
			var hsLine = Settings.SLB_FX.hbe_getAndPlay(game.bmOverGridAddFX, "fxBombCore");
			hsLine.setCenterRatio(0.5, 0);
			hsLine.scaleX = hsLine.scaleY = Settings.STAGE_SCALE;
			
			return hsLine;
		}
		
		function createBombX(cross:Bool = false) {
			var dist = Rock.SIZE_OFFSET;
			
			var cLeft = r.cX;
			var cRight = (Settings.GRID_WIDTH - r.cX - 1);
			cLeft -= 1;
			cRight -= 1;
			
			if (cross) {
				dist = Std.int(Math.sqrt(Rock.SIZE_OFFSET * Rock.SIZE_OFFSET * 2));
				cLeft = r.cX < r.cY ? r.cX : r.cY;
				cRight = (Settings.GRID_WIDTH - r.cX - 1) < (Settings.GRID_HEIGHT - r.cY - 1) ? (Settings.GRID_WIDTH - r.cX - 1) : (Settings.GRID_HEIGHT - r.cY - 1);
			}
			
			var lineLeft = createLine();
			lineLeft.x = x;
			lineLeft.y = y;
			lineLeft.rotation = -3.14 / 2;
			
			var edgeLeft = createEdge();
			edgeLeft.x = x;
			edgeLeft.y = y;
			edgeLeft.setCenterRatio(0.5, 1);
			edgeLeft.rotation = -3.14 / 2;
			var TLeft = game.tweener.create().to(t1 * Settings.FPS, edgeLeft.x = x - cLeft * dist);
			function onUpdateTLeft(e) {
				edgeLeft.x = Std.int(edgeLeft.x);
				lineLeft.scaleY = ((edgeLeft.x - x) / Rock.SIZE_OFFSET) * Settings.STAGE_SCALE;
			}
			TLeft.onUpdate = onUpdateTLeft;
			TLeft.delay(t2 * Settings.FPS);
			TLeft = TLeft.to(t3 * Settings.FPS, edgeLeft.alpha = 0, lineLeft.alpha = 0);
			function onCompleteTLeft() {
				edgeLeft.dispose();
				edgeLeft = null;
				
				lineLeft.dispose();
				lineLeft = null;
			}
			TLeft.onComplete = onCompleteTLeft;
			
			var lineRight = createLine();
			lineRight.x = x;
			lineRight.y = y;
			lineRight.rotation = -3.14 / 2;
			
			var edgeRight = createEdge();
			edgeRight.x = x;
			edgeRight.y = y;
			edgeRight.setCenterRatio(0.5, 1);
			edgeRight.scaleX = -Settings.STAGE_SCALE;
			edgeRight.rotation = 3.14 / 2;
			var tRight = game.tweener.create().to(t1 * Settings.FPS, edgeRight.x = x + cRight * dist);
			function onUpdateTRight(e) {
				edgeRight.x = Std.int(edgeRight.x);
				lineRight.scaleY = ((edgeRight.x - x) / Rock.SIZE_OFFSET) * Settings.STAGE_SCALE;
			}
			tRight.onUpdate = onUpdateTRight;
			tRight.delay(t2 * Settings.FPS);
			tRight = tRight.to(t3 * Settings.FPS, edgeRight.alpha = 0, lineRight.alpha = 0);
			function onCompleteTRight() {
				edgeRight.dispose();
				edgeRight = null;
				
				lineRight.dispose();
				lineRight = null;				
			}
			tRight.onComplete = onCompleteTRight;
		}
		
		function createBombY(cross:Bool = false) {
			var dist = Rock.SIZE_OFFSET;
			
			var cTop = r.cY;
			var cDown = (Settings.GRID_HEIGHT - r.cY - 1);
			cTop -= 1;
			cDown -= 1;
			
			if (cross) {
				dist = Std.int(Math.sqrt(Rock.SIZE_OFFSET * Rock.SIZE_OFFSET * 2));
				cTop = (Settings.GRID_WIDTH - r.cX - 1) < r.cY ? (Settings.GRID_WIDTH - r.cX - 1) : r.cY;
				cDown = r.cX < (Settings.GRID_HEIGHT - r.cY - 1) ? r.cX : (Settings.GRID_HEIGHT - r.cY - 1);
			}
			
			var lineTop = createLine();
			lineTop.x = x;
			lineTop.y = y;
			var edgeTop = createEdge();
			edgeTop.x = x;
			edgeTop.y = y;
			edgeTop.setCenterRatio(0.5, 1);
			var tTop = game.tweener.create().to(t1 * Settings.FPS, edgeTop.y = y - cTop * dist);
			function onUpdateTTop(e) {
				edgeTop.y = Std.int(edgeTop.y);
				lineTop.scaleY = ((edgeTop.y - y) / Rock.SIZE_OFFSET) * Settings.STAGE_SCALE;
			}
			tTop.onUpdate = onUpdateTTop;
			tTop.delay(t2 * Settings.FPS);
			tTop = tTop.to(t3 * Settings.FPS, edgeTop.alpha = 0, lineTop.alpha = 0);
			function onCompleteTTop() {
				edgeTop.dispose();
				edgeTop = null;
				
				lineTop.dispose();
				lineTop = null;
			}
			tTop.onComplete = onCompleteTTop;
			
			var lineBottom = createLine();
			lineBottom.x = x;
			lineBottom.y = y;
			var edgeBottom = createEdge();
			edgeBottom.x = x;
			edgeBottom.y = y;
			edgeBottom.setCenterRatio(0.5, 1);
			edgeBottom.scaleX = -Settings.STAGE_SCALE;
			edgeBottom.rotation = 3.14;
			var tBottom = game.tweener.create().to(t1 * Settings.FPS, edgeBottom.y = y + cDown * dist);
			function onUpdateTDown(e) {
				edgeBottom.y = Std.int(edgeBottom.y);
				lineBottom.scaleY = ((edgeBottom.y - y) / Rock.SIZE_OFFSET) * Settings.STAGE_SCALE;
			}
			tBottom.onUpdate = onUpdateTDown;
			tBottom.delay(t2 * Settings.FPS);
			tBottom = tBottom.to(t3 * Settings.FPS, edgeBottom.alpha = 0, lineBottom.alpha = 0);
			function onCompleteTDown() {
				edgeBottom.dispose();
				edgeBottom = null;
				
				lineBottom.dispose();
				lineBottom = null;
			}
			tBottom.onComplete = onCompleteTDown;
		}
		
		if (Std.random(2) == 0)	DO_GENERAL_SHAKE(10, 0);
		else					DO_GENERAL_SHAKE(0, 10);
		switch (tb) {
			case TypeBonus.TBBombVert :
				createBombY();
				DO_GENERAL_SHAKE(0, 10);
			case TypeBonus.TBBombHor :
				createBombX();
				DO_GENERAL_SHAKE(10, 0);
			case TypeBonus.TBBombPlus :
				createBombX();
				createBombY();
			default :
		}
	}
	
	public static function COMBO(v:Int, isLeft:Bool) {
		var game = Game.ME;
		
		var cCombo = new h2d.Sprite();
		cCombo.scaleX = cCombo.scaleY = 0;
		//cCombo.rotation = -3.14 / 4;
		game.root.add(cCombo, Settings.DM_FX_UI);
		
		var hsCombo = Settings.SLB_UI2.h_get("comboTxt");
		hsCombo.setCenterRatio(0.5, 1);
		hsCombo.filter = true;
		cCombo.addChild(hsCombo);
		
		var hsSplash = Settings.SLB_UI2.h_get("splashCombo");
		hsSplash.setCenterRatio(0.5, 1);
		hsSplash.filter = true;
		hsSplash.blendMode = Add;
		cCombo.addChild(hsSplash);
		
		var hsX = Settings.SLB_UI2.h_get("xTxt");
		hsX.setCenterRatio(0.5, 1);
		hsX.filter = true;
		cCombo.addChild(hsX);
		
		var hsNum = Settings.SLB_UI2.h_get(v <= 9 ? v + "Txt" : "infiniteTxt");
		hsNum.setCenterRatio(0.5, 1);
		hsNum.filter = true;
		cCombo.addChild(hsNum);
		
		var t = game.tweener.create().to(0.5 * Settings.FPS, 	cCombo.scaleX = Settings.STAGE_SCALE,
																cCombo.scaleY = Settings.STAGE_SCALE);
		t.ease(mt.motion.Ease.easeOutElastic);
		t.delay(1 * Settings.FPS);
		function onComplete1() {
			t = game.tweener.create().delay(0.5 * Settings.FPS).to(0.2 * Settings.FPS, hsCombo.alpha = 0, hsSplash.alpha = 0, hsX.alpha = 0, hsNum.alpha = 0);
			function onComplete2() {
				hsCombo.dispose();
				hsCombo = null;
				
				hsSplash.dispose();
				hsSplash = null;
				
				hsX.dispose();
				hsX = null;
				
				hsNum.dispose();
				hsNum = null;				
			}
			t.onComplete = onComplete2;
		}
		t.onComplete = onComplete1;
		
		if (!isLeft) {
			cCombo.rotation = -3.14 / 4;
			cCombo.x = Std.int(Settings.STAGE_WIDTH * 0.5 - Rock.SIZE_OFFSET);
			cCombo.y = Settings.STAGE_HEIGHT * 0.5 - Rock.SIZE_OFFSET * 2.5;
		}
		else {
			cCombo.x = Std.int(Settings.STAGE_WIDTH * 0.5 + Rock.SIZE_OFFSET * 2);
			cCombo.y = Settings.STAGE_HEIGHT * 0.5 - Rock.SIZE_OFFSET * 2;
		}
	}
	
	public static function END_MESSAGE(success:Bool) {
		var game = Game.ME;
		
		var hsMessage = 
			if (success)
				Settings.SLB_UI2.h_get("win");
			else
				Settings.SLB_LANG.h_get("lose_" + (Settings.SLB_LANG_IS_DL ? data.Lang.LANG : "en"));
		hsMessage.setCenterRatio(0.5, 1);
		hsMessage.filter = true;
		hsMessage.scaleX = hsMessage.scaleY = 0;
		hsMessage.x = Std.int(Settings.STAGE_WIDTH * 0.5);
		hsMessage.y = Std.int(Settings.STAGE_HEIGHT * 0.5);
		game.root.add(hsMessage, Settings.DM_FX_UI);
		
		var t = game.tweener.create().to(0.5 * Settings.FPS, 	hsMessage.scaleX = Settings.STAGE_SCALE #if !standalone / 0.65 #end,
																hsMessage.scaleY = Settings.STAGE_SCALE #if !standalone / 0.65 #end);
		t.ease(mt.motion.Ease.easeOutElastic);
		function onComplete1() {
			t = game.tweener.create().delay(1 * Settings.FPS).to(0.2 * Settings.FPS, hsMessage.alpha = 0);
			t.onComplete = function () {
				if (hsMessage != null)
					hsMessage.dispose();
				hsMessage = null;
			}
		}
		t.onComplete = onComplete1;
	}
	
	public static function STARS(bm:h2d.SpriteBatch, pool:Array<HParticle>, all:Bool, ?hs:HSprite = null, ?hbe:HSpriteBE = null) {
		for (i in 0...(all ? 40 : 1)) {
			var part = mt.deepnight.HParticle.allocFromPool(pool, Settings.SLB_FX.getTile("starPart"));
			part.scaleX = part.scaleY = Settings.STAGE_SCALE * mt.deepnight.Lib.rnd(0.5, 1);
			if (hs != null)
				part.setPos(hs.x, hs.y);
			else
				part.setPos(hbe.x, hbe.y);
			part.rotation = mt.deepnight.Lib.rnd(0, 3.14, true);
			part.life = Std.int((Std.random(2) + 1) * Settings.FPS);
			part.delay = Std.int((Std.random(50) * 0.01) * Settings.FPS);
			part.moveAng(mt.deepnight.Lib.rnd(-3.14, 0, all), (10 + Std.random(5)) * Settings.STAGE_SCALE);
			part.frictX = part.frictY = 0.98;
			part.gy = 0.2 * Settings.STAGE_SCALE;
			part.dr = 0.2 * Settings.STAGE_SCALE;
			part.onUpdate = function() {
				var miniPart = mt.deepnight.HParticle.allocFromPool(pool, Settings.SLB_FX.getTile("starPart"));
				miniPart.scaleX = part.scaleX / 2;
				miniPart.scaleY = part.scaleY / 2;
				miniPart.setPos(part.x, part.y);
				miniPart.rotation = part.rotation;
				miniPart.life = Std.int(0.1 * Settings.FPS);
				miniPart.alpha = 0.25;
				miniPart.da = 0.25 / (0.1 * Settings.FPS);
				miniPart.changePriority(1);
			}
			part.changePriority(0);
		}
	}
	
	public static function EXPLODE_GOLD(hs:HSprite) {
		var p = process.Levels.ME.root.localToGlobal(new h2d.col.Point(hs.x, hs.y));
		var levels = process.Levels.ME;
		
		var rnd = mt.deepnight.Lib.rnd;
		
		for (i in 0...40) {
			var part = mt.deepnight.HParticle.allocFromPool(levels.poolFX, Settings.SLB_FX.getTile("goldPart"));
			part.scaleX = part.scaleY = Settings.STAGE_SCALE * mt.deepnight.Lib.rnd(2, 4);
			part.setPos(p.x, p.y);
			part.rotation = mt.deepnight.Lib.rnd(0, 3.14, true);
			part.life = Std.int(rnd(0.5, 2) * Settings.FPS);
			part.delay = Std.int(rnd(0, 0.5) * Settings.FPS);
			part.moveAng(rnd(-3.14 / 4, 3.14 * (5 / 4), false), (20 + Std.random(10)) * Settings.STAGE_SCALE);
			part.frictX = part.frictY = 0.98;
			part.gy = 0.2 * Settings.STAGE_SCALE;
			part.dr = 0.2 * Settings.STAGE_SCALE;
			part.onUpdate = function() {
				var miniPart = mt.deepnight.HParticle.allocFromPool(levels.poolFX, Settings.SLB_FX.getTile("goldPart"));
				miniPart.scaleX = part.scaleX / 2;
				miniPart.scaleY = part.scaleY / 2;
				miniPart.setPos(part.x, part.y);
				miniPart.rotation = part.rotation;
				miniPart.life = Std.int(0.1 * Settings.FPS);
				miniPart.alpha = 0.25;
				miniPart.da = 0.25 / (0.1 * Settings.FPS);
				miniPart.changePriority(1);
			}
			part.changePriority(0);
		}
	}
	
	public static function GRIP_CATCH(cX:Int) {
		var game = Game.ME;
		
		var p = Settings.SLB_FX.h_getAndPlay("fxGrip", 1, true);
		p.scaleX = p.scaleY = Settings.STAGE_SCALE * 2;
		p.setCenterRatio(0.5, 1);
		p.x = game.cRocks.x + Rock.GET_POS(cX);
		p.y = game.cRocks.y + Rock.GET_POS(Settings.GRID_HEIGHT - 1) + Rock.SIZE_OFFSET;
		game.root.add(p, Settings.DM_FX);
	}
	
	public static function GRIP_SSB(x:Float):HSprite {
		var game = Game.ME;
		
		var p = Settings.SLB_FX.h_getAndPlay("fxCatch", 1, true);
		p.scaleX = p.scaleY = Settings.STAGE_SCALE * 4;
		p.filter = true;
		p.blendMode = Add;
		p.setCenterRatio(0.5, 1);
		p.x = Std.int(x);
		p.y = Std.int(Settings.STAGE_HEIGHT);
		game.root.add(p, Settings.DM_GRID);
		
		return p;
	}
	
	public static function UPDATE() {
		for (p in Game.ME.arPattern) {
			if (p.z == SpecialManager.PATTERN_ACTUAL) {
				if ((Game.ME.time + p.cX + p.cY) % Std.int(Settings.FPS / 2) == 0 && !Game.ME.isEndGame) {
					CLOUD_PATTERN(p);
				}
			}
			else {
				for (c in p.arCloud) {
					c.life = 0;
					c.fadeOutSpeed = 0.1;
				}
			}
		}
		
		var c = 0;
		for (p in Game.ME.arPattern) {
			c += p.arCloud.length;
		}
	}
}
