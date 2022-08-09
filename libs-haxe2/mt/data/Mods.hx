package mt.data;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class Mods {

	@:macro public static function parseODS( efile : Expr, sheet : Expr, t : Expr ) {
		Context.error("DEPRECATED, use ods.Data.parse instead",Context.currentPos());
		return null;
	}

	@:macro public static function build( params : Array<Expr> ) : Array<Field> {
		Context.error("DEPRECATED, use ods.Data.build instead",Context.currentPos());
		return null;
	}

	@:macro public static function buildComplex( params : Array<Expr> ) : Array<Field> {
		Context.error("DEPRECATED, use ods.Data.buildComplex instead",Context.currentPos());
		return null;
	}

}