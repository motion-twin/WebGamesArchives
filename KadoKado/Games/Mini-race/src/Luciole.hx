import Game;
import mt.bumdum.Phys;
import mt.bumdum.Lib;


class Luciole extends Tracker{//}

	public var flLine:Bool;
	var acc:Float;


	public function new(mc){
		super(mc);
		cpi = 0;

		acc = 0.01+Math.random()*0.2;
		root.gotoAndPlay(Std.random(2)+1);

		turnCoef = 0.1+Math.random()*0.2;
		turnLimit = 0.8+Math.random();

		//root.blendMode = "add";

		timer = 10+Math.random()*120;

	}

	public function update(){



		var opx = x;
		var opy = y;

		speed += acc;
		move();
		super.update();

		if(flLine){

			var dx = x-opx;
			var dy = y-opy;
			var a = Math.atan2(dy,dx);
			var dist = Math.sqrt(dx*dx+dy*dy);
			root._xscale = dist;
			root._yscale = 100;
			root._rotation = a/0.0174;
		}


		/*
		timer-=mt.Timer.tmod;
		if(timer<10){
			root._xscale = timer/10 *100;
			root._yscale = root._xscale;
			if(timer<0){
				kill();
			}
		}
		*/


	}




//{
}