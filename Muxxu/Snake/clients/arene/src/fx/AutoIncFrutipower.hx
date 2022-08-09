package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class AutoIncFrutipower extends CardFx {//}
	
	

	var timer:Int;
	var inc:Float;
	
	public function new(ca, inc) {
		super(ca);
		timer = 0;
		this.inc = inc;
	}
	

	override function update() {
		
		timer++;	
		if(timer%10==0) Game.me.incFrutipower( inc );			
		super.update();
		
		
	}


	
//{
}












