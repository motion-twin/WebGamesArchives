package ui;

import flash.display.Sprite;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/**
 * ...
 * @author 01101101
 */
class EmbedText extends Sprite {
	
	var tf:TextField;
	var ft:TextFormat;
	
	public function new (txt:String, c:UInt, s:Int = 24, ?align:TextFieldAutoSize, ?useEmbed:Bool = true) {
		super();
		
		if (useEmbed)	ft = new TextFormat("_zeph", s, c);
		else			ft = new TextFormat("Arial", s, c);
		
		tf = new TextField();
		tf.defaultTextFormat = ft;
		if (useEmbed) {
			tf.embedFonts = true;
			tf.antiAliasType = AntiAliasType.ADVANCED;
		}
		if (align == null)	align = TextFieldAutoSize.CENTER;
		tf.autoSize = align;
		
		tf.selectable = false;
		tf.multiline = false;
		
		tf.text = txt;
		
		tf.x = switch (align) {
			case TextFieldAutoSize.LEFT:	0;
			case TextFieldAutoSize.CENTER:	-tf.width / 2;
			case TextFieldAutoSize.RIGHT:	-tf.width;
		}
		tf.y = 0;
		
		addChild(tf);
	}
	
	public function destroy () {
		tf = null;
		ft = null;
	}
	
}










