package mt.fx;
import mt.bumdum9.Lib;

/**
 * Movement tweener
 */
class Tween extends Fx {
	
	var sin: { dx:Float, dy:Float };
	var root:flash.display.DisplayObject;
	public var speed:Float;
	public var fitPix:Bool;						/* fit to pixels */
	public var tw: mt.bumdum9.Tween;
	public var f:Float->{ x:Float, y:Float };
	
	/**
	 *
	 * @param	mc
	 * @param	ex			End X
	 * @param	ey			End Y
	 * @param	sp=0.1		Speed
	 * @param	?sx			start X
	 * @param	?sy			start Y
	 * @param	?pManager
	 */
	public function new(mc, ex, ey, sp=0.1, ?sx, ?sy, ?pManager) {
		super(pManager);
		root = mc;
		speed = sp;
		// TWEEEN
		if( sx == null ) sx = root.x;
		if( sy == null ) sy = root.y;
		tw = new mt.bumdum9.Tween(sx, sy, ex, ey);
		f = tw.getPos;
	}
	
	override function update() {
		coef = Math.min(coef + speed, 1);
		var c = curve(coef);
		var p = f(c);
		if( sin != null ) {
			var cc = Math.sin(c * 3.14);
			p.x += sin.dx * cc;
			p.y += sin.dy * cc;
		}
		
		root.x = p.x;
		root.y = p.y;
		if( fitPix ) {
			root.x = Std.int(root.x);
			root.y = Std.int(root.y);
		}
		
		if( coef == 1 ) kill();
	}
	
	public function setSin(pow,a=-1.57) {
		sin = { dx:Math.cos(a)*pow, dy:Math.sin(a)*pow };
	}
	
	public function setMod(x, y) {
		var me = this;
		f = function(c) { return me.tw.getModPos(c, x, y); }
	}
	
	public function setPixPerFrame(pix:Float) {
		var dist = tw.getDist();
		if( sin != null ) {
			var all = Math.sqrt(sin.dx * sin.dx + sin.dy * sin.dy) * 2 + dist;
			dist = all * Math.PI / 4;
		}
		speed = pix / dist;
	}
	
	public function testVersion() {
		return true;
	}
	
	public function endPixFit() {
		var me = this;
		onFinish = function() {
			me.root.x = Std.int(me.root.x);
			me.root.y = Std.int(me.root.y);
		}
	}
}
