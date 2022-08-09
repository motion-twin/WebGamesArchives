package mt.gx;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.Timer;


class Macros {
    macro static public function getClassName():ExprOf<String> {
        return { expr: EConst(CString(Context.getLocalClass().toString())), pos: Context.currentPos() }
    }
	
	macro static public function getSvnRevision() {
		var nb : String;
		var execSvn = Sys.command("svn info > __svn.txt");
		var t = sys.io.File.getContent("__svn.txt");
		
		if ( t.length == 0 ){
			nb = "-2";
			trace("cannot access SVN repository or command line");
		}
		else {
			var lit = "Revision:";
			nb = Std.string(Std.parseInt(t.substr(t.indexOf(lit)+1+lit.length)));
		}
		
		#if windows
		Sys.command("del /F __svn.txt");
		#else
		Sys.command("rm -rf __svn.txt");
		#end
		
		return { expr: EConst(CInt(nb)), pos: Context.currentPos() }
	}
	
	macro static public function getGitRevision() {
		var rev : String;
		var execSvn = Sys.command("git rev-parse HEAD > __git.txt");
		var t = sys.io.File.getContent("__git.txt");
		
		if ( t.length == 0 ){
			rev = "ERROR";
			trace("cannot access git repository or command line");
		}
		else {
			rev = t;
		}
		
		#if windows
		Sys.command("del /F __git.txt");
		#else
		Sys.command("rm -rf __git.txt");
		#end
		
		return { expr: EConst(CString(rev)), pos: Context.currentPos() }
	}
	
	macro static public function crc32( str : String )  {
        return { expr: EConst(CInt( Std.string(haxe.crypto.Crc32.make( haxe.io.Bytes.ofString(str))))), pos: Context.currentPos() };
    }
}

