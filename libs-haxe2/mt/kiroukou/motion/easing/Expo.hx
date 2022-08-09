package mt.kiroukou.motion.easing;

class Expo implements haxe.Public {
	inline static function easeIn ( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return ( t == 0 ) ? b : c * Math.pow( 2, 10 * ( t / d - 1 ) ) + b;
	}
	
	inline static function easeOut ( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return ( t == d ) ? b + c : c * ( -Math.pow( 2, -10 * t / d ) + 1 ) + b;
	}
	
	inline static function easeInOut ( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		if ( t == 0 )
			return b;
		if ( t == d )
			return b + c;
		if ( ( t /= d / 2 ) < 1 )
			return c / 2 * Math.pow( 2, 10 * ( t - 1 ) ) + b;
		return c / 2 * ( -Math.pow( 2, -10 * --t ) + 2 ) + b;
	}
}
