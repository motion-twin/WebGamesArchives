package navi.menu.asteroid;
import mt.bumdum.Lib;
import mt.bumdum.Phys;


class Rel extends Phys{//}


	public var ray:Float;
	var game:navi.menu.Asteroid;

	public function new(mc){
		game = navi.menu.Asteroid.me;
		super(mc);
		ray = 0;
	}


	// UPDATE
	override public function update(){
		super.update();
		recal();
	}


	function recal(){
		var m = ray;
		var px = Num.sMod( x+m, Cs.mcw+2*m);
		var py = Num.sMod( y+m, Cs.mch+2*m);
		x = px-m;
		y = py-m;
		updatePos();

	}



//{
}








