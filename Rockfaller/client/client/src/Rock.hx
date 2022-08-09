package ;

import mt.deepnight.slb.HSprite;

import process.Game;
import data.Settings;
import Common;
import manager.StateManager;
import manager.SoundManager;
import manager.SpecialManager;
import manager.RockAssetManager;
import manager.RegenManager;
import manager.TutoManager;

/**
 * ...
 * @author Tipyx
 */

using Lambda;

//enum Position {
	//UL;
	//UR;
	//BL;
	//BR;
//}

enum SWIPE_DIRECTION {
	SDLeft;
	SDRight;
}

enum FallDirection {
	FDDown;
	FDLeft;
	FDRight;
}

class Rock
{
// STATIC
	public static var ALL				: Array<Rock>			= [];
	
	public static var AR_SEL			: Array<Rock>			= [];
	public static var PREVIOUS_SEL		: Array<Rock>			= [];
	public static var ARE_SELECTED		: Bool					= false;
	public static var NUM_CLICK			: Int					= 0;
	public static var SWIPE_DIR			: SWIPE_DIRECTION		= null;
	public static var AR_SWIPE_ANG		: Array<Float>			= [];
	public static var SWIPE_RATIO		: Float					= 0;
	
	public static var SIZE_OFFSET						:Float = 124;
	public static inline var TIME_DESTROY				= 0.4;
	public static inline var SPEED_HL					= 0.15;
	
	public static var MAX_SPEED			: Float			= 0.9;
	//public static var MAX_SPEED			: Float			= 1.8;
	//public static var Y_SPEED			: Float			= 0.03;
	//public static var X_SPEED			: Float			= 0.02;
	public static var Y_SPEED			: Float			= 0.08;
	public static var X_SPEED			: Float			= 0.04;
	
// SPECIFIC
	var game 					: Game;
	
	public var type				: TypeRock;
	public var valueScore		: Int;
	
	public var ram				: manager.RockAssetManager;
	
	public var cX		: Int;
	public var cY		: Int;
	
	public var dir		: FallDirection;
	public var tweenHL	: mt.motion.Tween;
	
	public var rX		: Float;
	public var rY		: Float;
	
	public var wX		: Float;
	public var wY		: Float;
	
	public var dX		: Float;
	public var dY		: Float;
	
	public var isHL		: Bool;
	
	public var isAnimated			: Bool;
	public var isPickable			: Bool;
	public var isDestroy			: Bool;
	public var hasPhysix			: Bool;
	public var isRotable			: Bool;
	public var isDestroyableByBomb	: Bool;

	// SPECIAL EFFECT
	public var freezeCounter	: Int;
	public var isBubble			: Bool;

	public function new(newCX:Int, newCY:Int, newType:TypeRock, ?specialEffect:Bool = true, ?popNormally:Bool = true) {
		this.game = Game.ME;
		
		init(newCX, newCY, newType, specialEffect, popNormally);
	}
	
	public function init(newCX:Int, newCY:Int, newType:TypeRock, ?specialEffect:Bool = true, ?popNormally:Bool = true) {
		this.cX = newCX;
		this.cY = newCY;
		
		if (isBubble)
			setBubble(false);
		
		if (ram != null)
			ram.destroy(true);
		ram = new manager.RockAssetManager(this);
		
		type = null;
		
		isHL = false;
		
		valueScore = 0;
		
		isPickable = false;
		isDestroy = false;
		isAnimated = true;
		
		hasPhysix = true;
		isRotable = true;
		
		isDestroyableByBomb = true;
		
		freezeCounter = 0;
		isBubble = false;
		
		type = newType;
		
		switch(type) {
			case TypeRock.TRClassic(id) :
				if (id == null)
					throw "No id for TRClassic !";
					
				valueScore = Settings.BASE_SCORE;
				
			case TypeRock.TRMagma :
				hasPhysix = false;
				isRotable = false;
				isDestroyableByBomb = false;
				
			case TypeRock.TRBombCiv :
				
			case TypeRock.TRBlock, TypeRock.TRBlockBreakable, TypeRock.TRHole :
				hasPhysix = false;
				isRotable = false;
				isDestroyableByBomb = false;
				
			case TypeRock.TRBonus :
				
			case TypeRock.TRCog(v) :
				isPickable = true;
				
			case TypeRock.TRLoot(id) :
				isPickable = true;
				if (id == null && SpecialManager.POPRATE_LOOT.totalProba > 0) {
					//type = TypeRock.TRLoot("matterSilver");
					var loot = SpecialManager.POPRATE_LOOT.draw();
					type = TypeRock.TRLoot(loot);
					SpecialManager.POPRATE_LOOT.remove(loot);
				}
				
			case TypeRock.TRFreeze(v) :
				throw "NO TypeRock.TRFREEZE ALLOWED HERE !";
			case TypeRock.TRBubble :
				throw "NO TypeRock.TRBubble ALLOWED HERE !";
		}
		
		ram.setBE(type);
		
	// PHYSIX
		dX = 0;
		dY = 0;
		
		rX = 0.5;
		rY = 0.5;
		
		wX = GET_POS(cX);
		wY = GET_POS(cY);
		
		dir = null;
		
		if (popNormally) {
			function onCompleteTweenPop() {
				isAnimated = false;
			}
			game.tweener.create().to(TIME_DESTROY * Settings.FPS, ram.actualScale = 1).onComplete = onCompleteTweenPop;
		}
		else {
			ram.actualScale = 1;
			isAnimated = false;
		}
		
		update();
		
		if (!ALL.has(this))
			ALL.push(this);
	}
	
	public function showNewHL(r:Rock) {
		if (tweenHL != null)
			tweenHL.dispose();
		tweenHL = game.tweener.create().to((SPEED_HL / 2) * Settings.FPS,	wX = GET_POS(cX) + (GET_POS(r.cX) - GET_POS(cX)) * 0.1,
																			wY = GET_POS(cY) + (GET_POS(r.cY) - GET_POS(cY)) * 0.1);
		
		showHL();
	}
	
	public function showHL() {
		ram.showHL();
		isHL = true;
	}
	
	public function hideHL() {
		if (isHL) {
			if (tweenHL != null)
				tweenHL.dispose();
			tweenHL = game.tweener.create().to((SPEED_HL / 2) * Settings.FPS, wX = GET_POS(cX), wY = GET_POS(cY));			
		}
		
		isHL = false;
		
		ram.hideHL();
	}
	
	public function switchTo(offsetX:Int, offsetY:Int) {
		cX = cX + offsetX;
		cY = cY + offsetY;
		
		isAnimated = true;
		
		//ram.showHL();
		
		var t = game.tweener.create().to((game.levelInfo.level == 1 ? 0.5 : 0.2) * Settings.FPS * (1 - SWIPE_RATIO), wX = GET_POS(cX), wY = GET_POS(cY));
		t.ease(mt.motion.Ease.easeInCubic);
		function onComplete() {
			isAnimated = false;
			ram.hideHL();			
		}
		t.onComplete = onComplete;
	}
	
// SPECIAL
	public function setBubble(create:Bool) {
		if (create) {
			isBubble = true;
			isRotable = false;
			hasPhysix = false;
			SpecialManager.AR_BUBBLE.push(this);
		}
		else { // DELETE
			isBubble = false;
			isRotable = true;
			hasPhysix = true;
			SpecialManager.WATER_CAN_REGEN = false;
			SpecialManager.AR_BUBBLE.remove(this);
		}
		ram.setBubble(create);
	}
	
	public function setFreeze(c:Int) {
		if (c < freezeCounter)
			FX.DESTROY_ICE(this);
		
		freezeCounter = c;
		
		if (freezeCounter == 0) {
			switch (type) {
				case TypeRock.TRLoot, TypeRock.TRCog :
					isPickable = true;
				case TypeRock.TRClassic, TypeRock.TRBubble, TypeRock.TRFreeze, 
						TypeRock.TRBlock, TypeRock.TRBonus, TypeRock.TRMagma,
						TypeRock.TRBlockBreakable, TypeRock.TRHole, TypeRock.TRBombCiv :
			}
		}
		ram.setFreeze(freezeCounter);
	}
	
	public function doBonusEffect(scoreRocks:Int = 0):Int {
		var arRockToDestroy = [];
		if (type != null) { // TODO : Impossible normally
			switch (type) {
				case TypeRock.TRClassic, TypeRock.TRCog, TypeRock.TRBlock, TypeRock.TRHole, TypeRock.TRBubble,
						TypeRock.TRMagma, TypeRock.TRLoot, TypeRock.TRFreeze, TypeRock.TRBlockBreakable, TypeRock.TRBombCiv :
				case TypeRock.TRBonus(tb) :
					switch (tb) {
						case TypeBonus.TBBombMini :
							SoundManager.BOMB_HOR_VER_SFX();
							var r1 = GET_AT(cX - 1, cY);
							if (r1 != null)
								arRockToDestroy.push(r1);
							else
								game.goalManager.updateUnder(cX - 1, cY);
							var r2 = GET_AT(cX + 1, cY);
							if (r2 != null)
								arRockToDestroy.push(r2);
							else
								game.goalManager.updateUnder(cX + 1, cY);
							var r3 = GET_AT(cX, cY - 1);
							if (r3 != null)
								arRockToDestroy.push(r3);
							else
								game.goalManager.updateUnder(cX, cY - 1);
							var r4 = GET_AT(cX, cY + 1);
							if (r4 != null)
								arRockToDestroy.push(r4);
							else
								game.goalManager.updateUnder(cX, cY + 1);
							FX.BOMB(tb, this, arRockToDestroy);
						case TypeBonus.TBBombHor :
							SoundManager.BOMB_HOR_VER_SFX();
							for (x in 0...Settings.GRID_WIDTH) {
								var r = GET_AT(x, this.cY);
								if (r != null)
									arRockToDestroy.push(r);
								else
									game.goalManager.updateUnder(x, this.cY);
							}
							if (game.isEndGame && !tb.match(TypeBonus.TBColor))
								FX.BOMB_END(tb, this);
							else
								FX.BOMB(tb, this, arRockToDestroy);
						case TypeBonus.TBBombVert :
							SoundManager.BOMB_HOR_VER_SFX();
							for (y in 0...Settings.GRID_HEIGHT) {
								var r = GET_AT(this.cX, y);
								if (r != null)
									arRockToDestroy.push(r);
								else
									game.goalManager.updateUnder(this.cX, y);
							}
							if (game.isEndGame && !tb.match(TypeBonus.TBColor))
								FX.BOMB_END(tb, this);
							else
								FX.BOMB(tb, this, arRockToDestroy);
						case TypeBonus.TBBombPlus :
							SoundManager.BOMB_CROSS_PLUS_SFX();
							for (x in 0...Settings.GRID_WIDTH) {
								var r = GET_AT(x, this.cY);
								if (r != null)
									arRockToDestroy.push(r);
								else
									game.goalManager.updateUnder(x, this.cY);
							}
							for (y in 0...Settings.GRID_HEIGHT) {
								var r = GET_AT(this.cX, y);
								if (r != null)
									arRockToDestroy.push(r);
								else
									game.goalManager.updateUnder(this.cX, y);
							}
							if (game.isEndGame && !tb.match(TypeBonus.TBColor))
								FX.BOMB_END(tb, this);
							else
								FX.BOMB(tb, this, arRockToDestroy);
						case TypeBonus.TBBombCross :
							SoundManager.BOMB_CROSS_PLUS_SFX();
							var max = Settings.GRID_WIDTH > Settings.GRID_HEIGHT ? Settings.GRID_WIDTH : Settings.GRID_HEIGHT;
							for (i in 1...max + 1) {
								var r1 = GET_AT(cX - i, cY - i);
								if (r1 != null)
									arRockToDestroy.push(r1);
								else
									game.goalManager.updateUnder(cX - i, cY - i);
								var r2 = GET_AT(cX - i, cY + i);
								if (r2 != null)
									arRockToDestroy.push(r2);
								else
									game.goalManager.updateUnder(cX - i, cY + i);
								var r3 = GET_AT(cX + i, cY - i);
								if (r3 != null)
									arRockToDestroy.push(r3);
								else
									game.goalManager.updateUnder(cX + i, cY - i);
								var r4 = GET_AT(cX + i, cY + i);
								if (r4 != null)
									arRockToDestroy.push(r4);
								else
									game.goalManager.updateUnder(cX + i, cY + i);
							}
							FX.BOMB(tb, this, arRockToDestroy);
						case TypeBonus.TBColor(tr) :
							SoundManager.BOMB_COLOR_SFX();
							if (tr == null) {
								tr = TypeRock.TRClassic(Rock.GET_RANDOM_CLASSIC());
								type = TypeRock.TRBonus(TypeBonus.TBColor(tr));
							}
							for (r in ALL) {
								if (r != null) {
									if (r.type.equals(tr))
										arRockToDestroy.push(r);
								}
								else {
									game.goalManager.updateUnder(r.cX, r.cY);
								}
							}
							FX.BOMB(tb, this, arRockToDestroy);
					}
					if (game.isEndGame && !tb.match(TypeBonus.TBColor))
						FX.BOMB_END(tb, this);
					else
						FX.BOMB(tb, this, arRockToDestroy);
						
					game.goalManager.updateMercuryBomb(this, arRockToDestroy, tb);
					
					for (r in arRockToDestroy) {
						if (r.isDestroyableByBomb && !r.isDestroy) {
							if (r.isBubble) {
								r.setBubble(false);
							}
							else if (r.freezeCounter > 0) {
								r.setFreeze(r.freezeCounter - 1);								
							}
							else {
								//game.goalManager.updateMercuryBomb(this, r, tb);
								var v = Std.int(r.valueScore * (1 + game.multScore * 0.5));
								scoreRocks += v;
								r.destroy(true, false, true);
							}
						}
						else {
							switch (r.type) {
								case TypeRock.TRMagma :
									game.goalManager.updateRockEliminated(r);
									game.goalManager.updateUnder(r.cX, r.cY);
								case TypeRock.TRBlockBreakable(v) :
									if (v == 1) {
										r.destroy(true, false, true);
									}
									else {
										v--;
										r.type = TypeRock.TRBlockBreakable(v);
										r.ram.setBE(r.type);										
									}
								case TypeRock.TRClassic, TypeRock.TRCog, TypeRock.TRHole,
									TypeRock.TRBubble, TypeRock.TRLoot, TypeRock.TRFreeze, 
									TypeRock.TRBlock, TypeRock.TRBonus, TypeRock.TRBlockBreakable,
									TypeRock.TRBombCiv:
							}
						}
					}
			}
		}
		return scoreRocks;
	}
	
	public function resize() {
		ram.resize();
	}
	
	public function destroy(fx:Bool, delay:Bool, goal:Bool) {
		if (!isDestroy) {
			isAnimated = true;
			
			var scoreRocks = 0;
			
			isDestroy = true;
			
			if (tweenHL != null) {
				tweenHL.dispose();
				tweenHL = null;
			}
			
			if (goal) {
				game.goalManager.updateRockEliminated(this);
				game.goalManager.updateUnder(cX, cY);
			}
			
			if (fx) {
				switch (type) {
					case TypeRock.TRBonus :
						SoundManager.BOMB_EXPLODE_SFX();
					default:
				}
				
				FX.DESTROY_ROCK(this, delay, function () {
					scoreRocks = doBonusEffect(scoreRocks);

					var t = game.tweener.create().to(TIME_DESTROY * Settings.FPS, ram.actualScale = 0);
					function onComplete() {
						if (ram != null)
							ram.destroy(fx);
						ram = null;
						
						isAnimated = false;
						
						game.updateScore(scoreRocks);
						
						ALL.remove(this);
						
						if (isBubble)
							SpecialManager.AR_BUBBLE.remove(this);
						
						type = null;
						
						if (SpecialManager.IS_UNDER_LAVA(cX, cY)) {
							init(cX, cY, TypeRock.TRMagma, false, false);
							ram.hide();
						}
					}
					t.onComplete = onComplete;
				});				
			}
			else {
				ram.actualScale = 0;
				ram.resize();
				
				ram.destroy(fx);
				ram = null;
				
				isAnimated = false;
				
				game.updateScore(scoreRocks);
				
				ALL.remove(this);
				
				if (isBubble)
					SpecialManager.AR_BUBBLE.remove(this);
				
				type = null;
				
				if (SpecialManager.IS_UNDER_LAVA(cX, cY)) {
					init(cX, cY, TypeRock.TRMagma, false, false);
					ram.hide();
				}
			}
		}
	}
	
	public function update() {
		if (game.sm.arQueueState[0] == SFall && hasPhysix) {
			function checkLeft() {
				for (r in ALL) {
					if (r != this) {
						if (r.cX == cX && r.cY == cY - 1 && dir != FallDirection.FDLeft)
							return false;
						if (r.cX == cX - 1 && r.cY == cY - 1 && dir != FallDirection.FDLeft)
							return false;
						if (r.cX == cX - 1 && r.cY == cY)
							return false;
						if (r.cX == cX - 1 && r.cY == cY + 1)
							return false;
						if (r.cX == cX - 2 && r.cY == cY && r.dir == FallDirection.FDRight)
							return false;
					}
				}
				
				return true;
			}
			
			function checkRight() {
				for (r in ALL) {
					if (r != this) {
						if (r.cX == cX && r.cY == cY - 1 && dir != FallDirection.FDRight)
							return false;
						if (r.cX == cX + 1 && r.cY == cY - 1 && dir != FallDirection.FDRight)
							return false;
						if (r.cX == cX + 1 && r.cY == cY)
							return false;
						if (r.cX == cX + 1 && r.cY == cY + 1)
							return false;
						if (r.cX == cX + 2 && r.cY == cY && r.dir == FallDirection.FDLeft)
							return false;
					}
				}
				
				return true;
			}
			
			function checkUnder():Bool {
				for (r in ALL) {
					if (r != this) {
						if (r.dir == null && r.cX == cX && r.cY == cY + 1)
							return false;
						if (r.dir == FallDirection.FDDown && r.cX == cX && r.cY == cY + 1 && r.dY <= dY)
							return false;
						if (r.dir == FallDirection.FDRight && r.cX == cX - 1 && r.cY == cY + 1)
							return false;
						if (r.dir == FallDirection.FDLeft && r.cX == cX + 1 && r.cY == cY + 1)
							return false;
					}
				}
				
				return true;
			}
		
			rX += dX;
			rY += dY;
			
			isAnimated = true;
			
			var bSoundFall = false;
			if (dY > 0)
				bSoundFall = true;
			
			if (checkUnder() && cY < Settings.GRID_HEIGHT - 1) {
				dir = FallDirection.FDDown;
				
				dY += Y_SPEED;
				dY *= 0.99;
				
				if (dY > MAX_SPEED)
					dY = MAX_SPEED;
				
				dX = 0;
				rX = 0.5;
			}
			else if (checkLeft() && cX > 0 && cY < Settings.GRID_HEIGHT - 1) {
				dir = FallDirection.FDLeft;
				
				dX -= mt.deepnight.Lib.rnd(X_SPEED, X_SPEED * 2);
				
				dY = 0;
				rY = 0.5;
			}
			else if (checkRight() && cX < Settings.GRID_WIDTH - 1 && cY < Settings.GRID_HEIGHT - 1) {
				dir = FallDirection.FDRight;
				
				dX += mt.deepnight.Lib.rnd(X_SPEED, X_SPEED * 2);
				
				dY = 0;
				rY = 0.5;
			}
			else {
				dir = null;
				
				dX = 0;
				rX = 0.5;
				
				dY = 0;
				rY = 0.5;
				
				isAnimated = false;
			}
			
			if (dY == 0 && bSoundFall) {
						SoundManager.FALL_ROCK_SFX();
			}
			
			while (rX < 0) { rX++; cX--; dir = null; };
			while (rX > 1) { rX--; cX++; dir = null; };
			
			while (rY > 1) { rY--; cY++; dir = null; };
			
			wX = (cX + rX) * Rock.SIZE_OFFSET;
			wY = (cY + rY) * Rock.SIZE_OFFSET;
		}
		
		ram.update();
		
		resize();
	}
	
// STATIC
	public static function GET_POS(c:Float): Int {
		return Std.int((c + 0.5) * (SIZE_OFFSET));
	}
	
	public static function GET_AT(cX:Int, cY:Int):Rock {
		for (r in ALL)
			if (r != null && !r.isDestroy && r.cX == cX && r.cY == cY)
				return r;
				
		return null;
	}
	
	static function IS_NEIGHBOOR_SAME(r1:Rock, r2:Rock):Bool { // TODO : Optimize if possible
		if (r1 == null || r2 == null
		||	r1.freezeCounter > 0 || r2.freezeCounter > 0
		||	r1.isBubble || r2.isBubble
		||	r1.ram.typeID != r2.ram.typeID)
			return false;
		
		if (r1.ram.typeID == r2.ram.typeID
		&& r1.type.match(TypeRock.TRClassic)
		&&	IS_NEIGHBOOR(r1, r2))
			return true;
		else
			return false;
	}
	
	public static function IS_NEIGHBOOR(r1:{cX:Int, cY:Int}, r2:{cX:Int, cY:Int}):Bool {
		if (r1 != null && r2 != null
		&&	((r1.cX == r2.cX	&& r1.cY == r2.cY + 1)
		||	(r1.cX == r2.cX		&& r1.cY == r2.cY - 1)
		||	(r1.cX == r2.cX + 1	&& r1.cY == r2.cY)
		||	(r1.cX == r2.cX - 1	&& r1.cY == r2.cY)))
			return true;
		else
			return false;
	}
	
	public static function CHECK_MOVE_POSSIBLE():Bool {
		for (r in ALL) {
			var tl = r;
			if (tl == null || !tl.isRotable || tl.isBubble || SpecialManager.IS_ON_PATTERN(tl.cX, tl.cY))
				continue;
			var tr = Rock.GET_AT(tl.cX + 1, tl.cY);
			if (tr == null || !tr.isRotable || tr.isBubble || SpecialManager.IS_ON_PATTERN(tr.cX, tr.cY))
				continue;
			var bl = Rock.GET_AT(tl.cX, tl.cY + 1);
			if (bl == null || !bl.isRotable || bl.isBubble || SpecialManager.IS_ON_PATTERN(bl.cX, bl.cY))
				continue;
			var br = Rock.GET_AT(tl.cX + 1, tl.cY + 1);
			if (br == null || !br.isRotable || br.isBubble || SpecialManager.IS_ON_PATTERN(br.cX, br.cY))
				continue;
				
			return true;
		}
		
		return false;
	}
	
	public static function ON_MOUSE_DOWN() {
		if (AR_SEL.length > 0 && !Game.ME.uiTop.pickaxeEnable) {
			Game.ME.showRollOver();
			Game.ME.setRollOver(AR_SEL[0].cX, AR_SEL[0].cY);
			Rock.ARE_SELECTED = true;
		}
	}
	
	public static function ON_MOVE() {
		if (TutoManager.ALLOWED_ROLLOVER()) {
			if (Game.ME.uiTop.pickaxeEnable) {
				var gridMouseX = Std.int(Game.ME.cRocks.mouseX);
				var gridMouseY = Std.int(Game.ME.cRocks.mouseY);
				var checkCX = Std.int(gridMouseX / Rock.SIZE_OFFSET);
				var checkCY = Std.int(gridMouseY / Rock.SIZE_OFFSET);
				
				if (checkCX >= 0
				&&	checkCX <= Settings.GRID_WIDTH - 1
				&&	checkCY >= 0
				&&	checkCY <= Settings.GRID_HEIGHT - 1) {
					for (r in ALL)
						r.hideHL();
						
					AR_SEL = [];
					
					AR_SEL.push(Rock.GET_AT(checkCX, checkCY));
					
					for (r in AR_SEL)
						if (!r.isRotable && !r.type.match(TypeRock.TRBlockBreakable)) {
							AR_SEL = [];
							return;
						}
					
					for (r in AR_SEL)
						r.showHL();
					
					FX.ROLL_OVER(AR_SEL);
					
					Game.ME.setRollOverPickaxe(AR_SEL[0].cX, AR_SEL[0].cY);
					
					Game.ME.showRollOverPickaxe();
					
					Rock.ARE_SELECTED = false;
				}
				else {
					for (r in ALL)
						r.hideHL();
					
					AR_SEL = [];
					
					Game.ME.hideRollOverPickaxe();
					
					Rock.ARE_SELECTED = false;
				}
			}
			else if (Game.ME.clickIsEnable) {
				//var gridMouseX = Std.int(Game.ME.cRocks.mouseX);
				//var gridMouseY = Std.int(Game.ME.cRocks.mouseY);
				var gridMouseX = Std.int(Game.ME.cRocks.mouseX - Rock.SIZE_OFFSET / 2);
				var gridMouseY = Std.int(Game.ME.cRocks.mouseY - Rock.SIZE_OFFSET / 2);
				var checkCX = Std.int(gridMouseX / Rock.SIZE_OFFSET);
				var checkCY = Std.int(gridMouseY / Rock.SIZE_OFFSET);
				
				var r = Rock.GET_AT(checkCX, checkCY);
				
				if (r != null
				&&	gridMouseX >= 0
				&&	gridMouseY >= 0
				&&	checkCX >= 0
				&&	checkCX <= Settings.GRID_WIDTH - 1
				&&	checkCY >= 0
				&&	checkCY <= Settings.GRID_HEIGHT - 1) {
					if (AR_SEL.length == 4
					&&	(AR_SEL[0] == r))
						return;
					else {
						for (r in ALL)
							r.hideHL();
							
						if (checkCX == Settings.GRID_WIDTH - 1)
							checkCX--;
						
						if (checkCY == Settings.GRID_HEIGHT - 1)
							checkCY--;
							
						AR_SEL = [];
						
						SWIPE_RATIO = 0.;
						SWIPE_DIR = null;
						
						SET_ROLLOVER(checkCX, checkCY);
					}
				}
				else {
					for (r in ALL)
						r.hideHL();
					
					AR_SEL = [];
					
					Game.ME.hideRollOver();
					Rock.ARE_SELECTED = false;
				}
			}
			
			if (Game.ME.hintSelected != null) {
				for (rsel in AR_SEL)
					for (i in 0...2)
						for (j in 0...2)
							if (rsel.cX == Game.ME.hintSelected.x + i && rsel.cY == Game.ME.hintSelected.y + j) {
								Game.ME.hideHint();				
								return;
							}
			}
		}
	}
	
	public static function SET_ROLLOVER(cXTL:Int, cYTL:Int, showHL:Bool = true) { // TOPLEFT
		for (r in AR_SEL)
			r.hideHL();
			
		AR_SEL = [];
		
		AR_SEL.push(Rock.GET_AT(cXTL, cYTL));
		AR_SEL.push(Rock.GET_AT(cXTL + 1, cYTL));
		AR_SEL.push(Rock.GET_AT(cXTL, cYTL + 1));
		AR_SEL.push(Rock.GET_AT(cXTL + 1, cYTL + 1));
		
		for (r in AR_SEL)
			if (r == null || !r.isRotable || SpecialManager.IS_ON_PATTERN(r.cX, r.cY)) {
				AR_SEL = [];
				Game.ME.hideRollOver();
					
				Rock.ARE_SELECTED = false;
				return;
			}
		
		if (showHL) {
			AR_SEL[0].showNewHL(AR_SEL[1]);
			AR_SEL[1].showNewHL(AR_SEL[3]);
			AR_SEL[2].showNewHL(AR_SEL[0]);
			AR_SEL[3].showNewHL(AR_SEL[2]);			
		}
		
		FX.ROLL_OVER(AR_SEL);
		
		//Game.ME.showRollOver();
		//Game.ME.setRollOver(cXTL, cYTL);
		Rock.ARE_SELECTED = true;
		
		SoundManager.ROLLOVER_ROCKS_SFX();
	}
	
	public static function SWITCH() {
		var game = Game.ME;
		
		if (TutoManager.ALLOWED_CLICK()) {
			if (game.uiTop.pickaxeEnable && AR_SEL.length > 0) {
				game.movesWithoutCombo++;
				SoundManager.PICKAXE_SFX();
				game.sm.arQueueState.shift();
				game.sm.arQueueState.unshift(State.SSwitch);
				AR_SEL[0].destroy(true, false, true);
				game.sm.arQueueState.push(State.SFall);
				game.uiTop.costBooster();
				
				for (r in AR_SEL)
					r.hideHL();
				
				AR_SEL = [];
				
				Game.ME.hideRollOverPickaxe();
				
				SpecialManager.IS_PICKAXE = true;
				
				Rock.ARE_SELECTED = false;
			}
			else if (AR_SEL.length == 4) {
				game.clickIsEnable = false;
				
				game.sm.arQueueState.shift();
				game.sm.arQueueState.unshift(State.SSwitch);
				
				AR_SEL[0].switchTo(1, 0);
				AR_SEL[1].switchTo(0, 1);
				AR_SEL[2].switchTo(0, -1);
				AR_SEL[3].switchTo( -1, 0);
				
				if (game.levelInfo.level < 10)
					PREVIOUS_SEL = AR_SEL;
				
				AR_SEL = [];
				
				SoundManager.ROTATION_ROCKS_SFX();
				
				game.sm.arQueueState.push(State.SSolver);
			}
			
			game.hideHint();
		}
	}
	
	public static function CHECK_SOLVER() {
		var game = Game.ME;
		
		Game.ME.hideRollOver();
		Rock.ARE_SELECTED = false;
		
		var arRockVerified = [];
		
		var arPack:Array<Array<Rock>>	= [];
		
		for (r in ALL) {
			if (r != null) {
				if (arRockVerified[r.cX + r.cY * Settings.GRID_WIDTH] == null) {
					arRockVerified[r.cX + r.cY * Settings.GRID_WIDTH] = r;
					
					var i = arPack.push([r]);
					var pack = arPack[i - 1];
					
					for (rp in pack) {
						for (rc in ALL) {
							if (arRockVerified[rc.cX + rc.cY * Settings.GRID_WIDTH] == null
							&&	IS_NEIGHBOOR_SAME(rp, rc)) {
								pack.push(rc);
								arRockVerified[rc.cX + rc.cY * Settings.GRID_WIDTH] = rc;
							}
						}
					}
				}				
			}
		}
		
		var arRockDeleted:Array<{cX:Int, cY:Int, type:TypeRock}>	= [];
		var numPackDeleted	= 0;
		var scoreRocks		= 0;
		var isLeft			= true;
		
		inline function checkLineOrColumn(p:Array<Rock>):Bool {
			var l = true;
			var c = true;
			for (i in 1...p.length) {
				if (p[i].cX != p[i - 1].cX)
					l = false;
				if (p[i].cY != p[i - 1].cY)
					c = false;
			}
			return l || c;
		}
		
		for (p in arPack) {
			if (p.length >= 4) {
				if (game.levelInfo.level > 1) {
					if (game.levelInfo.level == 2) {
						if (p.length >= 5) {
							var n = Std.random(p.length);
							var r = new Rock(p[n].cX, p[n].cY, TypeRock.TRBonus(TypeBonus.TBBombMini), false, false);
							FX.FX_VANISH(r.cX, r.cY);
							SoundManager.BOMB_POP_SFX();
						}
					}
					else {
						if (p.length == 5) {
							var n = Std.random(p.length);
							var r = new Rock(p[n].cX, p[n].cY, TypeRock.TRBonus(TypeBonus.TBBombMini), false, false);
							FX.FX_VANISH(r.cX, r.cY);
							SoundManager.BOMB_POP_SFX();
						}
						else if (p.length == 6) {
							var bonus = Std.random(2) == 0 ? TypeBonus.TBBombHor : TypeBonus.TBBombVert;
							var n = Std.random(p.length);
							var r = new Rock(p[n].cX, p[n].cY, TypeRock.TRBonus(bonus), false, false);
							FX.FX_VANISH(r.cX, r.cY);
							SoundManager.BOMB_POP_SFX();
						}
						else if (p.length == 7) {
							var bonus = Std.random(2) == 0 ? TypeBonus.TBBombPlus : TypeBonus.TBBombCross;
							var n = Std.random(p.length);
							var r = new Rock(p[n].cX, p[n].cY, TypeRock.TRBonus(bonus), false, false);
							FX.FX_VANISH(r.cX, r.cY);
							SoundManager.BOMB_POP_SFX();
						}
						else if (p.length >= 8) {
							var n = Std.random(p.length);
							var r = new Rock(p[n].cX, p[n].cY, TypeRock.TRBonus(TypeBonus.TBColor()), false, false);
							FX.FX_VANISH(r.cX, r.cY);
							SoundManager.BOMB_POP_SFX();
						}						
					}
				}
				
				if (checkLineOrColumn(p)) { // Double score
					var lMax:Int = p.length < 7 ? p.length : 7;
					var mult = 1.;
					switch (lMax) {
						case 4 : mult = 1.5;
						case 5 : mult = 2;
						case 6 : mult = 2.5;
						case 7 : mult = 3;
					}
					
					for (rp in p)
						rp.valueScore = Std.int(rp.valueScore * mult);
				}
				
				numPackDeleted++;
				for (rp in p) {
					if (rp.cX >= Std.int(Settings.GRID_WIDTH / 2))
						isLeft = false;
					var v = Std.int(rp.valueScore * (1 + 0.5 * (p.length - 4)) * (1 + game.multScore * 0.5));
					scoreRocks += v;
					//FX.POINT_ROCK(rp.cX, rp.cY, Std.string(v));
					arRockDeleted.push({cX:rp.cX, cY:rp.cY, type:rp.type});
					rp.destroy(true, true, true);
				}
				
			// MERCURY
				game.goalManager.updateMercury(p);
			}
		}
		
		if (numPackDeleted == 0) {
			game.movesWithoutCombo++;
			if (PREVIOUS_SEL.length == 4 && game.multScore == 0) {
				PREVIOUS_SEL[0].switchTo(-1, 0);
				PREVIOUS_SEL[1].switchTo(0, -1);
				PREVIOUS_SEL[2].switchTo(0, 1);
				PREVIOUS_SEL[3].switchTo(1, 0);
				
				Game.ME.sm.arQueueState.push(State.SIdle);
			}
			else {
				if (game.multScore == 0 && !game.isEndGame && !SpecialManager.IS_PICKAXE)
					game.uiTop.costMove();
				Game.ME.sm.arQueueState.push(State.SRegen);
			}
			
			PREVIOUS_SEL = [];
			
		}
		else {
			if (game.multScore == 0 && !game.isEndGame && !SpecialManager.IS_PICKAXE)
				game.uiTop.costMove();
			game.movesWithoutCombo = 0;
			
			SoundManager.COMBO_SFX(game.multScore);
			if (game.multScore > 0 && !game.isEndGame)
				FX.COMBO(game.multScore + 1, isLeft);
			Game.ME.sm.arQueueState.push(State.SFall);
		}
		
		game.updateScore(scoreRocks);
		
		game.multScore++;
		game.numPackDeleted += numPackDeleted;
		
		manager.SpecialManager.END_SOLVER(arRockDeleted);
	}

	public static function FALL() {
		//Rock.UPDATE();
		for (r in ALL)
			if (r.hasPhysix)
				r.isAnimated = true;
		
		Game.ME.sm.arQueueState.push(State.SSolver);
	}
	
	public static function GRIP() {
		//if (GripZone.PICK())
			//Game.ME.sm.arQueueState.push(State.SFall);
		//else
			//Game.ME.sm.arQueueState.push(State.SRegen);
	}
	
	public static function IS_ROTABLE(cX:Int, cY:Int, tr:TypeRock):Bool {
		var rock = GET_AT(cX, cY);
		if (rock != null && !rock.isRotable)
			return false;
			
		for (b in SpecialManager.AR_BUBBLE)
			if (b.cX == cX && b.cY == cY)
				return false;
				
		if (SpecialManager.IS_ON_PATTERN(cX, cY))
			return false;
			
		switch (tr) {
			case TypeRock.TRBlock, TypeRock.TRBlockBreakable, TypeRock.TRBubble, TypeRock.TRMagma, TypeRock.TRHole :
				return false;
			default :
				return true;
		}
	}
	
	public static function NEW_REGEN(arManualRocks:Array<{tr:TypeRock, x:Int, y:Int}>, ?firstInit:Bool = false, ?specialEffect:Bool = true, ?popNormally:Bool = true) {
		var rm = new RegenManager(arManualRocks, firstInit, specialEffect);
		
		if (rm.isOneMovePossible) {
		// APPLY REGEN
			for (x in 0...Settings.GRID_WIDTH) {
				for (y in 0...Settings.GRID_HEIGHT) {
					var e = rm.getAt(x, y);
					var r = GET_AT(x, y);
					if (e == null)
						throw "FAIL NEW REGEN";
					else {
						if (r == null) {
							if (SpecialManager.IS_UNDER_LAVA(x, y)) {
								var rock = new Rock(x, y, TypeRock.TRMagma, false, false);
								rock.ram.hide();
							}
							else {
								var rock = new Rock(x, y, e.r.tr, specialEffect, popNormally);
								SpecialManager.AR_NEW_REGEN.push(rock);
								if (e.freezeC > 0)
									rock.setFreeze(e.freezeC);
							}
						}
					}
				}
			}
			
			rm.destroy();
			rm = null;
			
			if (!firstInit)
				Game.ME.sm.arQueueState.push(State.SSpecial);			
		}
		else
			Game.ME.sm.arQueueState.push(State.SRegenFull);
	}
	
	public static function REGEN_FULL() {
		var c = 0;
		var d = 0;
		for (r in ALL.copy()) {
			d++;
			if (r != null && IS_ROTABLE(r.cX, r.cY, r.type) && r.freezeCounter == 0) {
				switch (r.type) {
					case TypeRock.TRClassic :
						c++;
						r.destroy(false, false, false);
					default :
				}
			}
		}
		
		Game.ME.sm.arQueueState.push(State.SRegen);
	}
	
	public static function SPECIAL_AT_END() {
		manager.SpecialManager.END_REGEN();
	}
	
	static var actualCheck		: { x:Int, y:Int };
	public static var arHint			: Array<{ x:Int, y:Int, pack:Array<Rock> }>		= [];
	public static var checkHintIsDone	: Bool							= false;
	
	public static function CHECK_HINT() {
		if (actualCheck == null)
			RESET_HINT();
		
		var cX = actualCheck.x;
		var cY = actualCheck.y;
		
		var arSpin = [];
		
		arSpin.push(Rock.GET_AT(cX, cY));
		arSpin.push(Rock.GET_AT(cX + 1, cY));
		arSpin.push(Rock.GET_AT(cX, cY + 1));
		arSpin.push(Rock.GET_AT(cX + 1, cY + 1));
		
		arSpin[0].cX += 1;
		arSpin[1].cY += 1;
		arSpin[2].cY -= 1;
		arSpin[3].cX -= 1;
		
		function end() {
			arSpin[0].cX -= 1;
			arSpin[1].cY -= 1;
			arSpin[2].cY += 1;
			arSpin[3].cX += 1;
			
			if (actualCheck.x == Settings.GRID_WIDTH - 2 && actualCheck.y == Settings.GRID_HEIGHT - 2) {
				checkHintIsDone = true;
			}
			else {
				actualCheck.x += 1;
				if (actualCheck.x >= Settings.GRID_WIDTH - 1) {
					actualCheck.x = 0;
					actualCheck.y += 1;
				}
			}
		}
		
		for (r in arSpin)
			if (!r.isRotable || r.freezeCounter > 0 || !r.type.match(TypeRock.TRClassic) || SpecialManager.IS_ON_PATTERN(r.cX, r.cY)) {
				end();
				return;
			}
		
		var arRockVerified = [];
		
		var arPack:Array<Array<Rock>>	= [];
		
		for (r in ALL) {
			if (r != null) {
				if (arRockVerified[r.cX + r.cY * Settings.GRID_WIDTH] == null) {
					arRockVerified[r.cX + r.cY * Settings.GRID_WIDTH] = r;
					
					var i = arPack.push([r]);
					var pack = arPack[i - 1];
					
					for (rp in pack) {
						for (rc in ALL) {
							if (arRockVerified[rc.cX + rc.cY * Settings.GRID_WIDTH] == null
							&&	IS_NEIGHBOOR_SAME(rp, rc)) {
								pack.push(rc);
								arRockVerified[rc.cX + rc.cY * Settings.GRID_WIDTH] = rc;
								
							}
						}
					}
					
					if (pack.length >= 4) {
						arHint.push( { x:cX, y:cY, pack:pack } );
						end();
						return;
					}
				}				
			}
		}
		
		end();
	}
	
	public static function RESET_HINT() {
		actualCheck = { x:0, y:0 };
		arHint = [];
		checkHintIsDone = false;
	}
	
// POP ELEMENT
	static function GET_RANDOM_TYPEROCK():Int {
		var tr = null;
		var i = 0;
		while (tr == null) {
			i = Game.ME.rndS.random(SpecialManager.POPRATE_ELEMENT.length);
			tr = SpecialManager.POPRATE_ELEMENT[i];
			switch (tr) {
				case TypeRock.TRBlock, TypeRock.TRBonus, 
						TypeRock.TRMagma, TypeRock.TRBubble,
						TypeRock.TRBlockBreakable, TypeRock.TRHole,
						TypeRock.TRCog :
					throw "No " + tr + " can pop";
				case TypeRock.TRLoot :
					if (SpecialManager.LOOT_SPAWNED >= Settings.MAX_LOOT_BY_GRID)
						tr = null;
					else
						SpecialManager.LOOT_SPAWNED++;
				case TypeRock.TRClassic, TypeRock.TRFreeze, TypeRock.TRBombCiv :
			}
		}
		return i;
	}
	
	public static function GET_RANDOM_CLASSIC():String {
		var ar = GET_AVAILABLE_CLASSIC();
		
		return ar[Game.ME.rndS.random(ar.length)];
	}
	
	public static function GET_AVAILABLE_CLASSIC():Array<String> {
		var ar = [];
		for (c in Game.ME.levelInfo.arDeck) {
			if (c.t.match(TypeRock.TRClassic))
				ar.push(c.t.getParameters()[0]);
		}
		
		return ar;
	}
	
	static function STILL_CLASSIC_IN_DECK():Bool {
		for (e in SpecialManager.POPRATE_ELEMENT) {
			if (e.match(TypeRock.TRClassic))
				return true;
		}
		
		return false;
	}
	
	public static function CHECK_TR_IN_DECK(tr:TypeRock):Bool {
		var levelInfo = Game.ME.levelInfo;
		
		for (c in levelInfo.arDeck) {
			if (c.t.getIndex() == tr.getIndex())
				return true;
		}
		
		return false;
	}
	
	public static function RESIZE() {
		SIZE_OFFSET = Math.fround(124 * Settings.STAGE_SCALE #if standalone * 0.65 #end);
		
		for (r in ALL)
			if (r != null) {
				r.wX = GET_POS(r.cX);
				r.wY = GET_POS(r.cY);
				r.resize();
				r.ram.newResize();
			}
	}
	
	public static function DESTROY(animDestroy:Bool) {
		for (r in ALL)
			if (r != null) {
				if (animDestroy) {
					switch (r.type) {
						case TypeRock.TRHole :
						default :
							Game.ME.delayer.addFrameBased(function() {
								//r.destroy(false, false);
								r.destroy(true, true, false);
							}, 0.08 * (Settings.GRID_HEIGHT - 1 - r.cY) * Settings.FPS);
					}
				}
				else
					r.destroy(false, false, false);
			}
		
		ALL = [];
		AR_SEL = [];
		PREVIOUS_SEL = [];
		AR_SWIPE_ANG = [];
	}

	public static function UPDATE() {
		//ROLL_OVER();
		
		for (r in ALL)
			if (r != null)
				r.update();
				
		//trace(ALL.length);
	}
}