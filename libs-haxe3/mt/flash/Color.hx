package mt.flash;


typedef ColorHsl = {
	h	: Float, // 0-1
	s	: Float, // 0-1
	l	: Float, // 0-1
}

class Color 
{	
	static public function setPercentColor( mc:flash.display.DisplayObject, c:Float, col:Int, ?inc:Float=0 )
	{
		var color = ColorArgb.createFromRgb(col);
		var cp  = 1 - c;
		var ct = new flash.geom.ColorTransform( cp, cp, cp, 1, Std.int(c * color.red + inc ), Std.int(c * color.green + inc ), Std.int(c * color.blue + inc ), 0 );
		mc.transform.colorTransform = ct;
	}
	
	static public function setColor( mc:flash.display.DisplayObject, col:Int, dec = -255 )
	{
		var color = ColorArgb.createFromRgb(col);
		var ct = new flash.geom.ColorTransform( 1, 1, 1, 1, Std.int(color.red+dec ), Std.int(color.green+dec ), Std.int(color.blue+dec ), 0 );
		mc.transform.colorTransform = ct;
	}
	
	static public function overlay ( mc:flash.display.DisplayObject, col:Int, dec = -128 ) 
	{
		var color = ColorArgb.createFromRgb(col);
		var a = 1;
		var b = 2;
		var ct = new flash.geom.ColorTransform( a, a, a, 1, Std.int( (color.red + dec)* b ) , Std.int( (color.green + dec)* b ) , Std.int( (color.blue + dec)*b ), 0 );
		mc.transform.colorTransform = ct;
	}
	
	static public function overlay2 ( mc:flash.display.DisplayObject, col:Int, dec =-128 ) {
		var color = ColorArgb.createFromRgb(col);
		var a = 2;
		var b = 1;
		var ct = new flash.geom.ColorTransform( a, a, a, a, Std.int( (color.red + dec)* b ) , Std.int( (color.green + dec)* b ) , Std.int( (color.blue + dec)*b ), 0 );
		mc.transform.colorTransform = ct;
	}

	public static var CHANNEL_LUM = [ 0.241, 0.691, 0.068 ];
	static public function overlay3 ( mc:flash.display.DisplayObject, col:Int, ?dec:Null<Int>, luminosityEqualizer = true)
	{
		if( dec == null ) dec = -255;
		var color = ColorArgb.createFromRgb(col);
		if ( luminosityEqualizer )
		{
			var lum = ( color.red * CHANNEL_LUM[0] + color.green * CHANNEL_LUM[1] + color.blue * CHANNEL_LUM[2] );
			dec += 128 - Std.int(lum);
		}
		var a = 2;
		var b = 1;
		var ct = new flash.geom.ColorTransform( a, a, a, a, Std.int( (color.red + dec)* b ) , Std.int( (color.green + dec)* b ) , Std.int( (color.blue + dec)*b ), 0 );
		mc.transform.colorTransform = ct;
	}

	/**
	 * TODO check modulo method change impact
	 */
	static public function getRainbow(?c:Float)
	{
		if(c == null) c = Math.random();
		var max = 3;
		var a = [0.0, 0.0, 0.0];
		var part =  (1 / max * 2);
		for ( i in 0...max )
		{
			var med = part + i * 2 * part;
			var dif = mt.MLib.hMod( med - c, 0.5 );
			a[i] = Math.min( 1.5-Math.abs(dif)*3 ,1);
		}
		return rgb2Hex(Std.int(a[0] * 255), Std.int(a[1] * 255), Std.int(a[2] * 255));
	}
	
	static public function getRainbow2(?c)
	{
		if(c == null) c = Math.random();
		var lim = 1 / 3;
		var a = [];
		for ( i in 0...3 ) 
		{
			var coef = Math.abs( mt.MLib.hMod(c - lim*i, 0.5)) * 2;
			a.push( Std.int(coef * 255));
		}
		return new ColorArgb( a[0], a[1], a[2] );
	}

	static public function mergeCol(col:Int, col2:Int, ?c=0.5)
	{
		var o = ColorArgb.createFromRgb(col);
		var o2 = ColorArgb.createFromRgb(col2);
		var o3 = new ColorArgb(Std.int(o.red * c + o2.red * (1 - c)), Std.int(o.green * c + o2.green * (1 - c)), Std.int(o.blue * c + o2.blue * (1 - c)) );
		return o3.toRgb();
	}
	
	static public function mergeCol32(col:Int, col2:Int, ?c=0.5)
	{
		var o = ColorArgb.createFromRgb(col);
		var o2 = ColorArgb.createFromRgb(col2);
		var o3 = new ColorArgb(Std.int(o.red * c + o2.red * (1 - c)), Std.int(o.green * c + o2.green * (1 - c)), Std.int(o.blue * c + o2.blue * (1 - c)), Std.int(o.alpha * c + o2.alpha * (1 - c)) );
		return o3.toArgb();
	}
	
	static public function desaturate(?col:Int, ?o:ColorArgb, ratio:Float = 0.5, ?accurate:Bool=true) 
	{
		if( o == null )
			o = ColorArgb.createFromRgb(col);
		
		var gray = if( !accurate ) (o.red + o.green + o.blue) / 3 else 0.3 * o.red + 0.59 * o.green + 0.11 * o.blue;
		o.red 	= Std.int(o.red * (1 - ratio) + gray * ratio);
		o.green = Std.int(o.green * (1 - ratio) + gray * ratio);
		o.blue 	= Std.int(o.blue * (1 - ratio) + gray * ratio);
		return o.toRgb();
	}
	
	static public function brighten(col:Int, inc:Int)
	{
		var o = ColorArgb.createFromRgb(col);
		o.red 	= Std.int( mt.MLib.clamp(0, o.red 	+ inc, 255) );
		o.green = Std.int( mt.MLib.clamp(0, o.green + inc, 255) );
		o.blue 	= Std.int( mt.MLib.clamp(0, o.blue 	+ inc, 255) );
		return o.toRgb();
	}

	static public function shuffle(col:Int, inc:Int)
	{
		var o = ColorArgb.createFromRgb(col);
		o.red 	= Std.int( mt.MLib.fclamp( o.red	+ (Math.random()*2-1)*inc, 	0, 255 ) );
		o.green = Std.int( mt.MLib.fclamp( o.green  + (Math.random()*2-1)*inc, 	0, 255 ) );
		o.blue 	= Std.int( mt.MLib.fclamp( o.blue	+ (Math.random()*2-1)*inc, 	0, 255 ) );
		return o.toRgb();
	}

	public static function rgb2Hex( r: Int, g : Int, b : Int ) 
	{
		return (r << 16) + (g << 8) + b;
	}
	
	public static  function getWeb(col)
	{
		return "#"+StringTools.hex(col);
	}

	public static inline function rgbToHsl(?color:Int, ?colorObject:ColorArgb) : ColorHsl
	{
		if( colorObject == null ) colorObject = ColorArgb.createFromRgb(color);
		var r = colorObject.redCoef;
		var g = colorObject.greenCoef;
		var b = colorObject.blueCoef;
			
		var min = if(r <= g && r <= b) r else if(g <= b) g else b;
		var max = if(r >= g && r >= b) r else if(g >= b) g else b;
		var delta = max - min;
		
		var hsl : ColorHsl = { h:0., s:0., l:0. };
		hsl.l = max;
		if ( delta != 0 ) 
		{
			hsl.s = delta/max;
			var dr = ( (max-r)/6 + (delta/2) ) / delta;
			var dg = ( (max-g)/6 + (delta/2) ) / delta;
			var db = ( (max-b)/6 + (delta/2) ) / delta;
			
			if( r == max ) hsl.h = db-dg;
			else if( g == max ) hsl.h = 1/3 + dr - db;
			else if( b == max ) hsl.h = 2/3 + dg - dr;
			
			if( hsl.h < 0 ) hsl.h++;
			if( hsl.h > 1 ) hsl.h--;
		}
		return hsl;
	}
		
	public static function hsl2Rgb(?color:ColorHsl, ?hue = 0.0, ?sat = 1.0, ?lum = 0.5) 
	{
		if ( color != null ) 
		{
			hue = color.h;
			sat = color.s;
			lum = color.l;
		}
		var r:Float, g:Float, b:Float;
		if (lum == 0) 
		{
			r = g = b = 0;
		} 
		else 
		{
			if (sat == 0)
			{
				r = g = b = lum;
			} 
			else 
			{
				var h = hue * 6;
				var i = mt.MLib.floor(h);
				var c1 = lum * (1 - sat);
				var c2 = lum * (1 - sat * (h-i));
				var c3 = lum * (1 - sat * (1 - (h-i)));
				
				if( i==0 )		{ r = lum; g = c3; b = c1; }
				else if( i==1 )	{ r = c2; g = lum; b = c1; }
				else if( i==2 )	{ r = c1; g = lum; b = c3; }
				else if( i==3 )	{ r = c1; g = c2; b = lum; }
				else if( i==4 )	{ r = c3; g = c1; b = lum; }
				else 			{ r = lum; g = c1; b = c2; }
			}
		}
		return rgb2Hex( Std.int(r * 255), Std.int(g * 255), Std.int(b * 255));
	}
	
	public static inline function getDarkenTransform(ratio:Float) 
	{
		var ct = new flash.geom.ColorTransform();
		ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 1-ratio;
		return ct;
	}
	
	public static inline function getColorizeTransform(?col:ColorArgb, ?colInt:Int, ratio:Float)
	{
		if (col == null)
			col = ColorArgb.createFromRgb(colInt);
		var ct = new flash.geom.ColorTransform();
		ct.redOffset 		= col.red*ratio;
		ct.greenOffset 		= col.green*ratio;
		ct.blueOffset 		= col.blue*ratio;
		ct.redMultiplier 	= 1-ratio;
		ct.greenMultiplier 	= 1-ratio;
		ct.blueMultiplier 	= 1-ratio;
		return ct;
	}
}
