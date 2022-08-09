package mt.deepnight.hui;

import mt.deepnight.hui.Style;

class Button extends Component {
	public static var STYLE : Style = {
		var s = new Style();
		s.bg = Col(0xA94012,1);
		s;
	};

	static var THIS : Button = null;

	var tf				: h2d.Text;

	public function new(p, label:String, cb:Void->Void) {
		super(p);

		style = new Style(Component.BASE_STYLE, this);
		style.copyValues(STYLE);

		tf = createField(label);
		content.addChild(tf);
		setLabel(label);

		onClick = cb;
		interactive.onClick = onButtonClick;
		interactive.onOver = onButtonOver;
		interactive.onOut = onButtonOut;
	}

	public dynamic function onClick() {}
	public dynamic function onOver() {}
	public dynamic function onOut() {}

	public static function getThis() {
		return THIS;
	}

	public function enable() {
		removeState("disabled");
	}

	public function disable() {
		addState("disabled");
	}

	function onButtonClick(e:hxd.Event) {
		if( !hasState("disabled") ) {
			THIS = this;
			onClick();
			THIS = null;
		}
	}

	function onButtonOver(e:hxd.Event) {
		if( !hasState("disabled") ) {
			THIS = this;
			addState("over");
			onOver();
			THIS = null;
		}
	}

	function onButtonOut(e:hxd.Event) {
		if( !hasState("disabled") ) {
			THIS = this;
			removeState("over");
			onOut();
			THIS = null;
		}
	}

	public function setLabel(str:String) {
		if( str=="" ) {
			tf.visible = false;
			return;
		}

		tf.visible = true;
		tf.text = str;
		askRender(true);
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		switch( style.contentHAlign ) {
			case None :
			case Left : tf.x = 0;
			case Center : tf.x = Std.int(w*0.5 - tf.textWidth*0.5 - 1);
			case Right : tf.x = Std.int(w - tf.textWidth);
		}

		switch( style.contentVAlign ) {
			case None :
			case Top : tf.y = 0;
			case Center : tf.y = Std.int(h*0.5 - tf.textHeight*0.5 - 1);
			case Bottom : tf.y = Std.int(h - tf.textHeight);
		}

		//tf.width = tf.textWidth+5;
		//tf.height = tf.textHeight+5;
	}


	override function getContentWidth() {
		return super.getContentWidth() + (tf.visible ? tf.textWidth + 5 : 0);
	}

	override function getContentHeight() {
		return super.getContentHeight() + (tf.visible ? tf.textHeight + 8 : 0);
	}
}
