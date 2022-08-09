// ColorMatrix Class v1.2
//
// Author: Mario Klingemann
// http://www.quasimondo.com
package mt.flash;

class ColorMatrix {

	static inline var r_lum = 0.212671;
	static inline var g_lum = 0.715160;
	static inline var b_lum = 0.072169;

	/*
	// There seem  different standards for converting RGB
	// values to Luminance. This is the one by Paul Haeberli:

	private static var r_lum:Number = 0.3086;
	private static var g_lum:Number = 0.6094;
	private static var b_lum:Number = 0.0820;

	*/

	public var matrix  : Array<Float>;

	public function new() {
		reset();
	}

	public function reset() {
		matrix = [1.,0,0,0,0,
					0,1,0,0,0,
					0,0,1,0,0,
					0,0,0,1,0];
	}

	public function apply( c : Int ) {
		var a = c >>> 24;
		var r = (c >> 16) & 0xFF;
		var g = (c >> 8) & 0xFF;
		var b = c & 0xFF;
		var r2 = Std.int(matrix[0] * r + matrix[1] * g + matrix[2] * b + matrix[3] * a + matrix[4]);
		var g2 = Std.int(matrix[5] * r + matrix[6] * g + matrix[7] * b + matrix[8] * a + matrix[9]);
		var b2 = Std.int(matrix[10] * r + matrix[11] * g + matrix[12] * b + matrix[13] * a + matrix[14]);
		var a2 = Std.int(matrix[15] * r + matrix[16] * g + matrix[17] * b + matrix[18] * a + matrix[19]);
		if( r2 < 0 ) r2 = 0 else if( r2 > 255 ) r2 = 255;
		if( g2 < 0 ) g2 = 0 else if( g2 > 255 ) g2 = 255;
		if( b2 < 0 ) b2 = 0 else if( b2 > 255 ) b2 = 255;
		if( a2 < 0 ) a2 = 0 else if( a2 > 255 ) a2 = 255;
		return (a2 << 24) | (r2 << 16) | (g2 << 8) | b2;
	}

	public function adjustSaturation( s : Float ) {
		s += 1;
		var is=1-s;
	    var irlum = is * r_lum;
		var iglum = is * g_lum;
		var iblum = is * b_lum;
		var mat =  [irlum + s, iglum    , iblum    , 0, 0,
					irlum    , iglum + s, iblum    , 0, 0,
					irlum    , iglum    , iblum + s, 0, 0,
					0        , 0        , 0        , 1, 0 ];
		concat(mat);
	}

	public function adjustContrast( c : Float ) {
		adjustContrastRGB(c,c,c);
	}

	public function adjustContrastRGB( r : Float, g : Float, b : Float ) {
		r += 1;
		g += 1;
		b += 1;
		var mat =  [r,0,0,0,-128*(1-r),
					0,g,0,0,-128*(1-g),
					0,0,b,0,-128*(1-b),
					0,0,0,1,0];
		concat(mat);
	}


	public function adjustBrightness( b : Float ) {
		adjustBrightnessRGB(b,b,b);
	}

	public function adjustBrightnessRGB( r : Float, g : Float, b : Float ) {
		var mat =  [1,0,0,0,r*256,
					0,1,0,0,g*256,
					0,0,1,0,b*256,
					0,0,0,1,0];
		concat(mat);
	}

	public function adjustHue( angle : Float )	{
		angle *= Math.PI/180;
		var c = Math.cos( angle );
        var s = Math.sin( angle );
        var f1 = 0.213;
        var f2 = 0.715;
        var f3 = 0.072;
		var mat = [ (f1 + (c * (1 - f1))) + (s * (-f1)), (f2 + (c * (-f2))) + (s * (-f2)), (f3 + (c * (-f3))) + (s * (1 - f3)),0, 0,
					(f1 + (c * (-f1))) + (s * 0.143), (f2 + (c * (1 - f2))) + (s * 0.14), (f3 + (c * (-f3))) + (s * -0.283), 0, 0,
					(f1 + (c * (-f1))) + (s * (-(1 - f1))), (f2 + (c * (-f2))) + (s * f2), (f3 + (c * (1 - f3))) + (s * f3), 0, 0,
					0, 0, 0, 1, 0,
					0, 0, 0, 0, 1];
		concat(mat);
	}

	public function colorize( rgb : Int, ?amount : Float ) {
		var r = ( ( rgb >> 16 ) & 0xff ) / 255;
		var g = ( ( rgb >> 8  ) & 0xff ) / 255;
		var b = ( rgb & 0xff ) / 255;
		if( amount == null) amount = 1;
		var inv_amount = 1 - amount;
		var mat =  [inv_amount + amount*r*r_lum, amount*r*g_lum,  amount*r*b_lum, 0, 0,
					amount*g*r_lum, inv_amount + amount*g*g_lum, amount*g*b_lum, 0, 0,
					amount*b*r_lum,amount*b*g_lum, inv_amount + amount*b*b_lum, 0, 0,
					0 , 0 , 0 , 1, 0 ];
		concat(mat);
	}

	public function setAlpha( alpha : Float ) {
		var mat =  [1, 0, 0, 0, 0,
					0, 1, 0, 0, 0,
					0, 0, 1, 0, 0,
					0, 0, 0, alpha, 0];
		concat(mat);
	}

	public function desaturate() {
		var mat = [r_lum, g_lum, b_lum, 0, 0,
					r_lum, g_lum, b_lum, 0, 0,
					r_lum, g_lum, b_lum, 0, 0,
					0    , 0    , 0    , 1, 0];
		concat(mat);
	}

	public function concat( mat : Array<Float> ) {
		var temp = new Array();
		var i = 0;
		for( y in 0...4 ) {
			for( x in 0...5 ) {
				temp[i + x] = mat[i] * matrix[x] +
							   mat[i+1] * matrix[x +  5] +
							   mat[i+2] * matrix[x + 10] +
							   mat[i+3] * matrix[x + 15] +
							   (x == 4 ? mat[i+4] : 0);
			}
			i+=5;
		}
		matrix = temp;
	}

}
