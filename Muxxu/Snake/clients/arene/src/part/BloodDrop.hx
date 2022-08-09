package part;
import Protocole;
import mt.bumdum9.Lib;

class BloodDrop extends Part
{//}
	static public var POOL:Array<BloodDrop> = [];
	var prev: { x:Float, y:Float };
	
	function new() {
		super();
		backPool = POOL;
	}
	public static function get() {
		if( BloodDrop.POOL.length == 0 ) return new BloodDrop();
		var p = BloodDrop.POOL.pop();
		p.init();
		return p;
	}
	
	override function init() {
		super.init();
		sprite.drawFrame(Gfx.fx.get("blood_drop"));
		weight = 0.25;
		ray = 0;
		dropShade(true);
		prev = null;
		Stage.me.dm.add(sprite, Stage.DP_FX);
	}
	
	override function update() {
		super.update();
		if (prev != null) {
			var dx = prev.x-x;
			var dy = prev.y-y;
			sprite.graphics.clear();
			sprite.graphics.lineStyle(1, Game.me.bloodColor);
			sprite.graphics.moveTo(0, 0);
			sprite.graphics.lineTo( dx, dy);
			
		}
		prev = { x:x, y:y };
	}
	
	override function groundBounce() {
		
		var brush  = new pix.Element();
		brush.drawFrame(Gfx.fx.get(1 + Std.random(4), "blood_mini_spot"));
		
		
		var bmp = Stage.me.gore.bitmapData;
		var m = new flash.geom.Matrix();
		m.translate(Std.int(x), Std.int(y));
		
		bmp.draw(brush, m, sprite.transform.colorTransform);
		
		var n = 4;
		Stage.me.renderBg(new flash.geom.Rectangle(x-n,y-n,n*2,n*2));
		
		kill();
	}

	public function setColor(color) {
		Col.setPercentColor(sprite, 1, color);
	}
	
//{
}












