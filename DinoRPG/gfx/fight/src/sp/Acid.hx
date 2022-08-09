package sp;

import mt.bumdum.Lib;

class Acid extends mt.bumdum.Phys{//}


	public var ty:Float;

	public function new(mc){
		super(mc);

	}

	public override function update(){
		super.update();
		if( y > ty ){
			root.gotoAndPlay("cloud");

			weight = -(0.2*Math.random()*0.5);
			timer = 10+Math.random()*15;
			setScale(100+Math.random()*50);
			vr = (Math.random()*2-1)*3;
			y = ty;
			vy = 0;
		}

	}



//{
}