package mt.deepnight.mui;

enum LabelAlign {
	Left;
	Top;
	Center;
	Right;
	Bottom;
}

class Label extends Component {
	var tf			: flash.text.TextField;
	var halign		: LabelAlign;
	var valign		: LabelAlign;

	public var multiline(default, set)	: Bool;
	public var selectable(default, set)	: Bool;

	public function new(p, ?txt="") {
		super(p);

		hasBackground = false;
		halign = Center;
		valign = Center;

		tf = createField(txt);
		content.addChild(tf);
		setText(txt);

		multiline = false;
	}

	function set_selectable(v:Bool) {
		tf.mouseEnabled = tf.selectable = v;
		return selectable = v;
	}

	function set_multiline(v:Bool) {
		tf.multiline = tf.wordWrap = v;
		refreshText();
		return multiline = v;
	}

	function refreshText() {
		setText(tf.text);
	}

	public inline function getField() {
		return tf;
	}

	public inline function getText() {
		return tf.text;
	}

	public function setText(str:Dynamic) {
		tf.width = maxWidth;
		tf.height = maxHeight;

		tf.text = Std.string(str);

		updateTextFieldSize();

		askRender(true);
		return this;
	}

	public function setHAlign(a:LabelAlign) {
		halign = a;
		askRender(false);
		return this;
	}

	public function setVAlign(a:LabelAlign) {
		valign = a;
		askRender(false);
		return this;
	}

	override function prepareRender() {
		super.prepareRender();

		updateTextFieldSize();
	}

	function updateTextFieldSize() {
		if( forcedWidth!=null )
			tf.width = forcedWidth;
		else
			tf.width = mt.MLib.fmin( maxWidth, mt.MLib.fmax( minWidth, tf.textWidth+5 ) );

		if( forcedHeight!=null )
			tf.height = forcedHeight;
		else
			tf.height = mt.MLib.fmin( maxHeight, mt.MLib.fmax( minHeight, tf.textHeight+5 ) );
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		switch(halign) {
			case Left :
				tf.x = 0;

			case Center :
				tf.x = Std.int(w*0.5 - tf.textWidth*0.5);

			case Right :
				tf.x = Std.int(w - tf.textWidth);

			case Top, Bottom :
		}

		switch(valign) {
			case Top :
				tf.y = 0;

			case Center :
				tf.y = Std.int(h*0.5 - tf.textHeight*0.5);

			case Bottom :
				tf.y = Std.int(h - tf.textHeight);

			case Left, Right :
		}
	}

	override function onWatchChange(v) {
		super.onWatchChange(v);
		setText(v);
	}

	override function getContentWidth() {
		return super.getContentWidth() + tf.width;
	}

	override function getContentHeight() {
		return super.getContentHeight() + tf.height;
	}
}