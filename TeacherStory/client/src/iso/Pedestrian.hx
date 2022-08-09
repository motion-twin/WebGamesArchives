package iso;

class Pedestrian extends Iso {
	var goingLeft		: Bool;
	
	public function new() {
		super();
		
		zpriority = 13;
		cx = cy = -5;
		fl_static = false;
		minSpeed = 0;
		goingLeft = true;

		#if !debug
		cd.set("new", 30*mt.deepnight.Lib.rnd(30, 60));
		#end
	}
	
	public function newOne() {
		sprite.removeChildren();
		
		goingLeft = Std.random(2)==0;
		goingLeft = true;
		
		speed = mt.deepnight.Lib.rnd(0.04, 0.08);
		
		if( goingLeft ) {
			var mc = new lib.PassantFace();
			mc.gotoAndStop( Std.random(mc.totalFrames)+1 );
			sprite.addChild(mc);
			mc.y+=33;
		}
		else {
			var mc = new lib.PassantFace();
			mc.gotoAndStop( Std.random(mc.totalFrames)+1 );
			sprite.addChild(mc);
			mc.y+=33;
		}
		
		setPos(Const.RWID+1, goingLeft ? -2 : Const.RHEI+2);
		gotoXY( cx, goingLeft ? Const.RHEI+2 : -2 );
	}
	
	
	public override function onArrive() {
		super.onArrive();
		cd.set("new", 30*mt.deepnight.Lib.rnd(40,90));
	}
	
	override function getInCasePos() {
		return {xr:0.42, yr:0.5}
	}
	
	public override function update() {
		super.update();

		if( !man.gameStarted )
			return;
		
		if( !cd.hasSet("new", 99999) )
			newOne();
	}
	
}

