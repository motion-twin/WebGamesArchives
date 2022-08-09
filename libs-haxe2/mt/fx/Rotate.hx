package mt.fx;
import mt.bumdum9.Lib;

class Rotate extends Fx{//}

	public var speed:Float;
	public var frict:Float;

	var root:flash.display.DisplayObject;
	

	public function new(mc, speed=10.0, frict = 1.0 ) {
		super();
		root = mc;
		this.speed = speed;
		this.frict = frict;
	}
	
	override function update() {
	
		if( root.parent == null  ) {
			kill();
			return;
		}
		
		root.rotation += speed;
		speed *= frict;

	}

//{
}