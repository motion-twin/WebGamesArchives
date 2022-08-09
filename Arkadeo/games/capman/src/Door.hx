import mt.bumdum9.Lib;
import Protocol;


class Door extends EL{//}

	public var square:Square;
	public var dir:Int;
	
	public function new(?sq) {
		
		super();
		square = sq;
		
		// BEST LOC
		if( square == null ){
			var a = Game.me.squares.copy();
			Arr.shuffle(a, Game.me.seed);
			var best = -1;
			for( sq in a ) {
				var score = sq.getDoorScore();
				if( score > best ) {
					best = score;
					square = sq;
				}
			}
			if( square == null ) throw("error");
		}

		// OPEN ALL
		square.open(0);
		square.open(1);
		square.dnei[0].open(1);
		square.dnei[1].open(0);
		
		
		// GFX
		var pos = Square.getPos(square.x + 1, square.y + 1);
		goto("door");
		x = pos.x;
		y = pos.y;
		Level.me.dm.add(this, Level.DP_GROUND);
		
		// LINK
		var sq = square;
		for( di in 0...4 ) {
			sq.door = this;
			sq.doorDir = di;
			sq = sq.dnei[di];
		}
		
		
		//
		setDir(0);
	}
	public function setDir(di) {
		dir = di;
		rotation = dir * 90;
		
		// WALL
		var sq  = square;
		for( i in 0...2 ) {
			sq.setWall( 1-di, 2);
			sq = sq.dnei[di];
		}
		
		// UNWALL
		var sq  = square;
		for( i in 0...2 ) {
			sq.setWall( di, 0);
			sq = sq.dnei[1-di];
		}
		
		
		
	}
	
	public function flip(clockwise) {
		new fx.FlipDoor(this,clockwise);
		//new mt.fx.Flash(this);
	}
	
	
	override function kill() {
		super.kill();
		// UNLINK
		var sq = square;
		for( di in 0...4 ) {
			sq.door = null;
			sq.setWall(di, 0);
			sq.majGfx();
			sq = sq.dnei[di];
		}
		
		
	}
	
	
//{
}












