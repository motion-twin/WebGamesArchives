enum BE {
	Rock;
	Dino( id : Int, side : Bool, gfx : String, move : Int, pv : Int, pvMax : Int );
}

enum BH {
	BAdd( id : Int, side : Bool, gfx : String, x : Int, y : Int, pv : Int, pvMax : Int );
	BMove( id : Int, x : Int, y : Int );
	BRemove( id : Int );
	BFight( id : Int, ids : Array<Int>, fid : Int );
	BLife( id : Int, pv : Int );
	BKill( id : Int );
	BPoints( p1 : Int, p2 : Int );
}

typedef BattleData = {
	var _id : Int;
	var _t : Array<Array<BE>>;
	var _dino : String;
	var _move : String;
	var _fight : String;
	var _view : String;
	var _hist : Array<BH>;
	var _phist : Array<String>;
	var _hpos : Int;
	var _htot : Int;
	var _wait : String;
}