package fx;

class ClockRotate extends mt.fx.Fx {
	
	var to : Float;
	var from : Float;
	var root : flash.display.MovieClip;
	var sp : Float;
	
	public function new( root, to : Float, sp ){
		super();
		this.root = root;
		this.to = normalize(to);
		this.from = normalize(root.rotation);
		this.sp = sp;

		this.curve = function(c){
			return 4*(c*c*c) -9*(c*c) + 6*c;
		}
	}

	function normalize( r : Float ) : Float {
		while( r < 0 )
			r += 360;
		while( r >= 360 )
			r -= 360;
		return r;
	}

	override public function update(){
		coef += sp;
		
		if( coef >= 1 ){
			coef = 1;
			kill();
		}
		
		var v = from + (to-from) * curve(coef);
		root.rotation = v;
		root.gotoAndStop( Math.round(v/2) + 1 );
	}

}
