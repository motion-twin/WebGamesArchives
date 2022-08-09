import Protocole;
import mt.bumdum9.Lib;

class Part extends pix.Sprite
{//}
	
	public var vx:Float;
	public var vy:Float;
	public var frict:Float;
	public var weight:Float;
	public var timer:Null<Int>;
	
	public function new() {
		
		super();
		vx = 0;
		vy = 0;
		frict = 1;
		weight = 0;
	
		
	}
	
	override function update() {
		vy += weight;
		
		x += vx;
		y += vy;
		vx *= frict;
		vy *= frict;
		if( timer != null && timer-- <= 0) kill();
		
		super.update();
		
	}


	
	
//{
}












