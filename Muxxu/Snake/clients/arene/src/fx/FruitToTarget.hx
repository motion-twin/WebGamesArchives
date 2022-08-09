package fx;
import Protocole;
import mt.bumdum9.Lib;

class FruitToTarget extends Fx {//}

	var fid:Int;
	var fruit:Fruit;
	var speed:Float;
	var trg: { x:Float, y:Float };
	
	public function new(fr:Fruit,sp,trg) {
		super();
		this.trg = trg;
		fruit = fr;
		fid = fruit.initId;
		speed = sp;
		fr.dummy = true;
	}
	
	override function update() {
		super.update();
		
		if( fruit.initId != fid ) return;
		if( fruit.z < -1 ) return;
		fruit.vz = 0;
		fruit.z = 0;
		
		var dx = trg.x - fruit.x;
		var dy = trg.y - fruit.y;
		var a = Math.atan2(dy, dx);
		var dist = Math.sqrt(dx * dx + dy * dy);
		if( dist < speed) {
			speed = dist;
			fruit.dummy = false;
			kill();
		}
		
		fruit.x += Snk.cos(a)*speed;
		fruit.y += Snk.sin(a)*speed;
		
	}
	

	
	

	
	

		
	
//{
}
