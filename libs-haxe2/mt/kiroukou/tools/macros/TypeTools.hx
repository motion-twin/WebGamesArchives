package mt.kiroukou.tools.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using mt.kiroukou.tools.macros.ExprTools;

class TypeTools
{
	static var types = new IntHash<Type>();
	static var idCounter = 0;
	
	@:macro static public function getType(id:Int):Type
	{
		return types.get(id);
	}
	
	static public function register(type:Type):Int
	{
		var id = idCounter++;
		types.set(id, type);
		return id;
	}
	
	static public function toType(t:ComplexType, ?pos)
	{
		return [
			'_'.define(t, pos),
			'_'.resolve(pos)
		].toBlock(pos).typeof();
	}
	
	static public inline function instantiate(t:TypePath, ?args, ?pos)
	{
		return ENew(t, args == null ? [] : args).at(pos);
	}
	
	
	static public function asTypePath(s:String, ?params):TypePath
	{
		var parts = s.split('.');
		var name = parts.pop(), sub = null;
		if (parts.length > 0 && parts[parts.length - 1].charCodeAt(0) < 0x5B)
		{
			sub = name;
			name = parts.pop();
		}
		
		return {
			name: name,
			pack: parts,
			params: params == null ? [] : params,
			sub: sub
		}
	}
	
	static public inline function asComplexType(s:String, ?params)
	{
		return TPath(asTypePath(s, params));
	}
	
	static public inline function reduce(type:Type, ?once)
	{
		return Context.follow(type, once);
	}
	
	static public function isVar(field:ClassField)
	{
		return switch (field.kind)
		{
			case FVar(_, _): true;
			default: false;
		}
	}
	
	static public function getID(t:Type)
	{
		return
		switch( reduce(t) ) {
				case TInst(t, _): t.toString();
				case TEnum(t, _): t.toString();
				default: null;
			}
	}
	
	static public function toComplex(type:Type):ComplexType
	{
		return  TPath({
					pack : ['haxe','macro'],
					name : 'MacroType',
					params : [TPExpr('mt.kiroukou.tools.macros.TypeTools.getType'.resolve().call([register(type).toExpr()]))],
					sub : null,
				});
	}
}