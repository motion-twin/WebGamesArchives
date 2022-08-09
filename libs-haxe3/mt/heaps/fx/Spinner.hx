package mt.heaps.fx;


class Spinner<T:h2d.Sprite> extends Part<h2d.Sprite>
{
	public var mc:T;
	public var dist:Float;
	
	public function new(mc:T, dist = 0.0) {
		this.dist = dist;
		var box = new flash.display.Sprite();
		this.mc = mc;
		box.addChild(mc);
		super(box);
		mc.x = dist;
	}
	
	override function setPos(x:Float,y:Float) {
		var a = root.rotation * 0.0174;
		x -= Math.cos(a) * dist;
		y -= Math.sin(a) * dist;
		super.setPos(x, y);
	}
	
	public function launch(an:Float, power:Float, cvr:Float) {
		vx += Math.cos(an) * power;
		vy += Math.sin(an) * power;
		var sens = Std.random(2) * 2 - 1;
		root.rotation = (an / 0.0174) - sens * 90;
		vr = power*cvr*sens;
	}
}
