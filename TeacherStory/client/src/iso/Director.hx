package iso;

class Director extends Iso {
	var mc			: lib.Dirlo;
	
	public function new() {
		super();
		
		mc = new lib.Dirlo();
		sprite.addChild(mc);
		mc.y+=25;
		zpriority = -1;
	
		setPos(-2,-10);
		fl_static = false;
		minSpeed = 0;
		speed = 0.028;
		cd.set("start", 30*mt.deepnight.Lib.rnd(10, 20));
	}
	
	
	public function start() {
		setPos( cx, -7 );
		gotoXY( cx, Const.RHEI+8 );
	}
	
	public override function onArrive() {
		super.onArrive();
		cd.set("start", 30*mt.deepnight.Lib.rnd(1,2));
	}
	
	public override function update() {
		super.update();
		if( !cd.has("start") )  {
			cd.set("start", 99999);
			start();
		}
	}
	
}

