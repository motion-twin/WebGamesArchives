import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;


class Projectile extends Phys{//}


	var angle:Float;
	var speed:Float;
	var qcol:Int;

	public function new( mc : flash.MovieClip ){
		super(mc);
		qcol = 0xFFFFFF;
	}


	override function update(){

		// QUEUE
		var mc = Game.me.brushQueueMissile;
		mc._x = x;
		mc._y = y;
		mc._rotation = angle/0.0174;
		mc._xscale = speed*mt.Timer.tmod;
		Col.setColor(mc.smc,qcol);
		Game.me.plasma.drawMc(mc);

		//
		super.update();


	}

	public function setAngle(n){
		angle = n;
		root._rotation = angle/0.0174;
	}
	public function setSpeed(n){
		speed = n;
		vx = Math.cos(angle)*speed;
		vy = Math.sin(angle)*speed;
	}



//{
}



























