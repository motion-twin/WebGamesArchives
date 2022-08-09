package fx;
import mt.bumdum.Phys;

class Part extends Phys{//}

	public var bouncer:Bouncer;


	public function new(mc){
		super(mc);
		bouncer = new Bouncer(this);
	}

	override public function update(){

		super.update();
		x-= vx*mt.Timer.tmod;
		y-= vy*mt.Timer.tmod;
		bouncer.update();
		updatePos();
	}



//{
}