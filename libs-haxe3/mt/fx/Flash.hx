package mt.fx;

import mt.flash.Color;
class Flash extends Fx{


	var dataGlow:{str:Float,bl:Float,?color:Int};

	var color:Null<Int>;
	public var additive:Bool;

	var speed:Float;
	var root:flash.display.DisplayObject;
	var first:Bool;
	var power:Float;

	public function new(mc, sp = 0.1, ?color, power = 1.0 )
	{
		this.color = color;
		this.power = power;
		super();
		root = mc;
		speed = sp;
		first = true;
		additive = false;

		if ( this.color == null )
		{
			this.color = 0xFFFFFF;
			additive  = true;
		}
	}


	public override function kill()
	{
		super.kill();
		root = null;
	}

	override function update()
	{

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

	public function maj()
	{
		var c = 1-curve(coef);
		if ( additive )
		{
			var o = mt.flash.ColorArgb.createFromRgb(color);
			o.red 	= Std.int(o.red*c*power);
			o.green = Std.int(o.green*c*power);
			o.blue 	= Std.int(o.blue*c*power);
			root.transform.colorTransform = new flash.geom.ColorTransform(1, 1, 1, 1, o.red, o.green, o.blue, 0);
		}
		else
		{
			Color.setPercentColor(root, c * power, color);
		}

		if ( dataGlow != null )
		{
			root.filters = [];
			var col = color;
			if( col == null ) color = 0xFFFFFF;
			if( dataGlow.color != null ) col = dataGlow.color;
			var bl:Float = dataGlow.bl * c;
			var str:Float = dataGlow.str * c;
			if( coef > 0 ) root.filters = [new flash.filters.GlowFilter(col,1,bl,bl,str)];
		}

	}

	public function glow(str, bl, ?color)
	{
		dataGlow = { str:str, bl:bl, color:color};
		maj();
	}
}
