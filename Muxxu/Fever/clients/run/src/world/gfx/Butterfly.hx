package world.gfx;
import mt.bumdum9.Lib;
import Protocole;


class Butterfly extends pix.Sprite {//}
	

	var sprite:pix.Sprite;
	var island:world.Island;
	var square:world.Square;
	var th:Float;
	var h:Float;
	
	var dx:Float;
	var dy:Float;
	
	var vx:Float;
	var vy:Float;
	
	var sc:Float;
	
	public function new(isl,sq,coef) {
		super();
		island = isl;
		square = sq;
		
		sprite = new pix.Sprite();
		h = th = 2;
		dx = 0;
		dy = 0;
		sprite.setAnim(Gfx.fx.getAnim("butterfly"));
		addChild(sprite);
		island.dm.add(this, world.Island.DP_ELEMENTS);
		
		// SHADOW
		
		graphics.beginFill(0, 0.2);
		var r = 1;
		graphics.drawEllipse( -r*2, -r, r*4, r*2);
		
		//POS
		var p = square.getCenter();
		x = p.x;
		y = p.y;
		//
		Col.overlay(sprite, Col.getRainbow2(coef) );
		
		// SC
		sc = 0;
		sprite.scaleX = sprite.scaleY = sc;
		
	}
	
	override function update() {
		super.update();
		
		// HEIGHT
		if( Std.random(20) == 0 ) th = 2 + Math.random() * 14;
		h += (th - h) * 0.1;
		sprite.y = -h;
		
		// DIR
		if( Std.random(20) == 0 && square.rnei.length > 0 ) {
			var a = square.rnei.copy();
			Arr.shuffle(a);
			square = a[0];
		}
		
		// MOVE
		var pos = getTargetPos();
		vx = (pos.x - x) * 0.1;
		vy = (pos.y - y) * 0.1;
		
		x += vx;
		y += vy;
		
		if( Std.random(20) == 0 ) dx = Std.random(16) - 8;
		if( Std.random(20) == 0 ) dy = Std.random(16) - 8;
		
		//
		if( sc < 1 ) sc += 0.1;

		sprite.scaleX = sprite.scaleY = sc;
		
		
		/*
		var dist = Math.sqrt(vx * vx + vy * vy);
		
		while( dist > 1 ) {
			dist -= 2;
			var c = Math.random();
			var p = new pix.Part();
			island.dm.add(p, world.Island.DP_ELEMENTS );
			p.setPos(x-p.vx*c, (y-h)-p.vy*c );
			p.weight = 0.02 + Math.random() * 0.02;
			p.setAnim(Gfx.fx.getAnim("spark_twinkle"));
			p.anim.gotoRandom();
			p.setGround(p.y + h);
			p.timer = 10 + Std.random(10);
			p.vx = vx*0.5;
			p.vy = vy*0.5;
		}
		*/
		
	
	}
	
	function getTargetPos() {
		var p = square.getCenter();
		return {
			x : p.x +dx,
			y : p.y +dy,
		}
		
	}
	


	
//{
}











