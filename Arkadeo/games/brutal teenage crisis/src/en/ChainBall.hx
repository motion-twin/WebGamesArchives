package en;

import mt.deepnight.slb.BSprite;

class ChainBall extends Entity {
	var hero				: Hero;
	var chain				: Array<BSprite>;

	var attachX				: Int;
	var attachY				: Int;

	public function new(h:en.Hero) {
		super();
		attachX = -12;
		attachY = -15;
		hero = h;
		collides = false;
		killOnBottom = false;
		gravity*=0.3;
		radius = 8;

		chain = new Array();
		for(i in 0...3) {
			var s = mode.tiles.get("chain");
			s.setCenter(0.5, 0.5);
			s.scaleX = s.scaleY = 2;
			chain.push(s);
			mode.dm.add(s, Const.DP_HERO);
		}

		sprite.set("ball");
		sprite.setCenter(0.5, 0.5);
		mode.dm.add(sprite, Const.DP_HERO);
	}

	public function setAttach(x:Float, y:Float) {
		attachX = Std.int(x);
		attachY = Std.int(y);
	}

	public function hide() {
		sprite.visible = false;
		for(s in chain)
			s.visible = false;
	}

	public function show() {
		sprite.visible = true;
		for(s in chain)
			s.visible = true;

		update();
	}

	override function destroy() {
		super.destroy();
		for(s in chain)
			s.parent.removeChild(s);
		chain = [];
	}

	override function update() {
		var maxDist = 20;
		var tx = hero.xx + hero.dir * (-hero.sprite.width*0.5 + attachX);
		var ty = hero.yy - hero.sprite.height + attachY;
		var a = Math.atan2(ty-yy, tx-xx);
		var d = mt.deepnight.Lib.distance(xx,yy, tx,ty);
		if( sprite.visible ) {
			dx += Math.cos(a) * 0.02 * (d/maxDist);
			dy += Math.sin(a) * 0.02 * (d/maxDist);
		}
		if( d>=maxDist ) {
			var rx = tx - Math.cos(a)*maxDist;
			var ry = ty - Math.sin(a)*maxDist;
			setPosPixel(xx + (rx-xx)*0.2, yy + (ry-yy)*0.2);
		}

		super.update();

		var d = mt.deepnight.Lib.distance(tx,ty, xx,yy) - radius;
		for( i in 0...chain.length ) {
			var s = chain[i];
			s.x = Std.int( tx - Math.cos(a) * (0.2*d + (i/(chain.length-1)) * d * 0.7) );
			s.y = Std.int( ty - Math.sin(a) * (0.2*d + (i/(chain.length-1)) * d * 0.7) );
		}
	}
}