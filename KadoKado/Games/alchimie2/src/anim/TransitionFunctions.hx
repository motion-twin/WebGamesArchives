package anim ;

class TransitionFunctions {

	/*static function transitionParam(p : Int, f:Float -> Float -> Float) : Float -> Float -> Float {
		return switch (p) {
			case 1 :f;
			case -1:function(pos:Float, pa:Float){ return 1 - f(1-pos, pa); }
			case 0 :function(pos:Float, pa:Float){ return if (pos <= 0.5) f(2 * pos, pa) / 2 else (2 - f(2 * (1-pos), pa) / 2); }
		}
	}*/
	
	static function transitionParam(p:Int, f:Float -> Float) : Float -> Float {
		return switch (p){
			case 1:f;
			case -1:function(pos:Float){ return 1 - f(1-pos); }
			case 0:function(pos:Float){ return if (pos <= 0.5) f(2 * pos) / 2 else (2 - f(2 * (1-pos)) / 2); }
		}
	}

		public static function get( t:Transition ){
		return switch (t){
			case Linear: linear;
			case Quad(p): transitionParam(p, quad);
			case Cubic(p): transitionParam(p, cubic);
			case Quart(p): transitionParam(p, quart);
			case Quint(p): transitionParam(p, quint);
			case Pow(p): callback(pow,p);
			case Expo(p): transitionParam(p, expo);
			case Circ(p): transitionParam(p, circ);
			case Sine(p): transitionParam(p, sine);
			case Back(p,pa): transitionParam(p, callback(back,pa));
			case Bounce(p): transitionParam(p, bounce);
			case Elastic(p,pa): transitionParam(p, callback(elastic,pa));
		}
	}

	public static function linear( p:Float ){
		return p;
	}

	public static function pow( x:Float=6.0, p:Float ){
		return Math.pow(p, x);
	}

	public static function expo( p:Float ){
		return Math.pow(2, 8 * (p-1));
	}

	public static function circ( p:Float ){
		return 1 - Math.sin(Math.acos(p));
	}

	public static function sine( p:Float ){
		return 1 - Math.sin((1-p) * Math.PI / 2);
	}

	public static function back( pa:Float=1.618, p:Float ){
		return Math.pow(p, 2) * ((pa+1) * p - pa);
	}

	public static function bounce( p:Float ){
		var value = null;
		var a = 0.0;
		var b = 1.0;
		while (true){
			if (p >= (7 - 4 * a) / 11){
				value = -Math.pow((11- 6*a - 11*p) / 4, 2) + b*b;
				break;
			}
			a += b;
			b /= 2;
		}
		return value;
	}

	public static function elastic( pa:Float=1.0, p:Float ){
		return Math.pow(2, 10 * --p) * Math.cos(20 * p * Math.PI * pa / 3);
	}

	public static function quad(p:Float){
		return Math.pow(p, 2);
	}

	public static function cubic(p:Float){
		return Math.pow(p, 3);
	}

	public static function quart(p:Float){
		return Math.pow(p, 4);
	}

	public static function quint(p:Float){
		return Math.pow(p, 5);
	}
}
