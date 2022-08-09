package manager;

import mt.deepnight.slb.BLib;
import mt.deepnight.slb.HSprite;
import mt.deepnight.slb.HSpriteBE;

import Common;

import process.Game;

/**
 * ...
 * @author Tipyx
 */

import data.LevelDesign;
import data.Settings;
 
class RockAssetManager
{
	public static var TIME_HL	: Float 	= 0.04;
	
	var game 		: process.Game;
	
	var rock		: Rock;
	var x			: Float;
	var y			: Float;
	
	public var actualScale	: Float;
	public var oldScale		: Float;
	
	public var typeID	: String;
	public var frame	: Int;
	
// UNDER
	var arFXLoot	: Array<{hs:HSprite, tp:mt.deepnight.deprecated.TinyProcess}>;
	var fxBomb		: HSprite;

// BE
	public var mainBE		: HSpriteBE;
	public var slb			: BLib;
	
// OVER
	var hsFreeze	: HSpriteBE;
	var hsBubble	: HSpriteBE;
	var hsHover		: HSprite;
	
	var inter		: h2d.Interactive;
	var tweenBubble	: mt.motion.Tween;
	
	var needResize	: Bool;

	public function new(r:Rock) {
		game = process.Game.ME;
		
		this.rock = r;
		
		arFXLoot = [];
		
		oldScale = actualScale = 0;
		
		x = Std.int(rock.wX);
		y = Std.int(rock.wY);
	}
	
// SET
	public function setBE(tr:TypeRock) {
		this.typeID = Common.GET_HSID_FROM_TYPEROCK(tr, game.levelInfo.biome);
		
		if (mainBE != null)
			mainBE.dispose();
		
		slb = Settings.SLB_GRID;
		switch (tr) {
			case TypeRock.TRLoot :
				mainBE = slb.hbe_getAndPlay(game.bmRocks, typeID);
				setIsLoot();
				setSpecialHover();
			case TypeRock.TRBonus :
				mainBE = slb.hbe_getAndPlay(game.bmRocks, typeID);
				setIsBomb();
				setSpecialHover();
			case TypeRock.TRCog, TypeRock.TRBonus :
				mainBE = slb.hbe_getAndPlay(game.bmRocks, typeID);
				setIsLoot();
			case TypeRock.TRClassic, TypeRock.TRMagma, TypeRock.TRBlockBreakable,
					TypeRock.TRBubble, TypeRock.TRFreeze, TypeRock.TRBlock, 
					TypeRock.TRBombCiv :
				mainBE = slb.hbe_getAndPlay(game.bmRocks, typeID);
			case TypeRock.TRHole :
				mainBE = slb.hbe_getAndPlay(game.bmHole, typeID);
		}
		
		needResize = true;
		
		mainBE.setCenterRatio(0.5, 0.5);
		
		inter = new h2d.Interactive(124, 124);
		inter.propagateEvents = true;
		game.cRocks.add(inter, Game.DM_ROVER);
	}
	
	public function show() {
		if (mainBE != null)
			mainBE.visible = true;
		for (fx in arFXLoot)
			fx.hs.visible = true;
		
		if (hsFreeze != null)
			hsFreeze.visible = true;
		
		if (hsBubble != null)
			hsBubble.visible = true;
	}
	
	public function hide() {
		if (mainBE != null)
			mainBE.visible = false;
		for (fx in arFXLoot)
			fx.hs.visible = false;
		
		if (hsFreeze != null)
			hsFreeze.visible = false;
		
		if (hsBubble != null)
			hsBubble.visible = false;
		
		if (hsHover != null)
			hsHover.visible = false;
	}
	
	public function showHL() {
		mainBE.changePriority(2);
		if (hsHover != null) {
			mainBE.changePriority(1);
			hsHover.visible = true;
		}
		if (slb.exists(typeID + "Over", frame)) {
			mainBE.set(typeID + "Over", frame);
		}
		if (hsFreeze != null) {
			hsFreeze.set("iceFrontOver", 2 - rock.freezeCounter);
			hsFreeze.changePriority(0);
		}
		game.tweener.create().to(TIME_HL * Settings.FPS, actualScale = 1.5);
		rock.isHL = true;
	}
	
	public function hideHL() {
		if (hsHover != null)
			hsHover.visible = false;
		mainBE.set(typeID, frame);
		game.tweener.create().to(TIME_HL * Settings.FPS, actualScale = 1);
		mainBE.changePriority(3);
		rock.isHL = false;
		if (hsFreeze != null) {
			hsFreeze.set("iceFront", 2 - rock.freezeCounter);
			hsFreeze.changePriority(1);
		}
	}
	
	public function setIsLoot() {
		needResize = true;
		
		var color = "fxShineWhite";
		
		var hs1 = Settings.SLB_FX.h_get(color + "A");
		hs1.setCenterRatio(0.5, 0.5);
		hs1.blendMode = Add;
		hs1.filter = true;
		game.cRocks.add(hs1, Game.DM_RUNDER);
		
		var tp1 = game.createTinyProcess();
		tp1.onUpdate = function () {
			if (hs1 == null)
				tp1.destroy();
			else
				hs1.rotation += 0.02;
		}
		
		arFXLoot.push( { hs:hs1, tp:tp1 } );
		
		var hs2 = Settings.SLB_FX.h_get(color + "B");
		hs2.setCenterRatio(0.5, 0.5);
		hs2.blendMode = Add;
		hs2.filter = true;
		game.cRocks.add(hs2, Game.DM_RUNDER);
		
		var tp2 = game.createTinyProcess();
		tp2.onUpdate = function () {
			if (hs2 == null)
				tp2.destroy();
			else
				hs2.rotation -= 0.02;
		}
		
		arFXLoot.push( { hs:hs2, tp:tp2 } );
		
		var hs3 = Settings.SLB_FX.h_get(color + "C");
		hs3.setCenterRatio(0.5, 0.5);
		hs3.blendMode = Add;
		hs3.filter = true;
		game.cRocks.add(hs3, Game.DM_RUNDER);
		
		var tp3 = game.createTinyProcess();
		tp3.onUpdate = function () {
			if (hs3 == null)
				tp3.destroy();
			else
				hs3.rotation -= 0.01;
		}
		
		arFXLoot.push( { hs:hs3, tp:tp3 } );
		
		color = "fxShineWhite";
		
		var hs4 = Settings.SLB_FX.h_get(color + "C");
		hs4.setCenterRatio(0.5, 0.5);
		hs4.blendMode = Add;
		hs4.filter = true;
		hs4.alpha = 0.25;
		game.cRocks.add(hs4, Game.DM_ROVER);
		
		var tp4 = game.createTinyProcess();
		tp4.onUpdate = function () {
			if (hs4 == null)
				tp4.destroy();
			else
				hs4.rotation -= 0.01;
		}
		
		arFXLoot.push( { hs:hs4, tp:tp4 } );
	}
	
	function setIsBomb() {
		fxBomb = Settings.SLB_FX2.h_getAndPlay("bombGlow");
		fxBomb.a.setGeneralSpeed(0.5);
		fxBomb.setCenterRatio(0.5, 0.5);
		fxBomb.blendMode = Add;
		fxBomb.filter = true;
		game.cRocks.add(fxBomb, Game.DM_RUNDER);
	}
	
	function setSpecialHover() {
		hsHover = slb.h_get(typeID);
		hsHover.setCenterRatio(0.5, 0.5);
		hsHover.visible = false;
		hsHover.blendMode = Add;
		hsHover.alpha = 0.5;
		game.cRocks.add(hsHover, Game.DM_RBM);
	}
	
// ACTION & SPECIAL
	public function setBubble(create:Bool) {
		if (create) {
			hsBubble = Settings.SLB_GRID.hbe_get(game.bmBubble, "bubble");
			hsBubble.setCenterRatio(0.5, 0.5);
			hsBubble.scaleX = hsBubble.scaleY = 0;
			
			SoundManager.BUBBLE_POP_SFX();
			
			hsBubble.x = x;
			hsBubble.y = y;
			tweenBubble = game.tweener.create().to(0.5 * Settings.FPS, 	hsBubble.scaleX = actualScale * Settings.STAGE_SCALE,
																		hsBubble.scaleY = actualScale * Settings.STAGE_SCALE);
			tweenBubble.ease(mt.motion.Ease.easeOutElastic);
		}
		else {
			if (hsBubble == null || hsBubble.destroyed) {
				throw "BUBBLE ALREADY KILLED in " + rock.cX + " " + rock.cY;
			}
			hsBubble.a.play("bubblePlop");
			hsBubble.a.killAfterPlay();
			FX.DESTROY_BUBBLE(rock);
		}
	}

	public function setFreeze(c:Int) {
		if (hsFreeze == null && c > 0) {
			hsFreeze = Settings.SLB_GRID.hbe_get(game.bmIce, "iceFront", 2 - c);
			hsFreeze.scaleX = hsFreeze.scaleY = actualScale * Settings.STAGE_SCALE;
			hsFreeze.setCenterRatio(0.5, 0.5);
			hsFreeze.x = x;
			hsFreeze.y = y;
		}
		else {
			if (c == 0) {
				hsFreeze.dispose();
				hsFreeze = null;
			}
			else
				hsFreeze.setFrame(2 - c);			
		}
		
	}
	
// R D U
	public function resize() {
		if (needResize || x != Std.int(rock.wX) || y != Std.int(rock.wY) || actualScale != oldScale) {
			needResize = false;
			
			oldScale = actualScale;
			x = Std.int(rock.wX);
			y = Std.int(rock.wY);
			
			for (fx in arFXLoot) {
				fx.hs.scaleX = fx.hs.scaleY = actualScale * Settings.STAGE_SCALE * 1.6;
				fx.hs.x = x;
				fx.hs.y = y;
			}
			
			if (fxBomb != null) {
				fxBomb.scaleX = fxBomb.scaleY = actualScale * Settings.STAGE_SCALE;
				fxBomb.x = x;
				fxBomb.y = y;
			}
			
			if (mainBE != null) {
				mainBE.scaleX = mainBE.scaleY = actualScale * Settings.STAGE_SCALE;
				if (!rock.isHL) {
					mainBE.width = mainBE.width < Rock.SIZE_OFFSET ? mainBE.width : Rock.SIZE_OFFSET;
					mainBE.height = mainBE.height < Rock.SIZE_OFFSET ? mainBE.height : Rock.SIZE_OFFSET;					
				}
				mainBE.x = x;
				mainBE.y = y;
				//mainBE.x = rock.wX;
				//mainBE.y = rock.wY;
			}
			
			if (inter != null) {
				inter.scaleX = inter.scaleY = Settings.STAGE_SCALE;
				inter.x = Std.int(x - inter.scaleX * inter.width * 0.5);
				inter.y = Std.int(y - inter.scaleY * inter.height * 0.5);
			}
			
			if (hsFreeze != null) {
				hsFreeze.scaleX = hsFreeze.scaleY = actualScale * Settings.STAGE_SCALE;
				hsFreeze.x = x;
				hsFreeze.y = y;
			}
			
			if (hsBubble != null) {
				hsBubble.x = x;
				hsBubble.y = y;
			}
			
			if (hsHover != null) {
				hsHover.scaleX = hsHover.scaleY = actualScale * Settings.STAGE_SCALE;
				hsHover.x = x;
				hsHover.y = y;
			}
		}
	}
	
	public function newResize() {
		if (hsBubble != null)
			hsBubble.scaleX = hsBubble.scaleY = actualScale * Settings.STAGE_SCALE;		
	}
	
	public function destroy(fx:Bool) {
		for (fx in arFXLoot) {
			fx.hs.dispose();
			fx.hs = null;
			
			fx.tp.destroy();
		}
		
		arFXLoot = [];
		
		if (fxBomb != null) {
			fxBomb.dispose();
			fxBomb = null;
		}
		
		if (mainBE != null) {
			mainBE.dispose();
			mainBE = null;			
		}
		
		if (hsHover != null) {
			hsHover.dispose();
			hsHover = null;			
		}
		
		if (inter != null) {
			inter.dispose();
			inter = null;			
		}
		
		if (hsFreeze != null) {
			hsFreeze.dispose();
			hsFreeze = null;			
		}
		
		if (hsBubble != null && !hsBubble.destroyed) {
			if (fx)
				setBubble(false)
			else {
				hsBubble.dispose();
				hsBubble = null;				
			}
		}
		
		if (tweenBubble != null) {
			tweenBubble.dispose();
			tweenBubble = null;			
		}
		
		slb = null;
		
		typeID = "";
	}
	
	public function update() {
		if (typeID == "lava" && Std.random(5) == 0) {
			var rnd = game.rndS.range;
			
			var special = false;
			if (Std.random(30) == 0)
				special = true;
				
			var l = rnd(30, 60);
		
			var part = mt.deepnight.HParticle.allocFromPool(game.poolPartMagmaFX, Settings.SLB_FX.getTile("rocPartSmallGlow"));
			part.scale(Settings.STAGE_SCALE);
			part.setPos(x + rnd(0, mainBE.width / 2, true), 
						y - rnd(0, mainBE.width / 2, false));
			part.dy = -1 * Settings.STAGE_SCALE;
			part.life = l;
			part.alpha = 0;
			part.da = 0.02;
			part.maxAlpha = rnd(0.5, 1);
			part.scale(rnd(0.5, 1) * Settings.STAGE_SCALE);
			part.fadeOutSpeed = 0.02;
			if (special) {
				part.life = 30;
				part.gy = 0.2 * Settings.STAGE_SCALE;
				part.moveAng(rnd( -3.14 * 3 / 4, -3.14 / 4), 10 * Settings.STAGE_SCALE);
			}
			part.onUpdate = function() {
				part.x += (Math.sin(part.y));
			}
		
			var part2 = mt.deepnight.HParticle.allocFromPool(game.poolPartMagmaFX, Settings.SLB_FX.getTile("rocPartSmallGlow"), part.x, part.y);
			part2.dx = part.dx;
			part2.dy = part.dy;
			part2.gy = part.gy;
			part2.life = l;
			part2.alpha = 0;
			part2.da = 0.02;
			part2.maxAlpha = 0.1;
			part2.scale(4 * Settings.STAGE_SCALE);
			part2.fadeOutSpeed = 0.02;
			part2.onUpdate = function() {
				part2.x = part.x;
			}
		}
	}
}