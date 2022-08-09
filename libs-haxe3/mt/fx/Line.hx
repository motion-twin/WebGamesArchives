package mt.fx;

class Line extends mt.fx.Part<flash.display.Sprite> 
{
	var ox:Float;
	var oy:Float;
	var color:Int;
	
	public function new(color:Int) {
		var mc = new flash.display.Sprite();
		super(mc);
		this.color = color;
	}
	
	override function update() {
		ox = x;
		oy = y;
		super.update();
		
		root.graphics.clear();
		root.graphics.lineStyle(1, color);
		root.graphics.moveTo( 0, 0 );
		root.graphics.lineTo( ox-x, oy-y );	
	}
}
