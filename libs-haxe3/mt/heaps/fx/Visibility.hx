package mt.heaps.fx;

class Visibility extends mt.fx.Fx {
	
	public var alpha:Float;
	public var fadeAlpha:Bool;
	var fadeScale: { sx:Int, sy:Int, scx:Float, scy:Float };
	var root:h2d.Sprite;
	
	dynamic function setAlpha( sp:h2d.Sprite, v:Float) {
		
	}
	
	public function new(mc:h2d.Sprite) {
		super();
		root = mc;
	}
	
	function setVisibility(c:Float) {
		if (!fadeAlpha  && fadeScale == null)
			fadeAlpha=true;
	
		if ( fadeAlpha ) 
			setAlpha(root, c * alpha);
		
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