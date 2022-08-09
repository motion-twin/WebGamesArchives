package en.sh;

import mt.deepnight.Lib;

class Lazer extends en.Shoot {
	public var color		: Int;
	var slife				: Int;
	
	public function new(x,y, a:Float, col:Int, big:Bool) {
		super(x,y);
		
		slife = 4;
		color = col;
		
		dx = Math.cos(a)*speed*2;
		dy = Math.sin(a)*speed*2;
		sprite.rotation = Lib.deg(a);
		
		fx.energyHit(xx, yy, color);
		
		sprite.graphics.lineStyle(big ? 4 : 2, 0xFFFFFF, 1);
		sprite.graphics.moveTo(-10,0);
		sprite.graphics.lineTo(10,0);
		sprite.blendMode = flash.display.BlendMode.ADD;
		if( big )
			sprite.filters = [ new flash.filters.GlowFilter(color, 0.7, 8,8,4) ];
		else
			sprite.filters = [ new flash.filters.GlowFilter(color, 0.7, 4,4,4) ];
			
		S.BANK.lazer01().play(0.13);
		S.BANK.lazer03().play( Lib.rnd(0.05, 0.1) );
	}
	
	public override function update() {
		super.update();
		if( getCollision(cx,cy) )
			slife--;
		if( slife<=0 ) {
			fx.energyHit(xx,yy, color);
			destroy();
		}
		
		for(e in getMobsInRange(12))
			if( e.canBeHit() && !e.cd.has("lazer_"+uid) ) {
				e.hit(2);
				e.cd.set("lazer_"+uid, 10);
				fx.hit(xx,yy, color);
			}
	}
}