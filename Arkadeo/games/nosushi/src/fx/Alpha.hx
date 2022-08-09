package fx;
import mt.bumdum9.Lib;

class Alpha extends mt.fx.Fx{//}

	var mc : SP;
	var start : Float;
	var end : Float;
	var sp : Float;

	public function new( mc : SP, to : Float, sp=0.1 ){
		super();
		this.mc = mc;
		this.start = mc.alpha;
		this.end = to;
		this.sp = sp;
	}

	override function update(){
		super.update();
		coef = Math.min(coef + sp, 1);
		var c = curve(coef) ;

		mc.alpha = start + (end-start) * c;
	
		if( coef == 1 ) kill();
	}


}
