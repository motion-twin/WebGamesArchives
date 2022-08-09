package tools;

class EnumTools {
	inline public static function indexOf( e:Dynamic ) : Int {
		return Type.enumIndex(e);
	}

	inline public static function fromIndex( e:Enum<Dynamic>, v:Int ) : Dynamic {
		return Reflect.field(e, Type.getEnumConstructs(e)[v]);
	}

	inline public static function fromString( e:Enum<Dynamic>, v:String ) : Dynamic {
		return Reflect.field(e, v);
	}

	inline public static function sizeOf( e:Enum<Dynamic> ) : Int {
		return Type.getEnumConstructs(e).length;
	}

	inline public static function random( e:Enum<Dynamic>, ?rand:mt.Rand ) : Dynamic {
		return fromIndex(e, (rand == null) ? Std.random(sizeOf(e)) : rand.random(sizeOf(e)));
	}

	inline public static function foreach( e:Enum<Dynamic>, f:Dynamic->Void ) : Void {
		for (i in 0...sizeOf(e))
			f(fromIndex(e, i));
	}

	inline public static function compareIndex( a:Dynamic, b:Dynamic ) : Int {
		if (a == null && b == null)
			return 0;
		else if (a == null)
			return -1;
		else if (b == null)
			return 1;
		else
			return Reflect.compare(indexOf(a), indexOf(b));
	}
}
