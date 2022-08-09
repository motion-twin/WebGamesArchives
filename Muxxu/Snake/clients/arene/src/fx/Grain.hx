package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

typedef McGrain = { part:Part, timer:Int, max:Int };

class Grain extends Fx {//}
	
	var list:Array<McGrain>;
	
	public function new(sx,sy,max=16) {
		super();
		list = [];
		for( i in 0...max ) {
			var p = Part.get();
			p.sprite.drawFrame(Gfx.fx.get(0, "grain"));
			Stage.me.dm.add(p.sprite, Stage.DP_FRUITS);
			p.x = sx;
			p.y = sy;
			p.launch( i / max * 6.28,  Game.me.seed.rand() * 5, -(2 +  Game.me.seed.rand() * 3) );
			p.weight = 0.2;
			p.dropShade();
			p.frict =  0.96;
			
			var o = { part:p, timer:0, max:40 + Game.me.seed.random(600) };
			list.push(o);
			if( Game.me.have(BUCKET) ) o.max = 20 + Game.me.seed.random(40);
		}
		
		
	}
	
	override function update() {
		var a = list.copy();
		var inc = 1 + Game.me.numCard(FERTILIZER)*3;
		for( o in a ) {
			if( o.part.z <-1 ) continue;
			o.timer+=inc;
			var c = Math.min( o.timer / o.max, 1);
			if( c == 1 ) {
				spawnFruit(o);
				continue;
			}
			var fr = Std.int( c * 5 );
			o.part.sprite.drawFrame(Gfx.fx.get(fr, "grain"));
			
			
		}
		
	}
	function spawnFruit(o:McGrain) {
		list.remove(o);
		o.part.kill();
		var rank = Game.me.getRandomFruitRank();
		var fr = Fruit.get(rank);
		fr.x = o.part.x;
		fr.y = o.part.y;
		fr.updatePos();
		fr.specialSpawn();
	}
	
	

		
	
//{
}












