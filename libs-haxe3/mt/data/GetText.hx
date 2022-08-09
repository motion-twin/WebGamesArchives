package mt.data;

import haxe.macro.Expr;
import haxe.macro.Context;

#if (potools || macro)

typedef POData = Array<POEntry>;

typedef POEntry = {
	?msgid: String,
	?msgstr: String,

	id: Null<String>,
	str: Null<String>,

	?cTranslator: String,
	?cExtracted: String,
	?cRef: String,
	?cFlags: String,
	?cPrevious : String,
	?cComment: String,
}

#end

#if !flash
typedef LocaleString = String;
#else
abstract LocaleString(String) to String {
	inline public function new(s:String) {
		this = s;
	}

	public inline function toUpperCase() : LocaleString return cast this.toUpperCase();
	public inline function toLowerCase() : LocaleString return cast this.toLowerCase();
	public inline function charAt(i) return this.charAt(i);
	public inline function charCodeAt(i) return this.charCodeAt(i);
	public inline function indexOf(i, ?s) return this.indexOf(i,s);
	public inline function lastIndexOf(i, ?s) return this.lastIndexOf(i,s);
	public inline function split(i) return this.split(i);
	public inline function substr(i, ?l) return this.substr(i, l);
	public inline function substring(i, ?e) return this.substring(i,e);

	@:op(A+B) function add(to:LocaleString) return new LocaleString(this+to);

	public var length(get,never) : Int;
	inline function get_length() return this.length;

	#if heaps
	@:to
	inline function toUString() : hxd.UString {
		return (cast this:hxd.UString);
	}
	#end
}
#end

class GetText {

	var texts : Map<String,LocaleString>;


	public function toString() {
		return "GetText";
	}

	public function untranslated(str:Dynamic) : LocaleString {
		return cast Std.string(str);
	}

	public macro function _(ethis:Expr, estr:ExprOf<String>, ?params:ExprOf<Dynamic>) {
		var str = switch(estr.expr) {
			case EConst(CString(s)) : s;
			default :
				Context.error("Constant string expected here!", estr.pos);
		}

		var odd = false;
		var hasVars = false;
		var strVars = [];
		for(s in str.split("::")) {
			odd = !odd;
			if( !odd ) {
				hasVars = true;
				strVars.push(s);
			}
		}

		switch( params.expr ) {
			case EObjectDecl(fields) :

				var vmap = new Map();
				for(f in fields) {
					if( str.indexOf("::"+f.field+"::")<0 )
						Context.error("Variable "+f.field+" not found in the string!", f.expr.pos);
					vmap.set(f.field, true);
					f.field = "_"+f.field;
				}

				for(k in strVars)
					if( !vmap.exists(k) )
						Context.error("String requires field "+k, params.pos);

				params = { expr:EObjectDecl(fields), pos:params.pos };

			case EConst(CIdent("null")) :
				if( hasVars )
					Context.error("Missing params: "+strVars.join(", "), params.pos);

			default :
				Context.error("Anonymous object expected here!", params.pos);
		}


		return macro $ethis.get($estr,$params);
	}

	@:noCompletion public function get(str:Null<String>, ?params:Dynamic) : Null<LocaleString> {
		if(texts == null) throw "no data in dictionnary";
		if( str==null ) return null;

		str = StringTools.rtrim( str.split("||")[0] );

		if(texts.exists(str))
			str = texts.get(str);


		var list = str.split("::");
		var n = 0;
		if(params!=null){
			for (k in Reflect.fields(params)){
				str = StringTools.replace(str, "::" + k.substr(1) + "::", Reflect.field(params, k));
			}
		}

		return new LocaleString(str);
	}

	public function readMo(data:haxe.io.Bytes) {
		var r =  new MoReader(data);
		texts = r.parse();
		r = null;
	}

	public function emptyDictionary(){
		texts = new Map();
	}


	public function new() {
	}

	/**
	 * parse tout le projet pour générer le fichier POT
	 */
	macro public static function parse(codePath:String, potFilePath:String, ?refPoFilePath:String) {
		Sys.println("[GetText] Parsing source code...");
		var data : POData = [];
		data.push( POTools.mkHeaders([
			"MIME-Version" => "1.0",
			"Content-Type" => "text/plain; charset=UTF-8",
			"Content-Transfer-Encoding" => "8bit"
		]) );
		var strMap : Map<String,Bool> = new Map();
		explore(codePath, data, strMap);

		Sys.println("[GetText] Saving POT file...");
		POTools.exportFile( potFilePath, data );

		if( refPoFilePath != null ){
			if( !sys.FileSystem.exists(refPoFilePath) ){
				Sys.println("[GetText] Warning: File not found: "+refPoFilePath );
			}else{
				Sys.println("[GetText] Saving Translated-POT file...");
				POTools.exportTranslatedFile(potFilePath,refPoFilePath,data);
			}
		}

		Sys.println("[GetText] Done.");
		return macro {}
	}

	#if castle
	macro public static function parseCdb(filesList:Array<String>, potFilePath:String, ?refPoFilePath:String ){
		var data : POData = [];
		data.push( POTools.mkHeaders([
			"MIME-Version" => "1.0",
			"Content-Type" => "text/plain; charset=UTF-8",
			"Content-Transfer-Encoding" => "8bit"
		]) );
		var strMap : Map<String,Bool> = new Map();
		exploreCDB(filesList,data,strMap);

		POTools.exportFile( potFilePath, data );
		if( refPoFilePath != null ){
			if( !sys.FileSystem.exists(refPoFilePath) ){
				Sys.println("[GetText] Warning: File not found: "+refPoFilePath );
			}else{
				POTools.exportTranslatedFile(potFilePath,refPoFilePath,data);
			}
		}

		return macro {}
	}

	macro public static function parseGlobal( codePath:String, cdbFiles:Array<String>, potFilePath:String, ?refPoFilePath:String ){
		Sys.println("[GetText] Parsing source code...");
		var data : POData = [];
		data.push( POTools.mkHeaders([
			"MIME-Version" => "1.0",
			"Content-Type" => "text/plain; charset=UTF-8",
			"Content-Transfer-Encoding" => "8bit"
		]) );
		var strMap : Map<String,Bool> = new Map();
		explore(codePath, data, strMap);

		Sys.println("[GetText] Parsing CDBs...");
		exploreCDB(cdbFiles,data,strMap);

		Sys.println("[GetText] Saving POT file...");
		POTools.exportFile( potFilePath, data );

		if( refPoFilePath != null ){
			if( !sys.FileSystem.exists(refPoFilePath) ){
				Sys.println("[GetText] Warning: File not found: "+refPoFilePath );
			}else{
				POTools.exportTranslatedFile(potFilePath,refPoFilePath,data);
			}
		}

		return macro {}
	}
	#end

	#if macro

	static function explore(folder:String, data:POData, strMap:Map<String,Bool>) {
		// Test it: http://regexr.com/
		var strReg = ~/\._\([ ]*"((\\"|[^"])+)"/i;
		for( f in sys.FileSystem.readDirectory(folder) ) {
			// Parse sub folders
			if( sys.FileSystem.isDirectory(folder+"/"+f) ) {
				explore(folder+"/"+f, data, strMap);
				continue;
			}

			// Ignore non-sourcecode
			if( f.substr(f.length - 3) != ".hx" )
				continue;

			// Read lines
			var c = sys.io.File.getContent(folder+"/"+f);
			var n = 0;
			for( line in c.split("\n") ) {
				n++;
				if( line == "" )
					continue;

				var pos = 0;
				while( strReg.match(line.substr(pos)) ) {
					var str = strReg.matched(1);
					try {
					pos += strReg.matchedPos().pos + strReg.matchedPos().len;
					} catch(e:Dynamic) {
						//trace(str);
						throw e;
					}

					// Ignore commented strings
					var i = line.indexOf("//");
					if( i>=0 && i<strReg.matchedPos().pos )
						break;

					var cleanedStr = str;

					// Translator comment
					var comment : String = null;
					if( cleanedStr.indexOf("||")>=0 ) {
						var parts = cleanedStr.split("||");
						if( parts.length!=2 ) {
							throw "Malformed translator comment in "+f+" (line "+n+")";
							continue;
						}
						comment = StringTools.trim(parts[1]);
						cleanedStr = cleanedStr.substr(0,cleanedStr.indexOf("||"));
						cleanedStr = StringTools.rtrim(cleanedStr);
					}

					// New entry found
					if( !strMap.exists(cleanedStr) ) {
						strMap.set(cleanedStr, true);
						data.push({
							id			: cleanedStr,
							str			: "",
							cRef		: folder+"/"+f+":"+n,
							cExtracted	: comment,
						});
					}else{
						var previous = Lambda.find(data,function(e) return e.id==cleanedStr);
						if( previous != null )
							previous.cRef += " "+folder+"/"+f+":"+n;
					}
				}
			}
		}
	}

	#if castle
	static function exploreCDB( filesList:Array<String>, data:POData, strMap:Map<String,Bool> ){
		for( file in filesList ){
			var cbdData = cdb.Parser.parse( sys.io.File.getContent(file) );
			var columns = new Map<String,Array<Array<String>>>();
			for( sheet in cbdData.sheets ){
				var p = sheet.name.split("@");
				var sheetName = p.shift();
				if( !columns.exists(sheetName) )
					columns.set(sheetName,[]);
				var sheetColumns = columns.get(sheetName);

				var cid = p;

				for ( column in sheet.columns ) {
					if( column.kind == "localizable" && column.type == TString ){
						var p = p.copy();
						p.push( column.name );
						sheetColumns.push( p );
					}
				}
			}

			function add( idx:String, id:String, str : String ){
				if( str==null || str.length == 0 )
					return;

				var cleanedStr = str;
				var comment : String = id;
				if( cleanedStr.indexOf("||")>=0 ) {
					var parts = cleanedStr.split("||");
					if( parts.length!=2 ) {
						throw "Malformed translator comment in "+file+" @ "+idx;
					}
					comment += "\n"+StringTools.trim(parts[1]);
					cleanedStr = cleanedStr.substr(0,cleanedStr.indexOf("||"));
					cleanedStr = StringTools.rtrim(cleanedStr);
				}


				if( !strMap.exists(cleanedStr) ) {
					strMap.set(cleanedStr, true);
					data.push({
						id			: cleanedStr,
						str			: "",
						cRef		: idx,
						cExtracted	: comment,
					});
				}else{
					var previous = Lambda.find(data,function(e) return e.id==cleanedStr);
					if( previous != null )
						previous.cRef += " "+idx;
				}
			}

			function exploreSheet( idx:String, id:Null<String>, lines:Array<Dynamic>, columns:Array<Array<String>> ){
				for( col in columns ){
					var col = col.copy();
					var cname = col.shift();
					if( col.length == 0 ){
						var i = 0;
						for( line in lines ){
							if( line.enabled == false || line.active == false )
								continue;
							var id = id;
							if( line.id != null )
								id += " "+line.id;
							add( idx+"/#"+i+"."+cname, id, Reflect.field(line,cname) );
							i++;
						}
					}else{
						var i = 0;
						for( line in lines ){
							if( line.enabled == false || line.active == false )
								continue;
							var id = id;
							if( line.id != null )
								id += " "+line.id;
							exploreSheet( idx+"/#"+i+"."+cname, id, Reflect.field(line,cname), [col] );
							i++;
						}
					}
				}
			}

			for( sheet in cbdData.sheets ){
				var sColumns = columns.get(sheet.name);
				if( sColumns==null || sColumns.length == 0 )
					continue;

				exploreSheet( file+":"+sheet.name, "", sheet.lines, sColumns );
			}
		}
	}
	#end

	#end

}

/**
 * GNU GetText MO file reader
 * @doc https://www.gnu.org/software/gettext/manual/html_node/MO-Files.html
 */
class MoReader
{
	private var original_table_offset:UInt;
	private var translated_table_offset:UInt;
	private var hash_num_entries:UInt;
	private var hash_offset:UInt;
	private var data:haxe.io.BytesInput;

	static var MAGIC:UInt = 0x950412DE;
	static var MAGIC2:UInt = 0xDE120495;

	public function new(data:haxe.io.Bytes):Void
	{
		this.data = new haxe.io.BytesInput(data);
	}

	public function parse():Map<String,LocaleString>
	{
		var d = data;
		var header : UInt = d.readInt32();

		if(header != MAGIC && header != MAGIC2) {
			throw "Bad MO file header : " + header;
		}

		var revision:UInt = d.readInt32();
		if (revision > 1){
			throw "Bad MO file format revision : "+revision;
		}

		var num_strings:UInt = d.readInt32();
		original_table_offset= d.readInt32();
		translated_table_offset = d.readInt32();
		hash_num_entries= d.readInt32();
		hash_offset= d.readInt32();

		var texts : Map<String,LocaleString> = new Map();
		for (i in 1...num_strings)
			texts.set( getOriginalString(i), getTranslatedString(i) );

		return texts;

	}

	function getTranslatedString(index:Int):LocaleString {
		return getString(translated_table_offset + 8 * index );
	}

	function getOriginalString(index:Int):String {
		return getString(original_table_offset + 8 * index );
	}

	function getString(offset:UInt):LocaleString {
		data.position = offset;
		var length :UInt = data.readInt32();
		var pos :UInt = data.readInt32();
		data.position = pos;
		return new LocaleString( data.readString(length) );
	}
}

#if (potools || macro)

class POTools {

	public static function parseFile( path : String ) : POData {
		return parse( sys.io.File.getContent(path) );
	}

	public static function parse( data : String ) : POData {
		var arr : POData = [];
		var e : POEntry = cast { };
		var lnum = -1;
		for ( line in data.split("\n") ) {
			lnum++;
			// Remove CR before LF
			if ( line.length > 0 && line.substr( -1, 1) == "\r" )
				line = line.substr(0, line.length - 1);

			if( line.length == 0 ){
				arr.push(e);
				e = cast {};
				continue;
			}

			var f = line.charCodeAt(0);
			if( f == '"'.code ){
				if( e.msgstr != null ){
					e.msgstr += "\n"+line;
					e.str += getString(line,lnum);
				}else if( e.msgid != null ){
					e.msgid += "\n"+line;
					e.id += getString(line,lnum);
				}else{
					throw "Parse error line "+lnum;
				}
			}else if( f == '#'.code ){
				var p = line.charCodeAt(1);
				switch( p ){
					case ':'.code:
						var s = line.substr(3);
						if( e.cRef == null )
							e.cRef = s;
						else
							e.cRef += "\n"+s;
					case '.'.code:
						var s = line.substr(3);
						if( e.cExtracted == null )
							e.cExtracted = s;
						else
							e.cExtracted += "\n"+s;
					case ','.code:
						var s = line.substr(3);
						if( e.cFlags == null )
							e.cFlags = s;
						else
							e.cFlags += "\n"+s;
					case '|'.code:
						var s = line.substr(3);
						if( e.cPrevious == null )
							e.cPrevious = s;
						else
							e.cPrevious += "\n"+s;
					case '~'.code:
						var s = line.substr(3);
						if( e.cComment == null )
							e.cComment = s;
						else
							e.cComment += "\n"+s;
					case ' '.code:
						var s = line.substr(2);
						if( e.cTranslator == null )
							e.cTranslator = s;
						else
							e.cTranslator += "\n"+s;
					default:
						throw "Parse error line "+lnum;
				}
			}else if( StringTools.startsWith(line, "msgid ") ){
				e.msgid = line;
				e.id = getString(line,lnum);
			}else if( StringTools.startsWith(line, "msgstr ") ){
				e.msgstr = line;
				e.str = getString(line,lnum);
			}else{
				throw "Parse error line "+lnum;
			}
		}
		return arr;
	}

	public static function mkHeaders( headers : Map<String,String> ) : POEntry {
		var str = 'msgstr ""';
		for( k in headers.keys() )
			str += '\n"'+k+': '+headers.get(k)+'\\n"';

		return {
			id: "",
			str: null,
			msgstr: str,
		};
	}

	public static function exportFile( filePath : String, data : POData ){
		var fp = sys.io.File.write(filePath, true);
		export(fp,data);
		fp.close();
	}

	public static function exportTranslatedFile( potFilePath:String, refPoFilePath:String, data:POData ){
		var refData = parseFile( refPoFilePath );
		var expData : POData = [];
		var mref = new Map<String,{change: Bool, ref: POEntry, refid: Array<String>}>();
		for( entry in data ){
			if( entry.id == "" ){
				expData.push( entry );
				continue;
			}

			var refEntry = Lambda.find(refData,function(e) return e.id == entry.id);
			var change = false;
			var refid = null;
			if( refEntry != null && refEntry.str != "" ){
				change = refEntry.str != refEntry.id;
				if( entry.cExtracted != null )
					refid = entry.cExtracted+"\n\n--------\n"+refEntry.msgid;
				else
					refid = "--------\n"+refEntry.msgid;
				entry.msgid = null;
				entry.id = refEntry.str;
			}

			if( mref.exists(entry.id) ){
				var mEntry = mref.get( entry.id );
				if( refid != null ){
					mEntry.refid.push(refid);
					if( change )
						mEntry.change = true;
				}
			}else{
				var r = refid==null ? [] : [refid];
				mref.set( entry.id, {change: change, ref: entry, refid: r} );
				expData.push( entry );
			}
		}
		for( o in mref ){
			if( !o.change )
				continue;
			o.ref.cExtracted = o.refid.join("\n");
		}
		exportFile(potFilePath.split(".pot").join("-translated.pot"), expData);
	}

	public static function export( out: haxe.io.Output, data : POData ){
		var ids = new Map<String,Bool>();

		for( e in data ){
			if( e.cTranslator != null )
				out.writeString("# "+e.cTranslator.split("\n").join("\n# ")+"\n");
			if( e.cExtracted != null )
				out.writeString("#. "+e.cExtracted.split("\n").join("\n#. ")+"\n");
			if( e.cRef != null )
				out.writeString("#: "+e.cRef.split("\n").join("\n#: ")+"\n");
			if( e.cFlags != null )
				out.writeString("#, "+e.cFlags.split("\n").join("\n#, ")+"\n");
			if( e.cPrevious != null )
				out.writeString("#| "+e.cPrevious.split("\n").join("\n#| ")+"\n");
			if( e.cComment != null )
				out.writeString("#~ "+e.cComment.split("\n").join("\n#~ ")+"\n");

			var id = null;
			if( e.msgid != null ){
				out.writeString(e.msgid+"\n");
				id = getMultiString(e.msgid,0);
			}else if( e.id != null ){
				e.msgid = "msgid "+wrapQuote(e.id);
				out.writeString(e.msgid+"\n");
				id = e.id;
			}

			if( id != null ){
				#if gettext_warning
				if( ids.exists(id) )
					Sys.println("Warning: duplicate id in pot: "+id);
				#end
				ids.set(id,true);
			}

			if( e.msgstr != null ){
				out.writeString(e.msgstr+"\n");
			}else if( e.str != null ){
				e.msgstr = "msgstr "+wrapQuote(e.str);
				out.writeString(e.msgstr+"\n");
			}

			out.writeString("\n");
		}
		out.writeString("\n");
	}

	static var REG_STRING = ~/"((\\"|[^"]+)*)"$/;
	static function getString( line : String, lnum:Int ){
		if( !REG_STRING.match(line) )
			throw "Parse error line "+lnum+ "("+line+")";
		return REG_STRING.matched(1);
	}

	public static function getMultiString( lines : String, lnum ) {
		return lines.split("\n").map(function(s) return getString(s,lnum++)).join("");
	}

	public static function wrapQuote( str : String ){
		var arr = [str];
		var i = 0;
		while( arr[i].length > 72 ){
			var s = arr[i];
			var cut = s.indexOf(" ",72);
			if( cut < 0 || cut >= s.length -1 )
				break;
			arr[i] = s.substr(0,cut+1);
			arr[i+1] = s.substr(cut+1);
			i++;
		}
		if( arr.length > 1 )
			arr.unshift("");

		return arr.map(quote).join("\n");
	}

	public static function quote( str : String ){
		return '"'+str+'"';
	}

	public static function unescape( str : String ){
		return str.split('\\"').join('"').split("\\n").join("\n").split("\\\\").join("\\");
	}

	public static function escape( str : String ){
		return str.split("\\").join("\\\\").split("\n").join("\\n").split('"').join('\\"');
	}

	public static function cloneEntry( e : POEntry ) : POEntry {
		var ne : POEntry = {
			id: e.id,
			str: e.str,
		};

		if( e.msgid != null ) ne.msgid = e.msgid;
		if( e.msgstr != null ) ne.msgstr = e.msgstr;
		if( e.cTranslator != null ) ne.cTranslator = e.cTranslator;
		if( e.cExtracted != null ) ne.cExtracted = e.cExtracted;
		if( e.cRef != null ) ne.cRef = e.cRef;
		if( e.cFlags != null ) ne.cFlags = e.cFlags;
		if( e.cPrevious != null ) ne.cPrevious = e.cPrevious;
		if( e.cComment != null ) ne.cComment = e.cComment;

		return ne;
	}

}

#end
