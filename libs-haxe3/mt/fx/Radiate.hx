package mt.fx;

class Radiate extends Fx
{
	var color:Null<Int>;
	var speed:Float;
	var timer:Int;
	public var alpha:Bool;
	public var root:flash.display.DisplayObject;
	
	public function new(mc, sp=0.1, ?color, timer=-1 ) {
		this.color = color;
		super();
		root = mc;
		speed = sp;
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
		if( alpha )					root.alpha = c;
		else if( color == null )	mt.flash.Color.setColor(root, 0, Std.int(255 * c));
		else						mt.flash.Color.setPercentColor(root, c, color);
		
	}
	
	override function kill() {
		mt.flash.Color.setColor(root, 0, 0);
		super.kill();
		
	}
}
