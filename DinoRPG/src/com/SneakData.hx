package ;

enum _SneakCommandKind {
	SFight(fid:Int);
	STalk(fid:Int);
	SBegin;
	SFinish;
	SUseIrma;
	SCheck;
	//TODO add here
}

typedef SneakCommand = {
	var _l : String;
	var _k : _SneakCommandKind;
	var _x : Int;
	var _y : Int;
}

typedef SneakTileConfig = {
	var _walkable	: Bool;
	var _hideout	: Bool;
	var _movable 	: Bool;
	var _penality	: Int;
}

typedef SneakTileConfigs = {
	var _normal : SneakTileConfig;
	var _small 	: SneakTileConfig;
	var _wall	: SneakTileConfig;
	var _block 	: SneakTileConfig;
}

typedef SneakConfig = {
	var _fps 			: Int;
	var _key 			: String;
	var _playerSpeed 	: Float;
	var _tileWidth 		: Int;
	var _tileHeight 	: Int;
	var _worldTileWidth : Int;
	var _worldTileHeight: Int;
	var _viewportWidth 	: Int;
	var _viewportHeight : Int;
	var _configs 		: SneakTileConfigs;
	var _tiles 			: Array<{_ids:Array<Int>, _conf:SneakTileConfig}>;
	var _opaque			: Array<Int>;
	var _shuffle		: Array<{_id:Int, _values:Array<Int>}>;
	var _path			: { _begin:Int, _path:Int };
	var _enemyClass		: String;
}

typedef SneakInfos = {
	var _x 		: Int;
	var _y 		: Int;
	var _deads	: Array<Int>;
	var _fights	: Array<Int>;
	var _talks	: Array<Int>;
}

typedef SneakData = {
	var _config	: SneakConfig;
	var _sdino	: String;
	var _url	: Null<String>;
	var _baseUrl: String;
	var _level	: String;
	var _gfx 	: String;
	var _inf	: SneakInfos;
}

enum _SResponse {
	SOk;
	SUrl( url : String );
	SMessage( s : String, url : String );
	SNoAction( s : String );
	//TODO add here
}