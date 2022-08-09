package mt.fx;

import mt.flash.Color;
class FadeTo extends Fx
{
	var root:flash.display.DisplayObject;
	var inc:Int;
	var color:Int;
	var spc:Float;

	/**
	 * Fade to a color
	 * @param	mc					Target display object
	 * @param	spc=0.1				Speed
	 * @param	inc = 0				???
	 * @param	color = 0x808080	Color to fade to
	 */
	public function new(mc, spc = 0.1, inc = 0, color = 0x808080) {
		super();
		root = mc;
		this.inc = inc;
		this.color = color;
		this.spc = spc;
		super();
		coef = 0;
		
	}
	
	override function update() {
		super.update();
		coef = Math.min(coef + spc, 1);
		var c = curve(coef);
		var col = Color.mergeCol( color, 0x808080, c );
		var n = Std.int(inc * c);
		Color.overlay(root, col, n - 128);
		if( coef == 1 ) kill();
	}
}
