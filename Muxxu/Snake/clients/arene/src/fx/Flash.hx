package fx;
import mt.bumdum9.Lib;

class Flash extends Fx{//}

	
	var dataGlow:{str:Float,bl:Float};

	var type:Int;
	var color:Null<Int>;
	var coef:Float;
	var speed:Float;
	var root:flash.display.Sprite;

	public function new(mc, sp=0.1, ?type:Int,?color:Int ) {
		this.color = color;
		this.type = type;
		super();
		root = mc;
		speed = sp;
		coef = 1.0;

		maj();
	}
	
	override function update() {
		if( !root.visible ) return;
		coef = Math.max(coef - speed, 0);
		maj();
		if( coef == 0 ) kill();
	}
		
	function maj() {

		var c = coef;
		switch(type) {
			case 0 :		c = coef;
			case 1 :		c = 0.5 - Snk.cos(coef * 3.14) * 0.5;
		}
		
		
		if( color == null )	Col.setColor(root, 0, Std.int(255 * coef));
		else				Col.setPercentColor(root, coef, color);
		
		
		if( dataGlow != null ) {
			root.filters = [];
			var col = color;
			if( col == null ) color = 0xFFFFFF;
			var bl = dataGlow.bl * coef;
			var str = dataGlow.str * coef;
			if( coef > 0 ) root.filters = [new flash.filters.GlowFilter(color,1,bl,bl,str)];
		}
		
	}
	
	public function glow(str,bl) {
		dataGlow = { str:str, bl:bl};
		maj();
	}
	
//{
}