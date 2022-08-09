package mt.kiroukou.motion.easing;

class Bounce implements haxe.Public {
	inline static function easeOut ( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		if ( ( t /= d ) < ( 1 / 2.75 ) )
			return c * ( 7.5625 * t * t ) + b;
		else if ( t < ( 2 / 2.75 ) )
			return c * ( 7.5625 * ( t -= ( 1.5 / 2.75 ) ) * t + .75 ) + b;
		else if ( t < ( 2.5 / 2.75 ) )
			return c * ( 7.5625 * ( t -= ( 2.25 / 2.75 ) ) * t + .9375 ) + b;
		else
			return c * ( 7.5625 * ( t -= ( 2.625 / 2.75 ) ) * t + .984375 ) + b;
	}
	
	inline static function easeIn ( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return c - easeOut ( d - t, 0, c, d ) + b;
	}
	
	inline static function easeInOut ( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		if ( t < d / 2 )
			return easeIn ( t * 2, 0, c, d ) * .5 + b;
		else
			return easeOut ( t * 2 - d, 0, c, d ) * .5 + c *.5 + b;
	}
}
