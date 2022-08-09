import mt.deepnight.Particle;
import mt.deepnight.Lib;
import mt.deepnight.Color;
import flash.display.Sprite;
import flash.display.BlendMode;

import Iso;

class Fx {
	var man				: Manager;
	public var lasts	: Array<Particle>;
	var layer			: Int;
	
	public function new() {
		man = Manager.ME;
		lasts = new Array();
		front();
	}
	
	inline public function front() {
		layer = Const.DP_FX;
	}
	
	inline public function back() {
		layer = Const.DP_BG_FX;
	}
	
	inline public function bg() {
		layer = Const.DP_BG;
	}
	
	function getDirs(dir) {
		return switch(dir) {
			case 0 : {dx:1, dy:-0.5}
			case 1 : {dx:1, dy:0.5}
			case 2 : {dx:-1, dy:0.5}
			case 3 : {dx:-1, dy:-0.5}
		}
	}
	
	inline function pregister(p:Projectile, ?b:BlendMode) {
		man.sdm.add(p, layer);
		p.blendMode = b!=null ? b : BlendMode.ADD;
		p.mouseChildren = p.mouseEnabled = false;
	}
	
	inline function register(p:Particle, ?b:BlendMode) {
		if( man.cm.turbo ) {
			p.destroy();
		}
		else {
			if( layer==Const.DP_BG )
				man.buffer.dm.add(p,layer);
			else
				man.sdm.add(p, layer);
			p.blendMode = b!=null ? b : BlendMode.ADD;
			lasts.push(p);
		}
	}
	
	inline function registerGlobal(p:Particle, ?b:BlendMode) {
		man.gscroller.addChild(p);
		p.blendMode = b!=null ? b : BlendMode.ADD;
		p.mouseChildren = p.mouseEnabled = false;
		lasts.push(p);
	}
	
	inline function registerInto(cont:flash.display.DisplayObjectContainer, p:Particle, ?b:BlendMode) {
		cont.addChild(p);
		p.blendMode = b!=null ? b : BlendMode.ADD;
		p.mouseChildren = p.mouseEnabled = false;
		lasts.push(p);
	}
	
	inline function init() { // à appeler dans chaque fonction de génération
		lasts = new Array();
		front();
	}
	
	inline function rnd(min:Float, max:Float, ?sign) { return Lib.rnd(min,max,sign); }
	inline function irnd(min, max,?sign) { return Lib.irnd(min,max,sign); }
	inline function rad(a) { return Lib.rad(a); }
	inline function deg(a) { return Lib.deg(a); }
	
	public function hello() {
		init();
		
		var pt = Iso.isoToScreenStatic(Const.RWID*0.5, Const.RHEI*0.5);
		var x = pt.x+20;
		var y = pt.y-10;
		
		var mc = new lib.Bonjour();
		mc.gotoAndStop( switch( Const.LANG ) {
			case "fr" : 1;
			case "en" : 2;
			case "es" : 3;
			default : 2;
		});
		var p = new Particle(x,y);
		p.addChild(mc);
		p.reset();
		p.life = 32;
		p.onUpdate = function() {
			var t = 0.5-p.time()*0.5;
			p.setPos( x+t*rnd(0,1,true), y+t*rnd(0,3,true) );
		}
		register(p, BlendMode.NORMAL);
	}
	
	public function airWave(iso:Iso, dir:Int, ?sound=true, ?offY=0) {
		init();
		var x = iso.sprite.x;
		var y = iso.sprite.y+12;
		var d = getDirs(dir);
		if( sound )
			Manager.SBANK.windShort().play(0.4);
		for(i in 0...10) {
			var p = new Particle(x + rnd(0,10,true), y + offY + rnd(0,5,true));
			p.reset();
			p.drawBox(8 + irnd(0,10),1, 0xFFFFFF, rnd(0.3, 0.8));
			p.rotation = Math.atan2(d.dy, d.dx)*180 / 3.14;
			var s = rnd(3,10);
			p.dx = d.dx * s;
			p.dy = d.dy * s;
			p.life = irnd(0,5);
			p.frictX = p.frictY = 0.80;
			p.filters = [ new flash.filters.BlurFilter(8,2) ];
			register(p);
		}
	}
	
	public function earthAirWave(iso:Iso) {
		init();
		var x = iso.sprite.x;
		var y = iso.sprite.y;
		var d = getDirs(1);
		for(i in 0...5) {
			var p = new Particle(x + rnd(0,5,true), y + rnd(0,5,true));
			p.reset();
			p.drawBox(4 + irnd(0,10),1, 0xFFFFFF, rnd(0.3, 0.8));
			p.rotation = Math.atan2(d.dy, d.dx)*180 / 3.14;
			var s = rnd(3,6);
			p.dx = d.dx * s;
			p.dy = d.dy * s;
			p.life = irnd(0,5);
			p.frictX = p.frictY = 0.73;
			p.filters = [ new flash.filters.BlurFilter(8,2) ];
			register(p);
		}
	}
	
	public function grade(iso:Iso, n:Float) {
		init();
		
		var pt = iso.getHead();
		var tf = man.createField(Tx.LevelUp({_gain:n}), FBig, true);
		tf.textColor = 0xFFFFFF;
		tf.filters = [
			new flash.filters.GlowFilter(0xFFB300,1, 4,4, 4),
			new flash.filters.GlowFilter(0xE66200,1, 16,16, 2),
		];
		tf.x = Std.int( -tf.textWidth*0.5 );
		
		var pt = man.buffer.localToGlobal(pt.x, pt.y-6);
		var p = new Particle(pt.x, pt.y);
		p.reset();
		p.dy = -12;
		p.life = 60;
		p.alpha = 0;
		p.da = 0.3;
		p.frictY = 0.8;
		p.addChild(tf);
		registerGlobal(p, BlendMode.NORMAL);
	}
	
	
	public function xp(iso:Iso, n:Int) {
		init();
		
		var pt = iso.getHead();
		var tf = man.createField("+"+n+" XP", FBig, true);
		tf.textColor = 0xFFFF00;
		tf.filters = [
			new flash.filters.GlowFilter(0xFF9900,1, 2,2, 4),
			new flash.filters.GlowFilter(0xB75700,1, 2,2, 4),
			//new flash.filters.DropShadowFilter(2,90, 0xFFFF80,0.8, 0,0,1, 1,true),
			new flash.filters.GlowFilter(0xFFD24A,0.9, 16,16, 2,2),
			//new flash.filters.GlowFilter(0xFFBF00,1, 16,16, 1),
		];
		tf.x = Std.int( -tf.textWidth*0.5 );
		
		var pt = man.buffer.localToGlobal(pt.x, pt.y-6);
		var p = new Particle(pt.x, pt.y);
		p.reset();
		p.dy = -7;
		p.life = 40;
		p.alpha = 0;
		p.da = 0.3;
		p.frictY = 0.8;
		p.addChild(tf);
		registerGlobal(p, BlendMode.NORMAL);
	}
		
	public function wordEvent(iso:Iso, str:String, ?col=0xffffff) {
		init();
		var pt = iso.getHead();
		var tf = man.createField(str, FBig, true);
		tf.textColor = col;
		tf.filters = [ new flash.filters.GlowFilter(Color.brightnessInt(col, -0.8),1, 2,2, 4) ];
		tf.x = Std.int( -tf.textWidth*0.5 );
		
		var pt = man.buffer.localToGlobal(pt.x, pt.y-6);
		var p = new Particle(pt.x, pt.y);
		p.reset();
		p.dy = -14;
		p.life = 20;
		p.alpha = 0;
		p.da = 0.3;
		p.frictY = 0.7;
		p.addChild(tf);
		registerGlobal(p, BlendMode.NORMAL);
	}
		
	public function word(iso:Iso, str:String, ?col=0xffffff, ?xOffset=0.) {
		init();
		var pt = iso.getHead();
		var tf = man.createField(str, FBig, true);
		tf.textColor = col;
		//tf.filters = [ new flash.filters.GlowFilter(col,0.8, 4,4, 1) ];
		tf.filters = [ new flash.filters.GlowFilter(0x0,0.7, 2,2, 4) ];
		tf.x = Std.int( -tf.textWidth*0.5 + xOffset );
		
		var pt = man.buffer.localToGlobal(pt.x, pt.y-6);
		var p = new Particle(pt.x, pt.y);
		p.reset();
		p.dy = -14;
		p.life = 20;
		p.alpha = 0;
		p.da = 0.3;
		p.frictY = 0.7;
		p.addChild(tf);
		registerGlobal(p);
	}
	
	public function symbols(iso:Iso, c:String, count:Int, ?col=0xffffff, ?slow=false, ?dx=0, ?dy=0) {
		init();
		var pt = iso.getHead();
		for(i in 0...count) {
			var xs = [-rnd(3,6), rnd(0,1,true), rnd(3,6)];
			var tf = man.createField(c, FSmall, true);
			tf.textColor = col;
			tf.x = Std.int( -tf.textWidth*0.5 );
			
			var pt = man.buffer.localToGlobal(pt.x+xs[i%xs.length], pt.y);
			var p = new Particle(pt.x+dx, pt.y+dy);
			p.reset();
			p.alpha = rnd(0.5, 1);
			if( slow ) {
				p.delay = rnd(0,3) + i*7;
				p.dy = -rnd(0.8,1.5);
				p.frictY = 0.96;
				p.life = irnd(30,40);
			}
			else {
				p.delay = rnd(0,1) + i*3;
				p.dy = -rnd(6,12);
				p.frictY = 0.7;
				p.life = irnd(15,20);
			}
			p.addChild(tf);
			registerGlobal(p);
		}
	}
	
	public function words(iso:Iso, wlist:Array<String>, count:Int, spd:Float) {
		init();
		var pt = iso.getHead();
		for(i in 0...count) {
			var xs = [-rnd(3,6), rnd(0,1,true), rnd(3,6)];
			var tf = man.createField(wlist[Std.random(wlist.length)], FSmall, true);
			tf.x = Std.int( -tf.textWidth*0.5 );
			
			var pt = man.buffer.localToGlobal(pt.x+xs[i%xs.length], pt.y);
			var p = new Particle(pt.x, pt.y-20);
			p.reset();
			p.alpha = rnd(0.5, 1);
			p.delay = (1/spd) * (rnd(0,3) + i*7);
			p.dy = -rnd(0.8,1.5);
			p.frictY = 0.96;
			p.life = irnd(30,40);
			p.addChild(tf);
			registerGlobal(p);
		}
	}
	
	public function notes(iso:Iso, count:Int, spd:Float) {
		init();
		var pt = iso.getHead();
		for(i in 0...count) {
			var xs = [-rnd(3,6), rnd(0,1,true), rnd(3,6)];
			var pt = man.buffer.localToGlobal(pt.x+xs[i%xs.length], pt.y);
			var p = new Particle(pt.x, pt.y-20);
			
			var s = man.tiles.getSpriteRandom("note", Std.random);
			s.setCenter(0.5,0.5);
			p.addChild(s);
			
			p.reset();
			p.alpha = rnd(0.5, 1);
			p.delay = (1/spd) * (rnd(0,3) + i*7);
			p.dy = -rnd(0.8,1.5);
			p.frictY = 0.96;
			p.life = irnd(30,40);
			p.onKill = function() {
				s.destroy();
			}
			registerGlobal(p);
		}
	}
	
	public function cry(iso:Iso, ?count=40) {
		init();
		var pt = iso.getHead();
		for(i in 0...count) {
			var dir = (i%2==0 ? -1 : 1);
			var p = new Particle(pt.x+dir*3, pt.y);
			p.drawBox(1,1, 0xFFFFFF);
			p.dx = dir * rnd(0.1,2);
			p.dy = -rnd(1,3);
			p.gy = 0.2;
			p.delay = i;
			p.frictX = p.frictY = 0.96;
			p.life = rnd(5,10);
			register(p);
		}
	}
	
	public function sparks(iso:Iso, offX:Int, offY:Int, count:Int, color:Int) {
		init();
		var pt = iso.getHead();
		for(i in 0...count) {
			var dir = (i%2==0 ? -1 : 1);
			var p = new Particle(pt.x+offX, pt.y+offY);
			p.drawBox(1,1, color);
			p.dx = dir * rnd(0.2, 1);
			p.dy = -rnd(1, 2);
			p.gy = 0.2;
			p.delay = i;
			p.frictX = p.frictY = 0.96;
			p.life = rnd(5,10);
			p.filters = [ new flash.filters.GlowFilter(Color.brightnessInt(color, -0.5),1, 2,2,8) ];
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function airWaveVertical(iso:Iso) {
		init();
		for(i in 0...10) {
			var p = new Particle(iso.sprite.x + 2 + rnd(0,4,true), iso.sprite.y + 24 - rnd(0,5));
			p.reset();
			p.drawBox(1, irnd(5,10), 0xFFFFFF, rnd(0.3, 0.8));
			p.dy = -rnd(5,10);
			p.life = irnd(0,10);
			p.frictY = 0.80;
			p.filters = [ new flash.filters.BlurFilter(2,8) ];
			register(p);
		}
	}
	
	public function godLight(iso:Iso, col:Int) {
		var col = Color.saturationInt(col,0.5);
		init();

		var a = 70;
		var ar = a * 3.14/180;
		for(i in 0...40) {
			var p = new Particle(iso.sprite.x -8 + rnd(0,6,true), iso.sprite.y - 17 + rnd(0,20));
			p.drawBox(20,1, Color.lighten( col ,0.7 ), rnd(0.3, 0.6));
			p.reset();
			p.delay = i*2+rnd(0,5);
			p.rotation = a;
			var s = rnd(0.2, 0.3);
			p.dx = Math.cos(ar)*s;
			p.dy = Math.sin(ar)*s;
			p.alpha = 0;
			p.da = 0.05;
			//p.frictY = 0.9;
			p.life = irnd(20,40);
			p.filters = [ new flash.filters.BlurFilter(8,8) ];
			register(p);
		}
	}
	
	
	public function illuminate(iso:Iso, col:Int) {
		var col = Color.saturationInt(col,0.5);
		init();

		var a = 70;
		var ar = a * 3.14/180;
		for(i in 0...20) {
			var p = new Particle(iso.sprite.x -10 + rnd(0,6,true), iso.sprite.y - 30 + rnd(0,20));
			p.drawBox(20,1, Color.lighten( col ,0.7 ), rnd(0.3, 0.6));
			p.reset();
			p.delay = rnd(0,5);
			p.rotation = a;
			var s = rnd(0.2, 0.3);
			p.dx = Math.cos(ar)*s;
			p.dy = Math.sin(ar)*s;
			p.alpha = 0;
			p.da = 0.05;
			//p.frictY = 0.9;
			p.life = irnd(20,40);
			p.filters = [ new flash.filters.BlurFilter(8,8) ];
			register(p);
		}
		
		for(i in 0...20) {
			var p = new Particle(iso.sprite.x + rnd(0,8,true), iso.sprite.y + 3 + rnd(0,8));
			p.drawBox(1,1, Color.lighten( col ,0.9 ), rnd(0.5, 1));
			p.reset();
			p.delay = rnd(0,5);
			p.dy = -rnd(0.2, 0.7);
			p.gx = 0.02;
			p.life = irnd(10,30);
			p.filters = [ new flash.filters.GlowFilter(Color.lighten(col,0.3),1, 4,4, 6) ];
			register(p);
		}
	}
	
		
	public function waterShine(x:Float,y:Float, col:Int) {
		var col = Color.saturationInt(col,0.5);
		init();

		var n = 50;
		for(i in 0...n) {
			var p = new Particle(x + 5 + rnd(0,6,true), y + rnd(0,20));
			p.drawBox( rnd(10,15), 1, Color.lighten( col ,0.7 ), rnd(0.3, 0.6) );
			p.reset();
			p.delay = i*2 + rnd(0,5);
			p.dsx = rnd(0, 0.05, true);
			p.dx = rnd(0,0.5,true);
			p.frictX = 0.9;
			p.alpha = 0;
			p.da = 0.05;
			p.life = irnd(20,40);
			p.filters = [
				new flash.filters.GlowFilter(col,1, 2,2, 2),
				new flash.filters.GlowFilter(col,1, 8,8, 2),
			];
			register(p);
		}
	}

	
	public function divineDoor(iso:Iso, col:Int) {
		var col = Color.saturationInt(col,0.5);
		init();

		var ad = 150;
		var ar = rad(ad);
		var n = 50;
		for(i in 0...n) {
			var p = new Particle(iso.sprite.x + 5 + rnd(0,6,true), iso.sprite.y + rnd(0,20));
			p.drawBox( rnd(10,30), 1, Color.lighten( col ,0.7 ), rnd(0.3, 0.6) );
			p.reset();
			p.delay = i*2 + rnd(0,5);
			p.rotation = ad;
			var s = rnd(0.1, 0.3);
			p.dx = Math.cos(ar)*s;
			p.dy = Math.sin(ar)*s;
			p.alpha = 0;
			p.da = 0.05;
			p.life = irnd(20,40);
			p.filters = [
				new flash.filters.GlowFilter(col,1, 2,2, 2),
				new flash.filters.GlowFilter(col,1, 8,8, 2),
			];
			p.onUpdate = function() {
				p.scaleX = 1-p.time();
			}
			register(p);
		}
	}
	
	public function sacredHalo(iso:Iso, col:Int) {
		init();
		var pt = iso.getHead();
		for( i in 0...70 ) {
			var p = new Particle( pt.x, pt.y-4 );
			var a = -rnd(-1, 4.14);
			p.reset();
			p.graphics.lineStyle(1, 0xffffff, rnd(0.5, 1));
			p.graphics.moveTo(14, 1);
			p.graphics.lineTo(14, 0);
			p.dr = rnd(0.1, 2) * (a<-1.57 ? 1 : -1);
			p.dsx = -rnd(0.008, 0.010);
			p.alpha = 0;
			p.da = 0.07;
			p.delay = i*0.3;
			p.rotation = deg(a);
			p.filters = [
				new flash.filters.GlowFilter(col,1, 8,8,5),
			];
			register(p);
		}
	}
	
	public function done(iso:Iso, col:Int) {
		//var col = Color.saturationInt(col,0.5);
		init();
		
		// Paillettes tombantes
		var pt = iso.getHead();
		for(i in 0...15) {
			var p = new Particle(pt.x + rnd(0,10,true), pt.y - rnd(15,35));
			p.reset();
			p.drawBox(1,1, 0xffffff, rnd(0.5,1));
			p.dy = rnd(0.3, 0.7);
			p.alpha = 0;
			p.da = 0.1;
			p.frictY = rnd(0.97, 0.99);
			p.delay = i*1.2 + rnd(0,4);
			p.life = rnd(32,64);
			p.filters = [ new flash.filters.GlowFilter(col,1, 4,4, 4) ];
			register(p, BlendMode.ADD);
		}
		
		// Lumière divine
		var a = 1.57;
		for(i in 0...10) {
			var p = new Particle(iso.sprite.x + rnd(0,8,true), iso.sprite.y - rnd(10,40));
			p.drawBox(rnd(15,20),1, Color.lighten( col ,0.4 ), rnd(0.5, 1));
			p.reset();
			p.delay = rnd(0,5);
			p.rotation = deg(a);
			var s = rnd(0.2, 0.3);
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s;
			p.alpha = 0;
			p.da = 0.05;
			p.delay = i*3 + rnd(0,3);
			p.life = irnd(40,80);
			p.filters = [
				new flash.filters.BlurFilter(8,8),
				new flash.filters.GlowFilter(col,1, 8,8, 1),
			];
			register(p);
		}

		// lumière au sol
		back();
		var pt = iso.getFeet();
		var p = new Particle(pt.x, pt.y);
		p.reset();
		p.drawCircle(15, 0xffffff, 0.7);
		p.alpha = 0;
		p.da = 0.05;
		p.scaleY = 0.5;
		p.life = 140;
		p.filters = [
			new flash.filters.BlurFilter(16,8),
		];
		register(p, BlendMode.OVERLAY);
	}
	
	
	public function objectShine(iso:Iso, col:Int) {
		init();
		var col = Color.saturationInt(col,0.5);

		for(i in 0...2) {
			var p = new Particle(iso.getFeet().x + rnd(0,4,true), iso.getFeet().y - rnd(0,10));
			p.drawBox(1,1, Color.lighten( col ,0.9 ), rnd(0.5, 1));
			p.reset();
			p.delay = rnd(0,10);
			p.dy = -rnd(0.2, 0.4);
			p.life = irnd(10,30);
			p.filters = [ new flash.filters.GlowFilter(Color.lighten(col,0.3),0.5, 4,4, 6) ];
			register(p);
		}
	}
	
	public function shine(iso:Iso, col:Int, ?dx=0) {
		init();
		var col = Color.saturationInt(col,0.5);

		for(i in 0...20) {
			var p = new Particle(iso.sprite.x + rnd(0,8,true) + dx, iso.sprite.y + 24 - rnd(0,10));
			p.drawBox(1,1, Color.lighten( col ,0.9 ), rnd(0.5, 1));
			p.reset();
			p.delay = rnd(0,10);
			p.dy = -rnd(0.2, 0.7);
			p.life = irnd(10,30);
			p.filters = [ new flash.filters.GlowFilter(Color.lighten(col,0.3),1, 4,4, 6) ];
			register(p);
		}
	}
	
	public function shineMC(mc:flash.display.DisplayObjectContainer, x:Float,y:Float, col:Int, n:Int) {
		init();
		var col = Color.saturationInt(col,0.5);

		for(i in 0...n) {
			var p = new Particle(x + rnd(0,6,true), y + rnd(0,5));
			p.drawBox(1,1, Color.lighten( col ,0.3 ), rnd(0.5, 1));
			p.reset();
			p.delay = i*2;
			p.alpha = 0;
			p.da = 0.1;
			p.dy = -rnd(0.2, 0.7);
			p.gx = rnd(0, 0.05);
			p.life = irnd(10,30);
			p.filters = [ new flash.filters.GlowFilter(col,1, 8,8, 5) ];
			registerInto(mc, p);
		}
	}
	
	public function orb(mc:flash.display.DisplayObjectContainer, cx:Float,cy:Float) {
		if( Const.LOWQ )
			return;
			
		mc.cacheAsBitmap = false;
			
		init();
		var r = man.hud._maskFeu.scaleY;
		
		// Bulles
		for(i in 0...irnd(1,2)) {
			var a = rnd(0.3, 2.84);
			var d = rnd(15, 22);
			var x = cx+Math.cos(a)*d;
			var p = new Particle(x, cy+Math.sin(a)*d);
			p.reset();
			p.graphics.lineStyle(1, 0xFFFFFF, rnd(0.2, 0.6), flash.display.LineScaleMode.NONE);
			p.graphics.drawCircle(0, 0, rnd(0.5, 1.2));
			p.delay = i*2;
			p.alpha = 0;
			p.da = 0.1;
			p.dy = r<=0.6 ? -rnd(0.3, 0.5) : -rnd(0.1, 0.3);
			p.life = irnd(20,40);
			p.pixel = false;
			registerInto(mc, p, BlendMode.OVERLAY);
			var t = rnd(0,3.14);
			var os = r<=0.7 ? rnd(0.5, 1) : 0;
			p.onUpdate = function() {
				t+=rnd(0.07,0.14);
				p.x = x+Math.cos(t*3.14)*os;
				if( p.y<= cy+22-man.hud._maskFeu.height )
					p.destroy();
			}
		}
		
		// Surface
		var n = r<=0.6 ? irnd(5,8) : irnd(1,3);
		var tries = 20;
		if( r>0.95 || r<0.05 )
			n = 0;
		while(n>0 && tries-->0) {
			var x = cx + rnd(0,20,true);
			var y = cy + 21-man.hud._maskFeu.height+2;
			if( Lib.distance(x,y,cx,cy)>=21 )
				continue;
			var p = new Particle(x,y);
			p.reset();
			p.pixel = false;
			p.graphics.beginFill(Color.capBrightnessInt(Const.HEAL_TXT_COLOR, 0.9), rnd(0.7,0.9));
			p.graphics.drawCircle(0, 0, r<=0.6 ? rnd(0.7, 2) : rnd(0.5, 1.6));
			p.alpha = 0;
			p.da = rnd(0.1, 0.2);
			p.gy = -rnd(0, 0.008);
			p.life = irnd(5,15);
			p.filters = [ new flash.filters.BlurFilter(2,4) ];
			registerInto(mc, p, BlendMode.NORMAL);
			n--;
		}
		
		// Fumée
		if( r < 0.7 ) {
			var tries = 20;
			var n = (r<=0.6) ? irnd(2,6) : Std.random(2);
			if( r>0.95 || r<0.02 )
				n = 0;
			while(n>0 && tries-->0) {
				var x = cx + rnd(0,18,true);
				var y = cy + 21-man.hud._maskFeu.height+1;
				if( Lib.distance(x,y,cx,cy)>=21 )
					continue;
				var p = new Particle(x,y);
				p.reset();
				p.pixel = false;
				p.graphics.beginFill(0xffffff, (r<=0.5 ? 0.2 : 0) + rnd(0.1, 0.2));
				p.graphics.drawCircle(0, 0, rnd(1, 3));
				p.alpha = 0;
				p.da = rnd(0.05, 0.10);
				p.gy = -rnd(0.03, 0.04);
				p.life = irnd(10,20);
				p.filters = [ new flash.filters.BlurFilter(8,8) ];
				registerInto(mc, p, BlendMode.NORMAL);
				n--;
			}
		}
	}
	
	public function sand(mc, x,y, col) {
		init();
		for(i in 0...15) {
			var p = new Particle(x+rnd(0,1,true), y+rnd(0,1,true)-19);
			p.reset();
			p.drawBox(1,1,col, rnd(0.2,0.4));
			p.groundY = man.hud._bottom.y-2-22;
			p.bounce = 0.1;
			p.life = 35; //rnd(16,30);
			p.onBounce = function() {
				p.dx = rnd(0.1, 0.3, true);
				p.dy = rnd(0.1, 0.3);
				p.groundY = y;
				//p.gy*=0.5;
				p.gy = 0;
			}
			p.gy = rnd(0.03, 0.05);
			p.delay = i*2+rnd(0,8);
			registerInto(mc, p, BlendMode.NORMAL);
		}
	}
	
	public function bubbles(iso:Iso, ?xoff=0, ?alpha=1.0) {
		init();

		for(i in 0...5) {
			var p = new Particle(iso.sprite.x + rnd(0,8,true)+xoff, iso.sprite.y + iso.headY + rnd(0,5));
			//p.drawBox(1,1, Color.lighten( col ,0.9 ), rnd(0.5, 1));
			p.graphics.lineStyle(1, 0xFFFFFF, rnd(0.4, 0.8)*alpha);
			p.graphics.drawCircle(0,0, rnd(1,2));
			p.reset();
			p.alpha = 0;
			p.da = 0.1;
			p.delay = rnd(0,24);
			p.dy = -rnd(0.1, 0.4);
			//p.gx = 0.02;
			p.life = irnd(10,30);
			//p.filters = [ new flash.filters.GlowFilter(Color.lighten(col,0.3),1, 4,4, 6) ];
			register(p);
		}
	}
	
	public function row(y, col) {
		init();
		var center = Std.int(Const.RWID*0.5);
		for(dx in 0...center) {
			for(x in [center+dx, center-dx]) {
				var pt = Iso.isoToScreenStatic(x,y);
				var p = new Particle(pt.x, pt.y+20);
				p.drawCircle(2, col, 1);
				p.filters = [ new flash.filters.BlurFilter(4,4) ];
				p.life = rnd(2,3);
				p.ds = 0.3;
				p.delay = dx*3;
				register(p);
				
				for(i in 0...8) {
					var p = new Particle(pt.x, pt.y + 15);
					p.moveAng( rnd(0,6.28), rnd(4,5) );
					p.drawBox(1,1, col);
					//p.dy = -rnd(1, 3);
					p.frictX = p.frictY = 0.8;
					p.delay = dx*3;
					p.life = irnd(0,16);
					p.filters = [ new flash.filters.GlowFilter(col,1, 8,8, 5) ];
					register(p);
				}
			}
		}
	}
		
	public function column(x, y1, y2, col) {
		init();
		var n = 0;
		var y = y2;
		while( y>=y1 ) {
			// smoke
			back();
			for(i in 0...20) {
				var pt = Iso.isoToScreenStatic(x,y);
				var p = new Particle(pt.x + rnd(0,8,true), pt.y + 24 - rnd(0,4));
				p.reset();
				p.drawBox(irnd(2,5),irnd(2,5), 0x171C20, rnd(0.4, 0.9));
				p.gx = 0.03;
				p.dr = rnd(5,20,true);
				p.dy = -rnd(0.3, 0.4);
				p.delay = n*1 + rnd(0,15);
				p.life = irnd(0,16);
				p.filters = [ new flash.filters.BlurFilter(4,4) ];
				register(p, BlendMode.NORMAL);
			}
			
			front();
			// fire
			for(i in 0...10) {
				var pt = Iso.isoToScreenStatic(x,y);
				var p = new Particle(pt.x + rnd(0,8,true), pt.y + 24 - rnd(0,8));
				p.reset();
				p.drawBox(1,irnd(1,8), col);
				p.dy = -rnd(0.5, 5);
				p.frictY = 0.9;
				p.delay = n*1 + rnd(0,5);
				p.life = irnd(0,16);
				p.filters = [ new flash.filters.GlowFilter(Color.lighten(col,0.3),1, 4,4, 2) ];
				register(p);
			}
			n++;
			y--;
		}
	}
	
	
	public  function buff(iso:Iso) {
		init();
		var pt = iso.getHead();
		for(i in 0...2) {
			var dist = rnd(5,10);
			var p = new Particle(pt.x+rnd(6,8,true), pt.y+rnd(0,12,true));
			p.drawBox(1,1, 0xFFFF80, rnd(0.6,1));
			p.dx = rnd(0.1, 0.3, true);
			p.dy = rnd(0.1, 0.3, true);
			p.frictX = 1;
			p.frictY = 1;
			p.life = rnd(5, 15);
			p.alpha = 0;
			p.da = 0.1;
			p.filters = [
				new flash.filters.GlowFilter(0xFFCC00,0.7, 4,4, 8),
			];
			register(p);
		}
		iso.sprite.filters = [
			new flash.filters.GlowFilter(0xFFFF80,0.5, 2,2, 4),
			new flash.filters.GlowFilter(0xFFBE37,0.5, 8,8, 2),
		];
	}
	
	
	
	public function surprise(iso:Iso, ?col=0xFFFFFF) {
		init();
		for( i in 0...5 ) {
			var a = -50 - i*30;
			var ar = rad(a);
			var p = new Particle(iso.sprite.x + Math.cos(ar)*5, iso.sprite.y + Math.sin(ar)*5 + iso.headY );
			p.drawBox(irnd(3,5),1, col);
			p.reset();
			p.life = 5;
			p.moveAng(ar, rnd(2,3));
			p.frictX = p.frictY = 0.7;
			p.rotation = a;
			p.filters = [ new flash.filters.GlowFilter(col,0.7, 4,4, 1) ];
			register(p);
		}
	}
	
	public function blink(iso:Iso, col:Int, ?count=1, ?duration=700) {
		var o = {t:0.}
		var a = man.tw.create(o, "t", 1, TLinear, duration);
		a.onUpdateT = function(t) {
			if( t<1 )
				iso.sprite.filters = [ new flash.filters.GlowFilter(col, 0.9 * Math.abs(Math.sin(count*3.14*t)), 2,2,5) ];
			else
				iso.sprite.filters = [];
		}
		return a;
	}
	
	public function blinkMC(mc:flash.display.DisplayObject, col:Int, ?count=1, ?duration=700) {
		var o = {t:0.}
		var a = man.tw.create(o, "t", 1, TLinear, duration);
		a.onUpdateT = function(t) {
			if( t<1 )
				mc.filters = [ new flash.filters.GlowFilter(col, 1 * Math.abs(Math.sin(count*3.14*t)), 8,8,2) ];
			else
				mc.filters = [];
		}
		return a;
	}
	
	public function teint(iso:Iso, col:Int, ratio:Float, ?duration=700) {
		init();
		var o = {t:0.}
		var a = man.tw.create(o, "t", 1, TEaseOut, duration);
		a.onUpdateT = function(t) {
			var f = ratio * Math.sin(t*3.14);
			if( t<1 )
				iso.sprite.filters = [ Color.getColorizeMatrixFilter(col, f, 1-f) ];
			else
				iso.sprite.filters = [];
		}
		return a;
	}
	
	public function attention(iso:Iso, raise:Bool) {
		init();
		var col = raise ? 0x80FF00 : 0xD83027;
		var a = new Sprite();
		a.graphics.lineStyle(2, col, 1);
		var w = 2;
		a.graphics.moveTo(-w,0);
		a.graphics.lineTo(0,-w);
		a.graphics.lineTo(w,0);
		
		a.graphics.moveTo(0,-w);
		a.graphics.lineTo(0,w);
		
		a.scaleY = raise ? 1 : -1;
		
		var p = new Particle(iso.sprite.x-6, iso.sprite.y + iso.headY + (raise?5:-1));
		p.addChild(a);
		p.reset();
		p.alpha = 0;
		p.da = 0.15;
		p.gy = 0.02 * (raise?-1:1);
		p.life = 20;
		p.filters = [new flash.filters.GlowFilter(0x0,1, 2,2, 3)];
		register(p, BlendMode.NORMAL);
	}
	
	public function smokeBomb(iso:Iso, col:Int, ?offsetY=0) {
		init();
		front();
		var pt = iso.getBodyCenter();
		for(i in 0...20) {
			var p = new Particle(pt.x+rnd(0,8,true), pt.y+rnd(0,10,true) + offsetY);
			var alpha = rnd(0.4, 0.8);
			p.graphics.beginFill(col, alpha);
			p.graphics.drawCircle(0,0, 6);
			for(j in 0...irnd(1,4)) {
				p.graphics.endFill();
				p.graphics.beginFill(col, alpha);
				p.graphics.drawCircle(rnd(2,3,true), rnd(2,3,true), rnd(2,3));
			}
			p.dr = rnd(3,10,true);
			p.dx = rnd(0.6, 1.5, true);
			p.dy = rnd(0.6, 1.5, true);
			p.frictX = p.frictY = 0.92;
			p.life = rnd(10,30);
			p.filters = [
				new flash.filters.BlurFilter(2,2)
			];
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function smoke(iso:Iso, col:Int, ?scale=1.0, ?xOffset=0.0) {
		init();
		front();
		for(i in 0...30) {
			var p = new Particle(iso.sprite.x + xOffset, iso.sprite.y+28 - rnd(0,3));
			p.reset();
			var alpha = rnd(0.4, 0.8);
			p.graphics.beginFill(col, alpha);
			p.graphics.drawCircle(0,0, 4);
			for(j in 0...irnd(1,4)) {
				p.graphics.endFill();
				p.graphics.beginFill(col, alpha);
				p.graphics.drawCircle(rnd(2,3,true), rnd(2,3,true), rnd(2,3));
			}
			p.dr = rnd(3,10,true);
			p.dx = rnd(0.05, 0.2, true);
			p.dy = -rnd(0.6, 1.5);
			p.gx = 0.01;
			p.alpha = 0;
			p.da = 0.05;
			p.delay = i*0.5 + rnd(0,10);
			p.life = irnd(40,64);
			p.frictY = 0.97;
			p.scaleX = p.scaleY = scale;
			p.filters = [
				new flash.filters.BlurFilter(2,2,1)
			];
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function groundSmoke(iso:Iso, col:Int, ?scale=1.0) {
		init();
		back();
		for(i in 0...30) {
			var a = rnd(0, 2*3.1416);
			var p = new Particle(iso.sprite.x + iso.sprite.scaleX*6 + Math.cos(a)*rnd(0,3), iso.sprite.y+24 + Math.sin(a)*rnd(0,5));
			p.reset();
			var alpha = rnd(0.5, 0.8);
			p.graphics.beginFill(col, alpha);
			p.graphics.drawCircle(0,0, 4);
			for(j in 0...irnd(2,4)) {
				p.graphics.endFill();
				p.graphics.beginFill(col, alpha*0.8);
				p.graphics.drawCircle(rnd(2,3,true), rnd(2,3,true), rnd(2,3));
			}
			p.gy = -rnd(0, 0.005);
			p.dr = rnd(2,3,true);
			p.ds = -0.005;
			p.moveAng(a, rnd(0.65, 0.7));
			p.dy*=0.5; // transfo iso
			p.alpha = 0;
			p.da = 0.05;
			p.delay = i + rnd(0,15);
			p.life = irnd(50,74);
			p.scaleX = p.scaleY = scale;
			p.filters = [
				new flash.filters.BlurFilter(2,2,1)
			];
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function rainDots(iso:Iso, col:Int, ?blend:BlendMode) {
		if( blend==null )
			blend = BlendMode.ADD;
		init();
		var n = 40;
		var pt = iso.getHead();
		for(i in 0...n) {
			var p = new Particle(pt.x + rnd(0,8,true), pt.y - 18 - rnd(0,6));
			p.drawBox(1,1, col, rnd(0.5,1));
			p.reset();
			p.gy = rnd(0.02, 0.025);
			p.dy = rnd(0,0.2);
			p.groundY = iso.getFeet().y - 1 + rnd(0,2);
			p.alpha = 0;
			p.da = 0.1;
			p.delay = i*1.2 + rnd(0,4);
			p.bounce = 0;
			p.life = rnd(32,64);
			p.onBounce = function() {
				p.life = 0;
				p.dy = p.gy = 0;
				p.dx = rnd(0.1, 0.6, true);
			}
			p.filters = [ new flash.filters.GlowFilter(col,1, 4,4, 2) ];
			register(p, blend);
		}
	}
	
	
	public function risingDots(x:Float,y:Float, col:Int) {
		init();
		var n = 20;
		for(i in 0...n) {
			var p = new Particle(x + rnd(0,3,true), y - rnd(0,4));
			p.drawBox(1,1, col, rnd(0.5,1));
			p.reset();
			p.gy = -rnd(0.03, 0.035);
			p.dy = -rnd(1,3);
			p.alpha = 0;
			p.da = 0.1;
			p.frictY = 0.85;
			p.delay = i*1.2 + rnd(0,3);
			p.life = rnd(15,30);
			p.filters = [ new flash.filters.GlowFilter(col,1, 4,4, 4) ];
			register(p);
		}
	}
	
	public function moveFeedBack(x,y) {
		init();
		var p = new Particle(x,y);
		p.graphics.lineStyle(1, 0x926FFB, 1);
		p.graphics.drawCircle(0,0, 5);
		p.scaleY = 0.6;
		p.ds = 0.1;
		p.life = 0;
		registerGlobal(p);
	}
	
	
	public function rainLines(iso:Iso, col:Int) {
		init();
		var n = 40;
		var pt = iso.getHead();
		for(i in 0...n) {
			var p = new Particle(pt.x + rnd(0,8,true), pt.y - 18 - rnd(0,6));
			p.drawBox(1,rnd(3,8), col, rnd(0.5,1));
			p.reset();
			p.dy = rnd(1,2);
			//p.gy = rnd(0.02, 0.025);
			p.alpha = 0;
			p.da = 0.1;
			p.delay = i*1.2 + rnd(0,4);
			p.life = 10;
			p.filters = [ new flash.filters.GlowFilter(col,1, 4,4, 2) ];
			register(p);
		}
	}
	
	public function scooterSmoke(x:Float,y:Float, ?col=0xE3DEDB, ?scale=1.0) {
		init();
		front();
		var n = 2;
		for(i in 0...n) {
			var p = new Particle(x+rnd(0,5,true), y+rnd(0,1,true));
			p.reset();
			var w = rnd(1,5);
			p.drawBox(w,w, col, rnd(0.3, 0.7));
			p.filters = [ new flash.filters.BlurFilter(2,2) ];
			p.delay = rnd(0, n*0.8);
			p.life = rnd(20,30);
			p.dx = rnd(0, 0.3);
			p.scaleX = p.scaleY = scale;
			p.gx = 0.1*rnd(0.005, 0.010);
			p.gy = -rnd(0.008, 0.020);
			register(p, BlendMode.NORMAL);
		}
	}
	
	//public function dust(x,y, ?n=10) {
		//init();
		//for(i in 0...n) {
			//var p = new Particle(x+rnd(0,3,true), y+rnd(0,4,true));
			//p.reset();
			//p.drawBox(1,1,0xC0C0C0, rnd(0.2,0.4));
			//p.gx = rnd(0.01,0.04);
			//p.gy = rnd(0.02,0.06);
			//p.frictX = 0.80;
			//p.frictY = 0.94;
			//p.life = rnd(10,30);
			//p.bounce = 0;
			//p.groundY = y+16;
			//register(p);
		//}
	//}
	
	public function dustGround(x:Float,y:Float, ?n=4) {
		init();
		back();
		for(i in 0...n) {
			var p = new Particle(x+rnd(0,5,true), y+rnd(0,1,true));
			p.reset();
			var w = rnd(1,3);
			p.drawBox(w,w, 0xAD9D92, rnd(0.3, 0.7));
			p.filters = [ new flash.filters.BlurFilter(2,2) ];
			p.delay = rnd(0, n*0.8);
			p.life = rnd(20,30);
			p.dx = rnd(0, 0.3);
			p.gx = 0.1*rnd(0.005, 0.010);
			p.gy = -rnd(0.008, 0.020);
			register(p, BlendMode.MULTIPLY);
		}
	}
	
	
	public function smokeNova(pt:Point, ?col=0xAD9D92, sizeRatio=1.0, ?shrink=false, ?spd=1.0) {
		init();
		back();
		
		for( i in 0...(Const.LOWQ ? 20 : 50) ) {
			var a = rnd(0, 6.28);
			var s = 7*sizeRatio*spd;
			var d = shrink ? 100*sizeRatio : 0;
			var p = new Particle(pt.x+Math.cos(a)*d, pt.y+Math.sin(a)*d*0.5);
			p.reset();
			p.drawCircle( rnd(1,4), col, rnd(0.4, 0.8) );
			p.dr = rnd(1,5,true);
			p.dx = Math.cos(a)*s * (shrink?-1:1);
			p.dy = Math.sin(a)*s*0.5 * (shrink?-1:1);
			p.delay = rnd(0,3);
			//p.gy = -0.05;
			p.frictX = p.frictY = 0.94;
			p.life = rnd(8,20)*(1/spd);
			p.filters = [
				new flash.filters.BlurFilter(4,4),
			];
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function nova(pt:Point, col:Int, ?sizeRatio=1.0, ?blend:BlendMode) {
		back();
		var w = 7*sizeRatio;
		var p = new Particle(pt.x, pt.y);
		p.reset();
		var m = new flash.geom.Matrix();
		m.createGradientBox(w, w*0.5, 0, -w*0.5, -w*0.25);
		var c = Color.brightnessInt(col, 0.6);
		p.graphics.beginGradientFill(flash.display.GradientType.RADIAL, [col,col,col], [0,0,0.8], [0,160,255], m);
		p.graphics.drawEllipse(-w*0.5, -w*0.25, w, w*0.5);
		p.life = 999;
		p.da = -0.05;
		p.delay = 5;
		p.ds = 1.5;
		p.onUpdate = function() {
			p.ds*=0.90;
			if( p.alpha<=0 )
				p.life = 0;
		}
		register(p, blend!=null ? blend : BlendMode.NORMAL);
	}
	
	
	public function explosion(iso:Iso, col:Int, ?power=1.0) {
		init();
		var pt = iso.getHead();
		for(i in 0...(Const.LOWQ ? 20 : 40)) {
			var a = rnd(0, 6.28);
			var d = rnd(30,80)*power;
			var p = new Particle(pt.x-Math.cos(a)*d, pt.y-Math.sin(a)*d);
			p.reset();
			p.drawBox(rnd(1,4),1, 0xffffff, rnd(0.7, 1));
			p.rotation = deg(a);
			p.alpha = 0;
			p.da = rnd(0.005, 0.100);
			var s = rnd(0.8, 1) * d*0.2 * power;
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s;
			p.life = rnd(16,32) * power;
			p.frictX = p.frictY = 0.92;
			p.filters = [
				new flash.filters.GlowFilter(col, 1, 2,2, 3),
				new flash.filters.GlowFilter(col, 1, 8,8, 2),
			];
			register(p);
		}
	}
	
	
	public function dotsExplosion(iso:Iso, col:Int, ?power=1.0) {
		init();
		var pt = iso.getHead();
		for(i in 0...(Const.LOWQ ? 20 : 40)) {
			var a = rnd(0, 6.28);
			var d = rnd(30,80)*power;
			var p = new Particle(pt.x+rnd(0,5,true), pt.y+rnd(0,5,true));
			p.drawBox(1,1, col, rnd(0.7, 1));
			p.dx = rnd(0.5, 3, true);
			p.dy = -rnd(1, 6);
			p.delay = rnd(0,3);
			p.life = rnd(5,20) * power;
			p.frictX = p.frictY = 0.94;
			p.gy = rnd(0.2, 0.5);
			p.groundY = p.y + 20;
			p.onBounce = function() {
				p.destroy();
			}
			p.filters = [
				new flash.filters.GlowFilter(col, 1, 2,2, 3),
				new flash.filters.GlowFilter(col, 1, 8,8, 2),
			];
			register(p);
		}
	}
	
	
	public function smallExplosion(iso:Iso, col:Int) {
		init();
		
		var pt = iso.getHead();
		var p = new Particle(pt.x, pt.y);
		p.reset();
		var s = man.tiles.getSprite("hit",1);
		s.setCenter(0.5, 0.5);
		p.addChild(s);
		p.alpha = 0.7;
		p.rotation = rnd(0,360);
		p.scaleX = p.scaleY = rnd(1.6, 2);
		p.ds = -0.15;
		p.life = 10;
		p.filters = [
			new flash.filters.GlowFilter(col, 1, 8,8,2),
		];
		register(p);

		for(i in 0...(Const.LOWQ ? 15 : 30)) {
			var a = rnd(0, 6.28);
			var d = rnd(0,5);
			var p = new Particle(pt.x+Math.cos(a)*d, pt.y+Math.sin(a)*d);
			p.reset();
			var s = man.tiles.getSprite("dots", man.tiles.getRandomFrame("dots"));
			s.alpha = rnd(0.3, 1);
			s.setCenter(0.5, 0.5);
			p.addChild(s);
			p.alpha = 0;
			p.dr = rnd(2,6,true);
			p.da = rnd(0.005, 0.100);
			var s = rnd(0.4, 1.5);
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s;
			p.life = rnd(20,32);
			p.frictX = p.frictY = 0.96;
			p.scaleX = p.scaleY = rnd(0.5, 1);
			p.filters = [
				new flash.filters.GlowFilter(col, 1, 2,2, 4),
				new flash.filters.GlowFilter(col, 1, 8,8, 4),
			];
			register(p);
		}
	}
	
	
	public function charge(iso:Iso, col:Int, ?n=30) {
		init();
		var pt = iso.getBodyCenter();
		for(i in 0...n) {
			var a = rnd(0, 6.28);
			var d = 30;
			var p = new Particle(pt.x + Math.cos(a)*d, pt.y + Math.sin(a)*d );
			p.reset();
			p.drawBox(rnd(3,8), 1, col );
			p.moveAng(a, -rnd(2.8,3.3));
			p.rotation = deg(Math.atan2(p.dy,p.dx));
			p.delay = i+rnd(0,7);
			p.alpha = 0;
			p.da = 0.15;
			p.life = irnd(10,15);
			p.frictX = p.frictY = 0.92;
			p.filters = [ new flash.filters.GlowFilter(col,1, 8,8, 4) ];
			register(p, col==0x0 ? BlendMode.NORMAL : BlendMode.ADD);
		}
	}
	
	
	public function chargeGround(iso:Iso, col:Int) {
		init();
		// Au sol
		back();
		var c = Color.brightnessInt(col, -0.4);
		for(i in 0...50) {
			var a = rnd(0, 6.28);
			var d = 35;
			var p = new Particle(iso.sprite.x + Math.cos(a)*d, iso.sprite.y + 24 + Math.sin(a)*d*0.4 );
			p.reset();
			p.drawBox(rnd(4,8), 1, c, rnd(0.6,1) );
			p.moveAng(a, -rnd(2.8,3.3));
			p.dy*=0.4;
			p.rotation = deg(Math.atan2(p.dy,p.dx));
			p.delay = rnd(0,25);
			p.alpha = 0;
			p.da = 0.15;
			p.life = irnd(10,15);
			p.frictX = p.frictY = 0.95;
			p.filters = [ new flash.filters.GlowFilter(c,1, 4,4, 2) ];
			register(p);
		}
		// Colonne
		front();
		var n = 80;
		for(i in 0...n) {
			var atFront = i<n/2;
			if( !atFront )
				back();
			var a = rnd(0.5, 2.6) + (atFront ? 0 : 3.14);
			var d = 7;
			var p = new Particle(iso.sprite.x + Math.cos(a)*d*1.6, iso.sprite.y + 16 + Math.sin(a)*d + (atFront?0:10) );
			p.reset();
			p.drawBox(1, rnd(3,5), col, atFront ? rnd(0.85,1) : rnd(0.3,0.5) );
			p.delay = (atFront ? 10 : 0) + 5 + rnd(0,25);
			p.gy = -0.07;
			p.life = irnd(10,15);
			p.filters = [ new flash.filters.GlowFilter(col,1, 4,4, 2) ];
			register(p);
		}
	}
	
	public function cloud(iso:Iso, col:Int) {
		init();
		var pt = iso.getHead();
		for(i in 0...20) {
			var p = new Particle(pt.x + rnd(0,7,true), pt.y-8-rnd(0,7));
			p.reset();
			var w = rnd(3,5);
			p.gy = -0.006;
			p.drawBox(w,w, col, rnd(0.5,1));
			p.delay = rnd(0,10);
			p.dr = rnd(5,15, true);
			p.filters = [new flash.filters.BlurFilter(2,2)];
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function psyAttack(iso:Iso, col:Int, ?n=5) {
		init();
		var pt = iso.getHead();
		
		for( i in 0...n ) {
			var p = new Particle(pt.x, pt.y);
			p.reset();
			p.graphics.lineStyle(1, col, 0.5, flash.display.LineScaleMode.NONE);
			p.graphics.drawCircle(0,0, 3);
			p.ds = 0.05;
			p.dx = -0.5;
			p.dy = -p.dx*0.5;
			p.life = 20;
			p.delay = i*10;
			register(p);
		}
	}
	
	public function psyAttackTeacher(iso:Iso, col:Int, ?n=5) {
		init();
		var pt = iso.getHead();
		
		for( i in 0...n ) {
			var p = new Particle(pt.x+5, pt.y-2);
			p.reset();
			p.graphics.lineStyle(1, col, 0.7, flash.display.LineScaleMode.NONE);
			p.graphics.drawCircle(0,0, 3);
			p.ds = 0.05;
			p.dx = 0.5;
			p.dy = -p.dx*0.5;
			p.life = 20;
			p.delay = i*10;
			register(p);
		}
	}
	
	
	public function paper(from:Iso, to:Iso, ?n=1) {
		init();
		var fpt = from.getHead();
		var tpt = to.getHead;
		for(i in 0...n) {
			var w = 8;
			var h = w*1.3;
			var p = new Projectile(from.getHead().x, from.getHead().y, rnd(3,4));
			p.setTarget(to.getHead().x, to.getHead().y);
			var spr = new Sprite();
			spr.graphics.beginFill(0xDFDAD0, 1);
			spr.graphics.drawRect(-w*0.5, -h*0.5, w, h);
			p.addChild(spr);
			p.scaleY = rnd(0.4, 0.5);
			p.filters = [
				new flash.filters.DropShadowFilter(1,90, 0xffffff,1, 0,0,1),
				new flash.filters.DropShadowFilter(9,90, 0x0,0.5, 4,4,1),
			];
			var r = rnd(5,15);
			p.onUpdate = function() {
				spr.rotation+=r;
			}
			pregister(p, BlendMode.NORMAL);
			//var r = rnd(8,20,true);
			//var w = 8;
			//var h = w*1.3;
			//var p = new Particle(pt.x+rnd(0,5,true), pt.y-rnd(0,5));
			//p.reset();
			//var spr = new Sprite();
			//spr.graphics.beginFill(Color.brightnessInt(0xDFDAD0, -rnd(0,0.3)), 1);
			//spr.graphics.drawRect(-w*0.5, -h*0.5, w, h);
			//p.addChild(spr);
			//p.life = 30;
			//var a = Math.atan2(to.getHead().y+5-from.getHead().y+5, to.getHead().x-from.getHead().x);
			//var s = /p.life;
			//p.dx = Math.cos(a)*s;
			//p.dy = Math.sin(a)*s;
			//p.dr = rnd(5,15);
			//p.delay = n*3;
			//p.scaleY = 0.5;
			//register(p);
		}
	}
	
	public function papers(iso:Iso, ?n=10) {
		init();
		var pt = iso.getFeet();
		for(i in 0...n) {
			var r = rnd(8,20,true);
			var w = rnd(3,6);
			var h = w*1.3;
			var p = new Particle(pt.x+rnd(0,5,true), pt.y-rnd(0,5));
			p.reset();
			var spr = new Sprite();
			spr.graphics.beginFill(Color.brightnessInt(0xDFDAD0, -rnd(0,0.3)), 1);
			spr.graphics.drawRect(-w*0.5, -h*0.5, w, h);
			p.addChild(spr);
			p.dy = -rnd(2,4);
			p.dx = rnd(0.1,1,true);
			p.delay = rnd(0, n*0.1);
			p.scaleY = rnd(0.4,0.6);
			p.gy = 0.2;
			p.groundY = pt.y - 15 + rnd(0,25);
			p.bounce = 0;
			p.onBounce = function() {
				r *= 0.5;
				p.frictX = 0.8;
				p.gy = 0;
				p.life = 0;
			}
			p.onUpdate = function() {
				spr.rotation+=r;
				//if( p.x>=pt.y && p.dy>0 )
					//p.dy *= -0.9;
			}
			register(p);
		}
	}
	
	
	public function hit(x:Float,y:Float, ?col=0xFF9F35, ?alpha=1.0, ?randPos=false) {
		init();
		var p = new Particle(x,y);
		if( randPos )
			p.setPos( x+rnd(0,4,true), y+rnd(0,4,true) );
		p.reset();
		p.graphics.lineStyle(1, Color.brightnessInt(col, 0.6), alpha*rnd(0.6,1), flash.display.LineScaleMode.NONE);
		var r = 2;
		p.graphics.drawCircle(0,0,r);
		p.rotation = rnd(0,360);
		p.dr = rnd(30,50);
		p.ds = 0.15;
		p.life = rnd(2,6);
		p.onUpdate = function() {
			p.ds*=0.95;
			p.dr*=0.85;
		}
		p.filters = [new flash.filters.GlowFilter(col, 0.5, 4,4, 2)];
		register(p, BlendMode.HARDLIGHT);
	}
	
	public function dustCeil(centerX:Float, centerY:Float, radius:Float) {
		init();
		var h = 40;
		var a = rnd(0, 6.28);
		var n = Math.max( 6, Math.ceil(25*radius/120) );
		for( j in 0...Std.int(n) ) {
			a = 3.14 * j/n + rnd(0,0.2);
			var x = centerX + Math.cos(a) * rnd(0,radius);
			var y = centerY - h + Math.sin(a) * rnd(0,radius*0.5);
			//hit(x,y);
			
			for( i in 0...irnd(2,5) ) {
				var p = new Particle(x,y);
				p.reset();
				p.alpha = 0;
				p.da = 0.1;
				p.drawBox(1,1, 0xC0C0C0, rnd(0.2,0.8));
				//p.gx = rnd(0, 0.03);
				p.gy = rnd(0.08, 0.20);
				p.frictX = 0.95;
				p.frictY = 0.93;
				p.groundY = y + h;
				//p.bounce = 0;
				p.life = rnd(40,55);
				register(p, BlendMode.NORMAL);
				p.filters = [ new flash.filters.BlurFilter(0,2) ];
				var n = 0;
				p.onBounce = function() {
					n++;
					if( n==1 ) {
						p.dx = rnd(0.3,0.5,true);
						p.alpha *= 0.6;
					}
					if( n>=2 ) {
						p.gy = p.dy = 0;
						p.bounce = 0;
						p.life = rnd(10,20);
					}
					p.filters = [
						//new flash.filters.BlurFilter(2,0),
						new flash.filters.DropShadowFilter(1,90, 0x0,0.5, 2,2)
					];
				}
			}
			
				var p = new Particle(x,y);
				p.reset();
				//p.alpha = 0;
				//p.da = 0.1;
				p.drawBox(rnd(2,5),1, 0xC0C0C0, rnd(0.2,0.3));
				//p.gx = rnd(0, 0.03);
				//p.gx = rnd(0.02, 0.20);
				//p.frictX = 0.95;
				//p.frictY = 0.9;
				p.life = rnd(5,10);
				p.ds = -0.02;
				register(p, BlendMode.NORMAL);
				p.filters = [ new flash.filters.BlurFilter(0,2) ];
		}
	}
	
	
	public function itemRain(iso:Iso, col:Int, n:Int) {
		init();
		var pt = iso.getHead();
		for(i in 0...n) {
			var p = new Particle(pt.x + rnd(0,8,true), pt.y - 30 - rnd(0,5));
			p.drawBox(2,1, col);
			p.alpha = 0;
			p.da = 0.2;
			p.dr = rnd(5,15);
			p.gy = 0.2;
			p.delay = i*2;
			p.dy = rnd(0,1);
			p.groundY = iso.getFeet().y;
			p.bounce = rnd(0.4, 0.8);
			p.frictX = 0.95;
			p.frictY = 0.96;
			p.onBounce = function() {
				if( p.dx==0 )
					p.dx = rnd(0.5,2,true);
				p.dr *= -1.3;
			}
			register(p);
		}
	}
	
	public function bigText(str:String, col:Int, ?duration=1000) {
		if( man.cm.turbo )
			return;
		init();
		
		var tf = man.createField(str, true);
		tf.textColor = col;
		tf.filters = [
			new flash.filters.DropShadowFilter(1,90, 0xFFFFFF,0.1, 0,0,1, 1, true),
			new flash.filters.DropShadowFilter(1,90, Color.brightnessInt(col, -0.3),1, 0,0,1),
			new flash.filters.GlowFilter(Color.brightnessInt(col, -0.6), 1, 2,2,8),
		];
		
		var wrapper = new Sprite();
		man.dm.add(wrapper, Const.DP_INTERF);
		wrapper.y = Std.int( Const.HEI*0.3 );
		
		var bmp = Lib.flatten(tf);
		wrapper.addChild(bmp);
		bmp.scaleX = bmp.scaleY = 5;
		bmp.x = Std.int(-bmp.width*0.5);
		
		man.tw.create(bmp, "x", bmp.x+20, TEaseOut, 1500);
		
		man.tw.create(wrapper, "x", Std.int(Const.WID*0.5), TLinear, 200).onEnd = function() {
			man.delayer.add( function() {
				bmp.transform.colorTransform = new flash.geom.ColorTransform(1,1,1,1, 255,255,255);
				man.tw.create(wrapper, "alpha", 0, 400).onEnd = function() {
					bmp.bitmapData.dispose();
					wrapper.parent.removeChild(wrapper);
				}
			}, duration);
		}
		
		//var p = new Particle(50,50);
		//p.addChild(bmp);
		//registerGlobal(p, BlendMode.NORMAL);
	}
	
	
	public function projHoming(from:Iso, to:Iso, col:Int, ?n=30) {
		init();
		for(i in 0...n) {
			var p = new Projectile(from.sprite.x, from.sprite.y+from.headY, 3);
			pregister(p);
			p.drawBox(rnd(2,3),2, Color.lighten(col,0.5), rnd(0.4,1));
			p.setHoming();
			p.delay = rnd(0, n*0.8);
			p.speed = rnd(2,3);
			p.setTarget( to.sprite.x, to.sprite.y+to.headY);
			p.filters = [ new flash.filters.GlowFilter(col, 1, 4,4,2) ];
			p.onUpdate = function() {
				var pt = man.buffer.globalToLocal(flash.Lib.current.stage.mouseX, flash.Lib.current.stage.mouseY);
				p.setTarget(pt.x, pt.y);
			}
			p.onEnd = function() hit(p.x, p.y, col, 0.5);
		}
	}
	
	public function projLines(from:Iso, to:Iso, col:Int, ?n=30, ?spd=1.0) {
		init();
		for(i in 0...n) {
			var pt = from.getHead();
			var p = new Projectile(pt.x+rnd(0,4,true), pt.y+rnd(0,4,true), 3);
			pregister(p);
			p.drawBox(rnd(5,9), rnd(0.3,1), Color.lighten(col,0.5), rnd(0.5,1));
			var pt = to.getHead();
			p.setTarget( pt.x+rnd(0,4,true), pt.y+rnd(0,4,true));
			p.setLinear();
			p.rotation = deg( Math.atan2(p.ty-p.y, p.tx-p.x) );
			p.delay = rnd(0,n*0.5);
			p.speed = rnd(5,8)*spd;
			p.filters = [ new flash.filters.GlowFilter(col, 1, 4,4,2) ];
			p.onEnd = function() hit(p.x, p.y, col, 0.5);
		}
	}
	
	public function projDots(from:Iso, to:Iso, col:Int, ?n=30, ?spd=1.0, ?ease=false) {
		init();
		for(i in 0...n) {
			var pt = from.getHead();
			var p = new Projectile(pt.x+rnd(0,4,true), pt.y+rnd(0,4,true), 3);
			pregister(p);
			p.drawBox(1,1, Color.lighten(col,0.5), rnd(0.6, 1));
			var pt = to.getHead();
			p.setTarget( pt.x+rnd(0,4,true), pt.y+rnd(0,4,true));
			if( ease )
				p.setEaseOut();
			else
				p.setLinear();
			p.pixel = true;
			p.delay = rnd(0,n*0.5);
			p.speed = rnd(4.5,7)*spd;
			p.filters = [ new flash.filters.GlowFilter(col, 1, 4,4,8) ];
			if( !Const.LOWQ )
				p.onEnd = function() hit(p.x, p.y, col, 0.5);
		}
	}
	public function projLaunch(from:Iso, to:Iso, col:Int, w:Int, h:Int, curv:Float, ?dx=0, ?dy=6) {
		init();
		
		var fpt = from.getHead();
		var p = new Projectile(fpt.x+dx, fpt.y+dy);
		p.drawBox(w,h, col, 1);
		var tpt = to.getHead();
		p.setTarget(tpt.x, tpt.y+6);
		p.speed = p.tdist()>40 ? 2 : 1;
		p.setLinear();
		var h = curv * rnd(30,40);
		p.onUpdate = function() {
			var d = Math.sin( p.progress()*3.14 ) * h;
			p.y -= d;
			p.filters = [
				new flash.filters.GlowFilter(0x0,0.8, 2,2, 3),
				new flash.filters.DropShadowFilter(d+16,90, 0x0,0.3, 4,4,1)
			];
		}
		p.dr = rnd(8,15,true);
		p.onEnd = function() man.cm.signal("projEnd");
		pregister(p, BlendMode.NORMAL);
		return p;
	}
	
	public function projObject(from:Iso, to:Iso, spd:Float, curve:Float, col:Int, w:Float,h:Float) {
		init();
		var p = new Projectile(from.sprite.x, from.sprite.y+from.headY+6);
		p.drawBox(w,h, col);
		p.setTarget(to.sprite.x, to.sprite.y+to.headY);
		p.speed = spd;
		p.setLinear();
		p.filters = [
			new flash.filters.GlowFilter(0x0,1, 2,2, 3),
			new flash.filters.DropShadowFilter(h*0.5,-90, 0x0,0.5, 0,0,1, 1,true)
		];
		p.onUpdate = function() {
			var d = Math.sin( p.progress()*3.14 ) * 25 * curve;
			p.y -= d;
		}
		p.dr = (8+Std.random(5)) * (Std.random(2)*2-1);
		p.onEnd = function() {
			man.cm.signal("projEnd");
		}
		
		pregister(p, BlendMode.NORMAL);
		
		return p;
		
	}
	
	public function leaves(col:Int, spd:Float) {
		init();
		bg();
		var start = Particle.ALL.length<10;
		var n = start ? 20 : irnd(1,3);
		for(i in 0...n) {
			var p = new Particle( rnd(-20,man.buffer.width), rnd(-20,man.buffer.height) );
			//p.drawBox(rnd(3,6),rnd(3,5), col, rnd(0.4,1));
			p.drawBox(1,1, 0xffffff, rnd(0.4,1));
			//p.r = rnd(5,9);
			p.gx = rnd(0.03, 0.12)*spd;
			p.gy = rnd(0.01, 0.06)*spd;
			p.frictX = p.frictY = 0.94;
			if( !start ) {
				p.alpha = 0;
				p.delay = rnd(0,16);
				p.da = 0.01;
			}
			p.life = rnd(96,200);
			p.filters = [
				//new flash.filters.BlurFilter(2,2),
				//new flash.filters.GlowFilter(Color.brightnessInt(col,0.3),1, 8,8,1),
				new flash.filters.GlowFilter(col, 0.9, 8,8, 1),
			];
			register(p, BlendMode.ADD);
		}
	}
		
	public function backSnow() {
		init();
		bg();
		var start = Particle.ALL.length<10;
		var n = start ? 20 : irnd(1,3);
		for(i in 0...n) {
			var w = irnd(1,2);
			var p = new Particle( rnd(0,man.buffer.width), rnd(-20,man.buffer.height) );
			p.drawBox(w,w, 0xffffff, rnd(0.4,1));
			p.gx = -rnd(0, 0.05);
			p.gy = rnd(0.03, 0.06);
			p.frictX = p.frictY = 0.94;
			if( !start ) {
				p.alpha = 0;
				p.delay = rnd(0,16);
				p.da = 0.01;
			}
			p.life = rnd(96,200);
			register(p, NORMAL);
		}
	}
	
	public function plasmaLightning() {
		init();
		bg();
		var x = rnd(0,man.buffer.width);
		var y = rnd(0,man.buffer.height);
		for(i in 0...irnd(2,4)) {
			var p = new Particle(x+rnd(0,15,true), y+rnd(0,15,true));
			p.reset();
			var w = rnd(80,200);
			var m = new flash.geom.Matrix();
			m.createGradientBox(w,w, 0, -w*0.5,-w*0.5);
			p.graphics.beginGradientFill(flash.display.GradientType.RADIAL, [0xffffff,0xffffff], [rnd(0.3,0.6),0], [0,255], m);
			p.graphics.drawCircle(0,0,w*0.5);
			p.alpha = 0;
			p.delay = rnd(0,20);
			p.da = rnd(0.1,0.3);
			p.gy = 0.01;
			p.life = rnd(16,40);
			register(p, BlendMode.OVERLAY);
		}
	}
	
	public function floatingObject() {
		init();
		bg();
		
		var mc : flash.display.MovieClip = null;
		if( rnd(0,100)<0.5 )
			mc = new lib.Perdu();
		else {
			mc = new lib.ObjetsPerdus();
			mc.gotoAndStop( Std.random(mc.totalFrames)+1 );
		}
		
		var a = -rnd(1.2, 3.6);
		var p = new Particle(50 + Math.cos(a)*100, 50+Math.sin(a)*100);
		p.ignoreLimit = true;
		p.reset();
		p.addChild(mc);
		p.dx = 0.3;
		p.dr = rnd(0.2, 1);
		p.rotation = rnd(0,360);
		p.dy = p.dx*0.5;
		p.life = 999999;
		p.onUpdate = function() {
			if( p.x>man.buffer.width )
				p.life = 0;
		}
		p.filters = [ new  flash.filters.BlurFilter(2,2) ];
		p.onUpdate = function() {
			mc.y = Math.sin(man.time*0.04) * 10;
		}
		register(p, BlendMode.NORMAL);
	}
	
	public function projHit(pr:Projectile) {
		init();
		hit(pr.x, pr.y);
		var p = new Particle(pr.x, pr.y);
		p.reset();
		p.graphics.copyFrom(pr.graphics);
		p.dr = -rnd(20,25);
		p.dx = -rnd(1.5, 2);
		p.dy = -rnd(5,6);
		p.gy = 0.6;
		p.life = 8;
		p.filters = pr.filters;
		register(p, BlendMode.NORMAL);
		return p;
	}
	
	public function fadeIn(col:Int, duration:Float) {
		if( man.cm.turbo )
			return;
		var spr = new Sprite();
		man.dm.add(spr, Const.DP_INTERF);
		spr.graphics.beginFill(col, 1);
		spr.graphics.drawRect(0,0,Const.WID, Const.HEI);
		man.tw.create(spr, "alpha", 0, TEase, duration).onEnd = function() {
			spr.parent.removeChild(spr);
		}
	}
	
	
	public function fadeOut(col:Int, duration:Float) {
		if( man.cm.turbo )
			return;
		var spr = new Sprite();
		man.dm.add(spr, Const.DP_INTERF);
		spr.graphics.beginFill(col, 1);
		spr.graphics.drawRect(0,0,Const.WID, Const.HEI);
		spr.alpha = 0;
		man.tw.create(spr, "alpha", 1, TEase, duration);
	}
	
	public function crossFade(col:Int, fadeDuration:Float, gapDuration:Float) {
		if( man.cm.turbo )
			return;
		var spr = new Sprite();
		man.dm.add(spr, Const.DP_INTERF);
		spr.graphics.beginFill(col, 1);
		spr.graphics.drawRect(0,0,Const.WID, Const.HEI);
		spr.alpha = 0;
		man.tw.create(spr, "alpha", 1, TEase, fadeDuration);
		man.delayer.add(function() {
			man.tw.create(spr, "alpha", 0, TEase, fadeDuration).onEnd = function() {
				spr.parent.removeChild(spr);
			}
		}, gapDuration+fadeDuration);
	}
	
	public function flashBang(alpha:Float, duration:Float) {
		if( man.cm.turbo || man.fps<20 )
			return;
		var spr = man.flashBang;
		if( spr.visible && spr.alpha>alpha )
			return;
		man.tw.terminate(spr);
		spr.visible = true;
		spr.alpha = alpha;
		man.tw.create(spr, "alpha", 0, TEaseIn, duration).onEnd = function() {
			spr.visible = false;
		}
	}
	
	public function palmLight(t:iso.Teacher, ?c=0xFFAE40, ?lines=4, ?dots=8) {
		init();
		
		var pt = t.getHead();
		pt.x+=16;
		pt.y+=-8+3;
		var p = new Particle(pt.x, pt.y);
		p.reset();
		var s = man.tiles.getSprite("hit",1);
		s.setCenter(0.5, 0.5);
		p.addChild(s);
		p.rotation = rnd(0,360);
		p.scaleX = p.scaleY = rnd(1.6, 2);
		p.ds = -0.15;
		p.life = 4;
		p.filters = [
			new flash.filters.GlowFilter(c, 1, 8,8,2),
		];
		register(p);
		
		// Points
		for(i in 0...dots) {
			var p = new Particle(pt.x+rnd(0,3,true), pt.y+rnd(0,3,true));
			var a = rnd(0,6.28);
			p.reset();
			p.drawBox(3,1, c, rnd(0.5,1));
			p.rotation = deg(a);
			var s = rnd(1,2);
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s;
			p.frictX = p.frictY = 0.9;
			p.life = rnd(2,10);
			p.filters = [ new flash.filters.GlowFilter(c,1, 4,4,2) ];
			register(p);
		}
		
		// Lignes
		for(i in 0...lines) {
			var p = new Particle(pt.x+rnd(0,3,true), pt.y+rnd(0,3,true));
			var a = rnd(0,6.28);
			p.reset();
			p.drawBox(rnd(3,6), 1, c, rnd(0.5,1));
			p.rotation = deg(a);
			p.dx = rnd(2,4);
			p.dy = -p.dx*0.5;
			p.rotation = -33;
			p.frictX = p.frictY = 0.9;
			p.life = rnd(2,10);
			p.filters = [ new flash.filters.GlowFilter(c,1, 4,4,2) ];
			register(p);
		}
	}
	
	public function multiHits(i:Iso, n:Int, ?color=0xFFAC00) {
		init();
		var pt = i.getHead();
		for(i in 0...n) {
			var p = new Particle(pt.x + rnd(0,6,true), pt.y+rnd(0,9,true));
			p.reset();
			var s = man.tiles.getSprite("hit",1);
			s.setCenter(0.5,0.5);
			p.addChild( s );
			p.rotation = rnd(0,360);
			p.life = 0;
			p.ds = -0.04;
			p.dr = rnd(0,2);
			p.scaleX = p.scaleY = rnd(0.5, 1.1);
			p.delay = i*3 + rnd(0,2);
			p.onStart = function() {
				flashBang(rnd(0.05,0.10), rnd(100,200));
			}
			p.filters = [
				new flash.filters.GlowFilter(color, 0.7, 4,4,2),
			];
			register(p);
		}
	}
	
	public function chargeBall(x,y, frames:Int, ?color=0xFFAC00, ?scale=1.0) {
		init();
		for(i in 0...4) {
			var large = i<=1;
			var p = new Particle(x,y);
			p.reset();
			var s = man.tiles.getSprite("hit",1);
			s.setCenter(0.5,0.5);
			p.addChild( s );
			p.rotation = rnd(0,360);
			p.scaleX = p.scaleY = scale * (large ? 1.3 : rnd(0.6, 0.8));
			p.alpha = large ? 0.15 : rnd(0.5,0.7);
			p.dr = rnd(2,9, true);
			p.ds = large ? 0.01 : -0.01;
			p.life = frames;
			p.filters = [
				new flash.filters.GlowFilter(color,1, 4,4,1),
			];
			register(p);
		}
	}
	
	public function slices(i:Iso, n:Int, ?color=0xFFAC00) {
		init();
		var pt = i.getHead();
		var a = rnd(0, 6.28);
		for(i in 0...n) {
			var p = new Particle(pt.x + rnd(0,2,true), pt.y+rnd(0,4,true)+3);
			p.reset();
			
			var s = man.tiles.getSprite("hit",0);
			s.setCenter(0.5,0.5);
			p.addChild( s );
			
			p.alpha = rnd(0.7, 1);
			p.rotation = deg(a);
			p.life = 0;
			p.ds = -0.04;
			p.dr = rnd(0,2);
			p.delay = i*1.5 + rnd(0,1.5);
			p.scaleX = p.scaleY = rnd(0.8, 2);
			p.dx = Math.cos(a+1.6)*1;
			p.dy = Math.sin(a+1.6)*1;
			//p.scaleX*=-1;
			p.onStart = function() {
				flashBang(rnd(0.05,0.10), rnd(100,200));
			}
			p.filters = [
				new flash.filters.GlowFilter(color, 1, 8,8,3),
			];
			a+=rnd(0.5, 2);
			register(p);
		}
	}
	
	public function bombParts(x,y) {
		init();
		var p = new Particle(x+rnd(0,1,true), y+rnd(0,1,true));
		p.drawBox(1,1, 0xFFFF80, rnd(0.4,0.8));
		p.dx = rnd(0,0.5,true);
		p.dy = rnd(0,0.5,true);
		p.frictX = p.frictY = 0.95;
		p.life = rnd(5,15);
		register(p);
	}
	
	public function bomb(x,y) {
		init();
		for(i in 0...10) {
			var p = new Particle(x + rnd(0,3,true), y+rnd(0,3,true));
			p.drawCircle(rnd(2,4),0xFFFFFF);
			p.dx = rnd(1, 8, true);
			p.dy = rnd(1, 8, true);
			p.frictX = p.frictY = rnd(0.80, 0.90);
			p.life = rnd(5,20);
			p.ds = -0.01;
			p.filters = [ new flash.filters.GlowFilter(0xFFAC00, 1, 4,4, 3) ];
			register(p);
		}
		for(i in 0...6) {
			var p = new Particle(x + rnd(0,3,true), y+rnd(0,3,true));
			p.drawCircle(rnd(5,10),0xFFFFFF);
			p.dx = rnd(0.5, 2, true);
			p.dy = rnd(0.5, 2, true);
			p.frictX = p.frictY = 0.9;
			p.life = rnd(10,20);
			p.ds = -0.02;
			p.filters = [ new flash.filters.GlowFilter(0xFFAC00, 1, 8,8, 3) ];
			register(p);
		}
	}
	
	
	public function lightning(ifrom:Iso, ito:Iso, ?col=0x00BFFF) {
		init();
		var from = ifrom.getHead();
		var to = {x:ito.sprite.x, y:ito.sprite.y}
		var d = Lib.distance(from.x, from.y, to.x, to.y);
		var a = Math.atan2(to.y-from.y, to.x-from.x);
		var n = 7;
		for(sub in 0...5) {
			var p = new Particle(from.x, from.y);
			p.graphics.moveTo(0,0);
			p.graphics.lineStyle(1, 0xFFFFFF, 1);
			for(i in 0...n) {
				var x = Math.cos(a) * (d * (i+1)/n);
				var y = Math.sin(a) * (d * (i+1)/n);
				p.graphics.lineTo(x+rnd(1,5,true), y+rnd(1,5,true));
			}
			p.filters = [ new flash.filters.GlowFilter(col, 1, 8,16, 4) ];
			p.life = rnd(2,4);
			p.delay = sub*2;
			register(p);
		}
	}
	
	
	public function changeFurnColor(iso:Iso) {
		for(i in 0...10) {
			var d = rnd(0,30);
			var p = new Particle(iso.sprite.x+iso.furnMc.x + d, iso.sprite.y+iso.furnMc.y + d*0.5 + rnd(0,5,true));
			p.drawBox(1,1, 0x00FFFF, 1);
			p.dy = -rnd(0.5, 2);
			p.frictY = 0.94;
			p.life = rnd(5,15);
			p.filters = [ new flash.filters.GlowFilter(0x119BEE,0.8, 8,8,8) ];
			register(p);
		}
	}
	
	
	public function highlightSeat(cx,cy) {
		var n = 17;
		var pt = Iso.isoToScreenStatic(cx,cy+1);
		for(i in 0...n) {
			var a = rnd(0, 6.28);
			var d = rnd(3,10);
			var p = new Particle(pt.x+Math.cos(a)*d+5, pt.y+Math.sin(a)*d*0.5 + 15);
			p.drawBox(1, 1, 0x00FFFF, rnd(0.5, 0.7));
			p.gy = -rnd(0.01, 0.02);
			p.frictX = p.frictY = 0.92;
			p.alpha = 0;
			p.da = 0.1;
			p.delay = 30 * i/(n-1);
			p.life = rnd(15,20);
			p.filters = [ new flash.filters.GlowFilter(0x00FFFF,0.8, 4,4,2) ];
			register(p);
		}
	}
	
	public function streetSnow() {
		for( i in 0...3) {
			var w = irnd(1,2);
			var pt = Iso.isoToScreenStatic(Const.RWID+irnd(0,6), rnd(0,Const.RHEI));
			var p = new Particle(pt.x+rnd(0,5,true), pt.y+rnd(0,5,true));
			p.drawBox(w,w, 0xE4ECEF, 1);
			p.dx = -rnd(0, 0.1);
			p.dy = rnd(0.2, 0.3);
			p.frictX = rnd(0.85, 0.95);
			p.frictY = rnd(0.85, 0.95);
			p.gx = -rnd(0,0.15);
			p.gy = rnd(0.1,0.15);
			p.alpha = 0;
			p.da = 0.1;
			p.life = rnd(5, 45);
			register(p, NORMAL);
		}
	}
	
	
	public inline function update() {
		Particle.LIMIT = Const.LOWQ ? 40 : 130;
		Particle.update();
	}
}





