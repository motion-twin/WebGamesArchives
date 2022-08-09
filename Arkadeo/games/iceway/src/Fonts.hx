package ;

class Fonts
{
	@:meta(Embed(source="./PixelSquare10.ttf", fontName="PixelSquare"))
	static var PixelSquareFont:Class<Dynamic>;
	
	public static function init()
	{
		flash.text.Font.registerFont(PixelSquareFont);
	}
}
