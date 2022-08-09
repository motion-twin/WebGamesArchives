package mt.gx.mcr;


import haxe.macro.Context;
import haxe.macro.Expr;


/**
 * ...
 * @author de
 */
class Tools
{
	//retrieves a const string and its pos from an expr
	public static function cs( e:Expr ) : { pos: Position, str: String}
	{
		return
		switch( e.expr )
		{
			case EConst( c ): 
				switch( c )
				{
					case CString( str ): {pos:e.pos,str:str};
					default:null;
				}
			default: null;
		}
	}
	
	public static function cls( e:Expr ) : { pos: Position, str: String}
	{
		return
		switch( e.expr )
		{
			case EConst( c ): 
				switch( c )
				{
					case CIdent( str ): {pos:e.pos,str:Std.string(str)};
					default:null;
				}
			default: null;
		}
	}
	
	/*
	public static function tp( e:Expr ) : { pos: Position, str: String}
	{
		var cur = "";
		return
		switch( e.expr )
		{
			case EType( c,field ):
				cur += field;
				switch( c.expr )
				{
					case EType(_,_):
						return { str:cur +"."+ tp( c ).str, pos:c.pos};
					case EConst( id ): 
						switch(id)
						{
							case CIdent( id ): return { str:id,pos:c.pos};
							case CString( id ): return { str:id,pos:c.pos};
							case CType( id ): return { str:id, pos:c.pos };
							default: return { str:"", pos:c.pos };
						}
					default:null;
				}
			default: null;
		}
	}
	*/
	public static function ffunc(f : Field) : Function
	{
		return switch( f.kind )
		{
			case FFun(f): f;
			default: null;
		}
	}
}