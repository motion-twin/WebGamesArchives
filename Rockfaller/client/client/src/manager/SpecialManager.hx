package manager;

import manager.SpecialManager.Geyser;
import mt.deepnight.slb.HSprite;

import Common;

import data.Settings;
import data.LevelDesign;
import process.Game;
import manager.StateManager;

/**
 * ...
 * @author Tipyx
 */
class SpecialManager
{
	public static var POPRATE_ELEMENT		: Array<TypeRock>;
	public static var POPRATE_LOOT			: mt.RandList<String>;
	public static var AR_NEW_REGEN			: Array<Rock>;
	
// WATER
	public static var WATER_LEVEL		: Int														= 0;
	public static var WATER_CAN_REGEN	: Bool														= true;
	public static var AR_BUBBLE			: Array<Rock>												= [];
	
// MAGMA
	public static var MAGMA_LEVEL		: Int														= 0;
	public static var MAGMA_IS_DONE		: Bool														= false;
	public static var AR_MAGMA			: Array<Magma>												= [];
	
// FREEZE
	public static var FREEZE_ENABLE		: Bool														= false;
	
// BOMB CIV
	public static var BOMBCIV_IS_DONE	: Bool														= false;
	public static var BOMBCIV_EXPLODED	: Bool														= false;
	
// PATTERN
	public static var PATTERN_ENABLE	: Bool														= false;
	public static var PATTERN_IS_DONE	: Bool														= false;
	public static var PATTERN_AR		: Array<{cX:Int, cY:Int, z:Int}>							= [];
	public static var PATTERN_MAX		: Int														= 0;
	public static var PATTERN_ACTUAL	: Int														= 0;
	
// GEYSER
	public static var GEYSER_ENABLE		: Bool														= false;
	public static var GEYSER_IS_DONE	: Bool														= false;
	public static var AR_GEYSER			: Array<Geyser>												= [];
	
// LOOT
	public static var LOOT_SPAWNED		: Int														= 0;
	
	public static var IS_PICKAXE		: Bool														= false;
	
	public static function INIT() {
		var game = Game.ME;
		
		var levelInfo = Game.ME.levelInfo;
		
		if (levelInfo.level == 6)
			Settings.MAX_LOOT_BY_GRID = 1;
		else
			Settings.MAX_LOOT_BY_GRID = 3;
		
		for (ts in levelInfo.arGP) {
			switch (ts) {
				case TypeGP.TGWater :
					WATER_LEVEL = 1;
				case TypeGP.TGMagma :
					MAGMA_LEVEL++;
					MAGMA_IS_DONE = false;
				case TypeGP.TGFreeze(v) :
				case TypeGP.TGBombCiv(n) :
				case TypeGP.TGPattern(ar) :
					PATTERN_ENABLE = true;
					PATTERN_AR = ar;
				case TypeGP.TGGeyser(ar) :
					GEYSER_ENABLE = true;
					for (g in ar) {
						var geyser = new Geyser(g.y, g.isLeft);
						game.root.add(geyser, Settings.DM_GELAT);
						AR_GEYSER.push(geyser);
					}
			}
		}
		
		if (PATTERN_ENABLE) {
			PATTERN_MAX = 0;
			
			for (e in PATTERN_AR) {
				if (e.z > PATTERN_MAX)
					PATTERN_MAX = e.z;
					
				game.arPattern.push( { arCloud:[], cX:e.cX, cY:e.cY, z:e.z } );
				
				var c = 0;
				
				for (el in PATTERN_AR) {
					if (el != e && el.z == e.z) {
						if (el.cX == e.cX + 1 && el.cY == e.cY)
							c++;
						else if (el.cX == e.cX && el.cY == e.cY + 1)
							c++;
						else if (el.cX == e.cX + 1 && el.cY == e.cY + 1)
							c++;
					}
				}
				
				if (c == 3) {
					game.arPattern.push( { arCloud:[], cX:e.cX + 0.5, cY:e.cY + 0.5, z:e.z } );
				}
			}
			
			PATTERN_ACTUAL = 0;
		}
		
		if (Game.ME.levelInfo.level > 2) {
			POPRATE_LOOT = new mt.RandList(Game.ME.rndS.random);
			for (l in LevelDesign.AR_LOOT)
				if (levelInfo.level >= l.levelMin && levelInfo.level <= l.levelMax)
					POPRATE_LOOT.add(l.namePNG, l.poprate);
		}
		
		SHUFFLE_DECK();
	}

	public static function SHUFFLE_DECK() {
	// INIT DECK
		trace("SET & SHUFFLE DECK !");
	
		POPRATE_ELEMENT = [];
		
		var levelInfo = Game.ME.levelInfo;
		
		for (c in levelInfo.arDeck) {
			for (i in 0...c.v)
				POPRATE_ELEMENT.push(c.t);
		}
		
		function randomArray(ar:Array<TypeRock>) {
			var length:Int= ar.length;
			var mixed:Array<TypeRock> = ar.slice(0, length);
			var rn:Int;
			var el:TypeRock;
			for (i in 0...ar.length) {
				el = mixed[i];
				rn = Math.floor(Math.random() * length);
				mixed[i] = mixed[rn];
				mixed[rn] = el;
			}
			return mixed;
		}
		
		if (Game.ME.levelInfo.level > 5) {
			if (POPRATE_LOOT.totalProba > 0) {
				var poprateLoot = 2;
				if (!LevelDesign.TUTO_IS_DONE(6) && Game.ME.levelInfo.level == 6)
					poprateLoot = Std.int(POPRATE_ELEMENT.length / 2);
				for (i in 0...poprateLoot) {
					POPRATE_ELEMENT.push(TypeRock.TRLoot());					
				}
			}
		}
		
		POPRATE_ELEMENT = randomArray(POPRATE_ELEMENT);
	}
	
	public static function END_SWITCH():Bool {
		return true;
	}
	
	public static function END_SOLVER(arRockDeleted:Array<{cX:Int, cY:Int, type:TypeRock}>) {
		var bLoot = false;
		for (r in Rock.ALL) {
			if (r != null && !r.isBubble && r.freezeCounter == 0) {
				switch (r.type) {
					case TypeRock.TRLoot :
						for (dr in arRockDeleted)
							if (Rock.IS_NEIGHBOOR(dr, r)) {
								Game.ME.grip.arRockToDo.push(r);
								Game.ME.grip.arRockDeleted = arRockDeleted;
								bLoot = true;
								if (!Game.ME.grip.isPicking)
									Game.ME.grip.pick();
								break;
							}
					default :
				}
			}
		}
		
		if (bLoot)
			return;
			
		for (r in Rock.ALL) {
			if (r != null) {
				var b = true;
				for (dr in arRockDeleted) {
					if (Rock.IS_NEIGHBOOR(dr, r)) {
						if (r.isBubble) {
							b = false;
							r.setBubble(false);
							break;
						}
						else if (r.freezeCounter > 0) {
							b = false;
							r.setFreeze(r.freezeCounter - 1);
							break;
						}
					}
				}
				switch (r.type) {
					case TypeRock.TRBonus(tb) :
						for (dr in arRockDeleted)
							if (dr.cX == r.cX && dr.cY == r.cY) {
								b = false;
								break;
							}
						if (b) {
							for (dr in arRockDeleted) {
								if (Rock.IS_NEIGHBOOR(dr, r) && dr.type != null) {
									switch (tb) {
										case TypeBonus.TBColor :
											switch (dr.type) {
												case TypeRock.TRClassic :
													r.type = TypeRock.TRBonus(TypeBonus.TBColor(dr.type));
												default :
													r.type = TypeRock.TRBonus(TypeBonus.TBColor(TypeRock.TRClassic(Rock.GET_RANDOM_CLASSIC())));
											}
										case TypeBonus.TBBombCross, TypeBonus.TBBombPlus,
												TypeBonus.TBBombHor, TypeBonus.TBBombVert,
												TypeBonus.TBBombMini :
									}
									r.destroy(true, false, true);
								}								
							}
						}
					case TypeRock.TRBlockBreakable(v) :
						for (dr in arRockDeleted)
							if (Rock.IS_NEIGHBOOR(dr, r)) {
								if (v == 1) {
									r.destroy(true, false, true);
								}
								else {
									SoundManager.BLOC_BREAKABLE_SFX();
									v--;
									r.type = TypeRock.TRBlockBreakable(v);
									r.ram.setBE(r.type);
								}
								break;
							}
					case TypeRock.TRBombCiv(n) :
						for (dr in arRockDeleted) {
							if (b && Rock.IS_NEIGHBOOR(dr, r)) {
								r.destroy(true, false, true);
							}
						}
					case TypeRock.TRLoot :
						for (dr in arRockDeleted)
							if (b && Rock.IS_NEIGHBOOR(dr, r))
								throw "TypeRock.TRLoot not possible here";
					case TypeRock.TRBubble, TypeRock.TRClassic, TypeRock.TRFreeze,
							TypeRock.TRCog, TypeRock.TRBlock, TypeRock.TRMagma, TypeRock.TRHole :
				}					
			}
		}
	}
	
	public static function END_FALL():Bool {
		return true;
	}
	
	public static function END_REGEN() {
		if (!IS_PICKAXE) {
			if (!GEYSER_IS_DONE && GEYSER_ENABLE) {
				Game.ME.sm.arQueueState.push(State.SGeyser);
			}
			else if (WATER_LEVEL > 0 && WATER_CAN_REGEN) {
				Game.ME.sm.arQueueState.push(State.SWater);
			}
			else if (MAGMA_LEVEL > 0 && !MAGMA_IS_DONE) {
				Game.ME.sm.arQueueState.push(State.SMagma);
			}
			else if (!BOMBCIV_IS_DONE) {
				Game.ME.sm.arQueueState.push(State.SBombCiv);
			}
			else if (!PATTERN_IS_DONE && PATTERN_ENABLE) {
				Game.ME.sm.arQueueState.push(State.SPattern);
			}			
		}
	}
	
	public static function END_TURN() {
		WATER_CAN_REGEN = true;
		MAGMA_IS_DONE = false;
		BOMBCIV_IS_DONE = false;
		PATTERN_IS_DONE = false;
		GEYSER_IS_DONE = false;
		
		IS_PICKAXE = false;
		
		TutoManager.END_TURN();
	}
	
// CHECK DIFFERENT SPECIAL EFFECT
	public static function WATER() {
		for (i in 0...WATER_LEVEL) {
			var r = null;
			var i = 0;
			while (r == null && i < Settings.GRID_WIDTH * Settings.GRID_HEIGHT * 10 ) {
				i++;
				var nr = Rock.GET_AT(Game.ME.rndS.random(Settings.GRID_WIDTH), Game.ME.rndS.random(Settings.GRID_HEIGHT));
				for (b in AR_BUBBLE)
					if (Rock.IS_NEIGHBOOR(nr, b) && !nr.isBubble && nr.isRotable)
						r = nr;
			}
			if (r != null)
				r.setBubble(true);
		}
		
		WATER_CAN_REGEN = false;
		
		Game.ME.sm.arQueueState.push(State.SFall);
	}
	
	public static function MAGMA() {
		var game = Game.ME;
		
		for (m in AR_MAGMA.copy()) {
			if (m.life == 0) {
				m.destroy();
				AR_MAGMA.remove(m);
			}
			else
				m.nextStep();
		}
		
		if (game.levelInfo.level <= 120)
			MAGMA_LEVEL = 1;
		
		if (AR_MAGMA.length < MAGMA_LEVEL) {
			var cX = 0;
			var b = true;
			while (b) {
				cX = Game.ME.rndS.random(Settings.GRID_WIDTH);
				b = false;
				for (m in AR_MAGMA)
					if (m.cX == cX)
						b = true;
			}
			
			var m = new Magma(cX);
			game.cRocks.add(m, Game.DM_ROVER);
			AR_MAGMA.push(m);
		}
		
		MAGMA_IS_DONE = true;
		
		game.sm.arQueueState.push(State.SFall);
	}
	
	public static function IS_UNDER_LAVA(cX:Int, cY:Int):Bool {
		for (m in AR_MAGMA) {
			if (m.cX == cX && cY >= (Settings.GRID_HEIGHT - m.gcY))
				return true;
		}
		
		return false;
	}
	
	public static function BOMB_CIV_CD() {
		var game = Game.ME;
		
		if (!game.goalManager.checkEnd()) {
			for (r in Rock.ALL) {
				switch (r.type) {
					case TypeRock.TRBombCiv(n) :
						SoundManager.BOMB_CIV_SFX();
						var b = true;
						for (rg in AR_NEW_REGEN)
							if (r.cX == rg.cX && r.cY == rg.cY)
								b = false;
						if (b) {
							n -= 1;
							r.init(r.cX, r.cY, TypeRock.TRBombCiv(n), false, false);								
						}
						if (n == 0) {
							r.isAnimated = true;
							game.delayer.addFrameBased("", function () {
								SoundManager.BOMB_CIV_EXPLODE_SFX();
								var cX = r.cX;
								var cY = r.cY;
								
								r.destroy(true, false, true);
								
								for (ro in Rock.ALL) {
									var dist = mt.deepnight.Lib.distance(ro.cX, ro.cY, cX, cY);
									game.delayer.addFrameBased("", function () {
										ro.destroy(true, false, false);
									}, 0.2 * Settings.FPS * dist);
								}
							}, 0.3 * Settings.FPS);
							BOMBCIV_EXPLODED = true;
							
							return;
						}
					default :
				}
			}
		}
		
		BOMBCIV_IS_DONE = true;
		
		game.sm.arQueueState.push(State.SFall);
	}
	
	public static function PATTERN() {
		var game = Game.ME;
		
		if (PATTERN_MAX > 0) {
			PATTERN_ACTUAL++;
			
			if (PATTERN_ACTUAL > PATTERN_MAX)
				PATTERN_ACTUAL = 0;
			
		}
		PATTERN_IS_DONE = true;
		game.sm.arQueueState.push(State.SFall);
	}
	
	public static function IS_ON_PATTERN(cX:Int, cY:Int):Bool {
		for (e in PATTERN_AR)
			if (e.cX == cX && e.cY == cY && e.z == PATTERN_ACTUAL)
				return true;
				
		return false;
	}
	
	public static function CREATE_MERCURY(cX:Int, cY:Int) {
		var r = Rock.GET_AT(cX, cY);
		
		if (IS_ON_MERCURY(cX, cY) || (r != null && r.type.match(TypeRock.TRHole)))
			return;
		
		var game = Game.ME;
		
		var mercUnder = Settings.SLB_GRID.hbe_get(game.bmUnderMerc, "mercury");
		mercUnder.setCenterRatio(0.5, 0.5);
		mercUnder.x = Rock.GET_POS(cX);
		mercUnder.y = Rock.GET_POS(cY);
		mercUnder.alpha = 1 - Game.ME.rndS.random(10) / 100;
		mercUnder.rotation = Game.ME.rndS.random(4) * (1.56);
		
		mercUnder.scaleX = mercUnder.scaleY = 0;
		game.tweener.create().to(0.2 * Settings.FPS, mercUnder.scaleX = mercUnder.scaleY = Settings.STAGE_SCALE);
		
		game.arMerc.push( { hbeUnder:mercUnder, cX:cX, cY:cY } );
	}
	
	public static function IS_ON_MERCURY(cX:Int, cY:Int):Bool {
		var arMerc = Game.ME.arMerc;
		if (arMerc != null) {
			for (m in arMerc)
				if (m.cX == cX && m.cY == cY)
					return true;
			return false;
		}
		else
			return false;
	}
	
	public static function GEYSER() {
		for (g in AR_GEYSER)
			g.slide();
		
		GEYSER_IS_DONE = true;
		SoundManager.GEYSER_SFX();
		
		Game.ME.sm.arQueueState.push(State.SFall);
	}
	
	public static function GEYSER_MOVE(cY:Int, isLeft:Bool) {
		if (isLeft) {
			for (i in 0...Settings.GRID_WIDTH) {
				var cX = Settings.GRID_WIDTH - 1 - i;
				var rock = Rock.GET_AT(cX, cY);
				if (rock != null) {
					var nextRock = Rock.GET_AT(cX + 1, cY);
					if (rock.isBubble || rock.isRotable) {
						if (cX == Settings.GRID_WIDTH - 1) {
							rock.destroy(true, false, false);
						}
						else if (nextRock != null && !nextRock.isBubble && !nextRock.isRotable)
							rock.destroy(true, false, false);
						else
							rock.switchTo(1, 0);						
					}
				}
			}
		}
		else {
			for (i in 0...Settings.GRID_WIDTH) {
				var cX = i;
				var rock = Rock.GET_AT(cX, cY);
				if (rock != null) {
					var previousRock = Rock.GET_AT(cX - 1, cY);
					if (rock.isBubble || rock.isRotable) {
						if (cX == 0) {
							rock.destroy(true, false, false);
						}
						else if (previousRock != null && !previousRock.isBubble && !previousRock.isRotable)
							rock.destroy(true, false, false);
						else
							rock.switchTo(-1, 0);						
					}
				}
			}
		}
	}
	
	public static function RESIZE() {
		for (m in AR_MAGMA)
			m.resize();
			
		for (g in AR_GEYSER)
			g.resize();
	}
	
	public static function DESTROY() {
		WATER_LEVEL = 0;
		WATER_CAN_REGEN = true;
		AR_BUBBLE = [];
		
		MAGMA_LEVEL = 0;
		MAGMA_IS_DONE = false;
		
		for (m in AR_MAGMA)
			m.destroy(true);
			
		AR_MAGMA = [];
		
		FREEZE_ENABLE = false;
		
		BOMBCIV_IS_DONE = false;
		BOMBCIV_EXPLODED = false;
		
		PATTERN_ENABLE = false;
		PATTERN_IS_DONE = false;
		PATTERN_AR = [];
		PATTERN_MAX = 0;
		PATTERN_ACTUAL = 0;
		
		for (g in AR_GEYSER)
			g.destroy();
			
		AR_GEYSER = [];
		
		LOOT_SPAWNED = 0;
		
		POPRATE_ELEMENT = [];
		POPRATE_LOOT = null;
	}
}

class Magma extends h2d.Sprite {
	var game		: Game;
	
	public var cX	: Int;
	var bcY			: Int;
	public var gcY	: Int;
	
	public var life	: Int;
	
	var t					: mt.motion.Tween;
	public var isTweening	: Bool;
	
	var hsCore		: mt.deepnight.slb.HSprite;
	var hs			: mt.deepnight.slb.HSprite;
	
	var speed		: Float;
	
	public function new (cX:Int) {
		super();
		
		this.cX = cX;
		
		game = Game.ME;
		
		life = 4;
		
		bcY = 4;
		
		gcY = 0;
		
		speed = 0.5;
		
		hsCore = Settings.SLB_FX2.h_getAndPlay("fxLavaCore");
		hsCore.a.setGeneralSpeed(0.5);
		hsCore.setCenterRatio(0.5, 1);
		hsCore.scaleX = Settings.STAGE_SCALE;
		hsCore.scaleY = Settings.STAGE_SCALE;
		hsCore.filter = true;
		this.addChild(hsCore);
		
		hs = Settings.SLB_FX2.h_getAndPlay("fxLava");
		hs.a.setGeneralSpeed(0.5);
		hs.setCenterRatio(0.5, 0.5);
		hs.scaleX = hs.scaleY = Settings.STAGE_SCALE;
		hs.y = -hsCore.height;
		hs.filter = true;
		this.addChild(hs);
		
		this.x = Rock.GET_POS(cX);
		this.y = Rock.GET_POS(Settings.GRID_HEIGHT + 4);
		
		isTweening = true;
		
		t = game.tweener.create().to(speed * Settings.FPS, hsCore.scaleY = Settings.STAGE_SCALE * bcY);
		function onComplete() {
			isTweening = false;
		}
		function onUpdate(e) {
			hs.y = -hsCore.height;
		}
		t.onComplete = onComplete;
		t.onUpdate = onUpdate;
	}
	
	public function nextStep() {
		life--;
		
		if (life == 3) {
			var total = 0;
			for (m in SpecialManager.AR_MAGMA)
				total += m.gcY;
				
			gcY = 4;
			
			SoundManager.LAVA_SFX();
			
			isTweening = true;
			t = game.tweener.create().to(speed * Settings.FPS, hsCore.scaleY = Settings.STAGE_SCALE * (bcY + gcY)).ease(mt.motion.Ease.easeInCubic);
			function onUpdate(e) {
				hs.y = -hsCore.height;
			}
			function onComplete() {
				isTweening = false;
				for (i in (Settings.GRID_HEIGHT - gcY)...Settings.GRID_HEIGHT) {
					var r = Rock.GET_AT(cX, i);
					if (r != null) {
						if (r.isDestroyableByBomb) {
							r.doBonusEffect();
							r.init(cX, i, TypeRock.TRMagma, false, false);
							r.ram.hide();
						}
					}
				}
			}
			t.onUpdate = onUpdate;
			t.onComplete = onComplete;
		}
	}
	
	public function resize() {
		hsCore.scaleX = Settings.STAGE_SCALE;
		
		if (life == 4)
			hsCore.scaleY = Settings.STAGE_SCALE * bcY;
		else if (life > 0)
			hsCore.scaleY = Settings.STAGE_SCALE * (bcY + gcY);
		else
			hsCore.scaleY = Settings.STAGE_SCALE;
			
		hs.scaleX = hs.scaleY = Settings.STAGE_SCALE;
		hs.y = -hsCore.height;
		
		this.x = Rock.GET_POS(cX);
		this.y = Rock.GET_POS(Settings.GRID_HEIGHT + 4);
	}
	
	public function destroy(?now:Bool = false) {
		if (now) {
			isTweening = false;
			hs.dispose();
			hs = null;
			hsCore.dispose();
			hsCore = null;
			for (i in (Settings.GRID_HEIGHT - gcY)...Settings.GRID_HEIGHT) {
				var r = Rock.GET_AT(cX, i);
				if (r != null) {
					if (r.type == TypeRock.TRMagma) {
						r.destroy(false, false, false);
					}
				}
			}
		}
		else {
			isTweening = true;
			t = game.tweener.create().to(speed * Settings.FPS, hsCore.scaleY = Settings.STAGE_SCALE).ease(mt.motion.Ease.easeInCubic);
			function onComplete() {
				isTweening = false;
				hs.dispose();
				hs = null;
				hsCore.dispose();
				hsCore = null;
				for (i in (Settings.GRID_HEIGHT - gcY)...Settings.GRID_HEIGHT) {
					var r = Rock.GET_AT(cX, i);
					if (r != null) {
						if (r.type == TypeRock.TRMagma) {
							r.destroy(false, false, false);
						}
					}
				}
			}
			function onUpdate(e) {
				hs.y = -hsCore.height;
			}
			t.onComplete = onComplete;
			t.onUpdate = onUpdate;			
		}
	}
}

class Geyser extends h2d.Sprite {
	var cY					: Int;
	var isLeft				: Bool;
	
	var hs					: HSprite;
	var hsHat				: HSprite;
	
	public var isTweening	: Bool;
	
	public function new(cY:Int, isLeft:Bool) {
		super();
		
		this.isLeft = isLeft;
		this.cY = cY;
		
		isTweening = false;
		
		hs = Settings.SLB_FX2.h_getAndPlay("fxWaterCore");
		hs.setCenterRatio(0, 0.5);
		this.addChild(hs);
		
		hsHat = Settings.SLB_FX2.h_getAndPlay("fxWater");
		hsHat.setCenterRatio(0.5, 0.5);
		this.addChild(hsHat);
	}
	
	public function slide() {
		isTweening = true;
		
		var t = Game.ME.tweener.create();
		t.to(0.5 * Settings.FPS, hs.scaleX = (Settings.STAGE_WIDTH * 1.1) / hs.frameData.wid).ease(mt.motion.Ease.easeInCubic).onUpdate = function (t) {
			hsHat.x = hs.width;
			if (t >= 1)
				SpecialManager.GEYSER_MOVE(cY, isLeft);
		};
		t.delay(0.5 * Settings.FPS);
		t.to(0.2 * Settings.FPS, hs.scaleY = 0).ease(mt.motion.Ease.easeOutCubic).onComplete = function () {
			isTweening = false;
		};
		t.delay(0.5 * Settings.FPS).onComplete = function () {
			reset();
		}
	}
	
	public function reset() {
		//isTweening = false;
		
		hs.scaleX = -Settings.STAGE_SCALE * 0.5;
		hs.scaleY = Settings.STAGE_SCALE;
		hsHat.x = - hs.width * 1;
		
		var t = Game.ME.tweener.create();
		t.to(0.2 * Settings.FPS, hs.scaleX = Settings.STAGE_SCALE * 0.5).onUpdate = function (t) {
			hsHat.x = hs.width * (hs.scaleX > 0 ? 1 : - 1);
		}
	}
	
	public function resize() {
		hs.scaleX = Settings.STAGE_SCALE * 0.5;
		hs.scaleY = Settings.STAGE_SCALE;
		hsHat.scaleX = hsHat.scaleY = Settings.STAGE_SCALE;
		hsHat.x = hs.width;
		
		if (!isLeft) {
			this.x = Settings.STAGE_WIDTH;
			this.rotation = 3.14;
		}
		
		this.y = (cY + 0.5) * Rock.SIZE_OFFSET + Game.ME.cRocks.y;
	}
	
	public function destroy() {
		hs.dispose();
		hs = null;
		
		hsHat.dispose();
		hsHat = null;
		
		this.dispose();
	}
}
