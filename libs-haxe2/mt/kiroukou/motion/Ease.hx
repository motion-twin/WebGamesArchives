package mt.kiroukou.motion;

class Back implements haxe.Public {
	inline static function easeIn( t : Float ) : Float {
		return t * t * ( ( 1.70158 + 1 ) * t - 1.70158 );
	}
	
	inline static function easeOut( t : Float ) : Float {
		return ( ( t = t - 1 ) * t * ( ( 1.70158 + 1 ) * t + 1.70158 ) + 1 );
	}
	
	inline static function easeInOut( t : Float ) : Float {
		var s = 1.70158;
		if( ( t /= 1 / 2 ) < 1 )
			return 0.5 * ( t * t * ( ( ( s *= ( 1.525 ) ) + 1 ) * t - s ) );
		return 0.5 * ( ( t -= 2 ) * t * ( ( ( s *= ( 1.525 ) ) + 1 ) * t + s ) + 2 );
	}
}

class Bounce implements haxe.Public {
	inline static function easeOut ( t : Float ) : Float {
		var tmp = 1 / 2.75;
		if ( t < tmp )
			return ( 7.5625 * t * t );
		else if ( t < ( 2 * tmp ) )
			return ( 7.5625 * ( t -= ( 1.5 * tmp ) ) * t + .75 );
		else if ( t < ( 2.5 * tmp ) )
			return ( 7.5625 * ( t -= ( 2.25 * tmp ) ) * t + .9375 );
		else
			return ( 7.5625 * ( t -= ( 2.625 * tmp ) ) * t + .984375 );
	}
	
	inline static function easeIn ( t : Float ) : Float {
		return easeOut(t);
	}
	
	inline static function easeInOut ( t : Float ) : Float {
		if ( t < 0.5 )
			return easeIn ( t * 2 ) * .5;
		else
			return easeOut ( t * 2 - 1) * .5 + .5;
	}
}

class Circ implements haxe.Public {
	inline static function easeIn ( t : Float ) : Float {
		return -( Math.sqrt( 1 - ( t ) * t ) - 1 );
	}
	
	inline static function easeOut ( t : Float ) : Float {
		return Math.sqrt( 1 - ( t = t - 1 ) * t );
	}
	
	inline static function easeInOut ( t : Float ) : Float {
		if ( ( t / 2 ) < 1 )
			return -.5 * ( Math.sqrt( 1 - t * t ) - 1 );
		return .5 * ( Math.sqrt( 1 - ( t -= 2 ) * t ) + 1 );
	}
}


class Cubic implements haxe.Public {
	inline static function easeIn ( t : Float ) : Float {
		return t * t * t;
	}
	
	inline static function easeOut ( t : Float ) : Float {
		return ( ( t = t - 1 ) * t * t + 1 );
	}
	
	inline static function easeInOut ( t : Float ) : Float {
		var v;
		if ( ( t / 2 ) < 1 )
			v =  .5 * t * t * t;
		else
			v = .5 * ( ( t -= 2 ) * t * t + 2 );
		return v;
	}
}

class Elastic implements haxe.Public {
	inline static function easeIn ( t : Float ) : Float {
		if ( t == 0 )
			return 0;
		if ( t == 1 )
			return 1;
		var p = .3;
		var s = p / 4;
		return -( Math.pow( 2, 10 * ( t -= 1 ) ) * Math.sin( ( t - s ) * ( 2 * Math.PI ) / p ) );
	}
	
	inline static function easeOut ( t : Float ) : Float {
		if( t == 0 )
			return 0;
		if ( t == 1 )
			return 1;
		var p = .3;
		var	s = p / 4;
		return ( Math.pow( 2, -10 * t ) * Math.sin( ( t - s ) * ( 2 * Math.PI ) / p ) + 1 );
	}
	
	inline static function easeInOut ( t : Float ) : Float {
		if ( t == 0 )
			return 0;
		if ( ( t / 2 ) == 2 )
			return 1;
		var p = ( .3 * 1.5 );
		var	s = p / 4;
		if ( t < 1 )
			return -.5 * ( Math.pow( 2, 10 * ( t -= 1 ) ) * Math.sin( ( t - s ) * ( 2 * Math.PI ) / p ) );
		return Math.pow( 2, -10 * ( t -= 1 ) ) * Math.sin( ( t - s ) * ( 2 * Math.PI ) / p ) * .5 + 1;
	}
}

class Expo implements haxe.Public {
	inline static function easeIn ( t : Float ) : Float {
		return ( t == 0 ) ? 0 : Math.pow( 2, 10 * ( t - 1 ) );
	}
	
	inline static function easeOut ( t : Float ) : Float {
		return ( t == 1 ) ? 1 : ( -Math.pow( 2, -10 * t ) + 1 );
	}
	
	inline static function easeInOut ( t : Float ) : Float {
		if ( t == 0 )
			return 0;
		if ( t == 1 )
			return 1;
		if ( ( t / 2 ) < 1 )
			return .5 * Math.pow( 2, 10 * ( t - 1 ) );
		return .5 * ( -Math.pow( 2, -10 * --t ) + 2 );
	}
}

class Linear implements haxe.Public {
	inline static function easeNone ( t : Float ) : Float {
		return t;
	}
	
	inline static function easeIn ( t : Float ) : Float {
		return t;
	}
	
	inline static function easeOut ( t : Float ) : Float {
		return t;
	}
	
	inline static function easeInOut ( t : Float ) : Float {
		return t;
	}
}


class Quad implements haxe.Public {
	inline static function easeIn ( t : Float ) : Float {
		return t * t;
	}
	
	inline static function easeOut ( t : Float ) : Float {
		return -t * ( t - 2 );
	}
	
	inline static function easeInOut ( t : Float ) : Float {
		if ( ( t / 2 ) < 1 )
			return .5 * t * t;
		return -.5 * ( ( --t ) * ( t - 2 ) - 1 );
	}
}

class Quart implements haxe.Public {
	inline static function easeIn ( t : Float ) : Float {
		return t * t * t * t;
	}
	
	inline static function easeOut ( t : Float ) : Float {
		return -( ( t = t - 1 ) * t * t * t - 1 );
	}
	
	inline static function easeInOut ( t : Float ) : Float {
		if ( ( t / 2 ) < 1 )
			return .5 * t * t * t * t;
		return -.5 * ( ( t -= 2 ) * t * t * t - 2);
	}
}

class Quint implements haxe.Public {
	
	inline static function easeIn ( t : Float ) : Float {
		return t * t * t * t * t;
	}
	
	inline static function easeOut ( t : Float ) : Float {
		return ( t = t - 1 ) * t * t * t * t + 1;
	}
	
	inline static function easeInOut ( t : Float ) : Float {
		var v = if ( ( t / 2 ) < 1 )
					.5 * t * t * t * t * t;
				else
					.5 * ( ( t -= 2 ) * t * t * t * t + 2 );
		return v;
	}
}


class Sine implements haxe.Public {
	inline static function easeIn ( t : Float ) : Float {
		return -Math.cos ( t * ( Math.PI / 2 ) ) + 1;
	}
	
	inline static function easeOut ( t : Float ) : Float {
		return Math.sin( t * ( Math.PI / 2 ) );
	}
	
	inline static function easeInOut ( t : Float ) : Float {
		return -.5 * ( Math.cos( Math.PI * t ) - 1 );
	}
}

