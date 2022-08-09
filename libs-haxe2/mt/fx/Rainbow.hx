package mt.fx;
import mt.bumdum9.Lib;

class Rainbow extends Fx{//}

	var mc:flash.display.DisplayObject;
	var coef:Float;
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
		var color = Col.objToCol( Col.getRainbow2(coef) );
		color = Col.brighten(color, inc);
		Col.setPercentColor(mc, 1, color);
	}
	
//{
}