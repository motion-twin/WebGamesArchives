package fx;
import mt.bumdum.Phys;

class Tracer extends Phys{//}


	public function new(mc){
		super(mc);
	}

	override public function update(){

		super.update();
		Game.me.plasmaDraw(root);
	}



//{
}
