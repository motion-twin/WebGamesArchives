package mt.kiroukou.motion.easing;

class Sine implements haxe.Public {
	inline static function easeIn( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return -c * Math.cos ( t / d * ( Math.PI / 2 ) ) + c + b;
	}
	
	inline static function easeOut( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return c * Math.sin( t / d * ( Math.PI / 2 ) ) + b;
	}
	
	inline static function easeInOut( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		return -c / 2 * ( Math.cos( Math.PI * t / d ) - 1 ) + b;
	}
}
