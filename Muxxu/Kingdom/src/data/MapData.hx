package data;

enum GState {
	GWait;
	GBattle( attack : Bool );
	GFortify;
	GMove( to : Int, k : Int );
}

typedef MapData = {
	var _x : Int;
	var _y : Int;
	var _selectUrl : String;
	var _moveUrl : String;
	var _infUrl : String;
	var _infos : Array<{ _u : Null<String>, _s : Int }>;
	var _ter : List<Int>;
	var _vas : List<Int>;
	var _gen : Array<{ _id : Int, _p : Int, _n : String, _u : String, _s : GState, _c : Int }>;
	var _move : String;
	var _moveto : String;
	var _nob : String;
	var _adm : Bool;
	var _cross : Array<String>;
}

typedef MiniMapData = {
	var width : Int;
	var height : Int;
	var bytes : haxe.io.Bytes;
	var x : Int;
	var y : Int;
	var viewX : Int;
	var viewY : Int;
	var selX : Int;
	var selY : Int;
}