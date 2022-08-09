import flash.display.BlendMode;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

import mt.MLib;
import mt.deepnight.slb.BSprite;
import mt.deepnight.FParticle;
import mt.deepnight.Lib;
import mt.deepnight.Tweenie;
import mt.deepnight.Color;

class Fx {
	var game			: m.Game;
	public var lowq		: Bool;
	var pool			: BitmapDataPool;
	var cd				: mt.Cooldown;

	public function new() {
		cd = new mt.Cooldown();
		FParticle.LIMIT = 150;
		game = m.Game.ME;
		lowq = false;
		pool = new BitmapDataPool();

		// Teleport
		var s = new Sprite();
		s.graphics.beginFill(0x0080FF,1);
		s.graphics.drawCircle(0,0,30);
		s.filters = [ new flash.filters.BlurFilter(8,8,2) ];
		pool.addDisplayObject("teleport", s, 8);

		// Ball trail (green)
		var s = new Sprite();
		s.graphics.beginFill(0x80FF00,0.5);
		s.graphics.drawCircle(8,8,8);
		s.filters = [ new flash.filters.BlurFilter(8,8,2) ];
		pool.addDisplayObject("trailGreen", s, 8);

		// Ball trail (red)
		var s = new Sprite();
		s.graphics.beginFill(0xFF0000,1);
		s.graphics.drawCircle(8,8,8);
		s.filters = [ new flash.filters.BlurFilter(8,8,2) ];
		pool.addDisplayObject("trailRed", s, 8);

		// Auto kick warning
		var s = new Sprite();
		var tf = m.Global.ME.createField("!",FSmall,true);
		tf.textColor = 0xFFFF80;
		tf.filters = [
			new flash.filters.GlowFilter(0xFF8000,1, 2,2,4),
			new flash.filters.GlowFilter(0xCC0000,1, 8,8,2),
		];
		tf.scaleX = tf.scaleY = 2;
		s.addChild(tf);
		pool.addDisplayObject("kickWarning", s, 4);

		// Generic hit
		var s = new Sprite();
		s.graphics.lineStyle(1, 0xFFFF80, 1);
		s.graphics.drawCircle(0,0,10);
		s.filters = [ new flash.filters.GlowFilter(0xFFBF00,1, 8,8,3, 2) ];
		pool.addDisplayObject("hit", s, 8);

		// item spark
		var s = new Sprite();
		s.graphics.beginFill(0xffffff,1);
		s.graphics.drawRect(0,0,1,1);
		s.filters = [
			new flash.filters.GlowFilter(0xFFBF00,1, 4,4,6, 2),
			new flash.filters.GlowFilter(0xFF7900,1, 8,8,3, 2)
		];
		pool.addDisplayObject("itemSpark", s, 12);

		// grass
		var s = new Sprite();
		s.graphics.beginFill(0x95A330,1);
		s.graphics.drawRect(0,0,3,1);
		s.filters = [
			new flash.filters.GlowFilter(0x95A330,0.5, 2,2,4),
			new flash.filters.DropShadowFilter(1,90, 0x5E661E,0.5, 0,0),
		];
		pool.addDisplayObject("grass", s, 3);

		// Bowling Hit
		var s = new Sprite();
		s.graphics.beginFill(0xFFFF80,1);
		s.graphics.drawCircle(0,0,20);
		s.filters = [ new flash.filters.GlowFilter(0xFFBF00,1, 16,16,3) ];
		pool.addDisplayObject("bowlingHit", s, 16);

		// Surprise line
		var s = new Sprite();
		s.graphics.beginFill(0xFFFFFF,1);
		s.graphics.drawRect(0,0, 5,1);
		s.filters = [ new flash.filters.GlowFilter(0xFFFFFF,0.5, 8,8,3) ];
		pool.addDisplayObject("surprise", s, 8);

		// Water slip
		var s = new Sprite();
		s.graphics.beginFill(0xAED7FF,1);
		s.graphics.drawRect(0,0, 6,1);
		s.filters = [ new flash.filters.GlowFilter(0x379BFF,0.5, 8,8,3) ];
		pool.addDisplayObject("waterSlip", s, 8);

		// Electric Hit
		var s = new Sprite();
		s.graphics.beginFill(0x8080C0,1);
		s.graphics.drawCircle(0,0,50);
		s.filters = [ new flash.filters.GlowFilter(0x4B28D7,1, 16,16,3) ];
		pool.addDisplayObject("electricHit", s, 16);

		// Electricity
		var s = new Sprite();
		s.graphics.lineStyle(1, 0xBFFBFF, 1, true, NONE);
		s.graphics.moveTo(0,0);
		s.graphics.lineTo(8,-3);
		s.graphics.lineTo(12,2);
		s.graphics.moveTo(8,-3);
		s.graphics.lineTo(10,4);
		s.filters = [ new flash.filters.GlowFilter(0x00ACFF,1, 8,8,3) ];
		pool.addDisplayObject("electricityLow", s, 8);
		s.filters = [ new flash.filters.GlowFilter(0xFC32F7,1, 8,8,3) ];
		pool.addDisplayObject("electricityHigh", s, 8);

		// Init pool
		pool.addBitmapData("fbang", [new BitmapData(50,50, true, 0xffFFCC00)]);
		pool.addBitmapData("leaves", game.tiles.getAllBitmapDatas("fxWind_orange"));
		pool.addBitmapData("redCard", [game.tiles.getBitmapData("cartonRouge")]);
		pool.addBitmapData("yellowCard", [game.tiles.getBitmapData("cartonJaune")]);
		pool.addBitmapData("smoke", game.tiles.getAllBitmapDatas("fxMiniSprout"));

		// Explosion holes
		var pt0 = new flash.geom.Point();
		var s = new Sprite();
		var bmp = new Bitmap();
		s.addChild(bmp);
		var ct = new flash.geom.ColorTransform();
		ct.color = 0x432C27;
		for(bd in game.tiles.getAllBitmapDatas("taches")) {
			bmp.bitmapData = bd;
			bmp.scaleX = 1;
			bmp.scaleY = 0.75;
			bmp.alpha = rnd(0.7, 0.9);
			bd.colorTransform(bd.rect, ct);
			//bd.applyFilter(bd, bd.rect,	pt0, new flash.filters.DropShadowFilter(1,90, 0x0,0.2, 0,0,1, 1,true));
			pool.addDisplayObject("expHole", s);
			bd.dispose();
		}

		// Explosion hole halos
		for(bd in game.tiles.getAllBitmapDatas("taches")) {
			bmp.bitmapData = bd;
			bmp.scaleX = 2;
			bmp.scaleY = 1.5;
			bmp.alpha = rnd(0.4, 0.55);
			bd.colorTransform(bd.rect, ct);
			//bd.applyFilter(bd, bd.rect,	pt0, new flash.filters.DropShadowFilter(1,90, 0x0,0.2, 0,0,1, 1,true));
			//bd.applyFilter(bd, bd.rect,	pt0, new flash.filters.BlurFilter(4,2));
			pool.addDisplayObject("expHoleHalo", s, 4);
			bd.dispose();
		}
		bmp.bitmapData = null;
		bmp = null;
	}


	public function register(p:FParticle, ?b:BlendMode, ?bg=false) {
		game.sdm.add(p, bg ? Const.DP_FX_BG : Const.DP_FX);
		p.blendMode = b!=null ? b : BlendMode.ADD;
		p.filters = [];
	}

	inline function rnd(min,max,?sign) { return Lib.rnd(min,max,sign); }
	inline function irnd(min,max,?sign) { return Lib.irnd(min,max,sign); }


	public function destroy() {
		FParticle.clearAll();
		pool.destroy();
	}


	public function smoke(x:Float,y:Float) {
		var p = new FParticle(x+rnd(0,7,true), y-rnd(0,2));
		p.useBitmapData( pool.getRandom("smoke"), false );
		p.reset();
		if( !lowq )
			p.dr = rnd(5,10,true);
		p.gy = -rnd(0.01, 0.06);
		p.life = rnd(3,10);
		register(p, BlendMode.NORMAL, true);
	}



	public function hit(x,y, ?scale=1.0, ?alpha=1.0) {
		var p = new FParticle(x,y);
		p.useBitmapData( pool.get("hit"), false );
		p.scaleX = p.scaleY = scale*0.2;
		p.ds = 0.5;
		p.onUpdate = function() {
			p.ds*=0.7;
		}
		p.life = 3;
		p.fadeOutSpeed = 0.2;
		register(p);
	}

	public inline function flashBang(col:Int, alpha:Float, duration:Int) {
		if( lowq || cd.has("fbang") )
			return;

		cd.set("fbang", Const.seconds(1));
		var bmp = new Bitmap( pool.get("fbang") );
		game.gdm.add(bmp, Const.DP_FX);
		bmp.bitmapData.fillRect( bmp.bitmapData.rect, Color.addAlphaF(col, alpha) );
		bmp.width = Const.WID;
		bmp.height = Const.HEI;
		bmp.blendMode = ADD;
		game.tw.create(bmp.alpha, 0, TEaseIn, duration).onEnd = function() {
			bmp.parent.removeChild(bmp);
			bmp.bitmapData = null;
		}
	}

	public function smokeGroundHit(e:Entity) {
		if( lowq )
			return;

		for(i in 0...4) {
			var p = new FParticle(e.xx+rnd(0,4,true), e.yy+rnd(0,4,true));
			p.useBitmapData( pool.getRandom("smoke"), false );
			p.dx = -rnd(1, 1.5, true);
			p.alpha = rnd(0.7, 1);
			p.frict = 0.92;
			p.life = rnd(15,30);
			register(p, BlendMode.NORMAL);
		}
	}

	public function itemSpark(x:Float,y:Float) {
		if( lowq )
			return;

		for(i in 0...2) {
			var p = new FParticle(x+rnd(2,8,true), y-rnd(0,7));
			p.useBitmapData( pool.get("itemSpark"), false );
			p.dy = -rnd(0.7, 0.9);
			p.frictY = rnd(0.97, 0.99);
			register(p);
		}
	}



	public function pop(x:Float,y:Float, str:String, ?col=0xD5F1FF) {
		if( !game.hud.wrapper.visible )
			return;

		var id = "str:"+str;
		if( !pool.exists(id) ) {
			var tf = m.Global.ME.createField(str, FBig, true );
			tf.textColor = 0xffffff;
			tf.filters = [
				new flash.filters.GlowFilter(Color.setLuminosityInt(0xD5F1FF,0.1),1, 2,2,10),
				new flash.filters.GlowFilter(col,1, 2,2,10)
			];
			pool.addDisplayObject(id, tf);
		}

		var p = new FParticle( x, y);
		p.reset();
		p.useBitmapData( pool.get(id), false );
		p.dy = -16;
		p.frictY = 0.8;
		register(p, BlendMode.NORMAL);
	}


	public function autoKickWarn(e:en.Player) {
		var e = game.ball;
		var p = new FParticle(e.xx, e.yy-45);
		p.useBitmapData( pool.get("kickWarning"), false);
		p.life = 2;
		p.fadeOutSpeed = 0.3;
		register(p, NORMAL);
	}


	public function say(e:Entity, str:String) {
		var id = "str:"+str;
		if( !pool.exists(id) ) {
			var tf = m.Global.ME.createField(str, FBig, true );
			tf.textColor = 0xffffff;
			pool.addDisplayObject(id, tf);
		}

		var p = new FParticle( e.xx, e.yy-25);
		p.reset();
		p.useBitmapData( pool.get(id), false );
		p.dy = -8;
		p.frictY = 0.8;
		register(p, BlendMode.NORMAL);
	}

	public function popTime(x:Float,y:Float, n:Int) {
		var id = "time"+n;
		if( !pool.exists(id) ) {
			var tf = m.Global.ME.createField(Lang.PickTime({_n:n}), FBig, true );
			tf.textColor = 0xD5F1FF;
			tf.filters = [
				new flash.filters.GlowFilter(0x2D2941,1, 2,2,10),
				new flash.filters.GlowFilter(0x82D7FF,1, 2,2,10)
			];
			var bmp = Lib.flatten(tf);
			bmp.bitmapData = Lib.scaleBitmap(bmp.bitmapData, 2, true);
			pool.addBitmapData(id, bmp.bitmapData);
		}

		var p = new FParticle(x, y);
		p.reset();
		p.useBitmapData( pool.get(id), false);
		p.dy = -16;
		p.frictY = 0.8;
		register(p, BlendMode.NORMAL);
	}


	public function redCross(e:en.Player) {
		var p = new FParticle(0, -10);
		p.graphics.lineStyle(10, 0xFF0000, 1, true, NONE);
		p.graphics.moveTo(-7, -10);
		p.graphics.lineTo(7, 10);
		p.graphics.moveTo(7, -10);
		p.graphics.lineTo(-7, 10);
		p.life = Const.seconds(3);

		p.blendMode = ADD;
		e.spr.addChild(p);
	}




	public function slip(e:en.Player) {
		var base = 0;
		for(i in 0...15) {
			var a = base + rnd(0, 0.3, true) + (i%2==0 ? -2.6 : -0.4);
			var p = new FParticle(e.xx, e.yy);
			p.useBitmapData( pool.get("waterSlip"), false );
			p.scaleX = rnd(0.5, 1);
			p.moveAng(a, rnd(1,5));
			p.gy = rnd(0.10, 0.12);
			p.dsx = -0.05;
			p.rotation = MLib.toDeg(a);
			p.life = rnd(3, 6);
			register(p, NORMAL);
		}
	}



	public function fault(e:en.Player) {
		// Card
		var p = new FParticle(e.xx, e.yy);
		p.useBitmapData( pool.get(e.faults==1 ? "yellowCard" : "redCard"), false );
		p.rotation = 7;
		p.scaleX = p.scaleY = 6;
		p.ds = -1.2;
		p.onUpdate = function() {
			p.ds*=0.7;
		}
		register(p, NORMAL);

		// Text
		var id = "str:"+Lang.Fault+e.faults;
		if( !pool.exists(id) ) {
			var tf = game.createField( Lang.Fault, FBig, true );
			tf.textColor = e.faults==1 ? 0xFFDF00 : 0xFF2600;
			tf.filters = [ new flash.filters.GlowFilter(e.faults==1 ? 0xAE6400 : 0x771200,1, 2,2,6) ];
			pool.addDisplayObject(id, tf);
		}
		var p = new FParticle(e.xx, e.yy);
		p.useBitmapData( pool.get(id), false );
		register(p, NORMAL);
	}


	public function wind(a:Float, pow:Float) {
		var fa = a + rnd(0, 1, true);
		var x = game.viewport.x + game.getWidth()*0.5 - Math.cos(fa)*game.getWidth()*0.7;
		var y = game.viewport.y + game.getHeight()*0.5 - Math.sin(fa)*game.getHeight()*0.7;
		var p = new FParticle( x, y );
		p.useBitmapData( pool.getRandom("leaves"), false );
		p.moveAng(a, pow*10*rnd(0.7, 1.3));
		if( !lowq )
			p.dr = rnd(3,12,true);
		p.gx = rnd(0, 0.03,true);
		p.gy = rnd(0, 0.03,true);
		p.frict = rnd(0.99, 1);
		p.life = rnd(50,80);
		register(p, NORMAL);
	}



	public function airGrab(e:en.Player) {
		hit(e.xx, e.yy-20, 2);

		for(i in 0...18) {
			var p = new FParticle(e.xx,e.yy);
			p.useBitmapData( pool.getRandom("smoke"), false );
			var a = rnd(0,6.28);
			var s = rnd(3,5);
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s*0.6;
			p.frict = 0.9;
			p.life = rnd(30,40);
			register(p, BlendMode.NORMAL, true);
		}
	}

	public function clash(a:Entity, b:Entity) {
		var x = a.xx + (b.xx-a.xx)*0.5;
		var y = a.yy + (b.yy-a.yy)*0.5;
		if( lowq )
			hit(x,y,1.5);
		else {
			var p = new FParticle(x,y);
			var s = game.tiles.getAndPlay("fxSlam", 1, true);
			s.scaleX = s.scaleY = 2;
			s.a.setGeneralSpeed(0.8);
			s.setCenter(0.5, 0.5);
			s.rotation = MLib.toDeg( Math.atan2(b.yy-a.yy, b.xx-a.xx)+1 );
			p.addChild(s);
			p.life = 30;

			register(p);
		}
	}

	public function marker(x,y, ?col=0xFFFF00) {
		#if debug
		var p = new FParticle(x,y);
		p.reset();
		p.graphics.lineStyle(3, col, 1);
		p.graphics.drawCircle(0,0, 10);
		p.scaleY = 0.6;
		p.life = 60;
		register(p, BlendMode.NORMAL);
		#end
	}

	public function radius(x,y, r, ?c=0xFFFF00) {
		#if debug
		var p = new FParticle(x,y);
		p.reset();
		p.graphics.lineStyle(2, c, 1);
		p.graphics.drawCircle(0,0,r);
		p.life = 60;
		register(p, BlendMode.NORMAL);
		#end
	}

	public function explosion(x:Float,y:Float, radius:Float) {
		var bd = pool.getRandom("expHole");
		var pt = new flash.geom.Point(x-bd.width*0.5, y-bd.height*0.5);
		game.stadium.splatters.bitmapData.copyPixels( bd, bd.rect, pt, true);

		var bd = pool.getRandom("expHoleHalo");
		var pt = new flash.geom.Point(x-bd.width*0.5, y-bd.height*0.5);
		game.stadium.splatters.bitmapData.copyPixels( bd, bd.rect, pt, true);

		// Halo
		var id = "haloExp";
		var r = 40;
		if( !pool.exists(id) ) {
			var s = new Sprite();
			s.graphics.beginFill(0xFF0000, 0.5);
			s.graphics.drawCircle(0,0,r);
			pool.addDisplayObject(id, s);
		}
		var p = new FParticle(x,y);
		p.useBitmapData( pool.get(id), false );
		p.scaleX = p.scaleY = (radius*2)/(r*2);
		p.life = 1;
		register(p);

		// Anim explosion
		var s = game.tiles.getAndPlay("fxMine", 1, true);
		s.x = x;
		s.y = y;
		s.setCenter(0.5,0.5);
		game.sdm.add(s, Const.DP_FX);

		// Ground dirts
		if( !lowq ) {
			var id = "explosionDirt";
			if( !pool.exists(id) ) {
				var s = new Sprite();
				s.graphics.beginFill(0x8F5630, 1);
				s.graphics.moveTo(0,3);
				s.graphics.lineTo(6,-1);
				s.graphics.lineTo(2,-6);
				s.graphics.lineTo(-2,-4);
				s.graphics.lineTo(-5,-2);
				s.filters = [
					new flash.filters.GlowFilter(0x59351E,0.5, 2,2,8),
					new flash.filters.DropShadowFilter(1,90, 0xBF7340,1, 2,2,1, 1,true),
					new flash.filters.DropShadowFilter(2,90, 0x492C18,1, 0,0),
				];
				pool.addDisplayObject(id, s, 2);
			}

			for(i in 0...8) {
				var high = i>=5;
				var p = new FParticle(x,y);
				p.useBitmapData( pool.get(id), false );
				p.alpha = rnd(0.5, 1);
				p.dr = rnd(5,20,true);
				p.dx = rnd(0,3,true);
				p.scaleX = p.scaleY = rnd(0.5, 1);
				p.dy = high ? -rnd(9,12) : -rnd(3,5);
				p.gy = 0.3;
				p.bounce = 0.5;
				p.groundY = y + rnd(0,15,true);
				p.onBounce = function() {
					p.dr = 0;
					p.rotation = rnd(0,5,true);
				}
				register(p, BlendMode.NORMAL);
			}
		}
	}


	public function electricityBall(x:Float, y:Float, pow:Float) {
		if( game.time%2!=0 )
			return;

		var low = pow<0.7;

		var p = new FParticle(x+rnd(0,4,true), y-5+rnd(0,4,true));
		p.useBitmapData( pool.getRandom("electricity"+(low?"Low":"High")), false );
		p.life = 0;
		p.alpha = 0.3 + pow*0.7;
		p.scaleY = p.scaleX = (low ? 0.8 : 1.5) * rnd(0.8, 1);
		p.rotation = rnd(0, 360);
		p.ds = rnd(0, 0.1, true);
		p.fadeOutSpeed = 0.15;
		register(p);
	}

	public function electricityBounce(x:Float, y:Float) {
		for(i in 0...5) {
			var p = new FParticle(x+rnd(0,4,true), y-5+rnd(0,4,true));
			p.useBitmapData( pool.getRandom("electricityLow"), false );
			p.life = rnd(2,5);
			p.alpha = 1;
			p.scaleY = p.scaleX = 1;
			p.moveAng( rnd(0,6.28), rnd(3, 6) );
			p.dy*=0.6;
			p.rotation = rnd(0, 360);
			p.ds = rnd(0, 0.06, true);
			//p.fadeOutSpeed = 0.15;
			register(p);
		}
	}

	public function electricityRemains(x:Float, y:Float) {
		if( game.time%2!=0 )
			return;

		var p = new FParticle(x+rnd(0,9,true), y-5+rnd(0,4,true));
		p.useBitmapData( pool.getRandom("electricityLow"), false );
		p.life = 0;
		p.alpha = 0.8;
		p.scaleY = p.scaleX = rnd(0.8, 1);
		p.rotation = rnd(0, 360);
		p.ds = rnd(0, 0.1, true);
		p.fadeOutSpeed = 0.15;
		register(p);
	}

	public function electricExplosion(x:Float, y:Float, r:Float) {
		if( !lowq )
			flashBang(0x0080FF, 0.7, 600);

		var p = new FParticle(x,y);
		var s = game.tiles.getAndPlay("fxBeam", 1, true);
		s.a.onEnd( function() p.destroy() );
		s.setCenter(0.5, 0.5);
		s.width = s.height = r*2.2;
		p.addChild(s);
		p.life = 60;
		register(p);

		var p = new FParticle(x,y);
		var s = game.tiles.getAndPlay("fxBolt", 1, true);
		s.a.onEnd( function() p.destroy() );
		s.setCenter(0.5, 0.5);
		s.height = game.getHeight();
		p.addChild(s);
		p.life = 60;
		register(p);

		//var p = new FParticle(x+rnd(0,6,true), y+rnd(0,6,true));
		//p.useBitmapData( pool.getRandom("electricHit"), false );
		//p.width = p.height = r*2.2;
		//p.life = 0;
		//p.fadeOutSpeed = 0.15;
		//register(p);
	}


	public function bowlingHit(x:Float, y:Float, pow:Float) {
		var p = new FParticle(x,y-10);
		p.useBitmapData( pool.get("bowlingHit"), false );
		p.life = 0;
		p.scaleY = p.scaleX = rnd(0.7, 1)*pow;
		p.ds = 0.1;
		p.fadeOutSpeed = 0.15;
		register(p);
	}


	public function ballTrail(b:en.Ball, alpha:Float) {
		if( lowq )
			return;

		if( game.time%2!=0 )
			return;

		var p = new FParticle(b.spr.x, b.spr.y-5);
		p.useBitmapData( b.lastOwner.side==0 ? pool.get("trailGreen") : pool.get("trailRed"), false );
		p.life = rnd(5,15);
		register(p, true);
	}


	public function surprise(e:en.Player) {
		if( lowq )
			return;

		var n = 4;
		for(i in 0...n) {
			var adeg = -25 - i * 140/(n-1);
			var a = MLib.toRad(adeg);
			var p = new FParticle(e.xx+Math.cos(a)*5, e.yy-32+Math.sin(a)*5);
			p.useBitmapData( pool.get("surprise"), false );
			p.life = 5;
			p.rotation = adeg;
			var s = 3.5;
			p.dx = Math.cos(a)*s + e.dx*15;
			p.dy = Math.sin(a)*s + e.dy*15;
			p.frictX = p.frictY = 0.85;
			register(p);
		}
	}



	public function kickLight(x,y,a, pow:Float) {
		pow = MLib.fclamp(pow, 0,1);
		var p = new FParticle(x,y);

		var s = new BSprite(m.Global.ME.tiles);
		p.addChild(s);
		s.a.play("fxShoot").killAfterPlay();
		s.setCenter(0.3,0.5);
		s.scaleX = s.scaleY = 0.5 + pow*pow;
		s.alpha = pow>=0.9 ? 1 : 0.5;

		p.rotation = MLib.toDeg(a);
		p.life = 15;
		register(p);
	}



	public function grass(x:Float,y:Float, n:Int) {
		if( lowq )
			return;

		for(i in 0...n) {
			var p = new FParticle(x+rnd(0,5,true), y+rnd(0,5,true));
			p.useBitmapData( pool.getRandom("grass"), false );
			p.alpha = rnd(0.6, 0.8);
			p.dx = rnd(0.5,2,true);
			p.dy = -rnd(2,5);
			p.dr = rnd(8,15,true);
			p.gy = rnd(0.2, 0.5);
			p.frictX = p.frictY = 0.92;
			p.life = rnd(8,20);
			p.bounce = 0.5;
			p.groundY = y+rnd(0,5,true);
			p.onBounce = function() {
				p.dr = 0;
			}
			register(p, BlendMode.NORMAL);
		}
	}


	public function grassKick(x:Float,y:Float, ang:Float, n:Int) {
		if( lowq )
			return;

		for(i in 0...n) {
			var p = new FParticle(x+rnd(0,5,true), y+rnd(0,5,true));
			p.useBitmapData( pool.getRandom("grass"), false );
			p.alpha = rnd(0.6, 0.8);
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


	public function teleport(e:Entity, enter:Bool) {
		var p = new FParticle(e.xx,e.yy);
		p.useBitmapData( pool.get("teleport"), false );
		p.ds = enter ? -0.1 : 0.1;
		p.life = 0;
		register(p);
	}


	public function update() {
		FParticle.update();
		cd.update();
	}
}