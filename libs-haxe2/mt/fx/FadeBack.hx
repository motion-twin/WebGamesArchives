package mt.fx;
import mt.bumdum9.Lib;

/**
 * Removes slowly a colorTransform
 */
class FadeBack extends mt.fx.Fx {
	var root:flash.display.Sprite;
	var ct:flash.geom.ColorTransform;
	var spc:Float;

	public function new(mc,spc=0.1) {
		super();
		root = mc;
		ct = root.transform.colorTransform;
		this.spc = spc;
	}
	
	override function update() {
		super.update();
		coef = Math.min(coef + spc, 1);
		var c = 1-curve(coef);
		root.transform.colorTransform = new flash.geom.ColorTransform(
			(1 - c) + ct.redMultiplier 	 * c,
			(1 - c) + ct.greenMultiplier * c,
			(1 - c) + ct.blueMultiplier  * c,
			1,
			ct.redOffset 	* c,
			ct.greenOffset 	* c,
			ct.blueOffset 	* c,
			0
		);
		
		if( coef == 1 )
			kill();
	}
}

