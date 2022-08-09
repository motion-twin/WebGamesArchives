package game.viewer;

enum TransitionParam {
	In;
	Out;
	InOut;
}

enum Transition {
	Linear;
	Quad(p:TransitionParam);	// Quadratic
	Cubic(p:TransitionParam);	// Cubicular
	Quart(p:TransitionParam);	// Quartetic
	Quint(p:TransitionParam);	// Quintetic
	Pow(pa:Float);
	Expo(p:TransitionParam);
	Circ(p:TransitionParam);
	Sine(p:TransitionParam);
	Back(p:TransitionParam, pa:Float);
	Bounce(p:TransitionParam);
	Elastic(p:TransitionParam, pa:Float);
}

class TransitionFunctions {

	static function transitionParam(p:TransitionParam, f:Float -> Float) : Float -> Float {
		return switch (p){
			case In:f;
			case Out:function(pos:Float){ return 1 - f(1-pos); }
			case InOut:function(pos:Float){ return if (pos <= 0.5) f(2 * pos) / 2 else (2 - f(2 * (1-pos))) / 2; }
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
		var value : Null<Float> = null;
		var a = 0.0;
		var b = 1.0;
		while (true){
			if (p >= (7 - 4 * a) / 11){
				value = -Math.pow((11- 6*a - 11*p) / 4, 2) + b*b;
				break;
			}
			a += b;
			b /= 2.0;
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

	public static function loop(ratio:Float){
		if (ratio <= 0.5)
			return ratio * 2;
		return (1 - ratio) * 2;
	}
}
