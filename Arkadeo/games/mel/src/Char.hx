import api.AKApi;
import DefaultImport;

import flash.display.Shape;
import flash.display.BlendMode;
import flash.display.FrameLabel;
import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.filters.GlowFilter;
import mt.gx.math.Vec2;
import mt.gx.MathEx;
import mt.gx.Pool;

import mt.deepnight.Tweenie;
import Data;

import Nmy;


import fx.SMS;
using mt.gx.Ex;
/**
 * ...
 * @author de
 */
enum CharState
{
	SPAWN;
	
	WANDER_STAND;
	WANDER_RUN;
	
	JUMP;
	FALL;
	DOUBLE_JUMP;
	
	WALL_STICK;
	WALL_JUMP;
	
	KICK_JUMP;
	
	TEST;
	
	CROUCH;
	CROUCH_STUCK;
	FORCE_CROUCH;
	PAUSE;
	
	TOLERANT_FALL;
}

typedef FrameLabelExt = { frame:Int, name:String, prev:FrameLabel, next:FrameLabel, dur:Int, lastFrame : Int };

class TargetedShape extends gfx.MovementFX,implements haxe.Public
{
	var nmy : Nmy;
	var char : Char;
	
	function new ()
	{
		super();
		gotoAndStop( "target" );
	}
	
	public var game(get, null) : Game; function get_game() return Game.me
	
	function init(c,e)
	{
		char = c;
		nmy = e;
		
		var lvl = game.level;
		
		lvl.dm.add( this , Level.CHAR_DEPTH);
		///mt.gx.as.Lib.toFront( this);
		
		scaleX = scaleY = 3.5;
		
		game.tweenie.create( this, "scaleX", 1, TType.TElasticEnd,425);
		game.tweenie.create( this, "scaleY", 1, TType.TElasticEnd,425);
		
		e.nmyFlags.set( NMY_FLAGS.ACQUIRED);
		
		update();
	}
	
	function update()
	{
		mt.gx.Debug.assert(nmy.mc != null );
		var xy = nmy.getLogCenter();
		
		if ( xy == null)
		{
			x = nmy.mc.x /*+ nmy.mc.width*.5*/;
			y = nmy.mc.y /*+ nmy.mc.height*.5*/;
		}
		else
		{
			x = Std.int( xy.x );
			y = Std.int( xy.y );
		}
	}
	
	function destroy() {
		if(nmy != null)
			nmy.nmyFlags.unset( ACQUIRED );
		
		if (parent != null ) 
			parent.removeChild( this );
			
		game.char.targets.destroy( this );

		nmy = null; 
		char = null;
	}
}


enum CharFlags 
{
	FOCUSED;
	STICK_2_JUMP;
}



class Char extends Entity, implements haxe.Public
{
	var nmyKilled = 0;
	
	var godMode 	= false;
	var state 		: CharState;
	var me 			: gfx.Hero;
	var stateLife	: Int;
	var jumpEscaped = false;
	var tasks 		: List < Void->Bool > ;//true means remove me
	
	var grid 		: flash.display.Shape;
	var cl 			: flash.geom.ColorTransform;
	//var charPostFx 	: flash.display.Bitmap;
	
	var targets		: Pool<TargetedShape>;
	var kickData 	: { locked : Nmy, angle : Float, dist : Float };
	var flagsExt 	: haxe.EnumFlags<CharFlags>;
	
	var blinkTimer 	: Int;
	var crouchGauge : Float = 0.0;
	var input = true;
	
	var powers 		: haxe.EnumFlags<CharPowers>;
	var shadowPow 	: Int = 0;
	var hits	 	: Hash<flash.geom.Rectangle>;
	
	static inline var MAX_JUMP_SPEED = -0.7;
	function new()
	{
		super();
		mc = me = new gfx.Hero();
		powers = haxe.EnumFlags.ofInt(0);
		
		tasks = new List();
		targets = new mt.gx.Pool(function() return new TargetedShape() );
		
		
		changeState(SPAWN);
		move( Lib.nbcw() >> 1, Lib.nbch() - 1 );
		
		if ( Level.GRID)
		{
			grid = new Shape();
			var g = grid.graphics;
			g.lineStyle(0.03, 0xFF00FF,0.3);
			for ( y in 0... Lib.nbch())
			{
				g.moveTo( 0, y*16 );
				g.lineTo( Lib.nbcw()*16, y*16);
			}
			
			for ( x in 0... Lib.nbcw())
			{
				g.moveTo( x*16, 0 );
				g.lineTo( x*16, Lib.nbch()*16);
			}
			
			grid.blendMode = flash.display.BlendMode.ADD;
			game.level.dm.add(grid, Level.FX_DEPTH);
		}
		
		cl = new flash.geom.ColorTransform();
		me.transform.colorTransform = cl;
		
		flagsExt = haxe.EnumFlags.ofInt(0);
		
		pv = 2;
		#if debug pv = 10; #end
		if ( Game.isLeague())
			powers.set(CP_DOUBLE_JUMP);
			
		hits  = new Hash<flash.geom.Rectangle>();
		
		#if ide
		for ( l in me.currentLabels)
		{
			me.gotoAndStop( l.name );
			var smc : { _hit : MovieClip } = cast me.smc;
			var rect = smc._hit.getRect(me.smc);
			hits.set( l.name,  rect);
			//trace(l.frame + " " + l.name+ " " +rect);
			//trace( "hits.set( '" + l.name + "',  new flash.geom.Rectangle("+rect.x+","+rect.y+","+rect.width+","+rect.height+")*);" );
		}
		
		//powers.set( CP_KICK );
		//powers.set( CP_SUPER_JUMP );
		//powers.set( CP_WALL_STICK );
		//powers.set( CP_CANCEL );
		#else
		hits.set( 'stand',  new flash.geom.Rectangle(-10,-60,20,59.8));
		hits.set( 'walk',  new flash.geom.Rectangle(-2,-60,20,59.8));
		hits.set( 'jump',  new flash.geom.Rectangle(-9,-52.9,20,48.9));
		hits.set( 'doubleJump',  new flash.geom.Rectangle(-11.1,-26.4,22.6,23.7));
		hits.set( 'grip',  new flash.geom.Rectangle(-21.05,-36.85,22.1,45));
		hits.set( 'crouch',  new flash.geom.Rectangle(-9,-49.85,20,49.9));
		#end
	}
	
	public function destroy() {
		me.detach();
		me = null;
		
		tasks = null;
		grid.detach();
		
		grid = null;
		cl = null;
		//charPostFx
		targets.kill();
		targets = null;
		
		kickData = null;
		
		
	}
	
	static var mrect = new flash.geom.Rectangle();
	
	override function getRect() : flash.geom.Rectangle
	{
		var r = hits.get( me.currentLabel );
		mrect.x = r.x + me.x;
		mrect.y = r.y + me.y;
		mrect.width = r.width;
		mrect.height = r.height;
		
		return mrect;
	}
	
	var gr : fx.Greyscale = null;
	public override function onDestroy()
	{
		game.pause = true;
		mt.gx.as.Lib.stopAllAnimation( (cast game.root) );
		changeState(PAUSE);
		gr = new fx.Greyscale(); 
		gr.setStrengthBloom( 0 );
		mt.gx.time.FTimer.tick( function(r) 
		{
			gr.setStrengthBloom( r);
			Game.me.filters = [gr.get()];
			
			if ( r >= 0.99 && !game.level.gameOverCalled)
			{
				#if !ide
					game.level.gameOverCalled = true;
					api.AKApi.gameOver(false);
				#end
			}
		}, 40 );
	}
	
	function getMeter()
		return  (-(cy + ry) + Lib.nbch()) / 3.0
	
	function getAbsCy()
		return  (-(cy + ry) + Lib.nbch())
	
	function mkCl()
		me.transform.colorTransform = cl
	
	var pcxy = -1;
	function update()
	{
		//if ( Level.GRID)		grid.y = ((Std.int(mc.y) << 4) >> 4) - (Lib.ph()>>1);
		if ( Level.GRID)		grid.y =- game.view.y;
		
		
		var l = lev();
		
		stateLife++;
		updateState();
			
		if(tasks.length>0)
		for (t in tasks)
			if ( t() )
				tasks.remove(t);
				
		syncPos();
		
		if ( cy * 255 + cx != pcxy)
			pcxy = cy * 255 + cx;
			
		
		if ( blinkTimer > 0)
		{
			blinkTimer--;
			blinkFrame(blinkTimer);
			
			if ( blinkTimer == 0)
			{
				cl.ofs(); cl.mul(); mkCl();
				blinkTimer = -1;
			}
		}
		
		if ( shadowPow > 0 )
			if ( MathEx.posMod( Game.getFrame(), 2) == 0 )
			{
				var r = (state == DOUBLE_JUMP && stateLife > CANCEl_SL && powers.has(CP_CANCEL )) ? 0xFF1108 : 0xFFAA2A;
				
				if( !Game.isLowQuality() )
					new fx.Shade2( me, 6,  r);
			}
			
				
		
		//if( dy != 0 )trace(dy);
	}
	public var tolerance = 3;
	
	public function onTakeKdo(kd : KdoDef)
	{
		if ( kd == null ) return;
		
		var c = switch(kd.frame)
		{
			case 1: 0xAFFC0C;
			case 2: 0xFFBB00;
			case 3: 0x1BFFFF;
			case 4: 0xFFB9F5;
		};
		
		var kdp = kd.mc.getRect( game.level.getRoot());
		new fx.SMS(Data.getSmsKdo());
			
		var rd = Game.me.rd;
		var spr  = 14;
		for ( i in 0...6)
		{
			var sp = new flash.display.Sprite();
			var gfx = sp.graphics;
			gfx.beginFill(c);
			gfx.drawCircle(0,0,1.5);
			gfx.endFill();
			
			gfx.beginFill(c,0.25);
			gfx.drawCircle(0,0,6);
			gfx.endFill();
			
			var p = new mt.fx.Part(sp);
			p.timer = 22;
			p.fadeLimit = 10;
			p.fadeType = 2;
			
			p.x = kdp.x + kdp.width * 0.5 + Dice.rollF( rd,-spr,spr);
			p.y = kdp.y + kdp.height * 0.5 + Dice.rollF( rd,-spr,spr); 
			p.vy = -3;
			p.frict = Dice.rollF( rd,0.85, 0.95);
			p.sfr = 0.99;
			p.fadeIn( Dice.roll( rd, 2, 8 ) );
			p.sleep( Dice.roll( rd,0, 3));
			
			p.alpha = 0.8;
			
			game.level.dm.add( sp,Level.FX_DEPTH );
		}
		
		#if !ide
		mt.gx.Debug.assert( kd.tok.score.get() <= game.score,kd.tok.score.get()+"<>"+ game.score);
		AKApi.takePrizeTokens( kd.tok );
		#end
	}	
	
	function blinkFrame(bt)
	{
		var t = 7;
		switch(bt%t)
		{
			case 0,1,2	: cl.ofs(222, 122, 0); 	cl.mul(0, 0, 0);
			case 3,4	: cl.ofs(255,255,255); 	cl.mul();
			case 5,6	: cl.ofs(); 			cl.mul(); 
		}
		mkCl();
	}
	
	function blinkFrame2(bt)
	{
		var t = 8;
		switch(bt%t)
		{
			case 0,1,2,4,5	: 	cl.ofs(); 				cl.mul();
			case 6	: 			cl.ofs(255,255,255); 	cl.mul();
			case 7	: 			cl.ofs(222, 122, 0); 	cl.mul(0, 0, 0);
		}
		mkCl();
	}
	
	var wasSpace = false;
	var isSpace = false;
	var onSpace = false;
	
	function setDir() 
	{
		if ( dx < -0.001 )
			mc.scaleX = -1;
		else if ( dx > 0.001 )
			mc.scaleX = 1;
	}
	
	inline function goLeft() 
	{
		return 
		if ( dx < -  0.01 )
			-1;
		else 1;
	}
		
	function getPlayerDir():Float
	{
		var l = dx * dx + dy * dy;
		if ( l == 0)
			return 0;
		else
		{
			l = Math.sqrt(l);
			return  Math.atan2( dx / l, -dy / l);
		}
	}
		
	function updateKey()
	{
		if ( isDead() || game.level.gameOverCalled ) return;
		
		var lev = game.level;
		wasSpace = isSpace;
		isSpace = Game.isKeyDown( K.SPACE ) || Game.isKeyDown( K.CONTROL ) || Game.isKeyDown( K.UP );
		onSpace = isSpace && !wasSpace;
		
		switch(state)
		{
			case WALL_STICK:
			{
				if ( Game.isKeyDown( K.DOWN ) && !flagsExt.has(STICK_2_JUMP) && stateLife >= 4)
				{
					flags.unset(CAN_GRIP);
					changeState(FALL);
					return;
				}
					
				if ( onSpace && !flagsExt.has(STICK_2_JUMP))
				{
					changeState( WALL_JUMP );
					return;
				}
					
				if ( stateLife >= 10 && !flagsExt.has(STICK_2_JUMP) )
				{
					if( !lev.testColl(cx-1,cy-1) && lev.testColl(cx-1,cy) && Game.isKeyDown(K.LEFT ))
					{
						cx = cx - 1;
						cy = cy - 1;
						rx = 0.75;
						ry = 1;
						
						var f = game.level.data.playFX( "slash2" );
						f.x = mc.x;
						f.y = mc.y;
						
						changeState( CROUCH_STUCK );
						
						f.scaleX = 1;
						me.scaleX = 1;
					}
					
					if( !lev.testColl(cx+1,cy-1) && lev.testColl(cx+1,cy) && Game.isKeyDown(K.RIGHT ))
					{
						cx = cx + 1;
						cy = cy - 1;
						rx = 0;
						ry = 1;
						
						var f = game.level.data.playFX( "slash2" );
						f.x = mc.x;
						f.y = mc.y;
						
						changeState( CROUCH_STUCK );
						
						f.scaleX = -1;
						me.scaleX = -1;
					}
					
					return;
				}
			}
			case TOLERANT_FALL:
				if( onSpace )
					changeState( JUMP );
					
			case WANDER_RUN, WANDER_STAND:
				fx = 0.65;
				var incr = 0.225;
				var s = 0.750;
				
				var r = Math.abs(dx) / s;
				
				//mcd.freq = Std.int(0.5 + 1.0 / r);
				//mcd.freq = 100;
				
				if ( stateLife <= 2 )
					incr *= 0.5;
				
				var odx = dx;
				
				if ( Game.isKeyDown( K.LEFT ) )
					dx -= s*incr;
				else if ( Game.isKeyDown( K.RIGHT ) )
					dx += s * incr;
					
				if ( Math.abs(dx) > 0.01 && !MathEx.sameSign( odx, dx ) )
				{
					var m = game.level.data.playFX( "runChange" );
					m.x = me.x; m.y = me.y;
					m.scaleX = goLeft();
				}
				
				if ( isSpace )//onSpace
				{
					changeState( JUMP );
				}
				else
				{
					if ( dx > s )
						dx = s;
					if ( dx < -s)
						dx = -s;
						
					if ( Math.abs( dx ) > 0.01)
					{
						if ( state != WANDER_RUN )//lessen the startup fuzz
						{
							//rx += goLeft() * 0.125;
							changeState( WANDER_RUN );
						}
					}
					else
					{
						if ( Game.isKeyDown( K.DOWN ) && powers.has(CP_SUPER_JUMP) )
						{
							dx *= 0.1;
							changeState(CROUCH);
						}
					}
					
					setDir();
				}
				
			case DOUBLE_JUMP:
				var jinc = 0.2;
				var dj = 0.5;
				if ( Game.isKeyDown( K.LEFT ) )
				{
					dx -= dj * jinc;
					if ( dx < -dj) dx = -dj;
				}
				else if ( Game.isKeyDown( K.RIGHT ) )
				{
					dx += dj * jinc;
					if ( dx > dj) dx = dj;
				}
			
			case  FALL, JUMP:
				fx = 0.68; 
				var jinc = 0.125;
				var sj = 0.525;
				
				
				if ( Game.isKeyDown( K.LEFT ) )
				{
					dx -= sj * jinc;
					
					if ( dx < -sj)
						dx = -sj;
				}
				else if ( Game.isKeyDown( K.RIGHT ) )
				{
					dx += sj * jinc;
					
					if ( dx > sj)
						dx = sj;
				}
				
				if (state == JUMP)
				{
					if ( !isSpace && ! jumpEscaped )
					{
						if( dy < 0) dy = Math.max(MAX_JUMP_SPEED * 0.5,dy);
						jumpEscaped = true; 
					}
					
					if ( onSpace && jumpEscaped && powers.has(CP_DOUBLE_JUMP)) 
					{
						changeState( DOUBLE_JUMP );
						return;
					}
				}
				else
					if ( onSpace && powers.has(CP_DOUBLE_JUMP) )
					{
						changeState( DOUBLE_JUMP );
						return;
					}
					
				if ( Game.isKeyToggled( K.DOWN ) && powers.has(CP_KICK))
				{
					makeAcquisition();
					
					var acqs = targets.getUsed();
					
					var min = null;
					for( a in acqs )
					{
						if ( min == null) min = a ;
						else
						{
							if ( 	MathEx.dist2( mc.x, mc.y, a.x, a.y ) 
							< 		MathEx.dist2( mc.x, mc.y, min.x, min.y )) 
								min = a;
						}
					}
					
					var acq = min;
					if ( acq !=null)
					{
						var mrx = cx + rx;
						var mry = cy + ry;
						
						var lck = acq.nmy;
						
						acq.destroy();
						
						var lrx = lck.mc.x;
						var lry = lck.mc.y;
						 
						var a = Math.atan2( mry-lrx,mrx-lry);
						var d = Math.sqrt((mrx - lrx) * (mrx - lrx) + (mry - lry) * (mry - lry));
						
						kickData = { locked : lck, angle : a, dist : d };
						changeState( KICK_JUMP );
					}
				}
				
					
			case CROUCH:
				//SUPER_JUMP
				if ( onSpace )
				{
					var f = getCrouchFocus();
					changeState( JUMP );
					jumpEscaped = true;//cancel jump kill
					dy *= f;
					shadowPow++;
					
					mt.gx.time.FTimer.delay( function() shadowPow--, 10);
				}else
				if ( !Game.isKeyDown( K.DOWN ))
					changeState( WANDER_RUN );
		
			
					
			default:
		}
	}
	
	function focusMax()
	{
		if ( !flagsExt.has(FOCUSED ))
		{
			var g = new flash.filters.GlowFilter( Data.ORANGE, 0.9666, 3, 3, 10);
			me.filters = [ g ];
		}
		flagsExt.set(FOCUSED);
	}
	
	function defocus()
	{
		crouchGauge = 0;
		cl.rst();
		mkCl();
		
		me.filters = me.filters.filter( function(f) 
		{
			if ( Std.is(f, GlowFilter)) 
			{
				var a : flash.filters.GlowFilter = cast f;
				return !MathEx.eq( a.alpha, 0.9666, 0.01);
			}return true;
		}).array();
		flagsExt.unset(FOCUSED);
	}
	
	static inline var crMin = 0.6;
	static inline var crMax = 1.40;
	static inline var crD = 80;
	
	function getCrouchFocus() : Float
		return crMin + ( getCrouchRatio() * (crMax - crMin) )
	
	function onColl(e : Nmy ) : Bool
	{
		
		if ( !e.aggro ) return false; 
		
		if ( godMode ) return false;
		
		switch(state)
		{
			
			//hurt self
			case KICK_JUMP :
				return false;
				
			default:
				if( e.type != NT_SWARM )
					hurt( 1 );
				else	
					hurt(10);
				return false;
				
			case DOUBLE_JUMP:
			{
				if (e.canBeKilled)
				{
					var r = e.hurt(1);
					changeState(JUMP);
					return r;
				}
				else if( e.instaKill )
				{
					if( e.type != NT_SWARM )
						hurt( 1 );
					else	
						hurt(10);
					return false;
				}
				else return false;
			}
		}
	}
	
	static inline var crouch_max = 40 * 1.5;
	function getCrouchRatio() : Float
		return MathEx.clamp( stateLife / crouch_max, 0 , 1)
	
	static inline var lock_dist = 10 * 10;
	
	var jumpSceneLabels : Hash<FrameLabelExt>;
	
	function updateState()
	{
		switch(state)
		{
			case SPAWN: 	changeState( WANDER_STAND );
			case KICK_JUMP:
			
			if (kickData == null) return;
			
			var kd = kickData;
			var lck = kickData.locked;
			lck.stop = true;
			
			function ha(  )
			{
				var a = kd.angle;
				var pivot = -Math.PI / 2;
				var racc = 0.25;
				if ( a > pivot)	a = pivot + (a - pivot) *racc;
				else	a = (pivot - a ) * racc +  a;
				return a;
			}
			switch( stateLife )
			{
				case 1: //disappear
				{
					if ( !Game.isLowQuality() ){
						var m = game.level.data.playFX("targetExplode");
						var c = lck.getLogCenter();
						m.x = c.x;
						m.y = c.y;
					}
					
					lck.pause = true;
					me.visible = false;
					me.gotoAndStop( "jump" );
					me.smc.gotoAndStop( 'init' );
					
					dx = 0;
					dy = 0;
				}
				
				case 6:
				{
					dx = 0;
					dy = 0;
					me.visible = true;
					cx = lck.cx; cy = lck.cy;
					ry = lck.ry /*- 0.3*/; rx = lck.rx;
					
					var lrx = lck.mc.x;
					var lry = lck.mc.y;
					
					if ( !Game.isLowQuality() ){
						var m = game.level.data.playFX("teleport");
						var c = lck.getLogCenter();
						m.x = c.x;
						m.y = c.y;
						m.scaleX = -1;
						m.rotationZ = MathEx.RAD2DEG * (kd.angle+Math.PI);
					}
					
					var a = ha();
					var fx = Math.cos( a ); var fy = Math.sin( a );
					
					var tx = fx;
					var ty = fy;
					moveF( cx + rx + tx, cy + ry + ty);
					flags.unset(GRAVITY );
					flags.set(FLY);
					
					me.smc.gotoAndStop( "sideKick" );
				}
				
				case 22:
				{
					var a = ha();
					var fx = Math.cos( a );
					var fy = Math.sin( a );
					
					var intensX = MathEx.clamp( (kd.dist * 0.55) , 1.25, 2.5 );
					var intensY = MathEx.clamp( (kd.dist * 0.33) , 0.9, 1.1 );
					
					dx = fx * 0.4 * intensX;
				
					lck.hurt( 1 );
					lck.pause = true;
					
					invincible = false;
					flags.unset(FLY);
					flags.set(GRAVITY);
					me.smc.gotoAndStop( "init" );
					changeState(JUMP);
					dy = MAX_JUMP_SPEED * 1.1 * intensY;
					jumpEscaped = true;
					kickData = null;
				}
			}
			
			case TOLERANT_FALL:
					if( stateLife > tolerance )
						changeState( FALL );
			case CROUCH_STUCK:
				if ( me.smc.isPlaying ) me.smc.stop();
				
				me.smc.prevFrame();
				me.smc.prevFrame();
				
			default:
		}
		
		if(input) updateKey();
		updatePhy();
		
		switch(state)
		{
			
			case WANDER_RUN:
				if ( Math.abs(dx) <= 0.015 )
					changeState( WANDER_STAND );
					
			case FORCE_CROUCH,CROUCH:
				if( getCrouchRatio() >= 0.99  )
				{
					crouchGauge = 0;
					cl.rst();
					mkCl();
					
					focusMax();
				}
				else
				{
					crouchGauge += getCrouchRatio() * 0.0125;
					var fr = Std.int(crouchGauge * crD);
					blinkFrame2(fr);
				}
				
			case JUMP:
				if( powers.has(CP_KICK))
					makeAcquisition();
				
				if ( jumpSceneLabels == null )
				{
					jumpSceneLabels = new Hash<FrameLabelExt>();
					
					var cl = me.smc.currentScene.labels;
					for ( i in 0...cl.length)
					{
						var l  =  cl[i];
						
						var prev = ( i == 0 ) ? null : cl[i - 1];
						var next = ( i == cl.length - 1 ) ? null : cl[i + 1];
						var dur = (next == null) ? (me.smc.totalFrames - 1) - l.frame : next.frame - l.frame;
						
						var f = { frame:l.frame, name:l.name,
							prev : prev,
							next : next,
							dur : dur,
							lastFrame : l.frame+dur,
							};
							
						jumpSceneLabels.set(l.name, f );
					}
				}
				
				var smc = me.smc;
				var labels = smc.currentLabels;
				var l = 0.1;
				switch( smc.currentLabel)
				{
					case "init":
					{
						var elem = jumpSceneLabels.get( "init" );
						var n = elem.next;
						
						if ( smc.currentFrame == n.frame - 1)
						{
							if ( dx < -l ) 		smc.gotoAndPlay( "initLeft");
							else if ( dx > l)	smc.gotoAndPlay( "initRight");
						}
					}
					
					case "initLeft","loopLeft":
					{
						smc.stop();
						
						if ( dx > -l )	smc.prevFrame();
						else			smc.nextFrame();
					}
					
					case "loop":
					{
						var jsl = jumpSceneLabels.get('loop');
						
						if ( dx > -l && dx < l )
							smc.play();
						else {
							if ( dx <= -l )
								smc.gotoAndPlay('initLeft');
							else  if( dx >= l)
								smc.gotoAndPlay('initRight');
						}
					}
					
					case "initRight", "loopRight":
					{
						smc.stop();
						
						if ( dx < l)	smc.prevFrame();
						else			smc.nextFrame();
						
						if ( smc.currentFrame == jumpSceneLabels.get( "initRight" ).frame-1)
						{
							var lbl = jumpSceneLabels.get("loop");
							var tgt = lbl.frame + lbl.dur;
							
							while ( smc.currentFrame != tgt )
								smc.prevFrame();
						}
					}
					
					default:
				}
			default:
		}
		
		if ( state !=  JUMP )
			cleanAcquisition();
			
		
		if ( state ==  DOUBLE_JUMP )
			if (stateLife > CANCEl_SL)
				if ( Game.isKeyDown( K.DOWN ) && powers.has(CP_CANCEL)) {
					scheduleRestoreGrip();
					changeState(FALL);
				}
	}
	
	public static inline var CANCEl_SL = 24;
	
	
	function cleanAcquisition()
	{
		if( targets.nbUsed() > 0)
			for ( t in targets.getUsed() )
				t.destroy();
	}
	
	function makeAcquisition()
	{
		function getD( e : Nmy )
			return MathEx.pow2i(cx - e.cx) + MathEx.pow2i(cy - e.cy);
			
		function hasPath( e : Nmy )
		{
			var hasColl = false;
			function t(x, y)
			{
				if ( lev().testColl(x, y))
					hasColl = true;
			}
			return !hasColl;
		}
		
		function isValid( e : Nmy )
		{
			if (e.mc == null) return false;
			var sameSide = (dx < 0 && e.cx < cx ) || (dx > 0 && e.cx > cx );
			var samePlace = (e.cy == cy && e.cx == cx );
			
			return
				sameSide
			&&	e.canBeTarget
			&& ((e.mc.y) >= (mc.y) )
			&&  getD(e ) <= lock_dist
			&& hasPath(e);
			
		}
				
		for( t in targets.getUsed() )
			if ( !isValid( t.nmy) )		t.destroy();
			else						t.update();
				
			
		for ( tl in game.level.nmy )
			for ( e in tl )
				if ( !e.nmyFlags.has(ACQUIRED) && isValid(e) )
				{
					var c = targets.create();
					c.init( this, e);
				}
				
	}
	
	override function onFall()
	{
		if ( state == KICK_JUMP ) return;
		
		if(state != WALL_STICK)
			changeState( TOLERANT_FALL );
	}
	
	override function onLand( dy )
	{
		if ( state == KICK_JUMP ) return;
		
		switch( state )
		{
			case CROUCH_STUCK, WANDER_STAND, FORCE_CROUCH:
				
			default:
				
			
			if ( dy > 0.74) 	
			{
				changeState(CROUCH_STUCK);
			}
			else 			
			{
				dx *= 0.25;
				setDir();
				changeState(WANDER_STAND);
			}
		}
	}
	
	
	function leaveState(s)
	{
		if (s == null) return;
		
		var lev = game.level;
		
		switch(s)
		{
			case FORCE_CROUCH,CROUCH:
				defocus();
			case KICK_JUMP:
				flags.unset(NO_COLLIDE);
				kickData = null;
				
			case WALL_STICK:
				oppy = 0; 
				me.scaleX = 1; 
				flags.unset(GRIPPED);
				flagsExt.unset(STICK_2_JUMP);
			case JUMP:
				//me.scaleX = dx < 0? -1:1;
				
			case DOUBLE_JUMP:
				shadowPow--;
			default:
		}
	}
	
	function scheduleRestoreGrip() {
		if( powers.has(CP_WALL_STICK)){
			var t = 5;
			tasks.pushBack( function()
			{
				t--;
				
				if ( t == 0 ){
					if( (state == JUMP || state == FALL) && powers.has(CP_WALL_STICK)) {
						flags.set( CAN_GRIP );
					}
					return true;
				}
				
				return false;
			});
		}
	}
	
	inline function lev() return game.level
	function changeState(ns:CharState)
	{
		leaveState( state);
		
		switch(ns)
		{
			case PAUSE: me.stop(); me.smc.stop();
			case TEST:
				me.gotoAndStop( "walk" );
				
				var inner : flash.display.MovieClip = cast me.getChildAt(0);
				for ( a in 0...inner.numChildren)
					if ( Std.is( a , flash.display.MovieClip) )
						(cast a).stop();
						
				
			case SPAWN:
				me.gotoAndStop( "stand" );
				
			case DOUBLE_JUMP:
				var acTrigBonus = 0.5;
				
				me.gotoAndStop( "doubleJump" );
				flags.set( GRAVITY );
				flags.unset( CAN_GRIP );
				
				dy = -0.45;
					
				if ( Game.isKeyDown( K.LEFT ))
					dx -= acTrigBonus;
				else if ( Game.isKeyDown( K.RIGHT ))
					dx += acTrigBonus;
					
				ry = 0.99;
				
				
				var m = game.level.data.playFX( "doubleJump" );
				m.x = me.x;
				m.y = me.y;
				m.rotation = getPlayerDir() * MathEx.RAD2DEG;
				shadowPow++;
				
			case WALL_JUMP:
				
				flags.unset( CAN_GRIP );
				scheduleRestoreGrip();
				
				if ( game.level.testColl( cx - 1, cy) )
					dx += 1.25;
				else
					dx -= 1.25;
				
				shadowPow++;
				mt.gx.time.FTimer.delay(
					function()
					{
						shadowPow--;
					}
					,10
				);
				
				changeState( JUMP);
				
				dy *= 0.75;
				return;
				
			case KICK_JUMP:
				invincible = true;
				flags.set(NO_COLLIDE);
				flags.unset(GRAVITY);
				
				dx = 0;
				dy = 0;
				var mc = game.level.data.playFX("teleportStart");
				mc.x = me.x;
				mc.y = me.y;
				
			case JUMP:
				me.gotoAndStop( "jump" );
				flags.set( GRAVITY );
				
				fx = 0.7;
				dy = -0.7;
				ry = 0.99;
				setDir();
				jumpEscaped = false;
				
				
			case TOLERANT_FALL,FALL:
				me.gotoAndStop( "jump" );
				flags.set( GRAVITY );
				
			case WANDER_RUN:
				me.gotoAndStop( "walk" );
				
				if (	!lev().testColl( cx -1, cy)
				&&		!lev().testColl( cx +1, cy) 
				 )
				{
					if ( Math.abs(dx) > 0.1)
					{
						var m = game.level.data.playFX("run");
						m.x = me.x;
						m.y = me.y;
						m.scaleX = goLeft();
					}
					setDir();
				}
				
			case WANDER_STAND:
				if( me.currentFrameLabel != "stand")
					me.gotoAndStop( "stand" );
				
				dy = 0;
				ry = 1;
				flags.unset( GRAVITY );
				if( powers.has(CP_WALL_STICK))
					flags.set(CAN_GRIP);
					
			case FORCE_CROUCH,CROUCH:
				me.gotoAndStop( "crouch" );
				
			case CROUCH_STUCK:
				me.gotoAndStop( "crouch" );
				me.smc.gotoAndStop( me.smc.totalFrames );
				me.smc.stop();
				dx = 0;
				dy = 0;
				
				
				mt.gx.time.FTimer.delay( 
					function()
					{
						changeState( WANDER_STAND );
					}, Std.int(me.smc.totalFrames / 2));
				
				
			case WALL_STICK:
				me.gotoAndStop( "grip" );
				flags.unset( GRAVITY );
				flags.set(GRIPPED);
				dx = 0;
				dy = 0;
				oppy = Entity.grav;
				
				var t = 100;
				tasks.pushBack( function()
				{
					if ( state != WALL_STICK)
						return true;
					t--;
					if ( t <= 0 )
					{
						flags.unset(CAN_GRIP);
						changeState(FALL);
						return true;
					}
					return false;
				});
		}
		stateLife = 0;
		state = ns;
	}
	
	
	override function onWallGrip(x:Int, y:Int)
	{
		if( powers.has( CP_WALL_STICK) )
			if ( state == FALL || state == JUMP )
			{
				if ( cx > x )
				{
					me.scaleX = -1;
					rx = 0;
				}
				else
				{
					rx = 1;
					me.scaleX = 1;
				}
				ry = 0.99;
				changeState( WALL_STICK);
			}
	}
	
	public override function hurt(v)
	{
		if ( godMode ) 
			return false;
		
		if ( Level.NO_KILL )
			return false;
			
		var b = super.hurt(v);
		if ( b == false )
		{
			godMode = true;
			
			game.addChild( game.level.data.bmpHit );
			mt.gx.time.FTimer.tick( function(r)
			{
				var rr = 1.0 - (r * r);
				game.level.data.bmpHit.alpha = rr;
				cl.alphaMultiplier = Math.sin( Game.getFrame() * 0.75 );
				if ( r >= 1.0)
				{	
					cl.alphaMultiplier = 1.0;
					godMode = false;
					game.filters = [];
					game.level.data.bmpHit.detach();
				}
				me.transform.colorTransform = cl;
			},80);
			game.ui.bar._blink.play();
		}
		return b;
	}
}
