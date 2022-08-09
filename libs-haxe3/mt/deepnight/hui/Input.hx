package mt.deepnight.hui;

import h2d.Text;
import h2d.Bitmap;
import hxd.Event;
import hxd.Key;
import mt.deepnight.hui.Style;

class Input extends Label {
	public static var STYLE : Style = {
		var s = new Style();
		s.bg = Col(0x0, 0.4);
		s.bgOutline = Lighter;
		s.textColor = 0xFFFFFF;
		s.padding = 5;
		s.contentHAlign = Left;
		s;
	};
	var caret					: Bitmap;
	var caretPos(default,set)	: Int;
	var viewport				: { x:Float, wid:Float };
	var maskWrapper				: h2d.Mask;
	public var numbersOnly		: Bool;

	public function new(p, ?txt="") {
		super(p, txt);

		style = new Style(Component.BASE_STYLE,this);
		style.copyValues(STYLE);

		numbersOnly = false;
		viewport = { x:0, wid:100 }
		setCursor(TextInput);

		maskWrapper = new h2d.Mask(8,8, wrapper);
		content.parent.removeChild(content);
		maskWrapper.addChild(content);

		caret = new h2d.Bitmap(h2d.Tools.getWhiteTile(), content);
		caret.visible = false;
		caret.scaleX = 1/caret.tile.width;
		caret.scaleY = 10/caret.tile.height;

		caretPos = 0;

		enableInteractive();

		interactive.onFocus = function(_) {
			addState("focus");
			caret.visible = true;
			caret.alpha = 1;
			caretPos = caretPos;
			#if (openfl && cpp)
			flash.Lib.current.requestSoftKeyboard();
			#end
			onFocus();
		}

		interactive.onFocusLost = function(_) {
			removeState("focus");
			caret.visible = false;
			#if (openfl && cpp)
			flash.Lib.current.__dismissSoftKeyboard();
			#end
			onBlur();
		}

		interactive.onClick = function(e:Event) {
			focus();
			var mx = e.relX;
			var str = get();
			var i = 0;
			var last = 0.;
			while( i<str.length ) {
				var x = content.x + tf.calcTextWidth(str.substr(0,i));
				if( x>=mx ) {
					if( MLib.fabs(last-mx) < MLib.fabs(x-mx) )
						i--;
					break;
				}
				last = x;
				i++;
			}
			caretPos = i;
		}

		interactive.onKeyDown = onKey;
	}

	public dynamic function onFocus() {
	}

	public dynamic function onBlur() {
	}

	public dynamic function onConfirm(val:String) {
	}

	function onKey(e:Event) {
		var val = get();

		switch( e.keyCode ) {
			case Key.LEFT:
				if( caretPos > 0 )
					caretPos--;

			case Key.RIGHT:
				if( caretPos < get().length )
					caretPos++;

			case Key.HOME:
				caretPos = 0;

			case Key.END:
				caretPos = get().length;

			case Key.DELETE:
				val = val.substr(0, caretPos) + val.substr(caretPos + 1);
				set(val);

			case Key.BACKSPACE:
				if( caretPos > 0 ) {
					val = val.substr(0, caretPos - 1) + val.substr(caretPos);
					set(val);
					caretPos--;
				}

			case Key.ENTER, Key.ESCAPE:
				blur();
				onConfirm( get() );

			default :
				// Insert normal char
				var c = e.charCode;
				if( c != 0 ) {
					if( !numbersOnly || numbersOnly && ( (c>="0".code && c<="9".code) || c==".".code || c=="-".code ) ) {
						val = val.substr(0, caretPos) + String.fromCharCode(c) + val.substr(caretPos);
						set(val);
						caretPos++;
					}
				}
		}
	}


	override function updateTextFieldSize() {
		tf.maxWidth = 9999;
	}

	public function clear() {
		set("");
		caretPos = 0;
	}

	inline function set_caretPos(v) {
		caretPos = v;
		caret.x = tf.calcTextWidth(get().substr(0,caretPos));

		if( caret.x>viewport.x+viewport.wid-5 )
			viewport.x = caret.x - viewport.wid + 8;

		if( caret.x<viewport.x+5 )
			viewport.x = caret.x - 15;

		viewport.x = MLib.fmax(0, viewport.x);

		askRender(false);
		return caretPos;
	}

	override function prepareRender() {
		super.prepareRender();
		viewport.wid = forcedWidth!=null ? forcedWidth : getWidth();

		maskWrapper.width = viewport.wid;
		maskWrapper.height = getHeight();

		caret.y = tf.y+3;
		caret.scaleY = (tf.textHeight-6)/caret.tile.height;
	}


	override function renderContent(w,h) {
		super.renderContent(w,h);
		caretPos = caretPos;
		content.x = style.hpadding-viewport.x;
	}

	public function focus() {
		interactive.focus();
	}

	public function blur() {
		interactive.blur();
	}

	override function destroy() {
		super.destroy();
		maskWrapper.dispose();
		caret.dispose();
		viewport = null;
	}

	override function getContentWidth() {
		return MLib.fmin( viewport.wid, super.getContentWidth() );
	}

	override function update() {
		super.update();

		if( caret.visible ) {
			caret.alpha-=0.05;
			if( caret.alpha<=0.2 )
				caret.alpha = 1;
		}
	}
}