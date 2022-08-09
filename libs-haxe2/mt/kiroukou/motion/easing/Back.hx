package mt.kiroukou.motion.easing;

class Back implements haxe.Public {
	inline static function easeIn( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return c * ( t /= d ) * t * ( ( 1.70158 + 1 ) * t - 1.70158 ) + b;
	}
	
	inline static function easeOut( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return c * ( ( t = t / d - 1 ) * t * ( ( 1.70158 + 1 ) * t + 1.70158 ) + 1 ) + b;
	}
	
	inline static function easeInOut( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		var s = 1.70158; 
		if ( ( t /= d / 2 ) < 1 )
			return c / 2 * ( t * t * ( ( ( s *= ( 1.525 ) ) + 1 ) * t - s ) ) + b;
		return c / 2 * ( ( t -= 2 ) * t * ( ( ( s *= ( 1.525 ) ) + 1 ) * t + s ) + 2 ) + b;
	}
}
