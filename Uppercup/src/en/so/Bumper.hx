package en.so;

import TeamInfos;

class Bumper extends en.SpecialObstacle {
	public function new() {
		super();

		radius = Const.GRID*1.2;

		spr.set("bumper");
		spr.setCenter(0.5,0.5);

		removeShadow();
	}


	override function unregister() {
		super.unregister();
	}

	override function onTouchBall() {
		super.onTouchBall();
		var b = game.ball;
		cd.set("touch", Const.seconds(0.3));
		var a = Math.atan2(b.yy-yy, b.xx-xx) + rnd(0, 1, true);
		var s = 0.95;
		b.dx = Math.cos(a)*s;
		b.dy = Math.sin(a)*s;
		b.dz *= 0.5;
		b.makeUncatchable(0, rnd(1,15));
		b.makeUncatchable(1, rnd(1,15));
		b.loseElectricCounter();
		m.Global.SBANK.bumper(1);
		spr.setFrame(1);
		game.delayer.add(function() {
			spr.setFrame(0);
		}, rnd(7, 10));
	}


	override public function update() {
		super.update();
		//if( spr.alpha<1 ) {
			//spr.alpha+=0.1;
			//if( spr.alpha>1 )
				//spr.alpha = 1;
		//}
//
		//spr.x += offX;
		spr.y += 0;
	}
}