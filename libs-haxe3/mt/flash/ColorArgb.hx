package mt.flash;

class ColorArgb
{
	public var red:Int;
	public var green:Int;
	public var blue:Int;
	public var alpha:Int;
	
	public var redCoef(get, set):Float; 
	inline function get_redCoef() { return red / 255; }
	inline function set_redCoef(coef:Float):Float { red = Std.int(255 * coef); return coef; }
	
	public var greenCoef(get, set):Float;
	inline function get_greenCoef() { return green / 255; }
	inline function set_greenCoef(coef:Float):Float { green = Std.int(255 * coef); return coef; }
	
	public var blueCoef(get, set):Float;
	inline function get_blueCoef() { return blue / 255; }
	inline function set_blueCoef(coef:Float):Float { blue = Std.int(255 * coef); return coef; }
	
	public var alphaCoef(get, set):Float;
	inline function get_alphaCoef() { return alpha / 255; }
	inline function set_alphaCoef(coef:Float):Float { alpha = Std.int(255 * coef); return coef; }
	
	public inline static function createFromRgb(color:Int):ColorArgb
	{
		var rgb = new ColorArgb();
		rgb.fromRgb(color);
		return rgb;
	}
	
	public inline static function createFromArgb(color:Int):ColorArgb
	{
		var argb = new ColorArgb();
		argb.fromArgb(color);
		return argb;
	}
	
	public inline function new(p_red=0, p_green=0, p_blue=0, p_alpha=0)
	{
		this.red = p_red;
		this.green = p_green;
		this.blue = p_blue;
		this.alpha = p_alpha;
	}
	
	public function toRgb():Int
	{
		var r = mt.MLib.clamp(red, 0, 255 );
		var g = mt.MLib.clamp(green, 0, 255 );
		var b = mt.MLib.clamp(blue, 0, 255 );
		
		return r << 16 | g << 8 | b;
	}
	
	public function toArgb():Int
	{
		var a = mt.MLib.clamp(alpha, 0, 255 );
		var r = mt.MLib.clamp(red, 0, 255 );
		var g = mt.MLib.clamp(green, 0, 255 );
		var b = mt.MLib.clamp(blue, 0, 255 );
		
		return a << 24 | r << 16 | g << 8 | b;
	}
	
	public function fromRgb(color:Int)
	{
		red 	= (color >> 16) & 0xFF;
		green 	= (color >> 8) & 0xFF;
		blue 	= color & 0xFF;
	}
	
	public function fromArgb(color:Int)
	{
		alpha 	= (color >> 24) & 0xFF;
		red 	= (color >> 16) & 0xFF;
		green 	= (color >> 8)  & 0xFF;
		blue 	= color & 0xFF;
	}
	
	public function copyFrom(argb:ColorArgb)
	{
		red 	= argb.red;
		green 	= argb.green;
		blue 	= argb.blue;
		alpha 	= argb.alpha;
	}
	
	public function toMatrix(withAlpha:Bool = false )
	{
		return [redCoef, 0, 0, 0, 0,
				0, greenCoef, 0, 0, 0,
				0, 0, blueCoef, 0, 0,
				0, 0, 0, withAlpha?alphaCoef:1.0, 0];
	}
}
