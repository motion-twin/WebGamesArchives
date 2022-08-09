import flash.display.BlendMode;
import flash.display.Sprite;
import flash.display.MovieClip;
import mt.deepnight.Particle;
import mt.deepnight.Color;

class Fx {
	var game		: Game;
	var anims		: Array<MovieClip>;
	public function new() {
		game = Game.ME;
		anims = new Array();
	}
	
	inline function register(p:Particle, ?b:BlendMode, ?inScrolling=true) {
		if( inScrolling )
			game.sdm.add(p, Game.DP_FX);
		else
			game.dm.add(p, game.shopping ? Game.DP_INTERF : Game.DP_FX);
		p.blendMode = b==null ? BlendMode.ADD : b;

		//if( game.perf<=0.35 )
			//p.destroy();
	}
	
	inline function rnd(min,max,?sign=false) { return mt.deepnight.Lib.rnd(min,max,sign); }
	inline function irnd(min,max,?sign=false) { return mt.deepnight.Lib.irnd(min,max,sign); }
	inline function deg(a) { return mt.deepnight.Lib.deg(a); }
	inline function rad(a) { return mt.deepnight.Lib.rad(a); }
	

	public function tinyDrops(x,y,col) { // moustique
		if( game.perf<=0.7 )
			return;
		for(i in 0...8) {
			var p = new Particle(x+rnd(0,2,true), y+rnd(0,4,true));
			p.reset();
			p.drawBox(1,1, col);
			
			p.gy = rnd(0.1, 0.7);
			var s = rnd(1,2);
			p.life = rnd(8,16);
			p.frictX = p.frictY = 0.93;
			
			p.pixel = true;
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function popDots(cx,cy,col) {
		if( game.perf<=0.7 )
			return;
		var n = game.perf>=0.85 ? 9 : 5;
		var base = rnd(0, 6.28);
		for(i in 0...n) {
			var a = base + 6.28 * i/n;
			var d = rnd(5,6);
			var x = cx + Math.cos(a)*d;
			var y = cy + Math.sin(a)*d;
			var p = new Particle(x,y);
			p.reset();
			p.drawBox(2,1, col);
			
			p.rotation = deg(a);
			p.dx = Math.cos(a)*4;
			p.dy = Math.sin(a)*4;
			p.life = 24 + i*2;
			p.frictX = p.frictY = 0.85;
			
			p.filters = [ new flash.filters.GlowFilter(col, 0.7, 8,8, 6) ];
			p.pixel = true;
			register(p);
		}
	}
	
	public function popCircle(e:Entity) {
		var pt = e.getPoint();
		var p = new Particle(pt);
		p.reset();
		p.graphics.lineStyle(1, e.color, 0.5);
		p.graphics.drawCircle(0,0, e.radius+3);
		p.life = rnd(0,3);
		p.ds = 0.03;
		register(p);
	}
	
	public function uber() {
		var e = game.player;
		var pt = e.getPoint();
		var n = game.perf>=0.7 ? 5 : 1;
		for(i in 0...n) {
			var color = Color.randomColor( rnd(0,1), 0.4, 1 );
			var p = new Particle(pt.x+rnd(0,20,true), pt.y+rnd(0,35,true));
			p.drawBox(2,2, color, rnd(0.5, 1) );
			p.reset();
			p.dx = -e.dx*4;
			p.dy = -e.dy*4;
			//p.rotation = deg(Math.atan2(p.dy,p.dx));
			p.frictX = 0.92;
			p.frictY = 0.97;
			p.alpha = 0;
			p.da = 0.1;
			p.gx = rnd(0, 0.2,true);
			p.gy = rnd(0, 0.1, true);
			p.life = rnd(0,32);
			p.filters = [
				new flash.filters.GlowFilter(color, 0.7, 8,8,5),
			];
			register(p);
		}
	}
	
	public function hit(x,y,col) {
		for(i in 0...3) {
			var p = new Particle(x+rnd(0,3,true), y+rnd(0,3,true));
			p.reset();
			p.graphics.lineStyle(1, col, 1);
			p.graphics.drawCircle(0,0, rnd(3,8));
			p.life = rnd(2,6);
			p.ds = 0.02;
			p.filters = [ new flash.filters.GlowFilter(col, 0.5, 16,16, 2) ];
			register(p);
		}
	}
	
	public function shootStart(x,y,col) {
		if( game.perf<0.9 )
			return;
		var p = new Particle(x+rnd(0,2,true), y+rnd(0,2,true));
		p.reset();
		p.graphics.lineStyle(1, col, rnd(0.4, 0.6));
		p.graphics.drawCircle(0,0, rnd(2,5));
		p.life = rnd(0,3);
		p.ds = 0.02;
		p.filters = [ new flash.filters.GlowFilter(col, 0.5, 16,16, 2) ];
		register(p, false);
	}
	
	public function bigHit(e:Entity) {
		//var col = e.color;
		var col = 0xF06CF0;
		
		var pt = e.getPoint();
		var p = new Particle(pt.x, pt.y);
		p.reset();
		p.graphics.beginFill(col, 0.3);
		p.graphics.drawCircle(0,0, e.radius*0.7);
		p.life = 3;
		//p.ds = -0.02;
		register(p, BlendMode.ADD);
		
		var p = new Particle(pt.x, pt.y);
		p.reset();
		p.graphics.lineStyle(1, col, 1, flash.display.LineScaleMode.NONE);
		p.graphics.drawCircle(0,0, e.radius*rnd(0.7,0.9));
		p.graphics.drawCircle(0,0, e.radius);
		p.life = 3;
		p.ds = 0.12;
		p.filters = [ new flash.filters.GlowFilter(col, 1, 8,8, 3) ];
		register(p, BlendMode.ADD);
	}
	
	public function anim( mc:MovieClip, x,y) {
		mc.x = x;
		mc.y = y;
		mc.rotation = rnd(0,360);
		game.sdm.add(mc, Game.DP_FX);
		mc.gotoAndStop(1);
		anims.push(mc);
		return mc;
	}
	
	public function cadaver() {
		var mc = new lib.Dead();
		var pt = game.player.getPoint();
		var p = new Particle(pt.x, pt.y);
		p.addChild(mc);
		p.dr = rnd(2,5,true);
		p.dx = rnd(1,2,true);
		p.dr = (p.dx<0 ? -1 : 1) * 5;
		p.dy = -rnd(6,7);
		p.frictX = 1;
		p.gy = 0.4;
		p.scaleX = p.scaleY = 0.8;
		p.life = 100;
		p.flatten();
		register(p, BlendMode.NORMAL);
	}
	
	public function buyItem(cont:flash.display.DisplayObjectContainer, icon:flash.display.DisplayObject, x:Float,y:Float, w:Float,h:Float) {
		icon.alpha = 0;
		Game.TW.create(icon, "alpha", 1, 1500);
		
		var p = new Particle(x,y);
		p.reset();
		p.delay = 12;
		p.graphics.beginFill(0xffffff, 1);
		p.graphics.drawCircle(0,0,50);
		p.scaleX = p.scaleY = 0.1;
		p.ds = 0.12;
		p.life = 1;
		p.blendMode = BlendMode.OVERLAY;
		//p.flatten();
		cont.addChild(p);
		
		var n = game.perf<=0.7 ? 0 : 10;
		for(i in 0...n) {
			//var p = new Particle(x + w - w*i/n, y + rnd(0,h));
			var a = rnd(0, 6.28);
			var d = rnd(30,60);
			var p = new Particle(x+Math.cos(a)*d, y+Math.sin(a)*d);
			p.reset();
			p.drawBox(rnd(2,3), rnd(2,3), 0xFFFFB7, rnd(0.2, 0.7));
			p.delay = 16 * i/n;
			var s = rnd(0.10, 0.20);
			p.dx = -Math.cos(a)*d*s;
			p.dy = -Math.sin(a)*d*s;
			p.frictX = p.frictY = 0.95;
			//p.dy = -rnd(0,1);
			//p.ds = 0.05;
			p.life = 16;
			//p.gy = -0.02;
			p.filters = [
				new flash.filters.GlowFilter(0xFFB300,1, 16,16,3),
			];
			p.blendMode = BlendMode.ADD;
			p.flatten(16);
			cont.addChild(p);
		}
	}
	
	public function pickCoin(e:it.Coin) {
		if( game.perf<0.8 )
			return;
		var pt = e.getScreenPoint();
		var t = { x:game.player.moneyCounter.wrapper.x+40, y:game.player.moneyCounter.wrapper.y }
		
		var p = new Particle(pt.x, pt.y);
		p.reset();
		
		var bmp = mt.deepnight.Lib.flatten(e.spr);
		bmp.alpha = 0.3;
		p.addChild( bmp );
		
		var a = Math.atan2(t.y-pt.y, t.x-pt.x);
		var s = 25;
		p.scaleX = p.scaleY = e.spr.scaleX;
		p.dx = Math.cos(a)*s;
		p.dy = Math.sin(a)*s;
		p.onUpdate = function() {
			if( mt.deepnight.Lib.abs(t.x-p.x)<s*2 && mt.deepnight.Lib.abs(t.y-p.y)<s*2 )
				p.destroy();
		}
		p.onKill = function() {
			bmp.bitmapData.dispose();
		}
		p.life = 30;
		
		register(p, false);
	}
	
	public function splash(from:Entity, to:Entity) {
		if( game.perf<0.7 )
			return;
		var pt = to.getPoint();
		var x = pt.x+5;
		var y = pt.y+5;
		var col = 0xC66FD2;
		var col = 0x8A2F97;
		var r = game.getRoomAt(x,y);
		if( r==null || !r.ready )
			return;
		
		var wrapper = new Sprite();
		wrapper.filters = [
			new flash.filters.BlurFilter(2,2),
			new flash.filters.DropShadowFilter(6,90, 0xffffff,0.2, 2,2, 1, 1,true),
			new flash.filters.DropShadowFilter(3,90, col,1, 0,0, 1, 1,true),
			new flash.filters.DropShadowFilter(2,90, 0x0,0.3, 4,4, 1),
		];
		
		var ct = new flash.geom.ColorTransform();
		ct.color = col;
			
		for( i in 0...irnd(1,2) ) {
			var mc = new lib.Splash1();
			wrapper.addChild(mc);
			mc.gotoAndStop( Std.random(mc.totalFrames)+1 );
			mc.rotation = rnd(0,360);
			mc.scaleX = mc.scaleY = rnd(4,5);
			mc.transform.colorTransform = ct;
		}
		
		//if( from!=to ) {
			//var mc = new lib.Splash2();
			//wrapper.addChild(mc);
			//mc.gotoAndStop( Std.random(mc.totalFrames)+1 );
			//mc.rotation = deg( from.getAngleTo(to) );
			//mc.scaleX = mc.scaleY = rnd(2,3);
			//mc.transform.colorTransform = ct;
		//}
		
		wrapper.alpha = 0.5;
		var b = wrapper.getBounds(wrapper);
		var cox = (b.left + b.width*0.5);
		var coy = (b.top + b.height*0.5);
		var q = flash.Lib.current.stage.quality;
		flash.Lib.current.stage.quality = flash.display.StageQuality.LOW;
		var bmp = mt.deepnight.Lib.flatten(wrapper);
		flash.Lib.current.stage.quality = q;
		var pt = new flash.geom.Point(x-bmp.width*0.5-r.cx*Room.CWID*Room.GRID, y-bmp.height*0.5-r.cy*Room.CHEI*Room.GRID);
		pt.x+=cox;
		pt.y+=coy;
		r.splashes.bitmapData.copyPixels(bmp.bitmapData, bmp.bitmapData.rect, pt, r.bg.bitmapData, pt, true);
		
		bmp.bitmapData.dispose();
	}
	
	public function playerSpawn() {
		var player = game.player;
		var pt = player.getPoint();
		player.spr.alpha = 0;
		Game.TW.create(player.spr, "alpha", 1, 800);

		var mc = anim( new lib.Puf(), pt.x, pt.y );
		var ct = new flash.geom.ColorTransform();
		ct.color = 0x392646;
		mc.transform.colorTransform = ct;
		mc.rotation = rnd(0,360);
		mc.scaleX = mc.scaleY = 1.3;
		//mc.blendMode = flash.display.BlendMode.ADD;
		
		var n = 15;
		for(i in 0...n) {
			var a = rnd(0, 6.28);
			var d = rnd(50,100);
			var p = new Particle(pt.x+Math.cos(a)*d, pt.y+Math.sin(a)*d);
			p.reset();
			p.drawBox(rnd(2,5), 2, 0x0, rnd(0.5, 1));
			
			p.rotation = deg(a);
			var s = rnd(0.09, 0.13);
			p.dx = -Math.cos(a)*d*s;
			p.dy = -Math.sin(a)*d*s;
			p.frictX = p.frictY = 0.92;
			p.alpha = 0.5;
			p.da = 0.3;
			p.life = 16;
			p.delay = i*0.2;
			p.filters = [
				new flash.filters.GlowFilter(0x0,0.7, 12,12,3),
			];
			p.flatten(16);
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function playerDeath() {
		var e = game.player;
		e.mc.visible = false;
		var pt = e.getScreenPoint();
		pt.x+=10;
		if( pt.x<0 ) pt.x = -10;
		if( pt.x>=Game.WID ) pt.x = Game.WID+10;
		if( pt.y<0 ) pt.y = -10;
		if( pt.y>=Game.HEI ) pt.y = Game.HEI+10;
		
		var p = new Particle(pt.x,pt.y);
		p.reset();
		//p.delay = 12;
		p.graphics.beginFill(0xD27AE9, 0.5);
		p.graphics.drawCircle(0,0,50);
		p.scaleX = p.scaleY = 2;
		p.ds -= 0.2;
		p.life = 1;
		//p.blendMode = BlendMode.OVERLAY;
		register(p, false);
		
		for(i in 0...50) {
			var p = new Particle(pt.x+rnd(0,10,true), pt.y+rnd(0,10,true));
			p.drawBox( rnd(3,6), rnd(3,6), Std.random(100)<30 ? 0xFF8040 : 0xD55BFD );
			p.reset();
			var a = rnd(0, 6.28);
			var s = rnd(5,10);
			p.rotation = deg(a);
			p.frictX = 0.96;
			p.frictY = 0.94;
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s;
			p.dr = rnd(10,30);
			p.gy = 0.1;
			p.delay = rnd(0,8);
			p.life = rnd(15,70);
			p.filters = [
				new flash.filters.DropShadowFilter(2,-90, 0x0,0.4, 2,2,1, 1,true),
				new flash.filters.GlowFilter(0x0, 0.3, 2,2,3),
			];
			p.flatten(2);
			register(p, BlendMode.NORMAL, false);
		}
		
		cadaver();
	}
	public function explodeLight(e:Entity, col:Int) {
		if( game.perf<=0.7 )
			return;
		var pt = e.getPoint();
		for(i in 0...15) {
			var p = new Particle(pt.x+rnd(0,10,true), pt.y+rnd(0,10,true));
			p.reset();
			p.drawBox(rnd(2,8),2, col);
			var a = rnd(0, 6.28);
			var s = rnd(9,15);
			p.rotation = deg(a);
			p.frictX = p.frictY = 0.90;
			p.dx = Math.cos(a)*s;
			p.dy = Math.sin(a)*s;
			p.life = rnd(5,20);
			//p.gy = 0.2;
			p.filters = [ new flash.filters.GlowFilter(col, 0.7, 8,8, 2) ];
			//p.onUpdate = function() {
				//p.rotation = deg( Math.atan2(p.dy, p.dx) );
			//}
			register(p);
		}
	}
	
	public function update() {
		mt.deepnight.Particle.update();
		
		var i = 0;
		while( i<anims.length ) {
			if( anims[i].currentFrame==anims[i].totalFrames ) {
				anims[i].parent.removeChild(anims[i]);
				anims.splice(i,1);
			}
			else {
				anims[i].nextFrame();
				i++;
			}
		}
	}
}