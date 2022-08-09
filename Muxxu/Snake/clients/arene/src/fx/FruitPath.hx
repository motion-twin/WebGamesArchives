package fx;
import Protocole;

class FruitPath extends Fx {//}
	
	var speed:Float;
	var x:Float;
	var y:Float;
	var an:Float;
	var timer:Int;
	var freq:Int;
	var rank:Int;

	public function new(nx,ny,a,first,freq=4) {
		super();
		x = nx;
		y = ny;
		an = a;
		rank = first;
		
		speed = 5;
		timer = 0;
		this.freq = freq;
	}
	
	override function update() {
		super.update();
	
		x += Snk.cos(an) * speed;
		y += Snk.sin(an) * speed;
		
		timer++;
		if(  timer% freq == 0 ) {
			var fr = Fruit.get(rank);
			fr.x = x;
			fr.y = y;
			fr.specialSpawn();
			rank++;
			rank = Fruit.getClassic(rank);
			
	
		}
		
		if( !Stage.me.isIn(x, y, 10) || rank >= DFruit.LIST.length ) kill();
		

	}
	

	
//{
}












