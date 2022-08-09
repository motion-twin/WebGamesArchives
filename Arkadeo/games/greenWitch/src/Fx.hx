import flash.display.BlendMode;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

import mt.deepnight.Particle;
import mt.deepnight.Lib;
import mt.deepnight.Color;

import Const;

class Fx {
	static var BURNS : Array<BitmapData> = [];
	static var PROP_CACHE: Array<Array<Bool>>;
	static var PROP_GRID = 15;
	static var BLOOD : Array<BitmapData> = [];
	static var BLOOD_ID = 0;
	
	
	var lowq			: Bool;
	var lastMoveOrder	: Null<Particle>;
	var game			: mode.Play;
	var perf			: Float;
	var fadeMask		: Sprite;
	
	
	public function new() {
		game = mode.Play.ME;
		lowq = api.AKApi.isLowQuality();
		Particle.LIMIT = #if debug 9999 #else lowq ? 30 : 150 #end;
		
		fadeMask = new Sprite();
		fadeMask.graphics.beginFill(0x0, 1);
		fadeMask.graphics.drawRect(0,0, game.buffer.width, game.buffer.height);
		game.buffer.dm.add(fadeMask, Const.DP_MASK);
		fadeMask.visible = false;
		
		// Tâches noires
		var base = game.char.get("dirt");
		base.setCenter(0, 0);
		var wrapper = new Sprite();
		wrapper.addChild(base);
		wrapper.scaleY = 0.6;
		base.filters = [
			Color.getColorizeMatrixFilter(0x0, 1,0),
		];
		for(i in 0...10) {
			base.setFrame(i%game.char.countFrames("dirt"));
			base.scaleX = base.scaleY = rnd(1, 2.5);
			base.alpha = rnd(0.2, 0.35);
			BURNS.push( Lib.flatten(wrapper).bitmapData );
		}
		
		// Tâches sang
		var base = game.char.get("dirt");
		base.setCenter(0,0);
		base.filters = [
			Color.getColorizeMatrixFilter(0x210E1D, 1,0),
			new flash.filters.GlowFilter(0x63141C,0.7, 8,8,1),
			new flash.filters.DropShadowFilter(1,-90, 0x63141C,0.7, 0,0,1, 1,true),
		];
		var wrapper = new Sprite();
		wrapper.addChild(base);
		wrapper.scaleY = 0.6;
		for(i in 0...10) {
			base.setFrame(i%game.char.countFrames("dirt"));
			base.scaleX = base.scaleY = rnd(1, 2.5);
			base.alpha = rnd(0.7, 0.9);
			BLOOD.push( Lib.flatten(wrapper,8).bitmapData );
		}
		
	}
	
	public function onLevelChange() {
		PROP_CACHE = new Array();
		for(x in 0...Math.ceil(game.currentLevel.ground.width/PROP_GRID)) {
			PROP_CACHE[x] = new Array();
			for(y in 0...Math.ceil(game.currentLevel.ground.height/PROP_GRID))
				PROP_CACHE[x][y] = false;
		}
	}
	
	
	public function register(p:Particle, ?b:BlendMode, ?bg=false) {
		game.sdm.add(p, bg ? Const.DP_BG_FX : Const.DP_FX);
		p.blendMode = b!=null ? b : BlendMode.ADD;
	}
	
	inline function rnd(min,max,?sign) { return Lib.rnd(min,max,sign); }
	inline function irnd(min,max,?sign) { return Lib.irnd(min,max,sign); }
	
	
	public inline function markerCase(cx,cy, ?col=0xFFFF00, ?alpha=1.0) {
		#if debug
		marker( (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID, col, alpha );
		#end
	}
	
	public inline function markerCaseTxt(cx:Float,cy:Float, txt:Dynamic, ?col=0xFFFF00) {
		#if debug
		var p = new Particle( (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID );
		var tf = game.createField(txt, col, true);
		p.addChild(tf);
		tf.filters = [ new flash.filters.GlowFilter(0x0,1, 2,2,4) ];
		tf.x = Std.int(-tf.width*0.5);
		tf.y = Std.int(-tf.height*0.5)-5;
		p.life = 40;
		p.drawCircle(4, col);
		register(p, BlendMode.NORMAL);
		#end
	}
	
	public inline function marker(x,y, ?col=0xFFFF00, ?alpha=1.0) {
		#if debug
		var p = new Particle(x,y);
		p.alpha = alpha;
		p.drawCircle(5, col);
		p.life = 50;
		p.filters = [
			new flash.filters.GlowFilter(col,1, 16,16, 1),
		];
		register(p, BlendMode.NORMAL);
		#end
	}
	
	public function cancelOrder() {
		if( lastMoveOrder!=null ) {
			lastMoveOrder.life = 1;
			lastMoveOrder = null;
		}
	}
	public function moveOrder(x,y, col) {
		cancelOrder();
		
		var p = new Particle(x,y);
		var wrap = new Sprite();
		p.addChild(wrap);
		wrap.graphics.lineStyle(1, col, 0.5, flash.display.LineScaleMode.NONE);
		wrap.graphics.drawCircle(0,0, 8);
		wrap.scaleY = 0.6;
		p.scaleX = p.scaleY = 1.5;
		p.ds = -0.08;
		p.life = 300;
		p.filters = [
			//new flash.filters.DropShadowFilter(2, -90, col,0.7, 0,2),
			//new flash.filters.DropShadowFilter(2, -90, col,0.7, 0,2),
			new flash.filters.GlowFilter(col,1, 8,4, 3),
		];
		p.onUpdate = function() {
			p.ds*=0.9;
		}
		register(p);
		lastMoveOrder = p;
	}
	
	
	public function staff(x,y, w:WeaponType) {
		if( perf<0.8 )
			return;
		var c = switch(w) {
			case W_Basic : 0x94E718;
			case W_Lightning : 0x00BFFF;
			case W_Grenade : 0xFF9900;
			case W_Lazer : 0xFF00FF;
		}
		for(i in 0...2) {
			var p = new Particle(x+rnd(0,2,true), y+rnd(0,2,true));
			p.drawBox(1,1, Color.brightnessInt(c, 0.7), 1);
			p.frictX = p.frictY = 0.85;
			p.dx = rnd(0, 0.6, true);
			p.dy = -rnd(0.5, 2);
			p.filters = [ new flash.filters.GlowFilter(c, 1, 4,4, 7) ];
			p.life = rnd(0,5);
			register(p);
		}
	}
	
	inline function propTag(x:Float,y:Float) {
		var cx = Std.int(x/Const.GRID);
		var cy = Std.int(y/Const.GRID);
		if( cx>0 && cy>0 && cx<PROP_CACHE.length && cy<PROP_CACHE[cx].length )
			return PROP_CACHE[cx][cy]==false ? { PROP_CACHE[cx][cy] = true; true;} : false;
		else
			return false;
	}
	
	public function burn(x:Float,y:Float) {
		if( propTag(x,y) ) {
			var b = BURNS[Std.random(BURNS.length)];
			game.currentLevel.ground.bitmapData.copyPixels(b, b.rect, new flash.geom.Point(x-b.width*0.5+rnd(0,3,true), y-b.height*0.5+rnd(0,4,true)), true);
		}
	}
	
	public function blood(x:Float,y:Float) {
		var bd = BLOOD[ (BLOOD_ID++) % BLOOD.length ];
		game.currentLevel.ground.bitmapData.copyPixels(bd, bd.rect, new flash.geom.Point(x-bd.width*0.5+rnd(0,3,true), y-bd.height*0.5+rnd(0,4,true)), true);
	}
	
	public function bones(x:Float,y:Float, ?col=0xDFDACA) {
		var w = 20;
		var s = new Sprite();
		var g = s.graphics;
		for(i in 0...12) {
			var a = rnd(0,6.28);
			var d = rnd(0,w);
			var x = w*0.5 + Math.cos(a)*rnd(0,w);
			var y = w*0.5 + Math.sin(a)*rnd(0,w);
			g.lineStyle(rnd(0.5,2), col, rnd(0.1, 0.7));
			g.moveTo(x,y);
			g.lineTo(x+rnd(0,4,true), y+rnd(0,4,true));
		}
		s.filters = [ new flash.filters.DropShadowFilter(1,90, Color.brightnessInt(col,-0.6),1, 0,0,1) ];
		s.x = x-w*0.5;
		s.y = y-w*0.5;
		game.currentLevel.ground.bitmapData.draw(s, s.transform.matrix);
	}
	
	public function bombSmoke(x,y, col) {
		for( i in 0...2 ) {
			var p = new Particle(x+rnd(0,3,true), y+rnd(0,3,true));
			p.drawBox(4,4, col, rnd(0.5, 1));
			p.filters = [ new flash.filters.BlurFilter(4,4) ];
			p.dx = rnd(0,0.5,true);
			p.dy = -rnd(0,0.5);
			p.dr = 10;
			p.frictX = p.frictY = 0.96;
			p.life = rnd(10,20);
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function halo(x,y, r, col) {
		var p = new Particle(x,y);
		p.drawCircle(r, col, 0.5);
		p.scaleY = 0.6;
		p.ds = 0.02;
		p.life = 0;
		if( r<=20 )
			p.filters = [ new flash.filters.BlurFilter(16,16) ];
		else
			p.filters = [ new flash.filters.BlurFilter(32,32) ];
		register(p, BlendMode.ADD);
	}
	
	public function doorExplosion(x,y) {
		halo(x,y, 50, 0xFF4A15);
		for( i in 0...10 ) {
			var p = new Particle(x+rnd(0,10,true), y+rnd(0,10,true));
			p.drawBox(20,20, Std.random(3)==0 ? 0x3C4A4D : 0x0, rnd(0.5, 1));
			p.filters = [ new flash.filters.BlurFilter(16,16) ];
			p.dx = rnd(0,0.5,true);
			p.dy = -rnd(0.1,2);
			p.gy = -rnd(0.02, 0.15);
			p.dr = rnd(5,15);
			p.frictX = p.frictY = 0.96;
			p.life = rnd(10,30);
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function hitSmoke(x,y) {
		for( i in 0...4 ) {
			var p = new Particle(x+rnd(0,3,true), y+rnd(0,3,true));
			p.drawBox(4,4, 0x0, 1);
			p.filters = [ new flash.filters.BlurFilter(4,4) ];
			p.dy = -rnd(0.5, 3);
			p.dr = 10;
			p.frictY = rnd(0.8, 0.9);
			p.life = rnd(10,20);
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function lazer(x,y, a, len, wid, col:Int) {
		energyHit(x,y, col, 2);
		energyHit(x+Math.cos(a)*len, y+Math.sin(a)*len, col);
		
		var p = new Particle(x,y);
		p.graphics.beginFill(0xFFFFFF,1);
		p.graphics.drawRect(0,-wid*0.5, len,wid);
		p.filters = [
			new flash.filters.BlurFilter(4,4),
			new flash.filters.GlowFilter(col,1, 8,8, 2),
		];
		p.rotation = Lib.deg(a);
		p.life = 3;
		var t = 0.;
		p.onUpdate = function() {
			p.scaleY = 0.75 + Math.sin(t*3.14)*0.25;
			t+=0.2;
		}
		
		register(p, true);
		
		// Particules rémanentes
		for(i in 0...9) {
			var d = rnd(5, len-5);
			var p = new Particle(x+Math.cos(a)*d, y+Math.sin(a)*d);
			p.drawBox(rnd(3,5), 1, 0xFFFFFF, rnd(0.6,1));
			p.delay = 6;
			var s = rnd(0.3, 1);
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s;
			p.frictX = p.frictY = 0.8;
			p.alpha = 0;
			p.da = 0.1;
			p.life = rnd(3,6);
			p.filters = [
				//new flash.filters.BlurFilter(2,2),
				new flash.filters.GlowFilter(col,1, 4,4, 6),
			];
			p.rotation = Lib.deg(a);
			register(p);
		}
	}
	
	
	public function pop(x:Float,y:Float, str:Dynamic, ?col=0xFFFFFF, ?scale=1.0, ?long=false) {
		var p = new Particle(x,y-10);
		
		var tf = game.createField(Std.string(str), true);
		tf.textColor = col;
		tf.filters = [ new flash.filters.GlowFilter(Color.brightnessInt(col, -0.7), 1, 2,2, 4) ];
		var bmp = Lib.flatten(tf);
		p.addChild(bmp);
		bmp.scaleX = bmp.scaleY = scale;
		bmp.x = Std.int(-bmp.width*0.5);
		bmp.y = Std.int(-bmp.height*0.5);
		p.onKill = function() {
			bmp.bitmapData.dispose();
		}
		
		p.dy = -rnd(6,9);
		p.frictY = 0.8;
		p.life = long ? 35 : 15;
		register(p, BlendMode.NORMAL);
	}
	
	
	public function xp(x:Float,y:Float, v:Int) {
		var p = new Particle(x,y-10);
		
		var tf = game.createField(v+" xp", true);
		tf.textColor = v>0 ? 0x01A6FE : 0xFF0000;
		tf.filters = [ new flash.filters.GlowFilter(tf.textColor, 0.5, 4,4, 3) ];
		var bmp = Lib.flatten(tf);
		p.addChild(bmp);
		bmp.x = Std.int(-bmp.width*0.5);
		bmp.y = Std.int(-bmp.height*0.5);
		p.onKill = function() {
			bmp.bitmapData.dispose();
		}
		
		p.frictY = 0.8;
		p.alpha = 0.7;
		p.life = 12;
		register(p, BlendMode.ADD);
	}
	
	
	public function levelUp() {
		var e = game.hero;
		var c = 0x01A6FE;
		blink(e);
		
		// Texte
		var p = new Particle(e.xx,e.yy-10);
		
		var tf = game.createField(Lang.LevelUp({_n:e.level+1}), true);
		tf.textColor = Color.brightnessInt(c, 0.7);
		tf.filters = [ new flash.filters.GlowFilter(c, 0.3, 8,8, 5) ];
		var bmp = Lib.flatten(tf);
		p.addChild(bmp);
		bmp.scaleX = bmp.scaleY = 2;
		bmp.x = Std.int(-bmp.width*0.5);
		bmp.y = Std.int(-bmp.height*0.5);
		p.onKill = function() {
			bmp.bitmapData.dispose();
		}
		
		p.dy = -9;
		p.frictY = 0.8;
		p.life = 60;
		register(p, BlendMode.ADD);
	
		// Nova
		var p = new Particle(e.xx,e.yy);
		var s = new Sprite();
		s.graphics.beginFill(0xFFFFFF,1);
		s.graphics.drawCircle(0,0,50);
		s.graphics.drawCircle(0,-6,70);
		s.scaleY = 0.8;
		s.filters = [
			new flash.filters.BlurFilter(8,4),
			new flash.filters.GlowFilter(c,1, 32,32,2),
		];
		p.scaleX = p.scaleY = 0.01;
		p.delay = 4;
		var bmp = Lib.flatten(s, 32, true);
		bmp.x = -bmp.width*0.5;
		bmp.y = -bmp.height*0.5;
		p.addChild(bmp);
		p.onKill = function() {
			bmp.bitmapData.dispose();
		}
		var ds = 0.25;
		p.onUpdate = function() {
			p.scaleX+=ds;
			p.scaleY+=ds;
			ds *= 0.85;
		}
		p.life = 4;
		register(p);
		
		// Particules
		//for(i in 0...10) {
			//var p =new Particle(e.xx, e.yy-15);
			//p.drawBox(3,3, 0xFFFFFF);
			//p.filters = [ new flash.filters.GlowFilter(c,1, 8,8, 4) ];
			//var s = rnd(2,5);
			//var a = rnd(0, 6.28);
			//var a = 3.14/2;
			//p.dx = Math.cos(a)*s;
			//p.dy = Math.sin(a)*s;
			//p.frictX = p.frictY = 0.95;
			//register(p);
		//}
	}
	
	
	public function popScore(x:Float,y:Float, v:Int) {
		var p = new Particle(x,y-10);
		var col = 0x80FF00;
		
		var tf = game.createField(Std.string(v), true);
		tf.textColor = col;
		tf.filters = [ new flash.filters.GlowFilter(col, 0.5, 4,4, 4) ];
		var bmp = Lib.flatten(tf);
		p.addChild(bmp);
		//bmp.scaleX = bmp.scaleY = 1;
		bmp.x = Std.int(-bmp.width*0.5);
		bmp.y = Std.int(-bmp.height*0.5);
		p.onKill = function() {
			bmp.bitmapData.dispose();
		}
		
		p.dy = -1;
		p.frictY = 0.8;
		p.life = 30;
		register(p, BlendMode.NORMAL);
	}
	
	
	public function energyHit(x:Float,y:Float, col:Int, ?scale=1.0) {
		var p = new Particle(x, y);
		p.drawCircle(scale*rnd(3,4), Color.brightnessInt(col, 0.7), 0.6);
		p.life = 6;
		p.ds = 0.06;
		p.filters = [
			new flash.filters.BlurFilter(2,2),
			new flash.filters.GlowFilter(col, 1, 8,8, 2),
		];
		p.onUpdate = function() {
			if( p.alpha<1 )
				p.alpha = 0;
		}
		register(p);
		
	}
	
	public function burnHit(x:Float,y:Float) {
		var p = new Particle(x, y);
		//p.drawCircle(rnd(9,14), 0xFFFF80, 0.6);
		var s = game.char.getRandom("dirt", Std.random);
		s.transform.colorTransform = Color.getColorizeCT(0xFFFF00,1);
		s.setCenter(0.5, 0.5);
		p.addChild(s);
		p.life = rnd(4, 8);
		p.dr = rnd(3, 8, true);
		p.dy = -rnd(0.2, 1);
		//p.ds = -0.1;
		p.alpha = 0;
		p.da = 0.2;
		p.scaleX = p.scaleY = rnd(0.7, 1.2);
		p.filters = [
			new flash.filters.BlurFilter(2,2),
			new flash.filters.GlowFilter(0xFF6C00, 1, 8,8, 4),
		];
		//p.onUpdate = function() {
			//if( p.alpha<1 )
				//p.alpha = 0;
		//}
		register(p);
		
	}
	
	public function lightning(x:Float,y:Float, tx:Float,ty:Float, ?col=0x0080FF, big:Bool) {
		glow(x,y, 25, 0xFFFFFF);
		burn(tx,ty);
		for(pt in [{x:x,y:y}, {x:tx,y:ty}])
			energyHit(pt.x, pt.y, col);
		
		var n = Math.ceil( Lib.distance(x,y,tx,ty)/15 );
		
		
		for(i in 0...(big ? 4 : 1)) {
			var n = irnd(n, n+4);
			var p = new Particle(x,y);
			var decal = i==0 ? 2 : 7;
			
			var g = p.graphics;
			g.lineStyle(i==0 ? 2 : 1, 0xFFFFFF, rnd(0.6, 0.9));
			g.moveTo(0,0);
			for(i in 1...n)
				g.lineTo(i*(tx-x)/n + rnd(0,decal,true), i*(ty-y)/n + rnd(0,decal,true));
			g.lineTo(tx-x, ty-y);
			
			p.ds = -0.02;
			if( big )
				p.filters = [
					new flash.filters.GlowFilter(col, 1, 8,8, 5),
					new flash.filters.GlowFilter(col, 1, 32,32, 1)
				];
			else
				p.filters = [
					new flash.filters.GlowFilter(col, 1, 4,4, 1),
					new flash.filters.GlowFilter(col, 1, 16,16, 1)
				];
			p.life = rnd(4,6);
			p.delay = i*1.5;
			p.onUpdate = function() {
				if( p.alpha<1 )
					p.alpha = 0;
			}
			register(p);
		}
		
		if( perf>0.8 )
			for(i in 0...4) {
				var p = new Particle(tx+rnd(0,5,true), ty+rnd(0,5,true));
				p.drawBox(1,1, 0xFFFF9B, rnd(0.5, 0.7));
				p.dx = rnd(0,2,true);
				p.dy = -rnd(2,8);
				p.gy = rnd(0.3, 0.6);
				p.groundY = ty+rnd(0,10);
				p.bounce = 0;
				p.frictX = p.frictY = 0.85;
				p.life = rnd(10,60);
				p.filters = [
					new flash.filters.GlowFilter(0xFF6C00,1, 4,4, 8),
				];
				p.onBounce = function() {
					p.dy = p.gy = 0;
				}
				register(p, BlendMode.NORMAL);
			}
	}
	
	
	public function fadeIn(?t=600) {
		game.tw.terminate(fadeMask);
		fadeMask.visible = true;
		fadeMask.alpha = 1;
		game.tw.create(fadeMask, "alpha", 0, t).onEnd = function() {
			fadeMask.visible = false;
		}
	}
	
	public function fadeOut(?t=600) {
		game.tw.terminate(fadeMask);
		fadeMask.visible = true;
		fadeMask.alpha = 0;
		game.tw.create(fadeMask, "alpha", 1, t);
	}
	

	public function blink(e:Entity, ?col=0xFFFFFF) {
		if( e.life<=0 )
			return;
		var o = {t:0.}
		game.tw.create(o, "t", 1, 300).onUpdate = function() {
			if( o.t<1 )
				e.sprite.transform.colorTransform = Color.getColorizeCT(col, 1-o.t);
			else
				e.sprite.transform.colorTransform = new flash.geom.ColorTransform();
		}
	}
	
	public function pickUp(x,y, ?col=0x00C6FF) {
		var p = new Particle(x,y);
		p.drawCircle(20, col, 0.5);
		p.life = 0;
		p.filters = [ new flash.filters.BlurFilter(16,16) ];
		register(p, BlendMode.ADD);
	}
	
	public function heroDeath() {
		var e = game.hero;
		var x = e.xx;
		var y = e.yy;
		
		// Disparition
		e.setShadow(false);
		e.sprite.visible = false;
		
		// Sang
		blood(x+rnd(0,10,true), y+rnd(0,10,true));
		blood(x+20,y);
		blood(x-20,y);
		blood(x,y+20);
		blood(x,y-20);
		
		// Nova
		var p = new Particle(x,y);
		var s = new Sprite();
		p.addChild(s);
		s.graphics.beginFill(0xFFFF80,1);
		s.graphics.drawCircle(0,0,100);
		s.graphics.drawCircle(0,-6,70);
		s.scaleY = 0.8;
		s.filters = [
			new flash.filters.BlurFilter(8,4),
			new flash.filters.GlowFilter(0xFF7900,1, 32,32,2),
		];
		p.scaleX = p.scaleY = 0.01;
		p.delay = 4;
		var ds = 0.25;
		p.onUpdate = function() {
			p.scaleX+=ds;
			p.scaleY+=ds;
			ds *= 0.85;
		}
		p.life = 4;
		register(p);
		
		// Evanouissement
		var n = 10;
		for(i in 0...n) {
			var p = new Particle(e.xx+rnd(0,5,true), e.yy-3-i*2+rnd(0,2,true));
			p.drawCircle(rnd(5,8), 0xFFFFFF);
			p.filters = [ new flash.filters.GlowFilter(0xFF8000,1, 8,8,2) ];
			p.ds = -0.05;
			p.delay = rnd(0,5);
			p.life = rnd(4,10);
			register(p);
		}
		
		// Explosion
		var n = 30;
		for(i in 0...n) {
			var a = 6.28 * i/(n-1) + rnd(0,0.2,true);
			var s = rnd(12, 18);
			var d = rnd(40, 70);
			var p = new Particle(x+Math.cos(a)*d, y-15+Math.sin(a)*d);
			p.drawBox(rnd(5,10), rnd(1,2), 0xFFFF80, rnd(0.6, 0.9));
			p.rotation = Lib.deg(a);
			p.dx = -Math.cos(a)*s;
			p.dy = -Math.sin(a)*s;
			p.frictX = p.frictY = 0.90;
			p.ds = -0.03;
			p.life = rnd(10, 20);
			p.filters = [ new flash.filters.GlowFilter(0xFF7900, 1, 8,8, 6) ];
			register(p);
		}
	}
	
	public function fireBallExplosion(x,y) {
		glow(x,y);
		for(i in 0...10) {
			var a = rnd(0,6.28);
			var p = new Particle(x+Math.cos(a)*rnd(2,4), y+Math.sin(a)*rnd(2,4));
			p.drawCircle(rnd(3,6), 0xFFFF80, rnd(0.5, 1));
			var s = rnd(3,6);
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s;
			p.life = rnd(2,6);
			p.frictX = p.frictY = 0.85;
			//p.rotation = Lib.deg(a);
			p.ds = -0.06;
			p.filters = [
				new flash.filters.GlowFilter(0xFF9300,1, 8,8, 5),
			];
			register(p);
		}
	}
	
	public function bigHit(x,y, ?col=0x0D9CF2) {
		for(i in 0...10) {
			var p = new Particle(x+rnd(0,3, true), y+rnd(0,3,true));
			p.drawBox(rnd(1,5),1, 0xFFFFFF, rnd(0.5, 1));
			var a = rnd(0,6.28);
			var s = rnd(2,4);
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s;
			//p.dy = rnd(0, 1, true);
			p.life = rnd(2,6);
			p.frictX = p.frictY = 0.92;
			p.rotation = Lib.deg(a);
			p.filters = [
				new flash.filters.GlowFilter(col,1, 4,4, 7),
			];
			register(p);
		}
	}
	
	public function hit(x,y, ?col=0x0D9CF2) {
		for(i in 0...10) {
			var p = new Particle(x+rnd(0,5,true), y+rnd(0,5,true));
			p.drawBox(1,1, 0xFFFFFF, rnd(0.5, 1));
			p.dx = rnd(0.3, 1, true);
			p.dy = rnd(0, 1, true);
			p.life = rnd(0,6);
			p.filters = [
				new flash.filters.GlowFilter(col,1, 4,4, 7),
			];
			register(p);
		}
	}
	
	public function death(x,y, ?col=0xE10000, ?n=6) {
		var p = new Particle(x,y);
		p.drawCircle(20, col, 0.5);
		p.life = 0;
		p.filters = [ new flash.filters.BlurFilter(16,16) ];
		register(p, BlendMode.ADD);

		var dark = Color.brightnessInt(col, -0.6);
		for(i in 0...n) {
			var p = new Particle(x+rnd(0,5,true), y+rnd(0,5,true));
			p.drawBox(rnd(2,4),rnd(2,4), col, rnd(0.5, 1));
			p.dx = rnd(0.3, 0.7, true);
			p.dy = i<n*0.5 ? -rnd(5,9) : -rnd(2, 3);
			p.dr = rnd(5,25, true);
			p.gy = 0.4;
			p.life = rnd(10,30);
			p.groundY = y+rnd(0,10);
			p.bounce = 0.5;
			p.filters = [
				new flash.filters.DropShadowFilter(2,90, dark,1,0,0),
			];
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function glow(x,y, ?r=20, ?col=0xFFFFFF, ?alpha=1.0) {
		if( perf<0.8 )
			return;
		var s = new Sprite();
		s.graphics.beginFill(col, alpha);
		s.graphics.drawCircle(0,0, r*0.5);
		s.filters = [ new flash.filters.BlurFilter(16,8) ];
		var bmp = Lib.flatten(s, 16);
		bmp.scaleX = bmp.scaleY = 2;
		bmp.x = -bmp.width*0.5;
		bmp.y = -bmp.height*0.5;
		
		var p = new Particle(x,y);
		p.addChild(bmp);
		p.onKill = function() {
			bmp.bitmapData.dispose();
		}
		p.life = 5;
		register(p, BlendMode.OVERLAY);
	}
	
	
	public function explode(x,y, ?size=1.0) {
		if( perf>=0.8 ) {
			var p = new Particle(x,y);
			p.drawCircle(40*size, 0xFF6000, 0.6);
			p.scaleY = 0.8;
			p.life = 4;
			p.filters = [ new flash.filters.BlurFilter(32,32) ];
			register(p, BlendMode.ADD);
		}

		var n = perf>=0.7 ? 15*size : 6;
		for(i in 0...Std.int(n)) {
			var p = new Particle(x+rnd(0,5,true), y+rnd(0,5,true));
			if( i<n*0.4 ) {
				p.drawBox(rnd(2,4), rnd(2,5), 0xD20000, rnd(0.8, 1));
				p.dr = rnd(20,40, true);
			}
			else
				p.drawBox(1,1, 0x930000, rnd(0.8, 1));
			p.dx = rnd(0.3, 2, true);
			p.dy = i<n*0.5 ? -rnd(5,9) : -rnd(2, 5);
			//p.dr = rnd(5,25, true);
			p.gy = 0.4;
			p.life = rnd(10,30);
			p.groundY = y+rnd(0,10);
			p.bounce = 0.5;
			p.filters = [
				new flash.filters.GlowFilter(0xFFFF00,1, 2,2,4),
				new flash.filters.GlowFilter(0xFF4D00,0.7, 4,4,4),
				//new flash.filters.DropShadowFilter(2,90, 0x39455B,1,0,0),
			];
			register(p, BlendMode.NORMAL);
		}
	}
	
	
	
	public function prince(x:Float,y:Float, col) {
		var p = new Particle(x,y);
		p.drawCircle(20, col, 0.6);
		p.life = 3;
		p.scaleY = 0.6;
		p.filters = [ new flash.filters.BlurFilter(16,16) ];
		register(p);

		var n = 10;
		for(i in 0...n) {
			var p = new Particle(x+ (i<5 ? rnd(2,5, true) : rnd(5, 15, true)), y-rnd(0,4));
			p.drawBox(1,rnd(2,6), 0xFFFFFF, rnd(0.4, 0.7));
			p.filters = [ new flash.filters.GlowFilter(col,0.9, 8,8, 6) ];
			p.dy = i<5 ? -rnd(7,10) : -rnd(4,7);
			p.frictX = p.frictY = 0.89;
			p.life = rnd(10,20);
			register(p);
		}
	}
	
	
	public function spawnSignal(x:Float,y:Float, ratio:Float) {
		var c = 0xFFAF09;
		for(i in 0...(perf<0.8 ? 2 : 5)) {
			var a = rnd(0,6.28);
			var s = rnd(0.2, 0.6); //i<2 ? rnd(0.1, 0.3) : rnd(0.3,1)*ratio;
			var d = i<2 ? rnd(1,2) : rnd(4,7)*ratio;
			var p = new Particle(x+Math.cos(a)*d, y+Math.sin(a)*d);
			p.drawBox(2, rnd(5,10), c, rnd(0.9, 1)*ratio*ratio);
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s;
			p.dy-=0.5;
			p.rotation = Lib.deg(a);
			p.alpha = 0;
			p.da = 0.1;
			p.ds = -0.05;
			p.filters = [new flash.filters.GlowFilter(c,0.5, 8,8,10)];
			p.life = rnd(8,20);
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function spawnFinal(x,y) {
		for(i in 0...6) {
			//var a = rnd(0,6.28);
			var p = new Particle(x+rnd(0,4,true), y+rnd(0,4,true));
			p.drawBox(4,4, 0xFF0909, rnd(0.5, 1));
			p.dx = rnd(0.5, 3, true);
			p.dy = rnd(0.5, 3, true);
			p.dr = rnd(10, 25, true);
			p.frictX = p.frictY = 0.85;
			p.filters = [new flash.filters.GlowFilter(0xFF0909,0.5, 8,8,7)];
			p.life = rnd(5,10);
			register(p);
		}
	}
	
	
	public function spawnSmoke(e:Entity, ?yOffset=0) {
		blink(e, 0xFFFFFF);
		for(i in 0...6) {
			var p = new Particle(e.xx+rnd(2,9,true), e.yy-rnd(0,20)+yOffset);
			p.drawBox(10,10, 0xFFFFFF, rnd(0.5, 1));
			//p.dr = rnd(10, 25, true);
			p.filters = [new flash.filters.BlurFilter(16,16)];
			p.life = rnd(5,10);
			register(p);
		}
	}
	
	public function turretExplosion(x:Float,y:Float, col) {
		var p = new Particle(x,y);
		p.drawCircle(20, col, 0.6);
		p.life = 3;
		p.scaleY = 0.6;
		//p.ds = 0.05;
		p.filters = [ new flash.filters.BlurFilter(16,16) ];
		register(p);

		for(i in 0...10) {
			var p = new Particle(x+rnd(0,7,true), y-rnd(0,4));
			p.drawBox(1,2, 0xFFFFFF, rnd(0.4, 0.7));
			p.filters = [ new flash.filters.GlowFilter(col,1, 4,4, 6) ];
			p.dy = -rnd(3,7);
			p.frictX = p.frictY = 0.92;
			p.life = rnd(5,20);
			register(p);
		}
	}
	
	public function shieldGlow(e:Entity) {
		var w = 20;
		var p = new Particle(e.xx, e.yy-15);
		var m = new flash.geom.Matrix();
		m.createGradientBox(w*2,w*2, 0, -w,-w);
		p.graphics.beginGradientFill(flash.display.GradientType.RADIAL, [0xFFFFFF,0xFFFFFF], [0,0.2], [128,255], m);
		p.graphics.drawCircle(0,0, w);
		p.life = 15;
		p.alpha = 0;
		p.da = 0.1;
		p.scaleY = 1.2;
		p.filters = [
			//new flash.filters.BlurFilter(2,2),
			new flash.filters.GlowFilter(0x1BB3E4, 1, 8,8,2),
		];
		p.onUpdate = function() {
			p.setPos(e.xx, e.yy-15);
		}
		register(p);
	}
		
	public function shieldHit(e:Entity) {
		var w = 20;
		var p = new Particle(e.xx, e.yy-15);
		var m = new flash.geom.Matrix();
		m.createGradientBox(w*2,w*2, 0, -w,-w);
		p.graphics.beginGradientFill(flash.display.GradientType.RADIAL, [0xFFFFFF,0xFFFFFF], [0,0.6], [0,255], m);
		p.graphics.drawCircle(0,0, w);
		p.life = 2;
		p.scaleY = 1.2;
		p.filters = [
			new flash.filters.BlurFilter(2,2),
			new flash.filters.GlowFilter(0xFFFF00, 1, 8,8,2),
		];
		p.onUpdate = function() {
			p.setPos(e.xx, e.yy-15);
		}
		register(p);
	}
	
	public function kamikazeExplosion(x:Float,y:Float, r) {
		var p = new Particle(x,y);
		p.drawCircle(r, 0x0, 0.5);
		p.life = 1;
		p.scaleY = 0.9;
		p.ds = -0.09;
		p.filters = [ new flash.filters.BlurFilter(16,16) ];
		register(p, BlendMode.OVERLAY);

		var n = 15;
		for(i in 0...n) {
			var a = rnd(0,6.28);
			var s = rnd(7,10);
			var p = new Particle(x+Math.cos(a)*4, y+Math.sin(a)*4);
			p.drawBox(6,6, 0x0, rnd(0.5, 1));
			//p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s*0.85;
			p.frictX = p.frictY = 0.9;
			p.dr = rnd(10,25, true);
			p.life = rnd(10,30);
			p.filters = [
				new flash.filters.BlurFilter(4,4),
			];
			register(p, BlendMode.OVERLAY, true);
		}
	}
	
	public function burnGround(x,y, r) {
		for(i in 0...(perf>0.8 ? 15 : 6)) {
			var a = rnd(0, 6.28);
			var d = rnd(r*0.9, r*1);
			var p = new Particle(x,y);
			var s = new Sprite();
			s.graphics.beginFill(0xFFFF00, 1);
			s.graphics.drawRect(0,0, rnd(2,5),1);
			p.addChild(s);
			if( i<5 ) {
				s.y = r;
				p.dr = rnd(3,4);
			}
			else {
				s.y = -rnd(r*0.4, r);
				p.dr = rnd(1,3);
				p.ds = rnd(0, -0.01);
			}
			p.rotation = rnd(0,360);
			p.filters = [
				new flash.filters.GlowFilter(0xFF4000,1, 4,4,5),
			];
			p.delay = rnd(0,10);
			p.life = rnd(20, 30);
			p.alpha = 0;
			p.da = 0.1;
			register(p);
		}
		
	}
		
	public function slowGround(x,y, r, col, ?fast=false) {
		var base = rnd(0,6.28);
		var n = perf>0.8 ? 10 : 5;
		for(i in 0...n) {
			var ratio = i/(n-1);
			var a = 6.28*ratio + rnd(0, 0.3, true);
			var d = rnd(r*0.8, r*0.95);
			var p = new Particle(x+Math.cos(a)*d, y+Math.sin(a)*d);
			p.drawBox(rnd(15,25),4, col, rnd(0.7,1));
			p.filters = [
				new flash.filters.BlurFilter(8,8),
			];
			p.rotation = Lib.deg(a+1.57);
			var s = rnd(0, 0.2);
			var dir = i%2==0 ? 1 : -1;
			p.dx = dir*Math.cos(a)*s;
			p.dy = dir*Math.sin(a)*s;
			if( !fast )
				p.delay = rnd(0,15);
			p.life = rnd(20, 30);
			p.alpha = 0;
			p.da = 0.02;
			register(p, BlendMode.ADD, true);
		}
		
	}
	
	public inline function update() {
		perf = api.AKApi.getPerf();
		Particle.update();
	}
}