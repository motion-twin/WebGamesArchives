import DefaultImport;
import flash.display.Shape;
import flash.display.Sprite;
import flash.sampler.NewObjectSample;
import gfx.BG;
import gfx.Danger;
import mt.fx.Shake;
import mt.gx.math.Vec2i;
import mt.gx.Flags;
import mt.gx.Pool;
import mt.gx.MathEx;
import McCache;
import mt.gx.time.FTimer;

using mt.gx.Ex;

enum NMY_FLAGS
{
	ACQUIRED;
}

enum NMY_MASS_STATE
{
	STALLED;
	THINKING(fr : Int );
	GOTO(x:Float);
}

enum NMY_SWARM_STATE
{
	STALLED;
	TRACK_DEADLINE;
	SWARM_PLAYER;
	NSS_GOTO(x:Int, y:Int );
}


enum NMY_BAD_STATE
{
	NBD_IDLE(f:Int);
	NBD_WANDER(x:Int,y:Int);
	NBD_GOTO_ANCHOR;
}

import flash.display.MovieClip;
class Nmy extends Entity
{
	//var sh : flash.display.Shape;
	var spawnCell : Vec2i;
	var type : NMY_TYPE;
	var aggro = true;
	var instaKill = false;
	var canBeTarget = false;
	var canBeKilled = false;
	
	var nmyFlags : mt.gx.Flags<NMY_FLAGS>;
	var massState : NMY_MASS_STATE;
	var swarmState : NMY_SWARM_STATE;
	var swarmToBg : Bool;
	
	var badState : NMY_BAD_STATE;
	
	var pause = false;
	
	var oscillate = false;
	var d  = 1.0;
	var stop = false;
	
	var life : Int;
	
	public static var swarmPool : Pool<gfx.Swarm>;
	public static var handlePool : Pool<gfx.Grabbers>;
	public static var torchPool : Pool<gfx.Danger>;
	public static var bladePool : Pool<CachedMc>;
	public static var massPool : Pool<gfx.Sentinel>;
	
	public static var dgrBlade : Danger = 
	{
		var d = new Danger();
		d.gotoAndStop(3);
		McCache.make(d.smc);
		d;
	};
	
	public static function create()
	{
		if (swarmPool != null) swarmPool = null;
		if (handlePool != null) swarmPool = null;
		if (torchPool != null) torchPool = null;
		if (bladePool != null) bladePool = null;
		if (massPool != null) massPool = null;
		
		var mr = new mt.Rand( Game.getSeed() );
		swarmPool = new Pool( function()
		{
			var r = new gfx.Swarm();
			r.mouseEnabled = false;
			return r;
		});
		handlePool = new Pool( function()
		{
			var r = new gfx.Grabbers();

			var wr : MovieClip = cast(r.smc).wr;
			var wl : MovieClip = cast(r.smc).wl;
			
			var rdr = mr.random( wr.totalFrames ) + 1;
		
			wr.gotoAndPlay( rdr ); 
			wl.gotoAndPlay( rdr ); 
			
			r.mouseEnabled = false;
			return r;
		});
		torchPool = new Pool( function(){
			var r = new gfx.Danger();
			r.gotoAndStop(1);
			r.mouseEnabled = false;
			return r;
		});
		bladePool = new Pool( function() 
		{
			var r = McCache.instance( dgrBlade.smc );
			
			r.mouseEnabled = false;
			return r;
		});
		massPool = new Pool( function() 
		{
			var r = new gfx.Sentinel();
			r.gotoAndStop(1);
			r.mouseEnabled = false;
			return r;
		});
		
		swarmPool.reserve( 50 );
		handlePool.reserve( 10 );
		torchPool.reserve( 10 );
		bladePool.reserve( 10 );
		massPool.reserve(10);
	}
	
	public function new(?p:Int)
	{
		super();
		page = p;
		nmyFlags = new Flags(0);
		massState = STALLED;
		badState = NBD_IDLE(40);
		swarmState = STALLED;
		spawnCell = new Vec2i();
	}
	
	public override function getRect() : flash.geom.Rectangle
	{
		if ( type == NT_BLADE )
 			return mc.getRect(game.level.getRoot());
			
		mt.gx.Debug.assert(mc != null);
		var f : { _hit: flash.display.MovieClip } = (cast mc);
		if (f != null &&  f._hit != null)
			return f._hit.getRect( game.level.getRoot()  );
			
 		var smc : { _hit: flash.display.MovieClip } = (cast mc).smc;
		if (smc != null)
		{
			var f : flash.display.MovieClip = smc._hit;
			if ( f != null)
				return f.getRect( game.level.getRoot() );
		}
		
		return super.getRect();
	}
	
	public function getLogCenter()
	{
		var r = getRect();
		return { x:r.x + r.width * 0.5, y:r.y + r.height * 0.5 };
	}
	
	
	static var colTrans = new flash.geom.ColorTransform();
	static var bisColTrans = 
	{
		var c = new flash.geom.ColorTransform();
		c.mul( .2, .2, .2);
		c.ofs(50, 50, 50);
		c;
	}
	
	
	public override function restage()
	{
		var l = game.level;
		switch(type)
		{
			default: l.dm.add( mc , Level.CHAR_DEPTH); 
			case NT_SWARM:			
				if ( swarmToBg && mc.parent == null) 
					l.dm.add( mc , Level.PRE_SWARM_DEPTH); 
				else 
					l.dm.add( mc , Level.CHAR_DEPTH); 
			case NT_TORCH,NT_BLADE: 	
				if ( mc.parent == null )
				{
					l.dumpDl();
					l.dm.add( mc , Level.DANGER_DEPTH); 
					l.dumpDl();
				}
			
		}
		
		
	}
	
	public var uid:Int = 0;
	
	
	public function init( t : NMY_TYPE, cx, cy , d = 1.0)
	{ 
		move(0, 0);
		life = 0;
		badState = NBD_IDLE(40);
		massState = STALLED;
		swarmState = STALLED;
		
		if ( cx == 0 && cy == 0)
			uid = Game.me.rd.random( 10001000 );
		else
			uid = (cx * 1337 + cy) ^ 0xdeadbeef;
		
		var mr = getMr();
		this.d = d;
		stop = false;
		
		
		function mkFlyer()
		{
			flags.unset(GRAVITY );
			flags.set(FLY );
		}
		
		type = t;
		switch( type  )
		{
			case NT_SWARM:
			mc = swarmPool.create();
			
			if ( Dice.percent( mr, 40 ) )
			{
				swarmToBg = true;
				aggro = false;
				mc.transform.colorTransform = bisColTrans;
				mc.alpha = 0.80;
			}
			else
			{
				swarmToBg = false;	
				mc.alpha = 1.0;
				aggro = true;
				mc.transform.colorTransform = colTrans;
			}
			
			mkFlyer();
			canBeKilled = false;
			canBeTarget = false;
			oscillate = true;
			flags.set( NO_COLLIDE );
			swarmState = TRACK_DEADLINE;
			invincible = true;
			instaKill = true;
			
			mr = getMr();
			var mc  = getMovieClip();
			var r = Dice.rollF( mr,0, 1.0);
			mc.scaleY = mc.scaleX = 2 * (r * r ) + 0.5;
			
			cy = Lib.nbch() * 2;
			cx = (mr.random( Lib.nbcw() ) + mr.random( Lib.nbcw() )) >>1;
			
			rx = 0.5;
			ry = 0.99;
			
			
			//move(cx, cy);
			if(swarmToBg) {
				mc.scaleX *= 0.33;
				mc.scaleY *= 0.33;
			}
			
			
			//#if debug
			//var sp = new Sprite();
			//sp.graphics.beginFill(0x00FF00);
			//sp.graphics.drawRect(0, 0, 10, 10);
			//sp.graphics.endFill();
			//mc.addChild( sp);
			//#end
			
			
			case NT_BAD_HANDLE,NT_HANDLE:
			var me = handlePool.create();
			
			if ( d >= 2.5 || type == NT_BAD_HANDLE )
			{
				type = NT_BAD_HANDLE;
				me.smc.gotoAndStop(2);
				aggro = true;
			}
			else
			{
				me.smc.gotoAndStop(1);
				aggro = false;
				cy--;
			}
			canBeKilled  = true;
			mc = me;
			mkFlyer();
			canBeTarget = true;
			oscillate = true;
			
			case NT_TORCH:
			mc = torchPool.create();
			instaKill = true;
			canBeKilled = false;
			flags.set(NO_COLLIDE);
			mkFlyer();
			
			case NT_BLADE:
			mc = bladePool.create();
			instaKill = true;
			canBeKilled = false;
			flags.set(NO_COLLIDE);
			flags.unset(GRAVITY);
			mkFlyer();
			
			case NT_MASSIVE:
			mc = massPool.create();
			instaKill = true;
			canBeKilled = false;
		}
		
		pause = false;
		
		mc.visible = true;
		spawnCell.set( cx, cy);
		move( cx, cy);
		
		update();
		syncPos();
		return this;
	}
	
	public override function syncPos() {
		super.syncPos();
		if (oscillate)
		{
			var v = Game.getFrame() * 0.05 + life * 0.05 + (uid * ((uid%2==0) ? 0.1 : -0.1));
			var s = Math.sin( v );
			mc.y += Math.abs( s ) * 4 / mc.scaleX;
		}
	}
	
	function getMr()
	{
		return new mt.Rand( Game.getSeed() + (Game.getFrame() * 44353) + uid  ); 
	}
	
	public function badMove()
	{
		var l = game.level;
		var mr = getMr();
		
		if( Dice.percent(mr,50 + d * 10) )
		{
			if ( Dice.percent( mr, 50 ))
			{
				if ( !l.testColl( cx + 1, cy ))
				{
					badState = NBD_WANDER( cx + 1, cy );
					return;
				}
			}
			else 
			{
				if ( !l.testColl( cx - 1, cy ))
				{
					badState = NBD_WANDER( cx - 1, cy );
					return;
				}
			}
		}
		
		badState = NBD_GOTO_ANCHOR;
	}
	
	public function update()
	{
		if ( mc.parent == null)							restage();
		if ( mc.parent == null || game.char == null) 	return;
		
		var lev = game.level;
		if (lev == null) return;
		if ( pause) return;
		
		life++;
		
		stop = true;
		var mr = getMr();
		switch(type)
		{
			default:
				
			case NT_BAD_HANDLE:
					
				var period = ((uid * 1984) ^ (0xdeaddead)) + life ;
				var s = (uid % 2 == 0) ? 1 : - 1;
				var mag = d;
				var f :Float -> Float= function(r) return r*r;
				
				var lbd = 40 * Std.int(d+0.5);
				var p = MathEx.posMod(period, 5 * lbd);
				//trace(p);
				if ( p < 1 * lbd )//stay still
				{
					
				}
				else if( p < 2 * lbd ) //go left
				{
					var r = (p % lbd) / lbd;
					r = MathEx.clamp( r , 0., 1.);
					var ncx = spawnCell.x - f(s * mag * r); 
					
					cx = Std.int(ncx);
					rx = ncx - cx;
				}
				else if( p < 3 * lbd ) // go center
				{
					var r = 1.0 - ((p % lbd) / lbd);
					r = MathEx.clamp( r , 0., 1.);
					var ncx = spawnCell.x - f(s * mag * r); 
					
					cx = Std.int(ncx);
					rx = ncx - cx;
				}
				else if( p < 4 * lbd ) // go right
				{
					var r = (p % lbd) / lbd;
					r = MathEx.clamp( r , 0., 1.);
					var ncx = spawnCell.x + f(s * mag * r); 
					
					cx = Std.int(ncx);
					rx = ncx - cx;
				}
				else if( p < 5 * lbd ) // go center
				{
					var r = 1.0 - ((p % lbd) / lbd);
					r = MathEx.clamp( r , 0., 1.);
					var ncx = spawnCell.x + f(s * mag * r); 
					
					cx = Std.int(ncx);
					rx = ncx - cx;
				}
				
				if ( cx < 1 ) { cx = 2; rx = 0.0; };
				if ( cx > Lib.nbcw() - 1 ) { cx = Lib.nbcw() - 1; rx = 0; };
					
			case NT_MASSIVE:
				switch(massState)
				{
					case STALLED:
						massState = THINKING( 60 );
					case THINKING(n):
						if ( n == 1 )
						{
							var grMinx = cx;
							
							while (game.level.testColl(grMinx, cy+1) && grMinx >= 1)
								grMinx--;
							grMinx++;
							
							if ( grMinx < 2 )
								grMinx = 2;
								
							var grMaxx = cx+1;
							while (game.level.testColl(grMaxx, cy+1) && grMaxx < Lib.nbcw())
								grMaxx++;
							grMaxx--;
								
							var f = Dice.roll( mr,grMinx, grMaxx );
							for ( i in 0...5)
								if ( f == cx )
									f = Dice.roll( mr,grMinx, grMaxx );
							massState = GOTO(f);
							getMovieClip().gotoAndStop(2);
						}
						else
							massState = THINKING(n - 1);
						
					case GOTO(x):
					{
						var fx = cx + rx;
						
						if ( x < fx )
						{
							rx -= 0.15;
							fx = cx + rx;
							if ( x >= fx )
							{
								cx = Std.int(x);
								rx = x - cx;
								massState = STALLED;
								getMovieClip().gotoAndStop(1);
							}
							else
								mc.scaleX = 1;
						}
						else 	
						if ( x > fx )
						{
							rx += 0.15;
							fx = cx + rx;
							if ( x <= fx )
							{
								cx = Std.int(x);
								rx = x - cx;
								massState = STALLED;
								getMovieClip().gotoAndStop(1);
							}
							else
								mc.scaleX = -1;
						}
						else
						{
							massState = STALLED;
							getMovieClip().gotoAndStop(1);
						}
					}
				}
		
			
			case NT_SWARM:
				var deathy =  game.level.getD();//in c unit ?
				
				//#if !debug
				mc.visible = Math.abs( game.char.cy - cy ) <= Lib.nbch();
				//#end
				//trace(cx + " " + cy);
				
				switch(swarmState)
				{
					default:
					case TRACK_DEADLINE:
						if ( Math.abs( game.char.cy - cy ) <= 4 && aggro == true )
						{
							swarmState = SWARM_PLAYER;
							oscillate = false;
						}
						else
						{
							if ( deathy <= getFy()  )
							{
								//swarmState = getFx() + Dice.roll( - 3.0, 3.0 );
								//take a guess near deadline 
								var kx : Int = cx;
								var ky : Int = Std.int( deathy ); 
								
								for ( i in 0...8)
								{
									var d = 0;
									if (swarmToBg)
										d = 15;
										
									var m = -4;
									if ( kx <= 2 ) m = 0;
									var ckx : Int = kx + Dice.roll( mr,m, 4 );
									
									if ( ckx < 2 ) ckx = 2;
									if ( ckx > Lib.nbcw()) ckx = Lib.nbcw()-1;
									
									var cky : Int = ky - Dice.roll( mr,-10 , 5  );
									cky -= d;
									
									if ( lev.getNmyXY( NT_SWARM,ckx, cky,this ) == null)
									{
										kx = ckx;
										ky = cky;
										break;
									}
								}
								swarmState = NSS_GOTO( kx, ky);
							}
						}
						
					case NSS_GOTO(lx, ly):
					{
						var spl = 0.95;
						if( (Math.abs(cx - lx) + Math.abs(cy - ly)) <= 2  )
							swarmState = TRACK_DEADLINE;
						else
						{
							moveF( 	getFx() * spl + lx * (1-spl), 
									getFy() * spl + ly * (1-spl));
						}
					}
						
					case SWARM_PLAYER:
					{
						var spl = 0.8 + 0.1 / mc.scaleX;
						moveF( 	getFx() * spl + game.char.getFx() * (1-spl), 
								getFy() * spl + game.char.getFy() * (1 - spl));
								
						if( !Game.isLowQuality())
							new fx.Shade(mc, 10, 0x00CDFF);
					}
				}
				
			case NT_BLADE:
				var ch : CachedMc = cast mc;
				//ch.cursor = 2.0;
				ch.update(1.0);
		}
		
		updatePhy();
		syncPos();
	}
	
	public override function onDestroy()
	{
		aggro = false;
		
		var p = mc.parent;
		var v : mt.fx.Vanish = new mt.fx.Vanish(mc);
		v.setFadeBlur(10, 10);
		v.fadeAlpha = true;
		
		switch(type )
		{
			case NT_HANDLE, NT_BAD_HANDLE:
			canBeTarget = false;
			v.onFinish = function()
			{
				mt.gx.time.FTimer.delay( function()
				{
					canBeTarget = true;
					canBeKilled = true;
					stop = false;
					pause = false;
					if ( type == NT_BAD_HANDLE) {
						FTimer.delay( function(){
						aggro =  true;
						},20);
					}
					pv = 1;
					mc.alpha = 1;
					mc.filters = [];
					p.addChild( mc );
					new mt.fx.Spawn( mc );
					game.level.nmy.get( type ).push( this );
				}, 40 * 5 );
			}
			
			default:
			v.onFinish = function() this.onDispose();	
		}
			
		
		var p = game.level.data.playFX("teleportStart");
		var r = getRect();
		p.x = r.x;
		p.y = r.y;
	}
	
	public override function onDispose()
	{
		super.onDispose();
		game.level.tasks.pushBack( function()
		{
			mc.visible = false;
			game.level.nmy.get( type ).remove( this );
			
			switch( type )
			{
				case NT_SWARM: 					swarmPool.destroy( cast mc );
				case NT_BAD_HANDLE,NT_HANDLE:	handlePool.destroy( cast mc );
				case NT_TORCH:					torchPool.destroy( cast mc );
				case NT_BLADE:					bladePool.destroy( cast mc );
				case NT_MASSIVE : 				massPool.destroy( cast mc );
			}
			
			mt.gx.as.Lib.detach(mc);
			mc = null;
			badState = NBD_IDLE(40);
			massState = STALLED;
			swarmState = STALLED;
			return true;
			}
		);
	}
	
	public function getMovieClip() : MovieClip
	{
		return cast mc;
	}
}