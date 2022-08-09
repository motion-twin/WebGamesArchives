
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;


class Fly extends Phys {//}


	var angle:Float;
	var dec:Float;
	var ecart:Float;
	var cycle:Float;
	var speed:Float;
	var acc:Float;
	var sfr:Float;
	var sc:Float;


	public function new( mc : flash.MovieClip ){
		super(mc);

		angle = -1.57 + (Math.random()*2-1)*0.35;
		dec =  Std.random(628);
		ecart = 0.1;
		cycle = 33;

		speed = 1;
		acc = 0.3;
		sfr = 0.95;

		sc = 0;

	}


	override function update(){


		sc = Math.min(sc+0.1*mt.Timer.tmod,1);

		dec = (dec+cycle*mt.Timer.tmod)%628;
		angle += Math.sin(dec*0.01)*ecart*sc;

		speed += acc*mt.Timer.tmod;
		speed *= Math.pow(sfr,mt.Timer.tmod);

		vx = Math.cos(angle)*speed;
		vy = Math.sin(angle)*speed;

		root._rotation = angle/0.0174;

		super.update();

	}





//{
}



























