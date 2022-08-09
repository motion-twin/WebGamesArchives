package mt.fx;
import mt.bumdum9.Lib;

class Flash extends Fx{//}

	
	var dataGlow:{str:Float,bl:Float,?color:Int};

	var color:Null<Int>;
	public var additive:Bool;

	var speed:Float;
	var root:flash.display.DisplayObject;
	var first:Bool;
	var power:Float;

	public function new(mc, sp=0.1, ?color, power=1.0 ) {
		this.color = color;
		this.power = power;
		super();
		root = mc;
		speed = sp;
		first = true;
		additive = false;
		
		if ( this.color == null ) {
			this.color = 0xFFFFFF;
			additive  = true;
		}
	}
	
	
	public override function kill()
	{
		super.kill();
		root = null;
	}
	
	override function update() {
		if( !root.visible ) return;
		if(!first) coef = Math.min(coef+speed, 1);
		first = false;
		maj();
		if( coef == 1 ) kill();
	}
		
	public function maj() {

		var c = 1-curve(coef);
		
		//if( color == null )	Col.setColor(root, 0, Std.int(255 * c*power));
		if ( additive ) {
			var o = Col.colToObj(color);
			o.r = Std.int(o.r*c*power);
			o.g = Std.int(o.g*c*power);
			o.b = Std.int(o.b*c*power);
			root.transform.colorTransform = new CT(1,1,1,1,o.r,o.g,o.b,0);
		}else {
			Col.setPercentColor(root, c*power, color);
		}
		
		
		if( dataGlow != null ) {
			root.filters = [];
			var col = color;
			if( col == null ) color = 0xFFFFFF;
			if( dataGlow.color != null ) col = dataGlow.color;
			var bl:Float = dataGlow.bl * c;
			var str:Float = dataGlow.str * c;
			if( coef > 0 ) root.filters = [new flash.filters.GlowFilter(col,1,bl,bl,str)];
		}
		
	}
	
	public function glow(str,bl,?color) {
		dataGlow = { str:str, bl:bl, color:color};
		maj();
	}
	
//{
}