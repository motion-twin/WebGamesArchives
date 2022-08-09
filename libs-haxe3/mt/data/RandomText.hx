package mt.data;

import mt.Compat;

enum TextElement {
	EText( t : String );
	ESub( e : String );
}

class RandomText {

	var texts : Hash<Array<List<TextElement>>>;
	
	function new() {
		texts = new Hash();
	}

	public dynamic function random( v : Int ) {
		return Std.random(v);
	}
	
	public function generate( start : String ) {
		var buf = new StringBuf();
		var t = texts.get(start);
		if( t == null ) throw "Invalid start '"+start+"'";
		genTextRec(buf,t);
		return buf.toString();
	}

	function genTextRec(buf:StringBuf,t:Array<List<TextElement>>) {
		for( e in t[random(t.length)] )
			switch( e ) {
			case EText(t): buf.add(t);
			case ESub(e): genTextRec(buf,texts.get(e));
			}
	}

	public function loadText( str : String ) {
		var lines = str.split("\n").iterator();
		var rtags = ~/\$([A-Za-z0-9_]+)/;
		var first = true;
		for( l in lines ) {
			l = StringTools.trim(l);
			if( l.length == 0 ) continue;
			if( l.charCodeAt(l.length-1) != ":".code )
				throw "Invalid text '"+l+"'";
			if( first ) {
				// remove BOM
				if( l.charCodeAt(0) == 0xEF && l.charCodeAt(1) == 0xBB && l.charCodeAt(2) == 0xBF )
					l = l.substr(3);
				first = false;
			}
			var id = l.substr(0,l.length-1);
			if( texts.exists(id) )
				throw "Duplicate text '"+id+"'";
			var pl = new Array();
			texts.set(id,pl);
			for( l in lines ) {
				var tab = (l.charCodeAt(0) == "\t".code);
				l = StringTools.trim(l);
				if( l.length == 0 ) break;
				if( !tab )
					throw "Invalid text element '"+l+"'";
				var elements = new List();
				pl.push(elements);
				if( l == "€" )
					continue;
				l = l.split("*").join(" ");
				while( rtags.match(l) ) {
					var left = rtags.matchedLeft();
					if( left.length > 0 )
						elements.add(EText(left));
					elements.add(ESub(rtags.matched(1)));
					l = rtags.matchedRight();
				}
				if( l.length > 0 )
					elements.add(EText(l));
			}
		}
	}

	public function check() {
		for( tid in texts.keys() )
			for( k in texts.get(tid) )
				for( i in k )
					switch( i ) {
					case EText(_):
					case ESub(name):
						if( name == tid )
							throw name+" is recursive";
						if( !texts.exists(name) )
							throw "Unknown text element '"+name+"' in '"+tid+"'";
					}
	}

	public static function load(str) {
		var r = new RandomText();
		r.loadText(str);
		r.check();
		return r;
	}

}