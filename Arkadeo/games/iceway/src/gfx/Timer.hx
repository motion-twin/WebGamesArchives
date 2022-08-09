package gfx;
import Lib;

@:bind("gfx.Timer")
class Timer extends Sprite
{
	inline static var TEXT_OFFSET_X = 38;
	inline static var TEXT_OFFSET_Y = 10;

	public var _text :flash.text.TextField;
	public function new()
	{
		super();
		setField();
	}
	
	function setField()
	{
		var tf = new flash.text.TextFormat( "_PixelSquareBold", 24, 0 );
		tf.color = 0x2C898B;
		_text = new flash.text.TextField();
		_text.defaultTextFormat = tf;
		addChild(_text);
		
		_text.x = TEXT_OFFSET_X;
		_text.y = TEXT_OFFSET_Y;
		
		_text.embedFonts = true;
		_text.mouseEnabled = false;
		_text.selectable = false;
		_text.width = 50;
		_text.height = 30;
		_text.autoSize = flash.text.TextFieldAutoSize.RIGHT;
	}
}