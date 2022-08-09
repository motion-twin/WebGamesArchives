/*
  BACKGROUND

    El tortuga, général tortue vétéran avec un bandeau sur l'oeil gauche,
	en a marre des tondeuses qui ont tué ses meilleurs soldats.

	Afin de  mettre fin à ce calvaire il a inventé un procédé de tonte
	révolutionnaire : la tonte laser par quadrillage de zone.

	Afin de démontrer l'efficacité de son invention aux humains il a décidé
	de tondre l'ensemble des jardins du quartier.

	Malheureusement son plan sera mis à rude épreuve par ses ennemis jurés
	les écureuils fous au dents d'aciers (qui prennent les tortues pour des
	noix géantes) et par Epice, le chien débile, qui rendra la progression
	d'El tortuga très compliquée.

  COMMENT JOUER

    Déployez votre cable laser sur la pelouse vierge, rejoignez le bord pour
	tondre la zone entourée.

	Démerdez-vous (touches fléchées + touche entrée pour sortir du chemin et
	déployer votre cable laser sur la zone non tondue.

  TODO

    - boss phases
	- bonuses

 */
import flash.Lib;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.events.Event;
import flash.display.Shape;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.text.TextField;
import geom.PVector;
import geom.Pt;
import KKApi;

enum GameOverKind {
	DOG;
	DOG_LAZERS;
	SQUIREL;
	ELECTRIFIED;
}

enum State {
	INIT;
	INIT_LEVEL;
	PLAY;
	CUT;
	SUCCESS;
	NEXT_LEVEL;
	GAME_OVER(k:GameOverKind);
}

class Game extends flash.display.Sprite {
	inline public static var VW = 300;
	inline public static var VH = 300;
	inline public static var W = 401;
	inline public static var H = 401;
	//inline public static var W = 301;
	//inline public static var H = 301;

	inline public static var PADW = 20;
	inline public static var PADH = 20;
	inline public static var SLOW_SPEED = 2.4;
	inline public static var FAST_SPEED = 3.8;
	inline public static var LINE_WIDTH = 1;

	static var instance : Game;
	static var drawKeyDown = false;
	static var origin = new flash.geom.Point(0,0);
	static var root : flash.display.MovieClip;
	static var state = INIT;
	static var drawColor : UInt = 0;
	static var pcent  : Text;
	static var pcentDecimal : Text;
	static var pcentGoal : Text;
	static var vpcent : Float = 0.0;
	public static var now : Float= 0;
	// The vile qix, boo boo
	public static var qix : Qix;
	// The Hero cursor
	static var cursor : Cursor;
	static var movePower : mt.flash.Volatile<Float> = 0.0;
	static var moveMod : mt.flash.Volatile<Int> = 10;
	// What is shown to the user
	static var view : BitmapData;
	// Resulting bitmap updated at each frame
	static var screen : BitmapData;
	// We use this bitmap for the game logic
	// (collision detection use getPixel32, etc.)
	static var moveZone : BitmapData;
	// A temporary bitmap
	static var buffer : BitmapData;
	// The visual 'safe' path as shown to the player
	static var visipath : BitmapData;
	// Last filled shape
	static var lastFill : BitmapData;
	// When the cursor move into the to-conquer zone,
	// we draw on this bitmap, it is a temporary bitmap
	public static var drawing : BitmapData;
	// Safe point where the drawing started from.
	public static var drawStart : PVector;
	public static var drawVector : Point;
	public static var drawStartTime : Float;
	// follow the hero drawing line to speed him up
	static var lazerSpark : LazerSpark;
	// goal
	static var stats : GameLevelStat;
	static var levelIdx : mt.flash.Volatile<Int> = 0;
	public static var level : Level;
	static var nBlocksWidth : mt.flash.Volatile<Int> = 10;
	static var nBlocksHeight : mt.flash.Volatile<Int> = 10;
	static var gameover = false;
	public static var field = new flash.geom.Rectangle();
	static var log = new Array();

	public function new(r:flash.display.MovieClip){
		super();
		var rect = new flash.display.Sprite();
		focusRect = rect;
		Game.root = r;
		flash.ui.Mouse.hide();
		instance = this;
		init();
		Game.root.addChild(this);
		KKApi.registerButton(Game.root);
		// Mouse.init(root.stage);
		Key.init();
		if (flash.Lib.current.stage != null)
			flash.Lib.current.stage.focus = this;

		#if debug
		com.remixtechnology.SWFProfiler.init(Game.root);
		#end
	}

	function init(){
		var fieldWidth = W - 2*PADW;
		nBlocksWidth = Math.floor(fieldWidth / moveMod);
		fieldWidth = nBlocksWidth * moveMod;
		var fieldHeight = H - 2*PADH;
		nBlocksHeight = Math.floor(fieldWidth / moveMod);
		fieldHeight = nBlocksHeight * moveMod;
		field.x = (W - fieldWidth) / 2;
		field.y = (H - fieldHeight) / 2;
		field.width = fieldWidth;
		field.height = fieldHeight;
		view = new BitmapData(VW, VH, true, 0xFF555500);
		screen = new BitmapData(W, H, true, 0x00000000);
		buffer = new BitmapData(W, H, true, 0x00000000);
		visipath = new BitmapData(W, H, true, 0x00000000);
		moveZone = new BitmapData(W, H, true, Colors.OUTSIDE);
		cursor = new Cursor();
		qix = new Qix();
		addChild(new Bitmap(view));
		pcent = new Text("00,", 16, 0xFFFFFFFF, 0xFF000000);
		pcentDecimal = new Text("0", 12, 0xFFFFFFFF, 0xFF000000);
		pcentGoal = new Text("99", 16, 0xFFFFFFFF, 0xFF000000);
		levelIdx = 0;
	}

	static function reset(levelNbr:Int){
		level = Level.get(levelNbr);
		levelIdx = levelNbr+1;
		stats = new GameLevelStat();
		log.push(stats);
		if (drawing != null){
			drawing.dispose();
			drawing = null;
		}
		lazerSpark = null;
		screen.fillRect(screen.rect, 0x00FFFFFF);
		buffer.fillRect(buffer.rect, 0x00000000);
		visipath.fillRect(visipath.rect, 0x00000000);
		moveZone.fillRect(moveZone.rect, Colors.OUTSIDE);
		moveZone.fillRect(
			new Rectangle(PADW, PADH-1, nBlocksWidth*moveMod+1, nBlocksHeight*moveMod+2),
			Colors.CONQUERED_PATH
		);
		moveZone.fillRect(
			new Rectangle(PADW+1, PADH, nBlocksWidth*moveMod-1, nBlocksHeight*moveMod-1),
			Colors.TO_CONQUER
		);
		cursor.moveVector = {x:0.0, y:0.0};
		movePower = 0.0;
		cursor.pos.x = PADW + moveMod * Math.floor(nBlocksWidth/2);
		cursor.pos.y = PADH + moveMod * nBlocksHeight - 1;
		cursor.oldPos = cursor.pos.clone();
		cursor.speed = FAST_SPEED;
		qix.setPos(Math.round(W/2), Math.round(H/4));
		qix.reset();
		vpcent = 0.0;
		deltaPcent = 0.0;
		refreshPercentCounter();
		updateVisiPath();
		MyGrass.update(true,true);
		Spark.reset();
	}

	// -----------------------------------------------------------------
	// Level completion statistics
	// -----------------------------------------------------------------

	static function updateStats(){
		var space = 4;
		var topX = PADW+1;
		var topY = PADH+1;
		var w = W - 2*topX;
		var h = H - 2*topY;
		var n = 0;
		var slow = 0;
		var fast = 0;
		var empty = 0;
		for (x in 0...Std.int(w/space)){
			for (y in 0...Std.int(h/space)){
				n++;
				var color = moveZone.getPixel32(topX+x*space, topY+y*space);
				if (Colors.isConqueredSlow(color))
					slow++;
				else if (Colors.isConqueredFast(color))
					fast++;
				else
					empty++;
			}
		}
		stats.update(slow, fast, empty, n, level.goal);
		if (stats.lastZone != null){
			KKApi.addScore(KKApi.const(stats.lastZone.value));
		}
	}

	static function refreshPercentCounter(){
		pcentGoal.setText("/"+level.goal+"%");
		pcentDecimal.setText(""+Math.floor((vpcent - Math.floor(vpcent))* 10));
		pcent.setText(StringTools.lpad(""+Math.floor(vpcent), "0", 2)+",");
	}

	static var deltaPcent = 0.0;

	static function updatePercentCounter(){
		if (stats != null && vpcent < stats.pcent){
			var maxt = (1.5 * mt.Timer.wantedFPS);
			var time = Math.min(maxt, deltaPcent*maxt/50);
			vpcent = Math.min(stats.pcent, vpcent + deltaPcent/time);
			refreshPercentCounter();
		}
	}

	// -----------------------------------------------------------------
	// Move/conquered zone handling
	// -----------------------------------------------------------------

	public static function getPixel( x:Int, y:Int ) : UInt {
		return moveZone.getPixel32(x,y);
	}

	public static function getPixels( x:Int, y:Int ) : Array<UInt> {
		return getPixelsAround(moveZone, x, y);
	}

	public static function getDrawingPixels( x:Int, y:Int ) : Array<UInt> {
		return getPixelsAround(drawing, x, y);
	}

	static function getPixelsAround( b:BitmapData, x:Int, y:Int ) : Array<UInt> {
		return [
			b.getPixel32(x-1, y-1),
			b.getPixel32(x,   y-1),
			b.getPixel32(x+1, y-1),
			b.getPixel32(x-1, y),
			b.getPixel32(x, y),
			b.getPixel32(x+1, y),
			b.getPixel32(x-1, y+1),
			b.getPixel32(x,   y+1),
			b.getPixel32(x+1, y+1),
		];
	}

	public static function getCursorPos() : { x:Int, y:Int } {
		return {
			x:Math.round(cursor.pos.x),
			y:Math.round(cursor.pos.y),
		};
	}

	static function updateCursor(){
		cursor.oldPos = cursor.pos.clone();
		var nextVector = null;
		var speed = cursor.speed * mt.Timer.tmod;
		if (speed > movePower){
			if (Key.LEFT.isDown)
				nextVector = { x:-1.0, y:0.0 };
			else if (Key.RIGHT.isDown)
				nextVector = { x:1.0, y:0.0 };
			else if (Key.UP.isDown)
				nextVector = { x:0.0, y:-1.0 };
			else if (Key.DOWN.isDown)
				nextVector = { x:0.0, y:1.0 };
		}
		while (speed > 0){
			if (movePower <= 0.00001){
				var prev = new PVector(Math.round(cursor.pos.x), Math.round(cursor.pos.y));
				cursor.pos.x = Math.round(cursor.pos.x);
				cursor.pos.y = Math.round(cursor.pos.y);
				cursorMoved(prev);
				if (nextVector != null
				&&  canMoveAt(Math.round(cursor.pos.x + nextVector.x*moveMod), Math.round(cursor.pos.y + nextVector.y*moveMod))
				&&  canMoveAt(Math.round(cursor.pos.x + nextVector.x*moveMod/2), Math.round(cursor.pos.y + nextVector.y*moveMod/2))
				){
					cursor.setNewMoveVector(nextVector.x, nextVector.y);
					movePower = moveMod;
				}
				else {
					movePower = 0;
					cursor.setNewMoveVector(0.0, 0.0);
					break;
				}
			}
			var n = Math.min(1, speed);
			var n = Math.min(n, movePower);
			speed -= n;
			movePower -= n;
			var prev = new PVector(Math.round(cursor.pos.x), Math.round(cursor.pos.y));
			cursor.pos.x += cursor.moveVector.x * n;
			cursor.pos.y += cursor.moveVector.y * n;
			cursorMoved(prev);
		}
		cursor.update();
	}

	static function canMoveAt( x:Int, y:Int ) : Bool {
		if (drawing != null && x == drawStart.x && y == drawStart.y)
			return false;
		var color : UInt = Colors.OUTSIDE;
		if (x > 0 && x < W && y > 0 && y < H)
			color = moveZone.getPixel32(x,y);
		switch (color){
			case Colors.CONQUERED_PATH, Colors.CONQUERED_PATH_FAST:
				var pixels = getPixelsAround(moveZone, x, y);
				for (pix in pixels){
					if (pix == Colors.TO_CONQUER){
						// ok at least one black zone is near
						return true;
					}
				}
				return false;

			case Colors.TO_CONQUER:
				if (drawing == null)
					return drawKeyDown;
				var pathColor = drawing.getPixel32(x, y);
				return pathColor == 0x00000000;

			default:
		}
		return false;
	}

	static function cursorMoved(prevPos:PVector){
		var x = Math.round(cursor.pos.x);
		var y = Math.round(cursor.pos.y);
		if (prevPos.x == x && prevPos.y == y)
			return;
		var color : UInt = moveZone.getPixel32(x,y);
		switch (color){
			case Colors.CONQUERED_PATH, Colors.CONQUERED_PATH_FAST:
				if (drawing != null)
					linkPoint(x, y, drawStart.clone().add(drawVector));

			case Colors.TO_CONQUER:
				if (drawing == null){
					cursor.speed = drawKeyDown ? SLOW_SPEED : FAST_SPEED;
					drawColor = cursor.speed == SLOW_SPEED ? Colors.DRAWING_PATH_SLOW : Colors.DRAWING_PATH_FAST;
					drawStart = prevPos;
					drawVector = new Point(cursor.pos.x-prevPos.x, cursor.pos.y-prevPos.y);
					drawVector.normalize(1.0);
					drawStartTime = now;
					drawing = new BitmapData(W,H,true,0x00000000);
				}
				if (drawing != null){
					drawing.setPixel32(x, y, drawColor);
					if (cursor.speed == SLOW_SPEED && !drawKeyDown){
						cursor.speed = FAST_SPEED;
						drawColor = Colors.DRAWING_PATH_FAST;
						drawing.floodFill(x, y, drawColor);
					}
				}

			case Colors.OUTSIDE:
				throw "Error, cursor is outside";
		}
	}

	static function linkPoint( x:Int, y:Int, start:PVector ){
		state = CUT;
		// Merge the line on the moveZone
		moveZone.copyPixels(drawing, drawing.rect, new Point(0,0), true);
		// get pixels around arrival zone, we need to determine two pixels, one for each separated zone
		var pixels = getPixelsAround(moveZone, x, y);
		var z1 = { x:0,   y:0   };
		var z2 = { x:0,   y:0   };
		if (pixels[0] == drawColor){
			z1 = { x:x-1, y:y   };
			z2 = { x:x,   y:y-1 };
		}
		else if (pixels[1] == drawColor){
			z1 = { x:x-1, y:y-1 };
			z2 = { x:x+1, y:y-1 };
		}
		else if (pixels[2] == drawColor){
			z1 = { x:x,   y:y-1 };
			z2 = { x:x+1, y:y   };
		}
		else if (pixels[3] == drawColor){
			z1 = { x:x-1, y:y-1 };
			z2 = { x:x-1, y:y+1 };
		}
		else if (pixels[5] == drawColor){
			z1 = { x:x+1, y:y-1 };
			z2 = { x:x+1, y:y+1 };
		}
		else if (pixels[6] == drawColor){
			z1 = { x:x-1, y:y   };
			z2 = { x:x,   y:y+1 };
		}
		else if (pixels[7] == drawColor){
			z1 = { x:x-1, y:y+1 };
			z2 = { x:x+1, y:y+1 };
		}
		else if (pixels[8] == drawColor){
			z1 = { x:x+1, y:y   };
			z2 = { x:x,   y:y+1 };
		}
		// ok, we don't need grey anymore, it's a path and we fill it with regular path white
		var color = if (drawColor == Colors.DRAWING_PATH_FAST) Colors.CONQUERED_PATH_FAST else Colors.CONQUERED_PATH;
		moveZone.floodFill(Math.round(start.x), Math.round(start.y), color);
		// ok time to decide which edge has to be filled
		var tmp = moveZone.clone();
		var fcolor : UInt = if (drawColor == Colors.DRAWING_PATH_FAST) Colors.CONQUERED_ZONE_FAST else Colors.CONQUERED_ZONE;
		var color : UInt = 0xFFFF0000;
		var z = z1;
		tmp.floodFill(z.x, z.y, color);
		var qPos = new PVector(qix.x, qix.y); // qix.getPos();
		if (tmp.getPixel32(Math.round(qPos.x), Math.round(qPos.y)) == color){
			// oups, wrong side :)
			z = z2;
			moveZone.floodFill(z.x, z.y, color);
			tmp.dispose();
		}
		else {
			// good side, let's swap
			moveZone.dispose();
			moveZone = tmp;
		}
		if (lastFill != null)
			lastFill.dispose();
		lastFill = moveZone.clone();
		var rArray : Array<Null<UInt>> = [];
		for (i in 0...256)
			rArray[i] = 0x01000000;
		rArray[255] = Colors.FLASH_COLOR;
		lastFill.paletteMap(moveZone, moveZone.rect, new flash.geom.Point(0,0), rArray, null, null, null);
		moveZone.floodFill(z.x, z.y, fcolor);
		drawing.dispose();
		drawing = null;
		lazerSpark = null;
		cursor.speed = FAST_SPEED;
		updateStats();
		deltaPcent = stats.pcent - vpcent;
		MyGrass.update(true);
		updateVisiPath();
	}

	/*
	  Update the visible path the hero can move on after a fill.

	  Method:
	  - floodfill the qix zone (in blue),
	  - extract the blue channel of the resulting bitmap
	  - duplicate this new bitmap in 4 directions
	  - invert the center (produces the outline)
	  - threshold the result to keep only the outline
	 */
	static function updateVisiPath(){
		buffer.fillRect(buffer.rect, 0x00000000);
		buffer.copyPixels(moveZone, moveZone.rect, new Point(0,0));
		var pq = qix.getPos();
		buffer.floodFill(Math.round(pq.x), Math.round(pq.y), 0xFF0000FF);
		buffer.copyChannel(buffer, buffer.rect, new Point(0,0), flash.display.BitmapDataChannel.BLUE, flash.display.BitmapDataChannel.ALPHA);
		visipath.fillRect(visipath.rect, 0x00000000);
		visipath.copyPixels(buffer, buffer.rect, new Point(-LINE_WIDTH,  0), true);
		visipath.copyPixels(buffer, buffer.rect, new Point( LINE_WIDTH,  0), true);
		visipath.copyPixels(buffer, buffer.rect, new Point( 0,  LINE_WIDTH), true);
		visipath.copyPixels(buffer, buffer.rect, new Point( 0, -LINE_WIDTH), true);
		visipath.draw(new flash.display.Bitmap(buffer), flash.display.BlendMode.INVERT);
		//var threshold = 0xFFFFFF00;
		var threshold = 0xFFFEFE01;
		var color = 0x00000000;
		var maskColor = 0xFFFFFFFF;
		visipath.threshold(visipath, visipath.rect, new flash.geom.Point(0,0), ">=", threshold, color, maskColor, true);
		var colorT = new flash.geom.ColorTransform(
			1, 1, 0.5, 1,
			100, 100, 100, 0
		);
		visipath.colorTransform(visipath.rect, colorT);
	}

	static var nextLevelScreen : LevelScreen;
	static var debriefLevelScreen : LevelDebriefingScreen;
	static var anim : CutParticleSystem;

	public function update(){
		now = flash.Lib.getTimer();
		if (flash.Lib.current.stage != null)
			flash.Lib.current.stage.focus = this;
		Key.update();
		drawKeyDown = Key.SPACE.isDown || Key.ENTER.isDown;
		#if debug
		if (Key.X.isDown){
			Key.X.isDown = false;
			if (untyped com.remixtechnology.SWFProfiler.displayed)
				untyped com.remixtechnology.SWFProfiler.hide();
			else
				untyped com.remixtechnology.SWFProfiler.show();
		}
		if (Key.DELETE.isDown){
			haxe.Log.clear();
			haxe.Log.setColor(Colors.LOG_COLOR);
		}
		#end
		switch (state){
			case INIT:
				state = NEXT_LEVEL;

			case NEXT_LEVEL:
				reset(levelIdx);
				state = INIT_LEVEL;
				nextLevelScreen = new LevelScreen(levelIdx, view);

			case INIT_LEVEL:
				if (nextLevelScreen.update(MyGrass.update())){
					nextLevelScreen = null;
					state = PLAY;
				}

			case PLAY:
				if (anim != null && anim.update())
					anim = null;
				if (drawing != null){
					if (lazerSpark != null)
						lazerSpark.update();
					else if (now - drawStartTime > level.lazerSparkDelay)
						lazerSpark = new LazerSpark();
				}
				qix.update();
				Spark.updateSparks();
				if (!checkCollisions())
					updateCursor();

			case CUT:
				qix.updateAnim();
				Spark.pauseSparksAnim();
				var ready = MyGrass.update();
				if (ready){
					// There is a little shit with getcolorbounds, its doesn't work like intended with alpha.
					var mask : UInt = 0x00FF0000;
					var color : UInt = Colors.FLASH_COLOR & mask;
					anim = new CutParticleSystem(lastFill, mask, color);
					lastFill.dispose();
					lastFill = null;
					if (stats.pcent >= level.goal){
						state = SUCCESS;
					}
					else {
						state = PLAY;
					}
				}

			case SUCCESS:
				if (anim != null && anim.update())
					anim = null;
				if (debriefLevelScreen == null)
					debriefLevelScreen = new LevelDebriefingScreen(levelIdx, stats);
				if (debriefLevelScreen.update()){
					debriefLevelScreen = null;
					anim = null;
					state = NEXT_LEVEL;
				}

			case GAME_OVER(goKind):
				if (!gameover){
					gameover = true;
					var l = Lambda.map(log, function(s)
						return [ s.pcent, s.score, s.list.length ]
					);
					KKApi.gameOver(Lambda.array(l));
				}
				qix.updateAnim();
				switch (goKind){
					case ELECTRIFIED:
					case DOG:
					case DOG_LAZERS:
					case SQUIREL:
				}
		}
		updatePercentCounter();
		render();
	}

	static function drawingCollidesQixLazers():Bool {
		if (qix.lazers == null)
			return false;
		if (drawing == null)
			return false;
		return (drawing.hitTest(origin, 255, qix.lazersBack, origin, 255) || drawing.hitTest(origin, 255, qix.lazersFront, origin, 255));
	}

	static function cursorCollidesQixLazers():Bool {
		if (qix.lazers == null)
			return false;
		var col = cursor.getCollisionBitmap();
		return (
			qix.lazersBack.hitTest(origin, 255, col, cursor.pos, 255) ||
			qix.lazersFront.hitTest(origin, 255, col, cursor.pos, 255)
		);
	}

	static function cursorCollidesSquirels():Bool {
		for (spark in Spark.sparks){
			var cpos = spark.pos.clone();
			// May have to test teleport (oldpos/newpos)
			if (Util.squareDist(cpos, cursor.pos) <= 17*17)
				return true;
		}
		return false;
	}

	static function checkCollisions(){
		#if debug
		// return false;
		#end
		if (drawing != null){
			if (drawing.hitTest(origin, 255, qix.bitmap, qix.getCollisionPos(), 255)){
				state = GAME_OVER(DOG);
				return true;
			}
			if (lazerSpark != null){
				if (lazerSpark.vector == null){
					state = GAME_OVER(ELECTRIFIED);
					return true;
				}
				var rect = new geom.Vector2D(lazerSpark.oldPos, lazerSpark.pos);
				if (rect.rectangleContains(cursor.pos) || rect.rectangleContains(cursor.oldPos)){
					state = GAME_OVER(ELECTRIFIED);
					return true;
				}
			}
			if (cursorCollidesQixLazers()){
				state = GAME_OVER(DOG_LAZERS);
				return true;
			}
			if (cursorCollidesSquirels()){
				state = GAME_OVER(SQUIREL);
				return true;
			}
		}
		else {
			if (cursorCollidesSquirels()){
				state = GAME_OVER(SQUIREL);
				return true;
			}
			if (cursorCollidesQixLazers()){
				state = GAME_OVER(DOG_LAZERS);
				return true;
			}
		}
		return false;
	}

	// -----------------------------------------------------------------
	// Rendering stuff
	// -----------------------------------------------------------------

	public static function drawAt( dst:BitmapData, src:flash.display.IBitmapDrawable, x:Float, y:Float, ?rotate:Float, ?blend:flash.display.BlendMode ){
		var m = new flash.geom.Matrix();
		if (rotate != null)
			m.rotate(rotate);
		m.translate(x,y);
		dst.draw(src, m, blend);
	}

	static function render(){
		// what we are going to show
		var vx = Math.min(Math.max(0, Math.round(cursor.pos.x - VW/2)), W-VW);
		var vy = Math.min(Math.max(0, Math.round(cursor.pos.y - VH/2)), H-VH);
		var rect = new Rectangle(vx, vy, VW, VH);
		var gok = null;
		if (gameover){
			switch(state){
				case GAME_OVER(k): gok = k;
				default:
			}
		}
		// wait for grass to be ready before drawing it and anything above it
		if (MyGrass.grass != null){
			screen.copyPixels(MyGrass.grass, MyGrass.grass.rect, new Point(0,0), true);
			screen.draw(new Bitmap(visipath), flash.display.BlendMode.ADD);
			// blink last fill if any
			if (lastFill != null)
				if (untyped mt.Timer.frameCount % 4 == 0)
					drawAt(screen, new Bitmap(lastFill), 0, 0, flash.display.BlendMode.SCREEN);
			// draw drawing line, blink on gameover
			if (drawing != null){
				if (!gameover || (gok != DOG) || untyped mt.Timer.frameCount % 10 >= 5)
					for (i in 0...LINE_WIDTH)
						drawAt(screen, new Bitmap(drawing), i, i, flash.display.BlendMode.ADD);
			}
			// draw turtle, blink on gameover
			if (!gameover || untyped mt.Timer.frameCount % 10 >= 5)
				drawAt(screen, cursor.gfx, cursor.pos.x, cursor.pos.y);
			// draw squirels
			for (spark in Spark.sparks)
				drawAt(screen, spark.movie, spark.pos.x, spark.pos.y);
			// draw qix back lazers
			if (qix.lazers != null){
				drawAt(screen, new Bitmap(qix.lazersBack), 0, 0);
				drawAt(screen, new Bitmap(qix.lazersBack), 0, 0, flash.display.BlendMode.ADD);
			}
			// draw qix
			drawAt(screen, qix, qix.x, qix.y);
			// draw qix front lazers
			if (qix.lazers != null){
				drawAt(screen, new Bitmap(qix.lazersFront), 0, 0);
				drawAt(screen, new Bitmap(qix.lazersFront), 0, 0, flash.display.BlendMode.ADD);
			}
			// draw drawing line spark
			if (lazerSpark != null)
				drawAt(screen, LazerSpark.shape, lazerSpark.pos.x, lazerSpark.pos.y);
		}
		// if some animation is occuring, render it
		if (anim != null)
			anim.render(screen);
		// put result on screen
		view.copyPixels(screen, rect, new Point(0,0), true);
		if (MyGrass.grass != null){
			drawAt(view, pcentGoal, VW-pcentGoal.width, 0);
			drawAt(view, pcentDecimal, VW-pcentGoal.width-pcentDecimal.width, 3);
			drawAt(view, pcent, VW-pcentGoal.width-pcentDecimal.width-pcent.width+4, 0);
		}
		if (debriefLevelScreen != null)
			debriefLevelScreen.render(view);
		if (nextLevelScreen != null)
			nextLevelScreen.render(view);
	}
}
