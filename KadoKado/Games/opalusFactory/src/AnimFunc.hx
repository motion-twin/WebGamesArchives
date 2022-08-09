class AnimFunc {


	public static function bounce( p:Float ){
		var value = null;
		var a = 0;
		var b = 1;
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

	public static function quint(p:Float){
		return Math.pow(p, 5);
	}
	
}