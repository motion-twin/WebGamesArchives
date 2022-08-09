import Protocole;
import mt.bumdum9.Lib;

typedef StageTile = { x:Int, y:Int, empty:Bool, id:Int, nei:Array<StageTile> };

class Stage
{//}
	static var DIR = [[1, 0], [0, 1], [ -1, 0], [0, -1]];

	static public var DP_FX = 			8;
	static public var DP_FRUITS = 		5;
	static public var DP_SNAKE = 		4;
	static public var DP_RELIEF = 		3;
	static public var DP_SHADE = 		2;
	static public var DP_UNDER_FX = 	1;
	static public var DP_BG = 			0;
	
	static public var WALL  = 			3;
	
	public var widthMax:Int;
	public var width:Int;
	public var height:Int;
	public var shadeLayer:flash.display.Sprite;

	
	public var bgScreen:flash.display.Bitmap;
	public var bg:pix.Element;
	public var gore:flash.display.Bitmap;
	public var relief:SP;
	public var ground:SP;
	var reliefBmp:flash.display.BitmapData;
	var art:flash.display.BitmapData;
	public var snakeRender:flash.display.Bitmap;

	
	public var dm:mt.DepthManager;
	public var root:flash.display.Sprite;
	var mask:flash.display.Sprite;
	public static var me:Stage;
	var seed:mt.Rand;
	
	public function new(w, h) {
		me = this;
		width = w;
		height = h;
		widthMax = width + 60;
		root = new flash.display.Sprite();
		Game.me.dm.add(root,Game.DP_STAGE);
		dm = new mt.DepthManager(root);
		seed = Game.me.seed.clone();
		//
		/*
		mask = new flash.display.Sprite();
		Game.me.root.addChild(mask);
		mask.graphics.beginFill(0xFF0000);
		mask.graphics.drawRect(0, 0, width, height);
		root.mask = mask;
		*/
		
		//
		initBg();
		
		// SNAKE RENDER
		/*
		snakeRender = new flash.display.Bitmap();
		snakeRender.bitmapData = new flash.display.BitmapData(width, height, true, 0);
		snakeRender.scaleX = 2;
		snakeRender.scaleY = 2;
		dm.add(snakeRender, DP_SNAKE);
		*/
		
		// SHADE
		shadeLayer = new flash.display.Sprite();
		Col.setPercentColor(shadeLayer, 1, 0 );
		shadeLayer.blendMode = flash.display.BlendMode.LAYER;
		shadeLayer.alpha = 0.5;
		
		var mc = new flash.display.Sprite();
		mc.blendMode = flash.display.BlendMode.OVERLAY;
		mc.addChild(shadeLayer);
		dm.add(mc, DP_SHADE);
		

		
		
	}
	
	// BG
	function initBg() {
		
		// BG SCREEN
		
		bgScreen = new flash.display.Bitmap();
		bgScreen.bitmapData = new flash.display.BitmapData(width, height, false, 0xFF0000 );
		dm.add(bgScreen, DP_BG);
		
		// STAGE
		bg = new pix.Element();
		var ma = WALL;
		var color = Gfx.col("green_0");
		art = new flash.display.BitmapData(widthMax - ma * 2, height - ma * 2, false, color );
		var cont = new flash.display.Bitmap();
		cont.bitmapData = art;
		cont.x = ma;
		cont.y = ma;
		bg.addChild(cont);
		

		
		// WALLS
		drawWalls();

		// GROUND
		ground = new SP();
		bg.addChild(ground);
		
		// GORE
		gore = new flash.display.Bitmap();
		gore.bitmapData = new flash.display.BitmapData(widthMax, height, true, 0 );
		bg.addChild(gore);
		
		// RELIEF
		genRelief();
		
		// DRAW TILES
		drawTiles();
		
		//
		renderBg();

	}
	function destroyBg() {
		bgScreen.parent.removeChild(bgScreen);
		bgScreen.bitmapData.dispose();
		gore.bitmapData.dispose();
		reliefBmp.dispose();
		art.dispose();
	}
	
	public function renderBg(?rect:flash.geom.Rectangle) {
		//rect = new flash.geom.Rectangle(WALL, WALL, width - WALL, height - WALL);
		bgScreen.bitmapData.draw(bg,null,null,null,rect);
	}
	function genRelief() {

		relief = new SP();
		relief.blendMode = flash.display.BlendMode.OVERLAY;
		
		var bmp = new flash.display.Bitmap();
		bmp.bitmapData = new flash.display.BitmapData(widthMax, height, false, 0x888888 );
		
		bmp.alpha = 1;
		bmp.x = WALL;
		bmp.y = WALL;
		reliefBmp = bmp.bitmapData;
		
		
		
		relief.addChild(bmp);
		bg.addChild(relief);
		return;
	
		
	}
	function palRestrict(bmp:flash.display.BitmapData, n=32) {
		for ( x in 0...bmp.width) {
			for ( y in 0...bmp.height) {
				var pix = bmp.getPixel32(x, y);
				var  o = Col.colToObj32(pix);
				var r = Std.int(o.r / n) * n;
				var g = Std.int(o.g / n) * n;
				var b = Std.int(o.b / n) * n;
				o = { r:r, g:g, b:b, a:o.a };
				bmp.setPixel32( x, y , Col.objToCol32(o) );
			}
		}
	}

	// TILES
	var txMax:Int;
	var tyMax:Int;
	var grid:Array < Array<StageTile> > ;
	var tiles:Array<StageTile>;
	function drawTiles() {
		var ec = 16;
		txMax = Std.int( widthMax / 16 );
		tyMax = Std.int( height / 16 );
		grid = [];
		tiles = [];
		
		var density = 2+seed.random(8);
		
		
		for( x in 0...txMax ) {
			grid[x] = [];
			for(y in 0...tyMax ) {
				var o = { x:x, y:y, empty:seed.random(density) == 0, id:0, nei:[] };
				grid[x][y] = o;
				tiles.push(o);
			}
		}
		
		// NEI
		for( t in tiles ) {
			var id = 0;
			for( d in DIR ) {
				var nx = t.x + d[0];
				var ny = t.y + d[1];
				if(nx >= 0 && nx < txMax && ny >= 0 && ny < tyMax ) t.nei[id] = grid[nx][ny];
				id++;
			}
		}
		
		//
		expandEmpty();
		//
		setTilesBorders();
		//
		
		for( t in tiles ) {
			var fid = 32 + t.id + seed.random(2) * 16;
			
			var fr = Gfx.tilesColor.get( fid );
			fr.drawAt( art, t.x * 16, t.y * 16 );
			var fr = Gfx.tilesGrey.get( fid );
			fr.drawAt( reliefBmp, t.x * 16, t.y * 16 );
		}
		
		
	}
	function expandEmpty() {
		for( t in tiles ) {
			if( t.empty ) continue;
			var rnd = 0;
			for( i in 0...4 ) if( t.nei[i] != null && t.nei[i].empty ) rnd++;
			rnd = [100, 7, 4, 3, 2][rnd];
			if( seed.random(rnd) == 0 ) t.empty = true;
		}
		
	}
	
	function setTilesBorders() {
		for( t in tiles ) {
			if( t.empty ) {
				t.id = 0;
				continue;
			}
			var sum = 0;
			for( i in 0...4 ) if( t.nei[i] == null || !t.nei[i].empty ) sum += Std.int(Math.pow(2, (i+1)%4));
			t.id = sum;
		}
	}
	

	
	//
	public function incSize(winc,hinc) {
		width += winc;
		height += hinc;
		if ( width >= widthMax ) width = widthMax;
		bgScreen.bitmapData.dispose();
		bgScreen.bitmapData = new flash.display.BitmapData(width, height, false, Gfx.col("green_1"));
		drawWalls();
		renderBg();
	}

	
	// WALLS
	var mcWalls:flash.display.Sprite;
	
	public function drawWalls() {
		if( mcWalls == null ) {
			mcWalls = new flash.display.Sprite();
			dm.add(mcWalls,DP_BG);
		}
		
		var gfx = mcWalls.graphics;
		gfx.clear();
		var col = Gfx.col("green_2");
		gfx.beginFill(col);
		for( i in 0...WALL ) {
			gfx.beginFill(col);
			gfx.beginFill(Col.brighten(col,-20));
			gfx.drawRect(i, i, width - (2 * i), 1);
			
			gfx.beginFill(Col.brighten(col,25));
			gfx.drawRect(width - (i + 1), i, 1, height - 2 * i);
			
			gfx.beginFill(Col.brighten(col,45));
			gfx.drawRect(i, height - (i + 1), width - 2 * i, 1);
			
			gfx.beginFill(Col.brighten(col,0));
			gfx.drawRect(i, i, 1, height - 2 * i);
		}
				
	}
	
	// COMMANDS
	public function setPos(x, y) {
		root.x = x;
		root.y = y;
		if( mask != null ) {
			mask.x = x;
			mask.y = y;
		}
	}
	public function getGlobalPos(x,y) {
		return { x:x + root.x, y:y + root.y };
		
	}
	public function getRandomPos(ma = 0, ?snakeRay, ?obsRay ) {
		var x = ma + Game.me.seed.rand() * (width - 2 * ma);
		var y = ma + Game.me.seed.rand() * (height - 2 * ma);
		if ( snakeRay != null && Game.me.snake!= null && !Game.me.snake.dead ) {
			var dx = Game.me.snake.x - x;
			var dy = Game.me.snake.y - y;
			var dist = Math.sqrt(dx * dx + dy * dy);
			if ( dist < snakeRay ) 	return getRandomPos(ma, snakeRay, obsRay );
		}
		if( obsRay != null) {
			for( obs in Game.me.obstacles ) {
				var dx = obs.x - x;
				var dy = obs.y - y;
				if( Math.sqrt(dx * dx + dy * dy) > obsRay + obs.ray ) continue;
				return getRandomPos(ma, snakeRay, obsRay );
			}
		}
		return new flash.geom.Point(x,y);
	
	}
	public function getWallPos(c:Float,ma=0.0) {
				
		var ww = Stage.me.width-2*ma;
		var hh = Stage.me.height-2*ma;
		var length =  ww + ww + hh + hh;
		var dist =  c * length;
	
		if( dist < ww ) 			return { x:ma+dist, y:ma };
		dist -= ww;
		if( dist < hh ) 			return { x:ma+ww, y:ma+dist };
		dist -= hh;
		if( dist < ww ) 			return { x:ma+ww-dist, y:ma+hh };
		dist -= ww;
		if( dist < hh ) 			return { x:ma, y:ma+hh-dist };
		
		return null;
	}
	public function clamp(x, y, ray=0) {
		return {
			x:Num.mm( ray, x, width - ray),
			y:Num.mm( ray, y, height - ray),
		};
	}

	public function getPart(str, ?dp) {
		if ( dp == null ) dp = DP_FX;
		var p = Part.get();
		var anim = Gfx.fx.getAnim(str);
		p.sprite.setAnim(anim, false);
		p.sprite.anim.onFinish = p.kill;
		dm.add(p.sprite, dp);
		return p;
		
	}
	public function sendToDepth(mc:flash.display.Sprite,d:Int) {
		if ( mc.parent != null ) mc.parent.removeChild(mc);
		dm.add(mc, d);
	}
	
	// UTILS
	public function isIn(x:Float,y:Float,ray) {
		return x >= ray && x < width - ray && y >= ray && y < height ;
	}
	
	//
	public function kill() {
		if(root.parent != null) root.parent.removeChild(root);
		destroyBg();
		//snakeRender.bitmapData.dispose();
	}
	
//{
}












