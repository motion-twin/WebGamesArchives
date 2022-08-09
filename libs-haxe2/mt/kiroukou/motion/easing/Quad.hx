package mt.kiroukou.motion.easing;

class Quad implements haxe.Public {
	inline static function easeIn ( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return c * ( t /= d ) * t + b;
	}
	
	inline static function easeOut ( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return -c * ( t /= d ) * ( t - 2 ) + b;
	}
	
	inline static function easeInOut ( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		if ( ( t /= d / 2 ) < 1 )
			return c / 2 * t * t + b;
		return -c / 2 * ( ( --t ) * ( t - 2 ) - 1 ) + b;
	}
}
