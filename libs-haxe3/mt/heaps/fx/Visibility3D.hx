package mt.heaps.fx;

class Visibility3D extends mt.fx.Fx {
	
	public var 	alpha:Float;
	public var 	fadeAlpha:Bool;
	
	var 		fadeScale: { sx:Int, sy:Int, sz:Int, scx:Float, scy:Float,scz:Float };
	var 		root:h3d.scene.Object;
	
	dynamic function setAlpha( sp:h3d.scene.Object, v:Float) {
		
	}
	
	public function new(mc:h3d.scene.Object) {
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
			
			switch(fadeScale.sz) {
				case -1 :	root.scaleZ =  fadeScale.scz / c;
				case 1 :	root.scaleZ =  fadeScale.scz * c;
			}
		}
		
		
		return this;
	}
	
}