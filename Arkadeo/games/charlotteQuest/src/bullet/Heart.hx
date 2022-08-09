package bullet;

import flash.display.Bitmap;
import flash.display.BitmapData;

class Heart extends Bullet {
	static var CACHE : IntHash<{bd:BitmapData, cox:Float, coy:Float}> = new IntHash();
	
	var bmp			: flash.display.Bitmap;
	public function new(ang:Float, r:Float, level:Int) {
		super();
		
		var powerScale = level/8;
		
		power = 1 + powerScale*5;
		trailWid = if( level==0 ) 0 else 1;
		
		hitPlayer = false;
		radius = 15;
		color = 0xFF80FF;
		copyPos(game.player);
		//xr+=0.9;
		//yr-=0.15;
		xr+= Math.cos(ang)*0.8;
		yr+= Math.sin(ang)*0.4;
		//var spd = 0.40 + 0.15*powerScale;
		var spd = 0.50;
		dx = Math.cos(ang)*spd;
		dy = Math.sin(ang)*spd;
		
		range = r;
		
		var cacheId = Std.int(powerScale*100);
		
		//trace("l="+level+" ps="+powerScale);
		if( CACHE.exists(cacheId) ) {
			var c = CACHE.get(cacheId);
			bmp = new Bitmap( c.bd, flash.display.PixelSnapping.NEVER, false );
			bmp.x = c.cox;
			bmp.y = c.coy;
		}
		else {
			var mc = new lib.Shoot();
			mc.gotoAndStop( 1+level );
			var padding =
				if( level<3 ) 2
				else if( level<=5 ) 8
				else if( level<=7 ) 12
				else 8;
			bmp = mt.deepnight.Lib.flatten(mc, padding, true);
			CACHE.set(cacheId, {
				bd	: bmp.bitmapData,
				cox	: bmp.x,
				coy	: bmp.y,
			});
		}
		
		spr.addChild(bmp);
		spr.blendMode = flash.display.BlendMode.ADD;
		
		//updatePos();
		//var pt = getScreenPoint();
		//fx.shootStart(pt.x, pt.y, color);
	}
	
	public static inline function clearCache() {
		CACHE = new IntHash();
	}
	
	//public override function destroy() {
		//super.destroy();
		//if( deleted )
			//return;
		//bmp.bitmapData.dispose();
	//}
}
