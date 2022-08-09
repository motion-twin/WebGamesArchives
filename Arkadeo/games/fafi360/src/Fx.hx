import flash.display.BlendMode;
import flash.display.Sprite;

import mt.MLib;
import mt.deepnight.Particle;
import mt.deepnight.Lib;
import mt.deepnight.Color;

class Fx {
	var game		: Game;

	public function new() {
		game = Game.ME;
		Particle.LIMIT = 100;
	}

	public function register(p:Particle, ?b:BlendMode, ?bg=false) {
		game.sdm.add(p, bg ? Game.DP_FX_BG : Game.DP_FX);
		p.blendMode = b!=null ? b : BlendMode.ADD;
	}

	inline function rnd(min,max,?sign) { return Lib.rnd(min,max,sign); }
	inline function irnd(min,max,?sign) { return Lib.irnd(min,max,sign); }



	public function smoke(x:Float,y:Float) {
		var p = new Particle(x+rnd(0,7,true), y-rnd(0,2));
		p.drawBox(rnd(3,6),rnd(3,6), 0xDCDFA2, rnd(0.3, 0.8));
		p.reset();
		p.dr = rnd(5,10,true);
		p.gy = -rnd(0.01, 0.06);
		p.filters = [ new flash.filters.BlurFilter(8,8) ];
		p.life = rnd(3,10);
		register(p, BlendMode.NORMAL, true);
	}


	public function snowWalk(x:Float,y:Float) {
		if( game.lowq )
			return;
		var p = new Particle(x+rnd(0,5,true), y-rnd(0,2));
		p.drawBox(2,2, 0xF0F5F7, rnd(0.3, 0.8));
		p.reset();
		//p.dr = rnd(5,10,true);
		p.gy = rnd(0.2, 0.3);
		p.frictX = p.frictY = 0.9;
		p.dx = rnd(0.1, 0.5, true);
		p.dy = -rnd(1,3);
		p.groundY = y;
		p.filters = [ new flash.filters.BlurFilter(2,2) ];
		p.life = rnd(10,20);
		register(p, BlendMode.NORMAL);
	}

	public function waterHit(x:Float,y:Float, power:Float, ?col=0xB6EAF3) {
		if( game.lowq )
			return;

		var w = rnd(7,13);
		var p = new Particle(x,y);
		p.reset();
		p.graphics.lineStyle(1,col,0.1, true, NONE);
		p.graphics.drawEllipse(-w*0.5,-w*0.25,w,w/2);
		p.ds = rnd(0.04, 0.08);
		p.life = rnd(5,10);
		register(p, true);

		for(i in 0...Math.ceil(power*5) ) {
			var p = new Particle(x+rnd(0,5,true), y-rnd(0,2));
			p.drawBox(2,rnd(1,3), col, rnd(0.3, 0.8));
			p.reset();
			//p.dr = rnd(5,10,true);
			p.gy = rnd(0.2, 0.3);
			p.frictX = p.frictY = 0.9;
			p.dx = rnd(0.1, 0.5, true);
			p.dy = -rnd(1,8)*power;
			p.groundY = y;
			//p.filters = [ new flash.filters.BlurFilter(2,2) ];
			p.life = rnd(10,20);
			register(p, BlendMode.NORMAL);
		}
	}

	public function hit(x,y, ?scale=1.0, ?alpha=1.0) {
		var p = new Particle(x,y);
		p.reset();
		p.graphics.lineStyle(1,0xFFFF80, 0.6*alpha, true, NONE);
		p.graphics.drawCircle(0,0,2);
		p.scaleX = p.scaleY = scale;
		p.ds = 0.5;
		p.onUpdate = function() {
			p.ds*=0.8;
		}
		p.life = 3;
		register(p);
	}

	public function popHalo(x,y, col) {
		var p = new Particle(x,y);
		p.reset();
		p.drawCircle(20, col, 0.2);
		p.scaleX = p.scaleY = 0.01;
		p.ds = 0.5;
		p.onUpdate = function() {
			p.ds*=0.7;
		}
		p.life = 3;
		register(p);
	}

	public function glow(e:Entity, col:Int, dms:Float) {
		var o = {t:0.}
		var a = game.tw.create(o, "t", 1, TEaseOut, dms);
		a.onUpdate = function() {
			e.spr.filters = [ new flash.filters.GlowFilter(col, 1-o.t, 2,2,8) ];
		}
		a.onEnd = function() {
			e.spr.filters = [];
		}
	}

	public function pick(x,y, col) {
		for(i in 0...8) {
			var p = new Particle(x+rnd(0,6,true), y+rnd(0,4,true));
			p.reset();
			p.drawBox(1,1,col, rnd(0.6, 1));
			p.dy = -rnd(2,4);
			//p.gy = -rnd(0.02, 0.06);
			p.frictY = 0.94;
			p.life = rnd(10,20);
			p.filters = [
				new flash.filters.GlowFilter(col, 0.8, 8,8,8),
			];
			register(p);
		}
	}

	public function flashBang(col:Int, alpha:Float, duration:Int) {
		var s = new Sprite();
		game.buffer.dm.add(s, Game.DP_FX);
		s.graphics.beginFill(col, alpha);
		s.graphics.drawRect(0,0,game.buffer.width, game.buffer.height);
		s.blendMode = BlendMode.ADD;
		game.tw.create(s, "alpha", 0, TEaseIn, duration).onEnd = function() {
			s.parent.removeChild(s);
		}
	}

	public function smokeGroundHit(e:Entity) {
		if( game.lowq )
			return;

		for(i in 0...4) {
			var p = new Particle(e.xx+rnd(0,4,true), e.yy+rnd(0,4,true));
			p.reset();
			var s = game.tiles.get("smoke");
			s.setCenter(0.5,0.5);
			p.addChild(s);
			var s = rnd(0.5, 1);
			p.scaleX = s * (Std.random(2)*2-1);
			p.scaleY = s * (Std.random(2)*2-1);
			p.dx = -rnd(0.5, 1.5, true);
			//p.dy = -rnd(1.5, 4);
			p.dr = rnd(2,5,true);
			p.transform.colorTransform = Color.getColorizeCT(0xE9BB67, 1);
			p.alpha = rnd(0.2, 0.8);
			//p.gy = -rnd(0.02, 0.06);
			p.frictX = 0.92;
			p.frictY = 0.92;
			p.life = rnd(20,30);
			register(p, BlendMode.NORMAL, true);
		}
	}

	public function itemSpark(x:Float,y:Float) {
		if( game.lowq )
			return;

		var p = new Particle(x+rnd(0,4,true), y-rnd(0,7));
		p.reset();
		p.drawBox(1,1, 0xFFFF00, rnd(0.1,0.6));
		p.dy = -0.6;
		p.frictY = 0.97;
		p.filters = [ new flash.filters.GlowFilter(0xFFCC00, 1, 4,4,3) ];
		register(p);
	}


	public function popKPoint(x:Float,y:Float, pk:api.AKProtocol.SecureInGamePrizeTokens) {
		var col = switch(pk.frame) {
			case 1 : 0x74E800;
			case 2 : 0xFE9901;
			case 3 : 0x51A8FF;
			case 4 : 0xFF5EC2;
			default : 0xFFFFFF;
		}

		var tf = game.createField( Std.string(pk.amount.get()+" PK"), true ); // TODO trad
		tf.textColor = col;
		tf.filters = [
			new flash.filters.GlowFilter(Color.setLuminosityInt(col,0.3),1, 2,2,10),
			new flash.filters.GlowFilter(0xFFFFFF,1, 2,2,10)
		];

		var bmp = Lib.flatten(tf);

		var p = new Particle(x,y);
		p.reset();
		p.addChild(bmp);
		p.dy = -16;
		p.frictY = 0.8;
		p.x = Std.int(x - p.width*0.5*p.scaleX);
		p.y = Std.int(y - p.height*0.5*p.scaleY);
		p.onKill = function() {
			bmp.bitmapData.dispose();
		}
		register(p, BlendMode.NORMAL);
		return tf;
	}


	public function popPass(x:Float,y:Float, n:Int) {
		var txt = n<0 ? Lang.LostBall : n==1 ? Lang.Pass({_n:n}) : Lang.Passes({_n:n});
		var c = 0xB6C7D3;
		if( n<0 )
			c = 0xFF3C3C;
		if( n>=Game.PASS_THRESHOLD )
			c = 0xFFC600;
		var tf = game.createField(txt, true );
		tf.textColor = c;
		tf.filters = [
			new flash.filters.GlowFilter(Color.setLuminosityInt(c,0.3),1, 2,2,10),
			new flash.filters.GlowFilter(0xFFFFFF,1, 2,2,10)
		];

		var bmp = Lib.flatten(tf);

		var p = new Particle( Std.int(x-bmp.width*0.5), y);
		p.reset();
		p.addChild(bmp);
		p.dy = -16;
		p.frictY = 0.8;
		p.onKill = function() {
			bmp.bitmapData.dispose();
		}
		register(p, BlendMode.NORMAL);
		return tf;
	}


	public function popTime(x:Float,y:Float, n:Int) {
		var tf = game.createField(Lang.PickTime({_n:n}), true );
		tf.textColor = 0xD5F1FF;
		tf.filters = [
			new flash.filters.GlowFilter(0x2D2941,1, 2,2,10),
			new flash.filters.GlowFilter(0x82D7FF,1, 2,2,10)
		];

		var bmp = Lib.flatten(tf);

		var p = new Particle( Std.int(x-bmp.width*0.5), y);
		p.reset();
		p.addChild(bmp);
		p.dy = -16;
		p.frictY = 0.8;
		p.onKill = function() {
			bmp.bitmapData.dispose();
		}
		register(p, BlendMode.NORMAL);
		return tf;
	}



	public function popScore(x:Float,y:Float, v:Int, ?col=0xFFFFFF, ?big=false) {
		var tf = game.createField( Std.string(v), true );
		tf.textColor = col;
		tf.filters = [];
		var bmp = Lib.flatten(tf);
		//var bmp = mt.deepnight.Lib.flatten(tf);

		var p = new Particle(Std.int(x - bmp.width*0.5), Std.int(y - bmp.height*0.5));
		p.reset();
		p.addChild(bmp);
		p.scaleX = p.scaleY = big ? 2 : 1;
		p.dy = -16;
		p.frictY = 0.8;
		p.filters = [
			new flash.filters.GlowFilter(col,0.4, 4,4,1),
		];
		p.onKill = function() {
			bmp.bitmapData.dispose();
		}
		register(p);
		return tf;
	}


	public function smokePop(x,y) {
		// ombre fantome
		var p = new Particle(x,y);
		p.reset();
		p.drawCircle(6, 0x0, 0.25);
		p.scaleY = 0.75;
		p.life = rnd(4,8);
		register(p, BlendMode.NORMAL);

		for(i in 0...(game.lowq ? 1 : 4)) {
			var p = new Particle(x+rnd(0,4,true), y+rnd(0,4,true));
			p.reset();
			var s = game.tiles.get("smoke");
			s.setCenter(0.5,0.5);
			p.addChild(s);
			var s = rnd(0.7, 1.2);
			p.scaleX = s * (Std.random(2)*2-1);
			p.scaleY = s * (Std.random(2)*2-1);
			p.dy = -rnd(1.5,4);
			p.dr = rnd(2,5,true);
			p.alpha = rnd(0.4, 0.7);
			//p.gy = -rnd(0.02, 0.06);
			p.frictY = 0.92;
			p.life = rnd(20,30);
			register(p);
		}
	}

	public function airGrab(e:en.Player) {
		var p = new Particle(e.xx, e.yy-20);
		p.reset();
		p.graphics.beginFill(0xFFFF00, 0.7);
		p.graphics.drawCircle(0,0,8);
		p.graphics.endFill();
		p.scaleX = p.scaleY = 1;
		p.life = 1;
		p.ds = 0.1;
		register(p);

		for(i in 0...18) {
			var p = new Particle(e.xx,e.yy);
			p.reset();
			p.drawBox(5,5, 0xDCDFA2, rnd(0.3, 0.6));
			var a = rnd(0,6.28);
			var s = rnd(3,5);
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s*0.6;
			p.frictX = p.frictY = 0.9;
			p.life = rnd(30,40);
			p.filters = [ new flash.filters.BlurFilter(2,2) ];
			register(p, BlendMode.NORMAL, true);
		}
	}

	public function clash(a:Entity, b:Entity) {
		var x = a.xx + (b.xx-a.xx)*0.5;
		var y = a.yy + (b.yy-a.yy)*0.5;
		var p = new Particle(x,y);
		p.reset();
		p.graphics.beginFill(0xFFFF80, 0.5);
		p.graphics.drawCircle(0,0,10);
		p.graphics.drawCircle(-1,-1, 8);
		p.graphics.endFill();
		p.scaleX = p.scaleY = 0.3;
		p.dr = rnd(4,6, true);
		p.life = 4;
		p.ds = 0.8;
		p.onUpdate = function() {
			p.ds*=0.6;
		}
		p.filters = [
			new flash.filters.GlowFilter(0xFFFF80, 1, 8,8,1),
		];

		register(p);
	}

	public function marker(x,y, ?col=0xFFFF00) {
		#if debug
		var p = new Particle(x,y);
		p.reset();
		p.graphics.lineStyle(3, col, 1);
		p.graphics.drawCircle(0,0, 10);
		p.scaleY = 0.6;
		p.life = 60;
		p.filters = [ new flash.filters.GlowFilter(0x0,0.5, 2,2, 3) ];
		register(p, BlendMode.NORMAL);
		#end
	}

	public function radius(x,y, r, ?c=0xFFFF00) {
		#if debug
		var p = new Particle(x,y);
		p.reset();
		p.graphics.lineStyle(2, c, 1);
		p.graphics.drawCircle(0,0,r);
		p.life = 60;
		p.filters = [ new flash.filters.GlowFilter(0x0,0.5, 2,2, 3) ];
		register(p, BlendMode.NORMAL);
		#end
	}

	public function explosion(x,y, radius) {
		// Trou noir 1
		var mc = new lib.Taches();
		mc.gotoAndStop( Std.random(mc.totalFrames)+1 );
		mc.rotation = rnd(0,360);
		mc.alpha = 0.5;
		var wrap = new Sprite();
		wrap.addChild(mc);
		wrap.x = x;
		wrap.y = y;
		wrap.scaleY = 0.6;
		wrap.filters = [ new flash.filters.DropShadowFilter(2,90, 0x0,1, 0,0,1, 1,true) ];
		game.ground.draw(wrap, wrap.transform.matrix);

		// Trou noir 2
		var mc = new lib.Taches();
		mc.gotoAndStop( Std.random(mc.totalFrames)+1 );
		mc.rotation = rnd(0,360);
		mc.alpha = 0.2;
		var wrap = new Sprite();
		wrap.addChild(mc);
		wrap.x = x;
		wrap.y = y;
		wrap.scaleX = 2;
		wrap.scaleY = 2.5*0.6;
		game.ground.draw(wrap, wrap.transform.matrix);

		// Halo
		var p = new Particle(x,y);
		p.reset();
		p.graphics.beginFill(0xFF0000, 0.5);
		p.graphics.drawCircle(0,0,radius);
		p.graphics.endFill();
		p.scaleX = p.scaleY = 1;
		p.life = 1;
		register(p);

		var mc = new lib.Badaboom();
		var p = new Particle(x,y);
		p.reset();
		p.addChild(mc);
		p.life = 20;
		register(p, BlendMode.NORMAL);

		if( !game.lowq )
			for(i in 0...14) {
				var high = i>=7;
				var p = new Particle(x,y);
				p.reset();
				p.drawBox(5,rnd(3,5), 0x8F5630, rnd(0.5, 1));
				p.dr = rnd(5,10,true);
				p.dx = rnd(0,1,true);
				p.dy = high ? -rnd(6,10) : -rnd(3,5);
				p.gy = 0.3;
				p.bounce = 0.5;
				p.groundY = y + rnd(0,10,true);
				p.filters = [
					new flash.filters.GlowFilter(0x0,0.5, 2,2,1),
					new flash.filters.DropShadowFilter(3,90, 0x0,0.5,0,0,1, 1,true),
				];
				register(p, BlendMode.NORMAL);
			}
	}

	public function ballTrail(b:en.Ball, alpha:Float) {
		if( game.lowq )
			return;

		var p = new Particle(b.spr.x, b.spr.y);
		p.reset();
		p.graphics.beginFill(0xFFFF80, alpha*0.1);
		p.graphics.drawCircle(0, -4, en.Ball.RADIUS);
		p.ds = -0.03;
		p.filters = [new flash.filters.BlurFilter(8,8)];
		p.life = 15;
		register(p);
	}

	public function fireTrail(b:en.Ball) {
		for(i in 0...(game.lowq ? 2 : 5)) {
			var p = new Particle(b.spr.x+rnd(0,5,true), b.spr.y-3+rnd(0,5,true));
			p.reset();
			p.drawBox(1,1, 0xFFFF00, rnd(0.1, 0.5));
			p.filters = [  new flash.filters.GlowFilter(0xEE40DD,1, 4,4,10) ];
			p.life = 15;
			p.gy = 0.1;
			p.groundY = p.y+b.z;
			//p.onUpdate = function() {
				//p.alpha = rnd(0.5,1);
			//}
			register(p);
		}
	}

	public function surprise(e:en.Player) {
		var n = 4;
		for(i in 0...n) {
			var p = new Particle(e.xx, e.yy-32);
			p.reset();
			p.drawBox(4,1, 0xFFFFFF);
			p.life = 5;
			p.rotation = -25 - i * 140/(n-1);
			var a = MLib.toRad(p.rotation);
			var s = 3.5;
			p.dx = Math.cos(a)*s + e.dx*15;
			p.dy = Math.sin(a)*s + e.dy*15;
			p.frictX = p.frictY = 0.85;
			register(p);
			//e.spr.addChild(p);
		}
	}

	public function lightSlash(x,y,a) {
		for(i in 0...(game.lowq ? 5 : 14)) {
			var p = new Particle(x+rnd(0,5,true), y+rnd(0,5,true)-4);
			p.reset();
			p.drawBox(rnd(2,7),1, 0xFFFF80, rnd(0.3,0.6));
			p.rotation = MLib.toDeg(a);
			var s = i%4==0 ? rnd(0.5,1) : rnd(5, 7);
			//var a2 = i%4==0 ? a+3.14 : a;
			var a2 = a;
			p.dx = Math.cos(a2)*s;
			p.dy = Math.sin(a2)*s;
			p.frictX = p.frictY = 0.92;
			p.filters = [ new flash.filters.GlowFilter(0xFFAC00,0.9, 8,8,3) ];
			p.life = rnd(1,5);
			register(p);
		}
	}

	public function grass(x:Float,y:Float, n:Int) {
		if( game.lowq )
			return;

		for(i in 0...n) {
			var p = new Particle(x+rnd(0,5,true), y+rnd(0,5,true));
			p.reset();
			p.drawBox(rnd(1,3),1, 0x95D01A, rnd(0.6, 1));
			p.dx = rnd(0.5,2,true);
			p.dy = -rnd(2,5);
			p.dr = rnd(8,15,true);
			p.gy = 0.5;
			p.frictX = p.frictY = 0.92;
			p.life = rnd(8,20);
			p.bounce = 0.5;
			p.groundY = y;
			register(p, BlendMode.NORMAL, true);
		}
	}


	public function grassKick(x:Float,y:Float, ang:Float, n:Int) {
		if( game.lowq )
			return;

		for(i in 0...n) {
			var p = new Particle(x+rnd(0,5,true), y+rnd(0,5,true));
			p.reset();
			p.drawBox(rnd(1,3),1, 0xA5E421, rnd(0.7, 1));
			var s = rnd(0.5,8);
			var a = ang+rnd(0, 0.2, true);
			if( i%4==0 )
				a+=3.14;
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s;
			p.dr = rnd(8,15,true);
			p.frictX = p.frictY = 0.92;
			p.life = rnd(12,30);
			var z = 0.;
			var dz = rnd(0.5, 3);
			p.onUpdate = function() {
				z+=dz;
				dz-=0.3;
				if( z<0 ) {
					dz *= -0.5;
					z = 0;
				}
				p.y-=z;
			}
			register(p, BlendMode.NORMAL, true);
		}
	}


	public function update() {
		Particle.update();
	}
}