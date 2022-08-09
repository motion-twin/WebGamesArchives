package data;

enum BattleHistory {
	BKill( cid : Int, kind : Int );
	BJoin( cid : Int, count : Int, def : Bool );
	BQuit( cid : Int, count : Int );
	BFlee( cid : Int, count : Int );
	BUnitsLeave( cid : Int, count : Int );
	BUnitsAdd( cid : Int, count : Int );
	BDie( cid : Int );
	BWin( def : Bool );
}

typedef BattleUnit = {
	var cid : Int;
	var kind : Int;
	var life : Int;
}

typedef BattleCamp = {
	var id : Int; // db.Unit
	var gid : Null<Int>; // db.General
	var def : Bool; // true|false
	var kill : Int;
	var units : Array<{ f : Int, l : Array<Int>, k : Int }>; // #fighting in pairs, and lifes of pending units
}

typedef Battle = {
	var ids : IntHash<{ u : Null<Int>, g : Null<String>, k : Null<Bool> }>; // k = true(defense) | false(general) | null(garnison)
	var history : Array<{ t : Float, h : BattleHistory }>;
	var camps : Array<BattleCamp>;
	var pairs : List<{ u1 : BattleUnit, u2 : BattleUnit }>;
	var provoke : Bool;
}

typedef BattleUnitData = {
	var _c : Int;
	var _k : Int;
	var _l : Int;
}

typedef BattleData = {
	var _campUrl : String;
	var _lifes : Array<Int>;
	var _camps : Array<{ _id : Int, _def : Bool, _units : Array<Array<Int>> }>;
	var _pairs : List<{ _u1 : BattleUnitData, _u2 : BattleUnitData }>;
}