package tipyx;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Tipyx
 */

/*
 * Put this class somewhere in your code and change the path of your asset directory
 * @:build(tipyx.AssetNamesBuilder.build("assets/"))
 * class AssetName {
 * 		
 * }
 */

class AssetNamesBuilder
{
	public static function build(path:String):Array<Field> {
		if ( path.substr( -1, 1) == "/" )
			path = path.substr(0, path.length - 1);
		var fileNames = sys.FileSystem.readDirectory(path);
		
        var fields = Context.getBuildFields();
		
		for (f in fileNames) {
			var name = f.split("-").join("_").split(".").join("__");

			if (sys.FileSystem.isDirectory(path+"/" + f)) {
				fields.push({
					name:name,
					access:[Access.APublic, Access.AStatic],
					pos:Context.currentPos(),
					kind:FieldType.FVar(null, {pos: Context.currentPos(), expr: EObjectDecl( buildRec(path+"/"+f) ) })
				});
			}
			else {
				
				fields.push({
					name:name,
					access:[Access.APublic, Access.AStatic, Access.AInline],
					pos:Context.currentPos(),
					kind:FieldType.FVar(macro:String, macro $v{f})
				});
			}
		}
		
        return fields;
	}
	
	#if macro
	static function buildRec( path ) : Array<{field: String, expr: Expr}> {
		var arr = [];
		for ( f in sys.FileSystem.readDirectory(path) ) {
			if ( sys.FileSystem.isDirectory(path + "/" + f) ) {
				arr.push( {
					field: f.split("-").join("_").split(".").join("__"),
					expr: {pos:Context.currentPos(), expr:EObjectDecl(buildRec(path+"/"+f))}
				});
			}else {
				arr.push( {
					field: f.split("-").join("_").split(".").join("__"),
					expr: macro $v{path+"/"+f}
				});
			}
		}
		return arr;
	}
	#end
}