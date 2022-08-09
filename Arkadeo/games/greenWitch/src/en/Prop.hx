package en;

import mt.deepnight.Lib;

class Prop extends Entity {
	public static var ALL : Array<Prop> = [];
	
	var key		: String;
	
	public function new(tcx,tcy, key:String) {
		super();

		this.key = key;
		collides = true;
		weight = 2;
		side = 0;
		radius = 9;
		
		xr = rnd(0.2, 0.8);
		yr = rnd(0.2, 0.8);
		cx = tcx;
		cy = tcy;
		updateScreenCoords();

		sprite.swap(game.tiles, key, game.tiles.getRandomFrame(key, rseed.random));
		setShadow(true);
		switch( key ) {
			case "barrel" :
				sprite.setCenter(0.5, 0.84);
				initLife(2);
			case "shrine" :
				sprite.setCenter(0.5, 0.8);
				initLife(9999);
		}
	}
	
	override function splat() {
		var col = switch(key) {
			case "barrel" : 0xAF8069;
			default : 0xA29186;
		}
		fx.death(xx,yy, col, 15);
		fx.bones(xx,yy, col);
	}

	override function register() {
		super.register();
		ALL.push(this);
	}
	override function detach() {
		super.detach();
		ALL.remove(this);
	}
	
	override function update() {
		super.update();
		if( getCollision(cx,cy) )
			destroy();
	}
}