package mt.fx;

class Rainbow extends Fx
{
	var mc:flash.display.DisplayObject;
	var spc:Float;
	var inc:Int;
	
	public function new(mc,spc=0.05) {
		super();
		this.mc = mc;
		this.spc = spc;
		inc = 0;
		coef = 0;
	}
	
	override function update() {
		coef = (coef+spc)%1;
		var color = mt.flash.Color.getRainbow2(coef).toRgb();
		color = mt.flash.Color.brighten(color, inc);
		mt.flash.Color.setPercentColor(mc, 1, color);
	}

}