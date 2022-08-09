import haxe.EnumFlags;
import DefaultImport;

using mt.gx.Ex;
enum EntFlags
{
	GRAVITY;
	CAN_GRIP;
	GRIPPED;
	FLY;
	NO_COLLIDE;
}



class Entity  implements haxe.Public
{
	var cx	: Vol<Int>;
	var cy	: Vol<Int>;
	
	var rx	: Vol<Float>;
	var ry	: Vol<Float>;
	
	var dx 	: Vol<Float>;
	var dy 	: Vol<Float>;
	
	var fx 	: Float; //xfriction
	
	var oppy : Float;//oppose to grav
	
	var flags : haxe.EnumFlags<EntFlags>;
	var mc : flash.display.Sprite;

	var page : Null<Int>;
	var maxPv : Float = 1.0;
	var pv : Float = 1.0;
	var invincible = false;
	var cell:flash.display.Sprite;
	var hb:flash.display.Sprite; 
	var restager : Restager;
	var name:String;
	
	
	public var game(get, null) : Game; function get_game() return Game.me
	
	
	public function new()
	{
		flags = EnumFlags.ofInt(0);
		fx = 0.9;
		
		dx = 0;
		dy = 0;
		
		oppy = 0;
		
		rx = 0;
		ry = 0;
		
		cx = 0;
		cy = 0;
		
		if ( Level.ENT_PIVOT)
		{
			cell = new flash.display.Sprite();
			var g = cell.graphics;
			g.beginFill(0x00FFAA);
			g.drawRect(0,0,16,16);
			g.endFill();
		}
		
		if ( Level.SHOW_HIT_BOX )
		{
			hb = new flash.display.Sprite();
			hb.alpha = 0.25;
		}
	}
	
	public function isDead() return pv <= 0
	public function hurt(v)
	{
		if (invincible) return false;
		
		pv -= v;
		if ( pv <= 0 )
		{
			onDestroy();
			return true;
		}
		return false;
	}
	
	
	//whence page is activated
	public function restage()
	{
		if ( page != null) {
			//trace("default restage " +name);
			defaultRestage();
		}
		mc.visible = true;
	}
	
	public function defaultRestage()
	{
		if (mc == null || restager == null) 
		{
			#if debug trace("no restager or no mc ") ;#end
			return;
		}
		var l = game.level;
		if ( l.others.has( this ))
		{
			//#if debug trace("already in this"); #end
			return;
		}
		
		switch( restager )
		{
			case RandPlatform(seed):
				
			var wall = game.level.getRandomPlace( game.level.getWallCache(page), seed );
			mt.gx.Debug.assert( wall != null );
			cx = wall.px;
			cy = wall.py;
			wall.pl.addChild( mc );
			l.others.push( this );
			//trace("RandPlatform "+name);
			
			case FixedPlatform( cx, cy )://platform px py = cx, cy
			var wc = l.getWallCache(page);
			var w = null;
			for ( pl in wc )
				if ( pl.px == cx && pl.py == cy )
				{
					w = pl;
					break;
				}
				
			if ( w == null)
				throw "assert";
				
			w.addChild( mc );
			l.others.push( this );
			//trace("FixedPlatform "+name);
			
			case Fixed:
			syncPos();
			if ( !l.others.has(this) )
				l.others.push( this );
			l.dm.add( mc, Level.CHAR_DEPTH );
			//trace("Fixed "+name);
		}
		mc.visible = true;
	}
	
	public function unstage()
	{
		//trace("unstaging " + name);
		var l = game.level;
		l.others.remove( this );
		
		if ( mc.parent != null) {
			mc.parent.removeChild( mc );
			mc.visible = false;
		}
	}
	
	public function getRect():flash.geom.Rectangle
		return mc.getRect( game.level.getRoot() )
		
	public static inline var sy_cap = 0.775;
	public static inline var grav = 0.035;
	
	function onFall() { /*trace("falling");*/ }
	function onLand(dy) { /*trace("landing");*/ }
	function onWallGrip(x:Int, y:Int) { /*trace("gripping "+x+""+y);*/ }
	
	public function movePix(x,y)
	{
		cx = x >> Lib.cw_shift;
		cy = y >> Lib.ch_shift;
		
		rx = (x - (cx << Lib.cw_shift)) / Lib.cw;
		ry = (y - (cy << Lib.ch_shift)) / Lib.cw;
	}
	
	public function moveF(cx:Float,cy:Float)
	{
		this.cx = Std.int(cx);
		this.cy = Std.int(cy);
		
		rx = cx - this.cx;
		ry = cy - this.cy;
	}
	
	public function move(cx:Int,cy:Int)
	{
		this.cx = cx;
		this.cy = cy;
		
		rx = 0.5;
		ry = 1.0;
	}
	
	public function tpToF(cx:Float,cy:Float)
	{
		this.cx = Std.int(cx);
		this.cy = Std.int(cy);
		
		rx = ((cx>0) ? 1 : -1) * ( cx - this.cx );
		ry = ((cy>0) ? 1 : -1) * ( cy - this.cy );
	}
	
	public function getFx() return cx + rx
	public function getFy() return cy + ry
	
	public function getCx( pix : Float) : Int
		return Std.int(pix / Lib.cw)
		
	public function getCy( pix : Float) : Int
		return Std.int(pix / Lib.ch)
	
	public function syncPos() {
		/*
		var krx = Std.int(rx * 1000.0);
		rx = krx * 0.001;
		
		var kry = Std.int(ry * 1000.0);
		ry = kry * 0.001;
		*/
		
		mc.x = Std.int( Lib.cw * (rx + cx));
		mc.y = Std.int( Lib.ch * (ry + cy));
	}
	
	//called whenever should be disposed, trigger object removal here
	public function onDispose()
	{
		if (hb != null) hb.detach();
	}
	
	//called whenever should dies, trigger fx here !
	public function onDestroy()
	{
		
	}
	
	public function dump()
	{
		//trace(cx + " " + cy);
		//trace(rx + " " + ry);
	}
	
	
	public function updatePhy() {
		
		Lib.Prof.get().begin( 'uphy' );
		var lev = game.level;
		ry += dy;
		
		if( flags.has(GRAVITY))		dy += (grav-oppy);
		if ( dy > sy_cap) 			dy = sy_cap;
		
		
		rx += dx;
		dx = dx * fx;
		
		//TODO put a wider feet test 
		function testColY()
		{
			if ( !flags.has(GRAVITY) && !flags.has(FLY))
				if ( !lev.testColl( cx, cy + 1 ) )
				{
					flags.set( GRAVITY );
					onFall();
				}
			
			if ( flags.has(GRAVITY) && !flags.has(FLY))
			{
				var t = lev.testColl( cx, cy + 1 );
				
				if( dy > 0 && t && ry >= 0.95)
				{
					var ody = dy;
					dy = 0;
					ry = 1;
					onLand(ody);
				}
			}
		}
			
		function testColX()
		{
			var t = this;
			
			if ( !flags.has(CAN_GRIP) )
			{
				if ( lev.testBorder( cx - 1, cy ))
				{
					if ( dx < 0 )
						dx = 0; //stuck on wall an running
					else if (!flags.has(GRIPPED) && (cx-1==0))
						rx += 0.05;//stuck an wall bounce
						
					if ( rx < 0.4 )
						rx = 0.4;
				}
				
				if ( lev.testBorder( cx + 1, cy ) )
				{
					if ( dx > 0 )
						dx = 0;
					else if (!flags.has(GRIPPED) && (cx+1==Lib.nbcw()-1) )
						rx -= 0.05;
					
					if ( rx > 0.6 ) 
						rx = 0.6;
				}
			}
			else
			{
				if ( lev.testColl( cx - 1, cy ))
				{
					var ccyp = lev.testColl( cx, cy - 1 );
					var ccx = lev.testColl( cx, cy );
					var shallGrip = flags.has(CAN_GRIP) && !ccyp && ! ccx && Math.abs(dy ) > 0.005;
					var tb = lev.testBorder( cx - 1, cy );
					
					if ( dx < 0 )
					{
						if ((shallGrip||tb))
							dx = 0; //stuck on wall an running
					}
					else if (!flags.has(GRIPPED) && (cx-1<=0))
						rx += 0.05;//stuck an wall bounce
						
					if ( (shallGrip||tb) && rx < 0.4 )
						rx = 0.4;
					
					if ( shallGrip )
						onWallGrip( cx - 1, cy );
				}
				
				if ( lev.testColl( cx + 1, cy ) )
				{
					var ccx = lev.testColl( cx, cy );
					var ccyp = lev.testColl( cx, cy - 1 );
					var shallGrip = flags.has(CAN_GRIP) && !ccyp && !ccx && Math.abs(dy ) > 0.005;
					var tb = lev.testBorder( cx + 1, cy );
					
					if ( dx > 0 )
					{
						if((shallGrip||tb))
							dx = 0;
					}
					else if (!flags.has(GRIPPED) && (cx+1==Lib.nbcw()-1) )
						rx -= 0.05;
						
					if ( (shallGrip||tb) && rx > 0.6 ) 
						rx = 0.6;
					
					if( shallGrip )
						onWallGrip( cx + 1, cy );
				}
			}
		}
		
		testColY();
		
		while(ry<0) {
			cy--;
			ry++;
			
			if(!flags.has(NO_COLLIDE))
				testColY();
		}
		while(ry>1) {
			cy++;
			ry--;
			
			if(!flags.has(NO_COLLIDE))
				testColY();
		}
		
		if(!flags.has(NO_COLLIDE))
			testColX();
			
		//process x
		while(rx<0) {
			cx--;
			rx++;
		}
		while(rx>1) {
			cx++;
			rx--;
		}
		
		if ( Level.ENT_PIVOT)
		{
			cell.x = cx << 4;
			cell.y = cy << 4;
			if (cell.parent == null && mc.parent != null)
			{
				mc.parent.addChild( cell );
				//mt.gx.as.Lib.toFront( cell);
			}
		}
		
		if ( Level.SHOW_HIT_BOX && hb != null)
		{
			var r = getRect();
			hb.graphics.clear();
			hb.graphics.beginFill(0xFFAA00);
			hb.graphics.drawRect( r.x, r.y, r.width, r.height );
			hb.graphics.endFill();
			
			if ( hb.parent == null && mc.parent != null)
			{
				mc.parent.addChild( hb );
				//mt.gx.as.Lib.toFront( hb);
			}
		}
		
		Lib.Prof.get().end( 'uphy' );
	}
	
	public function onProc()
	{
		
	}
	
}