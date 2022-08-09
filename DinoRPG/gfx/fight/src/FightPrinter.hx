package ;

/**
 * ...
 * @author Thomas
 */

class FightPrinter
{

	public static function toString( v : Dynamic ) {
		var s = new StringBuf();
		switch( Type.typeof(v) ) {
		case TObject:
			s.add("{");
			var first = true;
			for( f in Reflect.fields(v) ) {
				if( first ) {
					s.add(" ");
					first = false;
				} else
					s.add(", ");
				s.add(f);
				s.add(" : ");
				s.add(FightPrinter.toString(Reflect.field(v,f)));
			}
			s.add("}");
		case TEnum(_):
			s.add(Type.enumConstructor(v));
			var l = Type.enumParameters(v);
			if( l.length > 0 ) {
				s.add("(");
				s.add(Lambda.map(l,FightPrinter.toString).join(", "));
				s.add(")");
			}
		case TClass(c):
			if( c == String ) {
				s.add('"');
				s.add(v);
				s.add('"');
			} else if( c == List ) {
				s.add("{ var l = new List();");
				var l : List<Dynamic> = v;
				for( x in l )
					s.add("l.add(" + FightPrinter.toString(x) + ");");
				s.add(" l; }");
			} else if( c == Array ) {
				s.add("[");
				s.add( Lambda.map(v,FightPrinter.toString).join(",") );
				s.add("]");
			} else
				s.add(Std.string(v));
		default:
			s.add(Std.string(v));
		}
		return s.toString();
	}
	
}