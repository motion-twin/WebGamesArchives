package mt.fx;
import mt.bumdum9.Lib;

class Line extends mt.fx.Part<SP> {//}
	
	var ox:Float;
	var oy:Float;
	var color:Int;
	
	public function new(color:Int) {
		var mc = new SP();
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
	

	
	
//{
}