package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class AutoIncQueue extends CardFx {//}
	
	

	var timer:Int;
	var inc:Float;
	
	public function new(ca) {
		super(ca);
		timer = 0;		
	}
	

	override function update() {
		timer++;	
		if (timer % 10 == 0) sn.length += 2;			
		super.update();		
	}


	
//{
}












