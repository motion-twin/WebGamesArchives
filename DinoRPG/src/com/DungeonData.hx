
enum _DIcon {
	DINothing;
	DIBlock;
	DIIcon( i : String );
	DIMonster( m : String );
}

typedef DungeonData = {
	var _d : String;
	var _x : Int;
	var _y : Int;
	var _l : Int;
	var _ldelta : Int;
	var _dir : Bool;
	var _sdino : String;
	var _smonster : String;
	var _fog : haxe.io.Bytes;
	var _flags : Array<Int>;
	var _keys : Array<Bool>;
	var _group : Array<{ _n : String, _g : String }>;
	var _monsters : Array<String>;
	var _url : String;
	var _lock : Bool;
	var _skin : String;
	var _sicons : Array<_DIcon>;
	var _tower : Bool;
	var _text : Null<String>;
	var _tlvl : String;
}

typedef DungeonCommand = {
	var _x : Int;
	var _y : Int;
	var _l : Int;
	var _dx : Int;
	var _dy : Int;
	var _dl : Int;
}

enum _DResponse {
	DOk;
	DUrl( url : String );
	DMessage( s : String, ?icon : String, ?url : String );
}
