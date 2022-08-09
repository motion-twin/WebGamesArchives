package iso;

class Bike extends Iso {
	public var running	: Bool;
	
	public function new() {
		super(Const.RWID+2,-10);
		running = false;
		accel = 0.03;
		minSpeed = 0;
		zpriority = 20;
		fl_static = false;
		
		var mc = new lib.Bike();
		sprite.addChild(mc);
		mc.y+=29;
		
		if( man.subject==Common.Subject.S_Science || Type.getClass(man.helper)==iso.h.Eddy )
			cd.set("start", 999999);
		else
			cd.set("start", 30*mt.deepnight.Lib.rnd(80, 150));
	}
	
	
	public function start() {
		if( man.bus.running )
			return;
		cd.set("start", 99999);
		running = true;
		setPos( cx, -10 );
		man.delayer.add( function() {
			Manager.SBANK.moto().play(0.2, 0.6);
		}, 700);
		gotoXY( cx, Const.RHEI+8 );
	}
	
	public override function onArrive() {
		super.onArrive();
		cd.set("start", 30*mt.deepnight.Lib.rnd(80, 150));
		running = false;
	}
	
	public override function update() {
		super.update();
		
		if( !man.gameStarted )
			return;
		
		if( !cd.has("start") )
			start();
		if( running && !Const.LOWQ )
			man.fx.scooterSmoke(sprite.x+15, sprite.y+20, 0x0, 1.5);
	}
	
}


