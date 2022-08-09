import Protocol;
import mt.bumdum9.Lib;

class Stykades extends mt.fx.Sequence {
	
	public static var WAVES = ods.Data.parse("data.ods", "waves", DataWave);
	
	var age:Int;
	public var death:Int;

	public function new() {
		super();
		age = 0;
		death = 0;
	}

	override function update() {
		super.update();
		age++;
	}
	
	public function spawnRandom() {
		#if dev
		for( w in WAVES ) {
			if ( w.test ) {
				launch(w);
				return;
			}
		}
		#end
		var waves = [];
		var sum = 0;
		var userLevel = api.AKApi.getLevel();
		for( w in WAVES ) {
			if( userLevel < w.minLevel || w.start > age || (w.end != null && w.end < age ) ) continue;
			waves.push(w);
			sum += w.weight;
		}
		
		var rnd = Game.me.seed.random(sum);
		var sum = 0;
		for( w in waves ) {
			sum += w.weight;
			if ( sum > rnd ) {
				launch(w);
				break;
			}
		}
	}
	
	public function spawnAll() {
		var waves = [];
		var sum = 0;
		var userLevel = api.AKApi.getLevel();
		for( w in WAVES ) {
			if( w.start > age || (w.end != null && w.end < age ) ) continue;
			waves.push(w);
			sum += w.weight;
		}
		
		var rnd = Game.me.seed.random(sum);
		var sum = 0;
		for( w in waves ) {
			sum += w.weight;
			if ( sum > rnd ) {
				launch(w);
				break;
			}
		}
	}
	
	public function launch(data:DataWave) {
		switch(data.type) {
			case NOISE :				new wave.Noise(data);
			case POINT :				new wave.Point(data);
			case PATH(gap) : 			new wave.Path(data, gap);
			case CIRCLE(ray) : 			new wave.Circle(data,ray);
			case CIRCLE_SEEK(ray) : 	new wave.CircleSeek(data,ray);
			case CORNER :
				var corner = Game.me.seed.random(4);
				var ma = 40;
				var x = ma + (corner % 2) * (Game.WIDTH-2*ma);
				var y = ma + Std.int(corner/2) * (Game.HEIGHT-2*ma);
				new wave.Point(data, { x:x, y:y } );
				
			case SIDE : 				new wave.Side(data);
			case MIRROR :				new wave.Mirror(data);
			case BORDER :				new wave.Border(data);
			
			// TODO
			case KAMIKAZE_PATH : new wave.Border(data);
		}
	}
	
	public function onPower(?t) {

	}
}
