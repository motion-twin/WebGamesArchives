package fx;
import mt.bumdum9.Lib;

class Sparkling extends Fx{//}


	public var timer:Int;
	public var freq:Int;
	public var ray:Float;
	public var anim:String;
	var root:flash.display.Sprite;
	
	
	public function new(mc, time=10, frequence=1) {
		super();
		root = mc;
		timer = time;
		freq = frequence;
		ray = 10;
		anim = "spark_onde";
	}
	
	override function update() {
		if( !root.visible ) return;
		if( timer % freq == 0 ) spark();
		if( timer-- == 0 ) kill();
	}
	
	function spark() {
		
		var p = Stage.me.getPart(anim);
		p.x = root.x + (Math.random() * 2 - 1) * ray;
		p.y = root.y + (Math.random() * 2 - 1) * ray;
		p.weight = -(0.1 + Math.random() * 0.2);
		p.sprite.blendMode = flash.display.BlendMode.ADD;
	}
	
		

//{
}