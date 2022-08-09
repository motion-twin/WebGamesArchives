package ;
import anim.FrameManager;
import entities.Bonus;
import entities.BulletImpact;
import entities.Drop;
import entities.Dropper;
import entities.Entity;
import entities.Explosion;
import entities.Obstacle;
import entities.Oil;
import entities.Player;
import entities.Rail;
import entities.Shooter;
import entities.Shot;
import events.EventManager;
import events.GameEvent;
import Data;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.ui.Mouse;
import Game;
import gfx.ProgressMap;
import mt.data.Texts;
import mt.deepnight.RandList;
import mt.DepthManager;
import mt.gx.Dice;
import mt.gx.MathEx;
import mt.gx.time.FTimer;
import Road;
import RoadEngine;
import ui.EmbedText;
import ui.Fx;
import ui.Hint;
import ui.PMWrapper;
import ui.UIWrapper;
import api.AKApi;
import api.AKConst;

/**
 * ...
 * @author 01101101
 */

using Lambda;
class Level extends Sprite {
	
	static public var instance:Level;
	
	public static inline var ROAD_DEPTH = 0;
	public static inline var FLOOR_DEPTH = 10;
	public static inline var VEHICLES_DEPTH = 20;
	public static inline var HELICO_DEPTH = 25;
	public static inline var LIGHT_DEPTH = 30;
	public static inline var FX_DEPTH = 40;
	public static var DEPTHS = [ROAD_DEPTH, FLOOR_DEPTH, VEHICLES_DEPTH, HELICO_DEPTH, LIGHT_DEPTH, FX_DEPTH];
	public static var me:Level;
	var dm:DepthManager;
	
	public static var gridSize:Rectangle;
	
	public var gameIsOver:Bool;
	public var endingGame:Bool;
	
	public var container:Sprite;
	public var light:Bitmap;
	public var UIContainer:Sprite;
	
	public var road:Road;
	public var roadBD:BitmapData;
	public var roadB:Bitmap;
	
	//public var baseObjects:WeightedList<OT>;
	public var baseObjects:RandList<OT>;
	
	var bloodBD:BitmapData;
	var bloodB:Bitmap;
	//var bloodRepeat:Int;
	
	var flash:Sprite;
	
	public var player:Player;
	
	var progressMap:PMWrapper;
	var uiWrapper:UIWrapper;
	
	var entities:List<Entity>;
	var grid:IntHash<List<Entity>>;
	var _gridBD:BitmapData;
	
	public var hints:Array<Hint>;
	
	var scroll:Int;
	
	// PROGRESSION MODE
	//var progress:Int;// Current distance reached
	//var progressTotal:Int;// Distance to reach to win the game
	// LEAGUE MODE
	public var level:Int;// Difficulty level
	var nextScore:Int;// Score to reach to increment level
	
	public var kadoList:Array<Bonus>;
	var kadoCount:Int;
	
	var allowedShooters:Int;
	
	var isDownFn:Dynamic;
	
	var _dummy:Sprite;
	
	var mouseTimer:Bool;
	var justClicked:Bool;
	
	public function new () {
		instance = this;
		
		isDownFn = AKApi.isDown;
		
		super();
		init();
	}
	
	public function init () {
		
		gameIsOver = endingGame = false;
		
		EM.instance.addEventListener(GE.GENERATE_ROAD, gameEventHandler);
		EM.instance.addEventListener(GE.PAINT_ENTITY, gameEventHandler);
		EM.instance.addEventListener(GE.SPAWN_ENTITY, gameEventHandler);
		EM.instance.addEventListener(GE.KILL_ENTITY, gameEventHandler);
		
		scroll = 0;
		//progress = 0;
		level = 0;
		
		allowedShooters = 1;
		
		if (AKApi.getGameMode() == GM_PROGRESSION) {
			level = AKApi.getLevel();
			Game.RATIO = switch (level) {
				default:	1.1;
			}
			Game.SPEED = Std.int(Game.BASE_SPEED * Game.RATIO);
		}
		nextScore = Data.l(level);
		
		// Kados
		kadoList = new Array<Bonus>();
		for (igpt in AKApi.getInGamePrizeTokens()) {
			kadoList.push(new Bonus(OT.OKado, igpt));
		}
		kadoCount = kadoList.length;
		
		// Base objects
		//baseObjects = new WeightedList<OT>();
		baseObjects = new RandList<OT>();
		baseObjects.add(OT.ORock, 3);
		baseObjects.add(OT.OCrack, 6);
		baseObjects.add(OT.OSkull, 1);
		
		// Container
		container = new Sprite();
		addChild(container);
		light = new Bitmap(new LightBM(0, 0));
		light.blendMode = BlendMode.HARDLIGHT;
		//light.blendMode = BlendMode.OVERLAY;
		//light.alpha = 0.5;
		addChild(light);
		UIContainer = new Sprite();
		addChild(UIContainer);
		
		dm = new DepthManager(container);
		for (i in DEPTHS)	var p = dm.getPlan(i);
		
		new Fx(dm);
		
		// ENTITIES & GRID
		entities = new List<Entity>();
		grid = new IntHash<List<Entity>>();
		hints = new Array<Hint>();
		
		// PLAYER
		player = new Player();
		
		me = this;
		
		// ROAD
		road = RE.createRoad();
		
		if (AKApi.getGameMode() == GM_PROGRESSION) {
			if (level == 1)			road.setWidths(2, 10, 5, 2);
			else if (level == 2)	road.setWidths(1, 7, 5, 3);
			else if (level == 3)	road.setWidths(0, 10, 7, 1);
			else if (level == 4)	road.setWidths(1, 5, 10, 2);
			else if (level == 5)	road.setWidths(0, 0, 10, 7);
			else if (level == 6)	road.setWidths(0, 10, 8, 1);
			else if (level == 7)	road.setWidths(0, 7, 10, 5);
			else if (level == 8)	road.setWidths(0, 10, 9, 5);
			else if (level == 9)	road.setWidths(1, 8, 7, 2);
			else if (level == 10)	road.setWidths(1);
			else if (level == 11)	road.setWidths(0, 0, 5, 5);
			else if (level == 12)	road.setWidths(0, 1, 2, 10);
			else if (level == 13)	road.setWidths(1);
			else if (level == 14)	road.setWidths(1);
			else if (level == 15)	road.setWidths(0, 1);
			else if (level == 16)	road.setWidths(0, 0, 1);
			else if (level == 17)	road.setWidths(0, 1);
			else if (level == 18)	road.setWidths(0, 0, 1);
			else if (level == 19)	road.setWidths(0, 0, 1);
			else if (level == 20)	road.setWidths(0, 0, 0, 1);
			else					road.setWidths(0, 10);
		}
		RE.smartAddSlice(road, level, true);
		for (i in 0...3)	RE.smartAddSlice(road, level);
		
		roadBD = new BitmapData(road.getBD().width * Game.TILE_SIZE, road.getBD().height * Game.TILE_SIZE, false);
		roadB = new Bitmap(roadBD);
		dm.add(roadB, ROAD_DEPTH);
		for (i in 1...road.getBD().height + 1)	RE.renderPart(road, roadBD, road.getBD().height - i);
		
		player.x = roadB.width / 2;
		player.y = roadB.height - Game.SIZE.height / 4;
		dm.add(player, VEHICLES_DEPTH);
		
		gridSize = new Rectangle(0, 0, Math.ceil(road.getBD().width * Game.TILE_SIZE / Game.GRID_SIZE), Math.ceil(road.getBD().height * Game.TILE_SIZE / Game.GRID_SIZE));
		
		// PROGRESS MAP
		if (AKApi.getGameMode() == GM_PROGRESSION) {
			progressMap = new PMWrapper();
			AKApi.setStatusMC(progressMap);
		}
		
		// UI
		uiWrapper = new UIWrapper();
		uiWrapper.x = 0;
		uiWrapper.y = Game.SIZE.height;
		UIContainer.addChild(uiWrapper);
		
		container.x = (Game.SIZE.width - roadB.width) / 2;
		container.y = Game.SIZE.height - roadB.height;
		
		var bloodScale = 6;
		_dummy = new Sprite();
		_dummy.graphics.beginFill(0x00FF00, 1);
		_dummy.graphics.drawRect(0, 0, Math.ceil(Game.SIZE.width / bloodScale), Math.ceil(Game.SIZE.height / bloodScale));
		_dummy.graphics.endFill();
		_dummy.filters = [new flash.filters.GlowFilter(0xFF0000, 1, 100 / bloodScale, 100 / bloodScale, 1, 1, true, true)];
		bloodBD = new BitmapData(Math.ceil(Game.SIZE.width / bloodScale), Math.ceil(Game.SIZE.height / bloodScale), true, 0x00FF0000);
		bloodBD.draw(_dummy);
		bloodB = new Bitmap(bloodBD);
		bloodB.scaleX = bloodB.scaleY = bloodScale;
		_dummy.filters = [];
		_dummy = null;
		addChild(bloodB);
		
		flash = new Sprite();
		flash.graphics.beginFill(0xFFFFFF);
		flash.graphics.drawRect(0, 0, Game.SIZE.width, Game.SIZE.height);
		flash.graphics.endFill();
		
		mouseTimer = false;
		justClicked = false;
		
		//FTimer.delay(_countEnt, 30);
		
	}
	
	function gameEventHandler (e:GameEvent) :Void {
		//trace(e.type + " / " + e.data);
		switch (e.type) {
			case GE.PAINT_ENTITY:
				paintEntity(e.data);
			case GE.SPAWN_ENTITY:
				if (Std.is(e.data, Entity))			spawnEntity(e.data);
				else if (Std.is(e.data, SpawnData))	spawnEntity(cast(e.data, SpawnData).entity, cast(e.data, SpawnData).params);
			case GE.KILL_ENTITY:
				killEntity(e.data);
			case GE.GENERATE_ROAD:
				RE.smartAddSlice(road, level);
		}
	}
	
	public function update () {
		
		if (gameIsOver)	return;
		
		// Scroll road
		scroll += Game.SPEED;
		roadB.y += Game.SPEED;
		while (scroll >= Game.TILE_SIZE) {
			scroll -= Game.TILE_SIZE;
			if (road.scroll(1)) {
				roadB.y -= Game.TILE_SIZE;
				roadBD.scroll(0, Game.TILE_SIZE);
				RE.renderPart(road, roadBD);
			}
		}
		
		// Player input
		if (player.ctrlLock == 0 && !endingGame) {
			var vx = 0;
			var vy = 0;
			
			// MOUSE MODE
			if (Game.MOUSE_MODE) {
				var mx = 0;
				var my = 0;
				if (stage != null) {
					var v = AKApi.getCustomValue(Std.int(stage.mouseY) * 1000 + Std.int(stage.mouseX));
					mx = v % 1000;
					mx -= Std.int(player.getScreenPos().x + player.w / 2 + player.offset.x);
					my = Math.floor(v / 1000);
					my -= Std.int(player.getScreenPos().y + player.h / 2 + player.offset.y);
				}
				if (mx < -32)			vx -= Std.int(Game.SPEED * 0.5);
				else if (mx < -16)		vx -= Std.int(Game.SPEED * 0.25);
				if (mx > 32)			vx += Std.int(Game.SPEED * 0.5);
				else if (mx > 16)		vx += Std.int(Game.SPEED * 0.25);
				if (my < -40)			vy -= Std.int(Game.SPEED * 0.5);
				if (my > 40)			vy += Std.int(Game.SPEED * 0.5);
				
				if (stage != null && AKApi.isClicked(stage) && !justClicked && !player.isOD)	player.startOD();
				//
				if (isDownFn(K.LEFT) || isDownFn(K.RIGHT) || isDownFn(K.UP) || isDownFn(K.DOWN)) {
					Game.MOUSE_MODE = false;
					mouseTimer = false;
					var xx = Game.SIZE.width / 2 - Level.instance.container.x;
					var yy = 10 - Level.instance.container.y;
					Fx.instance.plainText(Text.mouseModeOff, 0xFFFFFF, 14, xx, yy);
				}
			}
			// KEYBOARD MODE
			else {
				if ( (isDownFn(K.SPACE) || isDownFn(K.CONTROL)) && !player.isOD)	player.startOD();
				
				#if tuning
				if ( (isDownFn(K.CONTROL)) && !player.isOD){
					player.overdrive = Player.MAXIMUM_OVERDRIVE;
					player.startOD(true);
				}
				#end 
				
				if (isDownFn(K.LEFT))	vx -= Std.int(Game.SPEED * 0.5);
				if (isDownFn(K.RIGHT))	vx += Std.int(Game.SPEED * 0.5);
				if (isDownFn(K.UP))		vy -= Std.int(Game.SPEED * 0.5);
				if (isDownFn(K.DOWN))	vy += Std.int(Game.SPEED * 0.5);
				//
				if (stage != null && AKApi.isClicked(stage) && !justClicked) {
					justClicked = true;
					var xx = Game.SIZE.width / 2 - Level.instance.container.x;
					var yy = 10 - Level.instance.container.y;
					if (mouseTimer) {
						Game.MOUSE_MODE = true;
						Fx.instance.plainText(Text.mouseModeOn, 0xFFFFFF, 14, xx, yy);
						FTimer.delay(function () { justClicked = false; }, 3);
					} else {
						mouseTimer = true;
						FTimer.delay(function () {
							mouseTimer = false;
						}, 30);
						Fx.instance.plainText(Text.mouseModeClick, 0xFFFFFF, 14, xx, yy);
					}
				} else if (!AKApi.isClicked(stage)) {
					justClicked = false;
				}
			}
			if (vx != 0)	player.vx = vx;
			if (vy != 0)	player.vy = vy;
		}
		
		// Detect if player is on sand
		var gt = getGroundType(player.center.x, player.center.y);
		if (gt == GroundType.Sand) {
			uiWrapper.shake();
			if (!endingGame)	player.doOverheat();
			
			if (!Fx.noFx()) {
				var isSand = Std.is(RoadEngine.sandBM, SandBMb);
				
				if(Dice.percent(33))
				{
					Fx.instance.sandTex(player.x - 12, player.bottomRight.y, 1, 1, isSand);
					Fx.instance.sandTex(player.x + 12, player.bottomRight.y, -1, 1, isSand);
				}
				player.dragSand = Player.MAX_DRAG_SAND;
			}
			//else Fx.instance.sandTex(player.x, player.bottomRight.y);
		} else {
			uiWrapper.y = Game.SIZE.height;
		}
		
		// Player update
		removeFromGrid(player);
		player.update(gt);
		player.x = MathEx.clamp(player.x, player.w / 2 + 4, roadB.width - player.w / 2 - 4);
		if (!Level.instance.endingGame)	player.y = MathEx.clamp(player.y, roadB.height - Game.SIZE.height + 4 - player.offset.y, roadB.height - player.h - 4 - player.offset.y);
		addToGrid(player);
		
		if ( player.overheat >= 0.1 && player.overheat < Player.MAXIMUM_OVERHEAT) {
			bloodB.alpha = (1 - MathEx.ratio(player.overheat, 0, Player.MAXIMUM_OVERHEAT));
			bloodB.visible = true;
		}
		else {
			bloodB.visible = false;
		}
		
		if (UIContainer.contains(flash)) {
			if (flash.alpha > 0)	flash.alpha = 0;
			else					UIContainer.removeChild(flash);
		}
		
		// Update entities
		for (e in entities) {
			removeFromGrid(e);
			if (e.needGroundType)	e.update(getGroundType(e.x + e.w / 2 + e.offset.x, e.y + e.h / 2 + e.offset.y));
			else					e.update();
			if (e.y > roadB.height + 100) {
				killEntity(e);
				continue;
			}
			//if ((Std.is(e, Obstacle) || Std.is(e, Shooter) || Std.is(e, Dropper)) && e.colliding && e.protection == 0) {
			if (!endingGame && Std.is(e, Obstacle) && e.colliding && e.protection == 0) {
				checkCollisionsEntity(e);
			}
			if (!e.dead && e.colliding)	addToGrid(e);
			
			if (endingGame) continue;
			
			// Check avoid
			if (Std.is(e, Obstacle) && cast(e, Obstacle).canAvoid && e.colliding && e.protection == 0 && cast(e, Obstacle).behaviour == Behaviour.Leader) {
				if (getGroundType(e.center.x, e.center.y) == GroundType.Sand || getColliding(e, 0, -100, true, true).length > 0) {
					var xTargets = new Array<Float>();
					var xDist = 48;
					var yDist = 48;
					if (getGroundType(e.center.x + xDist, e.y - yDist) == GroundType.Asphalt && getColliding(e, xDist, -yDist).length == 0)		xTargets.push(e.center.x + xDist);
					if (getGroundType(e.center.x - xDist, e.y - yDist) == GroundType.Asphalt && getColliding(e, -xDist, -yDist).length == 0)	xTargets.push(e.center.x - xDist);
					if (xTargets.length == 0) {
						if (e.center.x >= roadB.width / 2)	xTargets.push(e.center.x - xDist);
						else								xTargets.push(e.center.x + xDist);
					}
					cast(e, Obstacle).avoid(xTargets[Game.RAND.random(xTargets.length)]);
				}
			}
		}
		
		// Collisions
		//if (player.protection == 0)	checkCollisions();
		if (player.health > 0)	checkCollisions();
		
		// Center cam on player
		var cx = Game.SIZE.width / 2 - player.center.x;
		cx = MathEx.clamp(cx, -(roadB.width - Game.SIZE.width), 0);
		if (Math.abs(container.x - cx) < 0.1)	container.x = cx;
		else									container.x -= (container.x - cx) * 0.1;
		
		Fx.instance.update();
		
		uiWrapper.update(-player.speedRatio, player.overheatRatio, player.overdriveRatio);
		
		if (endingGame)	return;
		
		var pts:Int = Std.int(12 * player.scoreMod);
		AKApi.addScore(AKApi.const(Std.int(pts)));
		
		//if (player.scoreMod == 1.5)		Fx.instance.speedLines(1);
		//else if (player.scoreMod == 2)	Fx.instance.speedLines(2);
		
		if (AKApi.getGameMode() == GM_PROGRESSION) {
			// Kado
			if (kadoList.length > 0) {
				var ptarget = (kadoCount - kadoList.length + 1) * nextScore / (kadoCount + 1);
				if (AKApi.getScore() >= ptarget) {
					kadoList[0].x = positionKado();
					spawnEntity(kadoList.shift());
				}
			}
			// Progress
			progressMap.setProgress(AKApi.getScore() / nextScore);
			AKApi.setProgression(AKApi.getScore() / nextScore);
			// Reached next score
			if (AKApi.getScore() >= nextScore) {
				endGame();
			}
		}
		else if (AKApi.getGameMode() == GM_LEAGUE) {
			// Kado
			if (kadoList.length > 0) {
				if (AKApi.getScore() >=  kadoList[0].igpt.score.get()) {
					kadoList[0].x = positionKado();
					spawnEntity(kadoList.shift());
				}
			}
			// Reached next score
			if (AKApi.getScore() >= nextScore) {
				level += 2;
				nextScore += Data.l(level);
				Game.RATIO += 0.03;
				Game.SPEED = Std.int(Game.BASE_SPEED * Game.RATIO);
				road.upDifficulty();
			}
		}
		
		//_updateGrid();
	}
	
	function endGame () {
		player.overdrive = Player.MAXIMUM_OVERDRIVE;
		if (!player.isOD)	player.startOD(true);
		endingGame = true;
		FTimer.delay(callback(AKApi.gameOver, true), 80);
	}
	
	function positionKado () :Int {
		var x = Std.int(RoadEngine.lastRoadStart + Game.RAND.random(RoadEngine.lastRoadWidth - 3)) + 1;
		x *= Game.TILE_SIZE;
		/*var x = 0;
		var s = 0;
		while (getGroundType(x, 0) != GroundType.Asphalt && s < 50) {
			x = Game.RAND.random(Std.int(roadB.width));
			s++;
		}*/
		return x;
	}
	
	inline function removeFromGrid (v:Entity) :Void {
		//return;
		for (k in v.getKeys()) {
			if (grid.get(k) == null)	continue;
			
			var l = grid.get(k);
			while (l.remove(v)) { }
			//if (l.length == 0)	grid.remove(k);
		}
	}
	
	function addToGrid (v:Entity) :Void {
		//return;
		#if debug
		if ( v == null ) throw "can't add null";
		#end
		
		if (!v.colliding)	return;
		
		for (k in v.getKeys()) {
			var l;
			if ( grid.get(k) != null ) {
				#if debug 
				throw "already in grid !";
				#end 
				l = grid.get(k);
				while (l.remove(v)) { }
			}
			else {
				l = new List<Entity>();
				grid.set(k, l);
			}
			l.add(v);
		}
	}
	
	function getGroundType (x:Float, y:Float) :GroundType {
		x = x / Game.TILE_SIZE;
		y = y / Game.TILE_SIZE;
		var p = road.getBD().getPixel(Std.int(x), Std.int(y));
		
		switch (p & 0xFF0000) {
			case RE.SAND_COLOR:
				//player.baseColor = 0xFFFFFF;
				return GroundType.Sand;
			case RE.ROAD_COLOR:
				//player.baseColor = 0x6666FF;
				return GroundType.Asphalt;
			default:
				return GroundType.Unknown;
		}
	}
	
	public function getColliding (v:Entity, xOffset:Int = 0, yOffset:Int = 0, ignoreSameType:Bool = false, ignoreBonuses:Bool = false, onlyBonuses:Bool = false, forceRails:Bool = false) :List<Entity> {
		var cl = new List<Entity>();
		//return cl;
		var gk = v.getKeys(xOffset, yOffset);
		for (k in gk) {
			var g = grid.get(k);
			if (g == null)	continue;
			
			var l = g;
			for (lv in l) {
				if (lv == v || lv == player || (ignoreSameType && lv.type == v.type) || (ignoreBonuses && Std.is(lv, Bonus)))	continue;// doesn't collide with itself or the player
				else if (cl.indexOf(lv) == -1) {// if is not already listed as colliding
					if (((onlyBonuses && Std.is(lv, Bonus)) || !onlyBonuses))	cl.add(lv);
					else if (forceRails && Std.is(lv, Rail))					cl.add(lv);
				}
			}
		}
		return cl;
	}
	
	function checkCollisions () :Void {
		// Get colliding entities
		var cl:List<Entity> = null;
		if (player.protection == 0)	cl = getColliding(player);
		else						cl = getColliding(player, 0, 0, false, false, true, true);
		if (cl.length == 0)	return;
		// Remove player from grid
		removeFromGrid(player);
		// Apply collision effects
		for (e in cl) {
			if (Std.is(e, Bonus)) {
				cast(e, Bonus).use(player);
			}
			else if (Std.is(e, Rail)) {
				if (player.center == e.center)	player.x += (Game.RAND.random(2) * 2 - 1) / 10;
				var side = 1;
				if (player.center.x < e.center.x) {
					player.x = e.topLeft.x - player.w - player.offset.x;
				} else if (player.x > e.x) {
					player.x = e.bottomRight.x - player.offset.x;
					side = -1;
				}
				player.vx = 0;
				// Grind on the rail
				if (player.y > e.y) {
					//var d = Math.floor((player.y - e.y) / Game.SPEED);
					var d = Std.int(30 / Game.RATIO);
					player.doGrind(d, side);
				}
			}
			else if (Std.is(e, Shot)) {
				var dir = cast(e, Shot).direction;
				player.vx = Game.SPEED * 0.5 * dir;
				player.ctrlLock = 15;
				player.hit();
				e.colliding = false;
				EM.instance.dispatchEvent(new GameEvent(GE.CANCEL_SHOT));// Cancel all
				doFlash();
			}
			else if (Std.is(e, BulletImpact)) {
				var dir = cast(e, BulletImpact).direction;
				player.vx = Game.SPEED * 0.5 * dir;
				player.ctrlLock = 15;
				player.hit();
				EM.instance.dispatchEvent(new GameEvent(GE.CANCEL_SHOT));// Cancel all
				doFlash();
			}
			else if (Std.is(e, Drop)) {
				var dir = (player.center.x > e.center.x) ? 1 : -1;
				player.vx = Game.SPEED * 0.4 * dir;
				player.ctrlLock = 10;
				player.hit();
				killEntity(e);
				
					paintEntityDirect(  "hole_" + (Std.random(3) + 1), e.x + (e.w >> 1), e.y + (e.h >> 1));
					
				doFlash();
				doExplosion(e.center.x, e.center.y, e.vx, e.vy);
			}
			else if (Std.is(e, Oil)) {
				player.loseControl(Std.int(30 / Game.RATIO));
			}
			else if (Std.is(e, Obstacle) || Std.is(e, Dropper)) {
				// Standard resolution
				var dir = (player.center.x > e.center.x) ? -1 : 1;
				if (player.isOD || !Std.is(e, Obstacle) || (Std.is(e, Obstacle) && !cast(e, Obstacle).monster)) {
				//if (!Std.is(e, Obstacle) || (Std.is(e, Obstacle) && !cast(e, Obstacle).monster)) {
					e.selfDestruct(15, dir);
				}
				player.hit();
				doFlash();
				// Points
				if (AKApi.getGameMode() == GM_LEAGUE) {
					var pts:Int = 981 + Game.RAND.random(19);
					var col = 0xFFFFFF;
					var size = 36;
					if (Std.is(e, Obstacle) && e.version == 666) {
						pts *= 2;
						size = 42;
					} else if (Std.is(e, Shooter) || Std.is(e, Dropper)) {
						pts *= 4;
						size = 48;
					}
					AKApi.addScore(AKApi.const(Std.int(pts)));
					Fx.instance.text("+" + pts, col, size, e.center.x, e.topLeft.y - size/2);
				 }
			}
			//else trace("colliding with " + e);
		}
		// Add player back to grid
		addToGrid(player);
	}
	
	function checkCollisionsEntity (ee:Entity) :Void {
		// Get colliding entities
		var cl:List<Entity> = getColliding(ee);
		if (cl.length == 0)	return;
		// Remove entity from grid
		removeFromGrid(ee);
		// Apply collision effects
		for (e in cl) {
			if (Std.is(e, Rail)) {
				ee.selfDestruct();
			}
			else if (Std.is(e, Oil)) {
				ee.loseControl(Std.int(30 / Game.RATIO));
			}
			else if (Std.is(e, Shot)) {
				var dir = cast(e, Shot).direction;
				ee.selfDestruct(15, dir);
			}
			else if (Std.is(e, BulletImpact)) {
				var dir = cast(e, BulletImpact).direction;
				ee.selfDestruct(15, dir);
			}
			else if (Std.is(e, Drop)) {
				var dir = (ee.center.x > e.center.x) ? 1 : -1;
				ee.selfDestruct(15, dir);
				killEntity(e);
				paintEntityDirect(  "hole_" + (Std.random(3) + 1), e.x + (e.w >> 1), e.y + (e.h >> 1));
				doExplosion(e.center.x, e.center.y, e.vx, e.vy);
			}
			else if (Std.is(e, Obstacle)) {
				var oe = cast(e, Obstacle);
				var oee = cast(ee, Obstacle);
				var dir = (ee.center.x > e.center.x) ? -1 : 1;
				//if (ee.type == OT.OMonster && e.type == OT.OMonster) {
				if (oe.monster && oee.monster) {
					if (ee.center.y > e.center.y)	e.selfDestruct();
					else							ee.selfDestruct();
				} else {
					if (oee.monster)		e.selfDestruct();
					else if (oe.monster)	ee.selfDestruct();
					else {
						e.selfDestruct();
						ee.selfDestruct();
					}
				}
			}
			else if (Std.is(e, Shooter) || Std.is(e, Dropper)) {
				var dir = (ee.center.x > e.center.x) ? -1 : 1;
				ee.selfDestruct();
			}
			//else trace("colliding with " + e);
		}
		// Add entity back to grid
		if (ee.colliding)	addToGrid(ee);
	}
	
	function doExplosion (x:Float, y:Float, vx:Float = 0, vy:Float = 0, size:Int = 0) {
		var xplos = new Explosion(size);
		xplos.x = x - xplos.w / 2;
		xplos.y = y - xplos.h / 2;
		xplos.vx = vx;
		xplos.vy = vy;
		var sd = new SpawnData(xplos, { _adaptY:false } );
		EM.instance.dispatchEvent(new GameEvent(GE.SPAWN_ENTITY, sd));
		paintEntityDirect(  "hole_" + (Std.random(3) + 1), xplos.x + (xplos.w >> 1), xplos.y + (xplos.h >> 1));
	}
	
	function doFlash () {
		if (player.isOD)	return;
		flash.alpha = 1;
		UIContainer.addChild(flash);
	}
	
	function paintEntity (data: { f:String, x:Int, y:Int, b:BlendMode } ) {
		//trace("paint " + data);
		Game.TAP.x = data.x;
		Game.TAP.y = data.y;
		FM.copyFrame(roadBD, data.f, Game.SHEET_ROAD, Game.TAP, true, false, data.b);
	}
	
	public inline function paintEntityDirect ( f:String, x, y) {
		Game.TAP.x = x;
		Game.TAP.y = y;
		FM.copyFrame(roadBD, f, Game.SHEET_ROAD, Game.TAP, true, false, BlendMode.NORMAL);
	}
	
	public inline function paintEntityMul ( f:String, x, y) {
		Game.TAP.x = x;
		Game.TAP.y = y;
		FM.copyFrame(roadBD, f, Game.SHEET_ROAD, Game.TAP, true, false, BlendMode.MULTIPLY );
	}
	
	function spawnEntity (e:Entity, ?p:Dynamic) {
		var adaptY = true;
		if (p != null) {
			//trace(Reflect.hasField(p, "_adaptY"));
			if (Reflect.hasField(p, "_adaptY"))		adaptY = Reflect.getProperty(p, "_adaptY");
			e.setParams(p);
		}
		
		if (adaptY)	e.y += roadB.y - Game.SPEED;
		
		if (Std.is(e, Dropper)) {
			if (getCount(Dropper, true) > 0) {
				e.destroy();
				e = null;
				return;
			}
			cast(e, Dropper).init(roadB.height - Game.SIZE.height);
			EM.instance.dispatchEvent(new GameEvent(GE.LOCK_ROAD));
		}
		else if (Std.is(e, Shooter)) {
			if (allowedShooters > 0) {
				allowedShooters--;
				cast(e, Shooter).init(roadB.height - Game.SIZE.height);
				//trace("SPAWNED (" + allowedShooters + " spots left)");
			}
			else {
				e.destroy();
				e = null;
				//trace("NOT SPAWNED");
				return;
			}
		}
		else if (Std.is(e, Rail) && cast(e, Rail).infinite == false) {
			var ty = Std.int(e.y + e.h + Game.TILE_SIZE);
			for (i in 0...7) {
				var name = "zebra";
				if (i == 0)			name = "zebra_top";
				else if (i == 6)	name = "zebra_bottom";
				paintEntityDirect( name, Std.int(e.x + 16), ty );
				ty += 32;
			}
		}
		else if (Std.is(e, Bonus)) {
			var h = new Hint();
			h.x = h.xx = e.center.x;
			h.y = -container.y + 10;
			dm.add(h, FX_DEPTH);
			cast(e, Bonus).hint = h;
			hints.push(h);
			//trace("-> spawned " + e.name);
		}
		
		dm.add(e, e.layer);
		//trace("added " + e + " to layer " + e.layer);
		entities.add(e);
	}
	
	public function setAllowedShooters (v:Int) :Int {
		if (getCount(Shooter) > 0) {
			return 0;
		} else {
			allowedShooters = v;
			return v;
		}
	}
	
	public function getAllowedShooters () {
		return allowedShooters;
	}
	
	function killEntity (e:Entity) {
		if (e.colliding)	removeFromGrid(e);
		entities.remove(e);
		if (container.contains(e))	container.removeChild(e);
		e.destroy();
	}
	
	public function getCount (type:Dynamic, stopAtFirst:Bool = false) :Int {
		if (entities == null)	return 0;
		var c = 0;
		for (e in entities) {
			if (Std.is(e, type)) {
				c++;
				if (stopAtFirst)	return c;
			}
		}
		//if (type == Shooter && c > 0)	trace(c + " " + type + " found");
		return c;
	}
	
	//{ DEBUG FUNCTIONS
	public function _updateGrid () {
		// Init if first call
		if (_gridBD == null) {
			_gridBD = new BitmapData(Std.int(gridSize.width), Std.int(gridSize.height), false);
			var _gridB = new Bitmap(_gridBD);
			_gridB.x = _gridB.y = 5;
			//_gridB.scaleX = _gridB.scaleY = 2;
			//_gridB.y = 32;
			addChild(_gridB);
		}
		// Copy the road
		var r = Game.TILE_SIZE / Game.GRID_SIZE;
		Game.TAM.identity();
		Game.TAM.scale(r, r);
		//var ct = new ColorTransform(1, 1, 1, 1, 128, 128, 128);
		//_gridBD.draw(road.getBD(), Game.TAM, ct);
		_gridBD.draw(road.getBD(), Game.TAM);
		// Add grid entities
		for (k in grid.keys()) {
			if (grid.get(k).length == 0)	continue;
			var kx = k & Game.BIT_MASK;
			var ky = k >> Game.BIT_OFFSET;
			if (kx >= 0 && ky >= 0 && kx < gridSize.width && ky < gridSize.height) {
				_gridBD.setPixel(kx, ky, 0xFFFFFF);
			}
		}
	}
	
	public function _countEnt () {
		trace("entities.length: " + entities.length + ", container.numChildren: " + container.numChildren);
		FTimer.delay(_countEnt, 30);
	}
	//}
	
}










