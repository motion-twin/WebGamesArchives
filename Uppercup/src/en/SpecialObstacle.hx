package en;

import mt.deepnight.Lib;

class SpecialObstacle extends Entity {
	public static var ALL : Array<SpecialObstacle> = [];
	var offX		: Float;
	var offY		: Float;
	var radius		: Float;

	public function new() {
		super();

		radius = Const.GRID*0.7;
		offX = offY = 0;

		ALL.push(this);

		do {
			cx = Const.FPADDING + rseed.irange(8, Const.FWID-8);
			cy = Const.FPADDING + rseed.irange(2, Const.FHEI-2);
		} while( hasObstacleAround() );
		xr = yr = 0.5;

		game.sdm.add(spr, Const.DP_BG1);
		game.zsortables.remove(this);

		//removeShadow();
	}


	override function unregister() {
		super.unregister();
		ALL.remove(this);
	}


	function hasObstacleAround() {
		for(e in ALL)
			if( e!=this && Math.abs(cx-e.cx)<=2 && Math.abs(cy-e.cy)<=2 )
				return true;
		return false;
	}

	function onTouchBall() {
	}

	override public function update() {
		super.update();

		if( !game.ball.hasOwner() && game.ball.z<=Const.OBSTACLE_HEIGHT && distanceSqr(game.ball)<=radius*radius && !cd.has("touch") )
			onTouchBall();
		//if( spr.alpha<1 ) {
			//spr.alpha+=0.1;
			//if( spr.alpha>1 )
				//spr.alpha = 1;
		//}
//
		//spr.x += offX;
		//spr.y += offY;
	}
}