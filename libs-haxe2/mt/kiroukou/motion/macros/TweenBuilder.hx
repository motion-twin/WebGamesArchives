package mt.kiroukou.motion.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

using mt.kiroukou.tools.macros.MacroTools;
using mt.kiroukou.tools.macros.PosTools;
using mt.kiroukou.tools.macros.ExprTools;

/**
 * TODO :
 * components
 */
class TweenBuilder {
	
	public static function build( target : Expr, exprs:Array<haxe.macro.Expr>, ?locals ) : Expr {
		var pos = Context.currentPos();
		if( exprs.length == 0 )
			haxe.macro.Context.error('at least one argument required', pos);
		var ret:Array<Expr> = [];
		while( exprs.length > 0 ) {
			var e = exprs.pop();
			switch(e.expr ) {
				case EBinop(op, e1, e2 ):
					ret.push( switch(op) {
							case OpAssign:
								var name = e1.getIdent();
								var eprop = target.field(name);
								//TODO Handle other kind of properties with Plugins
								macro mt.kiroukou.motion.Tween.FloatProperty.get( function() { return $eprop; }, function(p:Float) { return $eprop = p; }, $e2 );
							default:
								pos.error('cannot handle ' + op);
							});
				default:
					pos.error('cannot handle '+e);
			}
		}
		return { expr : EArrayDecl(ret), pos : pos };
	}
	
}
