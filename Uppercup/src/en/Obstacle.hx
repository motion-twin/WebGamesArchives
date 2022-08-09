package en;

import TeamInfos;

class Obstacle extends Entity {
	public static var ALL : Array<Obstacle> = [];
	var offX		: Float;
	var offY		: Float;

	public function new(p:Perk) {
		super();

		offX = offY = 0;

		ALL.push(this);

		do {
			cx = Const.FPADDING + rseed.irange(8, Const.FWID-8);
			cy = Const.FPADDING + rseed.irange(2, Const.FHEI-2);
		} while( hasObstacleAround() );
		xr = yr = 0.5;

		game.stadium.colMap[cx][cy] = Const.OBSTACLE_HEIGHT;
		var f = 0;
		switch(p) {
			case _PPumpkins :
				f = 0;
				game.stadium.colMap[cx+1][cy] = Const.OBSTACLE_HEIGHT;
				offX = Const.GRID*0.6;

			case _PRocks :
				f = 1;
				offY = -10;
				game.stadium.colMap[cx][cy-1] = Const.OBSTACLE_HEIGHT;

			case _PLifeBelts :
				f = 2;
				offX = Const.GRID*0.5;
				offY = -11;
				var h = 0.4;
				game.stadium.colMap[cx][cy] = Const.OBSTACLE_HEIGHT * h;
				game.stadium.colMap[cx][cy-1] = Const.OBSTACLE_HEIGHT * h;
				game.stadium.colMap[cx+1][cy-1] = Const.OBSTACLE_HEIGHT * h;
				game.stadium.colMap[cx+1][cy] = Const.OBSTACLE_HEIGHT * h;

			case _PAnvils :
				f = 3;
				offX = -2;
				offY = -8;
				game.stadium.colMap[cx][cy-1] = Const.OBSTACLE_HEIGHT;

			default :
				throw "unknown obstacle "+p;
		}
		spr.set("item_colision", f);
		spr.setCenter(0.5, 0.45);
		removeShadow();

		if( game.round>0 )
			spr.alpha = 0;
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

	override public function update() {
		super.update();
		if( spr.alpha<1 ) {
			spr.alpha+=0.1;
			if( spr.alpha>1 )
				spr.alpha = 1;
		}

		spr.x += offX;
		spr.y += offY;
	}
}