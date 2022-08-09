package iso;

import mt.deepnight.Sfx;

class Bus extends Iso {
	var cm			: mt.deepnight.Cinematic;
	var mc			: lib.Bus;
	var frame		: Float;
	public var running	: Bool;
	
	
	public function new() {
		super(Const.RWID+3,-10);
		running = false;
		frame = 0;
		accel = 0.03;
		minSpeed = 0;
		zpriority = 20;
		fl_static = false;
		
		cm = new mt.deepnight.Cinematic();
		
		mc = new lib.Bus();
		sprite.addChild(mc);
		mc.y+=29;
		mc._sub.stop();
	
		cd.set("start", 30*mt.deepnight.Lib.rnd(40, 120));
	}
	
	
	public function start() {
		if( man.bike.running )
			return;
		cd.set("start", 99999);
		running = true;
		cm.create({
			2000>>Manager.SBANK.busBrake().play(0.3, 0.6);
			setPos( cx, -10 );
			speed = 0.13;
			gotoXY( cx, -1 );
			4500 >> Manager.SBANK.busBrake().play(0.2, 0.6);
			5000;
			speed = 0.25;
			Manager.SBANK.busStart().play(0.1, 0.6).tweenPanning(-0.5, 5000);
			gotoXY( cx, 25 );
			6500;
			cd.set("start", 30*mt.deepnight.Lib.rnd(40, 120));
			running = false;
		});
	}
	
	public override function update() {
		super.update();
		
		if( !man.gameStarted )
			return;
		
		if( !cd.has("start") )
			start();
			
		cm.update();
		if( Const.LOWQ ) {
			mc.stop();
		}
		else {
			mc.play();
			var s = getScreenSpeed();
			frame+=s*6;
			while(frame>1 ) {
				frame--;
				if( mc._sub.currentFrame==mc._sub.totalFrames )
					mc._sub.gotoAndStop(1);
				else
					mc._sub.nextFrame();
			}
		}
	}
	
}

