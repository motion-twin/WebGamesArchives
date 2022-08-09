package seq;
import mt.bumdum9.Lib;
import Protocol;

class SpitCoins extends mt.fx.Sequence {

	var list:Array<Square>;
	var source:Square;
	
	public function new() {
		super();
		source = Game.me.hero.square;
		list = [];
		Game.me.buildDistFrom(Game.me.hero.square, true);
		for( sq in Game.me.squares ) if( sq.coin == null && !sq.isBlock() ) list.push(sq);
		list.sort(order);
	}
	
	function order(a:Square, b:Square) {
		if( a.hdist < b.hdist ) return 1;
		return -1;
	}
	
	override function update() {
		super.update();
		for( i in 0...3 ){
			var e = new fx.RunningCoin(source, list.pop());
			var coef = 1-timer / 10;
			if( coef > 0 ) e.spc += coef * 0.75;
			if( list.length == 0 ) break;
		}
		if( list.length == 0 ) kill();
	}
}

