package mt.deepnight.hui;

import h2d.Text;
import mt.deepnight.hui.Style;

class Label extends Component {
	public static var STYLE : Style = {
		var s = new Style();
		s.bg = None;
		s.bgOutline = None;
		s.textColor = 0xFFFFFF;
		s.padding = 0;
		s;
	};

	var tf			: Text;

	public function new(p, ?txt="") {
		super(p);

		style = new Style(Component.BASE_STYLE,this);
		style.copyValues(STYLE);

		tf = createField(txt);
		content.addChild(tf);
		set(txt);

		setCursor(Default);

		disableInteractive();
	}

	override function toString() {
		return super.toString() + (tf!=null ? " ["+tf.text.substr(0,25)+"]" : "");
	}

	public function setDropShadow(dx,dy, ?col=0x0, ?a=1.0) {
		tf.dropShadow = { dx:dx, dy:dy, color:col, alpha:a };
	}

	public function removeDropShadow() {
		tf.dropShadow = null;
	}

	function refreshText() {
		set(tf.text);
	}

	public inline function getField() {
		return tf;
	}

	public inline function get() {
		return tf.text;
	}

	public function set(str:Dynamic) {
		str = Std.string(str);
		if( tf.text!=str ) {
			tf.text = str;

			updateTextFieldSize();

			askRender(true);
		}
		return this;
	}

	override function prepareRender() {
		super.prepareRender();

		updateTextFieldSize();
	}

	function updateTextFieldSize() {
		tf.maxWidth = getWidth()-style.hpadding*2;
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		switch( style.contentHAlign ) {
			case None :

			case Left :
				tf.x = 0;

			case Center :
				tf.x = Std.int(w*0.5 - tf.textWidth*0.5);

			case Right :
				tf.x = Std.int(w - tf.textWidth);
		}

		switch( style.contentVAlign ) {
			case None :

			case Top :
				tf.y = 0;

			case Center :
				tf.y = Std.int(h*0.5 - tf.textHeight*0.5);

			case Bottom :
				tf.y = Std.int(h - tf.textHeight);
		}
	}

	override function onWatchChange(v) {
		super.onWatchChange(v);
		set(v);
	}

	override function getContentWidth() {
		return super.getContentWidth() + tf.textWidth;
	}

	override function getContentHeight() {
		return super.getContentHeight() + tf.textHeight;
	}
}