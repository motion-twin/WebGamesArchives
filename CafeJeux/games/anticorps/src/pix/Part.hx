package pix;
import Common;

class Part extends pix.Phys {//}

	public var timer:Float;
	var scale:Float;



	public function new(mc) {
		Game.me.parts.push(this);
		super(mc);
		scale = 100;
	}

	public function update(){

		fly();
		// TIMER
		if(timer!=null){
			timer -= mt.Timer.tmod;
			if( timer<10 ){
				var c = timer/10;
				root._xscale = c*scale;
				root._yscale = c*scale;
				if( timer<0 ){
					kill();
				}
			}
		}
	}

	public function setScale(n){
		scale = n;
		root._xscale = scale;
		root._yscale = scale;
	}

	override function kill(){
		Game.me.parts.remove(this);
		super.kill();
	}






//{
}











