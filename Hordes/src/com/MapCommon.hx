typedef OutMapResponse = {
	_zid		: Int, // arrival zone id
	_c			: Int, // arrival cell
	_z			: Int, // zombies
	_h			: Int, // humans
	_t			: Int, // info tag
	_state		: Bool,
	_m			: Int, // moves
	_neig		: Array<Int>, // detection chances (scout) on nearby sectors
	_neigDrops	: Array<Bool>, // detection chances (scout) on nearby sectors
}

typedef OutMapInit = {
	_w		: Int,
	_h		: Int,
	_x		: Int,
	_y		: Int,
	_b		: Array<OutMapBuildings>,
	_view	: Array<Int>,
	_global	: Array<Int>,
	_mid	: Int, // mapId
	_city	: String,
	_map	: Bool,
	_up		: Bool,
	_details: Array<OutMapDetail>,
	_hour	: Int, // 0-23
	_r		: OutMapResponse,
	_town	: Bool,
	_e		: Array<OutMapExpeditions>,
	_path	: String, // only used for expeditions editing
	_editor	: Bool,
	_slow	: Bool,
	_users	: Array<OutMapCitizen>,
}

typedef OutMapCitizen = {
	_x		: Int,
	_y		: Int,
	_n		: String,
}

typedef OutMapBuildings = {
	_id		: Int,
	_n		: String,
}

typedef OutMapDetail = {
	_z		: Int, // zombies
	_c		: Int, // cell content
	_t		: Int, // info tag
	_nvt	: Bool, // nvt = not visited today
	_s 		: Bool, // souls
}

typedef OutMapExpeditions = {
	_i		: Int,		// id
	_n		: String,	// name
	_p		: String,	// path
}


class MapCommon {
	public static var CoordSep = ":";
	public static var GroupSep = "|";
	public static var MaxPathStringLength = 240;

	/*------------------------------------------------------------------------
	CREATES THE CODEC KEY
	------------------------------------------------------------------------*/
	static function getRSeed() {
		return new mt.Rand(984 * (2564 + 5));
	}

	public static function genKey(len:Int) {
		var str = new StringBuf();
		var rseed = getRSeed();
		for( i in 0...len ) {
			str.addChar(65 + rseed.random(50));
		}
		return str.toString();
	}

	static function permute(s:String) {
		var rseed = getRSeed();
		var arr = s.split("");
		var i = 0;
		var changes = new Array();
		while( i < arr.length ) {
			var swap = rseed.random(arr.length);
			if( changes[swap] == null && changes[i] == null ) {
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

	public static function zombieDanger(seed:Int, z:Int, fl_exact:Bool) {
		if( z == 0 ) return 0;
		if( fl_exact ) return Math.floor( (z-1)/2 );
		var rseed = new mt.Rand(seed);
		switch( rseed.random(3) ) {
			case 0	: if(z > 3) z-- else z++; // -1
			case 1	: z++; // +1
			default	: // no distortion
		}
		return Std.int( Math.min( 2, Math.floor( (z - 1) / 2 ) ) ); // 0, 1 or 2
	}

	public static function getPathLength(plist:Array<{x:Int, y:Int}>) {
		var prev = null;
		var len = 0;
		for( pt in plist ) {
			if( prev != null && pt.x != null && pt.y != null ) {
				len += Math.floor( Math.abs(pt.x - prev.x) + Math.abs(pt.y - prev.y) );
			}
			prev = pt;
		}
		return len;
	}

	public static function coords(cityX, cityY, x, y) {
		return {
			x	:   x - cityX,
			y	: -(y - cityY),
			sep	: " / ",
		}
	}

	public static function coordsToReal(cityX, cityY, x, y) {
		return {
			x	: cityX + x,
			y	: cityY - y,
			sep	: " / ",
		}
	}
}
