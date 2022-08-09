package seq;
import mt.bumdum9.Lib;

class Play extends mt.fx.Sequence {

	var squares:Array<Square>;
	
	public function new() {
		super();
		squares = Game.me.squares.copy();
		Arr.shuffle(squares, Game.me.seed);
		squares = squares.splice(0, Cs.FIRST_FILL);
		squares.sort(sort);
	}
	
	function sort(a:Square, b:Square) {
		if( a.x < b.x )	return -1;
		else			return 1;
	}
	
	function init() {
		nextStep();
		Game.me.newTurn();
	}
	
	override function update() {
		super.update();
		switch(step) {
			case 0 : // FILL
				if( squares.length > 0 ) {
					var sq = squares.pop();
					var b = new ent.Ball();
					b.setSquare(sq);
					b.register();
					b.updatePos();
					var e = new fx.ScaleIn(b);
				} else {
					init();
				}
			case 1 : // MAIN LOOP
				//ZSORT
				var freq = Game.me.ents.length >> 3;
				if( Game.me.gtimer % freq == 0 || Game.me.forceZSort ) {
					Game.me.ents.sort(zSort);
					Game.me.forceZSort = false;
					for( e in Game.me.ents )
						Game.me.dm.over(e.root);
				}
		}
	}
	
	function zSort(a:Ent, b:Ent ) {
		var aa = a.y * 1000 + a.x;
		var bb = b.y * 1000 + b.x;
		if( aa < bb ) 		return -1;
		else if( aa > bb ) 	return 1;
		else 				return 0;
	}
}
