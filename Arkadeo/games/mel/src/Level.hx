using mt.gx.Ex;

import api.AKApi;
import ark.gfx.InGamePK;
import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.geom.ColorTransform;
import fx.SMS;
import haxe.Public;
import haxe.Timer;
import mt.DepthManager;
import mt.fx.Blink;
import mt.gx.Debug;
import mt.Rand;

import mt.fx.Flash;
import mt.fx.Fx;

import mt.gx.Pair;
import mt.gx.Pool;
import mt.gx.MathEx;

import VScroller;
import DefaultImport;
import Lib.Prof;

using mt.gx.Ex;

import Char;

import haxe.EnumFlags;
import api.AKProtocol;


class LevelSprite extends Sprite, implements haxe.Public
{
	var coll : Bool;
	
	var cw : Int;
	var ch: Int;
	var px : Int;
	var py : Int;
	
	var pageKey : Int;
	var cooKey : Int;
	
	public var game(get, null) : Game; function get_game() return Game.me
	
	function new(px,py,cw,ch,key)
	{
		super();
		
		coll = true;
		
		this.cw = cw;
		this.cw = cw;
		this.ch = ch;
		this.px = px;
		this.py = py;
		
		x = Std.int( Lib.cw * px);
		y = Std.int( Lib.ch * py);
		
		cooKey = game.level.makeKey( px, py);
		pageKey = key;
		addToCol();
	}
	
	function addToCol()
	{
		var lev = lev();
		for ( kcx in 0...cw)
			for( kcy in 0...ch)
				lev.setWall( px + kcx, py + kcy , this );
	}
	
	function finalize()
	{
		detach();
	}
	
	function remFromCol()
	{
		var lev = lev();
		for ( kcx in 0...cw)
			for ( kcy in 0...ch)
			{
				var p = lev.getWall( px + kcx, py + kcy);
				if( p == this)
					lev.setWall( px + kcx, py + kcy , null );
				//else
				//	throw "assert";
			}
	}
	
	function lev()	return game.level
	
	function setPos( px,py)
	{
		remFromCol();
		this.px = px;
		this.py = py;
		x = Std.int( Lib.cw * px);
		y = Std.int( Lib.ch * py);
		addToCol();
	}
}

class Crossing extends LevelSprite
{
	public function new(px,py,cw,ch,key, prop = true)
	{
		super(px,py,cw,ch,key);
		
		if ( ch > 1 )
			throw "assert";
			
		var l = lev();
		var s = new mt.Rand( (px * py + Game.getSeed()) ^ ( 54354 * ch + 1337 * cw));
		var p = 
		(Game.isLeague() || Data.LD[Game.getLevel()].platforms == null )
		?l.data.platforms.random(s)
		:l.data.platforms.get(Data.LD[Game.getLevel()].platforms);
		
		var c = p.corner.random(s);
		var m = new flash.geom.Matrix();
		m.scale( -1, 1);
		
		var curX = 0.;
		for ( x in 0...cw)
		{
			var t =  null;
			
			if ( cw == 1)
			{
				t = p.mid.random(s);
			}
			else
			{
				if ( x == 0) 				t = c;
				else if ( x == cw - 1)		t = c;
				else						t = p.mid.random(s);
			}
			
			//graphics.moveTo( curX, 0);
			var v = 16;
			graphics.beginBitmapFill( t.bmp.bitmapData, (x == cw - 1) || (x!=0&&s.random(2)==0)?m:null);
			graphics.drawRect(curX, 0, v, t.bmp.bitmapData.height);
			graphics.endFill();
			curX += v;
		}
		
		if ( s.random(10)==0 && prop)
		{
			var b =  new Bitmap( l.data.props.random(s).bitmapData );
			addChild( b );
			b.y -= b.height;
			b.x = s.random(Std.int(cw * Lib.cw - b.width));
			b.scaleX = ( s.random(10) < 5 ) ? 1 : -1;
		}
		
		var g = new flash.filters.GlowFilter();
		g.blurX = 1.5;
		g.blurY = 1.5;
		g.color = 0;
		filters = [g];
		cacheAsBitmap = true;
		
	}
	
}


typedef PageContent = 
{
	addSprites : List<Sprite>
}

typedef PoweredClip = 
{
	> Bitmap,
	pow : CharPowers,
}

class PageItems implements Public
{
	var dl : List<Entity>;
	
	var bonus : List<Bonus>;
	var kdo : List<{ pfKey:Int,kd:KdoDef,ent:Kdo}>;
	
	function new ()
	{
		bonus = new List();
		dl = new List();
		kdo = new List();
	}
	
	function mk()
	{
		for ( d in kdo) dl.push( d.ent );
		for ( d in bonus) dl.push( d );
	}
	
	
}

class Level
{
	var sideDropsSrc : gfx.Plan1;
	public var sideDrops : IntHash<Array<Bitmap>>;
	
	public var bg : Array < Pair< Bitmap, Bitmap> >;
	var char : Char;
	public var dm  : mt.DepthManager;
	var root  : Sprite;
	public inline function getRoot() return root
	var pages : mt.gx.BitArray;
	public var pagesData : IntHash<PageItems>;
	
	public static inline var SIDE_DEPTH = 0;
	public static inline var PRE_SWARM_DEPTH = 10;
	public static inline var DANGER_DEPTH = 20;
	public static inline var PLATFORM_DEPTH = 30;
	public static inline var CHAR_DEPTH = 40;
	public static inline var FX_DEPTH = 50;
	
	public static var DEPTHS = [SIDE_DEPTH,PRE_SWARM_DEPTH,DANGER_DEPTH,PLATFORM_DEPTH,CHAR_DEPTH,FX_DEPTH];
	
	var mate :
	{
		p4: Bitmap,
		p3: Bitmap,
		//colorMood : gfx.ColorMood,
		p2: Bitmap,
		p2b : Bitmap,
		p2mood: Bitmap,
	};
	
	var previousPage : Null<Int> = null;
	public var data : Data;
	//public var gen : Gen;
	public var p3 : P3Scroller;
	public var p2 : P2Scroller;
	public var p2b : P2BScroller;
	public var bmpPool : Pool<KeyedBitmap>;
	public var heightMeterPool : Pool<gfx.Height>;
	var walls : IntHash<LevelSprite>;
	public var deadLine : Shape;
	var dLevel : mt.flash.Volatile<Float>;
	public var life : mt.flash.Volatile<Int>;
	
	public var nmy : mt.gx.EnumHash < NMY_TYPE, List<Nmy> > ;
	public var others : List<Entity>;
	
	public var kdos : Array<KdoDefSrc>;
	//public var kdosBound : IntHash<  >;//page to list of kdo
	
	public var bonus : Array<CharPowers>;
	
	
	public var tasks : List < Void->Bool > ;//true means remove me
	
	public static inline var NO_PLATE = false;// #if debug true #else false #end;
	public static inline var SIMPLE_PLATE = false;//#if debug true #else false #end;
	public static inline var NO_BG = false;
	public static inline var GRID = false;
	
	public static inline var SHOW_LEVEL_MAP = false;
	
	public static inline var ENT_PIVOT = SHOW_LEVEL_MAP || false;
	public static inline var STICK_PLAYER = false;
	
	public static 		 var SKIP_VIEW_SYNC = false;
	public static 		 var ENABLE_FLIP = true;
	
	#if debug
	public static 		 var SHOW_HIT_BOX = true;
	#else
	public static 		 var SHOW_HIT_BOX = false;
	#end
	public static 		 var NO_DEADLINE = false;
	public static 		 var NO_KILL = false;
	//append a danger feedback ?
	// show some swarm in no collide and behind the screen ? 
	
	public var floor : Crossing;
	public inline function makeFloor() 
	{
		floor = new Crossing( 0, Lib.nbch(), Lib.nbcw() + 1, 1, 0);
		dm.add(floor, PLATFORM_DEPTH );
	}
	public inline function getPage() 		return Std.int(game.view.y / Lib.ph())
	public inline function getCharPage() 	return Std.int(game.char.mc.y / Lib.ph())
	
	public inline function getD()		return dLevel
	static var m_shift = 6;
	static var m_mask  = (1 << m_shift) - 1;
	public var dbg : Bitmap;
	
	public var deadlinePack : Array<Nmy>;
	public var winCy : Null<Vol<Int>>;
	public var gameOverCalled = false;
	
	public function new()
	{
		dLevel = 0;
		root = new Sprite();
		
		dm = new mt.DepthManager(root);
		for ( i in DEPTHS )
			var p = dm.getPlan( i );
		
		pages = new mt.gx.BitArray();
		bg = [];
		walls = new IntHash();
		sideDrops = new IntHash();
		data = new Data();
		bmpPool = new Pool( function() return new KeyedBitmap() ).reserve( 4 );
		nmy = new mt.gx.EnumHash( NMY_TYPE );
		tasks = new List();
		makeMate();
		deadlinePack = [];
		life = 0;
		
		winCy = null;
		
		kdos = [];
		others = new List();
		pagesData = new IntHash();
		makeBonuses();
		
	}
	
	public function dumpDl()
	{
		#if (ide && false)
		for ( ri in 0...root.numChildren)
		{
			var c = root.getChildAt( ri );
			trace( c+" "+c.name);
		}
		#end
	}
	
	public var game(get, null) : Game; function get_game() return Game.me
	
	public function init()
	{
		var rd = new Rand( 125435 - Game.getSeed() );
		
		#if ide
		for (k in [ 
					{ amount:1, score:1 , frame:1 },
					{ amount:3, score:3 , frame:2},
					{ amount:5, score:5 , frame:3},
					{ amount:7, score:10 , frame:4},
					])
		{
			var mc = new InGamePK();
			mc.gotoAndStop( k.frame );
			
			kdos.pushBack( {mc:mc, tok:null,taken : false,frame:k.frame} );
		}
		#else
		for (k in AKApi.getInGamePrizeTokens())
		{
			var mc = new InGamePK();
			mc.gotoAndStop(k.frame);
			
			var pk = { mc:mc, tok:k, taken : false, frame:k.frame } 
			kdos.pushBack( pk );
			#if debug trace(pk);#end
		}
		#end
		
		for ( i in 0...2)
		{
			var f, s = null;
			bg[i]  = new mt.gx.Pair( null,null );
		}
		
		heightMeterPool = new mt.gx.Pool(function() return new gfx.Height() );
		heightMeterPool.reserve(4);
		
		addMate();
		
		Game.me.char = char = new Char();
		dm.add(char.mc, CHAR_DEPTH);
		data.addLdLines( new mt.Rand( Game.getSeed() ) );
		
		addPage(0);
		
		
		if (SHOW_LEVEL_MAP)
		{
			dbg = new Bitmap();
			dbg.bitmapData = data.pageBmp;
			dbg.scaleY = 2;
			dbg.scaleX = 2;
			dbg.y -= 400;
		}
		
		function spawnStartBonus()
		{
			var r = getUnknownBasic(rd);
			var p0 = pagesData.get(0);
			var brk = true;
			
			while(true) 
			{
				brk = true;
				for ( u in p0.bonus )
					if ( u.isPow )
					{
						var pu = (cast u).pow;
						if ( pu == r )
						{
							r = getBasic(rd);
							brk = false;
						}
					}
				if ( brk ) break;
			}
			
			var v  = new UpBonus( 0, r );
			v.cx = 4 + rd.random( Lib.nbcw() - 4 ) - 2;
			
			while( MathEx.absi( char.cx - v.cx ) <= 4 )
				v.cx = 4 + rd.random( Lib.nbcw() - 4 ) - 2;
				
			v.cy = game.char.cy;
			v.restager = Fixed;
			
			v.page = 0;
			var pd = p0;
			pd.dl.push( v );
			pd.bonus.push( v );
			v.restage();
			//trace("[Init]creating UpBonus " + v.uid + " " + v.cx + " "+v.cy);
		}
		
		if ( Game.isLevelup() )
		{
			var l = Game.getLevel();
			if ( Data.LD[ l ].sms != null )
				new fx.SMS( Data.LD[ l ].sms );
				
			if ( Game.getLevel() >= 18 )
				spawnStartBonus();
		}
		else
			spawnStartBonus();
		
		dumpDl();
	}
	
	public function makeMate()
	{
		var rd = new mt.Rand( Game.getSeed() ^ 13371337 );
		sideDropsSrc = new gfx.Plan1();
		for(i in 1...sideDropsSrc.totalFrames+1 )
		{
			function copy() return mt.deepnight.Lib.flatten( sideDropsSrc );
			sideDropsSrc.gotoAndStop( i );
			
			var c = mt.deepnight.Lib.flatten( sideDropsSrc );
			
			var a = [c, new Bitmap(c.bitmapData), new Bitmap(c.bitmapData), new Bitmap(c.bitmapData)];
			
			sideDrops.set( i, a);
			
			for( p in a )
			{
				dm.add(p, SIDE_DEPTH);
				p.x = -2000;
				p.y = -2000;
			}
			
			a[0].x = 8;
			a[2].x = 8;
			
			a[1].x = Lib.w()-4; a[1].scaleX = -1;
			a[3].x = Lib.w()-4; a[3].scaleX = -1;
		}
		
		var plan4 : Bitmap = mt.deepnight.Lib.flatten(new gfx.BG());
		var p4Detail = new gfx.Plan4();
		var shuff = mt.gx.Iota.int_rangeA( 1,p4Detail.totalFrames+1 );
		
		for ( i in 0...4)
		{
			var cur = 0.0;
			while( cur < Lib.w() )
			{
				var upDown = i == 0;
	
				var m = new flash.geom.Matrix();
				var s = 0.4 + rd.rand() * 0.5 * (upDown ? 0.8 : 1.0);
				if ( rd.random(2) == 0)
					m.scale( -1, 1);
				if ( upDown)
					m.scale(1, -1);
				m.scale(s, s);
				
				var ew = p4Detail.width * s;
				
				m.translate(cur + Dice.rollF( rd,-ew*0.2,0), upDown? -p4Detail.height*0.2:Lib.h());
				
				var idx = rd.random(shuff.length - 1);
				p4Detail.gotoAndStop( 1 + shuff[idx] );
				plan4.bitmapData.draw( p4Detail, m );
				cur += ew;
			}
		}
		
		plan4.bitmapData.draw( new gfx.MoodPlan4() );
		
		mate = {
					p4: plan4,
					p3 : mt.deepnight.Lib.flatten( randFrame(new gfx.Plan3() , rd )),
					p2 : mt.deepnight.Lib.flatten( randFrame(new gfx.Plan2() , rd )),
					p2b :
						{
							var bmp = mt.deepnight.Lib.flatten( randFrame(new gfx.Plan2() , rd ));
							bmp.scaleX = -1;
							bmp.x = Lib.w();
							bmp;
						},
					p2mood : mt.deepnight.Lib.flatten( randFrame(new gfx.MoodPlan2() , rd )) };
					
		p3 = new P3Scroller();
		p2 = new P2Scroller();
		p2b = new P2BScroller();
		
		deadLine = new Shape();
		
		var g = deadLine.graphics;
		g.beginFill(0xFF0000);
		g.lineStyle(0.03, 0xFF0000);
		g.moveTo(0, 0);
		g.lineTo(Lib.w(), 0);
		g.endFill();
		
		#if false
		deadLine.alpha = 0.5;
		#else 
		deadLine.alpha = 0;
		#end
		
	}
	
	
	public static function randFrame( mc : MovieClip, rd:mt.Rand )
	{
		var v = 1 + rd.random( mc.totalFrames );
		mc.gotoAndStop( v );
		return mc;
	}
	
	public var p3index : Int = 0;
	public function addMate()
	{
		var g :flash.display.DisplayObject = null;
		
		var i = 0;
		if (!NO_BG)
		{
			Game.me.addChild(g=mate.p4);
			g.parent.setChildIndex(g, i++);
		}
		
		p3index = i++;

		if (!NO_BG)
		{
			Game.me.addChild(g =  mate.p2mood    );
			g.parent.setChildIndex(g, i++);
		}
		
		
		if (Game.me.hasDeadLine() )
		{
			calcDeadLine();
			dm.add(deadLine,FX_DEPTH);
			var r = new Rand( Game.getLevel() * Game.getSeed() );
			
			var n = 50;
				
			for ( i in 0...n )
			{
				var n = addNmy( NT_SWARM, r.random( Lib.nbcw()), 0 );
				deadlinePack.push( n );
			}
		}
		
		new fx.Init();
	}
	
	
	public inline function makeKey(cx, cy)
	{
		mt.gx.Debug.assert( (cx & ~m_mask) == 0);
		
		return (cx&m_mask) | (cy << m_shift);
	}
	
	public inline function setWall( cx, cy, obj)					walls.set( makeKey(cx, cy), obj )
	public inline function testColl(cx:Int, cy:Int)
	{
		if ( cx <= 0 || cx >= Lib.nbcw())
			return true;
		else
		{
			var w = getWall(cx, cy);
			return w != null && w .coll;
		}
	}
	
	public inline function testBorder(cx:Int, cy:Int)
		return  ( cx <= 0 || cx >= Lib.nbcw())
	
	public function getWalls()
		return walls
	
	public inline function getWall( cx : Int, cy :Int )
	{
		if ( cx < 0 || cx >= Lib.nbcw()) 	return null;
		else								return walls.get( makeKey(cx,cy) );
	}
	
	
	public static var emptyPixels = [];
	
	public function getRandomPlace( wallCache : Array<LevelSprite>, seed : Int ) : {pl:LevelSprite,px:Int,py:Int}
	{
		var rd = new Rand( seed );
		for ( i in 0...5)
		{
			var pl = wallCache.random( rd );
			if ( pl == null ) continue;
			var px = rd.random( pl.cw - 1 ) + 1;
			var py = -1;
			
			var doIt = true;
			doIt = testColl( pl.px, pl.py+- 1 ) == false;
			doIt = doIt && testColl( pl.px-1, pl.py + 1) == false;
			doIt = doIt && testColl( pl.px - 1, pl.py + 1 ) == false;
			
			if ( !doIt ) continue;
				
			var fx = px + pl.px;
			var fy = py + pl.py;
			
			function testNm( enm )
			{
				var smX = (enm.cx ==  fx) || (enm.cx ==  fx + 1 ) || (enm.cx ==  fx - 1) || (enm.cx ==  fx - 2) || (enm.cx == fx + 2);
				var smY = (enm.cy ==  fy + 1) || (enm.cy ==  fy ) || (enm.cy ==  fy - 1) || (enm.cy ==  fy + 2) || (enm.cy ==  fy - 2);
				return smY && smX;
			};	
			
			if( nmy.exists( NT_BLADE)) 	doIt = doIt && !nmy.get( NT_BLADE).test(testNm);
			if( nmy.exists( NT_TORCH)) 	doIt = doIt && !nmy.get( NT_TORCH).test(testNm);
			
			if ( !doIt ) continue;
			
			return { pl:pl, px:px, py:py };
		}
		
		return null;
	}
	
	public static inline function compKeys(pl0 : LevelSprite,pl1 : LevelSprite)
		return pl0.cooKey - pl1.cooKey
		
	public function getWallCache( p : Int )
	{
		var wallCache = walls.filterA( function( w ) return w != null && w.pageKey == p );
		wallCache.sort( compKeys );
		return wallCache;
	}
	
	public function addPage(n:Int)
	{
		if ( n < 0) return;
		if ( pages.has(n) ) return;
			
		if ( n == 0)
			makeFloor();
		var rd : mt.Rand = new mt.Rand( Game.getSeed() * 351433848 + n * 138864868 );
		var b = bmpPool.create();
		
		var ph = Lib.ph();
		b.bitmapData = data.wallLine.random(rd).bitmapData;
		b.x = 0;
		b.y = - n * ph;
		b.key = n;
		dm.add( b, SIDE_DEPTH );
		
		b = bmpPool.create();
		b.bitmapData = data.wallLine.random(rd).bitmapData;
		b.x = Lib.w() + 4;
		b.scaleX = -1;
		b.y = - n * ph;
		b.key = n;
		dm.add( b, SIDE_DEPTH );
		
		var d = pageDiff(n);
		
		Prof.get().begin("parsing bmp");
		
		
		readPixels = 0;
		data.iterPage( n, function(rx, ry, col ) 		procPlatforms(rd, rx, ry + n  * Lib.nbch(), col, d, n) );
		data.iterPage( n, function(rx, ry, col ) 		procOthers(rd, rx, ry + n  * Lib.nbch(), col, d, n) );
		Prof.get().end("parsing bmp");
		
		pages.set( n );
		root.setChildIndex(char.me, root.numChildren - 1);
		
		var kc : Int = n;
		var kdr : mt.Rand = new Rand(kc * 35443486 + Game.getSeed() * 345341);
		var kdrb : mt.Rand = new Rand(kc * 354486 - Game.getSeed() * 3441);
		
		var generosity = 1.0;
		var wallCache = getWallCache( n );  
		
		if ( pagesData.exists(n) )
		{
			var pd = pagesData.get(n);
			for ( i in pd.dl)
				if( i.mc != null)
					i.restage();
		}
		else
		{
			var pd = new PageItems();
			data.iterPage( n, function(rx, ry, col ) 		procBonus(rd, rx, ry + n  * Lib.nbch(), col, d, n,pd) );
			var has = Dice.percent( kdrb, 45 );
			if ( has && Game.conf.spawnBonuses!=null && Game.conf.spawnBonuses )
			{
				var wall = getRandomPlace( wallCache, kdrb.random(13371337) );
				if (wall != null)
				{
					var rd = bonuses.normRand( kdrb );
					
					if ( rd != null) {
						var e = bonuses[rd];
						var epow = e.pow;
						if ( !isBasic(epow) && !hasBasic() )
							epow = getBasic(kdrb);
						
						if ( !char.powers.has( epow ) ) {
							var fx = Std.int(wall.px + wall.pl.px );
							var fy = Std.int(wall.py + wall.pl.py);
							
							if ( !pd.bonus.test( function(b) return fx == b.cx && fy == b.cy ))
							{
								var b = new UpBonus( n,epow );
								b.cx = fx;
								b.cy = fy;
								b.restager = Fixed;
								pd.bonus.push( b );
								pd.dl.push( b );
								b.restage();
								
								//trace("[Rand]creating UpBonus " + b.uid + " " + b.cx + " "+ b.cy+" "+Game.char.cy);
							}
						}
					}
				}
			}
			
			if( Game.isLeague())
			if ( Dice.percent( kdrb, 30 ) ){
				var wall = getRandomPlace( wallCache, kdrb.random(13371337) );
				if ( wall != null)
				{
					var fx = Std.int(wall.px + wall.pl.px );
					var fy = Std.int(wall.py + wall.pl.py);
						
					if( !pd.bonus.test(function(b) return b.cx == fx && b.cy == fy) ){
						var b = new Bonus(n);
						b.cx = fx;
						b.cy = fy;
						b.restager = Fixed;
						b.restage();
						pd.bonus.push(b);
						pd.dl.push(b);
					}
				}
			}
			
			function addOnePP( k : KdoDefSrc )
			{
				var plSeed = kdr.random(13371337);
				var pl = getRandomPlace( getWallCache( n), plSeed );
				if ( pl!=null )
				{
					k.mc.scaleX = k.mc.scaleY = 0.5;
					k.mc.x = Std.int(pl.px * Lib.cw) + k.mc.width * 0.5;
					k.mc.y = Std.int(pl.py * Lib.ch) + k.mc.height * 0.5;
					var ent = new Kdo( n, k );
					pd.kdo.push( { pfKey:makeKey(pl.px, pl.py), kd : k, ent: ent} );
					k.taken = true;
					
					ent.restager = RandPlatform( plSeed );
					ent.restage();
					return true;
				}
				else return false;
			}
			
			
			if ( Game.isLeague())
			{
				var rkdo = kdos.filter( function(k) return k.tok != null && (Game.me.score >= k.tok.score.get()) && !k.taken );
				if ( rkdo.length > 0 )
					for ( i in 0...rkdo.length )
						if ( Dice.percent(kdr, 30))
						{
							var kl = rkdo.filter(function(k) return !k.taken).random(kdr);
							if (kl == null) break;
							
							var ok = addOnePP(kl);
							if (ok) 
								break;
						}
			}
			else if ( Game.isLevelup())
			{
				var pp = kdos.length / game.level.data.ldLength( Game.getLevel() ); 
				var nb = Math.ceil( pp );
				//trace("trying " + nb);
				for ( i in 0...nb )
				{
					var kl = kdos.filter(function(k) return !k.taken).random(kdr);
					if (kl == null) break;
					
					var ok = addOnePP(kl);
					if (ok) 
						break;
				}
			}
			
			pd.mk();
			pagesData.set( n, pd );
			for ( l in nmy)
			if( l != null )
				for(  n in l )
					n.restage();
					
					
		}
	}
	
	
	public function leagueDiff(n)
	{
		var p = [ { d:1.0, w:100 }, { d:2.0, w:0 }, { d:3.0, w:0 } ];
		
		var b = 4;
		for ( i in 0...n)
		{
			if( p[0].w > 0 )
			{
				p[0].w -= b;
				p[1].w += b;
			}
			else
			if( p[1].w > 0 )
			{
				p[1].w -= b;
				p[2].w += b;
			}
		}
		
		var mt = new mt.Rand(n * 137 + Game.getSeed());
		var r = mt.random( 100 );
		for ( v in  p )
		{
			if ( r < v.w )
				return v.d;
			else
				r -= v.w;
		}
		
		return 1.0;
	}
	
	public function wRand( rd:mt.Rand, arr : Array<{d:Float,w:Int}> )
	{
		var t = arr.sum(function(t) return t.w);
		var r = rd.random( t );
		for ( v in arr )
		{
			if ( r < v.w )
				return v.d;
			else
				r -= v.w;
		}
		
		return 1.0;
	}
	
	public function pageDiff( n )
	{
		#if test_level
		//return 3.0;
		#end
		
		#if debug
		//return 3.0;
		#end
		
		if ( Game.isLeague() )
			return leagueDiff(n);
		else
		{
			var d = Data.LD[ Game.getLevel() ].diff;
			if ( d == null) return leagueDiff(n);
			
			var sd = new mt.Rand( (0xdeaddead) ^ (n * 1337) + Game.getSeed() );
			return wRand(sd,d);
		}
	}

	public function extract( col,d ) 
	{
		col = col & 0xFFFFFF;
		var colR = (col>>16) & 0xFF;
		var colG = (col>>8) & 0xFF;
		var colB = (col>>0) & 0xFF;
		
		if ( d >= 2.01)		return colR;
		if ( d <= 1.01)  	return colB;
		else 				return colG;
	}
	
	public static var cry = -1;
	public static var cfx = -1;
	
	function mkLine(x,y,l,n)
	{
		var ry = - y + Lib.nbch();
		var cp = new Crossing(x, ry, l, 1, n , false );
		dm.add(cp,PLATFORM_DEPTH);
	}
	
	public var bonuses :Array<{ weight : Int, pow :CharPowers }>;
	function makeBonuses():Void 
	{
		bonuses = [];
		bonuses.push( { weight:30, pow:CP_DOUBLE_JUMP} );
		bonuses.push( { weight:40, pow:CP_WALL_STICK } );
		bonuses.push( { weight:40, pow:CP_SUPER_JUMP } );
		
		bonuses.push( { weight:20, pow:CP_KICK } );
		bonuses.push( { weight:10, pow:CP_CANCEL } );
	}
	
	function isBasic(p)
	{
		return p == CP_DOUBLE_JUMP || p == CP_WALL_STICK || p == CP_SUPER_JUMP;
	}
	
	function hasBasic()
	{
		var p = game.char.powers;
		return p.has( CP_DOUBLE_JUMP ) || p.has( CP_WALL_STICK ) || p.has( CP_SUPER_JUMP );
	}
	
	function getBasic(rd)
	{
		if (Dice.percent( rd, 50 ))
			return CP_SUPER_JUMP;
			
		if (Dice.percent( rd, 50 ))
			return CP_WALL_STICK;
			
		return CP_DOUBLE_JUMP;
	}
	
	function getUnknownBasic(rd)
	{
		if ( !char.powers.has(CP_SUPER_JUMP) && Dice.percent( rd, 50 ))
			return CP_SUPER_JUMP;
			
		if ( !char.powers.has(CP_WALL_STICK) && Dice.percent( rd, 50 ))
			return CP_WALL_STICK;
			
		if(!char.powers.has(CP_DOUBLE_JUMP))
			return CP_DOUBLE_JUMP;
		else
			return CP_KICK;
	}
	
	public var readPixels = 0;
	public function procPlatforms( rd:mt.Rand, rx:Int, ry:Int, col:Int, d : Float, n : Int ) {	
		
		function stop()
		{
			if ( cfx >= 0 ) mkLine( cfx, cry, rx - cfx,n );
			cfx = -1;
			cry = ry;
		}
		
		var colCode = extract( col, d );
		switch( colCode ) {
			case Lib.WALL_ID:{
				if ( cry != ry ) 	stop();
				if ( cfx < 0 )		cfx = rx;
				readPixels++;
			}
			default:
				stop(); // not known 
		}
		
		
	}
	
	public inline function getNmyXY( t:NMY_TYPE, cx :Int, cy:Int, me : Nmy )
	{
		if (!nmy.exists(t))
			return null;
		else 
		{
			var r = null;
			for ( n in nmy.get(t))
				if ( n.cx == cx && n.cy == cy && n != me)
				{
					r=n;
					break;
				}
					
			return r;
		}
	}
	
	public function addNmy(?np,t,x,y,d=1.0 )
	{
		var nmy_ent : Nmy = new Nmy(np).init( t, x, y, d );
		if ( !nmy.exists( t ) ) nmy.set( t , new List<Nmy>() );
		nmy.get( t ).pushBack( nmy_ent );
		nmy_ent.restage();
		return nmy_ent;
	}
	
	public function procBonus( rd:mt.Rand, rx:Int, ry:Int, col:Int, d : Float, n : Int,pd:PageItems ) 
	{
		var cy = - ry + Lib.nbch();
		var lev = game.level;
		
		if( col > 0xfa0000 ) 
			switch(col)
			{
				case 0xFF6400,0xFF7800,0xFF8C00,0xFFA000,0xFFB400:
					var i = Std.int(((col & 0x00FFFF) >> 8) % 100 / 20);
					var bn = Type.createEnumIndex( CharPowers, i );
					if ( !char.powers.has( bn ) )
					{
						if ( !pd.bonus.test(function(p) return p.cx == rx && p.cy != cy ) )
						{
							var v  = new UpBonus( n, bn );
							v.cx = rx;
							v.cy = cy;
							v.restager = Fixed;
							v.restage();
							pd.bonus.push( v );
						}
						
						//trace("[Level]creating UpBonus " + v.uid + " " + v.cx + " "+ v.cy);
					}
			}
			
	}
	
	
	public function procOthers( rd:mt.Rand, rx:Int, ry:Int, col:Int, d : Float, n : Int )
	{
		var cy = - ry + Lib.nbch();
		var lev = game.level;
		 
		//trace("testing: " + rx +" "+ cy);
		function testPix(x, y)	return extract(lev.data.getPixel(n,x, y),d) == Lib.WALL_ID;
		function genNmy(t) 		return addNmy(n,t, rx, cy,d);
		function mkBlade()
		{
			var t = genNmy(NT_BLADE);
			t.rx = 0;
			if ( lev.testColl( rx - 1 , cy ) )
			{
				t.mc.rotation = 90;
				t.cy--;
			}
			else  if( lev.testColl( rx + 1, cy )) 
			{
				t.mc.rotation = -90;
				t.cx++;
				t.cy++;
			}
			else if ( lev.testColl( rx, cy + 1 ) || testPix(rx, cy + 1))
			{
				t.mc.rotation = 0;
				//t.cx++;
			}else if ( lev.testColl( rx, cy - 1 ) || testPix(rx, cy - 1))
			{
				t.cx++;
				t.cy--;
				t.ry += 0.25;
				t.mc.rotation = -180;
			}
			else
			{
				
			}
			
			return t;
		}
		
		if( col > 0xfa0000 ) 
		{
			switch(col)
			{
				case 0xFF0000:
				{
					if(rd.random(8)<= 4)
					{
						var platform = lev.getWall( rx,  cy + 1  )  ;
						var p = heightMeterPool.create();
						if ( platform == null )
							return;
						platform.addChild(p);
						p.toBack();
						p.y = - p.height * 0.5 - 6 - 10;
						p.alpha = 0.8;
						
						var isFoot = false;
						
						var o = p._txt.defaultTextFormat;
						var pry = ry ;
						p._txt.setTextFormat( o);
						p._txt.defaultTextFormat = o;
						p._txt.text = !isFoot ? (Std.int(pry / 3.0 ) + "M") : (Std.int(pry) + "FT");
						p._txt.selectable = false;
					}
				}
				
			}
			
			
		}
		else
		{
			switch(col)
			{
				default:
					var colCode = extract( col, d );
					switch( colCode ) {
					default: //do nothing
					case 0xAB: 	genNmy( NT_BAD_HANDLE );	
					case 0x7F: 	genNmy( NT_HANDLE );
					case 0x5e: 	genNmy( NT_SWARM	);
					case 0xAC: //not yet implemented
					//torch
					case 0xde: 	var t = genNmy( NT_TORCH);
						if ( lev.testColl( rx , cy + 1 ) )
						{
							t.getMovieClip().gotoAndStop(2);
							t.rx = 0;
						}
						else  if( lev.testColl( rx , cy - 1 )) 
						{
							t.cy -= 2; 
							t.rx = 0;
							t.getMovieClip().gotoAndStop(1);
						}
						else 
						{
							//?
						}
					
					//blades
					case 0x36: 
						var r = mkBlade(); 
					
					
					//massives
					case 0xcd:genNmy( NT_MASSIVE );
				}
			}
		}
	}
	
	
	
	public function updatePages()
	{
		var wh = Lib.ph();
		var n = getPage();//nth page
		//var n = getCharPage();
		removePage( n - 2 );
		addPage( n - 1 );
		addPage( n  );
		addPage( n + 1 );
		addPage( n + 2 );
		removePage( n + 3 );
		
		function rd(n)
			return new mt.Rand( Std.int( Game.getSeed() + 271622  *  n + Game.getSeed() * (n * 402264 * 398287) ));
			
		var rdPN = rd(n);
		var rdPNP = rd(n + 1);
		
		var t = sideDropsSrc.totalFrames;
		
		function assign( pn,pnp)
		{
			var vp1 = 1 + rdPN.random(t);
			var vp2 = 1 + rdPN.random(t);
			
			if ( vp1 == vp2)
				vp2 = 1 + (vp1 % t);
				
			pn.first = sideDrops.get( vp1 )[0];
			pn.second = sideDrops.get( vp2 )[1];
			
			var vp1 = 1 + rdPNP.random(t);
			var vp2 = 1 + rdPNP.random(t);
			
			if ( vp1 == vp2)
				vp2 = 1 + (vp1 % t);
			
			pnp.first = sideDrops.get( vp1 )[2];
			pnp.second = sideDrops.get( vp2 )[3];
			
			pn.first.y =  - n * wh;//g
			pn.second.y =  - n * wh;
		
			pnp.first.y = - (n + 1) * wh;//r
			pnp.second.y = - (n + 1) * wh;
		}
		
		
		if (!NO_BG)
		{
			if ( n % 2 == 0)
				assign(bg[0], bg[1]);
			else
				assign(bg[1], bg[0]);
		}
	}
	
	var l1_bonus = false;
	public function update()
	{
		Prof.get().begin('level update');
		mt.gx.Debug.assert( root.numChildren != 0);
		
		char.update();
		
		#if !ide
		if ( mt.gx.MathEx.posMod( Game.getFrame(), 10) == 0 && !gameOverCalled)
		{
			var tx = Std.int( (char.cx + char.rx) * Lib.cw ); //-> char.mc.x
			var ty = Std.int( (char.cy + char.ry) * Lib.ch );
			
			AKApi.emitEvent( Std.int(char.cx) + 1024*1024 );
			AKApi.emitEvent( Std.int(char.cy) + 1024*1024 );
			
			AKApi.emitEvent( Std.int(char.rx * 256.0 + 512.0)  );
			AKApi.emitEvent( Std.int(char.ry * 256.0 + 512.0)  );
			
			var eid = AKApi.getEvent();
			while (eid != null){
				var ncx : Null<Int> = eid;
				var ncy : Null<Int> = AKApi.getEvent();
				var nrx : Null<Int> = AKApi.getEvent();
				var nry : Null<Int> = AKApi.getEvent();
				
				char.cx = ncx - 1024*1024;
				char.cy = ncy - 1024*1024;
				
				char.rx = (nrx - 512.0) / 256.0;
				char.ry = (nry - 512.0) / 256.0;
				
				eid = AKApi.getEvent();
			}
		}
		#end
		
		
		var charRect = char.getRect();
		for ( l in nmy )
			for ( e in l )
			{
				e.update();
				
				var rme = e.getRect();
				if ( rme.intersects(charRect))
				{
					var die = char.onColl( e );
					if ( die ) l.remove(e);
				}
			}
			
		var wh = Lib.h();
		var n = getPage();//nth page
		
		var r = 0.18;
		var view = game.view;
		var prevView = ( (1.0-r) * view.y + r * (- char.mc.y + wh/2));
		var deph = view.y - prevView;
		
		if( !SKIP_VIEW_SYNC )
		{
			view.y = Std.int(prevView);
			if ( STICK_PLAYER )	view.y = Std.int(-char.mc.y + wh/2);
			if ( view.y < -30 )	view.y = -30;
		}
	
		//mkP2Parallax(deph);
		
		if(!NO_BG)
		{
			p3.update();
			p2.update();
			p2b.update(); 
		}
		
		
		if ( n != previousPage)
		{
			previousPage = n;
			updatePages();
		}
		
		if ( game.hasDeadLine() )
			calcDeadLine();
		
		if ( SHOW_LEVEL_MAP && dbg.parent==null)
		{
			game.char.cell.addChild(dbg);
			dbg.parent.setChildIndex( dbg, dbg.parent.numChildren - 1);
		}
		
		var charCy = Math.abs(char.cy - Lib.nbch());
		if ( !Game.isLeague() )
			if ( winCy != null )
				if ( charCy >= winCy && fx.Win.me == null)
				{
					if( char.state == WANDER_STAND || char.state  == WANDER_RUN )
						new fx.Win();
					else 
						char.input = false;
				}
		
		
		if ( !Game.isLeague() ){
			var top = winCy;
			var r  = charCy / top;
			
			#if !ide
			api.AKApi.setProgression( r );
			#end
		}
		
		var cr = char.getRect();
		for ( p in others )
		{
			var lp = p;
			if ( p.mc == null)
			{
				others.remove( p );
				continue;
			}
			
			p.updatePhy();
			
			var diff : Float = Math.abs( p.mc.getRect( game.level.root).y - char.mc.y );
			p.mc.visible = !( diff > Lib.h());
			
			if ( p.mc.visible)
			{
				var rect : flash.geom.Rectangle = p.getRect();
				var lcr : flash.geom.Rectangle = cr;
				
				if ( rect.intersects(lcr) ) {
					p.onProc();
				}
				else
				{
					if (  	Game.isLevelup() 
					&& 		Game.getLevel() == 0 
					&& 		Std.is( p, UpBonus) 
					&& diff <= Lib.h() * 0.5 
					&& l1_bonus == false )
					{
						var sms = new SMS(Text.take_that_bonus);
						new mt.fx.Blink( p.mc,240,8,8 );
						l1_bonus = true;
						
						sms.onFinish = function() {
							var sms = new SMS(Text.dbl_jump_kills);
							for ( l in nmy) {
								for ( n in l ) {
									if (n.type == NT_BAD_HANDLE){
										var f = data.playFX('target');
										var r = n.getLogCenter();
										f.x = r.x;
										f.y = r.y;
									}
								}
							}
						};
					}
				}
			}
			
		}		
		
		
		
		if(tasks.length>0)
			for (t in tasks)
				if ( t() )
					tasks.remove(t);
		
		if(Game.isLeague())
		{
			rlife++;
			if ( !pulpzStarted && (rlife == 20 * 40 || char.getMeter()>40) )
			{
				pulpzStarted = true;
				new fx.Init( Text.flee_0);
				new SMS( Text.flee_1 );
			}
		}
		else pulpzStarted = true;
			
		if(pulpzStarted)
			life++;
			
		Prof.get().end('level update');
	}
	
	public function getBonus()
	{
		return others.filter( function(e) return Std.is(e, Bonus ));
	}
	
	var pulpzStarted = false;
	var rlife = 0;
	
	public function calcDeadLine()
	{
		var cyLevel = 0.0;
		var diffTune = 1.0; // more is easier
		
		if ( life <= 0 )
		{
			dLevel =  20 + Lib.nbch();
			return;
		}
		
		if( Game.conf.deadLineSpeed != null )
			diffTune = Game.conf.deadLineSpeed;
		
		var cyPal1 = 25.0;
		var sPal1 = 40 * 15 * (1.0/diffTune);
		
		var cyPal2 = 500.0;
		var sPal2 = 40 * 120 * (1.0/diffTune);
		
		
		if ( life <= sPal1  )
			cyLevel = (cyPal1 / sPal1 ) * life;//first section make slow beginnint
		else if ( life <= sPal2)
			cyLevel = cyPal1 + ( cyPal2 / sPal2 ) * (life - sPal1); // moderate speed
		else 
		{
			var b = cyPal1 + ( cyPal2 / sPal2 ) * (sPal2 - sPal1);
			var r = life - sPal2;
			var vb = ( cyPal2 / sPal2 );//continue on old rythm
			
			var vbfactor = (1.0 + Math.pow(r / (40.0 * 20.0), 0.333) / diffTune); // 1...n // speed up frankly
			b += r * ( vb * vbfactor); 
			
			cyLevel = b;
		}
		
		cyLevel -= 20.0;
		dLevel =  -cyLevel + Lib.nbch();
		deadLine.y = Std.int(dLevel * 16.0) ;
	}
	
	public function removePage(i:Int)
	{
		Prof.get().begin('rm page');
		for ( b in bmpPool.getUsed())
			if ( b.key == i)
				bmpPool.destroy(b);
				
		for ( w in walls)
			if ( w!=null&&w.pageKey == i)
			{
				w.remFromCol();
				w.finalize();
				walls.remove( makeKey( w.px,w.py) );
			}
			
		for ( k in nmy.keys())
			nmy.set( k, nmy.get(k).filter( function(e)
			{
				var del  = e.page == i;
 				if (del && e.mc.parent != null) 
					root.removeChild(e.mc);
				return !del;
			}));
			
		for ( b in others )
			if(b.page==i)
				b.unstage();
		
		/*
		var l = kdosBound.get(i);
		if(l!=null)
		for ( k in l)
			k.kd.mc.detach();
		*/
			
		pages.set( i, false );
		Prof.get().end("rm page");
	}
	
}