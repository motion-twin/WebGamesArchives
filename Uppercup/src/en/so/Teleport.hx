package en.so;

import TeamInfos;

class Teleport extends en.SpecialObstacle {
	static var ALL : Array<Teleport> = [];

	public function new() {
		super();

		ALL.push(this);
		radius = Const.GRID*1.2;
		zpriority = -999;

		spr.set("teleport");
		spr.setCenter(0.5,0.5);

		//spr.graphics.beginFill(0xFFFF00,1);
		//spr.graphics.drawCircle(0,0, radius);

		removeShadow();
	}


	override function unregister() {
		super.unregister();
		ALL.remove(this);
	}

	function getNext() {
		var targets = mt.deepnight.Lib.shuffle(ALL.filter(function(e) return e!=this), rseed.random);
		return targets[0];
	}

	function onTeleportComplete() {
		var b = game.ball;
		var a = rnd(0, 6.28);
		var s = rnd(0.3, 0.6);
		b.dx = Math.cos(a)*s;
		b.dy = Math.sin(a)*s;
		b.dz = rnd(3,5);
		b.backInGame();
		b.cd.set("teleport", 10, true);
		b.makeUncatchableBoth(10);
		fx.flashBang(0x0080FF, 0.6, 1000);
		fx.teleport(b, false);
		m.Global.SBANK.teleport_out(1);
	}

	override function onTouchBall() {
		var b = game.ball;
		if( b.cd.has("teleport") )
			return;

		super.onTouchBall();

		var t = getNext();
		if( t==null )
			return;

		b.cd.set("teleport", 9999);
		b.leaveGame();

		b.dx = b.dy = 0;
		b.dz = 2;
		b.z = 5;
		b.setPosFree(t.xx, t.yy);
		game.delayer.add( function() {
			onTeleportComplete();
		}, 200);

		m.Global.SBANK.teleport_in(1);
		fx.teleport(b, true);
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