package mt.deepnight.mui;

import flash.display.Sprite;
import mt.deepnight.Color;

class Check extends Component {
	public static var BG_COLOR = 0xE8623C;
	static var CHECK_WID = 15;

	var tf			: flash.text.TextField;
	var check		: Sprite;
	var onChange	: Null<Bool->Void>;

	public function new(p, label:String, ?selected=false, onChange:Bool->Void) {
		super(p);

		color = BG_COLOR;

		check = new Sprite();
		content.addChild(check);
		check.mouseChildren = check.mouseEnabled = false;

		tf = createField(label);
		content.addChild(tf);
		tf.width = tf.textWidth+5;
		tf.height = tf.textHeight+5;
		wrapper.buttonMode = wrapper.useHandCursor = true;

		toggleState("selected"); // force init
		toggleState("selected");

		if( selected )
			addState("selected");
		else
			removeState("selected");
		renderCheck();

		wrapper.addEventListener(flash.events.MouseEvent.CLICK, onClick);

		this.onChange = onChange;
	}


	//public function setFontSize(size:Int) {
		//var f = tf.getTextFormat();
		//f.size = size;
//
		//tf.setTextFormat(f);
		//tf.defaultTextFormat = f;
//
		//askRender(true);
	//}


	public function hideCheckBox() {
		check.visible = false;
		renderCheck();
		askRender(true);
	}



	function onClick(e:flash.events.MouseEvent) {
		e.stopPropagation();
		if( hasState("selected") )
			unselect();
		else
			select();
	}

	public function select() {
		addState("selected");
	}

	public function unselect() {
		removeState("selected");
	}

	public function setSelected(sel:Bool) {
		if( sel )
			addState("selected");
		else
			removeState("selected");
	}

	public function isSelected() {
		return hasState("selected");
	}


	override function applyStates() {
		super.applyStates();

		if( hasState("over") )
			bg.filters = [ new flash.filters.GlowFilter(0xFFFFFF,1, 2,2,4) ];
		else
			bg.filters = [];

		renderCheck();
	}

	override function onStateChange2(k,v) {
		super.onStateChange2(k,v);

		if( k=="selected" && onChange!=null ) {
			onChange(v);
			renderCheck();
		}
	}

	function renderCheck() {
		if( check.visible ) {
			check.graphics.clear();
			if( hasState("selected") ) {
				check.graphics.beginFill( 0xffffff, 1 );
				check.graphics.drawRect(0,0, CHECK_WID, CHECK_WID);
			}
			else {
				check.graphics.beginFill( Color.brightnessInt(color, -0.2), 1 );
				check.graphics.lineStyle( 1, 0x0, 0.3);
				check.graphics.drawRect(0,0, CHECK_WID, CHECK_WID);
			}
			updateCheckFilters();
		}
	}

	function updateCheckFilters() {
		if( check.visible ) {
			if( hasState("selected") )
				check.filters = [
					new flash.filters.GlowFilter(Color.brightnessInt(color, 0.2), 0.8, 4,4,1, 1, true),
					new flash.filters.GlowFilter(color, 0.5, 2,2,4),
					new flash.filters.GlowFilter(Color.brightnessInt(color, 0.4), 1, 4,4,2),
					new flash.filters.GlowFilter(Color.brightnessInt(color, 0.4), 1, 16,16,2),
				];
			else
				check.filters = [];
		}
		else {
			if( hasState("selected") )
				bg.filters = [
				new flash.filters.GlowFilter(Color.brightnessInt(color, 0.4), 1, 4,4,1, 1, true),
					new flash.filters.GlowFilter(0xffffff, 1, 2,2,6),
					new flash.filters.GlowFilter(Color.brightnessInt(color, 0.3), 0.8, 16,16,1),
				];
			else
				bg.filters = [];
		}
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		var cwid = getContentWidth();
		if( check.visible ) {
			check.x = 5;
			check.y = Std.int(h*0.5 - check.height*0.5 + 1);

			tf.x = check.x + CHECK_WID + 8;
			tf.y = Std.int(h*0.5 - tf.textHeight*0.5 - 1);
		}
		else {
			tf.x = Std.int(w*0.5 - tf.textWidth*0.5 - 1);
			tf.y = Std.int(h*0.5 - tf.textHeight*0.5 - 1);
		}

		tf.width = tf.textWidth+5;
		tf.height = tf.textHeight+5;
	}

	override function onWatchChange(v) {
		super.onWatchChange(v);

		if( v==true && !isSelected() )
			select();

		if( v==false && isSelected() )
			unselect();
	}

	override function getContentWidth() {
		return super.getContentWidth() + (tf.visible ? tf.textWidth + 5 : 0) + (check.visible ? CHECK_WID + 13 : 0);
	}

	override function getContentHeight() {
		return super.getContentHeight() + (tf.visible ? tf.textHeight + 8 : 0);
	}
}