package iso;

class Livreur extends Iso {
	var mc			: lib.Livreur;
	var hasPackage	: Bool;
	
	public function new() {
		super();
		hasPackage = true;
		
		mc = new lib.Livreur();
		sprite.addChild(mc);
		mc.y+=25;
		mc.scaleX = -1;
		setAnim("stand");
		//zpriority = -1;
	
		setPos(Const.EXIT);
		fl_static = false;
		//minSpeed = 0;
		speed = 0.3;
		//cd.set("start", 30*mt.deepnight.Lib.rnd(10, 20));
	}
	
	public function setPackage(b:Bool) {
		hasPackage = b;
		setAnim();
	}
	
	public override function goto(pt, ?speedMul=1.0) {
		super.goto(pt, speedMul);
		setAnim("walk");
	}
	
	public function sayDelivered() {
		var teacher = man.teacher;
		var tg = man.tg;
		if( teacher.data.level<=5 )
			ambiant(tg.m_deliver1());
		else if( teacher.data.level<=12 )
			ambiant(tg.m_deliver2());
		else if( teacher.data.level<=16 )
			ambiant(tg.m_deliver3());
		else
			ambiant(tg.m_deliver4());
	}
	
	public function setAnim(?k="stand") {
		if( hasPackage )
			k+="C";
		mc.gotoAndStop(k);
		try {
			var smc : flash.display.MovieClip = Reflect.field(mc._sub, "_sub");
			smc.stop();
		}catch(e:Dynamic) {}
	}
	
	override function onArrive() {
		super.onArrive();
		setAnim();
		man.cm.signal("livreur");
	}
	
	//public function setDir(dx:Int) {
		//mc.scaleX = dx>0 ? 1 : -1;
	//}
	
}

