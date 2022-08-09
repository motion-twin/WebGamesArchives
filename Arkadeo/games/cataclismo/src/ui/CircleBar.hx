package ui;

/**
 * ...
 */

class CircleBar extends flash.display.Sprite
{

	var bar : gfx.CircleBar;
	var mcmask : flash.display.Sprite;
	
	public function new()
	{
		super();
		bar = new gfx.CircleBar();
		addChild(bar);
		
		mcmask = new flash.display.Sprite();
		addChild(mcmask);
		bar.mask = mcmask;
		
	}
	
	/**
	 * set bar value from 0 to 1
	 * @param	val
	 */
	public function setProgress(ratio:Float) {
		var mc = mcmask;
		
		var g = mc.graphics;
		var r = 62;
		var a = -Math.PI/2 + ratio * 2  * Math.PI;

		g.clear();
		g.beginFill(0);
		g.moveTo(0,0);
		g.lineTo(0,-r);
		g.lineTo(r,-r);
		if( ratio >= 0.25 )
			g.lineTo(r,r);
		if( ratio >= 0.50 )
			g.lineTo(-r,r);
		if( ratio >= 0.75 )
			g.lineTo(-r,-r);
		g.lineTo(Math.cos(a) *r ,Math.sin(a) *r);
		g.lineTo(0,0);
		g.endFill();
	}
	
}