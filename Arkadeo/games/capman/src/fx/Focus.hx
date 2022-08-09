package fx;
import mt.bumdum9.Lib;
import Protocol;


class Focus extends mt.fx.Fx {//}

	public var root:SP;
	var startRay:Float;
	var endRay:Float;
	var thc:Float;
	var spc:Float;
	public function new(startRay, endRay, spc=0.1, thc = 1.0 ) {
		super();
		this.startRay = startRay;
		this.endRay = endRay;
		this.thc = thc;
		this.spc = spc;
		

		
		root = new SP();
		
	
		
	}
	
	override function update() {
		super.update();
		coef = Math.min(coef + spc, 1);
		var co = curve(coef);
		
		var lim = 16;
		var color = Col.hsl2Rgb((Game.me.gtimer % lim) / lim);
		
		var ray = startRay + (endRay - startRay)* co;
		
		root.graphics.clear();
		root.graphics.beginFill(color);
		root.graphics.drawCircle(0, 0, ray );
		
		
		//var ray2 = (ray * thc) * co + (ray * co) * (1 - thc);
		
		
		
		var a = ray * (1 - thc);
		var b = ray;
		var ray2 = a + (b - a) * co;
		//trace(thc + ":" + a);
		
	//	var ray2 = ray * ( (1 - thc) + co - co * (1 - thc) );
		//var ray2 = ray * ( (1 - thc) + co - (co - co*thc) );
		var cco = 1-Math.sin(co * 3.14);
		var ray2 = ray * ( (1 - thc) + cco * thc );
		
		
		root.graphics.drawCircle(0, 0, ray2);
		root.graphics.endFill();
		
		
		
		
		
		if( coef == 1 ) kill();
	}
	
	public function setPos(nx, ny) {
		root.x = nx;
		root.y = ny;
	}
	
	override function kill() {
		super.kill();
		root.parent.removeChild(root);
	}
	
	
//{
}












