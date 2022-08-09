package mt.deepnight;

import haxe.macro.Expr;
import haxe.macro.Context;

class MacroTools {
	public static macro function error(err:ExprOf<String>) {
		var pos = haxe.macro.Context.currentPos();
		switch( err.expr ) {
			case EConst(CString(s)) : Context.error(s, pos);
			default :
		}

		return {pos:pos, expr:EBlock([])}
	}

	public static macro function getBuild(pathToBuildFile:ExprOf<String>, preIncrement:ExprOf<Bool>) {
		var pos = Context.currentPos();
		var path = switch( pathToBuildFile.expr ) {
			case EConst(CString(s)) : s;
			default : Context.error("Constant expected here", pathToBuildFile.pos);
		}
		var inc = switch( preIncrement.expr ) {
			case EConst(CIdent(v)) : v=="true";
			default : false;
		}

		try {
			path = try Context.resolvePath(path) catch(e:Dynamic) { Context.error("Build file not found: "+path, pathToBuildFile.pos); }
			var v = sys.io.File.getContent(path);
			if( inc ) {
				v = Std.string( Std.parseInt(v)+1 );
				sys.io.File.saveContent(path, v);
			}
			return {pos:pos, expr:EConst(CInt( v ))}
		}
		catch(e:Dynamic) {
			Context.error("Couldn't read build file: "+path, pathToBuildFile.pos);
			return {pos:pos, expr:EConst(CInt("-1"))}
		}
	}


	public static macro function getBuildDate() {
		var pos = Context.currentPos();
		var d = Date.now();
		var months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
		return { pos:pos, expr:EConst(CString(months[d.getMonth()]+DateTools.format(d, " %d (%H:%M)"))) }
	}
}
