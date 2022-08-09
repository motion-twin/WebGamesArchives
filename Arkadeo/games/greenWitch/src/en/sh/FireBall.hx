package en.sh;

import mt.deepnight.Lib;
import mt.deepnight.retro.SpriteLibBitmap;

class FireBall extends en.Shoot {
	public var color		: Int;
	var subs				: Array<BSprite>;
	var halo				: Null<flash.display.Bitmap>;
	var ignoreWall			: Bool;
	
	public function new(x,y, tx:Float,ty:Float) {
		super(x,y);
		
		speed *= 0.2;
		ignoreWall = true;
		
		color = 0xFF0000;
		fx.energyHit(xx, yy, color);
		zpriority = 999;
		
		cd.set("duration", 150);
		
		var a = Math.atan2(ty-yy, tx-xx);
		dx = Math.cos(a)*speed;
		dy = Math.sin(a)*speed;
		//sprite.rotation = Lib.deg(a);
		
		var ct = new flash.geom.ColorTransform();
		ct.color = 0xFFFFFF;
		
		var lowq = api.AKApi.isLowQuality() || perf<0.8;
		subs = new Array();
		for(i in 0...(lowq ? 1 : 3)) {
			var s = game.char.getRandom("dirt", Std.random);
			sprite.addChild(s);
			s.setCenter(0.5,0.5);
			s.scaleX = s.scaleY = 0.8;
			s.alpha = 0.7;
			s.y = -10;
			s.transform.colorTransform = ct;
			subs.push(s);
		}
		
		if( !lowq ) {
			var s = new flash.display.Sprite();
			s.graphics.beginFill(0xFFFFFF, 1);
			s.graphics.drawCircle(0,0, 20);
			s.scaleY = 0.6;
			s.filters = [ new flash.filters.BlurFilter(16,16) ];
			halo = Lib.flatten(s, 8, true);
			halo.blendMode = flash.display.BlendMode.OVERLAY;
			game.sdm.add(halo, Const.DP_BG_FX);
		}
		
		//s2 = game.char.getRandom("dirt", Std.random);
		//sprite.addChild(s2);
		//s2.setCenter(0.5,0.5);
		//s2.transform.colorTransform = ct;
		//bmp = new flash.display.Bitmap( new flash.display.BitmapData(30,30, true, 0x0) );
		//for(i in 0...5) {
			//game.char.drawIntoBitmap(bmp.bitmapData, bmp.width*0.5, bmp.height*0.5, "dirt", 0, 0.5,0.5);
		//}
		//sprite.addChild(bmp);
		
		//sprite.graphics.lineStyle(7, color, 0.3);
		//sprite.graphics.beginFill(0xFFFFFF,1);
		//sprite.graphics.drawCircle(0, 0, 10);
		if( lowq )
			sprite.filters = [
				new flash.filters.GlowFilter(0xFF9300,1, 8,8,3),
			];
		else
			sprite.filters = [
				new flash.filters.GlowFilter(0xFFC600,1, 8,8,2),
				new flash.filters.GlowFilter(0xFF4000,1, 8,8,2),
			];
		//sprite.graphics.drawCircle(-5, 0, 2);
		sprite.blendMode = flash.display.BlendMode.ADD;
	}
	
	override function onTimeOut() {
		super.onTimeOut();
		fx.fireBallExplosion(xx,yy-8);
	}
	override function detach() {
		super.detach();
		for(s in subs)
			s.destroy();
		if( halo!=null ) {
			halo.parent.removeChild(halo);
			halo.bitmapData.dispose();
		}
	}
	
	public override function update() {
		super.update();
		
		if( !getCollision(cx,cy) )
			ignoreWall = false;
			
		var low = api.AKApi.isLowQuality();
		var i = 0;
		for(s in subs) {
			if( !low )
				s.rotation+= (3+i*2) * (i%2==0 ? -1 : 1);
			s.scaleX = s.scaleY = Lib.rnd(0.9, 1.1);
			i++;
		}
		//sprite.scaleX = sprite.scaleY = Lib.rnd(0.95, 1.05);
		if( halo!=null ) {
			halo.x = xx-halo.width*0.5;
			halo.y = yy-halo.height*0.5;
		}
		
		if( getCollision(cx,cy) && !ignoreWall ) {
			fx.fireBallExplosion(xx,yy-8);
			destroy();
			return;
		}
		
		for(e in game.getAllies())
			if( e.canBeHit() && distance(e)<18 ) {
				e.hit(3);
				fx.fireBallExplosion(xx,yy-8);
				destroy();
				break;
			}
	}
}
