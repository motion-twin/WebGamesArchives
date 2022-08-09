package data;

enum PuzzlePiece {
	PFood;
	PGold;
	PWood;
	PBuild;
	PSoldier;
	PPeople;
	PGather;
	PAgain;
}

typedef PuzzleData = {
	var _s : Int;
	var _t : Array<Array<Int>>;
	var _url : String;
	var _act : Int;
	var _reload : String;
}

typedef PuzzleCommand = {
	var _s : Int;
	var _x : Int;
	var _y : Int;
	var _h : Bool;
}

typedef PuzzleAnswer = {
	var _fill : Array<Array<Int>>;
	var _res : Array<Array<Int>>;
	var _url : Null<String>;
}
