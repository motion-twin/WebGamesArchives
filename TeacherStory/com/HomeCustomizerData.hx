typedef HCData = {
	id		: String,
	colors	: Bool,
	frames	: Array<Int>,
}

class HomeCustomizerData {
	public static var HUES = 30;

	#if neko
		static var XML_FR : haxe.xml.Fast = loadXml("fr") ;
		static var XML_ES : haxe.xml.Fast = loadXml("es") ;
		static var XML_EN : haxe.xml.Fast = loadXml("en") ;
		static var XML_DE : haxe.xml.Fast = loadXml("de") ;
	#else
		static var XML : haxe.xml.Fast = loadXml() ;
	#end

	
	static function loadXml(?lang : String) {
		#if neko
			var doc =  Xml.parse(neko.io.File.getContent(Config.TPL + "../../" + lang + "/tpl/homeCustomizer.xml")).firstElement() ;
		#else
			var raw = haxe.Resource.getString("xml_customizer");
			if( raw==null )
				throw "missing homeCustomizer.xml rsc";
			var doc = Xml.parse(raw).firstChild();
		#end
		return new haxe.xml.Fast(doc) ;
	}


	static function getXml() : haxe.xml.Fast {
		#if neko
			return switch(Config.LANG) {
						case "fr" : XML_FR ;
						case "en" : XML_EN ;
						case "es" : XML_ES ;
						case "de" : XML_DE ;
					}
		#else
			return XML ;
		#end
	}
	
	
	public static function getAvailableValues(id:String, level:Int) {
		var data : HCData = {
			id		: id,
			colors	: false,
			frames	: [],
		}
		
		for(node in getXml().nodes.l) {
			if( Std.parseInt(node.att.level)<=level ) {
				var k = node.att.id;
				if( k!=id )
					continue;
					
				if( node.has.colors )
					data.colors = true;
					
				if( node.has.frame )
					data.frames.push( Std.parseInt(node.att.frame) );
			}
		}
		
		return data;
	}



	public static function getNewValue(level : Int) : Array<{id : String, frame : Null<Int>, color : Null<Int>}> {
		var res = new Array() ;
		for(node in getXml().nodes.l) {
			if( Std.parseInt(node.att.level)==level ) {
				var k = node.att.id;
				
				res.push({ 	id : node.att.id,
							frame : (node.has.frame) ? Std.parseInt(node.att.frame) : null ,
							color : (node.has.colors) ? getDefaultColor() : null
						}) ;
			}
		}
		return res ;
	}
	
	
	public static function getName(id:String) {
		for(n in getXml().node.keys.nodes.k) {
			if( n.att.id==id )
				return n.att.name;
		}
		return "!!"+id+"!!";
	}


	#if neko

	public static function getText(level : Int) {
		for(node in getXml().nodes.l) {
			if( Std.parseInt(node.att.level)==level ) { //si plusieurs modifs pour un niveau : on prend le premier texte
				if (node.has.text)
					return node.att.text ;
			}
		}
		return "" ;
	}

	#end


	public static function getAllIds() : Array<String> {
		var res : Array<String> = new Array() ;
		
		for(node in getXml().nodes.l) {
			var k = node.att.id ;
			var level = Std.parseInt(node.att.level) ;
			var found = false ;
			for (r in res) {
				if (r != k)
					continue ;
				found = true ;
				break ;
			}
			if (found) continue ;

			res.push(k) ;
		}
		
		return res ;
	}

	
	public static function isValid(id:String, level:Int, frame:Int, color:Int) {
		var avail = getAvailableValues(id, level);
		if( avail==null )
			return false;
			
		if( !Lambda.has(avail.frames, frame) )
			return false;
		
		if( color>0 && !Lambda.has(getColors(), color) )
			return false;
		return true;
	}
	
	
	public static function getDefaultColor() {
		//return getColors()[Std.int(HUES+HUES*0.7)];
		return 0;
	}


	public static function getColors() {
		var colors = [];
		for(lum in [0.6, 0.45, 0.3, 0.15])
			for(x in 0...HUES)
				colors.push( mt.deepnight.Color.randomColor(x/HUES, 0.8, lum) );
		return colors;
	}
}

