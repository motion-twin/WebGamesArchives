package fx;
import Protocole;

class Volt extends Fx {//}
	
	var sprite:flash.display.Sprite;
	public var coef:Float;
	public var spc:Float;
	public var rx:Float;
	public var ry:Float;

	public function new(sp,rx=10.0,ry=10.0,spc=0.1) {
		super();
		this.spc = spc;
		this.rx = rx;
		this.ry = ry;
		
		sprite = sp;
		coef = 0 ;
		
	}
	
	override function update() {
		super.update();
	
		coef = Math.min(coef + spc, 1);
		
		if( Math.random() > coef ) {
			
			var p = Stage.me.getPart("volt");
			p.x = sprite.x + Math.random()*2*rx - rx;
			p.y = sprite.y + Math.random() * 2 * ry - ry;
			p.randMirror();
			
			
		}
		
		
		if( coef == 1 ) kill();
		
		
	}
	

	
//{
}












