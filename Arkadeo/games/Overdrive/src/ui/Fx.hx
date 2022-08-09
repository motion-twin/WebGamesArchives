package ui;
import anim.FrameManager;
import api.AKApi;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import mt.DepthManager;

import mt.deepnight.Particle;
import mt.deepnight.Lib;
import mt.deepnight.Color;

class Fx {
	
	static public var instance(default, null):Fx;
	
	var tick:Int;
	
	var lowq			: Bool;
	var lastMoveOrder	: Null<Particle>;
	var perf			: Float;
	var dm:DepthManager;
	
	var sandBD:BitmapData;
	var skullBD:BitmapData;
	var tireBD:BitmapData;
	var speedBD:BitmapData;
	var ODBD:BitmapData;
	//var shine:BitmapData;
	public static inline function noFx()
	{
		return AKApi.isLowQuality() || !Game.isRender;
	}
	
	public function new(dm:DepthManager) {
		this.dm = dm;
		lowq = api.AKApi.isLowQuality();
		
		Particle.LIMIT = lowq ? 30 : 150;
		#if debug
		Particle.LIMIT = 99999; // HACK
		#end
		
		sandBD = FM.getFrame("sand_4", Game.SHEET_ROAD);
		skullBD = FM.getFrame("skullBoss", Game.SHEET_ROAD);
		tireBD = FM.getFrame("tire_1", Game.SHEET_ROAD);
		ODBD = FM.getFrame("onde_1", Game.SHEET_ROAD);
		//shine = new BitmapData(40, 10, true, 0x00FF00FF);
		
		var s = new Sprite();
		s.graphics.beginFill(0xFFFFFF, rnd(0.3, 0.6));
		s.graphics.drawRect(0, 0, 2, Game.SIZE.height);
		s.graphics.endFill();
		s.filters = [ new flash.filters.BlurFilter(4, 8) ];
		var m = new Matrix();
		m.translate(4, 8);
		speedBD = new BitmapData(10, Game.SIZE.height + 16, true, 0x00FF00FF);
		speedBD.draw(s, m);
		s.filters = [];
		s = null;
		
		tick = 0;
		
		instance = this;
	}
	
	public function register(p:Particle, ?b:BlendMode, ?bg = false, layer:Int = -1) {
		if (layer == -1)	layer = Level.FX_DEPTH;
		dm.add(p, layer);
		p.blendMode = b!=null ? b : BlendMode.ADD;
	}
	
	inline function rnd(min,max,?sign) { return Lib.rnd(min,max,sign); }
	inline function irnd(min,max,?sign) { return Lib.irnd(min,max,sign); }
	
	public function smokeExplosion (x, y) {
		//return;
		for (i in 0...7) {
			var p = new Particle(x + rnd(0, 3, true), y + rnd(0, 3, true));
			p.drawCircle(rnd(7, 15), 0x000000, rnd(0.4, 0.7));
			
			if ( !noFx() ) 
				p.filters = [ new flash.filters.BlurFilter(4, 4) ];
			p.dx = rnd(1, 3, true);
			p.dy = rnd(3, 7);
			p.frictX = p.frictY = 0.96;
			p.life = rnd(3, 7);
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function paint (x, y) {
		//return;
		for (i in 0...7) {
			var p = new Particle(x + rnd(0, 3, true), y + rnd(0, 3, true));
			var col = switch (Std.random(4)) {
				case 0:	0xEB854A;
				case 1:	0xC6673D;
				case 2:	0x613B15;
				case 3:	0xB3B3B3;
			}
			p.drawBox(rnd(1, 4), rnd(4, 8), col, 1);
			p.dx = rnd(1, 3, true);
			p.dy = rnd(5, 7);
			p.dr = rnd(0, 10);
			p.frictX = p.frictY = 0.9;
			p.life = 10;
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function heal (x, y, c1:UInt = 0xCCCCFF, c2:UInt = 0x8080FF) {
		//return;
		var p = new Particle(x,y);
		var s = new Sprite();
		p.addChild(s);
		s.graphics.beginFill(c1, 0.5);
		s.graphics.drawCircle(0,0,50);
		s.graphics.drawCircle(0,0,25);
		s.graphics.endFill();
		
		if ( !noFx() ) 
			s.filters = [
				new flash.filters.BlurFilter(8,8),
				new flash.filters.GlowFilter(c2,1, 32,32,2)
			];
			
		p.scaleX = p.scaleY = 0.01;
		//p.delay = 4;
		var ds = 0.5;
		p.onUpdate = function() {
			p.scaleX+=ds;
			p.scaleY+=ds;
			ds *= 0.75;
		}
		p.onKill = function() {
			s.filters = [];
			p.removeChild(s);
		}
		p.life = 0;
		register(p);
	}
	
	public function smoke (x,y, col) {
	
		for( i in 0...2 ) {
			var p = new Particle(x + rnd(0, 3, true), y + rnd(0, 3, true));
			p.drawCircle(rnd(3, 5), col, rnd(0.4, 0.7));
			if ( !noFx() ) 
				p.filters = [ new flash.filters.BlurFilter(4,4) ];
			p.dx = rnd(0,0.5,true);
			p.dy = rnd(5,15);
			p.frictX = p.frictY = 0.96;
			p.life = rnd(5, 10);
			p.onKill = function() {
				p.filters = [];
			}
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function smokeRear (x,y, col) {
		//return;
		for( i in 0...1 ) {
			var p = new Particle(x + rnd(0, 3, true), y + rnd(0, 3, true));
			p.drawCircle(rnd(3, 5), col, rnd(0.1, 0.5));
			
			if ( !noFx() ) 
				p.filters = [ new flash.filters.BlurFilter(4, 4) ];
				
			p.dx = rnd(0,0.5,true);
			p.dy = rnd(5,10);
			p.frictX = p.frictY = 0.96;
			p.life = rnd(1, 5);
			p.onKill = function() {
				p.filters = [];
			}
			register(p, BlendMode.NORMAL);
		}
	}
	
	
	public function sandTex (x, y, side = 0, count:Int = 1, gray:Bool = false) {
		//return;
		for (i in 0...count) {
			Game.TAM.identity();
			Game.TAM.translate(-40, -36);
			var p = new Particle(x + rnd(0, 3, true), y + rnd(0, 3, true));
			var r = rnd(0, 1);
			//var m = 1 - 0.2 * r;//color multiplier
			//var o = 32 * r;//color offset
			//p.transform.colorTransform = new ColorTransform(m, m, m, 1, o, 0, o / 2);
			if (gray) {
				var ct = new ColorTransform();
				ct.color = 0xA59B83;
				p.transform.colorTransform = ct;
			}
			
			var b = new Bitmap(sandBD);
			b.x = -b.width / 2;
			b.y = -b.height / 2;
			p.addChild(b);
			//p.graphics.beginBitmapFill(sandBD, Game.TAM);
			//p.graphics.drawRect(-40, -36, 80, 72);
			//p.graphics.endFill();
			
			p.rotation = rnd(0, 360);
			//p.filters = [ new flash.filters.BlurFilter(rnd(0, 2), rnd(0, 2)) ];
			p.dx = rnd(0, 1, true);
			p.dy = rnd(5, 20);
			p.dr = rnd(3, 10) * side;
			p.frictX = p.frictY = 0.96;
			p.life = rnd(5, 10);
			register(p, BlendMode.NORMAL);
		}
	}
	
	
	public function grind (x:Float,y:Float, col, side) {
		//return;
		var p = new Particle(x + rnd(12, 17) * side, y + rnd(0, 1));
		p.drawBox(1, rnd(30, 50), 0xFFFFFF, rnd(0.4, 0.7));
		
		if( !noFx() )
			p.filters = [ new flash.filters.GlowFilter(col, 0.9, 1, 10, 4) ];
		p.dy = rnd(15, 40);
		p.dx = rnd(0, 2) * -side;
		p.dr = -p.dx * 0.5;
		p.frictX = p.frictY = 0.89;
		p.life = 2;
		register(p);
		
		if (!noFx() && Std.random(3) == 0) {
			col = switch (Std.random(4)) {
				case 0:	0xEB854A;
				case 1:	0xC6673D;
				case 2:	0x613B15;
				case 3:	0xB3B3B3;
			}
			p = new Particle(x + rnd(12, 17) * side, y + rnd(0, 20));
			p.drawBox(rnd(1, 4), rnd(4, 8), col, 1);
			p.dx = rnd(1, 3) * side;
			p.dy = rnd(5, 7);
			p.dr = rnd(0, 10);
			p.frictX = p.frictY = 0.9;
			p.life = 10;
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function bulletTrail (x:Float, y:Float, w:Float, d:Int) {
		//return;
		var p = new Particle(x, y + rnd(0, 4, true));
		p.graphics.beginFill(0xFFFFFF);
		p.graphics.drawRect(rnd(3, 12) * d, 0, w - rnd(10, 20), 2);
		p.graphics.endFill();
		if(!noFx())
			p.filters = [ new flash.filters.GlowFilter(0xFFCC00, 0.5, 10, 2) ];
		p.dx = 0;
		p.dy = 0;
		p.da = -0.3;
		p.life = 1;
		register(p);
	}
	
	public function bulletSmoke (x:Float, y:Float) {
		//return;
		for( i in 0...5 ) {
			var p = new Particle(x + rnd(0, 3, true), y + rnd(0, 3, true));
			p.drawCircle(rnd(1, 3), 0xCCCCCC, rnd(0.5, 1));
			
			if(!noFx())
				p.filters = [ new flash.filters.BlurFilter(4, 4) ];
			p.dx = rnd(0, 0.5, true);
			p.dy = -rnd(5, 7);
			p.frictX = p.frictY = 0.96;
			p.alpha = 0.5;
			p.life = rnd(1, 3);
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function mineSmoke (x:Float, y:Float) {
		//return;
		for (i in 0...7) {
			var p = new Particle(x + rnd(0, 3, true), y + rnd(0, 3, true));
			p.drawCircle(rnd(4, 10), 0xCCCCCC, rnd(0.4, 0.7));
			if(!noFx())
				p.filters = [ new flash.filters.BlurFilter(4, 4) ];
			p.dx = rnd(0, 2, true);
			p.dy = rnd(0, 2, true) + Game.SPEED;
			p.frictX = p.frictY = 0.96;
			p.life = rnd(1, 3);
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function ghostEyes (x:Float, y:Float) {
		//return;
		for (i in 0...3) {
			var p = new Particle(x - 8, y + i);
			p.drawBox(3, 2, 0xFF0000, 0.8);
			
			if(!noFx())
				p.filters = [ new flash.filters.BlurFilter(4, 4) ];
			p.dy = 5;
			p.life = 3;
			register(p, BlendMode.NORMAL);
			
			p = new Particle(x + 8, y + i);
			p.drawBox(3, 2, 0xFF0000, 0.8);
			if(!noFx())
				p.filters = [ new flash.filters.BlurFilter(4, 4) ];
			p.dy = 5;
			p.life = 3;
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function tireOil (x:Float, y:Float) {
		//return;
		for (i in 0...1) {
			var p = new Particle(x - 11, y);
			//p.drawBox(6, 20, 0x000000, 0.8);
			var b = new Bitmap(tireBD);
			b.x = -b.width / 2;
			b.y = -b.height / 2;
			p.addChild(b);
			p.dy = Game.SPEED;
			p.life = 1;
			register(p, BlendMode.OVERLAY);
			
			p = new Particle(x + 11, y);
			//p.drawBox(6, 20, 0x000000, 0.8);
			b = new Bitmap(tireBD);
			b.x = -b.width / 2;
			b.y = -b.height / 2;
			p.addChild(b);
			p.dy = Game.SPEED;
			p.life = 1;
			register(p, BlendMode.OVERLAY);
		}
	}
	
	public function shine (x:Float, y:Float, vy:Float, r:Float = 1) {
		//return;
		if (Fx.noFx())	return;
		
		var p = new Particle(x, y);
		p.graphics.beginFill(0xFFFFFF, 1);
		p.graphics.moveTo(-10, 0);
		p.graphics.lineTo(0, -rnd(20+20*r, 30+40*r));
		p.graphics.lineTo(10, 0);
		p.graphics.lineTo( -10, 0);
		
		if(!noFx())
			p.filters = [ new flash.filters.BlurFilter(rnd(2, 10), rnd(2, 10)) ];
		p.life = 6;
		p.alpha = rnd(0.2, 0.5)*r;
		p.rotation = rnd(0, 180, true);
		p.dr = rnd(2, 5, true);
		p.dy = vy;
		register(p, BlendMode.NORMAL, false, Level.FLOOR_DEPTH);
	}
	
	public function text (txt:String, c:UInt, s:Int, x:Float, y:Float) {
		if (Level.instance.endingGame)	return;
		var p = new Particle(x, y);
		var tf = new EmbedText(txt, c, s);
		p.addChild(tf);
		p.dy = -3;
		p.life = 15;
		p.onKill = function () { tf.destroy(); }
		register(p, BlendMode.ADD);
	}
	
	public function plainText (txt:String, c:UInt, s:Int, x:Float, y:Float) {
		if (Level.instance.endingGame)	return;
		var p = new Particle(x, y);
		var tf = new EmbedText(txt, c, s, null, false);
		p.addChild(tf);
		//p.dy = 0;
		p.life = 15;
		p.onKill = function () { tf.destroy(); }
		register(p, BlendMode.ADD);
	}
	
	public function turn (x:Float, y:Float, dir:Int, vx:Float, vy:Float) {
		//return;
		
		//TODO balancer des cailloux à la place
		
		//if (Std.random(4) != 0)	return;
		var p = new Particle(x, y+rnd(0, 3, true));
		//p.drawBox(2, 2, 0xFFFFFF);
		p.graphics.beginFill(0xFFFFFF, 0.8);
		p.graphics.moveTo(0, -4);
		p.graphics.lineTo(12*dir, 0);
		p.graphics.lineTo(0, 4);
		p.graphics.lineTo(0, -4);
		//p.filters = [ new flash.filters.BlurFilter(rnd(2, 10), rnd(2, 10)) ];
		p.rotation = -30 * dir;
		p.life = 0;
		p.dr = 5 * dir;
		p.dx = vx + dir;
		p.dy = vy + 1;
		register(p, BlendMode.OVERLAY, false, Level.FLOOR_DEPTH);
	}
	
	public function nova (x:Float, y:Float) {
		var p = new Particle(x,y);
		var s = new Sprite();
		p.addChild(s);
		s.graphics.beginFill(0xCCCCFF, 0.5);
		s.graphics.drawCircle(0,0,100);
		s.graphics.drawCircle(0,0,70);
		s.graphics.endFill();
		if(!noFx())
			s.filters = [
				new flash.filters.BlurFilter(8,8),
				new flash.filters.GlowFilter(0x8080FF,1, 32,32,2)
			];
		p.scaleX = p.scaleY = 0.01;
		//p.delay = 4;
		var ds = 0.5;
		p.onUpdate = function() {
			p.scaleX+=ds;
			p.scaleY+=ds;
			ds *= 0.75;
		}
		p.life = 0;
		register(p);
	}
	
	/*public function emitDark (x:Float, y:Float, ratio:Float) {
		var c1 = 0xCCCCFF;
		var c2 = 0x8080FF;
		var a = rnd(0,6.28);
		var p = new Particle(x+Math.cos(a)*rnd(16,26), y+Math.sin(a)*rnd(32,42));
		p.drawCircle(2+rnd(10,15)*ratio, c1, 0.3+rnd(0, 0.3)+0.4*ratio);
		var s = rnd(5, 8);
		p.dx = Math.cos(a)*s;
		p.dy = Math.sin(a)*s;
		p.life = 2;
		p.frictX = p.frictY = 0.85;
		p.ds = -0.06;
		p.filters = [
			//new flash.filters.BlurFilter(8,8),
			new flash.filters.GlowFilter(c2,1, 8,8, 5),
		];
		//register(p, BlendMode.MULTIPLY);
		register(p);
	}*/
	
	public function emitDark (x:Float, y:Float, ratio:Float) {
		//return;
		if (rnd(0, 1) > ratio || tick % 2 != 0)	return;
		var c1 = Game.COL_BLUE;//0xCCCCFF;
		var c2 = 0x8080FF;
		var a = rnd(0, 6.28);
		var s = 4+rnd(5, 10)*ratio;
		var p = new Particle(x + Math.cos(a) * (38+rnd(8, 18)*ratio), y + Math.sin(a) * (46+rnd(16, 26)*ratio));
		//p.drawBox(5+5*ratio+rnd(0, 5), rnd(1, 2), c1, 0.3+rnd(0, 0.3)+0.4*ratio);
		p.drawCircle(2, c1, 0.3+rnd(0, 0.3)+0.4*ratio);
		p.rotation = a * 180 / 3.14;
		p.dx = Math.cos(a) * -s;
		p.dy = Math.sin(a) * -s;
		p.frictX = p.frictY = 0.8;
		//p.ds = -0.03;
		p.life = 0;
		
		if(!noFx())
			p.filters = [ new flash.filters.GlowFilter(c2, 1, 6, 6) ];
		register(p);
	}
	
	public function isOD (x:Float, y:Float) {
		var p = new Particle(x + rnd(2, 5, true), y + rnd(0, 3, true));
		
		var b = new Bitmap(ODBD);
		//b.scaleX = b.scaleY = 1;
		b.x = -b.width / 2;
		b.y = -b.height;
		p.addChild(b);
		
		//var ct = new ColorTransform();
		//ct.color = 0x000000;
		//p.transform.colorTransform = ct;
		
		p.scaleX = 1 + (Std.random(5) + 1) / 10;
		p.rotation = rnd(0, 10) * Std.random(2) * 2 - 1;
		p.rotation += 180;
		//p.dx = rnd(0, 1, true);
		//p.dy = rnd(5, 20);
		//p.dr = rnd(0, 1) * Std.random(2)*2-1;
		p.ds = 0.95;
		p.frictX = p.frictY = 0.96;
		p.life = 3;
		register(p, BlendMode.NORMAL);
	}
	
	public function bossKill (x:Float, y:Float) {
		//return;
		for (i in 0...7) {
			//Game.TAM.identity();
			//Game.TAM.translate(-40, -36);
			var p = new Particle(x + rnd(3, 8, true), y + rnd(3, 8, true));
			var r = rnd(0, 1);
			//var m = 1 - 0.2 * r;//color multiplier
			//var o = 32 * r;//color offset
			//p.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 127*r, 127*r, 127*r);// to white
			p.transform.colorTransform = new ColorTransform(r, r, r);// to black
			
			var b = new Bitmap(skullBD);
			b.x = -b.width / 2;
			b.y = -b.height / 2;
			b.scaleX = p.scaleY = (Std.random(3) == 0) ? 1 : 2;
			p.addChild(b);
			
			//p.rotation = rnd(0, 360);
			//p.filters = [ new flash.filters.BlurFilter(rnd(0, 2), rnd(0, 2)) ];
			p.dx = rnd(3, 5, true);
			p.dy = rnd(3, 5, true);
			//p.dr = rnd(3, 10) * side;
			p.frictX = p.frictY = 0.85;
			p.life = rnd(5, 10);
			//p.delay = 10;
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function speedLines (lvl:Int = 1) {
		if (noFx())	return;
		
		var col = 0xFFFFFF;
		var alpha = rnd(0.3, 0.6);
		
		var x = 0.0;
		var p = null;
		if (lvl > 1 || Std.random(3) == 0) {
			x = rnd(0, Game.SIZE.width / 4);
			x -= Level.instance.container.x;
			p = new Particle(x, -Level.instance.container.y);
			
			var b = new Bitmap(speedBD);
			b.x = -b.width / 2;
			b.y = -b.height / 2;
			p.addChild(b);
			
			p.dy = 20*lvl + rnd(0, 10);
			p.life = 2;
			register(p, BlendMode.OVERLAY);
		}
		//
		if (lvl > 1 && Std.random(4) == 0) {
			x = rnd(0, Game.SIZE.width / 3, true);
			x += Game.SIZE.width / 2;
			x -= Level.instance.container.x;
			p = new Particle(x, -Level.instance.container.y);
			
			var b = new Bitmap(speedBD);
			b.x = -b.width / 2;
			b.y = -b.height / 2;
			p.addChild(b);
			
			p.dy = 20*lvl + rnd(0, 10);
			p.life = 2;
			register(p, BlendMode.OVERLAY);
		}
		//
		if (lvl > 1 || Std.random(3) == 0) {
			x = rnd(Game.SIZE.width / 4 * 3, Game.SIZE.width);
			x -= Level.instance.container.x;
			p = new Particle(x, -Level.instance.container.y);
			
			var b = new Bitmap(speedBD);
			b.x = -b.width / 2;
			b.y = -b.height / 2;
			p.addChild(b);
			
			p.dy = 20*lvl + rnd(0, 10);
			p.life = 2;
			register(p, BlendMode.OVERLAY);
		}
	}
	
	public inline function update() {
		perf = api.AKApi.getPerf();
		tick++;
		Particle.update();
	}
}










