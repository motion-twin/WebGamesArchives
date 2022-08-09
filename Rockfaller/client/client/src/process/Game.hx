package process;

import data.DataManager;
import mt.deepnight.HParticle;
import mt.deepnight.deprecated.HProcess;
import mt.deepnight.slb.HSprite;
import mt.deepnight.slb.HSpriteBE;
import process.LootEarned;

import Common;
import Protocol;

import Rock;
import data.LevelDesign;
import data.Settings;
import manager.GoalManager;
import manager.LifeManager;
import manager.StateManager;
import manager.SoundManager;
import manager.SpecialManager;
import manager.TutoManager;
import process.popup.BoosterMoves;

/**
 * ...
 * @author Tipyx
 */
class Game extends HProcess implements ProcessManaged
{
	public static var ME						: Game;
	
	static var num					= 0;
	public static var DM_RUNDER		= num++;
	public static var DM_RGRIP		= num++;
	public static var DM_RBM		= num++;
	public static var DM_ROVER		= num++;
	
// MANAGER
	public var fxManager			: mt.fx.Manager;
	public var pm 					: ProcessManager;
	public var sm					: StateManager;
	
	public var hsRollOver			: HSprite;
	public var hsRollOverPickaxe	: HSprite;
	
	public var tweenRollOver		: mt.motion.Tween;
	public var tweenRollOverPickaxe	: mt.motion.Tween;
	
	public var bmHole				: h2d.SpriteBatch;
	public var cRocks				: h2d.Layers;
	var bmUnderGelatin				: Null<h2d.SpriteBatch>;
	public var bmUnderMerc			: Null<h2d.SpriteBatch>;
	public var arGelatin			: Null<Array<{hbeUnder:HSpriteBE, cX:Int, cY:Int}>>;
	public var arMerc				: Null<Array<{hbeUnder:HSpriteBE, cX:Int, cY:Int}>>;
	public var bmRocks				: h2d.SpriteBatch;
	public var bmIce				: h2d.SpriteBatch;
	public var bmBubble				: h2d.SpriteBatch;
	
	public var bmPattern			: h2d.SpriteBatch;
	public var poolPattern			: Array<HParticle>;
	public var arPattern			: Array<{arCloud:Array<HParticle>, cX:Float, cY:Float, z:Int}>;
	
	public var bmOverGridFX			: h2d.SpriteBatch;
	public var poolOverGridFX		: Array<HParticle>;
	public var bmOverGridAddFX		: h2d.SpriteBatch;
	public var poolOverGridAddFX	: Array<HParticle>;
	public var bmUnderGridAddFX		: h2d.SpriteBatch;
	public var poolUnderGridAddFX	: Array<HParticle>;
	public var bmPartMagmaFX		: h2d.SpriteBatch;
	public var poolPartMagmaFX		: Array<HParticle>;
	
	public var uiTop				: ui.top.UITop;
	var arLavaCarpet				: Array<HSprite>;
	var hsMagmaLoop					: HSprite;
	var taupi						: Taupi;
	var walls						: Wall;
	var loot						: process.LootEarned;
	
	public var rndS					: mt.Rand;
	var seed						: Int;
	var iteration					: Int;
	
	public var rootMouseX			: Float;
	public var rootMouseY			: Float;
	
	public var gridWidth			: Float;
	public var gridHeight			: Float;
	
	public var tweener				: mt.motion.Tweener;
	
	var numLevel					: Int;
	public var levelInfo			: LevelInfo;
	public var goalManager			: GoalManager;
	public var score				: mt.flash.VarSecure;
	public var multScore			: Int;
	public var numPackDeleted		: Int;
	public var movesLeft			: mt.flash.VarSecure;
	public var movesLeftEnd			: mt.flash.VarSecure;
	var boosterMoves				: BoosterMoves;
	public var pickaxeUsed			: Int;
	public var addMovesUsed			: Int;
	public var movesWithoutCombo	: Int;
	
	var arHint						: Array<HSpriteBE>;
	public var hintSelected			: {x:Int, y:Int};
	var counterHint					: Int;
	static var TIME_HINT			: Float				= 3;
	
	public var arLoots				: Array<{id:String, num:Int}>;
	public var grip					: Grip;
	
	public var mouseLeftDown		: Bool;
	
	public var isEndGame			: Bool;
	
	public var clickIsEnable		= false;

	public var isReady				= true;
	
	public var isActive 			= false;
	public var lastEventFrame		= 0;
	public var frame 				= 0;
	
	public function new(numLevel:Int, isFromGame:Bool) {
		super();
		
		mt.device.EventTracker.track("start Level", Std.string(numLevel));
		
		ME = this;
		
		pm = ProcessManager.ME;
		
		this.numLevel = numLevel;
		
		levelInfo = LevelDesign.GET_LEVEL(numLevel);
		
		goalManager = new GoalManager(levelInfo);
		
		fxManager = new mt.fx.Manager();
		sm = new StateManager();
		
		rndS = new mt.Rand(0);
		seed = Std.random(9999);
		//seed = 9837;
		iteration = 0;
		
		tweener = new mt.motion.Tweener();
		
		arPattern = [];
		
	// GRID & GP
		Rock.RESIZE();
		
		gridWidth = Settings.GRID_WIDTH * Rock.SIZE_OFFSET;
		gridHeight = Settings.GRID_HEIGHT * Rock.SIZE_OFFSET;
			
		switch (levelInfo.type) {
			case TypeGoal.TGGelatin(ar) :
				bmUnderGelatin = new h2d.SpriteBatch(Settings.SLB_GRID.tile);
				bmUnderGelatin.filter = true;
				root.add(bmUnderGelatin, Settings.DM_GELAT);
				
				arGelatin = [];
				
				for (g in ar) {
					var gelaUnder = Settings.SLB_GRID.hbe_get(bmUnderGelatin, "mudBack");
					gelaUnder.setCenterRatio(0.5, 0.5);
					gelaUnder.scaleX = gelaUnder.scaleY = Settings.STAGE_SCALE;
					gelaUnder.x = Rock.GET_POS(g.cX);
					gelaUnder.y = Rock.GET_POS(g.cY);
					
					arGelatin.push( { hbeUnder:gelaUnder, cX:g.cX, cY:g.cY } );					
				}
			case TypeGoal.TGMercury(num, ar) :
				bmUnderMerc = new h2d.SpriteBatch(Settings.SLB_GRID.tile);
				bmUnderMerc.filter = true;
				root.add(bmUnderMerc, Settings.DM_GELAT);
				
				arMerc = [];
				for (m in ar) {
					var mercUnder = Settings.SLB_GRID.hbe_get(bmUnderMerc, "mercury");
					mercUnder.setCenterRatio(0.5, 0.5);
					mercUnder.scaleX = mercUnder.scaleY = Settings.STAGE_SCALE;
					mercUnder.x = Rock.GET_POS(m.cX);
					mercUnder.y = Rock.GET_POS(m.cY);
					mercUnder.alpha = 1 - Game.ME.rndS.random(10) / 100;
					mercUnder.rotation = Game.ME.rndS.random(4) * (1.56);
					
					arMerc.push( { hbeUnder:mercUnder, cX:m.cX, cY:m.cY } );
				}
			default :
		}
		
		bmHole = new h2d.SpriteBatch(Settings.SLB_GRID.tile);
		root.add(bmHole, Settings.DM_HOLE);
		
		cRocks = new h2d.Layers();
		root.add(cRocks, Settings.DM_GRID);
		
		bmRocks = new h2d.SpriteBatch(Settings.SLB_GRID.tile);
		bmRocks.filter = true;
		cRocks.add(bmRocks, Game.DM_RBM);
		
		SpecialManager.INIT();
		
		if (SpecialManager.PATTERN_ENABLE) {
			bmPattern = new h2d.SpriteBatch(Settings.SLB_FX.tile);
			bmPattern.filter = true;
			root.add(bmPattern, Settings.DM_ROLLOVER);
			
			poolPattern = HParticle.initPool(bmPattern, 1000);
		}
		
		var b = false;
		for (r in levelInfo.arManualRocks) {
			if (r.tr.match(TypeRock.TRFreeze)) {
				b = true;
				break;
			}
		}
		if (Rock.CHECK_TR_IN_DECK(TypeRock.TRFreeze(0)) || b) {
			bmIce = new h2d.SpriteBatch(Settings.SLB_GRID.tile);
			cRocks.add(bmIce, Game.DM_ROVER);			
		}
		
		if (SpecialManager.WATER_LEVEL > 0) {
			bmBubble = new h2d.SpriteBatch(Settings.SLB_GRID.tile);
			cRocks.add(bmBubble, Game.DM_ROVER);			
		}
		
		// FX
		bmOverGridFX = new h2d.SpriteBatch(Settings.SLB_FX.tile);
		bmOverGridFX.filter = true;
		root.add(bmOverGridFX, Settings.DM_FX_UI);
		
		poolOverGridFX = HParticle.initPool(bmOverGridFX, 200);
		
		bmOverGridAddFX = new h2d.SpriteBatch(Settings.SLB_FX.tile);
		bmOverGridAddFX.filter = false;
		bmOverGridAddFX.blendMode = h2d.BlendMode.Add;
		root.add(bmOverGridAddFX, Settings.DM_FX_UI);
		
		poolOverGridAddFX = HParticle.initPool(bmOverGridAddFX, 100);
		
		bmUnderGridAddFX = new h2d.SpriteBatch(Settings.SLB_FX.tile);
		bmUnderGridAddFX.filter = true;
		bmUnderGridAddFX.blendMode = Add;
		root.add(bmUnderGridAddFX, Settings.DM_GELAT);
		
		poolUnderGridAddFX = HParticle.initPool(bmUnderGridAddFX, 30);
		
		bmPartMagmaFX = new h2d.SpriteBatch(Settings.SLB_FX.tile);
		bmPartMagmaFX.filter = true;
		bmPartMagmaFX.colorMatrix = new h3d.Matrix();
		bmPartMagmaFX.colorMatrix = mt.deepnight.Color.getColorizeMatrixH2d(0xD24217, 1, 0);
		cRocks.add(bmPartMagmaFX, Game.DM_RBM);
		
		poolPartMagmaFX = HParticle.initPool(bmPartMagmaFX, 300);
		
	// ROLLOVER FX
		hsRollOver = Settings.SLB_FX.h_get("fxCircle");
		hsRollOver.setCenterRatio(0.5, 0.5);
		hsRollOver.filter = true;
		hsRollOver.alpha = 0;
		hsRollOver.blendMode = Add;
		root.add(hsRollOver, Settings.DM_ROLLOVER);
		
		var tp1 = createTinyProcess();
		tp1.onUpdate = function () {
			if (hsRollOver == null)
				tp1.destroy();
			else
				hsRollOver.rotation += 0.02;
		}
		
		hsRollOverPickaxe = Settings.SLB_FX2.h_getAndPlay("gripZone");
		hsRollOverPickaxe.setCenterRatio(0.5, 0.5);
		hsRollOverPickaxe.filter = true;
		hsRollOverPickaxe.alpha = 0;
		hsRollOverPickaxe.blendMode = Add;
		root.add(hsRollOverPickaxe, Settings.DM_ROLLOVER);
		
	// UI
		score = new mt.flash.VarSecure(0);
		
		uiTop = new ui.top.UITop();
		root.add(uiTop, Settings.DM_UI);
		
		taupi = new Taupi();
		root.add(taupi, Settings.DM_TAUPI);
		
		walls = new Wall();
		root.add(walls, Settings.DM_WALL);
		
		TutoManager.INIT_GAME();
		
		mouseLeftDown = false;
		
		isEndGame = false;
		
		rndS.initSeed(seed + iteration);
		trace("Seed : " + (seed + iteration));
		iteration += 1;
		
		clickIsEnable = false;
		
	// INIT GOAL
		goalManager.init();
		
		arLoots = [];
		
	// INIT MOVE AND SCORE
		
		movesLeft = new mt.flash.VarSecure(levelInfo.numMoves);
	#if debug
		//movesLeft.setValue(1);
		//levelInfo.type = TypeGoal.TGScoring(100);
		//levelInfo.arStepScore = [1000, 1001, 1002];
	#end
		pickaxeUsed = 0;
		addMovesUsed = 0;
		movesWithoutCombo = 0;
		uiTop.init();
		numPackDeleted = multScore = 0;
		updateScore(0, true);
		//updateScore(50000, true);
		
	// MANUAL ROCKS
		{
			Rock.NEW_REGEN(levelInfo.arManualRocks, true, false, false);
			
			for (mr in levelInfo.arManualRocks) {
				var r = Rock.GET_AT(mr.x, mr.y);
				switch (mr.tr) {
					case TypeRock.TRFreeze(v) :
						r.setFreeze(v);
					case TypeRock.TRBubble :
						r.setBubble(true);
					default :
				}
			}			
		}
		
	// INIT GRIP
		if (levelInfo.level > 2) {
			grip = new Grip();
			root.add(grip, Settings.DM_GRIP);			
		}
		
		if (numLevel >= 16)
			TIME_HINT = 6;
		else
			TIME_HINT = 3;
		
		arHint = [];
		hintSelected = null;
		counterHint = Std.int(TIME_HINT * Settings.FPS);
		
		sm.init();
		
		SoundManager.PLAY_GAME_MUSIC();
		
		onResize();
		
	// TUTO LEVEL 1
		if (levelInfo.level == 1 && !LevelDesign.TUTO_IS_DONE(1)) {
			TutoManager.SHOW_POPUP(1, 1);
		}
	// TUTO LEVEL 2
		else if (levelInfo.level == 2 && !LevelDesign.TUTO_IS_DONE(2)) {
			while (!Rock.checkHintIsDone)
				Rock.CHECK_HINT();
				
			TutoManager.coordFocus = null;
			for (h in Rock.arHint)
				if (h.x == 3 && h.y == 4)
					TutoManager.coordFocus = h;
			
			TutoManager.SHOW_POPUP(2, 1, function() {
				Rock.SET_ROLLOVER(3, 4);
				TutoManager.showHighlight();
			} );
		}
	// TUTO LEVEL 3
		else if (levelInfo.level == 3 && !LevelDesign.TUTO_IS_DONE(3)) {
			while (!Rock.checkHintIsDone)
				Rock.CHECK_HINT();
				
			for (h in Rock.arHint)
				if (h.x == 3 && h.y == 6)
					TutoManager.coordFocus = h;
			
			TutoManager.SHOW_POPUP(3, 1, function() {
				Rock.SET_ROLLOVER(3, 6);
				TutoManager.showHighlight();
			} );
		}
	// TUTO LEVEL 4
		else if (levelInfo.level == 4 && !LevelDesign.TUTO_IS_DONE(4)) {
			TutoManager.SHOW_POPUP(4, 1);
			TutoManager.showHighlight();
		}
	// TUTO LEVEL 5
		else if (levelInfo.level == 5 && !LevelDesign.TUTO_IS_DONE(5)) {
			uiTop.modGoal.showHL();
			TutoManager.SHOW_POPUP(5, 1);
		}
	// TUTO LEVEL 6
		else if (levelInfo.level == 6 && !LevelDesign.TUTO_IS_DONE(6)) {
		}
	// TUTO LEVEL 7
		else if (levelInfo.level == 7 && !LevelDesign.TUTO_IS_DONE(7)) {
			TutoManager.SHOW_POPUP(7, 1);
			uiTop.modGoal.showHL();
			TutoManager.showHighlight();
		}
	// TUTO LEVEL 8
		else if (levelInfo.level == 8 && !LevelDesign.TUTO_IS_DONE(8)) {
			TutoManager.coordFocus = { x:1, y:4, pack:[] };
			
			TutoManager.SHOW_POPUP(8, 1, function() {
				Rock.SET_ROLLOVER(1, 4);
				TutoManager.showHighlight();
			} );
		}
	// TUTO LEVEL 10
		else if (levelInfo.level == 10 && !LevelDesign.TUTO_IS_DONE(10)) {
			var pack = [];
			pack.push(Rock.GET_AT(2, 2));
			pack.push(Rock.GET_AT(2, 3));
			pack.push(Rock.GET_AT(3, 2));
			pack.push(Rock.GET_AT(4, 0));
			pack.push(Rock.GET_AT(4, 1));
			pack.push(Rock.GET_AT(5, 0));
			pack.push(Rock.GET_AT(5, 2));
			pack.push(Rock.GET_AT(5, 3));
			pack.push(Rock.GET_AT(6, 2));
			
			TutoManager.coordFocus = { x:2, y:2, pack:pack };
			
			TutoManager.SHOW_POPUP(10, 1, function() {
				Rock.SET_ROLLOVER(2, 2, false);
				TutoManager.showHLPack();
				TutoManager.showHighlight();
			} );
		}
	// TUTO LEVEL 12
		else if (levelInfo.level == 12 && !LevelDesign.TUTO_IS_DONE(12)) {
			LevelDesign.USER_DATA.pickaxe = 1;
			uiTop.refill();
			uiTop.btnPickaxe.showHL();
			TutoManager.SHOW_POPUP(12, 1);
		}
	// TUTO LEVEL 13
		else if (levelInfo.level == 13 && !LevelDesign.TUTO_IS_DONE(13)) {
			TutoManager.SHOW_POPUP(13, 1);
			uiTop.btnPickaxe.showHL();
		}
	// TUTO LEVEL 16
		else if (levelInfo.level == 16 && !LevelDesign.TUTO_IS_DONE(16)) {
			TutoManager.SHOW_POPUP(16, 1, function () {
				Rock.SET_ROLLOVER(2, 2);
			});
		}
	// TUTO LEVEL 56
		else if (levelInfo.level == 56 && !LevelDesign.TUTO_IS_DONE(56)) {
			TutoManager.SHOW_POPUP(56, 1);
		}
	// TUTO LEVEL 76
		else if (levelInfo.level == 76 && !LevelDesign.TUTO_IS_DONE(76)) {
			TutoManager.SHOW_POPUP(76, 1);
		}
	// TUTO LEVEL 96
		else if (levelInfo.level == 96 && !LevelDesign.TUTO_IS_DONE(96)) {
			TutoManager.SHOW_POPUP(96, 1);
		}
	// TUTO LEVEL 121
		else if (levelInfo.level == 121 && !LevelDesign.TUTO_IS_DONE(121)) {
			while (!Rock.checkHintIsDone)
				Rock.CHECK_HINT();
				
			TutoManager.coordFocus = null;
			for (h in Rock.arHint)
				if (h.x == 4 && h.y == 3)
					TutoManager.coordFocus = h;
			
			TutoManager.SHOW_POPUP(121, 1, function() {
				Rock.SET_ROLLOVER(4, 3);
				TutoManager.showHighlight();
			});
		}
		
		if (!Settings.IS_FPS_INIT_DONE) {
			delayer.add("", function() {
				Settings.IS_FPS_INIT_DONE = true;
				DataManager.SEND_ACTUAL_FPS_RATE("init game + 6 seconds");
			}, 5 * 1000.0);
		}
		
		if (levelInfo.level == 1 && isFromGame)
			DataManager.DO_PROTOCOL(ProtocolCom.DoLaunchGame(levelInfo.level));
		else if (isFromGame)
			new process.popup.GoalLevels(levelInfo, true);
	}
	
	public function onReady() {
		
	}
	
	override function onEvents(e:hxd.Event) {
		lastEventFrame = frame;
		switch(e.kind) {
			case hxd.Event.EventKind.EPush		: onMouseLeftDown();
			case hxd.Event.EventKind.ERelease	: onMouseLeftUp();
			case hxd.Event.EventKind.EMove		: onMove();
			default								:
		}
	}
	
	function onMouseLeftUp() {
		if (clickIsEnable && !paused && !isEndGame && !uiTop.waitServ) {
		#if mobile
			onMove();
		#end
			Rock.SWITCH();
		}
		
		mouseLeftDown = false;
	}
	
	function onMouseLeftDown() {
		if (clickIsEnable && !paused && !isEndGame) {
		#if mobile
			onMove();
		#end
			mouseLeftDown = true;
			Rock.ON_MOUSE_DOWN();			
		}
	}
	
	function onMove() {
		if (clickIsEnable && !paused && !isEndGame) {
			Rock.ON_MOVE();
		}
	}
	
	public function enableClick() {
		numPackDeleted = multScore = 0;
		manager.SpecialManager.END_TURN();
		deleteOldHint();
		if (levelInfo.level == 1) {
			if (TutoManager.countMoves == 6) {
				movesLeft.addValue( -movesLeft.get());
				showEnd(true);
			}
		}
		else if (levelInfo.level == 2 || levelInfo.level == 3) {
			if (goalManager.checkEnd()) {
				movesLeft.addValue( -movesLeft.get());
				showEnd(true);
			}
		}
		else {
			if (goalManager.checkEnd()) {
				showEnd(true);
			}
			else if (!Rock.CHECK_MOVE_POSSIBLE())
				showEnd(false);
			else if (movesLeft.get() <= 0) {
				showBoosterMoves();
			}			
		}
	#if !mobile
		if (!isEndGame)
			Rock.ON_MOVE();
	#end
	}
	
	function showBoosterMoves() {
		boosterMoves = new process.popup.BoosterMoves(this);
	}
	
	public function showEnd(success:Bool) {
		if (!isEndGame) {
			movesLeftEnd = new mt.flash.VarSecure(movesLeft.get());
			
			FX.END_MESSAGE(success);
			if (success)
				SoundManager.PLAY_WIN_JINGLE();
			else
				SoundManager.PLAY_LOSE_JINGLE();			
		}
		
		delayer.addFrameBased("", function () {
			var arBomb = [];
			//var bMax = movesLeft > 5 ? 5 : movesLeft;
			var bMax = movesLeft.get();
			
			var presentBomb = 0;
			
			if (success) {
				for (r in Rock.ALL) {
					if (arBomb.length < 5 && !r.isDestroy) {
						switch (r.type) {
							case TypeRock.TRBonus :
								r.isAnimated = true;
								arBomb.push(r);
								presentBomb++;
							default :
						}
					}
				}
			}
			
			bMax += arBomb.length;
			
			if ((movesLeft.get() > 0 || arBomb.length > 0) && success) {
				sm.arQueueState = [State.SEndBonus, State.SFall];
				
				var i = 0;
				if (arBomb.length == 0) {
					while (arBomb.length < bMax && i < Settings.GRID_WIDTH * Settings.GRID_HEIGHT * 10) {
						i++;
						var r = Rock.GET_AT(Std.random(Settings.GRID_WIDTH), Std.random(Settings.GRID_HEIGHT));
						for (b in arBomb) {
							if (r == b) {
								r = null;
								break;
							}
						}
						if (r != null && !r.isDestroy && r.isRotable && !r.isBubble && r.freezeCounter == 0 && r.type.match(TypeRock.TRClassic)) {
							delayer.addFrameBased(function () {
								FX.GO_TO_ROCK(Settings.STAGE_WIDTH * 0.5, 30 * Settings.STAGE_SCALE, r, function() {
									FX.FX_VANISH(r.cX, r.cY);
									SoundManager.BOMB_POP_SFX();
									r.init(r.cX, r.cY, TypeRock.TRBonus(Std.random(2) == 0 ? TypeBonus.TBBombHor : TypeBonus.TBBombVert), false, false);
									r.isAnimated = true;
									updateScore(1000);
									uiTop.costMove();
								});
							}, Rock.TIME_DESTROY * Settings.FPS * arBomb.length * 0.8);
							r.isAnimated = true;
							arBomb.push(r);
						}
					}					
				}
				delayer.addFrameBased(function () { 
					if (!Settings.IS_FPS_END_DONE) {
						Settings.IS_FPS_END_DONE = true;
						DataManager.SEND_ACTUAL_FPS_RATE("end game");
					}
					for (b in arBomb) {
						b.destroy(true, false, true);
					}
				}, (presentBomb == arBomb.length ? 0 : Settings.FPS * 0.7) + (Settings.FPS * 0.8 * Rock.TIME_DESTROY * (arBomb.length - presentBomb)));
			}
			else {
				sm.arQueueState = [State.SEndGame];
				function taupiAnimAfterTransition() {
					if (success)
						Rock.DESTROY(true);
				}
				function taupiAnimAfterEnd() { new process.popup.End(success, score.get(), levelInfo.level); };
				taupi.animAfterTransition = taupiAnimAfterTransition; 
				taupi.animAfterEnd = taupiAnimAfterEnd;
				delayer.addFrameBased(function () {
					if (grip != null)
						grip.visible = false;
					taupi.animEnd(success);
				}, Settings.FPS / 4);			
			}
		}, !isEndGame && success ? FX.TIME_END_MESSAGE * Settings.FPS : 0);
		
		isEndGame = true;
	}
	
	public function showLoot(id:String) {
		loot = new LootEarned(id);
		pause();
	}
	
	public function closeLoot() {
		if (loot != null) {
			loot.delete();
			loot = null;			
		}
		resume();
	}
	
	public function setRollOver(cX:Int, cY:Int) {
		hsRollOver.x = Std.int(cRocks.x + Rock.GET_POS(cX) + Rock.SIZE_OFFSET / 2);
		hsRollOver.y = Std.int(cRocks.y + Rock.GET_POS(cY) + Rock.SIZE_OFFSET / 2);
	}
	
	public function showRollOver() {
		hideRollOverPickaxe();
		if (tweenRollOver != null)
			tweenRollOver.dispose();
		tweenRollOver = tweener.create().to(0.2 * Settings.FPS, hsRollOver.alpha = 0.5);
	}
	
	public function hideRollOver() {
		if (tweenRollOver != null )
			tweenRollOver.dispose();
		tweenRollOver = tweener.create().to(0.2 * Settings.FPS, hsRollOver.alpha = 0);
	}
	
	public function setRollOverPickaxe(cX:Int, cY:Int) {
		hsRollOverPickaxe.x = Std.int(cRocks.x + Rock.GET_POS(cX));
		hsRollOverPickaxe.y = Std.int(cRocks.y + Rock.GET_POS(cY));
	}
	
	public function showRollOverPickaxe() {
		hideRollOver();
		if (tweenRollOverPickaxe != null)
			tweenRollOverPickaxe.dispose();
		tweenRollOverPickaxe = tweener.create().to(0.2 * Settings.FPS, hsRollOverPickaxe.alpha = 0.5);
	}
	
	public function hideRollOverPickaxe() {
		if (tweenRollOverPickaxe != null)
			tweenRollOverPickaxe.dispose();
		tweenRollOverPickaxe = tweener.create().to(0.2 * Settings.FPS, hsRollOverPickaxe.alpha = 0);
	}
	
	public function updateScore(newValue:Int, ?reset:Bool = false) {
		if (reset)
			score.setValue(newValue);
		else
			score.addValue(newValue);
		
		uiTop.updateScore();
	}
	
	public function addMove(num:Int) {
		addMovesUsed++;
		movesLeft.addValue(num);
		uiTop.addMoves(num);
	}
	
	function showHint() {
		for (rsel in Rock.AR_SEL)
				for (i in 0...2)
					for (j in 0...2)
						if (rsel.cX == hintSelected.x + i && rsel.cY == hintSelected.y + j)
							return;
		
		for (h in arHint) {
			h.alpha = 1;
			//tweener.create().to(0.2 * Settings.FPS, h.scaleX = Settings.STAGE_SCALE * 1.25, h.scaleY = Settings.STAGE_SCALE * 1.25);
		}
	}
	
	public function hideHint() {
		counterHint = Std.int(TIME_HINT * Settings.FPS);
		for (h in arHint) {
			h.alpha = 0;
			h.scaleX = h.scaleY = Settings.STAGE_SCALE;
		}
	}
	
	function setHint() {
		hintSelected = Rock.arHint[Std.random(Rock.arHint.length)];
		
		if (Rock.AR_SEL.length > 0) {
			for (rsel in Rock.AR_SEL)
				for (i in 0...2)
					for (j in 0...2)
						if (rsel.cX == hintSelected.x + i && rsel.cY == hintSelected.y + j)
							break;
		}
		
		if (arHint.length == 0) {
			for (i in 0...2) {
				for (j in 0...2) {
					var r = Rock.GET_AT(hintSelected.x + i, hintSelected.y + j).ram;
					var hsHint = Settings.SLB_GRID.hbe_get(bmRocks, r.typeID + "Over");
					hsHint.scaleX = hsHint.scaleY = Settings.STAGE_SCALE;
					hsHint.setCenterRatio(0.5, 0.5);
					hsHint.x = Rock.GET_POS(hintSelected.x + i);
					hsHint.y = Rock.GET_POS(hintSelected.y + j);
					hsHint.alpha = 0;
					hsHint.changePriority(0);
					arHint.push(hsHint);
					
					var tp = createTinyProcess();
					function onUpdateTPHint() {
						if (hsHint == null)
							tp.onDispose();
						else {
							hsHint.scaleX = (1.12 + Math.sin(tp.time / 5) * 0.12) * Settings.STAGE_SCALE;
							hsHint.scaleY = (1.12 + Math.sin(tp.time / 5) * 0.12) * Settings.STAGE_SCALE;
						}
					}
					tp.onUpdate = onUpdateTPHint;
				}
			}
		}
	}
	
	public function deleteOldHint() {
		counterHint = Std.int(TIME_HINT * Settings.FPS);
		
		Rock.RESET_HINT();
		
		for (hs in arHint) {
			hs.dispose();
			hs = null;
		}
		
		hintSelected = null;
		
		arHint = [];
	}
	
	override function onResize() {
		if (paused)
			pause();
		
		Rock.RESIZE();
		
		deleteOldHint();
		
		if (arGelatin != null) {
			for (g in arGelatin) {
				g.hbeUnder.scaleX = g.hbeUnder.scaleY = Settings.STAGE_SCALE;
				g.hbeUnder.x = Rock.GET_POS(g.cX);
				g.hbeUnder.y = Rock.GET_POS(g.cY);
			}			
		}
		
		if (arMerc != null) {
			for (g in arMerc) {
				g.hbeUnder.scaleX = g.hbeUnder.scaleY = Settings.STAGE_SCALE;
				g.hbeUnder.x = Rock.GET_POS(g.cX);
				g.hbeUnder.y = Rock.GET_POS(g.cY);
			}			
		}
		
		for (p in arPattern) {
			for (i in 0...p.arCloud.length) {
				var be = p.arCloud[i];
				be.scaleX = be.scaleY = Settings.STAGE_SCALE;
				be.x = Std.int(Rock.GET_POS(p.cX) + ((0.20 + 0.15 * i - 0.5) * Rock.SIZE_OFFSET));
				be.y = Std.int(Rock.GET_POS(p.cY) + ((0.20 + 0.15 * i - 0.5) * Rock.SIZE_OFFSET));
			}
		}
		
		hsRollOver.scaleX = hsRollOver.scaleY = Settings.STAGE_SCALE;
		hsRollOverPickaxe.scaleX = hsRollOverPickaxe.scaleY = Settings.STAGE_SCALE * 1.5;
		
		gridWidth = Settings.GRID_WIDTH * Rock.SIZE_OFFSET;
		gridHeight = Settings.GRID_HEIGHT * Rock.SIZE_OFFSET;
		
		cRocks.x = Std.int((Settings.STAGE_WIDTH - gridWidth) / 2);
		cRocks.y = Std.int((Settings.STAGE_HEIGHT * 0.9 - gridHeight) * 0.5);
		
		if (cRocks.y < Std.int(uiTop.getHeightTop() * 1.2))
			cRocks.y = Std.int(uiTop.getHeightTop() * 1.2);
		
		bmHole.x = cRocks.x;
		bmHole.y = cRocks.y;
		
		if (bmUnderGelatin != null) {
			bmUnderGelatin.x = cRocks.x;
			bmUnderGelatin.y = cRocks.y;
		}
			
		if (bmUnderMerc != null) {
			bmUnderMerc.x = cRocks.x;
			bmUnderMerc.y = cRocks.y;
		}
		
		if (bmPattern != null) {
			bmPattern.x = cRocks.x;
			bmPattern.y = cRocks.y;
		}
		
		if (grip != null)
			grip.resize();
		
		if (SpecialManager.MAGMA_LEVEL > 0) {
			if (arLavaCarpet != null) {
				for (l in arLavaCarpet) {
					l.dispose();
					l = null;
				}
				arLavaCarpet = null;
			}
			
			arLavaCarpet = [];
			var widLavaCarpet = Settings.SLB_UI.getFrameData("magmaGround").wid * Settings.STAGE_SCALE;
			for (i in 0...Std.int(Settings.STAGE_WIDTH / widLavaCarpet) + 1) {
				var hsLavaCarpet = Settings.SLB_UI.h_get("magmaGround");
				hsLavaCarpet.filter = true;
				hsLavaCarpet.setCenterRatio(0, 0);
				hsLavaCarpet.scaleX = hsLavaCarpet.scaleY = Settings.STAGE_SCALE;
				hsLavaCarpet.x = Std.int(hsLavaCarpet.width) * i;
				hsLavaCarpet.y = Std.int(cRocks.y + gridHeight + Rock.SIZE_OFFSET * 0.5);
				arLavaCarpet.push(hsLavaCarpet);
				root.add(hsLavaCarpet, Settings.DM_ROLLOVER);				
			}
			
			if (hsMagmaLoop == null) {
				hsMagmaLoop = Settings.SLB_UI.h_get("magmaLoop");
				root.add(hsMagmaLoop, Settings.DM_ROLLOVER);
			}
			
			hsMagmaLoop.scaleX = 1;
			hsMagmaLoop.scaleX = Settings.STAGE_WIDTH / hsMagmaLoop.width;
			hsMagmaLoop.scaleY = 1;
			hsMagmaLoop.scaleY = 2 * (Settings.STAGE_HEIGHT - Std.int(cRocks.y + gridHeight + Rock.SIZE_OFFSET * 0.5)) / hsMagmaLoop.height;
			hsMagmaLoop.x = Std.int(arLavaCarpet[0].x);
			hsMagmaLoop.y = Std.int(arLavaCarpet[0].y + arLavaCarpet[0].height * 0.5);
		}
		
		taupi.resize();
		walls.resize();
		uiTop.resize();
		manager.SpecialManager.RESIZE();
		manager.TutoManager.RESIZE();
		
		if (Rock.AR_SEL.length > 0) {
			setRollOver(Rock.AR_SEL[0].cX, Rock.AR_SEL[0].cY);
			setRollOverPickaxe(Rock.AR_SEL[0].cX, Rock.AR_SEL[0].cY);
		}
		
		super.onResize();
	}
	
	override function unregister() {
		fxManager.clean();
		fxManager = null;
		
		if (boosterMoves != null)
			boosterMoves = null;
		
		if (grip != null) {
			grip.destroy();
			grip = null;			
		}
		
		Rock.DESTROY(false);
		
		if (arGelatin != null) {
			for (g in arGelatin) {
				g.hbeUnder.dispose();
				g.hbeUnder = null;
			}
			arGelatin = null;
		}
		
		if (arMerc != null) {
			for (g in arMerc) {
				g.hbeUnder.dispose();
				g.hbeUnder = null;
			}
			arMerc = null;
		}
		
		if (poolPattern != null) {
			for (p in poolPattern) {
				p.dispose();
				p = null;
			}			
		}
		poolPattern = null;
		
		TutoManager.DESTROY_GAME();
		
		if (bmUnderGelatin != null)
			bmUnderGelatin.dispose();
		bmUnderGelatin = null;
		
		if (bmUnderMerc != null)
			bmUnderMerc.dispose();
		bmUnderMerc = null;
		
		if (bmPattern != null)
			bmPattern.dispose();
		bmPattern = null;
		
		cRocks.dispose();
		cRocks = null;
		
		bmRocks.dispose();
		bmRocks = null;
		
		bmHole.dispose();
		bmHole = null;
		
		if (bmIce != null)
			bmIce.dispose();
		bmIce = null;
		
		if (bmBubble != null)
			bmBubble.dispose();
		bmBubble = null;
		
		for (p in poolOverGridFX) {
			p.dispose();
			p = null;
		}
		poolOverGridFX = null;
		
		for (p in poolOverGridAddFX) {
			p.dispose();
			p = null;
		}
		poolOverGridAddFX = null;
		
		for (p in poolUnderGridAddFX) {
			p.dispose();
			p = null;
		}
		poolUnderGridAddFX = null;
		
		for (p in poolPartMagmaFX) {
			p.dispose();
			p = null;
		}
		poolPartMagmaFX = null;
		
		bmOverGridFX.dispose();
		bmOverGridFX = null;
		
		bmOverGridAddFX.dispose();
		bmOverGridAddFX = null;
		
		bmUnderGridAddFX.dispose();
		bmUnderGridAddFX = null;
		
		bmPartMagmaFX.dispose();
		bmPartMagmaFX = null;
		
		uiTop.destroy();
		uiTop = null;
		
		taupi.destroy();
		taupi = null;
		
		walls.destroy();
		walls = null;
		
		tweener.dispose();
		tweener = null;
		
		hsRollOver.dispose();
		hsRollOver = null;
		
		hsRollOverPickaxe.dispose();
		hsRollOverPickaxe = null;
		
		if (loot != null) {
			loot.delete();
			loot = null;
		}
		
		SpecialManager.DESTROY();
		
		if (process.popup.End.ME != null)
			process.popup.End.ME.unregister();
		
		if (process.popup.GoalLevels.ME != null)
			process.popup.GoalLevels.ME.destroy();
		
		if (process.popup.Pause.ME != null)
			process.popup.Pause.ME.unregister();

		#if mBase
		if ( isActive ) 
			mtnative.device.Device.setKeepScreenOn( false );
		#end
			
		ME = null;
		
		super.unregister();
	}
	
	override function update() {
		super.update();
		
		sm.update();
		
		tweener.update();
		
		rootMouseX = root.mouseX;
		rootMouseY = root.mouseY;
		
		Rock.UPDATE();
		
		if (grip != null)
			grip.update();
		
		taupi.update();
		
		uiTop.update();
		
		fxManager.update();
		
		FX.UPDATE();
		
		if (clickIsEnable && !isEndGame && LevelDesign.WANT_HINT()) {
			//trace(LevelDesign.WANT_HINT());
			if (!Rock.checkHintIsDone)
				Rock.CHECK_HINT();
			else if (hintSelected == null && Rock.arHint.length > 0) {
				setHint();
			}
			else if (arHint.length > 0 && TutoManager.ACTUAL_TUTO == null) {
				counterHint--;
				if (counterHint == 0) {
					counterHint = Std.int(TIME_HINT * Settings.FPS);
					showHint();
				}
			}
		}
		
		if (poolPattern != null)
			for (p in poolPattern)
				p.update(true);
		
		for (p in poolOverGridFX)
			p.update(true);
		
		for (p in poolOverGridAddFX)
			p.update(true);
		
		for (p in poolUnderGridAddFX)
			p.update(true);
		
		for (p in poolPartMagmaFX)
			p.update(true);			
		
		Settings.SLB_TAUPI.updateChildren();
		Settings.SLB_GRID.updateChildren();
		Settings.SLB_UI.updateChildren();
		Settings.SLB_FX.updateChildren();
		Settings.SLB_FX2.updateChildren();
		
		if (Std.random(Settings.FPS * 10) == 0)
			FX.FALL_PRTCL_ROCK();
			
		frame++;
		// KeepScreenOn for 90s
		var hasActivity = lastEventFrame > frame - Settings.FPS * 90;
		if ( isActive != hasActivity ) {
			isActive = hasActivity;
			#if mBase
			mtnative.device.Device.setKeepScreenOn( isActive );
			#end
		}
	}
}
