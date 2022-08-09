package part;

class Ashes2 extends Part
{
	var dm:mt.DepthManager;
	var clip:flash.MovieClip;
	var angle:Float;
	var ampl:Float;
	var dir:Int;
	
	public function new(mc){
		super(mc);
		dm = new mt.DepthManager(mc);
		this.timer = root._totalframes  + Math.random() * 20;
		this.vr = 0.0;
		this.bounceFrict = 0.0;
		this.groundFrict = 0.0;
		ampl = 90 + Math.random() * 90;
		angle = (Math.random() * ampl);
		dir = 1;
		clip = root;// dm.attach("animcendres", 1);
		clip._rotation = - Math.random() * 30;
	}
	
	inline static var TO_RAD = Math.PI / 180;
	
	override function kill()
	{
		x = Math.random()*Scene.WIDTH;
		y = Scene.getRandomPYPos();
		z = 0;
		clip._rotation = - Math.random() * 30;
		updatePos();
		clip.gotoAndPlay(1);
		timer = root._totalframes  + Math.random() * 20;
	}
	
	public function dispose()
	{
		clip.removeMovieClip();
		super.kill();
	}
	
}