package mt.deepnight.mui;

import flash.display.Sprite;

class Button extends Component {
	public static var BG_COLOR = 0xE8623C;
	static var THIS : Button = null;

	var tf				: flash.text.TextField;
	var centeredTxt		: Bool;

	public function new(p, label:String, cb:Void->Void) {
		super(p);

		color = BG_COLOR;
		centeredTxt = true;

		tf = createField(label);
		content.addChild(tf);
		setLabel(label);
		wrapper.buttonMode = wrapper.useHandCursor = true;

		onClick = cb;
		wrapper.addEventListener(flash.events.MouseEvent.CLICK, onButtonClick);
	}

	public dynamic function onClick() {}

	public static function getThis() {
		return THIS;
	}

	public function enable() {
		removeState("disabled");
	}

	public function disable() {
		addState("disabled");
	}

	function onButtonClick(e:flash.events.MouseEvent) {
		if( onClick!=null && !hasState("disabled") ) {
			e.stopPropagation();
			THIS = this;
			onClick();
			THIS = null;
		}
	}

	public function setLabel(str:String) {
		if( str=="" ) {
			tf.visible = false;
			return;
		}

		tf.visible = true;
		var w = tf.width;
		var h = tf.height;
		tf.width = maxWidth;
		tf.height = maxHeight;
		tf.text = str;
		tf.width = tf.textWidth+5;
		tf.height = tf.textHeight+5;
		askRender(true);
	}

	public function setTextAlignLeft() {
		centeredTxt = false;
		askRender(false);
	}

	public function setTextAlignCenter() {
		centeredTxt = true;
		askRender(false);
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		if( centeredTxt )
			tf.x = Std.int(w*0.5 - tf.textWidth*0.5 - 1);
		else
			tf.x = 0;

		tf.y = Std.int(h*0.5 - tf.textHeight*0.5 - 1);

		tf.width = tf.textWidth+5;
		tf.height = tf.textHeight+5;
	}


	override function applyStates() {
		super.applyStates();

		if(	hasState("over") && !hasState("disabled") )
			bg.filters = [ new flash.filters.GlowFilter(0xFFFFFF,1, 2,2,4) ];
		else
			bg.filters = [];

		if( hasState("disabled") )
			bg.alpha = tf.alpha = 0.3;
		else
			bg.alpha = tf.alpha = 1;
	}


	override function getContentWidth() {
		return super.getContentWidth() + (tf.visible ? tf.textWidth + 5 : 0);
	}

	override function getContentHeight() {
		return super.getContentHeight() + (tf.visible ? tf.textHeight + 8 : 0);
	}
}