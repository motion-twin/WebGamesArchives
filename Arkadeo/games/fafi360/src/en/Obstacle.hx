package en;

class Obstacle extends Entity {
	public function new(frame:Int) {
		super();
		
		game.miscEntities.push(this);
		
		var mc = new lib.Item_colision();
		spr.addChild(mc);
		mc.gotoAndStop(frame);
		#if debug
		mc.alpha = 0.4;
		#end
		
		do {
			cx = Game.FPADDING + rseed.irange(8, Game.FWID-8);
			cy = Game.FPADDING + rseed.irange(2, Game.FHEI-2);
		} while( hasObstacleAround() );
		xr = yr = 0.5;
		
		game.colMap[cx][cy] = 20;
		switch(frame) {
			case 1 : // missile
				mc.x += 1;
				mc.y += 5;
				var smc = new lib.MissileTrainee();
				smc.x = (cx+xr)*Game.GRID;
				smc.y = (cy+yr)*Game.GRID + 6;
				
				game.ground.draw(smc, smc.transform.matrix);
			case 2 : // citrouille
				mc.x += 9;
				mc.y += 5;
				game.colMap[cx+1][cy] = 20;
			case 5 : // rocher
				mc.x += 1;
				mc.y += 4;
				
			case 7 : // bouée
				mc.x += 8;
				mc.y += 12;
				game.colMap[cx+1][cy] = 20;
				
			case 8 : // enclume
				mc.x += 1;
				mc.y += 4;
		}
		
		if( game.round>0 ) {
			spr.alpha = 0;
			fx.smokePop(xx,yy);
		}
		#if debug
		game.drawCollisions();
		#end
	}
	
	function hasObstacleAround() {
		for(e in game.miscEntities)
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
	}
}