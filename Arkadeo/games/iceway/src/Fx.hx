package ;

import Lib;
import mt.deepnight.Particle;

/**
 * Attention, MLib propose un random seedé dans ce jeu.
 * Par conséquent les appels à des randoms de MLib doivent etre dans une boucle fixe OU seedée elle aussi.
 */
class Fx
{
	public static var windForce : Float = 0.2;
	public static function initSnow()
	{
		var offset = 80; 
		Particle.DEFAULT_SNAP_PIXELS = false;
		Particle.WINDX = windForce;
		Particle.DEFAULT_BOUNDS = new Rectangle(-offset, -offset, Lib.STAGE_WIDTH+offset, Lib.STAGE_HEIGHT+offset);
		//
		var count = Std.int(api.AKApi.getPerf() * 25);
		for( i in 0...count )
		{
			Fx.makeSnowParticle(Math.random() * Lib.STAGE_HEIGHT);
		}
	}

	public static function spawnKdo(cx:Float, cy:Float, color : Int, delay = 50)
	{
		var ox = Game.me.gameContainer.x;
		var oy = Game.me.gameContainer.y;
		var count = Std.int(api.AKApi.getPerf() * 25);
		for( i in 0...count )
		{
			var p = new Particle(-ox + cx + Std.random(10), -oy + cy);
			p.delay = delay + Std.random(30);
			//p.drawCircle(5, color, 1 );
			p.drawCircle(2, color );
			p.life = 40;
			p.gy = -MLib.frandRange(0.05, 0.15);
			p.fl_wind = false;
			//Game.me.addChild(p);
			Game.me.dm.add(p, Game.DM_FX);
		}
	}
	
	public static function makeSnowParticle( ypos : Float, ?lifes=0 )
	{
		var ox = Game.me.gameContainer.x;
		var oy = Game.me.gameContainer.y;
		//
		var p = new Particle();
		var gfx = new gfx.Flocon();
		gfx.gotoAndPlay(1 + Std.random(gfx.totalFrames));
		p.addChild( gfx );
		p.blendMode = flash.display.BlendMode.SCREEN;
		var depth = lifes + Math.random() * 150;
		p.scaleX = p.scaleY = 3 * depth / 100;
		p.delay =  Std.random(100);
		p.setPos( -40 + Math.random() * (Lib.STAGE_WIDTH + 80) - ox, ypos - oy);
		p.gy = (.7 + .3 * Math.random()) * (depth);
		p.dr = 1 + (0.4*lifes);
		p.life = 1000;
		p.frictX = p.frictY = 0.01;
		p.onKill = callback(makeSnowParticle, -50, lifes++);
		Game.me.dm.add(p, Game.DM_FX);
	}
	
	public static function makeSnowDust( cx:Float, cy:Float, ground:Float )
	{
		var p = new Particle(cx, cy);
		p.addChild( new gfx.Eclat() );
		p.scaleX = p.scaleY = 0.4 + .8 * Math.random();
		p.rotation =  Std.random(360);
		p.life = 70 +  Std.random(100);
		p.dy = -(.5 + Math.random() * 3);
		p.dx = MLib.frandRangeSym(.5);
		p.bounce = 0.05;
		p.onBounce = function() { p.dx = 0; }
		p.fl_wind = false;
		p.groundY = ground;
		p.gy += 1;
		Game.me.dm.add(p, Game.DM_GROUND);
	}
	
	public static function kdoFound(cx:Float, cy:Float, color:Int)
	{
		var ox = Game.me.gameContainer.x;
		var oy = Game.me.gameContainer.y;
		//spawn particles
		var count = Std.int(api.AKApi.getPerf() * 10);
		for( i in 0...count )
		{
			var p = new Particle(cx - ox, cy - oy);
			p.delay = 0.1 * Math.random();
			var s = new gfx.Star();
			var ct = s.transform.colorTransform;
			ct.color = color;
			s.transform.colorTransform = ct;
			s.scaleX = s.scaleY = 0.5 + .5 * Math.random();
			p.addChild(s);
			p.life = 25;
			p.ds = 0.1;
			p.dr = 5;
			p.gy += 1;
			p.fl_wind = false;
			p.dy = MLib.randRange( -5, -12);
			p.dx = MLib.randRangeSym(5);
			Game.me.dm.add(p, Game.DM_FX);
		}
	}
	
}