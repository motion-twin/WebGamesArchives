package page;

import flash.display.Sprite;
import flash.text.TextField;

class FatalError {
	var wrapper			: Sprite;

	public function new(title:String, msg:String, ?stack:String) {
		if( Game.ME!=null && !Game.ME.destroyed )
			Game.ME.destroy();

		wrapper = new Sprite();
		flash.Lib.current.addChild( wrapper);

		var bg = new Sprite();
		wrapper.addChild(bg);
		bg.graphics.beginFill(0x9B0000, 0.7);
		bg.graphics.drawRect(0,0, w(), h());

		var tf = createField(":'(", 200, 0xCF5A5A);
		wrapper.addChild(tf);
		tf.x = w()-tf.textWidth-50;
		tf.y = 50;
		tf.selectable = tf.mouseEnabled = false;

		var tf = createField(Lang.t._("An error occured!"), 18, 0xFFF1C1);
		wrapper.addChild(tf);
		tf.x = 5;
		tf.y = 50;

		var tf = createField(title,48);
		wrapper.addChild(tf);
		tf.x = 5;
		tf.y = 70;

		var tf = createField("\""+msg+"\"",24);
		wrapper.addChild(tf);
		tf.x = 5;
		tf.y = 120;

		var tf = createField(Lang.t._("We are so sorry... Please reload the page and try again."), 18, 0xFFF1C1);
		wrapper.addChild(tf);
		tf.x = 5;
		tf.y = 180;

		if( SoundMan.ME!=null )
			SoundMan.ME.destroy();

		#if( !prod && !mobile )
		if( stack!=null ) {
			var tf = createField(stack,16);
			wrapper.addChild(tf);
			tf.x = 5;
			tf.y = 160;
		}
		#end
	}

	inline function w() return Main.ME.w();
	inline function h() return Main.ME.h();

	function createField(str:String, size:Int, col=0xFFFFFF) {
		var tf = new TextField();
		var f = new flash.text.TextFormat("Arial", size, col);
		tf.defaultTextFormat = f;
		tf.setTextFormat(f);
		tf.mouseEnabled = tf.selectable = true;
		#if !cpp
		tf.mouseWheelEnabled = true;
		#end
		tf.multiline = tf.wordWrap = true;
		tf.width = w();
		tf.height = 500;
		tf.text = str;
		return tf;
	}
}