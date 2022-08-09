package en;

import mt.deepnight.Lib;

class Grenade extends Entity {
	public function new(tx:Float,ty:Float) {
		super();
		
		#if debug
		fx.marker(tx,ty);
		#end
		
		frict = 1;
		collides = false;
		weight = 0;
		speed = 0.15;
		wallBounce = 0.5;
		
		xx = game.hero.xx;
		yy = game.hero.yy;
		updateFromScreenCoords();

		sprite.swap("grenade");
		sprite.playAnim("throw");
		sprite.setCenter(0.5,0.5);
		
		setShadow(true);
		
		var d = Lib.distance(xx,yy,tx,ty);
		
		speed = d/500;
		var a = Math.atan2(ty-yy, tx-xx);
		dx = Math.cos(a)*speed;
		dy = Math.sin(a)*speed;
		dz = 5.5;
		if( dx<0 )
			sprite.scaleX = -1;
			
		//S.BANK.fall01().play(0.05);
	}
	
	public override function onHitGround() {
		super.onHitGround();
		
		var r = 65;
		
		var victims = game.explosion(false, xx,yy, r, 3, 2);
		for(e in victims)
			e.slowDown(20);
		
		S.BANK.explode04().play(1);
		fx.explode(xx,yy);
		destroy();
	}
	
	//public override function update() {
		//var a = Math.atan2(ty-yy, tx-xx);
		//dx = Math.cos(a)*speed;
		//dy = Math.sin(a)*speed;
		//if( Lib.distance(xx,yy, tx,ty)<=5 ) {
		//}
		//super.update();
	//}
}