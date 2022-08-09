package mt.deepnight.deprecated.assets;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class AssetTools {
	#if macro
	public static function error( ?msg="", p : Position ) {
		haxe.macro.Context.error(msg, p);
	}

	public static function warning( ?msg="", p : Position ) {
		haxe.macro.Context.warning(msg, p);
	}
	#end

	public static function cleanUpString(s:String) {
		var r = ~/[^a-z]/gi;
		return r.replace(s,"_");
	}
}