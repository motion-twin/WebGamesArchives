package mt.kiroukou.motion.easing;

class Elastic implements haxe.Public {
	inline static function easeIn( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		if ( t == 0 )
			return b;
		if ( ( t /= d ) == 1 )
			return b + c;
		var p = d * .3;
		var s = p / 4;
		return -( c * Math.pow( 2, 10 * ( t -= 1 ) ) * Math.sin( ( t * d - s ) * ( 2 * Math.PI ) / p ) ) + b;
	}
	
	inline static function easeOut ( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		if ( t == 0 )
			return b;
		if ( ( t /= d ) == 1 )
			return b + c;
		var p = d * .3;
		var	s = p / 4;
		return ( c * Math.pow( 2, -10 * t ) * Math.sin( ( t * d - s ) * ( 2 * Math.PI ) / p ) + c + b );
	}
	
	inline static function easeInOut ( t : Float, ?b : Float = 0, ?c : Float = 1, ?d : Float=1 ) : Float {
		if ( t == 0 )
			return b;
		if ( ( t /= d / 2 ) == 2 )
			return b + c;
		var p = d * ( .3 * 1.5 );
		var	s = p / 4;
		if ( t < 1 )
			return -.5 * ( c * Math.pow( 2, 10 * ( t -= 1 ) ) * Math.sin( ( t * d - s ) * ( 2 * Math.PI ) / p ) ) + b;
		return c * Math.pow( 2, -10 * ( t -= 1 ) ) * Math.sin( ( t * d - s ) * ( 2 * Math.PI ) / p ) * .5 + c + b;
	}
}
