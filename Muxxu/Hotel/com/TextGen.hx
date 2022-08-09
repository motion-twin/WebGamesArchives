class TextGen {
	static var TEXTS	: Hash<Array<String>>;
	//var texts			: Hash<Array<String>>;
	var rseed			: mt.Rand;

	static function fatal(err:String) {
		throw "TextGen : "+err;
	}
	
	public function new(seed:Int) {
		#if neko
		var raw = neko.io.File.getContent(Config.TPL+"../../xml/"+Config.LANG+"/texts.xml");
		#end
		#if flash
		var raw = haxe.Resource.getString(Game.LANG+".texts.xml");
		#end
		
		if ( raw==null || raw=="" )
			fatal("no data");
			
		initSeed(seed);
		
		if (TEXTS==null) {
			// parsing
			TEXTS = new Hash();

			var lines = raw.split("\n");
			var key : String = null;
			for (line in lines) {
				var trimmed = StringTools.trim(line);
				if ( trimmed.length==0 ) continue;
				if ( line.charAt(0)==" " )
					fatal("unexpected leading space around key "+key);
				if ( line.charAt(0)!="\t" )
					key = trimmed.toLowerCase();
				else {
					if ( key==null ) fatal("unexpected : "+line);
					if ( TEXTS.get(key)==null ) TEXTS.set(key,new Array());
					TEXTS.get(key).push( trimmed );
				}
			}
		}
	}
	
	public inline function initSeed(s) {
		rseed = new mt.Rand(0);
		rseed.initSeed(s);
	}

	
	public function get(key:String, ?rfunc:Int->Int, ?fl_firstRecurs=true) {
		if (rfunc==null)
			rfunc = rseed.random;
		key = key.toLowerCase();
		var list = TEXTS.get(key);
		if ( key==null || list==null || list.length==0 )
			fatal("unknown key "+key);
			
		var str = list[rfunc(list.length)];
		var list = str.split("%");
		if (list.length>1) {
			str = "";
			var i = 1;
			for (v in list) {
				if (i%2==0)
					str += get(v,false);
				else
					str+=v;
				i++;
			}
		}
		return str;
	}
	
	public function format(key:String, data:Dynamic) {
		var str = get(key);
		var list = str.split("::");
		var n = 0;
		for (k in Reflect.fields(data))
			str = StringTools.replace(str, "::"+k.substr(1)+"::", Reflect.field(data,k));
		return str;
	}
		
}
