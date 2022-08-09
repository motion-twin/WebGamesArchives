package mt.heaps.fx;

import mt.flash.Color;

class Flash extends mt.fx.Fx{

	var color:Null<Int>;
	public var additive:Bool;

	var speed:Float;
	var root:h2d.Sprite;
	var first:Bool;
	var power:Float;

	public function new(?pManager: mt.fx.Manager, mc, sp = 0.1, ?color, power = 1.0 ){
		this.color = color;
		this.power = power;
		super(pManager);
		root = mc;
		speed = sp;
		first = true;
		if ( this.color == null )
			this.color = 0xFFFFFF;
	}

	public override function kill(){
		super.kill();
		root = null;
	}

	override function update(){
		if(!first) coef = Math.min(coef+speed, 1);
		first = false;
		maj();
		if( coef == 1 ) {
			kill();
			return;
		}
		if(root == null) {
			kill();
			return;
		}
		if(root != null && root.parent == null) {
			kill();
			return;
		}
	}

	inline function flash(vec:h3d.Vector,sp:h2d.Sprite) {
		var d = Std.instance( sp, h2d.Drawable);
		if( d!=null)
			d.colorAdd = vec;
	}
	
	var vec: h3d.Vector = new h3d.Vector();
	public function maj(){
		var c = 1-curve(coef);
		var o = mt.flash.ColorArgb.createFromRgb(color);
		o.red 	= Std.int(o.red*c*power);
		o.green = Std.int(o.green*c*power);
		o.blue 	= Std.int(o.blue*c*power);
		vec.set(o.red/255.0, o.green/255.0, o.blue/255.0,0);
		root.traverse(flash.bind(vec));
	}

	public function glow(str, bl, ?color)
	{
		maj();
	}
}
