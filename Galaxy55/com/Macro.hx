#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

@:macro class Macro {

	public static function generate( e : Expr ) {
		var el = switch( e.expr ) {
		case EBlock(el): el;
		default: [e];
		}
		var out = [];
		for( e in el ) {
			var p = e.pos;
			switch( e.expr ) {
			case EVars(_):
				out.push(e);
			case EReturn(e):
				if( e != null )
					Context.error("No value allowed here", e.pos);
				break;
			default:
				out.push( { expr : ECall( { expr : EConst(CIdent("addStep")), pos : p }, [ { expr : EFunction(null, { ret : null, params : [], expr : e, args : [] } ), pos : p } ]), pos : p } );
			}
		}
		return { expr : EBlock(out), pos : e.pos };
	}
	
	public static function getModel( file : String ) {
		var p = Context.currentPos();
		var f = try Context.resolvePath(file) catch( e : Dynamic ) Context.error(Std.string(e), p);
		var i = sys.io.File.read(f);
		i.readByte();
		var count = i.readUInt30();
		var buf = [];
		for( x in 0...count*6 )
			buf.push( { expr : EConst(CFloat(Std.string(i.readFloat()))), pos : p } );
		i.close();
		return { expr : EArrayDecl(buf), pos : p };
	}
	
}