package bullet;

class Bad extends Bullet {
	var cache			: flash.display.Bitmap;
	
	public function new(e:Enemy, ?col=0xFFBF00) {
		super();
		
		range = 300;
		radius = 5;
		setPos(e.cx, e.cy, e.xr, e.yr);
		color = col;
		speed = 0.15;
		
		var s = new flash.display.Sprite();
		// Halo
		s.graphics.beginFill(color, 0.2);
		s.graphics.drawCircle(0, 0, radius*2);
		
		// Coeur
		s.graphics.beginFill(mt.deepnight.Color.lighten(color, 0.5), 1);
		s.graphics.lineStyle(1, color, 1, flash.display.LineScaleMode.NONE);
		s.graphics.drawCircle(0, 0, radius);
		s.filters = [
			new flash.filters.GlowFilter(color, 0.3, 4,4, 8, 2),
			new flash.filters.GlowFilter(color, 0.6, 16,16, 1, 2),
		];
		
		cache = mt.deepnight.Lib.flatten(s, 16);
		spr.addChild(cache);
		//spr.blendMode = flash.display.BlendMode.ADD;
	}
	
	public function toPlayer(?spd:Float) {
		if( spd!=null )
			speed = spd;
		var a = getAngleTo(game.player);
		dx = Math.cos(a)*speed;
		dy = Math.sin(a)*speed;
	}
	
	public override function destroy() {
		super.destroy();
		if( deleted )
			return;
		cache.bitmapData.dispose();
	}
	
	public override function update() {
		if( game.perf>=0.8 ) {
			spr.scaleX = spr.scaleY = rnd(0.9, 1.1);
			spr.alpha = rnd(0.5, 1);
		}
		super.update();
	}
}
