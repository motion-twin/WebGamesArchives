package mt.kiroukou.motion.easing;

class Quart implements haxe.Public {
	inline static function easeIn( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return c * ( t /= d ) * t * t * t + b;
	}
	
	inline static function easeOut( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return -c * ( ( t = t / d - 1 ) * t * t * t - 1 ) + b;
	}
	
	inline static function easeInOut( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		if ( ( t /= d / 2 ) < 1 )
			return c / 2 * t * t * t * t + b;
		return -c / 2 * ( ( t -= 2 ) * t * t * t - 2) + b;
	}
}
