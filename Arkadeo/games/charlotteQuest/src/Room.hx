import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import mt.flash.Volatile;
import mt.deepnight.RandList;

import api.AKProtocol;

import Game;

enum RoomKind {
	Bedroom;
	Horizontal;
	VerticalUp;
	VerticalDown;
	ToUp;
	ToDown;
	FromUp;
	FromDown;
}

enum RoomTheme {
	Castle1;
	Castle2;
	Castle3;
	Bubbles1;
	Bubbles2;
}

class Room {
	public static var ALL : Array<Room> = [];
	static var ATTACHED : Array<Room> = [];
	static var DISTANCE = 0;
	public static inline var PADDING = 32;
	public static inline var GRID = 30;
	public static var CWID = Std.int( Game.WID/GRID );
	public static var CHEI = Std.int( Game.HEI/GRID );
	public static var PERLIN : BitmapData;
	//static var WID = Std.int( CWID/GRID );
	//static var HEI = Std.int( CHEI/GRID );
	
	var game			: Game;
	var marks			: Hash<Bool>; // pour placements des ennemis
	var theme			: RoomTheme;
	
	//public var wrapper		: Sprite;
	public var walls		: Bitmap;
	public var mcCont		: Sprite;
	public var bg			: Bitmap;
	public var splashes		: Bitmap;
	
	public var cx			: Int;
	public var cy			: Int;
	public var collisions	: Array<Array<Bool>>;
	var emptySpots			: Array<{x:Int, y:Int}>;
	var wallSpots			: Array<{x:Int, y:Int}>;
	public var kind			: RoomKind;
	public var ready		: Bool;
	var extraCache			: RandList<BitmapData>;
	var drawCont			: Sprite;
	var drawStep			: Int;
	var addList				: Array<flash.display.DisplayObject>;
	
	public var seed			: Int;
	var rseed				: mt.Rand;
	public var hasPowerUp	: Volatile<Bool>;
	public var hasUber		: Volatile<Bool>;
	public var distance		: Volatile<Int>;
	public var shop			: Null<{cx:Int, cy:Int}>;
	public var arrival		: Null<{cx:Int, cy:Int}>;
	public var kpoints		: Array<api.SecureInGamePrizeTokens>;
	
	public function new(x,y, k:RoomKind) {
		distance = DISTANCE++;
		ALL[distance] = this;
		kind = k;
		game = Game.ME;
		emptySpots = new Array();
		wallSpots = new Array();
		ready = false;
		cx = x;
		cy = y;
		seed = game.seed + distance*999;
		rseed = new mt.Rand(seed);
		marks = new Hash();
		kpoints = new Array();
		hasPowerUp = false;
		hasUber = false;
		extraCache = new mt.deepnight.RandList();
		drawStep = 0;
		theme =
			if( game.glevel < 5 ) Castle1;
			else if( game.glevel<10 ) Castle2;
			else if( game.glevel<15 ) Castle3;
			else if( game.glevel<19 ) Bubbles1;
			else Bubbles2;
		
		if( PERLIN==null ) {
			var pseed = game.isProgression() ? game.glevel : game.seed;
			rseed.initSeed(pseed);
			PERLIN = new BitmapData( 400,400, true, 0x0 );
			//PERLIN.perlinNoise( 30,20, 1, game.seed, true, true, 1, true );
			PERLIN.perlinNoise( rseed.irange(12,25),rseed.irange(8,30), rseed.irange(1,2), pseed, true, true, 1, true );
			PERLIN.threshold( PERLIN, PERLIN.rect, new flash.geom.Point(0,0), "<", mt.deepnight.Color.addAlphaF(0x838383), 0x0 );
			//game.debug.addChild( new Bitmap(PERLIN) );
		}
		
		collisions = new Array();
		for( x in 0...CWID ) {
			collisions[x] = new Array();
			for( y in 0...CHEI )
				collisions[x][y] = false ;
		}
		
		//wrapper = new Sprite();
		//wrapper.x = cx*CWID*GRID;
		//wrapper.y = cy*CHEI*GRID;
		
		bg = new Bitmap();
		//wrapper.addChild(bg);
		bg.x = bg.y = -PADDING;
		
		splashes = new Bitmap();
		//wrapper.addChild(splashes);
		splashes.x = splashes.y = -PADDING;
		
		mcCont = new Sprite();
		//wrapper.addChild(mcCont);
		
		walls = new Bitmap();
		//wrapper.addChild(walls);
		walls.x = walls.y = -PADDING;

		game.setRoom(cx,cy, this);
		generate();
	}
	
	public inline function getEmptySpotsCopy() {
		return emptySpots.copy();
	}
	
	public function getWallSpotsCopy() {
		return wallSpots.copy();
	}
	

	public inline  function getPerlin(x:Float,y:Float)  {
		var x = Std.int(x);
		var y = Std.int(y);
		
		while( x<0 )
			x+=PERLIN.width;
		while( x>=PERLIN.width )
			x-=PERLIN.width;
			
		while( y<0 )
			y+=PERLIN.height;
		while( y>=PERLIN.height)
			y-=PERLIN.height;
			
		return PERLIN.getPixel32(x,y);
	}
	
	public inline function mark(cx:Int,cy:Int) {
		marks.set(cx+","+cy, true);
	}
	
	public inline function hasMark(cx:Int,cy:Int) {
		return marks.get(cx+","+cy);
	}
	
	public function generate() {
		if( game.isLeague() )
			rseed.initSeed(seed);
		else
			rseed.initSeed(game.glevel+distance);
		var id = switch(kind) {
			case Bedroom : "bedroom";
			case Horizontal : "horizontal";
			case VerticalUp, VerticalDown : "vertical";
			case ToUp, ToDown : "toUp";
			case FromUp, FromDown : "toUp";
			//case FromUp, FromDown : "fromUp";
		}
		
		var min = 0;
		min += Std.int( game.diff*0.35 );
		var realMax = game.levels.countFrames(id)-1;
		var max = Std.int( 2 + realMax * game.diff/17 );
		if( min>=10 )
			min = 10;
		if( max>realMax )
			max = realMax;
			
		//trace(kind+" "+min+" -> "+max);
		var f = if( distance==0 ) 0 else rseed.irange(min,max);
		var bd = game.levels.getBitmapData( id, f ) ;
		
		// Miroirs
		switch(kind) {
			case Horizontal :
				if( rseed.random(2)==0 )
					mirror(bd, false, true);
			case VerticalDown, VerticalUp :
				if( rseed.random(2)==0 ) {
					var r = rseed.random(4);
					mirror(bd, r&1!=0, r&2!=0);
				}
			case ToDown :
				mirror(bd, false, true);
			case FromUp :
				mirror(bd, true, false);
			case FromDown :
				mirror(bd, true, true);
			default :
		}
		
		// Init collisions
		emptySpots = new Array();
		for(x in 0...CWID)
			for(y in 0...CHEI) {
				var p = bd.getPixel(x,y);
				if( p==0xffffff )
					collisions[x][y] = true;
				else {
					emptySpots.push({x:x, y:y});
					collisions[x][y] = false;
				}
			}
		
		for( pt in emptySpots )
			if( getCol(pt.x-1, pt.y) || getCol(pt.x+1, pt.y) || getCol(pt.x, pt.y-1) || getCol(pt.x, pt.y+1) )
				if( pt.x>=4 && pt.x<CWID-4 || pt.y>=4 && pt.y<CHEI-4 )
					wallSpots.push(pt);
			
		bd.dispose();
	}
	
	function mirror(bd:BitmapData, flipX:Bool, flipY:Bool) {
		var tmp = bd.clone();
		var m = new flash.geom.Matrix();
		if( flipX ) {
			m.scale(-1, 1);
			m.translate(bd.width, 0);
		}
		if( flipY ) {
			m.scale(1, -1);
			m.translate(0, bd.height);
		}
		bd.draw(tmp, m);
		tmp.dispose();
	}
	
	public function addShop() {
		rseed.initSeed(seed);
		var spots = getWallSpotsCopy();
		var tries = 2000;
		while( shop==null && tries-->0 && spots.length>0 ) {
			var pt = spots.splice( rseed.random(spots.length), 1 )[0];
			var x = pt.x;
			var y = pt.y;
			if( x>=2 && x<CWID-2 )
				if( getCol(x, y+1) && !getCol(x-1, y) && !getCol(x+1, y) && getCol(x-1, y+1) && getCol(x+1, y+1) )
					if( !getCol(x-1, y-1) && !getCol(x, y-1) && !getCol(x+1, y-1) ) {
						shop = { cx : pt.x, cy : pt.y }
						break;
					}
		}
		return shop!=null;
	}
	
	public function addArrival() {
		rseed.initSeed(seed);
		var spots = getWallSpotsCopy();
		var tries = 1000;
		while( arrival==null && tries-->0 && spots.length>0 ) {
			var pt = spots.splice( rseed.random(spots.length), 1 )[0];
			var x = pt.x;
			var y = pt.y;
			if( x>=2 && x<CWID-2 )
				if( getCol(x, y+1) && !getCol(x-1, y) && !getCol(x+1, y) )
					arrival = { cx : pt.x, cy : pt.y }
		}
		return arrival!=null;
	}
	
	public function getPoint() {
		return {x:cx*GRID*CWID, y:cy*GRID*CHEI}
	}
	
	public function toString() {
		return "Room_"+kind+"#"+distance+"@"+cx+","+cy+"("+CWID+"x"+CHEI+")";
	}
	
	public function globalToLocal(gcx:Int,gcy:Int) {
		return { cx : gcx-this.cx*CWID, cy : gcy-this.cy*CHEI }
	}
	public function localToGlobal(lcx:Int,lcy:Int) {
		return { cx : lcx+this.cx*CWID, cy : lcy+this.cy*CHEI }
	}
	
	public function getNextDir() : {dx:Int, dy:Int} {
		return switch(kind) {
			case Bedroom		: {dx:1, dy:0};
			case Horizontal		: {dx:1, dy:0};
			case VerticalUp		: {dx:0, dy:-1};
			case VerticalDown	: {dx:0, dy:1};
			case ToUp			: {dx:0, dy:-1};
			case ToDown			: {dx:0, dy:1};
			case FromUp			: {dx:1, dy:0};
			case FromDown		: {dx:1, dy:0};
		}
	}
	
	public function getNext() {
		return ALL[distance+1];
		//var d = getNextDir();
		//return game.getRoom(cx+d.dx, cy+d.dy);
	}
	
	public function goneThrough() : Bool {
		var x = walls.x+PADDING - game.viewport.x;
		var y = walls.y+PADDING - game.viewport.y;
		var wid = CWID*GRID;
		var hei = CHEI*GRID;
		return switch( kind ) {
			case Horizontal, Bedroom	: x<=-wid;
			case VerticalUp		: y>=hei;
			case VerticalDown	: y<=-hei;
			case ToUp			: y>=hei;
			case ToDown			: y<=-hei;
			case FromUp			: x<=-wid;
			case FromDown		: x<=-wid;
		}
	}
	
	public function attach() {
		ATTACHED.push(this);
		game.sdm.add(bg, Game.DP_BG);
		game.sdm.add(splashes, Game.DP_BG);
		game.sdm.add(mcCont, Game.DP_BG);
		game.sdm.add(walls, Game.DP_LEVEL);
		
		bg.x = splashes.x = walls.x = cx*CWID*GRID-PADDING;
		bg.y = splashes.y = walls.y = cy*CHEI*GRID-PADDING;
		mcCont.x = cx*CWID*GRID;
		mcCont.y = cy*CHEI*GRID;
		
		if( !ready )
			draw();
	}
	public function detach() {
		ATTACHED.remove(this);
		var a = Game.TW.create(bg, "alpha", 0, 3000);
		a.onUpdate = function() {
			splashes.alpha = mcCont.alpha = walls.alpha = bg.alpha;
		}
		a.onEnd = function() {
			bg.parent.removeChild(bg);
			splashes.parent.removeChild(splashes);
			mcCont.parent.removeChild(mcCont);
			walls.parent.removeChild(walls);
		}
	}
	
	public inline function last(?endDistance=0) {
		return distance>=ALL.length-1-endDistance;
	}
	
	inline function isTheme(t:RoomTheme) {
		return Type.enumIndex(theme) == Type.enumIndex(t);
	}
	
	function draw() {
		#if dev
		var t = flash.Lib.getTimer();
		#end
		
		var pt0 = new flash.geom.Point(0,0);
		
		splashes.bitmapData = new flash.display.BitmapData(CWID*GRID+PADDING*2, CHEI*GRID+PADDING*2, true, 0x0);
		splashes.blendMode = flash.display.BlendMode.SCREEN;
		
		rseed.initSeed(seed+drawStep);
		
		// Fond
		if( drawStep==3 ) {
			addList = [];
			var w = 8;
			var h = 6;
			var scaleX = (CWID*GRID / w) / GRID;
			var scaleY = (CHEI*GRID / h) / GRID;
			//var cw = GRID*scaleX;
			//var ch = GRID*scaleY;
			//trace(cw+" "+ch);
			for( x in 0...w )
				for( y in 0...h ) {
					if( getPerlin( (x+cx*w)*4, (y+cy*h)*4 ) == 0x0 )
						continue;
					var spr : flash.display.MovieClip = switch(theme) {
						case Castle1, Castle2, Castle3 : cast new lib.Brick();
						case Bubbles1, Bubbles2 : cast new lib.Brick2();
					}
					spr.gotoAndStop(rseed.random(spr.totalFrames)+1 );
					spr.x = scaleX * (x*GRID + GRID*0.5);
					spr.y = scaleY * (y*GRID + GRID*0.5);
					
					//spr.width = spr.height = 30 * s;// * (0.8+ rseed.rand()*0.2);
					if( x>0 && x<w-1 && y>0 && y<h-1 ) {
						var s = rseed.range(0.8, 1.4);
						spr.scaleX = scaleX * s;
						spr.scaleY = scaleY * s;
					}
					else {
						var s = rseed.range(1, 1.2);
						spr.scaleX = scaleX * s;
						spr.scaleY = scaleY * s;
					}
					spr.rotation = rseed.rand()*3 * (rseed.random(2)*2-1);
					switch(theme) {
						case Castle1, Castle2, Castle3 :
							spr.filters = [
								new flash.filters.DropShadowFilter(rseed.range(3,10),-90, 0x0,0.6, 0,0,1, 1,true),
								//new flash.filters.DropShadowFilter(rseed.range(3,10),90, 0x0,0.3, 2,2,1)
								new flash.filters.GlowFilter(0x0,0.4, 16,16,2),
							];
						case Bubbles1, Bubbles2 :
							spr.scaleX*=0.8;
							spr.scaleY*=0.8;
							spr.alpha = rseed.range(0.6, 0.9);
					}
					addList.push(spr);
				}
			drawCont = new Sprite();
			while( addList.length>0 )
				drawCont.addChild( addList.splice(rseed.random(addList.length),1)[0] );
		}
		
		// Cache bitmap fond
		if( drawStep==4 ) {
			bg.bitmapData = new flash.display.BitmapData(CWID*GRID+PADDING*2, CHEI*GRID+PADDING*2, true, 0x0);
			var bd = bg.bitmapData;
			var m = new flash.geom.Matrix();
			m.translate(PADDING, PADDING);
			flash.Lib.current.stage.quality = flash.display.StageQuality.LOW;
			bd.draw(drawCont, m);
			flash.Lib.current.stage.quality = flash.display.StageQuality.HIGH;
			bd.applyFilter(bd, bd.rect, pt0, mt.deepnight.Color.getContrastFilter(-0.5));
			bd.applyFilter(bd, bd.rect, pt0, mt.deepnight.Color.getColorizeMatrixFilter(game.bgColor, 0.75, 0.25));
			//switch( theme ) {
				//case Castle1, Castle2, Castle3 :
					//bd.colorTransform(bd.rect, mt.deepnight.Color.getColorizeCT(0x42242D, 0.7));
				//case Bubbles1, Bubbles2 :
					//bd.applyFilter(bd, bd.rect, pt0, mt.deepnight.Color.getColorizeMatrixFilter(0x1C3522, 0.7, 0.3));
			//}
			
			// Nuages de fin
			if( arrival!=null ) {
				addMC( new lib.Reveil(), arrival.cx*GRID + GRID*0.5, arrival.cy*GRID );
				var bmp = new Bitmap( new GfxCloudsArrival(0,0) );
				var w = bmp.width*2;
				var h = bmp.height*2;
				var d = getNextDir();
				var m = new flash.geom.Matrix();
				m.scale(2,2);
				if( d.dy==1 )
					m.translate(0, Game.HEI-h);
				if( d.dx==1 ) {
					m.scale(Game.HEI/Game.WID, 1);
					m.rotate(-Math.PI*0.5);
					m.translate(Game.WID-h, Game.HEI);
				}
				if( d.dy==-1 ) {
					m.translate(-w*0.5, -h*0.5);
					m.rotate(Math.PI);
					m.translate(w*0.5, h*0.5);
				}
				m.translate(PADDING, PADDING);
				bd.draw( bmp, m, flash.display.BlendMode.ADD );
			}
		}
		
		// Murs
		if( drawStep==0 ) {
			drawCont = new Sprite();
			addList = [];
			for( x in 0...CWID )
				for( y in 0...CHEI ) {
					if( !getCol(x,y) )
						continue;
					var spr : flash.display.MovieClip = switch( theme ) {
						case Castle1, Castle2 : cast new lib.Brick();
						case Castle3 : rseed.random(100)<85 ? cast new lib.Brick() : cast new lib.Brick2();
						case Bubbles1 : cast new lib.Brick2();
						case Bubbles2 : cast new lib.Brick2();
					}
					spr.gotoAndStop(rseed.random(spr.totalFrames)+1 );
					spr.x = x*GRID + GRID*0.5;
					spr.y = y*GRID + GRID*0.5;
					spr.rotation = rseed.range(0,15, true);
					switch( theme ) {
						case Castle1 :
							spr.scaleX = spr.scaleY = rseed.range(0.9, 1.3);
						case Castle2 :
							spr.scaleX = spr.scaleY = rseed.range(0.9, 1.3);
							var r = rseed.range(0.5, 0.7);
							spr.filters = [
								new flash.filters.DropShadowFilter(rseed.range(3,10),-90, 0x0,0.4, 0,0,1, 1,true),
								mt.deepnight.Color.getColorizeMatrixFilter(0xA55243, r, 1-r),
							];
						case Castle3 :
							spr.scaleX = spr.scaleY = rseed.range(0.9, 1.3);
							var r = rseed.range(0.7, 0.8);
							spr.filters = [
								//new flash.filters.DropShadowFilter(rseed.range(3,10),-90, 0x0,0.4, 0,0,1, 1,true),
								//mt.deepnight.Color.getColorizeMatrixFilter(0x798536, r, 1-r),
							new flash.filters.DropShadowFilter(rseed.range(3,6),90, 0xffffff,0.2, 0,0,1, 1,true),
								mt.deepnight.Color.getColorizeMatrixFilter(0x447777, r, 1-r),
								//new flash.filters.GlowFilter(0x0,0.3, 16,16,2, 1, true),
								//new flash.filters.DropShadowFilter(1,-90,0x96A82F, 0.7, 2,2,3, 1,true),
							];
						case Bubbles1 :
							spr.scaleX = spr.scaleY = rseed.range(0.7, 1.5);
							spr.transform.colorTransform = mt.deepnight.Color.getColorizeCT(0x181B30, rseed.range(0, 0.4));
							spr.alpha = rseed.range(0.7, 0.9);
						case Bubbles2 :
							spr.scaleX = spr.scaleY = rseed.range(0.7, 1.5);
							spr.transform.colorTransform = mt.deepnight.Color.getColorizeCT(0x181B30, rseed.range(0, 0.4));
							spr.filters = [ mt.deepnight.Color.getColorizeMatrixFilter(0x6053A6, 0.7, 0.3) ];
							spr.alpha = rseed.range(0.7, 0.9);
					}
					addList.push(spr);
				}
		}
		
		// Extras
		if( drawStep==1 ) {
			var herbChance = 1;
			var boneChance = 1;
			switch(theme) {
				case Castle1 : herbChance = 1;
				case Castle2 : herbChance = 7;
				case Castle3 : herbChance = 0;
				case Bubbles1, Bubbles2 : herbChance = 0;
			}
			// Herbes
			if( herbChance>0 ) {
				var mc = new lib.DecorHerbes();
				var w = 100;
				var m = new flash.geom.Matrix();
				m.scale(2,2);
				m.translate(w*0.5, w*0.5);
				for( f in 1...mc.totalFrames+1 ) {
					mc.gotoAndStop(f);
					var bd = new BitmapData(w,w, true, 0x0);
					bd.draw(mc, m);
					extraCache.add(bd, herbChance);
				}
			}
			// Ossements
			if( boneChance>0 ) {
				var mc = new lib.DecorBones();
				var w = 100;
				var m = new flash.geom.Matrix();
				m.scale(2,2);
				m.translate(w*0.5, w*0.5);
				for( f in 1...mc.totalFrames+1 ) {
					mc.gotoAndStop(f);
					var bd = new BitmapData(w,w, true, 0x0);
					bd.draw(mc, m);
					extraCache.add(bd, boneChance);
				}
			}
			
			var chance = switch( theme ) {
				case Castle1 : 40;
				case Castle2 : 80;
				case Castle3 : 50;
				case Bubbles1 : 20;
				case Bubbles2 : 70;
			}
			if( chance>0 )
				for( x in 0...CWID )
					for( y in 0...CHEI ) {
						if( !getCol(x,y) || rseed.random(100)>=chance )
							continue;
						if( !getCol(x,y-1) )
							continue;
						for( i in 0...rseed.irange(1,2) ) {
							var bmp = new Bitmap( extraCache.draw(rseed.random) );
							addList.push(bmp);
							var m = new flash.geom.Matrix();
							m.translate(-bmp.width*0.5, -bmp.height*0.5);
							m.rotate( rseed.range(0,6.28) );
							var s = 0.5 * rseed.range(0.4 ,1.6);
							m.scale(s,s);
							m.translate(
								x*GRID + GRID*0.5 + rseed.range(GRID*0.2, GRID*0.5, true),
								y*GRID + GRID*0.5 + rseed.range(GRID*0.2, GRID*0.5, true)
							);
							bmp.transform.matrix = m;
						}
					}
		}
		
		// Cache bitmap murs
		if( drawStep==2 ) {
			while( addList.length>0 )
				drawCont.addChild( addList.splice(rseed.random(addList.length),1)[0] );
			walls.bitmapData = new flash.display.BitmapData(CWID*GRID+PADDING*2, CHEI*GRID+PADDING*2, true, 0x0);
			var bd = walls.bitmapData;
			var m = new flash.geom.Matrix();
			m.translate(PADDING, PADDING);
			flash.Lib.current.stage.quality = flash.display.StageQuality.LOW;
			bd.draw(drawCont, m);
			flash.Lib.current.stage.quality = flash.display.StageQuality.HIGH;

			switch( theme ) {
				case Castle1, Castle2 :
					bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0x000000, 0.7, 32,32,2, 2));
				case Castle3 :
					//bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0x2E3214, 1, 2,2,2));
					//bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0x588E48, 0.2, 64,64,2, 2,true));
					//bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(2,90,0x535A25, 0.7, 4,32,2, 1,true));
					bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(3,90,0x535A25, 0.8, 4,2,2, 1,true));
					bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(1,-90,0x96A82F, 0.7, 2,2,3));
					//bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0xCDC172, 1, 2,2,1));
					//bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0x2E3214, 0.4, 32,32,1, 1,true));
					//bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0x474A11, 1, 4,4,2, 1,true));
					
					bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0x000000, 0.7, 32,32,2, 2));
				case Bubbles1, Bubbles2 :
					bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0x0, 0.8, 4,4,1, 2));
					bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0x0, 0.8, 32,32,1, 2));
					bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0x472E5C, 0.8, 16,16,1, 2, true));
					bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(10,90, 0x181B30,0.4, 32,32,1));
			}
			
			bd.applyFilter(bd, bd.rect, pt0, mt.deepnight.Color.getColorizeMatrixFilter(game.bgColor, 0.2, 0.8));
			for(e in extraCache.allValuesReadOnly)
				e.dispose();
			#if debug
			bd.fillRect( new flash.geom.Rectangle(PADDING,PADDING,3,Game.HEI), 0xffFFFF00 );
			bd.fillRect( new flash.geom.Rectangle(PADDING+Game.WID-3,PADDING,3,Game.HEI), 0xff0080FF );
			bd.fillRect( new flash.geom.Rectangle(PADDING,PADDING,Game.WID,3), 0xffFFFF00 );
			bd.fillRect( new flash.geom.Rectangle(PADDING,PADDING+Game.HEI-3,Game.WID,3), 0xff0080FF );
			#end
		}

		
		if( drawStep==4 ) {
			// Chambre
			if( distance==0 )
				addMC( mt.deepnight.Lib.flatten(new lib.Room()), 0,0 );
			
			// Boutique
			if( shop!=null ) {
				var mc = new lib.Shop();
				mc.rotation = rseed.range(0,15,true);
				addMC( mc, shop.cx*GRID + GRID*0.5, shop.cy*GRID + GRID*0.5 + GRID*0.7 );
			}
			
			// Réveil
			if( arrival!=null )
				addMC( new lib.Reveil(), arrival.cx*GRID + GRID*0.5, arrival.cy*GRID );
		}
		
		
		if( drawStep>=4 )
			ready = true;
			
		if( drawStep==0 )
			game.populateRoom(this);
		
		#if dev
		//trace( "step="+drawStep+" t="+(flash.Lib.getTimer()-t) );
		#end
		drawStep++;
	}
	
	public function getDuration() { // en secondes
		return  switch( kind ) {
			case Bedroom, Horizontal, ToUp, ToDown : 12.5;
			case VerticalUp, VerticalDown, FromUp, FromDown : 9.5;
		}
	}
	
	public function addMC(mc:flash.display.DisplayObject, x,y) {
		mc.x += x;
		mc.y += y;
		mcCont.addChild(mc);
	}
	
	public inline function getCol(x:Int,y:Int) {
		if( x<0 || x>=CWID || y<0 || y>=CHEI )
			return false;
		else
			return collisions[x][y];
	}
	
	
	public static inline function updateAll() {
		for( r in ATTACHED )
			if( r.update() )
				break;
	}
	
	public static inline function getByDist(distance:Int) {
		return ALL[distance];
	}
	
	public inline function update() {
		if( game.absoluteTime%10==0 && !ready ) {
			draw();
			return true;
		}
		else
			return false;
	}
}
