package mt.deepnight.hui;

import h2d.Bitmap;
import h2d.Text;
import h2d.Graphics;
import mt.deepnight.Color;

class Check extends Button {
	static var CHECK_WID = 16;
	public static var STYLE = {
		var s = new Style();
		s.checkType = CheckBox;
		s.bg = Col(0xA94012,1);
		s.contentHAlign = Left;
		s;
	}

	var checkOn		: Bitmap;
	var checkOff	: Bitmap;
	var onChange	: Null<Bool->Void>;

	public function new(p, label:String, ?selected=false, onChange:Bool->Void) {
		super(p, label, function() {});

		style = new Style(Component.BASE_STYLE,this);
		style.copyValues(STYLE);

		checkOn = new h2d.Bitmap(h2d.Tile.fromColor(0xffffffff,CHECK_WID,CHECK_WID), content);
		checkOff = new h2d.Bitmap(h2d.Tile.fromColor(0xff000000,CHECK_WID,CHECK_WID), content);

		toggleState("selected"); // force init
		toggleState("selected");

		if( selected )
			addState("selected");
		else
			removeState("selected");
		renderCheck();

		this.onChange = onChange;
	}


	override function destroy() {
		super.destroy();
		checkOn.dispose();
		checkOff.dispose();
	}



	override function onButtonClick(e:hxd.Event) {
		super.onButtonClick(e);
		if( !hasState("disabled") )
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

	public inline function isSelected() {
		return hasState("selected");
	}


	override function applyStates() {
		super.applyStates();
		renderCheck();
	}

	override function onStateChange(k,v) {
		super.onStateChange(k,v);

		if( k=="selected" && onChange!=null )
			onChange(v);
	}

	function renderCheck() {
		switch( style.checkType ) {
			case CheckBox :
				checkOn.visible = hasState("selected");
				checkOff.visible = !checkOn.visible;

			case Outline(c,a) :
				checkOn.visible = hasState("selected");
				checkOff.visible = false;
		}
	}


	override function renderContent(w,h) {
		super.renderContent(w,h);

		renderCheck();
		switch( style.checkType ) {
			case CheckBox :
				switch( style.contentHAlign ) {
					case None :

					case Left :
						checkOn.x = Std.int(tf.x);
						checkOff.x = Std.int(tf.x);

					case Right :
						checkOn.x = Std.int(tf.x-CHECK_WID-8);
						checkOff.x = Std.int(tf.x-CHECK_WID-8);

					case Center :
						checkOn.x = Std.int(tf.x - checkOn.width*0.5 );
						checkOff.x = Std.int(tf.x - checkOff.width*0.5 );
				}

				checkOn.y = Std.int(tf.y+tf.textHeight*0.5 - checkOn.height*0.5);
				checkOff.y = Std.int(tf.y+tf.textHeight*0.5 - checkOff.height*0.5);
				checkOn.scaleX = checkOn.scaleY = 1;
				tf.x = checkOn.x + CHECK_WID + 8;

			case Outline(c,a) :
				checkOn.scaleX = w/checkOn.tile.width; // TODO
				checkOn.scaleY = h/checkOn.tile.height;
				checkOn.alpha = 0.2;
		}
	}

	override function onWatchChange(v) {
		super.onWatchChange(v);

		if( v==true && !isSelected() )
			select();

		if( v==false && isSelected() )
			unselect();
	}

	override function getContentWidth() {
		return super.getContentWidth() + (style.checkType==CheckBox ? CHECK_WID + 8 : 0);
	}

	override function getContentHeight() {
		return super.getContentHeight();
	}
}