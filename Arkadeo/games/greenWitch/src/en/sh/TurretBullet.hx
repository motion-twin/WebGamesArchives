package en.sh;

import mt.deepnight.Lib;

class TurretBullet extends en.Shoot {
	public var color		: Int;
	
	public function new(x,y, e:Entity) {
		super(x,y);
		
		speed *= 1.2;
		
		color = 0xFFC600;
		fx.energyHit(xx, yy, color);
		
		var a = Math.atan2(e.yy-yy, e.xx-xx);
		dx = Math.cos(a)*speed;
		dy = Math.sin(a)*speed;
		sprite.rotation = Lib.deg(a);
		
		sprite.graphics.lineStyle(7, color, 0.3);
		sprite.graphics.beginFill(color,1);
		sprite.graphics.drawCircle(0, 0, 3);
		sprite.graphics.drawCircle(-5, 0, 2);
		sprite.blendMode = flash.display.BlendMode.ADD;
		S.BANK.lazer02().play( Lib.rnd(0.03, 0.07) );
	}
	
	public override function update() {
		super.update();
		
		for(e in getPropsInRange(18))
			if( e.canBeHit() ) {
				e.hit(1);
				fx.hit(xx,yy, color);
				destroy();
				break;
			}
			
		for(e in getMobsInRange(18))
			if( e.canBeHit() ) {
				e.hit(1);
				fx.hit(xx,yy, color);
				destroy();
				break;
			}
	}
}