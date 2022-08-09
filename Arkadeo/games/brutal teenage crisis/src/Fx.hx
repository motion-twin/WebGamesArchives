import flash.display.BlendMode;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

import mt.deepnight.Particle;
import mt.deepnight.Lib;
import mt.deepnight.Color;
import mt.MLib;

import Const;

class Fx {
	public static var ME : Fx;
	var lowq			: Bool;
	var mode			: Mode;
	var perf			: Float;
	var powerColor		: Float;
	var pt0				: flash.geom.Point;
	var dangerBd		: BitmapData;

	public function new() {
		ME = this;
		mode = Mode.ME;
		lowq = api.AKApi.isLowQuality();
		perf = api.AKApi.getPerf();
		powerColor = 0;
		pt0 = new flash.geom.Point(0,0);
		Particle.LIMIT = #if debug 9999 #else lowq ? 30 : 350 #end;

		// Danger
		var s = new Sprite();
		s.graphics.beginFill(0xFF0000, 0.4);
		s.graphics.drawCircle(0,0, 50);
		s.filters = [ new flash.filters.BlurFilter(64,16) ];
		s.scaleX = 2;

		var tf = mode.createField("Danger", 0xFFFF00, true);
		tf.scaleX = tf.scaleY = 2;
		tf.x = Std.int(-tf.width*0.5);
		tf.y = -5;
		tf.filters = [];

		var d = new Sprite();
		d.addChild(s);
		d.addChild(tf);
		var bmp = Lib.flatten(d, 64);
		dangerBd = new BitmapData(bmp.bitmapData.width, MLib.ceil(bmp.bitmapData.height*0.5), true, 0x0);
		var r = new flash.geom.Rectangle(0,bmp.bitmapData.height*0.5, bmp.bitmapData.width, bmp.bitmapData.height*0.5);
		dangerBd.copyPixels(bmp.bitmapData, r, pt0);
	}

	public function destroy() {
		dangerBd.dispose();
		mode = null;
	}


	public function register(p:Particle, ?b:BlendMode, ?bg=false) {
		mode.dm.add(p, bg ? Const.DP_BG_FX : Const.DP_FX);
		p.blendMode = b!=null ? b : BlendMode.ADD;
	}


	inline function rnd(min,max,?sign) { return Lib.rnd(min,max,sign); }
	inline function irnd(min,max,?sign) { return Lib.irnd(min,max,sign); }


	public function clear() {
		Particle.clearAll();
	}


	public inline function marker(cx,cy, ?col=0xFFFF00, ?alpha=1.0) {
		var p = new Particle((cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.alpha = alpha;
		p.drawCircle(5, col);
		p.life = 50;
		p.filters = [
			new flash.filters.GlowFilter(col,1, 16,16, 1),
		];
		register(p, BlendMode.NORMAL);
	}

	public function radius(x,y, r, col:Int) {
		var p = new Particle(x,y);
		p.drawCircle(r, col);
		p.life = 0;
		p.ds = -0.02;
		p.filters = [ new flash.filters.BlurFilter(16,16) ];
		register(p);
	}


	public function bombExplosion(x,y, r) {
		var s = mode.tiles.getAndPlay("explo_big", 1, true);
		mode.dm.add(s, Const.DP_FX);
		s.blendMode = BlendMode.ADD;
		s.setCenter(0.5, 0.5);
		s.x = x;
		s.y = y;
		s.width = r*2;
		s.height = r*2;
		s.rotation = rnd(0, 360);
	}


	public function heroDash(e:Entity) {
		var p = new Particle(e.xx, e.yy-10);
		p.drawCircle(16, 0xDCA2DD, 1, false, 4);
		p.ds = 0.4;
		p.onUpdate = function() p.ds*=0.8;
		p.life = 0;
		register(p);

		var d = e.dx<0 ? -1 : 1;
		for(i in 0...12) {
			var p = new Particle(e.xx -d*10 + rnd(0,10,true), e.yy-rnd(3, 30));
			p.drawBox(rnd(4,16),1, 0xDCA2DD);
			p.dx = d*rnd(4, 8);
			p.frict = 0.85;
			p.life = rnd(0,3);
			register(p);
		}
	}


	public function explosion(x:Float, y:Float, ?intensity=1.0) {
		if( lowq )
			return;

		var p = new Particle(x,y);
		p.drawCircle(25, 0xFFFF80, 1, false, 2);
		p.ds = 0.2;
		p.life = 0;
		register(p);


		for(i in 0...(lowq ? 1 : MLib.ceil(5*intensity))) {
			var p = new Particle(x, y-10);
			if( i==0 ) {
				// Main
				p.drawCircle(16, 0xFFF8BF, 1);
				p.ds = 0.05;
			}
			else {
				// Small
				p.setPos(p.x + rnd(2,15,true), p.y + rnd(2,15,true));
				p.drawCircle(12, 0xFFF8BF, 1);
				p.delay = i + irnd(0,1);
				p.ds = -rnd(0.05, 0.10);
				p.moveAng(rnd(0,6.28), rnd(1,2));
				p.frict = rnd(0.9, 0.97);
			}
			p.filters = [
				new flash.filters.GlowFilter(0xFFCC00, 1, 16,16,2),
				new flash.filters.GlowFilter(0xFF8000, 0.7, 16,16,1),
			];
			p.life = rnd(1,3);
			register(p);
		}
	}


	public function lockActivation(e:Entity) {
		var p = new Particle(e.xx, e.yy-20);
		p.drawCircle(25, 0x97ADD2, 1);
		p.ds = 0.1;
		p.life = 4;
		register(p);

		var p = new Particle(e.xx, e.yy-20);
		p.drawCircle(25, 0x97ADD2, 0.5);
		p.delay = 10;
		p.ds = 0.1;
		p.life = 4;
		register(p);
	}


	public function heroDeath(e:en.Hero) {
		flashBang(0xFF0000, 1, 40);
		explosion(e.xx, e.yy-10, 1);
		shake(2, 800);
	}



	public function bottomDeathHero(x:Float) {
		var s = mode.tiles.getAndPlay("damage", 1, true);
		mode.dm.add(s, Const.DP_FX);
		s.blendMode = BlendMode.ADD;
		s.setCenter(0.5, 0);
		s.scaleX = 2;
		s.scaleY = -s.scaleX;
		s.x = x;
		s.y = Const.HEI;
	}


	public function bottomDeathMob(x:Float) {
		var s = mode.tiles.getAndPlay("damage", 1, true);
		mode.dm.add(s, Const.DP_FX);
		s.blendMode = BlendMode.ADD;
		s.setCenter(0.5, 0);
		s.scaleX = 1;
		s.scaleY = -s.scaleX;
		s.x = x;
		s.y = Const.HEI;
	}


	public function exit() {
		shake(2, 200);

		var e = mode.asProgression().exit;
		var x = e.xx;
		var y = e.yy-23;
		var h = mode.hero;
		var a = Math.atan2(y-(h.yy-20), x-h.xx);

		// Hero ball
		//var p = new Particle( h.xx, h.yy-20 );
		//p.drawCircle(25, 0xFFFF80);
		//p.frict = 0.85;
		//p.ds = -0.03;
		//p.moveAng( a, 15 );
		//p.life = 10;
		//p.filters = [ new flash.filters.GlowFilter( 0xFF8080, 1, 16,16, 2) ];
		//register(p);

		flashBang(0x0080FF, 1);

		// Light lines
		var n = 70;
		for(i in 0...n) {
			var a = a + rnd(0, 1.6,true);
			var s = rnd(30,35);
			var s = 50;
			var dist = rnd(0.5, 0.8);
			var p = new Particle(x-Math.cos(a)*s*dist*10, y-Math.sin(a)*s*dist*10);
			p.drawBox(rnd(5,12), 2, 0xFFFF00);
			p.rotation = MLib.toDeg(a);
			p.moveAng(a, s);
			p.frict = 0.77 + dist*0.15;
			p.delay = i * 0.25;
			p.life = rnd(5, 9);
			p.filters = [ new flash.filters.GlowFilter(Color.makeColorHsl(rnd(0,1), 0.7),1, 8,8, 4) ];
			register(p);
		}
	}


	public function slam(x,y) {
		var p = new Particle(x,y);
		p.drawCircle(30, 0x00FFFF);
		p.scaleY = 0.3;
		p.life = 0;
		p.ds = 0.1;
		p.filters = [ new flash.filters.BlurFilter(8,8) ];
		register(p);
	}

	public function spawn(x:Float,y:Float) {
		var p = new Particle(x,y-10);
		p.drawCircle(25, 0xFF0000);
		p.life = 2;
		p.ds = -0.07;
		p.filters = [ new flash.filters.BlurFilter(16,16) ];
		register(p);
	}

	public function spawnKP(e:en.it.KPoint) {
		var p = new Particle(e.xx, e.yy-10);
		p.drawCircle(30, 0x00A6FF);
		p.life = 4;
		p.ds = 0.07;
		p.filters = [ new flash.filters.BlurFilter(16,16) ];
		register(p);
	}


	public function phaseOut(e:Entity) {
		//var angs = [0, 1.48, 3.14, -1.48];
		for(i in 0...40) {
			var p = new Particle(e.xx+rnd(0,5,true), e.yy-rnd(5,25));
			p.drawBox(rnd(2,7),2, 0xDED0FB,1);
			p.filters = [ new flash.filters.GlowFilter(0x824DF0,1, 8,8,2) ];
			//var a = angs[Std.random(angs.length)];
			var a = rnd(0, 6.28);
			p.moveAng(a, rnd(2,16));
			p.frict = 0.91;
			p.life = rnd(5, 30);
			p.rotation = MLib.toDeg(a);
			register(p);
		}

		var p = new Particle(e.xx, e.yy-10);
		p.drawCircle(50, 0xA078F3, 1, false);
		p.life = 3;
		p.ds = -0.1;
		p.onUpdate = function() {
			p.ds*=0.5;
		}
		register(p);
	}

	public function pickKP(e:en.it.KPoint) {
		var col = switch( e.kp.frame ) {
			case 1 : 0x80FF00;
			case 2 : 0xFF9300;
			case 3 : 0x009FFF;
			case 4 : 0xFF80FF;
			default : 0xFF0000;
		}
		var p = new Particle(e.xx, e.yy-10);
		p.drawCircle(30, col, 0.3);
		p.life = 3;
		p.ds = 0.8;
		p.onUpdate = function() {
			p.ds*=0.5;
		}
		p.filters = [ new flash.filters.BlurFilter(16,16) ];
		register(p);

		pop(e.xx, e.yy, e.kp.amount.get(), col);

		for(i in 0...30) {
			var p = new Particle(e.xx, e.yy-10);
			p.moveAng( rnd(0,6.28), rnd(12,14) );
			p.life = rnd(10,30);
			p.drawBox(3, 3, col, 1);
			p.gx = rnd(0, 0.5, true);
			p.gy = rnd(0, 0.5, true);
			p.frict = 0.9;
			p.filters = [ new flash.filters.GlowFilter( col, 0.5, 8,8,3) ];
			register(p);
		}
	}

	public function creditLoss(x,y) {
		var p = new Particle(x,y);
		var ct = new flash.geom.ColorTransform();
		var s = mode.tiles.get("heart", 1);
		p.addChild(s);
		s.setCenter(0.5, 0.5);
		p.dx = 2;
		p.frict = 0.95;
		p.onUpdate = function() {
			s.visible = !s.visible;
			ct.greenMultiplier = ct.blueMultiplier = 1-p.time();
			ct.alphaMultiplier = 1-p.time()*0.3;
			s.transform.colorTransform = ct;
		}
		s.filters = [ new flash.filters.GlowFilter(0xFF0000, 0.8, 16,16,1) ];
		p.onKill = s.destroy;
		register(p);
	}


	public function flashBang(col:Int, ?alpha=1.0, ?duration=0.) {
		var p = new Particle(0,0);
		p.life = duration;
		p.da = -1/(duration+1);
		p.graphics.beginFill(col, alpha);
		p.graphics.drawRect(0,0, Const.WID, Const.HEI);
		register(p);
	}

	public function shake(power:Float, ms:Float) {
		if( lowq )
			ms*=0.5;
		mode.tw.terminate(mode.root, "y");
		mode.tw.create(mode.root, "y", mode.root.y+8*power, TShakeBoth, ms);
	}



	public function pop(x,y, str:Dynamic, ?col=0xFFBF00) {
		var p = new Particle(x,y);

		var tf = mode.createField(str, col, true);
		tf.filters = [ new flash.filters.GlowFilter(0x0, 1, 2,2, 8) ];

		var bmp = Lib.flatten(tf, 2);
		p.addChild(bmp);
		bmp.scaleX = bmp.scaleY = 2;
		bmp.x = Std.int(-bmp.width*0.5);
		bmp.y = Std.int(-bmp.height);
		p.onKill = function() {
			bmp.bitmapData.dispose();
			bmp.bitmapData = null;
		}

		p.dy = -12;
		p.frictY = 0.8;
		register(p, NORMAL);
	}

	public function rocks() {
		shake(1, 2000);
		var n = 20;
		for(i in 0...n) {
			var p = new Particle(Const.WID*i/n + rnd(0,20,true), 0);

			var s = mode.tiles.getRandom("rocher");
			p.addChild(s);
			s.setCenter(0.5, 0.5);
			p.onKill = p.destroy;

			p.scaleX = p.scaleY = rnd(0.5, 1.5);
			p.dy = rnd(1,8);
			p.delay = rnd(0, 20);
			p.gy = rnd(1.5, 3);
			p.frict = rnd(0.96, 0.99);
			p.rotation = rnd(0,360);
			p.groundY = Const.HEI + rnd(0, 20);
			p.life = rnd(40, 60);
			p.onBounce = function() {
				p.gy = p.dy = 0;
				p.groundY = 99999;
				p.rotation += rnd(20,40,true);
				shake(1,500);
			};
			register(p, NORMAL);
		}
	}

	public function danger(cx) { // warning
		var p = new Particle((cx+0.5)*Const.GRID, 0);

		var bmp = new Bitmap(dangerBd);
		p.addChild(bmp);
		bmp.x = Std.int(-bmp.width*0.5);

		p.pixel = true;
		p.life = 0;
		p.onKill = function() {
			bmp.bitmapData = null;
		}
		register(p);
	}

	public function superPower(e:Entity) {
		powerColor+=0.1;
		if( powerColor>=1 )
			powerColor--;
		var c = Color.randomColor(powerColor);

		// Pelure
		if( perf>=0.7 ) {
			var bmp = Lib.flatten(e.sprite, 8);
			var ct = new flash.geom.ColorTransform();
			ct.color = c;
			bmp.bitmapData.colorTransform( bmp.bitmapData.rect, ct );

			var p = new Particle(e.xx, e.yy);
			p.addChild(bmp);
			p.alpha = 0.5;
			p.da = -0.02;
			p.dx = rnd(0.2, 0.5, true);
			p.dy = rnd(0.2, 0.5, true);
			p.frictX = p.frictY = 0.92;
			p.life = 20 + rnd(0, 2);
			p.scaleX = e.dir;
			p.onKill = function() {
				bmp.bitmapData.dispose();
			}
			register(p, true);
		}

		// Cercles
		var p = new Particle(e.xx+rnd(0,4,true), e.yy-e.radius + rnd(0,4,true));
		p.graphics.lineStyle(1, c, rnd(0.2, 0.5));
		p.graphics.drawCircle(0,0, 20);
		p.ds = rnd(0.02, 0.05);
		p.life = rnd(3, 8);
		p.filters = [ new flash.filters.GlowFilter(c,1, 8,8, 2) ];
		register(p);
	}


	public function phaseSpark() {
		if( lowq )
			return;

		for( i in 0...2 ) {
			var p = new Particle(rnd(30,Const.WID-30), rnd(30,Const.HEI-30));
			p.drawBox(3,3, 0xD9C9FA, rnd(0.4, 1));
			p.moveAng(rnd(0, 6.28), rnd(1,2));
			p.da = rnd(0.03, 0.1);
			p.alpha = 0;
			p.gx = rnd(0, 0.1, true);
			p.gy = rnd(0, 0.1, true);
			p.life = rnd(7,20);
			p.filters = [
				new flash.filters.GlowFilter(0x9A70F1,0.7, 8,8,2),
			];
			register(p);
		}
	}


	public function light(x,y) {
		if( lowq )
			return;

		var p = new Particle(x,y);
		p.drawCircle(90, 0xFFFFCC, 1);
		p.life = 0;
		p.filters = [
			new flash.filters.BlurFilter(32,32),
		];
		register(p, BlendMode.OVERLAY);
	}

	public function spriteFx(k:String, x,y, ?blend:BlendMode) {
		var s = mode.tiles.getAndPlay(k, 1, true);
		mode.dm.add(s, Const.DP_FX);
		s.setCenter(0.5, 1);
		s.alpha = 0.6;
		s.x = x;
		s.y = y;
		s.blendMode = blend==null ? BlendMode.ADD : blend;
		return s;
	}


	public function popScore(x,y, v:Int) {
		var tf = mode.createField(v, 0xFFFF00, true);
		var p = new Particle(x,y);
		p.addChild(tf);
		tf.x = Std.int(-tf.width*0.5);
		tf.y = Std.int(-tf.height);
		tf.filters = [ new flash.filters.GlowFilter(0xFFA600, 0.8, 8,8, 2) ];
		p.dy = -0.3;
		register(p);
	}


	public inline function hit(x,y, n:Int) {
		for(i in 0...n) {
			var p = new Particle(x+rnd(0,10,true), y+rnd(0,10,true));
			p.drawCircle(rnd(9,13), 0xFFFFCC, 0.5);
			p.life = 0;
			p.filters = [
				new flash.filters.GlowFilter(0xFFAC00,1, 16,16, 3),
			];
			register(p);
		}
	}

	public inline function backHit(from:Entity, to:Entity, ?col=0xFFCC00) {
		if( lowq )
			return;
		var fc = from.getCenter();
		var tc = to.getCenter();
		var baseAng = Math.atan2( tc.y-fc.y, tc.x-fc.x );
		for(i in 0...5) {
			var a = baseAng + rnd(0, 0.35, true);
			var p = new Particle(fc.x, fc.y);
			p.drawBox(rnd(5,15), 2, col, rnd(0.4, 0.8));
			p.moveAng(a, rnd(20, 40));
			p.rotation = MLib.toDeg(a);
			p.frictX = p.frictY = rnd(0.80, 0.90);
			p.life = rnd(3, 10);
			p.filters = [ new flash.filters.GlowFilter(col,0.8, 4,4,2) ];
			register(p);
		}
	}

	public function loseLife(x) {
		flashBang(0xFFAC00, 0.5);
		shake(1, 1000);
		var s = mode.tiles.getAndPlay("damage", 1, true);
		mode.dm.add(s, Const.DP_FX);
		s.blendMode = BlendMode.ADD;
		s.setCenter(0.5, 0);
		s.scaleX = s.scaleY = 2;
		s.x = x;
	}

	public function dashTrail(e:Entity, tx:Float, ty:Float) {
		var d = Lib.distance(e.xx,e.yy,tx,ty);
		var a = Math.atan2(ty-e.yy, tx-e.xx);
		var n = MLib.ceil(d/20);
		var dx = Math.cos(a)*d/n;
		var dy = Math.sin(a)*d/n;
		for(i in 0...n) {
			var p = new Particle(e.xx+dx*i, e.yy+dy*i);
			var s = mode.tiles.get("fxDash");
			s.setCenter(0.5, 0.5);
			p.addChild(s);
			p.rotation = MLib.toDeg(a);
			p.onKill = s.destroy;
			p.ds = -rnd(0.02, 0.05);
			p.scaleX = p.scaleY = rnd(1, 2);
			p.life = rnd(5, 10);
			p.alpha = 0.1 + 0.9*(i/n);
			register(p);
		}

		var p = new Particle(tx,ty);
		p.drawCircle(25, 0x0ACCF5, 1);
		p.ds = 0.05;
		p.life = 2;
		register(p);
	}


	public function tutorialPointer(cx,cy) {
		var n = 300;
		var x = (cx+0.5)*Const.GRID;
		var y = (cy+0.5)*Const.GRID;

		var p = new Particle(x,y);
		p.drawCircle(100, 0xFFFF80, 1, false);
		p.filters = [ new flash.filters.GlowFilter(0xFF9900,1, 8,8, 4) ];
		p.ds = -0.08;
		p.onUpdate = function() p.ds*=0.85;
		p.life = 60;
		register(p);

		for(i in 0...n) {
			var a = rnd(0, 6.28);
			var x = x + Math.cos(a)*40;
			var y = y + Math.sin(a)*40;
			var p = new Particle(x,y);
			p.drawCircle(rnd(3,5), 0xFFFF80);
			p.delay = i*0.35 + rnd(0,50);
			p.alpha = 0;
			p.da = 0.15;
			p.moveAng(a+1.48, 2);
			p.frict = 0.95;
			p.life = rnd(15,25);
			p.filters = [ new flash.filters.BlurFilter(4,4), new flash.filters.GlowFilter(0xFF9900,1, 16,16, 2) ];
			register(p);
		}
	}


	public function sparks(x,y, dir) {
		for(i in 0...(lowq?2:5)) {
			var p = new Particle(x,y);
			var w = Std.random(100)<20 ? 2 : 1;
			p.drawBox(w,w, 0xFFFF00, rnd(0.5, 1));
			p.alpha = 0;
			p.da = 0.2;
			p.dx = -dir * rnd(0, 2);
			p.dy = -rnd(0.2, 2);
			p.rotation = MLib.toDeg(Math.atan2(p.dy,p.dx));
			if( Std.random(100)<30 )
				p.dx *= 3;
			if( Std.random(100)<30 )
				p.dy *= 5;
			p.gy = rnd(0.1, 0.3);
			p.life = rnd(5, 15);
			p.frictX = p.frictY = 0.95;
			p.filters = [ new flash.filters.GlowFilter(0xFF8600,1, 8,8, 6) ];
			register(p);
		}

	}

	public inline function update() {
		perf = api.AKApi.getPerf();
		Particle.update();
	}
}
