package part;
import mt.bumdum.Lib;


class Spirit extends Part{

	var dm:mt.DepthManager;
	var ball:flash.MovieClip;
	var angle:Float;
	var speed:Float;
	var dec:Float;
	var speedDec:Float;
	var ec:Float;

	public function new(mc){
		super(mc);
		dm = new mt.DepthManager(mc);
		angle = -1.57;
		speed = 1.5;
		dec = 0;
		speedDec = 23;
		ec = 0.1;

		timer = 100;
		ball = dm.attach("mcGhost",1);

		Filt.glow(root,10,1,0xFFFFFF );
	}

	public override function update(){
		super.update();
		dec = (dec+speedDec)%628;
		angle += Math.cos(dec*0.01)*ec;

		var dist = speed*mt.Timer.tmod;
		var dx = Math.cos(angle)*dist;
		var dy = Math.sin(angle)*dist;

		ball._x += dx;
		ball._y += dy;

		var mc = dm.attach("mcGhostQueue",0);
		mc._x = ball._x;
		mc._y = ball._y;
		mc._xscale = speed;
		mc._rotation =  angle/0.0174 + 180;
		ball._rotation = mc._rotation-90;

		//
		speedDec+= 0.3*mt.Timer.tmod;
		ec += 0.002*mt.Timer.tmod;
		speed += 0.1*mt.Timer.tmod;

	}
}