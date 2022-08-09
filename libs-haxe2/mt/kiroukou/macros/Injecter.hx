package mt.kiroukou.macros;

/**
 * N'injecte pas les méthodes statiques !
 * @author Thomas
 */
import haxe.macro.Expr;
import haxe.macro.Context;

class Injecter
{
    @:macro public static function build(className:String) : Array<Field>
	{
        var pos = Context.currentPos();
        var fields = Context.getBuildFields();
		
		var builderFields = switch( Context.getType(className) )
		{
			case TInst(ref, params): ref.get().fields.get();
			default : Context.error("This type is not available for Injecter", pos);
		}
		
		if( builderFields == null ) return fields;
		
		var tvoid = macro : Void;
		var tstring = macro : String;
		
		for( bfield in builderFields )
		{
			var access = bfield.isPublic ? [APublic] : [];
			switch( bfield.kind )
			{
				case FVar(read, write):
					var expr = null;
					if( bfield.expr() != null )
						expr = Context.getTypedExpr(bfield.expr());
					
					switch( bfield.type )
					{
						case TInst( ref, params ) :
							var ref = ref.get();
							var ttype = TPath( { pack : ref.pack, name : ref.name, params : [], sub : null } );
							fields.push( { name : bfield.name, doc : null, meta : [], access : access, kind : FVar(ttype, expr), pos : pos } );
						default: Context.error("Unsupported field type for "+bfield.name+" : "+bfield.type, pos);
					}
				case FMethod(kind):
					var expr = Context.getTypedExpr(bfield.expr()).expr;
					switch( expr )
					{
						case EFunction(name, f):
							
							fields.push( { name : bfield.name, doc : null, meta : [], access : access, kind :FFun( { args:f.args, ret:f.ret, expr:f.expr, params:f.params } ), pos : pos } );
						default:
					}
			}
		}
	
        return fields;
    }
}