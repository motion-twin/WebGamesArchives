package mt.db;

class Phoneme {

	var s : String;

	static var tables : Array<{
		var terminal : Null<haxe.io.Bytes>;
		var table : Array<Int>;
	}>;


	public function new() {
		if( tables == null )
			initTables();
	}

	static function initTables() {
		tables = [{ terminal : null, table : [] }];
		// replacing occurences :
		//   lowercase chars are not replacable anymore
		//	 uppercase chars get rewritten
		repl("EAU","O");
		repl("AU","O");
		repl("OU","U");
		repl("EU","e");
		repl("AI","e");
		repl("ER","e");
		repl("CH","sh");
		repl("OE","e");
		repl("PH","F");
		// muettes / terminales
		repl("H","");
		repl("S$","$");
		repl("T$","$");
		repl("TS$","$"); // forts
		repl("E$","$");
		repl("ES$","$"); // codes, achetes, etc.
		repl("P$","$"); // loup
		repl("X$","$"); // aux/eux
		repl("ER$","e$"); // verbe en -er
		// doublées
		repl("EE","e");
		repl("AA","A");
		repl("OO","O");
		repl("UU","U");
		repl("II","I");
		repl("LL","L");
		repl("TT","T");
		repl("SS","S");
		repl("NN","N");
		repl("MM","N");
		repl("RR","R");
		repl("PP","P");
		repl("FF","F");
		// K
		repl("C","K"); // C might be S or K ...
		repl("CE","SE");
		repl("CS","X");
		repl("CK","K");
		repl("SK","K");
		repl("QU","K");
		repl("GU","G");
		repl("GE","J");
		repl("Y","I");
		repl("Z","S");
		repl("TIO","SIO");
		repl("TIA","SIA");
		repl("ERT","ert"); // certains
		// nasales
		repl("EN","n");
		repl("ON","n");
		repl("ION","ioN");
		repl("IN","n");
		repl("INE","iNE");
		repl("AIN","n");
		repl("AN","n");
		repl("AM","n");
		repl("EM","n");
		repl("OM","n");
		repl("EMM","em");
		repl("AMM","am");
		repl("OMM","om");
	}

	static function repl( a : String, b : String ) {
		var state:Null<Int> = 0;
		// create tables
		for( i in 0...a.length ) {
			var t = tables[state].table;
			var c : Int = a.charCodeAt(i);
			state = t[c];
			if( state == null ) {
				state = tables.length;
				t[c] = state;
				tables.push({ terminal : null, table : new Array() });
			}
		}
		// set terminal state
		var t = tables[state];
		if( t.terminal != null ) throw "Duplicate replace "+a;
		if( a.length < b.length ) throw "Invalid replace "+a+":"+b;
		t.terminal = haxe.io.Bytes.ofString(b);
	}

	inline function get(at) : Int {
		return s.charCodeAt(at);
	}

	public function make( s : String ) {
		s = removeAccentsUTF8(s);
		s = s.toUpperCase();
		var buf = new StringBuf();
		var b = #if neko neko.Lib.bytesReference #else haxe.io.Bytes.ofString #end("$"+~/[^A-Z]+/g.split(s).join("$")+"$");
		var i = 0;
		var max = b.length;
		var tables = tables;
		var t, state:Null<Int>;
		var lastpos = 0, last, startpos;
		while( i < max ) {
			last = null;
			startpos = i;
			t = tables[0];
			do {
				state = t.table[b.get(i)];
				if( state == null )
					break;
				t = tables[state];
				++i;
				if( t.terminal != null ) {
					last = t.terminal;
					lastpos = i;
				}
			} while( i < max );
			if( last == null ) {
				i = startpos;
				var c = b.get(i);
				// to upper
				if( c >= "a".code && c <= "z".code )
					c += "A".code - "a".code;
				buf.addChar(c);
				i++;
			} else {
				var len = last.length;
				i = lastpos - len;
				b.blit(i,last,0,len);
			}
		}
		return buf.toString();
	}

	inline public static function removeAccentsUTF8(s){
		return mt.Utf8.removeAccents( s );
	}

	public static function levenshtein( a : String, b : String ) {
		var d = [];
		var k = a.length + 1;
		var k2 = b.length + 1;
		for( i in 0...k )
			d[i] = i;
		for( j in 0...k2 )
			d[j * k] = j;
		for( i in 1...k )
			for( j in 1...k2 ) {
				var v = StringTools.fastCodeAt(a, i-1) == StringTools.fastCodeAt(b, j-1) ? 0 : 1;
				var er = d[i - 1 + j * k] + 1;
				var ins = d[i + (j - 1) * k] + 1;
				var sub = d[i - 1 + (j - 1) * k] + v;
				d[i + j * k] = er < ins ? (er < sub ? er : sub) : (ins < sub ? ins : sub);
			}
		return d[a.length + b.length * k];
	}
	
}
