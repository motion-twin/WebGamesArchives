package fx;
import Protocole;
import mt.bumdum9.Lib;

class Bell extends Fx {//}

	var green:Array<Int>;
	static var EC = 14;
	var timer:mt.flash.Volatile<Int>;
	
	public function new() {
		super();
		timer = Std.int(sn.length / (3 * EC));
		
		green = [];
		for( rank in 0...160 ) {
			var data = Fruit.getData(rank);
			if( Lambda.has( data.tags, Green ) && Game.me.seed.random(data.freq) == 0 ) green.push(rank);
		}
		Arr.shuffle(green,Game.me.seed);
		
	}
	
	override function update() {
		super.update();
		
		if( Game.me.gtimer % 3 != 0 ) return;

		if( sn.length > 20 ) {
			var rank = green.pop();
			green.unshift(rank);
			var pos = sn.getRingData(sn.length).ring;
			var fruit = Fruit.get(rank);
			fruit.x = pos.x;
			fruit.y = pos.y;
			fruit.specialSpawn();
			sn.length -= EC;
		}
	
		
		if(timer-- == 0) kill();
				
	}
	

	

	
	

		
	
//{
}
