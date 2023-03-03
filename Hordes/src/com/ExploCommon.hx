package ;

//===============  EXPLORATION
typedef ExploInit = {
	_k		: Int, //kind of explo (building type)
	_w		: Int,
	_h		: Int,
	_mid	: Int, // mapId
	_zid	: Int, // zoneId
	_r		: ExploResponse,
	_d		: Bool, // if there's dog, we show direction to exit
}

typedef ExploCellDetail = {
	_seed	: Int, // éléments de déco
	_room	: Null<ExploRoom>, // room
	_z		: Int, // nombre de zombis
	_k		: Int, // nombre de zombis morts
	_w		: Bool, // walkable
	_exit	: Bool, // si c'est une sortie
}

typedef ExploResponse = {
	_x		: Int, //arrival coordinate
	_y		: Int,
	_d		: ExploCellDetail, // room details
	_o		: Int, // remaining oxygen
	_r		: Bool, //in room ?
	_dirs	: Array<Bool>,
	_move	: Bool,
}

typedef ExploRoom = {
	_locked : Bool,
	_door	: Int,
}

class ExploCommon {

	/*------------------------------------------------------------------------
	CREATES THE CODEC KEY
	------------------------------------------------------------------------*/
	static function getRSeed() {
		return new mt.Rand(256*(9+590+5));
	}

	public static function genKey(len:Int) {
		var str = new StringBuf();
		var rseed = getRSeed();
		for (i in 0...len) {
			str.addChar(65+rseed.random(50));
		}
		return str.toString();
	}
	
	#if !js
	public static function encode(s:String) {
		var codec = new mt.net.Codec(genKey(s.length));
		return StringTools.urlEncode( permute(codec.run(s)) );
	}

	public static function decode(s:String) {
		var codec = new mt.net.Codec(genKey(s.length));
		return codec.run(permute(s));
	}
	#end

	static function permute(s:String) {
		var rseed = getRSeed();
		var arr = s.split("");
		var i = 0;
		var changes = new Array();
		while (i<arr.length) {
			var swap = rseed.random(arr.length);
			if ( changes[swap]==null && changes[i]==null ) {
				var tmp = arr[swap];
				arr[swap] = arr[i];
				arr[i] = tmp;
				changes[i] = true;
				changes[swap] = true;
			}
			i++;
		}
		return arr.join("");
	}

}