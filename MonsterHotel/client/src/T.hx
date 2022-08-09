#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

typedef LangDb = Map<String, {
	value		: String,
	trashed		: Bool,
}>;

class T {
	static var TODO = "TODO";
	static var DB : Map<String, LangDb> = new Map();

	#if !macro

	static var LANG : String = null;
	static var FALLBACK : String = null;

	#else

	static var PATH = "./";
	static var PARSED : LangDb = new Map();

	static function initMacro() {
		PARSED = new Map();
		Context.onGenerate( onCompilationEnd );
		return true;
	}

	static inline function makeFileName(lang:String) {
		return PATH + "texts."+lang+".po";
	}

	#end

	/*
	macro public static function load(path:ExprOf<String>, langs:Array<String>) {
		switch( path.expr ) {
			case EConst(CString(s)) :
				s = StringTools.replace(s, "\\", "/");
				if( s.substr(s.length-1) != "/" )
					s+="/";
				PATH = s;

			default :
				error("Only constant String here");
		}

		var module = switch( Context.getLocalType() ) {
			case TInst(c, _): c.get().module;
			case TEnum(e, _): e.get().module;
			case TType(t, _): t.get().module;
			default: null;
		}

		initMacro();

		var initBlock : Array<Expr> = [];
		var p = Context.currentPos();

		for(l in langs) {
			var f = makeFileName(l);
			f = createFileIfNotFound(f);
			Context.registerModuleDependency(module, f);

			// Load existing data
			var content = getFileContent(f);
			DB.set(l, content);

			// Runtime DB init
			var el = {expr:EConst(CString(l)), pos:p};
			initBlock.push( macro mt.deepnight.T.DB.set($el, new Map()) );

			// Add runtime declarations
			for( k in DB.get(l).keys() ) {
				var ek = {expr:EConst(CString(k)), pos:p};
				var ev = {expr:EConst(CString(DB.get(l).get(k).value)), pos:p};
				initBlock.push( macro mt.deepnight.T.DB.get($el).set($ek, {value:$ev, trashed:false}) );
			}
		}

		var eblock = { pos:p, expr:EBlock(initBlock) }

		return macro {
			var t = new T();
			t.dbId = dbId;
			$eblock;
			t;
		}
	}*/


	macro public static function init(path:ExprOf<String>, langs:Array<String>) {

		switch( path.expr ) {
			case EConst(CString(s)) :
				s = StringTools.replace(s, "\\", "/");
				PATH = s;

			default :
				error("Only constant String here");
		}

		var module = switch( Context.getLocalType() ) {
			case TInst(c, _): c.get().module;
			case TEnum(e, _): e.get().module;
			case TType(t, _): t.get().module;
			default: null;
		}

		initMacro();


		// Path clean up & verification
		var found = false;
		for(p in Context.getClassPath() )
			if( sys.FileSystem.exists(p+PATH) ) {
				PATH = p + PATH;
				found = true;
				break;
			}

		if( !found )
			error("Directory not found: "+PATH, path.pos);

		if( PATH.substr(PATH.length-1) != "/" )
			PATH+="/";



		var block : Array<Expr> = [];
		var pos = Context.currentPos();

		for(l in langs) {
			var f = makeFileName(l);
			f = createFileIfNotFound(f);
			Context.registerModuleDependency(module, f);

			// Load existing data
			var content = getFileContent(f);
			DB.set(l, content);

			// Runtime DB init
			var el = {expr:EConst(CString(l)), pos:pos};
			block.push( macro mt.deepnight.T.DB.set($el, new Map()) );

			// Add runtime declarations
			for( k in DB.get(l).keys() ) {
				var ek = {expr:EConst(CString(k)), pos:pos};
				var ev = {expr:EConst(CString(DB.get(l).get(k).value)), pos:pos};
				block.push( macro mt.deepnight.T.DB.get($el).set($ek, {value:$ev, trashed:false}) );
			}
		}

		return {
			expr : EBlock(block),
			pos	: Context.currentPos(),
		}
	}

	#if !macro
	public static function setCurrentLang(l:String, ?preferedFallback:String) {
		LANG = l;

		if( preferedFallback!=null )
			if( DB.exists(preferedFallback) )
				FALLBACK = preferedFallback;
			else
				throw "Unknown language "+preferedFallback;
	}

	public static function resolve(k:String) {
		if( !DB.exists(LANG) || !DB.get(LANG).exists(k) || DB.get(LANG).get(k).value==TODO ) {
			if( !DB.exists(FALLBACK) || !DB.get(FALLBACK).exists(k) || DB.get(FALLBACK).get(k).value==TODO )
				return k;
			else
				return DB.get(FALLBACK).get(k).value;
		}

		if( LANG!=null )
			return DB.get(LANG).get(k).value;
		else
			return k;
	}
	#end

	macro public static function get(text:ExprOf<String>, ?data:Dynamic) {
		var pos = Context.currentPos();
		var k = switch( text.expr ) {
			case EConst( CString(k) ) : k;
			default :
				error("Unexpected expression ("+text.expr+")", text.pos);
		}

		PARSED.set(k, {value:"", trashed:false});

		var exists = true;
		for( db in DB )
			if( !db.exists(k) ) {
				exists = false;
				break;
			}
		//if( !exists )
			//warning("New entry found: "+k, text.pos);

		var ek = {expr:EConst(CString(k)), pos:pos}
		return macro mt.deepnight.T.resolve($ek);
	}


	#if macro
	static function error(str:String, ?pos:Position) {
		Context.error(str, pos==null ? Context.currentPos() : pos);
		return null;
	}

	static function warning(str:String, ?pos:Position) {
		Context.warning(str, pos==null ? Context.currentPos() : pos);
	}


	static function createFileIfNotFound(file:String) {
		try {
			file = Context.resolvePath(file);
		}
		catch( e : Dynamic ) {
			try {
				sys.io.File.saveContent(file, "");
			}
			catch( e:Dynamic ) {
				error("Couldn't create "+file+"!");
			}
			file = Context.resolvePath(file);
		}
		return file;
	}



	static function getFileContent(file:String) : LangDb {
		try file = Context.resolvePath(file) catch( e : Dynamic ) error("File not found: "+file);
		var content = sys.io.File.getContent(file);
		var pos : Position = Context.currentPos(); // TODO

		var lang : LangDb = new Map();

		var id = null;
		var trash = false;
		for( line in content.split("\n") ) {
			if( line.indexOf("msgid")>=0 ) {
				trash = false;
				id = line.split("\"")[1];
				lang.set(id, {value:TODO, trashed:false});
			}

			if( line.indexOf("#. msgid")>=0 ) {
				trash = true;
				id = line.split("\"")[1];
				lang.set(id, {value:TODO, trashed:false});
			}

			if( line.indexOf("msgstr")>=0 ) {
				if( id==null )
					error("Missing id", pos);
				var v = line.split("\"")[1];
				lang.set(id, {value:v, trashed:trash});
			}
		}
		//var xml = new haxe.xml.Fast( haxe.xml.Parser.parse(content).firstChild() );
		//
		//for( n in xml.nodes.t )
			//lang.set(n.att.id, n.innerHTML);

		return lang;
	}


	static function writeFile(file:String, content:String) {
		try file = Context.resolvePath(file) catch( e : Dynamic ) error("File not found: "+file);
		sys.io.File.saveContent(file, content);
	}

	static function sort(h:Map<String,String>) {
		var arr = [];
		for( k in h.keys() )
			arr.push({ k:k, v:h.get(k) });
		arr.sort( function(a,b) return Reflect.compare(a.k, b.k) );
		return arr;
	}


	static function checkLang(l:String) {
		var file = makeFileName(l);
		var needRewrite = false;

		var onDisk = getFileContent(file);
		var actives = new Map();
		var trash = new Map();

		for( k in PARSED.keys() ) {
			var v = PARSED.get(k);
			var od = onDisk.get(k);

			if( onDisk.exists(k) && !od.trashed && od.value==TODO ) {
				// Existing TODOs
				actives.set(k, od.value);
			}
			else if( !onDisk.exists(k) ) {
				// New texts
				actives.set(k, TODO);
				needRewrite = true;
			}
			else if( od.trashed ) {
				// Back from trash
				actives.set(k, od.value);
				needRewrite = true;
			}
			else {
				// Not modified
				actives.set(k, od.value);
			}

		}


		for( k in onDisk.keys() ) {
			var od = onDisk.get(k);
			// Orphaned texts
			if( !PARSED.exists(k) && !od.trashed ) {
				if( od.value!=TODO ) // Delete if it's a TODO entry
					trash.set(k, od.value);
				needRewrite = true;
			}

			// Existing trash
			if( od.trashed && od.value!=TODO && !PARSED.exists(k) )
				trash.set(k, od.value);
		}

		// Write the file
		if( needRewrite ) {
			var p = Context.makePosition({min:0, max:0, file:file});
			//warning("Rebuilding (func) "+l+"...", p);
			var lines = [];

			for( e in sort(actives) ) {
				lines.push("msgid \""+e.k+"\"");
				lines.push("msgstr \""+e.v+"\"");
				lines.push("");
			}

			lines.push("#. ---------------------------------------- TRASH");
			for( e in sort(trash) ) {
				lines.push("#. msgid \""+e.k+"\"");
				lines.push("#. msgstr \""+e.v+"\"");
				lines.push("");
			}


			writeFile(file, lines.join("\n"));
		}
	}


	static function onCompilationEnd(types:Array<haxe.macro.Type>) {
		for( k in DB.keys() )
			checkLang(k);
	}

	#end
}

