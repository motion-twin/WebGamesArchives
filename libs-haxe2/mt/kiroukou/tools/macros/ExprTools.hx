package mt.kiroukou.tools.macros;

import haxe.macro.Context;
import haxe.macro.Expr.ExprDef;
import haxe.macro.Expr;

using mt.kiroukou.tools.macros.ExprTools;
using mt.kiroukou.tools.macros.PosTools;
using Lambda;

class ExprTools {

	///single variable declaration
	static public inline function define(name:String, ?init:Expr, ?typ:ComplexType, ?pos:Position) {
		return at(EVars([ { name:name, type: typ, expr: init } ]), pos);
	}
	
	static public inline function field(e, field, ?pos) {
		return EField(e, field).at(pos);
	}
	
	static public inline function at(e:ExprDef, ?pos:Position) {
		return {
			expr: e,
			pos: pos.getPos(),
		}
	}
	
	static public inline function call(e, ?params, ?pos) {
		return ECall(e, params == null ? [] : params).at(pos);
	}
	
	static public inline function toExpr(v:Dynamic, ?pos:Position) {
		return Context.makeExpr(v, pos.getPos());
	}
	
	static public inline function toArray(exprs:Iterable<Expr>, ?pos) {
		return EArrayDecl(exprs.array()).at(pos);
	}
	
	static public inline function toMBlock(exprs, ?pos) {
		return EBlock(exprs).at(pos);
	}
	
	static public inline function toBlock(exprs:Iterable<Expr>, ?pos) {
		return toMBlock(Lambda.array(exprs), pos);
	}
	
	static inline function isUC(s:String) {
		return std.StringTools.fastCodeAt(s, 0) < 0x5B;
	}
	
	///builds an expression from an identifier path
	static public function drill(parts:Array<String>, ?pos) {
		var first = parts.shift();
		var ret = at(EConst(isUC(first) ? CType(first) : CIdent(first)), pos);
		for (part in parts)
			ret =	if (isUC(part))
						at(EType(ret, part), pos);
					else
						field(ret, part, pos);
		return ret;
	}
	
	///resolves a `.`-separated path of identifiers
	static public inline function resolve(s:String, ?pos) {
		return drill(s.split('.'), pos);
	}
	
	///attempts to extract the type of an expression
	static public function typeof(expr:Expr, ?locals) {
		if( locals != null )
			expr = [EVars(locals).at(expr.pos), expr].toMBlock(expr.pos);
		return Context.typeof(expr);
	}
}