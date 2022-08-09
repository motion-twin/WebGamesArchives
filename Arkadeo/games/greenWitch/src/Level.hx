import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;

import mt.deepnight.Lib;
import mt.deepnight.Color;
import mt.deepnight.PathFinder;

import Const;

@:bitmap("assets/levels.png") class GfxLevels extends BitmapData {}

enum Renderer {
	R_Crypt1;
	R_Crypt2;
	R_House;
	R_CryptMetal;
	R_Orange1;
	R_Orange2;
	R_YellowDungeon;
	R_Forest1;
	R_Forest2;
	R_Forest3;
	R_Forest4;
	R_Test;
}

typedef FloorInfos = {
	var renderer	: Renderer;
	var wid			: Int;
	var hei			: Int;
	var mobs		: Array<{mclass:Class<en.Mob>, n:Int}>;
	var dispenser	: Array<DispenserEffect>;
	var heal		: Int;
}

typedef PropInfos = {
	var pixel		: Int;
	var key			: String;
	var weight		: Float;
}

typedef AssetInfos = {
	var pixel		: Int;
	var cwid		: Int;
	var chei		: Int;
	var source		: {x:Int, y:Int, w:Int, h:Int, random:Int};
	var offset		: {dx:Int, dy:Int};
	var frames		: Int;
	var allowSight	: Bool;
}

class Level {
	static var ASSET_LIB : IntHash<AssetInfos>;
	static var PROP_LIB : IntHash<PropInfos>;
	static var LEVELS : IntHash<Array<FloorInfos>>;
	static var __INIT = initXml();
	
	var game			: mode.Play;
	var lx				: Int;
	var ly				: Int;
	public var wid		: Int;
	public var hei		: Int;
	var pt0				: flash.geom.Point;
	var rseed			: mt.Rand;
	public var pathFinder: PathFinder;
	
	var source			: BitmapData;
	var rooms			: BitmapData;
	var reachables		: BitmapData;
	var meta			: Hash<Array<{cx:Int, cy:Int, data:Dynamic}>>;
	var used			: IntHash<Bool>;
	
	var renderer		: Renderer;
	var assets			: Array<{cx:Int, cy:Int, inf:AssetInfos}>;
	var wallMap			: Array<Array<Bool>>;
	public var ground	: Bitmap;
	public var walls	: Bitmap;
	#if debug
	public var colLayer	: Bitmap;
	#end
	public var gbd		: BitmapData;
	public var wbd		: BitmapData;
	
	var col				: Array<Array<Bool>>;
	var softCol			: Array<Array<Bool>>; // collisions ignorées par le PathFinder
	var allowSight		: Array<Array<Bool>>; // collisions qui ne bloquent pas la vue
	
	public function new(x,y, w,h) {
		game = mode.Play.ME;
		pt0 = new flash.geom.Point(0,0);
		lx = x;
		ly = y;
		wid = w;
		hei = h;
		meta = new Hash();
		used = new IntHash();
		assets = new Array();
		renderer = R_Crypt1;
		
		initSeed();
		
		pathFinder = new PathFinder(wid,hei);
		pathFinder.fillAll(false);
		
		ground = new Bitmap(null, flash.display.PixelSnapping.NEVER, false);
		game.sdm.add(ground, Const.DP_BG);
		walls = new Bitmap(null, flash.display.PixelSnapping.NEVER, false);
		game.sdm.add(walls, Const.DP_BG);
		#if debug
		colLayer = new Bitmap( new BitmapData(wid*Const.GRID, hei*Const.GRID, true, 0x0), flash.display.PixelSnapping.NEVER, false);
		colLayer.alpha = 0.5;
		game.sdm.add(colLayer, Const.DP_INTERF);
		#end
		
		rooms = new BitmapData(wid, hei, false, 0x0);
		reachables = new BitmapData(wid, hei, false, 0x0);
		
		col = new Array();
		softCol = new Array();
		allowSight = new Array();
		for(x in 0...wid) {
			col[x] = new Array();
			softCol[x] = new Array();
			allowSight[x] = new Array();
			for(y in 0...hei) {
				col[x][y] = false;
				softCol[x][y] = false;
				allowSight[x][y] = false;
			}
		}
		
		parseSource();
	}
	
	
	public static function createLeagueLevel() {
		var rseed = new mt.Rand(0);
		rseed.initSeed(api.AKApi.getSeed());
		var id = rseed.random(3);
		var l = new Level(id*32, 32, 32, 32);
		l.renderer = R_Crypt1;
		return l;
	}
	
	public static inline function countFloors(lid:Int) {
		return LEVELS.get(lid).length;
	}
	
	public static function isLastProgressionLevel(lid:Int, depth:Int) {
		return LEVELS.get(lid).length<=depth+1;
	}
	
	
	public static function createProgressionLevel(lid:Int, depth:Int) {
		var floor = getLevelInfos(lid, depth);
		
		var y = 128;
		for(i in 1...lid)
			y+=getLevelInfos(i, 0).hei;
		var l = new Level(floor.wid*depth, y, floor.wid, floor.hei);
		l.renderer = floor.renderer;
		
		return l;
	}
	
	public static inline function getLevelInfos(lid:Int, depth:Int) {
		if( !LEVELS.exists(lid) )
			throw "XML ERROR: unknown level "+lid;
		if( depth >= LEVELS.get(lid).length )
			throw "XML ERROR: unknown floor "+(depth+1)+" in level "+lid;
		return LEVELS.get(lid)[depth];
	}
	
	
	function parseSource() {
		var base = new GfxLevels(0,0);
		source = new BitmapData(wid, hei, false, 0xFFFFFF);
		source.lock();
		source.copyPixels(base, new flash.geom.Rectangle(lx, ly, wid, hei), pt0);
		#if !debug
		if( game.isLeague() )
			Lib.flipBitmap(source, rseed.random(2)==0, rseed.random(2)==0);
		#end
		
		wallMap = new Array();
		for(x in 0...wid)
			wallMap[x] = new Array();
			
		for(y in 0...hei)
			for(x in 0...wid) {
				var p = getSource(x,y);
				
				// Murs
				if( p==0xffffff ) {
					wallMap[x][y] = true;
					setCollisionInternal(x,y, true);
				}
				
				// Départ
				if( p==0x00FF00 )
					addMeta("start", x,y);
					
				// Sortie
				if( p==0x0000FF && getSource(x-1,y)!=0x0000FF && getSource(x,y-1)!=0x0000FF )
					addMeta("exit", x,y);
					
				// Porte horizontale
				if( p==0xFF0000 && getSource(x+1,y)==0xFF0000 )
					addMeta("doors", x,y, true);
					
				// Porte verticale
				if( p==0xFF0000 && getSource(x,y+1)==0xFF0000 )
					addMeta("doors", x,y, false);
				
				// Assets
				if( ASSET_LIB.exists(p) ) {
					var a = ASSET_LIB.get(p);
					assets.push({ cx:x, cy:y, inf:a });
					// Collisions des assets
					if( a.chei<0 )
						for(dx in 0...a.cwid)
							for(dy in a.chei+1...1) {
								setCollisionInternal(x+dx, y+dy);
								if( a.allowSight )
									allowSight[x+dx][y+dy] = true;
							}
					else
						for(dx in 0...a.cwid)
							for(dy in 0...a.chei) {
								setCollisionInternal(x+dx, y+dy);
								if( a.allowSight )
									allowSight[x+dx][y+dy] = true;
							}
				}
				
				// Props
				if( PROP_LIB.exists(p) )
					addMeta("props", x,y, PROP_LIB.get(p));
			}
			
		analyseRooms();
		
		// Après que les collisions soient définies
		for(y in 0...hei)
			for(x in 0...wid) {
				if( !canBeReached(x,y) || getCollision(x,y) )
					continue;
					
				// Place contre un mur
				if( isWall(x,y-1) && getCollision(x+1,y-1) && getCollision(x-1,y-1) )
					if( !getCollision(x-1,y) && !getCollision(x+1,y) )
						if( !getCollision(x,y+1) && !getCollision(x-1,y+1) && !getCollision(x+1,y+1) )
							addMeta("onWall", x,y);
					
				// Loin des murs
				if( !getCollision(x-1,y) && !getCollision(x+1,y) && !getCollision(x,y-1) && !getCollision(x,y+1) ) {
					addMeta("middle", x,y);
					addMeta("middle_"+getRoomId(x, y), x, y);
				}
					
				// Spot libre
				addMeta("spot", x,y);
				addMeta("room_"+getRoomId(x, y), x, y);
			}
					
		source.unlock();
	}
	
	
	public function debugMeta(k:String) {
		#if debug
		var all = getAllMetaPoints(k);
		for(pt in all) {
			var tf = game.createField("[x]", 0x00FF00);
			tf.x = pt.cx*Const.GRID;
			tf.y = pt.cy*Const.GRID;
			walls.bitmapData.draw(tf, tf.transform.matrix);
		}
		#end
	}
	
	
	static function parseXmlCounters(str:String) {
		var r : Array<{k:String, n:Int}> = new Array();
		var list = str.split(",");
		for(e in list)
			try {
				if( e.indexOf("(")<0 ) {
					if( StringTools.trim(e).length==0 )
						throw "";
					r.push({k:StringTools.trim(e).toLowerCase(), n:1});
				}
				else {
					e = StringTools.replace(e, ")", "");
					if( Std.parseInt(e.split("(")[1])==null )
						throw "";
					r.push({ k : StringTools.trim(e.split("(")[0]).toLowerCase(), n : Std.parseInt(e.split("(")[1]) });
				}
			}
			catch(e:Dynamic) {
				throw "invalid string \""+str+"\"";
			}
		return r;
	}
	
	static function initXml() {
		var doc = try { new haxe.xml.Fast( Xml.parse( haxe.Resource.getString("levelInfos") ) ); } catch(e:Dynamic) { throw "malformed XML"; };
		
		// Levels
		LEVELS = new IntHash();
		
		try {
			for( node in doc.node.levels.nodes.l ) {
				var id = Std.parseInt(node.att.id);
				LEVELS.set(id, []);
				for( floor in node.nodes.floor ) {
					var data : FloorInfos = {
						renderer	: null,
						wid			: Std.parseInt( node.att.size.split(",")[0] ),
						hei			: Std.parseInt( node.att.size.split(",")[1] ),
						heal		: -1,
						mobs		: [],
						dispenser	: [],
					}
					data.renderer = switch( StringTools.trim(floor.att.render.toLowerCase()) ) {
						case "crypt1" : Renderer.R_Crypt1;
						case "crypt2" : Renderer.R_Crypt2;
						case "house" : Renderer.R_House;
						case "cryptmetal" : Renderer.R_CryptMetal;
						case "orange1" : Renderer.R_Orange1;
						case "orange2" : Renderer.R_Orange2;
						case "bordeaux" : Renderer.R_YellowDungeon;
						case "forest1" : Renderer.R_Forest1;
						case "forest2" : Renderer.R_Forest2;
						case "forest3" : Renderer.R_Forest3;
						case "forest4" : Renderer.R_Forest4;
						case "test" : Renderer.R_Test;
						default : throw "unknown render "+floor.att.render+" on level "+id;
					};
					if( floor.has.heal )
						data.heal = Std.parseInt( floor.att.heal );
					
					if( floor.has.mobs )
						for(m in parseXmlCounters(floor.att.mobs))
							switch(m.k) {
								case "hor" : data.mobs.push({n:m.n, mclass:en.mob.Horde});
								case "bat" : data.mobs.push({n:m.n, mclass:en.mob.Bat});
								case "big" : data.mobs.push({n:m.n, mclass:en.mob.Bleuarg});
								case "bom" : data.mobs.push({n:m.n, mclass:en.mob.Bomber});
								case "can" : data.mobs.push({n:m.n, mclass:en.mob.FireCannon});
								case "gho" : data.mobs.push({n:m.n, mclass:en.mob.Ghost});
								case "kam" : data.mobs.push({n:m.n, mclass:en.mob.Kamikaze});
								case "key" : data.mobs.push({n:m.n, mclass:en.mob.Unlocker});
								case "rab" : data.mobs.push({n:m.n, mclass:en.mob.Rabbit});
								default : throw "unknown mob \""+m.k+"\" in level "+id;
							}
					if( floor.has.dispenser )
						for(d in parseXmlCounters(floor.att.dispenser))
							for(i in 0...d.n)
								switch(d.k) {
									case "gat" : data.dispenser.push( D_GiveTurret(T_Gatling) );
									case "slo" : data.dispenser.push( D_GiveTurret(T_Slow) );
									case "bur" : data.dispenser.push( D_GiveTurret(T_Burner) );
									case "shi" : data.dispenser.push( D_GiveTurret(T_Shield) );
									case "bas" : data.dispenser.push( D_GiveWeapon(W_Basic) );
									case "laz" : data.dispenser.push( D_GiveWeapon(W_Lazer) );
									case "lig" : data.dispenser.push( D_GiveWeapon(W_Lightning) );
									case "gre" : data.dispenser.push( D_GiveWeapon(W_Grenade) );
									default : throw "unknown dispenser \""+d.k+"\" in level "+id;
								}
					LEVELS.get(id).push(data);
				}
				
			}
			
			// Assets
			PROP_LIB = new IntHash();
			ASSET_LIB = new IntHash();
			for( node in doc.node.assets.nodes.a ) {
				if( node.has.prop ) {
					// Prop
					var data : PropInfos = {
						pixel		: Std.parseInt("0x"+node.att.c),
						key			: node.att.prop,
						weight		: Std.parseFloat(node.att.weight),
					}
					PROP_LIB.set(data.pixel, data);
				}
				else {
					// Asset
					var data : AssetInfos = {
						pixel	: Std.parseInt("0x"+node.att.c),
						cwid	: 0,
						chei	: 0,
						source	: {x:0, y:0, w:0, h:0, random:1},
						offset	: {dx:0, dy:0},
						frames	: Std.parseInt(node.att.frames),
						allowSight	: node.has.allowSight && node.att.allowSight!="0",
					}
					data.cwid = Std.parseInt( node.att.collision.split(",")[0] );
					data.chei = Std.parseInt( node.att.collision.split(",")[1] );
					data.source.x = Std.parseInt( node.att.sourcePos.split(",")[0] );
					data.source.y = Std.parseInt( node.att.sourcePos.split(",")[1] );
					data.source.w = Std.parseInt( node.att.sourceSize.split(",")[0] );
					data.source.h = Std.parseInt( node.att.sourceSize.split(",")[1] );
					if( node.has.sourceRandom )
						data.source.random = Std.parseInt( node.att.sourceRandom );
					data.offset.dx = Std.parseInt( node.att.sourceOffset.split(",")[0] );
					data.offset.dy = Std.parseInt( node.att.sourceOffset.split(",")[1] );
					ASSET_LIB.set(data.pixel, data);
				}
			}
		}
		catch(e:Dynamic) {
			throw "[XML ERROR] "+e;
		}
		
		return true;
	}
	
	
	#if debug
	public static function estimateXp() {
		trace("-XP--------------------");
		var atotal = 0;
		var total = 0;
		var level = 0;
		for(l in 1...21) {
			var xp = 0;
			var d = 0;
			while( !isLastProgressionLevel(l,d-1) ) {
				var inf = getLevelInfos(l, d);
				for( m in inf.mobs ) {
					var e = Type.createInstance(m.mclass, [0,0]);
					xp+=e.getXpValue() * m.n;
					e.destroy();
				}
				d++;
			}
			atotal+=xp;
			total+=xp;
			while( total>en.Hero.getNextLevelXp(level) ) {
				total-=en.Hero.getNextLevelXp(level);
				level++;
			}
			trace("Level "+l+": "+xp+" ("+(level+1)+")");
		}
		trace("TOTAL: "+atotal);
		trace("HERO LEVEL "+(level+1));
	}
	#end
	
	
	
	function analyseRooms() {
		//rooms.copyPixels(source, source.rect, pt0);
		rooms.threshold(source, source.rect, pt0, "==", 0xFFff0000, 0xFFffffff, 0xFFffffff); // rouge -> blanc
		rooms.threshold(rooms, rooms.rect, pt0, "!=", 0xFFffffff, 0xFF000000, 0xFFffffff); // le reste -> poubelle

		// On complète avec les collisions (d'assets notamment)
		for( x in 0...wid )
			for( y in 0...hei )
				if( getCollision(x,y) ) {
					rooms.setPixel32(x,y, 0xffFFFFFF);
					reachables.setPixel32(x,y, 0xffFFFFFF);
				}
		
		for( pt in getAllMetaPoints("start") )
			reachables.floodFill(pt.cx, pt.cy, 0xFF0000);
		
		var roomId = 1;
		var r = rooms.getColorBoundsRect(0xFFffffff, 0xFF000000);
		var x = Std.int(r.x);
		var y = Std.int(r.y);
		while( r.width!=0 )
			if( rooms.getPixel(x,y)==0x0 ) {
				rooms.floodFill(x,y, Color.rgbaToInt({r:0, g:roomId, b:0, a:255}));
				r = rooms.getColorBoundsRect(0xFFffffff, 0xFF000000);
				x = Std.int(r.x);
				y = Std.int(r.y);
				roomId++;
			}
			else {
				x++;
				if( x>=rooms.width ) {
					x = 0;
					y++;
				}
			}
		
		for(x in 1...rooms.width-1)
			for(y in 1...rooms.height-1) {
				if( source.getPixel(x,y)==0xFF0000 ) {
					var roomId = getRoomId(x-1,y);
					if( roomId==-1 )
						roomId = getRoomId(x,y-1);
					if( roomId==-1 )
						trace("WARNING : invalid roomId at "+x+","+y);
					rooms.setPixel(x,y, Color.rgbaToInt({r:0, g:roomId+1, b:0, a:255}));
				}
			}
			
			
		#if debug
		var rdebug = rooms.clone();
		for(x in 0...rooms.width)
			for(y in 0...rooms.height) {
				var r = getRoomId(x,y);
				rdebug.setPixel(x,y, r<0 ? 0xFFFFFF : Color.randomColor(r*0.1, 1, 0.7));
			}
		var bmp = new Bitmap(rdebug);
		game.root.addChild(bmp);
		bmp.scaleX = bmp.scaleY = 2;
		bmp.y = Const.HEI-bmp.height;
		bmp.alpha = 0.9;
		
		var bmp2 = new Bitmap(reachables);
		game.root.addChild(bmp2);
		bmp2.scaleX = bmp2.scaleY = 2;
		bmp2.x = bmp.x+bmp.width+3;
		bmp2.y = Const.HEI-bmp2.height;
		bmp2.alpha = 0.5;
		#end
	}
	
	
	public inline function canBeReached(cx,cy) {
		return !getCollision(cx,cy) && reachables.getPixel(cx,cy)==0xFF0000;
		//if( getCollision(cx,cy) )
			//return false;
		//else
			//return en.Door.getDoors( getRoomId(cx,cy) ).length > 0;
	}
	
	public inline function getRoomId(cx,cy) {
		var id = Color.intToRgb(rooms.getPixel(cx,cy)).g-1;
		return id>=0 && id<128 ? id : -1;
	}
	
	inline function getSource(x,y) {
		return x<0 || x>=source.width || y<0 || y>=source.height ? 0xffffff : source.getPixel(x,y);
	}
	
	
	public function destroy() {
		ground.bitmapData.dispose();
		ground.parent.removeChild(ground);
		walls.bitmapData.dispose();
		walls.parent.removeChild(walls);
		source.dispose();
		rooms.dispose();
		reachables.dispose();
	}
	
	inline function setUsed(cx,cy, ?b=true) {
		used.set(cx+cy*hei, b);
	}
	inline function isUsed(cx,cy) {
		return used.get(cx+cy*hei)==true || getCollision(cx,cy);
	}
	
	public inline function addMeta(k, cx, cy, ?d:Dynamic) {
		if( meta.exists(k) )
			meta.get(k).push({cx:cx, cy:cy, data:d});
		else
			meta.set( k, [{cx:cx, cy:cy, data:d}] );
	}
	
	public inline function getAllMetaPoints(k) {
		return meta.exists(k) ? meta.get(k) : new Array();
	}
	
	public inline function setUsedZone(cx,cy, radiusWid, radiusHei) {
		for(x in cx-radiusWid...cx+radiusWid+1)
			for(y in cy-radiusHei...cy+radiusHei+1)
				setUsed(x,y);
	}
	
	public function getRoomSize(rid:Int) {
		return getAllMetaPoints("room_"+rid).length;
	}
	
	public function getSpotsInRoom(rid:Int) {
		return getAllMetaPoints("room_"+rid);
	}
	
	public function getSpotInRoom(rid:Int, cx:Int, cy:Int, minDist:Int, maxDist:Int, rs:mt.Rand) {
		var m = getAllMetaPoints("room_"+rid);
		if( m.length==0 ) {
			trace("FAILED in room "+rid);
			return null;
		}
		while( minDist>=0 ) {
			var tries = 50;
			while( tries-->0 ) {
				var pt = m[rs.random(m.length)];
				if( !getCollision(pt.cx, pt.cy) && Lib.distance(cx,cy, pt.cx, pt.cy)>=minDist && Lib.distance(cx,cy, pt.cx, pt.cy)<maxDist )
					return pt;
			}
			minDist--;
		}
		return null;
	}
	
	public inline function getMetaOnce(k, rs:mt.Rand) {
		var m = getAllMetaPoints(k);
		if( m.length==0 )
			return null;
		else {
			var pt = m[rs.random(m.length)];
			while( isUsed(pt.cx, pt.cy) )
				pt = m[rs.random(m.length)];
			setUsed(pt.cx, pt.cy);
			return pt;
		}
	}
	
	public inline function getMeta(k, rs:mt.Rand) {
		var m = getAllMetaPoints(k);
		if( m.length==0 )
			return null;
		else
			return m[rs.random(m.length)];
	}
	
	public inline function getMetaOnceFarFromOthers(k, rs:mt.Rand, others:Array<Entity>) {
		var meta = getAllMetaPoints(k).copy();
		var i = 0;
		while( i<meta.length )
			if( isUsed(meta[i].cx, meta[i].cy) )
				meta.splice(i,1);
			else
				i++;
		
		if( meta.length==0 )
			return null;
		else {
			var minDistCase = 10;
			var tooClose = false;
			var pt : {cx:Int, cy:Int};
			var meta2 = meta.copy();
			do {
				pt = meta2.splice(rs.random(meta2.length), 1)[0];
					
				tooClose = false;
				for(e in others)
					if( Lib.distance(pt.cx, pt.cy, e.cx, e.cy)<=minDistCase ) {
						tooClose = true;
						break;
					}
				if( meta2.length==0 ) {
					minDistCase--;
					meta2 = meta.copy();
				}
			} while( tooClose && minDistCase>0 );
			setUsed(pt.cx, pt.cy);
			return pt;
		}
	}
	
	public function addCollision(x,y) {
		setCollisionInternal(x,y, true);
		for(k in meta.keys())
			if( k=="onWall" || k=="spot" || k.indexOf("middle")==0 || k.indexOf("room")==0 )
				meta.set( k, Lambda.array(Lambda.filter(meta.get(k), function(pt) return canBeReached(pt.cx, pt.cy) )) );
	}
	
	inline function setCollisionInternal(x,y, ?b=true) {
		if( x>=0 && x<wid && y>=0 && y<hei ) {
			col[x][y] = b;
			pathFinder.setCollision(x,y, b);
		}
	}
	
	public function setSoftCollision(x,y, ?b=true) {
		softCol[x][y] = b;
	}
	
	public inline function getSpotOnce(?rs:mt.Rand) {
		if( rs==null )
			rs = rseed;
			
		return getMetaOnce("spot", rseed);
	}
	
	public function getFarSpot(?rs:mt.Rand, cx,cy, ?minDist=15, ?maxDist=99) {
		if( rs==null )
			rs = rseed;
			
		var spots = getAllMetaPoints("spot");
		while( minDist>=0 ) {
			for(tries in 0...50) {
				var pt = spots[rs.random(spots.length)];
				var d = mt.deepnight.Lib.distance(pt.cx, pt.cy, cx, cy);
				if( d>=minDist && d<=maxDist )
					return pt;
			}
			minDist--;
		}
		return null;
	}
	
	public inline function initSeed(?n=0) {
		rseed = new mt.Rand(0);
		rseed.initSeed(game.seed + n*42);
	}
	
	public inline function getCollision(x,y) {
		return
			if(x<0 || x>=wid || y<0 || y>=hei)
				true;
			else
				col[x][y]==true || softCol[x][y]==true;
	}
	
	
	public inline function getSightCollision(x,y) {
		return
			if(x<0 || x>=wid || y<0 || y>=hei)
				true;
			else
				(col[x][y]==true || softCol[x][y]==true) && !allowSight[x][y];
	}
	
	public inline function getHardCollision(x,y) {
		return
			if(x<0 || x>=wid || y<0 || y>=hei)
				true;
			else
				col[x][y]==true;
	}
	
	inline function isWall(cx,cy) {
		return wallMap[cx][cy]==true;
	}
	
	
	public function draw() {
		if( gbd!=null ) {
			gbd.dispose();
			wbd.dispose();
		}
		initSeed();
		var w = wid*Const.GRID;
		var h = hei*Const.GRID;
		wbd = new BitmapData(w,h, true, 0x212549);
		gbd = new BitmapData(w,h, true, 0x212549);
		ground.bitmapData = gbd;
		walls.bitmapData = wbd;
		wbd.lock();
		gbd.lock();
		
		var groundId = "";
		var bottomWallId = "";
		var topWallId = "";
		switch( renderer ) {
			case R_Crypt1 :
				topWallId = "topWall_1";
				bottomWallId = "bottomWall_1";
				groundId = "ground_1";
			case R_Crypt2 :
				topWallId = "topWall_1";
				bottomWallId = "bottomWall_1";
				groundId = "ground_4";
			case R_House :
				topWallId = "topWall_4";
				bottomWallId = "bottomWall_5";
				groundId = "ground_4";
			case R_CryptMetal :
				topWallId = "topWall_1";
				bottomWallId = "bottomWall_6";
				groundId = "ground_3";
			case R_Orange1 :
				topWallId = "topWall_2";
				bottomWallId = "bottomWall_2";
				groundId = "ground_2";
			case R_Orange2 :
				topWallId = "topWall_2";
				bottomWallId = "bottomWall_2";
				groundId = "ground_4";
			case R_YellowDungeon :
				topWallId = "topWall_4";
				bottomWallId = "bottomWall_4";
				groundId = "ground_4";
			case R_Forest1 :
				topWallId = "topWall_3";
				bottomWallId = "bottomWall_3";
				groundId = "ground_3";
			case R_Forest2 :
				topWallId = "topWall_2";
				bottomWallId = "bottomWall_2";
				groundId = "ground_3";
			case R_Forest3 :
				topWallId = "topWall_4";
				bottomWallId = "bottomWall_4";
				groundId = "ground_3";
			case R_Forest4 :
				topWallId = "topWall_3";
				bottomWallId = "bottomWall_5";
				groundId = "ground_3";
			case R_Test :
				topWallId = "topWall_1";
				bottomWallId = "bottomWall_1";
				groundId = "ground_4";
		}
		
		// Tranche des murs
		var edge = new Sprite();
		edge.graphics.beginFill(0x0,0.6);
		edge.graphics.drawRect(-1,-20,1,40);
		edge.graphics.beginFill(0xffffff,0.4);
		edge.graphics.drawRect(0,-20,1,40);
		
		for(cx in 0...wid)
			for(cy in 0...hei) {
				var x = cx*Const.GRID;
				var y = cy*Const.GRID;
				// Sol
				if( !isWall(cx,cy) )
					game.tiles.drawIntoBitmap(gbd, x,y, groundId, game.tiles.getRandomFrame(groundId, rseed.random));
				
				// Murs
				if( isWall(cx,cy) && !isWall(cx,cy+1) ) {
					game.tiles.drawIntoBitmap(wbd, x,y, bottomWallId, game.tiles.getRandomFrame(bottomWallId, rseed.random));
					if( cx>0 && !isWall(cx-1,cy) ) {
						edge.x = x;
						edge.y = y;
						edge.scaleX = 1;
						wbd.draw(edge, edge.transform.matrix, BlendMode.OVERLAY);
					}
					if( cx<wid-1 && !isWall(cx+1,cy) ) {
						edge.x = x+Const.GRID;
						edge.y = y;
						edge.scaleX = -1;
						wbd.draw(edge, edge.transform.matrix, BlendMode.OVERLAY);
					}
				}
				if( isWall(cx,cy) && isWall(cx,cy+1) && !isWall(cx,cy+2) )
					game.tiles.drawIntoBitmap(wbd, x,y, topWallId, game.tiles.getRandomFrame(topWallId, rseed.random));
			}
		
		// Epaisseur murs
		var gaps = gbd.clone();
		gaps.copyPixels(wbd, wbd.rect, pt0, true);
		var m = [
			1, 0, 0, 0, 0,
			0, 1, 0, 0, 0,
			0, 0, 1, 0, 0,
			0, 0, 0, -1, 0xff
		];
		gaps.applyFilter(gaps, gaps.rect, pt0, new flash.filters.ColorMatrixFilter(m)); // inversion alpha
		var c = switch( renderer ) {
			case R_Crypt1, R_Crypt2, R_CryptMetal : 0x1B3243;
			case R_Orange1, R_Orange2, R_Forest2 : 0x53211C;
			case R_Forest1, R_Forest4 : 0x312D53;
			case R_YellowDungeon, R_House, R_Forest3 : 0x553b31;
			case R_Test : 0x1B3243;
		}
		var w = 5;
		gaps.applyFilter( gaps, gaps.rect, pt0, new flash.filters.GlowFilter(c, 0.5, 24,24, 4, 1,true) );
		gaps.applyFilter( gaps, gaps.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(c, 0.02), 1, w+1,w+1, 50, 1, true) );
		gaps.applyFilter( gaps, gaps.rect, pt0, new flash.filters.GlowFilter(c, 1, w,w, 50, 1,true) );
		gaps.applyFilter( gaps, gaps.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(c, 0.1), 1, 2,2, 50, 1,true) );
		gaps.applyFilter( gaps, gaps.rect, pt0, new flash.filters.GlowFilter(0x0, 0.6, 2,2, 50) );
		
		var perlin = new BitmapData(gbd.width, gbd.height, true, 0x0);
		switch( renderer ) {
			case R_Crypt1, R_Orange1, R_YellowDungeon, R_Test, R_Orange2 :
				// Fissures sol
				perlin.perlinNoise(64,64,4, game.seed, false, true, true);
				perlin.threshold(perlin, perlin.rect, pt0, ">", Color.addAlphaF(0x5D5D5D), 0x0, 0xFFffffff);
				perlin.threshold(perlin, perlin.rect, pt0, ">", Color.addAlphaF(0), Color.addAlphaF(0x808080), 0xFFffffff);
				perlin.applyFilter(perlin, perlin.rect, pt0, new flash.filters.DropShadowFilter(1,-90, 0xA3A3A3,1, 0,0,1));
				perlin.applyFilter(perlin, perlin.rect, pt0, new flash.filters.DropShadowFilter(1,-90, 0x5C5C5C,1, 0,0,1));
				perlin.applyFilter(perlin, perlin.rect, pt0, new flash.filters.DropShadowFilter(1,90, 0x494949,1, 0,0,1));
				perlin.applyFilter(perlin, perlin.rect, pt0, new flash.filters.DropShadowFilter(1,90, 0xA3A3A3,1, 0,0,1));
				gbd.draw(perlin, BlendMode.OVERLAY);
				
			case R_House :
				// Fissures sol épaisses
				perlin.perlinNoise(64,64,4, game.seed, false, true, true);
				perlin.threshold(perlin, perlin.rect, pt0, ">", Color.addAlphaF(0x5D5D5D), 0x0, 0xFFffffff);
				perlin.threshold(perlin, perlin.rect, pt0, ">", Color.addAlphaF(0), Color.addAlphaF(0x808080), 0xFFffffff);
				perlin.applyFilter(perlin, perlin.rect, pt0, new flash.filters.DropShadowFilter(1,-90, 0xA3A3A3,1, 0,0,1));
				perlin.applyFilter(perlin, perlin.rect, pt0, new flash.filters.DropShadowFilter(1,-90, 0x5C5C5C,1, 0,0,1));
				perlin.applyFilter(perlin, perlin.rect, pt0, new flash.filters.DropShadowFilter(2,90, 0x4E4E4E,1, 0,0,1));
				perlin.applyFilter(perlin, perlin.rect, pt0, new flash.filters.DropShadowFilter(1,90, 0xA3A3A3,1, 0,0,1));
				gbd.draw(perlin, BlendMode.OVERLAY);
				
			case R_Forest1, R_Forest2, R_Forest3, R_Forest4, R_Crypt2, R_CryptMetal :
				var tex = game.tiles.getBitmapData("grass");
				var col = switch( renderer ) {
					case R_Forest2 : 0x574A22;
					case R_CryptMetal : 0x466055;
					default : 0x307460;
				}
				tex.applyFilter(tex, tex.rect, pt0, Color.getColorizeMatrixFilter(col, 1,0));

				// Plantes grimpantes
				var oldAlpha = wbd.clone();
				perlin.perlinNoise(32,8,2, game.seed+2, false, true, true);
				perlin.threshold(perlin, perlin.rect, pt0, ">", Color.addAlphaF(0x7A7A7A), 0x0);
				perlin.threshold(perlin, perlin.rect, pt0, ">", Color.addAlphaF(0), Color.addAlphaF(0x808080, 0.8));
				perlin.applyFilter(perlin, perlin.rect, pt0, new flash.filters.BlurFilter(4,4,2));
				var t = Lib.createTexture(tex, gbd.width, gbd.height, false);
				t.applyFilter(t, t.rect, pt0, new flash.filters.DropShadowFilter(2, 90, 0x0,0.7, 2,2));
				wbd.copyPixels( t, t.rect, pt0, perlin, true);
				wbd.copyChannel(oldAlpha, oldAlpha.rect, pt0, 8,8);
				
				// Herbe
				oldAlpha.copyPixels(gbd, gbd.rect, pt0);
				perlin.perlinNoise(90,128,3, game.seed, false, true, true);
				perlin.threshold(perlin, perlin.rect, pt0, ">", Color.addAlphaF(0x7A7A7A), 0x0);
				perlin.threshold(perlin, perlin.rect, pt0, ">", Color.addAlphaF(0), Color.addAlphaF(0x808080, 0.8));
				perlin.applyFilter(perlin, perlin.rect, pt0, new flash.filters.BlurFilter(32,32,2));
				var t = Lib.createTexture(tex, gbd.width, gbd.height, false);
				t.applyFilter(t, t.rect, pt0, new flash.filters.DropShadowFilter(2, 90, 0x1B254B,0.9, 2,2));
				t.applyFilter(t, t.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(col, -0.2),0.7, 32,32,2, 2));
				gbd.copyPixels( t, t.rect, pt0, perlin, true);
				gbd.copyChannel(oldAlpha, oldAlpha.rect, pt0, 8,8);
				
				tex.dispose();
				oldAlpha.dispose();
		}
		perlin.dispose();
		
		// Texture de l'épaisseur des murs
		var tex = Lib.createTexture(game.tiles.getBitmapData("wallTexture"), gaps.width, gaps.height, true);
		var g2 = gaps.clone();
		g2.draw(tex, new flash.geom.ColorTransform(1,1,1, 0.7), BlendMode.OVERLAY);
		gaps.copyPixels(g2, g2.rect, pt0, gaps);
		wbd.copyPixels(gaps, gaps.rect, pt0, true);
		gaps.dispose();
		
		// Ombres au sol
		gbd.applyFilter( gbd, gbd.rect, pt0, new flash.filters.DropShadowFilter(10,20, 0x0,0.4, 16,8,1, 1,true) );
		gbd.applyFilter( gbd, gbd.rect, pt0, new flash.filters.GlowFilter(0x0,0.4, 32,32,1, 1,true) );
		
		// Ombres murs (tranches)
		wbd.applyFilter( wbd, wbd.rect, pt0, new flash.filters.DropShadowFilter(6,-20, 0x0,0.3, 16,32,1, 1,true) );
		wbd.applyFilter( wbd, wbd.rect, pt0, new flash.filters.DropShadowFilter(6,160, 0x0,0.3, 16,32,1, 1,true) );

		// Draw des assets
		var tileSet = game.tiles.source;
		for( a in assets ) {
			var f = rseed.random(a.inf.frames);
			var dx = a.inf.source.random<=1 ? 0 : rseed.random(a.inf.source.random)*a.inf.source.w;
			wbd.copyPixels(
				tileSet,
				new flash.geom.Rectangle(a.inf.source.x + f*a.inf.source.w + dx, a.inf.source.y, a.inf.source.w, a.inf.source.h),
				new flash.geom.Point(a.cx*Const.GRID+a.inf.offset.dx, a.cy*Const.GRID+a.inf.offset.dy),
				true
			);
		}
		
		// Fleurs
		if( renderer==R_Forest1 || renderer==R_Forest2 ) {
			var spots = getAllMetaPoints("spot").copy();
			var i = 0.03 * wid*hei;
			while( i>0 && spots.length>0 ) {
				var pt = spots.splice(rseed.random(spots.length), 1)[0];
				var s = game.tiles.getRandom("blueFlower", rseed.random);
				s.x = pt.cx*Const.GRID;
				s.y = pt.cy*Const.GRID;
				ground.bitmapData.draw( s, s.transform.matrix );
				i--;
			}
		}
		
		// Gravas
		var dirts = [];
		var color = switch( renderer ) {
			case R_Forest1 : 0x394F6F;
			case R_Forest2 : 0x7A3F16;
			case R_Forest4 : 0x7A3F16;
			case R_Crypt1, R_CryptMetal : 0x04636A;
			case R_Orange1 : 0x7A3F16;
			case R_YellowDungeon, R_Forest3, R_Orange2, R_House : 0x815525;
			case R_Crypt2 : 0xD9CFB9;
			case R_Test : 0x0;
		}
		if( color!=0 ) {
			var teint = Color.getColorizeMatrixFilter(color, 1, 0);
			for(f in 0...game.tiles.countFrames("dirt")) {
				var bd = game.tiles.getBitmapData("dirt", f);
				bd.applyFilter(bd, bd.rect, pt0, teint);
				bd.colorTransform( bd.rect, new flash.geom.ColorTransform(1,1,1, 0.85) );
				dirts.push(bd);
			}
			var spots = getAllMetaPoints("spot").copy();
			var i = 0.08 * wid*hei;
			while( i>0 && spots.length>0 ) {
				var pt = spots.splice(rseed.random(spots.length), 1)[0];
				var f = rseed.random(dirts.length);
				var pt = new flash.geom.Point(pt.cx*Const.GRID, pt.cy*Const.GRID);
				ground.bitmapData.copyPixels(dirts[f], dirts[f].rect, pt, true);
				i--;
			}
		}
		
		//var teint = 0x824B0F;
		//var teint = Color.randomColor(rseed.rand(), 0.3, 0.4);
		//gbd.applyFilter(gbd, gbd.rect, pt0, Color.getColorizeMatrixFilter(teint, 1, 0));
		//var teint = Color.randomColor(rseed.rand(), 0.4, 0.6);
		//wbd.applyFilter(wbd, wbd.rect, pt0, Color.getColorizeMatrixFilter(teint, 0.3, 0.7));
		
		#if debug
		colLayer.bitmapData.lock();
		for(x in 0...wid)
			for(y in 0...hei)
				if( getHardCollision(x,y) )
					colLayer.bitmapData.fillRect( new flash.geom.Rectangle(x*Const.GRID, y*Const.GRID, Const.GRID, Const.GRID), 0xffFF0000 );
				else if( getCollision(x,y) )
					colLayer.bitmapData.fillRect( new flash.geom.Rectangle(x*Const.GRID, y*Const.GRID, Const.GRID, Const.GRID), 0xffFFFF00 );
		colLayer.bitmapData.unlock();
		#end
		
		ground.bitmapData.unlock();
		walls.bitmapData.unlock();

		initSeed();
		
		//debugMeta("spot");
	}
}
