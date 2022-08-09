package iso.h;

class Eddy extends iso.Helper {
	var wspots : Array<{cx:Int, cy:Int}>;
	
	public function new() {
		super(Eddy);
		speed*=0.5;
		init( cast new lib.EddyStand() );
		wspots = [
			{cx:3, cy:9},
			{cx:4, cy:10},
			{cx:3, cy:9},
			{cx:7, cy:8},
			{cx:5, cy:8},
			{cx:Const.RWID-2, cy:8},
			{cx:Const.RWID-1, cy:9},
			{cx:Const.BOARD.x-1, cy:Const.BOARD.y},
			{cx:5, cy:1},
		];

	}
		
	override function update() {
		super.update();
		if( active && man.gameStarted && !cd.hasSet("wander", 30*mt.deepnight.Lib.rnd(4,11)) ) {
			var pt = wspots[Std.random(wspots.length)];
			while( pt.cx==cx && pt.cy==cy )
				pt = wspots[Std.random(wspots.length)];
			gotoXY(pt.cx, pt.cy);
		}
	}
}

