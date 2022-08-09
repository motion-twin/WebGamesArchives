package fx;

class ScaleIn extends mt.fx.Fx
{
	var ent : ent.Ball;
	var speed : Float;
	
	public function new(ball:ent.Ball, speed :Float = 0.1) 
	{
		super();
		this.ent = ball;
		this.speed = speed;
		init();
	}
	
	inline function scale(mc:flash.display.Sprite, v : Float )
	{
		mc.scaleX = mc.scaleY = v;
	}
	
	function init()
	{
		scale(ent.root, 0);
		scale(ent.shade, 0);
		this.curveIn(2.5);
	}
	
	override function update()
	{
		var t = curve(coef);
		//
		scale(ent.root, t);
		scale(ent.shade, t);
		//
		coef += speed;
		if( coef >= 1 ) kill();
	}
}
