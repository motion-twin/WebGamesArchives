package mt.kiroukou.tools.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

class PosTools
{

	static public inline function getPos(pos:Position) {
		return
			if (pos == null)
				Context.currentPos();
			else
				pos;
	}
	
	static public inline function error(pos:Position, error:Dynamic):Dynamic {
		return Context.error(Std.string(error), pos);
	}
	
}