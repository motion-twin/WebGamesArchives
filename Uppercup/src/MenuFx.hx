import flash.display.BlendMode;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

import mt.MLib;
import mt.deepnight.slb.BSprite;
import mt.deepnight.Tweenie;
import mt.deepnight.FParticle;
import mt.deepnight.Lib;
import mt.deepnight.Color;

class MenuFx {
	public static var ME : MenuFx;

	public var lowq		: Bool;
	var mode			: m.MenuBase;
	var pool			: BitmapDataPool;

	public function new(m:m.MenuBase) {
		ME = this;
		mode = m;
		FParticle.LIMIT = 150;
		lowq = false;

		pool = new BitmapDataPool();
		pool.addBitmapData("fbang", [new BitmapData(50,50, true, 0xffFFCC00)]);

		// Photo sparks
		var s = new Sprite();
		s.graphics.beginFill(0xFFFFAE,1);
		s.graphics.drawCircle(10,10,10);
		s.filters = [
			new flash.filters.BlurFilter(2,2),
			new flash.filters.GlowFilter(0xFFBF00,0.8, 16,16,2),
		];
		pool.addDisplayObject("spark", s, 16);

		// Hit circle
		var s = new Sprite();
		s.graphics.lineStyle(2, 0xFFFFFF, 1, true, NONE);
		s.graphics.drawCircle(0,0, 30);
		s.filters = [ new flash.filters.GlowFilter(0xBF48FF,1, 16,16,3) ];
		pool.addDisplayObject("hitCircle", s, 16);

		// Golden hit circle
		var s = new Sprite();
		s.graphics.lineStyle(2, 0xFFFF00, 1, true, NONE);
		s.graphics.drawCircle(0,0, 30);
		s.filters = [ new flash.filters.GlowFilter(0xFF6000,1, 16,16,5) ];
		pool.addDisplayObject("goldenHitCircle", s, 16);

		// Star
		var s = mode.tiles.get("bigStar");
		s.transform.colorTransform = Color.getSimpleCT(0xFFFFFF, 1.0);
		s.filters = [ new flash.filters.GlowFilter(0xFFFF00,0.5, 8,8,2) ];
		pool.addDisplayObject("star", s, 8);
		s.dispose();

		// Mini star
		var s = mode.tiles.get("miniStar");
		var ct = new flash.geom.ColorTransform();
		ct.color = 0xFFFF00;
		s.filters = [ new flash.filters.GlowFilter(0xFFA600,0.4, 8,8,4) ];
		pool.addDisplayObject("miniStar", s, 8);
		s.dispose();

		// Hit rectangle
		var s = new Sprite();
		//s.graphics.lineStyle(2, 0xFFFFFF, 1, true, NONE);
		s.graphics.beginFill(0xFFFF00,1);
		s.graphics.drawRect(0,0,200,50);
		s.filters = [
			new flash.filters.BlurFilter(4,4,2),
			new flash.filters.GlowFilter(0xFF9300,1, 8,8,3, 1,true),
		];
		pool.addDisplayObject("hitRect", s, 4);

		// God spark
		var s = new Sprite();
		s.graphics.beginFill(0xFFFFFF, 1);
		s.graphics.drawRect(0,0,1,1);
		s.graphics.beginFill(0xDFA4FF, 0.06);
		s.graphics.drawCircle(0,0, 3);
		s.filters = [ new flash.filters.GlowFilter(0xBF48FF,1, 8,8,2) ];
		pool.addDisplayObject("godSpark", s, 8);

		// Active button
		var s = new Sprite();
		s.graphics.beginFill(0xFFFFFF, 1);
		s.graphics.drawRect(0,0,4,1);
		s.filters = [
			new flash.filters.GlowFilter(0x9F48FF,1, 4,4,2),
			new flash.filters.GlowFilter(0x9F48FF,1, 8,8,2),
		];
		pool.addDisplayObject("activeBt", s, 8);

		// Rain fx
		var s = new Sprite();
		var m = new flash.geom.Matrix();
		m.createGradientBox(30,1);
		s.graphics.beginGradientFill(LINEAR, [0xC7CCE0,0xC7CCE0], [0,1], [0,255], m);
		s.graphics.drawRect(0,0,30,1);
		s.filters = [
			new flash.filters.GlowFilter(0x64B1FF,0.4, 8,8,4),
		];
		pool.addDisplayObject("rain", s, 8);

		// Logo fx (blur)
		var s = new Sprite();
		var m = new flash.geom.Matrix();
		s.graphics.beginFill(0xFF0000, 0.2);
		s.graphics.drawCircle(0,0, 8);
		s.filters = [
			new flash.filters.BlurFilter(10,10, 2),
		];
		pool.addDisplayObject("logoBlur", s, 10);

		// Logo fx (lines)
		var s = new Sprite();
		var m = new flash.geom.Matrix();
		s.graphics.lineStyle(1, 0xF2EEDF, 1);
		s.graphics.moveTo(0,0);
		s.graphics.lineTo(12,0);
		s.filters = [
			new flash.filters.BlurFilter(8,0, 2),
			new flash.filters.GlowFilter(0xFF5353,1, 8,8,3, 2),
		];
		pool.addDisplayObject("logoLine", s, 8);

		// Logo fx (long lines)
		var s = new Sprite();
		var m = new flash.geom.Matrix();
		s.graphics.lineStyle(1, 0xFF4848, 1);
		s.graphics.moveTo(0,0);
		s.graphics.lineTo(60,0);
		s.filters = [
			new flash.filters.BlurFilter(16,0, 2),
			new flash.filters.GlowFilter(0xFF4848,0.7, 8,8,4, 2),
		];
		pool.addDisplayObject("logoLongLine", s, 16);

		// Rain ground
		var s = new Sprite();
		s.graphics.lineStyle(1, 0xC7CCE0, 1, true, NONE);
		s.graphics.drawEllipse(-10,-5, 20, 10);
		s.filters = [
			new flash.filters.GlowFilter(0x64B1FF,0.4, 8,8,4),
		];
		pool.addDisplayObject("ploc", s, 8);

		pool.addBitmapData("confetti", mode.tiles.getAllBitmapDatas("fxConfetis"));
		pool.addBitmapData("godLight", mode.tiles.getAllBitmapDatas("fxGodlight"));
		pool.addBitmapData("shine", mode.tiles.getBitmapData("shiningSpark"));
	}

	inline function rnd(min,max,?sign) { return Lib.rnd(min,max,sign); }
	inline function irnd(min,max,?sign) { return Lib.irnd(min,max,sign); }
	inline function wid() return mode.getWidth();
	inline function hei() return mode.getHeight();


	public function register(p:FParticle, ?b:BlendMode, ?bg=false) {
		if( bg )
			mode.bgFxWrapper.addChild(p);
		else
			mode.wrapper.addChild(p);
		p.blendMode = b!=null ? b : BlendMode.ADD;
	}


	public function destroy() {
		ME = null;
		FParticle.clearAll();
		pool.destroy();
	}

	public function photoSparks(bg:Bitmap, ?bang=false) {
		if( Std.random(100)<20 ) {
			if( bang )
				flashBang(0xFFFF00, rnd(0.1, 0.2), 1000);

			var p = new FParticle( (bg.x + rnd(0,bg.width))/Const.UPSCALE, (bg.y + bg.height * rnd(0.4,0.6))/Const.UPSCALE);
			p.useBitmapData( pool.get("spark"), false );
			p.fadeOutSpeed = 0.3;
			p.life = 0;
			p.onUpdate = function() {
				p.scaleX*=1.1;
				p.scaleY*=0.5;
			}
			register(p, true);
		}
	}

	public function blingBling(x,y,w,h) {
		var p = new FParticle(rnd(x,x+w), rnd(y,y+h));
		p.useBitmapData( pool.get("shine"), false );
		p.scaleX = rnd(0.3, 1);
		p.alpha = 0;
		p.da = rnd(0.05, 0.1);
		p.life = rnd(10, 20);
		register(p);
	}

	public function bigBall() {
		var p = new FParticle(mode.getWidth(), rnd(100, mode.getHeight()));
		p.useBitmapData( pool.get("shine"), false);
		register(p, NORMAL);
	}

	public function activeButton(x:Float, y:Float,w,h) {
		//var x = x + rnd(5,w-5);
		//var y = y + rnd(5,h-5);
		var a = rnd(0, 6.28);
		var d = rnd(w*0.5, w*0.8);
		//var p = new FParticle(x+rnd(0,5,true), y+rnd(0,5,true));
		var p = new FParticle( x+w*0.5+Math.cos(a)*d, y+h*0.5+Math.sin(a)*d );
		p.useBitmapData( pool.get("activeBt"), false );
		p.scaleX = rnd(0.5, 1.5);
		p.rotation = MLib.toDeg(a);
		p.moveAng(3.14+a, rnd(1.2,1.8));

		//p.gy = -rnd(0.1, 0.5);
		p.frict = rnd(0.95, 0.97);
		p.alpha = 0;
		p.da = rnd(0.1, 0.2);
		//p.dr = rnd(2, 5, true);

		p.life = rnd(7, 10);
		register(p);
	}

	public function godSparks() {
		var p = new FParticle(rnd(230,400), rnd(0,hei()*0.5));
		p.useBitmapData( pool.get("godSpark"), false );
		p.alpha = 0;
		p.da = 0.03;
		p.life = rnd(25,50);
		p.dx = rnd(0,1,true);
		p.dy = rnd(0,1,true);
		p.frict = 0.93;
		register(p, true);
	}

	public function hit(x,y, ?scale=1.0) {
		var p = new FParticle(x,y);
		p.useBitmapData( pool.get("hitCircle"), false );
		p.scaleX = p.scaleY = scale;
		p.ds = 0.3*scale;
		p.onUpdate = function() {
			p.ds*=0.9;
		}
		p.life = 0;
		register(p);
	}

	public function goldenHit(x,y, ?scale=1.0) {
		var p = new FParticle(x,y);
		p.useBitmapData( pool.get("goldenHitCircle"), false );
		p.scaleX = p.scaleY = scale;
		p.ds = 0.3*scale;
		p.onUpdate = function() {
			p.ds*=0.9;
		}
		p.life = 0;
		register(p, ADD);
	}

	public function star(x,y, ?scale=1.0) {
		// Small star
		var p = new FParticle(x,y);
		p.useBitmapData( pool.get("star"), false );
		p.ds = 0.1;
		p.onUpdate = function() {
			p.ds*=0.85;
		}
		p.frict = rnd(0.96, 0.98);
		p.alpha = 1;
		p.life = 8;
		register(p);

		// Big star
		var p = new FParticle(x,y);
		p.useBitmapData( pool.get("star"), false );
		p.scaleX = p.scaleY = 2;
		p.ds = 0.15;
		p.onUpdate = function() {
			p.ds*=0.99;
		}
		p.frict = rnd(0.96, 0.98);
		p.alpha = 0.3;
		p.life = 4;
		register(p);

		// Parts
		var n = 12;
		for(i in 0...n) {
			var p = new FParticle(x,y);
			p.useBitmapData( pool.get("miniStar"), false );
			p.moveAng(-0.5 + 3.9*i/(n-1), rnd(9,15));
			p.rotation = rnd(0,360);
			p.frict = rnd(0.94, 0.96);
			p.alpha = 0.5;
			p.life = rnd(10,20);
			register(p);
		}
	}

	public function buttonHit(c:mt.deepnight.mui.Component) {
		var pt = c.getGlobalCoord();
		var p = new FParticle(pt.x + c.getWidth()*0.5, pt.y + c.getHeight()*0.5);
		p.useBitmapData( pool.get("hitRect"), false );
		p.width = c.getWidth() + 5;
		p.height = c.getHeight() + 10;
		p.life = 0;
		register(p);
	}

	public function godLight(?init=false) {
		var p = new FParticle(rnd(250,450), rnd(-20, 0));
		p.useBitmapData( pool.getRandom("godLight"), false );
		if( !init ) {
			p.alpha = 0;
			p.da = 0.03;
		}
		p.dx = rnd(0, 1, true);
		p.rotation = 25;
		p.scaleX = rnd(1, 3);
		p.scaleY = rnd(0.6, 1);
		//p.dr = rnd(0,0.3,true);
		p.frict = 0.93;
		p.fadeOutSpeed = 0.02;
		p.life = rnd(5, 20);
		register(p);
	}

	public function confettis(?big=true) {
		var p = new FParticle( rnd(0,wid()), -10 );
		var spd = rnd(0.02, 0.06);
		p.useBitmapData( pool.getRandom("confetti"), false );
		p.dr = rnd(1,5,true);
		var baseCos = rnd(0,6.28);
		var sc = big ? 1 : 0.5;
		p.onUpdate = function() p.scaleX = sc*Math.cos(baseCos + mode.time*spd);
		p.scaleY = sc;
		p.dx = rnd(0, 0.1, true);
		p.gx = rnd(0, 0.06, true);
		p.gy = rnd(0.06, 0.12);
		p.life = rnd(60,120);
		p.frict = rnd(0.95, 0.98);
		register(p, true);
		p.blendMode = NORMAL;
	}

	public function textLine(y:Float, dir:Int) {
		for(i in 0...15) {
			var p = new FParticle(dir==-1?rnd(wid()*0.8, wid()):rnd(0, wid()*0.2), y+rnd(0,20));
			p.useBitmapData( pool.get("shine"), false );
			p.dx = dir * rnd(12,35);
			p.alpha = rnd(0.5, 1);
			p.frict = 0.95;
			p.life = rnd(15, 20);
			register(p);
		}
	}

	public function rain() {
		var p = new FParticle( rnd(-50,wid()-50), -10 );
		var spd = rnd(0.02, 0.06);
		p.useBitmapData( pool.getRandom("rain"), false );
		var a = rnd(1.3, 1.4);
		p.scaleX = rnd(0.3, 1);
		p.moveAng(a, rnd(15,20));
		p.rotation = MLib.toDeg(a);
		p.life = rnd(20,30);
		p.groundY = hei()-rnd(-5,70);
		p.onBounce = function() {
			p.destroy();
			var p2 = new FParticle(p.x, p.y);
			p2.useBitmapData( pool.getRandom("ploc"), false );
			p2.ds = rnd(0.03, 0.06);
			p2.scaleX = p2.scaleY = rnd(0.1, 0.3);
			p2.life = 0;
			p2.fadeOutSpeed = rnd(0.1, 0.2);
			p2.alpha = rnd(0.2, 1);
			register(p2, NORMAL);
		}
		register(p, NORMAL);
	}

	public function flashBang(col:Int, alpha:Float, duration:Float, ?delay=0.0) {
		var p = new FParticle(wid()*0.5, hei()*0.5);
		var bmp = p.useBitmapData( pool.get("fbang"), false );
		bmp.bitmapData.fillRect( bmp.bitmapData.rect, Color.addAlphaF(col, alpha) );
		p.width = wid();
		p.height = hei();
		p.alpha = alpha;
		p.life = 0;
		p.delay = delay;
		p.fadeOutSpeed = 1 / (duration*Const.FPS / 1000);
		register(p);
	}


	public function logo(final:Bitmap, hollow:Bitmap, proc:m.Logo) {
		var w = wid();
		var h = hei();
		var d = 900;
		var msOffset = 1000;
		var frameOffset = Const.seconds(msOffset/1000);

		function makeLine(x,y, a, ?ghost=false) {
			var p = new FParticle(final.x + x*final.scaleX - Math.cos(a)*100, final.y + y*final.scaleY - Math.sin(a)*100);
			p.moveAng(a, 32);
			p.frict = 0.81;
			p.alpha = 0;
			p.da = ghost? 0.02 : 0.1;
			p.rotation = MLib.toDeg(a);
			p.useBitmapData( pool.get("logoLongLine"), false );
			p.fadeOutSpeed = 0.3;
			p.life = d*Const.FPS/1000 + rnd(0,3);
			p.delay = frameOffset;
			register(p);
		}

		makeLine(201,32, MLib.toRad(108));
		makeLine(378,153, MLib.toRad(180));
		makeLine(33,162, MLib.toRad(36));
		makeLine(106,363, MLib.toRad(-36));
		makeLine(319,358, MLib.toRad(-108));

		makeLine(214,103, MLib.toRad(71), true);
		makeLine(80,173, MLib.toRad(0), true);
		makeLine(152,290, MLib.toRad(-71), true);
		makeLine(273,293, MLib.toRad(-144), true);

		var pts = [{x:267, y:186},{x:42, y:166},{x:180, y:300},{x:222, y:230},{x:186, y:173},{x:261, y:171},{x:141, y:332},{x:173, y:147},{x:173, y:238},{x:239, y:236},{x:271, y:277},{x:147, y:204},{x:123, y:226},{x:185, y:139},{x:124, y:344},{x:257, y:240},{x:179, y:105},{x:278, y:178},{x:268, y:278},{x:275, y:295},{x:184, y:288},{x:299, y:300},{x:141, y:322},{x:272, y:208},{x:140, y:173},{x:165, y:317},{x:99, y:214},{x:279, y:291},{x:187, y:111},{x:96, y:198},{x:201, y:63},{x:175, y:238},{x:233, y:230},{x:200, y:79},{x:179, y:140},{x:182, y:144},{x:323, y:162},{x:247, y:213},{x:185, y:254},{x:279, y:248}];
		//var pts = [];
		for(i in 0...40) {
			var pt = pts.shift();
			var tx : Float = pt.x;
			var ty : Float = pt.y;

			//var c1 : UInt = 0xffe01500;
			//var c2 : UInt = 0xff960401;
			//var tries = 100;
			//var tx = rnd(0, final.bitmapData.width);
			//var ty = rnd(0, final.bitmapData.height);
			//while( tries>0 && final.bitmapData.getPixel32(Std.int(tx),Std.int(ty))!=c1 && final.bitmapData.getPixel32(Std.int(tx),Std.int(ty))!=c2 ) {
				//tx = rnd(0, final.bitmapData.width);
				//ty = rnd(0, final.bitmapData.height);
				//tries--;
			//}
			//if( tries<=0 )
				//continue;
			//pts.push({x:tx, y:ty});

			tx*=final.scaleX;
			ty*=final.scaleY;
			tx+=final.x;
			ty+=final.y;

			var a = Math.atan2(h*0.5-ty, w*0.5-tx);
			tx-=Math.cos(a)*40;
			ty-=Math.sin(a)*40;

			var p = new FParticle( tx, ty );
			p.useBitmapData( pool.get("logoBlur"), false );
			p.alpha = 0;
			p.da = rnd(0.2,0.3);
			p.delay = frameOffset + i*0.1;
			p.frict = rnd(0.90, 0.94);
			p.moveAng(a, rnd(4,6));
			p.fadeOutSpeed = rnd(0.1, 0.3);
			p.life = rnd(0,4)+Const.FPS*d/1000;
			register(p);
		}

		var n = 45;
		for(i in 0...n)  {
			var a = 6.28 * i/n + rnd(0,0.5,true);
			var dist = rnd(5, 50);
			var p = new FParticle(w*0.5 + Math.cos(a)*dist, h*0.5 + Math.sin(a)*dist);
			p.useBitmapData(pool.get("logoLine"), false);
			var a = Math.atan2(h*0.5-p.y, w*0.5-p.x);
			var s = rnd(10,20);
			p.dx = -Math.cos(a)*s;
			p.dy = -Math.sin(a)*s;
			p.ds = -rnd(0.01, 0.03);
			p.rotation = MLib.toDeg(a);
			p.scaleX = rnd(0.5,1);
			p.frict = rnd(0.8, 0.9);
			p.life = rnd(5, 25);
			p.delay = frameOffset + rnd(0,3) + d*Const.FPS/1000;
			register(p);
		}

		flashBang(0xFF0000, 0.76, 1300, frameOffset + d*Const.FPS/1000);
		hollow.visible = true;
		hollow.alpha = 0;
		final.visible = true;
		final.alpha = 0;
		proc.delayer.add( function() {
			proc.tw.create( hollow.alpha, 0.8, TEaseIn, d );
			proc.delayer.add( function() {
				proc.tw.terminateWithoutCallbacks(hollow.alpha);
				proc.tw.create( hollow.alpha, 0, 1200 );
				proc.tw.create( final.alpha, 1, TEaseIn, 300 );
			}, d);
		}, msOffset);

		//var button = new mt.deepnight.mui.Button(proc.root, "copy", function() {
			//flash.system.System.setClipboard( "var pts = "+pts.map(function(pt) return "{x:"+MLib.round(pt.x)+", y:"+MLib.round(pt.y)+"}")+";" );
		//});

	}

	public function update() {
		FParticle.update();
	}
}