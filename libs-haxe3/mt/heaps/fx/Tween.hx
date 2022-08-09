package mt.heaps.fx;
import h2d.Sprite;

/**
 * Movement tweener
 */
class Tween extends mt.fx.Fx 
{
	var sin: { dx:Float, dy:Float };
	var root:h2d.Sprite;
	public var speed:Float;
	public var fitPix:Bool;						/* fit to pixels */
	public var tw: BudumTween;
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
		tw = new BudumTween(sx, sy, ex, ey);
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


class BudumTween {

	public var sx:Float;
	public var sy:Float;
	public var ex:Float;
	public var ey:Float;
	public var coef:Float;
	
	/**
	 * Define start pos and end pos
	 */
	public function new(?sx:Float,?sy:Float,?ex:Float,?ey:Float){
		this.sx = sx;
		this.sy = sy;
		this.ex = ex;
		this.ey = ey;
		coef = 0;
	}
	
	/**
	 * Tween positions with value between 0 and 1
	 * @param	?c
	 */
	public function getPos(?c:Float) {
		if ( c == null ) c = coef;
		return {
			x : sx + (ex-sx)*c,
			y : sy + (ey-sy)*c,
		};
	}
	
	public function getVelocity(c:Float) {
		return {
			vx : (ex-sx)*c,
			vy : (ey-sy)*c,
		};
	}

	public function getDist() {
		var dx = ex - sx;
		var dy = ey - sy;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	/**
	 * Returns angle in radians
	 */
	public function getAngle() {
		var dx = ex - sx;
		var dy = ey - sy;
		return Math.atan2(dy, dx);
	}

	public function getModPos(?c:Float,?mx:Float,?my:Float) {
		var dx = mt.MLib.hMod( ex - sx, mx * 0.5 );
		var dy = mt.MLib.hMod( ey - sy, my * 0.5 );
		return {
			x : mt.MLib.sMod(sx + dx*c,mx),
			y : mt.MLib.sMod(sy + dy*c,my),
		};
	}
}