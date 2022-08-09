package part;
import Protocole;
import mt.bumdum9.Lib;

class Line extends Part
{//}
	public static var POOL:Array<Line> = [];

	public var multi:Float;
	var prev: { x:Float, y:Float };
	public var color:Int;
	public var glowCoef:Null<Float>;
	
	function new() {
		super();
		backPool = Line.POOL;

	}
	override function init() {
		super.init();
		weight = 0.25;
		ray = 0;
		color = 0xFFFFFF;
		multi = 1;
		prev = null;
		glowCoef = null;
		Stage.me.dm.add(sprite, Stage.DP_FX);
	}
	static public function get() {
		if( Line.POOL.length == 0 ) return new Line();
		var p = Line.POOL.pop();
		p.init();
		return p;
	}
		
	override function update() {
		super.update();
		if (prev != null) {
			var dx = prev.x-x;
			var dy = prev.y - y;
			dx *= multi;
			dy *= multi;
			sprite.graphics.clear();
			sprite.graphics.lineStyle(0, color );
			sprite.graphics.moveTo(0, 0);
			sprite.graphics.lineTo( dx, dy);
		}
		prev = { x:x, y:y };
		
		
		if(glowCoef != null) {
			glowCoef = Math.max(glowCoef - 0.05, 0);
			var c = glowCoef;
			sprite.filters = [];
			Filt.glow(sprite, c*24, c*3, color);
			if( glowCoef <= 0 ) glowCoef = null;
		}
		
	}
	
	
	

//{
}












