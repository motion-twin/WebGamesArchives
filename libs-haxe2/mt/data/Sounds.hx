package mt.data;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class Sounds {

	@:macro public static function directory( dir : String ) {
		var p = Context.currentPos();
		var sounds = [];
		var r_names = ~/[^A-Za-z0-9]+/g;
		for( cp in Context.getClassPath() ) {
			var path = cp+dir;
			if( !sys.FileSystem.exists(path) || !sys.FileSystem.isDirectory(path) )
				continue;
			for( f in sys.FileSystem.readDirectory(path) ) {
				var ext = f.split(".").pop().toLowerCase();
				if( ext != "wav" && ext != "mp3" ) continue;
				var name = f.substr(0,f.length-4);
				name = r_names.replace(name,"_");
				var cl = { pack : ["sfx"], name : "S"+name, params : [] };
				var t = {
					pos : p,
					pack : cl.pack,
					name : cl.name,
					meta : [{ name : ":sound", pos : p, params : [{ expr : EConst(CString(dir+"/"+f)), pos : p }] }],
					params : [],
					isExtern : false,
					fields : [],
					kind : TDClass({ pack : ["flash","media"], name : "Sound", params : [] }),
				};
				Context.defineType(t);
				sounds.push({ field : name, expr : { expr : ENew(cl,[]), pos : p } });
			}
		}
		return { pos : p, expr : EObjectDecl(sounds) };
	}

}