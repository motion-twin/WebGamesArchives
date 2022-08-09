package mt.fx;

class Visibility extends Fx 
{
	public var alpha:Float;
	public var fadeAlpha:Bool;
	var fadeScale: { sx:Int, sy:Int, scx:Float, scy:Float };
	var fadeBlur: { x:Float, y:Float };
	var root:flash.display.DisplayObject;
	
	public function new(mc) {
		super();
		root = mc;
	}
	
	function setVisibility(c:Float) {
		if (!fadeAlpha && fadeBlur == null && fadeScale == null)
			fadeAlpha=true;
	
		if( fadeAlpha ) root.alpha = c * alpha;
		if( fadeBlur != null ) 	root.filters = [ new flash.filters.BlurFilter(fadeBlur.x*(1-c),fadeBlur.y*(1-c)) ];
		
		if( fadeScale != null ) {
			switch(fadeScale.sx) {
				case -1 :	root.scaleX =  fadeScale.scx / c;
				case 1 :	root.scaleX =  fadeScale.scx * c;
			}
			switch(fadeScale.sy) {
				case -1 :	root.scaleY =  fadeScale.scy / c;
				case 1 :	root.scaleY =  fadeScale.scy * c;
			}
		}
		
		//reminder :
		#if debug
		//if (!fadeAlpha && fadeBlur == null && fadeScale == null)
		//	throw "wrong setup";
		#end
		return this;
	}
	
}