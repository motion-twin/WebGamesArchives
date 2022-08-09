package fx;
import mt.bumdum9.Lib;

class Radiate extends mt.fx.Fx{//}

	var color:Null<Int>;
	var speed:Float;
	var timer:Int;
	var max : Float;
	public var root:flash.display.DisplayObject;


	public function new(mc, sp=0.1, color, max, timer ) {
		this.color = color;
		super();
		root = mc;
		speed = sp;
		this.max = max;
		this.timer = timer;
	}
	
	override function update() {
		if( !root.visible ||timer--==0) {
			kill();
			return;
		}
		maj();
	}
		
	public function maj() {
		
		coef = (coef + speed) % 1;
		var c = 0.5+Math.cos(curve(coef)*6.28)*0.5;
		Col.setPercentColor(root, c*max, color);
		
	}
	
	override function kill() {
		Col.setColor(root, 0, 0);
		super.kill();
		
	}
	

	
//{
}
