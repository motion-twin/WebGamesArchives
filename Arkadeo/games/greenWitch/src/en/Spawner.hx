package en;

import mt.deepnight.Lib;

class Spawner extends Entity {
	static var DELAY = api.AKApi.const(30*6);
	
	var delay			: mt.flash.Volatile<Int>;
	var countAs			: Class<Mob>;
	
	public function new(as:Class<Mob>, cx,cy) {
		countAs = as;

		super();
		
		weight = 99; // évolue dans le temps
		collides = true;
		
		this.cx = cx;
		this.cy = cy;
		updateScreenCoords();
		
		delay = DELAY.get() + irnd(0,10);
	}
	
	inline function mobClass() {
		return Std.string(countAs);
	}
	
	override function register() {
		super.register();
		var k = mobClass();
		if( !game.mobCounts.exists(k) )
			game.mobCounts.set(k, 1);
		else
			game.mobCounts.set(k, game.mobCounts.get(k)+1);
	}
	
	override function detach() {
		super.detach();
		game.mobCounts.set(mobClass(), game.mobCounts.get(mobClass())-1);
	}

	override public function update() {
		super.update();
		
		if( onScreen )
			delay--;
		else
			delay-=5;
			
		if( (uid+game.time)%3==0 ) {
			var ratio = 1-delay/DELAY.get();
			weight = ratio*5;
			if( onScreen )
				fx.spawnSignal(xx,yy, ratio);
		}
		
		if( !killed && delay<=0 ) {
			var e = Type.createInstance(countAs, [cx,cy]);
			e.xx = xx;
			e.yy = yy;
			e.updateFromScreenCoords();
			fx.spawnFinal(xx,yy);
			destroy();
		}
	}
}