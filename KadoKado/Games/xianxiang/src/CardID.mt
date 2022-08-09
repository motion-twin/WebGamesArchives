class CardID {	

	var color : int;
	var symbol : int;
	var socle : int;

	static function random() : CardID {
		return new CardID(Std.random(3),Std.random(4),Std.random(5));
	}

	function new(so,c,sy) {
		this.color = c;
		this.symbol = sy;
		this.socle = so;
	}

	function matchs( id : CardID ) {
		return
			((id.color == color)?1:0) +
			((id.symbol == symbol)?1:0) +
			((id.socle == socle)?1:0);
	}

	function toString() {
		return socle+"-"+color+"-"+symbol;
	}

}