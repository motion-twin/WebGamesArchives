
import haxe.macro.Expr;
import haxe.macro.Context;


class Media {//}
	

	public static function embedAll(dir) {
		var p = Context.currentPos();
		var r_names = ~/[^A-Za-z0-9]+/g;
		for( cp in Context.getClassPath() ) {
			var path = cp+dir;
			if( !sys.FileSystem.exists(path) || !sys.FileSystem.isDirectory(path) )
				continue;
			for( f in sys.FileSystem.readDirectory(path) ) {
				var ext = f.split(".").pop().toLowerCase();
				
				var name = f.substr(0,f.length-4);
				name = r_names.replace(name, "_");
				var cl = { pack : [dir], name : name, params : [] };
				
				switch(ext) {
					case "png", "bmp" :	// BITMAP
						var t = {
							pos : p,
							pack : cl.pack,
							name : cl.name,
							meta : [{ name : ":bitmap", pos : p, params : [{ expr : EConst(CString(dir+"/"+f)), pos : p }] }],
							params : [],
							isExtern : false,
							fields : [],
							kind : TDClass({ pack : ["flash","display"], name : "BitmapData", params : [] }),
						};
						Context.defineType(t);
						
					case "wav", "mp3" :	// SOUNDS
						
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
				
				}
			}
		}
	}


//{
}


