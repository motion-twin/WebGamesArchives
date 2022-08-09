package mt.motion.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Printer;
/**
 * TODO : components
 * Color, sound, filters...
 */
class TweenBuilder
{
	/*
	
	public static function getRelativeObjects(e:Expr, a:Array<Expr>)
	{
		switch(e.expr) {
			case EConst(CString(s)):
				// handle s
			case _:
				ExprTools.iter(e, getRelativeObjects, a);
			}
		}
	}
	*/
	
	public static function build( exprs:Array<haxe.macro.Expr> ) : Expr
	{
		var p = new Printer();
		inline function logExpr(e)
		{
			#if debug
			//trace(p.printExpr(e));
			#end
		}
		
		var pos = Context.currentPos();
		if( exprs.length == 0 )
			haxe.macro.Context.error('at least one argument required', pos);
		
		var ret:Array<Expr> = [];
		while ( exprs.length > 0 ) 
		{
			var e = exprs.pop();
			var tweenExpr = switch(e.expr ) 
			{
			//TODO retrouver l'objet sur lequel le tween est appliqué (avec un split sur l'expr $e1?  vérifier qu'il n'est pas nul sur les get/set
			//en profiter pour faire des tests sur le fait que la prop existe si possible, et le cas échéant tester si une extension de tween le permet (color, shake etc)
				case EBinop( OpAssign, e1, e2 ):
					logExpr(e1);
					var fieldName, objectInst;
					
					function findField(e:Expr) {
						switch(e.expr) {
							case EConst(CIdent(field)):
								fieldName = field;
								objectInst = macro null;
							case EField(e, field):
								fieldName = field;
								objectInst = e;
							case _:
								haxe.macro.ExprTools.iter(e, findField);
						}
					}
					findField(e1);
					logExpr(objectInst);
					macro mt.motion.Tween.FloatProperty.get($e { objectInst }, $v { fieldName }, function() { return $e1; }, function(p_:Float) { return $e1 = p_; }, $e2 );
					
				case EBinop( OpAssignOp(op), e1, e2 ):
					logExpr(e1);
					
					var fieldName, objectInst;
					
					function findField(e:Expr) {
						switch(e.expr) {
							case EConst(CIdent(field)):
								fieldName = field;
								objectInst = macro null;
								
							case EField(e, field):
								fieldName = field;
								objectInst = e;
							case _:
								haxe.macro.ExprTools.iter(e, findField);
						}
					}
					findField(e1);
					
					var tvalue = switch( op ) {
						case OpAdd: macro ($e1 + $e2);
						case OpSub: macro ($e1 - $e2);
						default: Context.error("Operator not supported", pos);
					}
					logExpr(objectInst);
					macro mt.motion.Tween.FloatProperty.get( $e { objectInst }, $v { fieldName }, function() { return $e1; }, function(p_:Float) { return $e1 = p_; }, $tvalue );
					
				default:
					Context.error('cannot handle ' + e, pos );
			}
			logExpr(tweenExpr);
			ret.push(tweenExpr);
		}
		return { expr : EArrayDecl(ret), pos : pos };
	}
	
}
