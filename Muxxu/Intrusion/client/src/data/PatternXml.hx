package data;

typedef FolderPattern = {
	folders		: Array<String>,
	files		: Array<String>,
	jfolders	: Array<String>,
	jfiles		: Array<String>,
}

class PatternXml {
	public var rseed	: mt.Rand;
	var patterns		: Hash<Array<String>>;

	public function new(seed:Int,raw:String) {
		rseed = Data.newRandSeed(seed);
		patterns = new Hash();

		var lines = raw.split("\n");
		var key : String = null;
		for (line in lines) {
			line = trim(line).toLowerCase();
			if ( line.length>0 )
				if ( line.charAt(0)!="\t" ) {
					key = line;
					if ( patterns.get(key)==null ) patterns.set(key,new Array());
				}
				else {
					if ( key==null ) fatal("unexpected key '"+line+"'");
					line = trimTabs(line);
					if ( line.length>0 )
						patterns.get(key).push( trim(line) );
				}

		}
	}


	public function getContent(key:String) : FolderPattern {
		var p : FolderPattern = {
			folders		: new Array(),
			files		: new Array(),
			jfolders	: new Array(),
			jfiles		: new Array(),
		}
		key = key.toLowerCase();
		var list = patterns.get(key);
		if ( list==null ) fatal("invalid pattern key '"+key+"'");
		for (key in list) {
			if ( isFolder(key) )
				p.folders.push(key);
			else
				p.files.push(key);
		}
		return p;
	}


	public static function getCount(rseed:mt.Rand, key:String) {
		key = key.toLowerCase();
		var a = key.split(":");
		if ( a.length==1 ) return 1;
		var min = Std.parseInt(a[0]);
		var max = Std.parseInt(a[1]);
		if ( min==max ) return min;
		var n = rseed.random(max-min+1)+min;
		return if(n<=0) 0 else n;
	}

//	public static function countReq(list:Array<PatternItem>) {
//		var n = 0;
//		for (item in list) {
//			if ( item.req ) n++;
//		}
//		return n;
//	}
//
//	public static function hasJunk(list:Array<PatternItem>) {
//		for (item in list) {
//			if ( !item.req ) return true;
//		}
//		return false;
//	}

	inline function isFolder(itemName:String) {
		return itemName.indexOf("/")>=0;
	}

	public static function cleanUpKey(key:String) {
		key = key.toLowerCase();
		key = StringTools.replace(key, "+", "");
		key = StringTools.replace(key, "\"", "");
		if ( key.indexOf(":")>=0 )
			return key.substr( key.lastIndexOf(":")+1 );
		else
			return key;
	}



	function trimTabs(str:String) {
		while (str.charAt(0)=="\t") str = str.substr(1);
		return str;
	}



	function trim(str:String) {
		while (str.charAt(0)==" ") str = str.substr(1);
		while (str.charAt(str.length-1)==" " || str.charAt(str.length-1)=="\t") str = str.substr(0,str.length-1);
		str = StringTools.replace(str,"\n","");
		str = StringTools.replace(str,"\r","");
		return str;
	}

	public function check(fsNames:data.TextXml) {
		for(k in patterns.keys()) {
			var wlist = patterns.get(k);
			for (w in wlist) {
				var clean = cleanUpKey(w);
				if ( w.indexOf("\"")>=0 ) {
					if ( !fsNames.exists(clean) ) fatal("invalid fsNames reference "+clean+" in "+k);
				}
				else
					if ( !patterns.exists(clean) ) fatal("invalid key "+clean+" in "+k);
			}
		}
	}



	function fatal(msg:String) {
		throw "[PatternXml] "+msg;
	}
}
