import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class Text extends Sprite {
	public static var LEFT = TextFormatAlign.LEFT;
	public static var RIGHT = TextFormatAlign.RIGHT;
	public static var CENTER = TextFormatAlign.CENTER;
	public static var JUSTIFY = TextFormatAlign.JUSTIFY;
	
	var txt : TextField;
	
	public function new(w:UInt, h:UInt, label:String, ?font:String="Nokia Cellphone FC", ?size:Null<UInt>=8, ?color:Null<UInt>=0x00000000, ?align:TextFormatAlign){
	// public function new(w:UInt, h:UInt, label:String, ?font:String="system", ?size:Null<UInt>=8, ?color:Null<UInt>=0x00000000, ?align:TextFormatAlign){
		super();
		if (align == null)
			align = flash.text.TextFormatAlign.LEFT;
		txt = new TextField();
		txt.width = w;
		txt.height = h;
		txt.embedFonts = true;
		txt.selectable = false;
		txt.sharpness = 100;
		txt.defaultTextFormat = new TextFormat(font, size, color, null, null, null, null, null, align);
		txt.text = label;
		addChild(txt);
	}

	public function setText( s:String ){
		txt.text = s;
	}

	public function setColor( c:UInt ){
		var fmt = txt.defaultTextFormat;
		fmt.color = c;
		txt.defaultTextFormat = fmt;
		txt.text = txt.text;
	}
}