package mt.deepnight.mui;

import flash.ui.Keyboard;
import flash.display.Sprite;
import mt.flash.Key;

class TextInput extends Component {
	public static var BG_COLOR = 0x3F4661;

	var tf					: flash.text.TextField;
	var autoSelectTimer		: Int;
	var lastValue			: String;
	var endOnRender			: Bool;
	var numberOnly			: Bool;

	var tshadow				: Sprite;
	var bshadow				: Sprite;

	public var readOnly(default,set)	: Bool;
	public var multiLine(default,set)	: Bool;
	public var onValidate				: Null<String->Void>;

	//var topShadow			: Sprite;
	//var joystick			: Joystick;

	public function new(p, ?txt="", ?onValidate:String->Void, ?numberOnly=false) {
		super(p);

		this.numberOnly = numberOnly;
		lastValue = txt;
		endOnRender = false;
		this.onValidate = onValidate;
		minWidth = 50;
		autoSelectTimer = 0;
		color = BG_COLOR;
		minWidth = 70;

		tf = createField(txt);
		tf.x = 4;
		tf.y = 2;
		content.addChild(tf);
		setText(txt);
		tf.type = flash.text.TextFieldType.INPUT;
		tf.selectable = tf.mouseEnabled = true;

		tf.addEventListener( flash.events.MouseEvent.CLICK, function(_) onClick() );
		tf.addEventListener( flash.events.FocusEvent.FOCUS_IN, function(_) addState("focus") );
		tf.addEventListener( flash.events.FocusEvent.FOCUS_OUT, function(_) removeState("focus") );
		tf.addEventListener( flash.events.Event.SCROLL, function(_) onScroll() );
		tf.addEventListener( flash.events.KeyboardEvent.KEY_DOWN, onKey );
		tf.addEventListener( flash.events.Event.CHANGE, onTextChange);

		setText(txt);

		readOnly = false;
		multiLine = false;

		var m = new flash.geom.Matrix();
		var ssize = 30;
		var salpha = 0.4;

		// Top shadow
		tshadow = new Sprite();
		content.addChild(tshadow);
		m.createGradientBox(ssize,ssize, Math.PI*0.5);
		tshadow.graphics.beginGradientFill(LINEAR, [0x0, 0x0], [salpha, 0], [0,255], m);
		tshadow.graphics.drawRect(0,0, ssize,ssize);

		// Bottom shadow
		bshadow = new Sprite();
		content.addChild(bshadow);
		m.createGradientBox(ssize,ssize, -Math.PI*0.5);
		bshadow.graphics.beginGradientFill(LINEAR, [0x0, 0x0], [salpha, 0], [0,255], m);
		bshadow.graphics.drawRect(0,0, ssize,ssize);

		//joystick = new Joystick(this, onJoystick);
	}

	//public function setFontSize(pt:Int) {
		//var f = tf.getTextFormat();
		//f.size = pt;
		//tf.defaultTextFormat = f;
		//tf.setTextFormat(f);
	//}
//
	//public function setFont(font:String) {
		//var f = tf.getTextFormat();
		//f.font = font;
		//tf.defaultTextFormat = f;
		//tf.setTextFormat(f);
	//}

	function onJoystick(dx:Float, dy:Float) {
		var dir = dx<0 ? -1 : 1;
		tf.scrollH = mt.MLib.max(0, tf.scrollH + Math.round(dir * dx*dx*15));
		tf.scrollV += Math.round(dy*0.7);

		updateShadows();
	}

	function set_multiLine(v) {
		tf.multiline = tf.wordWrap = multiLine = v;
		return v;
	}

	function set_readOnly(v) {
		readOnly = v;
		if( readOnly )
			tf.type = flash.text.TextFieldType.DYNAMIC;
		else
			tf.type = flash.text.TextFieldType.INPUT;
		return v;
	}

	public function setText(str:Dynamic) {
		tf.width = maxWidth;
		tf.height = maxHeight;

		tf.text = Std.string(str);

		updateTextFieldSize();

		askRender(false);
	}

	public inline function clear() {
		setText("");
	}

	public function getText() {
		return tf.text;
	}

	public function scrollToEnd() {
		endOnRender = true;
		askRender(false);
	}

	public function addLine(str:Dynamic, ?scrollToBottom=true) {
		var t = getText();
		if( t.length>0 )
			setText( t + "\n" + str );
		else
			setText(str);

		if( scrollToBottom )
			this.scrollToEnd();
	}


	public inline function getTextAsInt() {
		return Std.parseInt(tf.text);
	}


	public inline function getTextAsFloat() {
		return Std.parseFloat(tf.text);
	}


	function onTextChange(e:flash.events.Event) {
		if( numberOnly ) {
			var s = getText().split("").filter( function(c) {
				return c=="-" || c=="." || c>="0" && c<="9";
			}).join("");
			setText(s);
		}
		askRender(false);
	}


	override function applyStates() {
		super.applyStates();

		if( hasState("focus") ) {
			lastValue = getText();
			bg.filters = [
				new flash.filters.GlowFilter(0x0,0.7, 8,8, 1, 1,true),
				new flash.filters.GlowFilter(0xFFFFFF,1, 2,2,8),
				new flash.filters.GlowFilter(0x0, 1, 2,2,3),
			];
			autoSelectTimer = flash.Lib.getTimer();
		}
		else {
			validate();
			bg.filters = [];
		}
	}

	override function askRender(structureChanged) {
		super.askRender(structureChanged);

		//if( structureChanged && joystick!=null )
			//joystick.askRender(structureChanged);
	}

	override function prepareRender() {
		super.prepareRender();
		//joystick.setPos( getWidth()-joystick.getWidth()-1 + 10, getHeight()*0.5-joystick.getHeight()*0.5 + 2 );
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

	function updateShadows() {
		if( tshadow==null )
			return;

		var lineHei = tf.textHeight / tf.numLines;
		var visibleLines = Std.int(tf.height/lineHei);

		var w = getWidth();
		var h = getHeight();
		tshadow.visible = tf.scrollV>1;
		tshadow.width = w;

		bshadow.visible = tf.text.length>0 && tf.scrollV <= tf.numLines - visibleLines;
		bshadow.width = w;
		bshadow.y = h - bshadow.height;
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		tf.width = w - tf.x;
		tf.height = h - tf.y;
		updateShadows();

		// Auto-hide joystick when not needed
		//if( tf.textWidth>tf.width || tf.textHeight>tf.height )
			//joystick.show();
		//else
			//joystick.hide();

		if( endOnRender ) {
			endOnRender = false;
			tf.setSelection(tf.text.length-1, tf.text.length-1);
		}
	}

	function onScroll() {
		updateShadows();
	}


	function onClick() {
		if( !readOnly && flash.Lib.getTimer()-autoSelectTimer <= 300 )
			tf.setSelection(0,9999);
	}


	function onKey(e:flash.events.KeyboardEvent) {
		var k = e.keyCode;

		if( !multiLine ) {
			if( k == Key.ENTER ) {
				validate();
				leave();
			}

			if( k== Key.ESCAPE ) {
				setText( lastValue );
				leave();
			}
		}
		else {
			if( k== Key.ESCAPE ) {
				validate();
				leave();
			}
		}
	}

	public function focus() {
		wrapper.stage.focus = tf;
	}

	function leave() {
		if( wrapper.stage!=null )
			wrapper.stage.focus = null;
	}

	function validate() {
		if( onValidate!=null )
			onValidate( getText() );
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

