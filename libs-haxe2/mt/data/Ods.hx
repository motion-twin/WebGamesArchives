package mt.data;

private typedef F = haxe.xml.Fast;

enum Rule {
	RSkip;
	RBlank;
	RInt;
	RBool;
	RFloat;
	RText;
	RReg( e : EReg );
	RValues( v : Array<String>, ?indexes : Bool );
	REnum( v : Array<String>, e : Enum<Dynamic> );
	RMap( v : Array<String>, values : Array<Dynamic> );
	RArray( sep : String, rule : Rule );
	RCustom( name : String, parser : String -> Dynamic );
}

enum Column {
	A( name : String, r : Rule );
	N( name : String, r : Rule );
	R( r : Rule );
	Opt( c : Column );
	All( c : Column );
}

typedef Line = { name : String, cols : Array<Column> };

enum Document {
	DList( l : Array<Document> );
	DLine( r : Line );
	DMany( l : Document );
	DOpt( l : Document );
	DChoice( l : Array<Document> );
	DGroup( r : Line, sub : Document );
	DWhileNot( cond : Document, d : Document );
}

enum Check {
	CMatch;
	CExpected( l : Line, row : Int );
	CInvalid( v : String, l : Line, r : Rule, row : Int, col : Int );
	CCustom( v : String, l : Line, msg : String, row :Int, col : Int );
}

enum CustomError {
	CustomMessage( msg : String );
}

private typedef Status = {
	var curRow : Int;
	var rows : Array<F>;
	var rowRepeat : Int;
	var out : Array<Xml>; // build xml has only little impact on perfs and might be needed
	var obj : Dynamic;
}


class OdsChecker {

	var sheets : Hash<F>;
	var root : Xml;
	var status : Status;
	var lastError : Check;
	var customMessage : String;

	static var eblank = ~/^[ \r\n\t]*$/;
	static var eint = ~/^(-?[0-9]+|0x[0-9A-Fa-f]+)$/;
	static var efloat = ~/^-?([0-9]+)|([0-9]*[.,][0-9]+)$/;

	public function new() {
		sheets = new Hash();
	}

	public function loadODS( i : haxe.io.Input ) {
		var content = null;
		for( e in new format.zip.Reader(i).read() ) {
			if( e.fileName == "content.xml" ) {
				content = e;
				break;
			}
		}
		var data = if( content.compressed ) format.tools.Inflate.run(content.data) else content.data;
		load(Xml.parse(data.toString()));
	}

	public function load( x : Xml ) {
		if( x.nodeType == Xml.Document )
			x = x.firstElement();
		root = x;
		var x = new haxe.xml.Fast(x);
		var sx = x.node.resolve("office:body").node.resolve("office:spreadsheet");
		for( s in sx.nodes.resolve("table:table") )
			sheets.set(s.att.resolve("table:name"), s);
	}

	public function hasSheet( s : String ) {
		return sheets.exists(s);
	}

	public function getSheets() {
		return Lambda.array( { iterator : sheets.keys } );
	}

	public function check( sheet : String, doc : Document ) {
		var s = sheets.get(sheet);
		if( s == null ) throw "Sheet does not exists '" + sheet + "'";
		status = {
			curRow : 1,
			rows : Lambda.array(s.nodes.resolve("table:table-row")),
			rowRepeat : 0,
			out : new Array(),
			obj : {},
		};
		lastError = CMatch;
		if( !checkRec(doc,false) )
			throw "In '" + sheet + "' " + errorString(lastError);
		if( status.rows.length > 0 && !hasProperEnding(doc) )
			throw "In '" + sheet + "' " + errorString(lastError)+" (maybe extra data ?)";
		var x = Xml.createDocument();
		for( o in status.out )
			x.addChild(o);
		return { x : x, o : status.obj };
	}

	public function getLines( sheet : String ) : Iterator<Array<String>> {
		var s = sheets.get(sheet);
		if( s == null ) throw "Sheet does not exists '" + sheet + "'";
		var rows = s.nodes.resolve("table:table-row");
		var repeat = 0;
		var line = 0;
		var me = this;
		return {
			hasNext : function() {
				return rows.length > 0 || repeat > 0;
			},
			next : function() {
				var r;
				line++;
				if( repeat == 0 ) {
					r = rows.pop();
					var repeatVal = r.x.get("table:number-rows-repeated");
					if( repeatVal != null ) {
						repeat = Std.parseInt(repeatVal) - 1;
						rows.push(r);
					}
				} else {
					r = rows.first();
					if( --repeat == 0 )
						rows.pop();
				}
				var cols = [];
				for( c in r.nodes.resolve("table:table-cell") ) {
					var repeat = c.x.get("table:number-columns-repeated");
					if( repeat == null )
						cols.push(me.extractText(c, line));
					else {
						var t = me.extractText(c, line);
						for( i in 0...Std.parseInt(repeat) )
							cols.push(t);
					}
				}
				return cols;
			},
		};
	}

	function hasProperEnding( doc : Document ) {
		return switch(doc) {
		case DOpt(_), DMany(_): false;
		case DLine(_): true;
		case DGroup(_, d): hasProperEnding(d);
		case DChoice(a):
			var v = a.length > 0;
			for( x in a )
				if( !hasProperEnding(x) ) {
					v = false;
					break;
				}
			v;
		case DList(a):
			a.length > 0 && hasProperEnding(a[a.length - 1]);
		case DWhileNot(d, _):
			hasProperEnding(d);
		};
	}

	public function ruleString( r : Rule ) {
		return switch( r ) {
			case RSkip: "skip";
			case RBlank: "blank";
			case RInt: "int";
			case RBool: "bool";
			case RFloat: "float";
			case RText: "text";
			case RReg(e): "regexp";
			case RValues(vl, _), REnum(vl, _), RMap(vl, _): "one of these : (" + Lambda.map(vl, function(v) return "'" + v + "'").join(",") + ")";
			case RArray(sep, r): "an array of " + ruleString(r) + " separated by '" + sep + "'";
			case RCustom(name,_): name;
		};
	}

	function smartMatching( v : String, r : Rule ) {
		switch( r ) {
		case RArray(sep, r):
			for( v in v.split(sep) ) {
				var v = StringTools.trim(v);
				if( checkRule(r, v) == null )
					return { v : v, r : r };
			}
		default:
		}
		return { v : v, r : r };
	}

	function errorString( e : Check ) {
		return switch( e ) {
			case CMatch: "No Error";
			case CExpected(l, row): "line " + row + " expected " + ((l.name == null) ? Std.string(l.cols) : l.name);
			case CInvalid(v, l, r, row, col):
				var inf = smartMatching(v, r);
				var rule = ruleString(inf.r);
				"at " + columnName(col) + row + " '" + inf.v + "' should be " + rule + ((l.name == null)?"":" (" + l.name + ")");
			case CCustom(v, l, msg, row, col):
				"at " + columnName(col) + row + " '" + v + "' " + msg + ((l.name == null)?"":" (" + l.name + ")");
		};
	}

	function save() : Status {
		var odup = {};
		for( f in Reflect.fields(status.obj) ) {
			var v : Dynamic = Reflect.field(status.obj, f);
			if( Std.is(v, Array) ) {
				var a : Array<Dynamic> = v;
				Reflect.setField(odup, f, a.copy());
			} else
				Reflect.setField(odup, f, v);
		}
		return {
			curRow : status.curRow,
			rows : status.rows.copy(),
			out : status.out.copy(),
			rowRepeat : status.rowRepeat,
			obj : odup,
		};
	}

	function restore( s : Status ) {
		status.curRow = s.curRow;
		status.rows = s.rows;
		status.out = s.out;
		status.rowRepeat = s.rowRepeat;
		status.obj = s.obj;
	}

	public function columnName( c : Int ) {
		var s = "";
		do {
			s += String.fromCharCode("A".code + (c % 26));
			c = Std.int(c / 26);
		} while( c > 0 );
		return s;
	}

	function errorPos( e : Check ) {
		return switch( e ) {
		case CMatch: -1;
		case CExpected(_, r): r << 16;
		case CInvalid(_, _, _, r, c), CCustom(_, _, _, r, c): (r << 16) + c;
		}
	}

	function error( e : Check ) {
		if( errorPos(e) > errorPos(lastError) )
			lastError = e;
	}

	public function checkRule( r : Rule, v : String ) : Dynamic {
		switch( r ) {
		case RSkip:
			return null;
		case RBlank:
			return eblank.match(v) ? "" : null;
		case RInt:
			// remove non breaking spaces (digits separators)
			v = v.split("\xC2\xA0").join("");
			return eint.match(v) ? Std.parseInt(v) : null;
		case RBool:
			if( v == "true" || v == "1" )
				return true;
			if( v == "false" || v == "0" )
				return false;
			return null;
		case RFloat:
			return efloat.match(v) ? Std.parseFloat(v.split(",").join(".")) : null;
		case RText:
			v = StringTools.trim(v);
			return (v == "") ? null : v;
		case RReg(e):
			return e.match(v) ? v : null;
		case RValues(vl,idx):
			v = StringTools.trim(v);
			for( i in 0...vl.length )
				if( v == vl[i] ) {
					if( idx ) return i;
					return v;
				}
			return null;
		case REnum(vl, e):
			v = StringTools.trim(v);
			for( i in 0...vl.length )
				if( v == vl[i] )
					return Type.createEnumIndex(e, i);
			return null;
		case RMap(vl,values):
			v = StringTools.trim(v);
			for( i in 0...vl.length )
				if( v == vl[i] )
					return values[i];
			return null;
		case RArray(sep, r):
			var a = new Array();
			if( v != "" )
				for( v in v.split(sep) ) {
					var v = checkRule(r, StringTools.trim(v));
					if( v == null ) return null;
					a.push(v);
				}
			return a;
		case RCustom(_,parser):
			try {
				return parser(v);
			} catch( e : CustomError ) {
				switch( e ) {
				case CustomMessage(msg): customMessage = msg;
				}
				return null;
			}
		}
		return null;
	}

	function addField( obj : Dynamic, name : String, v : Dynamic ) {
		if( Reflect.hasField(obj, name) ) {
			var f : Dynamic = Reflect.field(obj, name);
			if( !Std.is(f, Array) ) {
				f = [f, v];
				Reflect.setField(obj, name, f);
			} else {
				var a : Array<Dynamic> = f;
				a.push(v);
			}
		} else
			Reflect.setField(obj, name, v);
	}

	function checkColumn( c : Column, v : String, x : Xml, obj : Dynamic ) {
		switch( c ) {
		case R(r):
			if( r != RSkip && checkRule(r, v) == null )
				return r;
		case Opt(c):
			var r = checkColumn(c, v, x, obj);
			if( r != null && v != "" )
				return r;
		case A(name, r):
			var k = checkRule(r, v);
			if( k == null )
				return r;
			var v = x.get(name);
			if( v == null ) v = "" else v += ";";
			x.set(name, v + Std.string(k));
			addField(obj, name, k);
		case N(name, r):
			var k = checkRule(r, v);
			if( k == null )
				return r;
			var n = Xml.createElement(name);
			n.addChild(Xml.createPCData(StringTools.htmlEscape(Std.string(k))));
			x.addChild(n);
			addField(obj, name, k);
		case All(c):
			return checkColumn(c, v, x, obj);
		}
		return null;
	}

	function extractText( cell : haxe.xml.Fast, line : Int ) {
		var html = new StringBuf();
		var first = true;
		for (x in cell.x){
			if( x.nodeName == "office:annotation" )
				continue;
			else if( x.nodeName != "text:p" )
				throw "assert " + x.nodeName+" at line "+line;
			else {
				if( first ) first = false else html.add("\n");
				for( e in x )
					extractTextContent(html, e, line);
			}
		}
		var v = StringTools.htmlUnescape(html.toString());
		v = v.split("&apos;").join("'").split("&quot;").join('"');
		return v;
	}

	function extractTextContent( html : StringBuf, e : Xml, line : Int ) {
		if( e.nodeType == Xml.Element ) {
			switch( e.nodeName ) {
			case "text:s":
				html.add("\n");
			case "text:span":
				for( x in e )
					extractTextContent(html,x, line);
			default:
				throw "assert " + e.nodeName+" at line "+line;
			}
		} else
			html.add(e.toString());
	}

	function checkLine( l : Line, hasMany : Bool ) {
		var row = status.rows[0];
		if( row == null ) {
			error(CExpected(l, status.curRow));
			return false;
		}
		var cols = row.nodes.resolve("table:table-cell");
		var n = 0;
		var cur = null;
		var curCol = -1;
		var x = if( l.name == null ) Xml.createDocument() else Xml.createElement(l.name);
		var rindex = 0;
		var rblank = R(RBlank);
		var obj = {};
		while( true ) {
			// update col
			n--;
			curCol++;
			if( n <= 0 ) {
				cur = cols.pop();
				if( cur == null )
					n = 10000;
				else {
					var repeat = cur.x.get("table:number-columns-repeated");
					n = if( repeat == null ) 1 else Std.parseInt(repeat);
				}
			}
			// get col value
			var v;
			if( cur == null )
				v = "";
			else
				v = extractText(cur,status.curRow);
			// update rule
			var rule = l.cols[rindex];
			if( rule == null ) {
				if( cur == null ) break;
				rule = rblank;
				curCol += n - 1;
				n = 1; // if this one is blank, the repeated will be as well
			}
			var r = checkColumn(rule, v, x, obj);
			if( r != null ) {
				if( customMessage != null ) {
					error(CCustom(v, l, customMessage, status.curRow, curCol));
					customMessage = null;
				} else
					error(CInvalid(v, l, r, status.curRow, curCol));
				return false;
			}
			switch( rule ) {
			case All(_):
				if( cur == null ) break;
				// if we could match this one, we will match all repeated
				curCol += n - 1;
				n = 1;
			default: rindex++;
			}
		}
		var repeat = row.x.get("table:number-rows-repeated");
		if( repeat != null ) {
			if( status.rowRepeat == 0 )
				status.rowRepeat = Std.parseInt(repeat);
			else {
				status.rowRepeat--;
				if( status.rowRepeat == 1 || l.name == null ) {
					status.rows.shift();
					status.rowRepeat = 0;
				}
			}
		} else
			status.rows.shift();
		if( l.name != null ) {
			status.out.push(x);
			if( hasMany ) {
				var f : Array<Dynamic> = Reflect.field(status.obj, l.name);
				if( f == null ) {
					f = [];
					Reflect.setField(status.obj, l.name, f);
				}
				f.push(obj);
			} else
				Reflect.setField(status.obj, l.name, obj);
		}
		status.curRow++;
		return true;
	}

	function checkRec( doc : Document, hasMany : Bool ) {
		switch( doc ) {
		case DList(l):
			var save = save();
			for( d in l )
				if( !checkRec(d,hasMany) ) {
					restore(save);
					return false;
				}
		case DLine(r):
			return checkLine(r,hasMany);
		case DMany(d):
			while( checkRec(d,true) ) {
			}
		case DOpt(d):
			checkRec(d,hasMany);
		case DChoice(l):
			var save = save();
			for( d in l ) {
				if( checkRec(d,hasMany) )
					return true;
				restore(save);
				save = this.save();
			}
			return false;
		case DGroup(r, sub):
			var save = save();
			var prev = status.obj;
			status.out = new Array();
			if( !checkLine(r,hasMany) ) {
				restore(save);
				return false;
			}
			var x = status.out.shift();
			var obj : Dynamic = Reflect.field(status.obj, r.name);
			if( hasMany ) {
				var o : Array<Dynamic> = obj;
				obj = o[o.length - 1];
			}
			status.obj = obj;
			if( !checkRec(sub,false) ) {
				restore(save);
				return false;
			}
			for( o in status.out )
				x.addChild(o);
			status.out = save.out;
			status.out.push(x);
			status.obj = prev;
		case DWhileNot(cond, d):
			while( !checkRec(cond,false) ) {
				lastError = CMatch;
				if( !checkRec(d, true) )
					return false;
			}
		}
		return true;
	}

}
