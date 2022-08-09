package mt.kiroukou.motion.easing;

class Linear implements haxe.Public {
	inline static function easeNone( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return c * t / d + b;
	}
	
	inline static function easeIn( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return c * t / d + b;
	}
	
	inline static function easeOut( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return c * t / d + b;
	}
	
	inline static function easeInOut ( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return c * t / d + b;
	}
}
