package fx;
import Protocol;
import mt.bumdum9.Lib;

class Wave extends mt.fx.Fx {

	var data:DataWave;
	var count:Int;
	var timer:Int;
	var hero:Hero;
	var rnd:Int->Int;

	public function new(data:DataWave) {
		super();
		this.data = data;
		count = 0;
		timer = 0;
		hero = Game.me.hero;
		rnd = Game.me.seed.random;
	}
	
	override function update() {
		super.update();
		if( Game.me.stykades.dead ) {
			kill();
			return;
		}
		timer++;
		while( count < data.max && timer >= data.chrono ) {
			spawn(data.bads[count % data.bads.length]);
			timer = 0;
			count++;
		}
		
		if ( count == data.max ) kill();
	}
	
	public function spawn(type:BadType) {
		var pos = Game.me.getRandomPointFarFromHero(100);
		new fx.Spawn(type,pos.x,pos.y);
		
	}
	
	public function getRandomPoint(ma) {
		var mx = ma+Game.BORDER_X;
		var my = ma+Game.BORDER_Y;
		return {
			x : mx+rnd(Game.WIDTH-2*mx),
			y : my+rnd(Game.HEIGHT-2*my),
		}
	}

}
