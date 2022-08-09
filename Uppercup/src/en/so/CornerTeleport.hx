package en.so;

import TeamInfos;

class CornerTeleport extends en.so.Teleport {
	static var ALL : Array<CornerTeleport> = [];

	var peerId			: Int;

	public function new(x,y,peer) {
		super();

		ALL.push(this);
		peerId = peer;
		radius = Const.GRID*4;
		zpriority = -999;

		spr.set("cornerTeleport");

		cx = Const.FPADDING+5;
		cy = Const.FPADDING+5;
		if( x==1 ) cx = Const.FPADDING+Const.FWID-6;
		if( y==1 ) cy = Const.FPADDING+Const.FHEI-6;
		setPos(cx,cy);

		removeShadow();
	}


	override function unregister() {
		super.unregister();
		ALL.remove(this);
	}

	override function onTeleportComplete() {
		super.onTeleportComplete();
		var b = game.ball;
		var pr = b.getPositionRatio();
		var s = rnd(0.3, 0.5);
		b.dx = rnd(0.2, 0.3);
		b.dy = rnd(0.2, 0.3);
		if( pr.x>0.5 )
			b.dx *= -1;
		if( pr.y>0.5 )
			b.dy *= -1;
		//var a = rnd(0, 6.28);
		//b.dx = Math.cos(a)*s;
		//b.dy = Math.sin(a)*s;
		b.cd.set("teleport", 30, true);
	}

	override function getNext() {
		var targets = ALL.filter(function(e) return e.peerId==peerId && e!=this);
		return targets[0];
	}
}