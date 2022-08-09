package mt.heaps.fx;
import h2d.Sprite;

class Grow extends mt.fx.Fx{

	var root:h2d.Sprite;
	public var spc:Float;
	var type : Int ;
	var delta : Float ;
	var from : Float ;

	//spc is the step of alpha per frame
	public function new(mc, spc=0.1, to = 1.0, mode = 0) {
		super();
		root = mc ;
		this.spc = spc;
		type = mode ;

		switch(mode) {
			case 0 : 	delta = if (root.scaleX < to) (to - root.scaleX) else ((root.scaleX - to) * -1) ; //X && Y
						from = root.scaleX ;
			case 1 : 	delta = if (root.scaleX < to) (to - root.scaleX) else ((root.scaleX - to) * -1) ; //X only
						from = root.scaleX ;
			case 2 : 	delta = if (root.scaleY < to) (to - root.scaleY) else ((root.scaleY - to) * -1) ; //Y only
						from = root.scaleY ;
			
		}
	}
	
	override function update() {
		super.update();
		coef = Math.min(coef + spc, 1);
		var c = curve(coef) ;
		switch(type) {
			case 0 : 
				root.scaleX = from + delta * c ;
				root.scaleY = root.scaleX ;
			case 1 : 
				root.scaleX = from + delta * c ;
			case 2 : 
				root.scaleY = from + delta * c ;
		}
		
		if( coef == 1 ) kill();
	}
}
