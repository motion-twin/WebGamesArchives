package ui;

import mt.MLib;
import mt.deepnight.Color;
import mt.deepnight.slb.*;
import mt.data.GetText;
import mt.device.TextField;
import com.*;

class Question extends H2dProcess {
	public static var CURRENT : Question;

	public var ctrap		: h2d.Interactive;
	public var wrapper		: h2d.Sprite;
	public var elements		: Array<{ s:h2d.Sprite, wid:Float, hei:Float }>;
	public var inputs		: Array<{ i:TextField, e:h2d.Sprite }>;
	var win					: h2d.Sprite;

	public var maxWid		: Int;
	var totalHei			: Float;
	var bhei				: Int = 60;
	var locked				: Bool;
	var ts					: Null<h2d.Drawable.DrawableShader>;
	var shotel(get,never)	: SHotel; inline function get_shotel() return Game.ME.shotel;
	var autoClose			: Bool;
	var inputFocus			: Bool;
	var ctrapCancels		: Bool;
	var padding = 20;

	public function new(?widMul=1.0, ?ctrapCancels=true) {
		clear();
		CURRENT = this;
		locked = false;
		autoClose = true;
		this.ctrapCancels = ctrapCancels;
		Game.ME.fx.clearAll();
		ui.Notification.NotificationManager.clearAll();
		inputs = [];
		inputFocus = false;
		totalHei = 0;

		super(Game.ME);
		Main.ME.uiWrapper.add(root, Const.DP_POP_UP);

		elements = [];
		name = 'Question';
		maxWid = MLib.min(MLib.ceil(650*widMul), w()-20);

		ctrap = new h2d.Interactive(8,8,root);
		ctrap.backgroundColor = alpha(Const.BLUE,0.85);
		ctrap.onClick = function(_) {
			if( !locked && ctrapCancels && !inputFocus )
				_onCancel();
		}

		win = new h2d.Sprite(root);
		wrapper = new h2d.Sprite(root);

		onResize();

		Assets.SBANK.click2(1);
	}

	public static function clear() {
		if( CURRENT!=null ) {
			CURRENT.destroy();
			CURRENT = null;
		}
	}

	public dynamic function onCancel() {
		destroy();
	}

	public function onBack() {
		if( ctrapCancels )
			onCancel();
	}

	function clearContent() {
		for(i in inputs)
			i.i.destroy();
		inputs = [];
		wrapper.removeAllChildren();
		elements = [];
		locked = false;
	}

	function _onCancel() {
		onCancel();
	}

	public inline function addCancel(?label:LocaleString) {
		addWhiteSpace();
		addButton( label!=null ? label : Lang.t._("Cancel") );
	}

	public inline function addOk(?label:LocaleString) {
		addWhiteSpace();
		addButton( label!=null ? label : Lang.t._("Ok") );
	}


	public function addCenteredSprite(s:h2d.Sprite, ?spaceAfter=true) {
		if( s.parent!=null )
			s.detach();
		wrapper.addChild(s);
		elements.push({ s:s, wid:s.width, hei:s.height+(spaceAfter?20:0) });
		rebuild();
	}

	public function addTextAndSprite(icon:h2d.Sprite, text:LocaleString, ?col=-1, ?spaceAfter=true) {
		var s = new h2d.Sprite(wrapper);

		var tf = Assets.createText(38, col==-1?0xFFFF80:col, text, s, ts);
		if( ts==null )
			ts = tf.shader;
		tf.dropShadow = { color:0x0, alpha:0.6, dx:0, dy:5 }
		tf.maxWidth = maxWid/tf.scaleX;
		tf.filter = true;
		tf.emit = true;
		//tf.x = maxWid*0.5 - tf.textWidth*tf.scaleX*0.5;
		//tf.y = bg.height*0.5 - tf.textHeight*tf.scaleY*0.5 - padding;

		if( icon.parent!=null )
			icon.detach();
		s.addChild(icon);
		icon.x = maxWid-icon.width*0.5;

		if( icon.height>tf.textHeight*tf.scaleY ) {
			icon.y = icon.height*0.5;
			tf.y = icon.y - tf.textHeight*tf.scaleY*0.5;
		}
		else
			icon.y = tf.textHeight*tf.scaleY*0.5;


		elements.push({ s:s, wid:maxWid, hei:MLib.fmax(icon.height, tf.textHeight*tf.scaleY)+(spaceAfter?20:0) });
		rebuild();
	}

	public function addSeparator() {
		addWhiteSpace();

		var s = Assets.tiles.getH2dBitmap("white", wrapper);
		s.color = h3d.Vector.fromColor( alpha(mt.deepnight.Color.brightnessInt(Const.BLUE,0.2))) ;
		s.width = maxWid;
		s.height = 1;
		elements.push({ s:s, wid:maxWid, hei:1 });

		addWhiteSpace();
	}

	public function addWhiteSpace(?h=1.0) {
		var s = Assets.tiles.getH2dBitmap("white", wrapper);
		s.height = 16*h;
		s.alpha = 0;
		elements.push({ s:s, wid:maxWid, hei:s.height });
		rebuild();
	}

	public function addEmptyFrame(h:Float) {
		var s = new h2d.Sprite(wrapper);

		var filler = Assets.tiles.getH2dBitmap("white", s);
		filler.setSize(maxWid, h);
		filler.alpha = 0;

		elements.push({ s:s, wid:maxWid, hei:h });
		rebuild();
		return s;
	}

	public inline function countElements() return elements.length;


	//public function addButtonPack(buttons:Array<{label:String, icon:String, cb:Void->Void}>) {
		//var m = 5;
		//var wid = ( maxWid-(m*buttons.length-1) ) / buttons.length;
		//var hei = 120;
//
		//var ctx = addEmptyFrame(hei);
//
		//var i = 0;
		//for(b in buttons) {
			//var s = new h2d.Sprite(ctx);
			//s.x = i*(wid+m);
//
			//var bg = Assets.tiles.getH2dBitmap("btnAction", s);
			//bg.setSize(wid,hei);
			//bg.emit = true;
//
			//var tf = new h2d.Text(Assets.fontHuge, s, ts!=null?cast ts.clone():null);
			//if( ts==null )
				//ts = tf.shader;
			//tf.text = Lang.fixMissingFontChars(b.label);
			//tf.scale( 0.7 );
			//if( b.label.length>30 )
				//tf.scale(0.78);
			//tf.maxWidth = (wid-10)/tf.scaleX;
			//tf.x = Std.int( wid*0.5 - tf.width*0.5*tf.scaleX );
			//tf.y = Std.int( hei - tf.height*tf.scaleY );
			//tf.filter = true;
			//tf.textColor = Const.BLUE;
			//tf.emit = true;
//
			//var icon = Assets.tiles.getH2dBitmap(b.icon);
			//s.addChild(icon);
			//icon.tile.setCenterRatio(0.5, 1);
			//icon.scale( (hei-tf.y-5)/icon.height );
			//icon.x = Std.int( wid*0.5 );
			//icon.y = Std.int( tf.y - 5);
			//icon.filter = true;
			//icon.emit = true;
//
			//i++;
		//}
	//}


	public function addButton(label:LocaleString, ?iconId:String, ?active=true, ?cb:Void->Void) {
		var s = new h2d.Sprite(wrapper);

		var wid = maxWid;
		var hei = bhei;
		var isize = bhei*0.8;

		var bg = Assets.tiles.getH2dBitmap(active?"btnAction":"btnActionOff", s);
		bg.width = wid;
		bg.height = hei;
		bg.emit = true;

		var tf = new h2d.Text(Assets.fontHuge, s, ts!=null?cast ts.clone():null);
		if( ts==null )
			ts = tf.shader;
		tf.text = Lang.fixMissingFontChars(label);
		tf.scale( MLib.fmin( (hei-25)/(tf.height*tf.scaleY), (wid-25)/(tf.width*tf.scaleX) ) );
		if( label.length>30 )
			tf.scale(0.78);
		tf.maxWidth = (wid-10)/tf.scaleX;
		tf.x = Std.int( wid*0.5 - tf.width*0.5*tf.scaleX );
		tf.y = Std.int( hei*0.5 - tf.height*0.5*tf.scaleY );
		tf.filter = true;
		tf.textColor = Const.BLUE;
		tf.alpha = active ? 1 : 0.4;
		tf.emit = true;

		if( iconId!=null ) {
			var icon = Assets.tiles.getH2dBitmap(iconId);
			s.addChild(icon);
			icon.tile.setCenterRatio(1, 0.5);
			icon.scale( isize/icon.height );
			tf.x += icon.width*0.5;
			icon.x = Std.int( tf.x - 10 );
			icon.y = Std.int(hei*0.5);
			icon.filter = true;
			icon.emit = true;
			icon.alpha = active ? 1 : 0.5;
		}

		var i = new h2d.Interactive(wid, hei, s);
		i.onClick = function(_) {
			if( !active || locked || destroyed )
				return;

			locked = true;

			// Blink current
			var blink = new h2d.Bitmap( h2d.Tile.fromColor(alpha(0xFFA600), wid+10,hei+10), s );
			blink.tile.setCenterRatio(0.5, 0.5);
			blink.x = wid*0.5;
			blink.y = hei*0.5;
			blink.blendMode = Add;
			var a = tw.create(blink.alpha, 0, 160);
			a.onUpdateT = function(t) {
				blink.alpha = 1-t;
			}
			a.onEnd = function() {
				if( autoClose )
					destroy();
				if( cb!=null )
					cb();
				else {
					locked = false;
					_onCancel();
				}
			};

			Assets.SBANK.click1(1);
		}
		i.onOver = function(_) if( active ) bg.color = h3d.Vector.fromColor(alpha(0xFFFF80), 1.1);
		i.onOut = function(_) if( active ) bg.color = null;

		elements.push({ s:s, wid:maxWid, hei:hei });
		rebuild();
	}

	public function addCheck(label:LocaleString, value:Bool, ?iconId:String, ?cb:Bool->Void) {
		var s = new h2d.Sprite(wrapper);

		var wid = maxWid;
		var hei = 60;

		var bg = new h2d.Bitmap( h2d.Tile.fromColor(alpha(0x0, 0.2)), s);
		bg.width = wid;
		bg.height = hei;

		var tf = new h2d.Text(Assets.fontHuge, s, ts!=null?cast ts.clone():null);
		if( ts==null )
			ts = tf.shader;
		tf.text = label;
		tf.scale( (hei-20) / (tf.height*tf.scaleY) );
		tf.maxWidth = (wid-10)/tf.scaleX;
		tf.x = Std.int( 10 );
		tf.y = Std.int( hei*0.5 - tf.height*0.5*tf.scaleY );
		tf.filter = true;

		var chk = Assets.tiles.h_get("check", s);
		chk.setCenterRatio(0.5, 0.5);
		chk.x = wid-35;
		chk.y = hei*0.5;
		chk.scale(1.5);

		if( iconId!=null ) {
			var icon = Assets.tiles.getH2dBitmap(iconId,0, 0,0.5);
			s.addChild(icon);
			icon.x = 10;
			icon.y = Std.int(hei*0.5);
			icon.filter = true;
			tf.x+=icon.width+10;
		}

		function _applyValue() {
			chk.set( value?"check":"iconForbidden" );
			chk.setScale( value?1:0.8 );
			tf.textColor = value ? 0xFFF9CA : 0xC13A00;
			//tf.alpha = value?1:0.5;
		}
		_applyValue();

		var i = new h2d.Interactive(wid, hei, s);
		i.onClick = function(_) {
			if( locked || destroyed )
				return;

			value = !value;
			if( cb!=null )
				cb(value);
			_applyValue();

			Assets.SBANK.click1(1);
		}

		elements.push({ s:s, wid:maxWid, hei:hei });
		rebuild();
	}

	public function addInput( val:String, ?autoCorrect=false, onChange:String->Void, ?onAction:Void->Void ) {
		var s = new h2d.Sprite(wrapper);

		var i = new mt.device.TextField();
		i.text = val;
		i.textColor = alpha(0xffffff);
		i.maxLength = GameData.HOTEL_NAME_MAX_LENGTH;
		i.onTextChanged = onChange;
		i.type = autoCorrect ? TF_Text : TF_TextNoAutoCorrect;
		inputs.push({ i:i, e:s });

		var bg = Assets.tiles.getColoredH2dBitmap("white", 0xffffff, 0.1, s);
		bg.width = maxWid;
		bg.height = bhei*0.8;
		bg.emit = true;

		var e = Assets.tiles.h_get("enluminureSlim", s);
		e.setPivotCoord(7,7);
		e.scale(0.75);
		var e = Assets.tiles.h_get("enluminureSlim", s);
		e.setPivotCoord(7,7);
		e.scale(0.75);
		e.rotate(MLib.PI);
		e.x = bg.width;
		e.y = bg.height;

		i.onFocusChanged = function(v) {
			inputFocus = v;
			bg.alpha = v ? 1 : 0.5;
			Game.ME.typing = v;
			onResize();
		}
		i.onFocusChanged(false);

		i.actionType = ACT_Done;
		if( onAction!=null )
			i.onAction = onAction;

		elements.push({ s:s, wid:maxWid, hei:bg.height+20 });
		rebuild();
	}


	public function addTitle(label:LocaleString) {
		var s = new h2d.Sprite(wrapper);

		var bg = Assets.tiles1.h_get("welcomeBack", s);
		bg.width = maxWid+padding*2;
		bg.x = -padding;
		bg.y = -padding;

		var tf = Assets.createText(38, 0xFFFF80, label, s, ts);
		if( ts==null )
			ts = tf.shader;
		tf.dropShadow = { color:0x0, alpha:0.6, dx:0, dy:5 }
		tf.maxWidth = maxWid/tf.scaleX;
		tf.filter = true;
		tf.emit = true;
		tf.x = maxWid*0.5 - tf.textWidth*tf.scaleX*0.5;
		tf.y = bg.height*0.5 - tf.textHeight*tf.scaleY*0.5 - padding;

		//bg.height = tf.textHeight*tf.scaleY;

		elements.push({ s:s, wid:maxWid, hei:bg.height + 15 });
		rebuild();
	}

	public function addText(?indent=0, label:LocaleString, ?iconId:String, ?col=-1, ?spaceAfter=true, ?scale=1.0) {
		var s = new h2d.Sprite(wrapper);

		var tf = new h2d.Text(Assets.fontHuge, s, ts!=null?cast ts.clone():null);
		if( ts==null )
			ts = tf.shader;
		tf.text = Lang.addNbsps( Lang.fixMissingFontChars(label) );
		tf.scale(0.5*scale);
		tf.textColor = col==-1 ? 0xFFFF80 : col;
		tf.dropShadow = { color:(col==-1 ? 0xAD400C : Color.brightnessInt(col,-0.6)), alpha:1, dx:0, dy:5 }
		tf.maxWidth = maxWid/tf.scaleX;
		tf.x = Std.int( indent );
		tf.filter = true;
		tf.emit = true;

		var isize = 50;
		if( iconId!=null ) {
			var icon = Assets.tiles.h_get(iconId,0, 0.5,0.5);
			s.addChild(icon);
			icon.constraintSize(isize);
			icon.x = Std.int( indent + isize*0.5 );
			icon.y = Std.int( tf.textHeight*tf.scaleY*0.5 );
			icon.filter = true;
			icon.emit = true;
			tf.x += isize + 10;
			tf.maxWidth -= (isize+10)/tf.scaleX;
		}

		elements.push({ s:s, wid:maxWid, hei:tf.textHeight*tf.scaleY + (spaceAfter?20:0) });
		rebuild();

		return s;
	}

	public function addValue(label:LocaleString, value:Dynamic, ?col=-1, ?spaceAfter=true, ?fontSize=36) {
		var value : String = switch( Type.typeof(value) ) {
			case Type.ValueType.TInt : Game.ME.prettyNumber(value);
			default : Std.string(value);
		}
		var s = new h2d.Sprite(wrapper);

		var wid = maxWid;

		var bg = Assets.tiles.getColoredH2dBitmap("white", 0x0, 0.2, s);
		bg.width = wid;

		var tf = Assets.createText(fontSize, col==-1?0xFFFF80:col, Lang.addNbsps(label), s, ts);
		if( ts==null ) ts = tf.shader;
		tf.dropShadow = { color:(col==-1 ? 0xAD400C : Color.brightnessInt(col,-0.6)), alpha:1, dx:0, dy:2 }
		tf.maxWidth = wid/tf.scaleX-10;

		var tv = Assets.createText(Std.int(1.25*fontSize), col==-1?0xFFFFFF:col, value, s, ts);
		tv.x = wid - tv.textWidth*tv.scaleX;
		tf.y = tv.textHeight*tv.scaleY*0.5 - tf.textHeight*tf.scaleY*0.5;

		bg.height = tv.textHeight*tv.scaleY;
		bg.visible = elements.length%2==0;

		elements.push({ s:s, wid:maxWid, hei:tf.height*tf.scaleY + (spaceAfter?20:0) });
		rebuild();
	}

	public function cancelAnimation() {
		tw.complete(wrapper.y);
		tw.complete(win.y);
	}

	function rebuild() {
		var y = 0.;
		var margin = #if responsive 7 #else 3 #end;
		for(e in elements) {
			e.s.x = Std.int(maxWid*0.5 - e.wid*0.5);
			e.s.y = y;
			y+=e.hei+margin;
		}
		totalHei = y-margin;

		onResize();

		for(e in inputs)
			updateInput(e);

		// Animate arrival
		Assets.SBANK.slide1(0.1);
		var y = wrapper.y;
		tw.create(wrapper.y, this.h()>y, 250);
		tw.create(win.y, this.h()>y, 250);
	}


	override function onResize() {
		super.onResize();

		if( wrapper!=null ) {
			wrapper.setScale(1);
			wrapper.setScale( MLib.fmin( Main.getScale(bhei,0.8), MLib.fmin( (w()-60)/maxWid, (h()-60)/totalHei ) ) );

			var w = maxWid*wrapper.scaleX;
			var h = totalHei*wrapper.scaleY;

			wrapper.x = Std.int( this.w()*0.5 - w*0.5 );
			#if mobile
			wrapper.y = Std.int( inputFocus ? 20/wrapper.scaleY : this.h()*0.5 - h*0.5 );
			#else
			wrapper.y = Std.int( this.h()*0.5 - h*0.5 );
			#end

			ctrap.width = this.w();
			ctrap.height = this.h();

			// Window
			win.disposeAllChildren();
			win.x = wrapper.x;
			win.y = wrapper.y;
			var i = new h2d.Interactive(w+padding*2, h+padding*2, win);
			i.backgroundColor = alpha(Const.BLUE);
			i.setPos(-padding, -padding);
			var p = padding+10;
			var e = Assets.tiles.getH2dBitmap("enluminure", win);
			e.setPos(-p, -p);
			var e = Assets.tiles.getH2dBitmap("enluminure", win);
			e.setPos(w+p, -p);
			e.rotate(MLib.PI*0.5);
			var e = Assets.tiles.getH2dBitmap("enluminure", win);
			e.setPos(w+p, h+p);
			e.rotate(MLib.PI);
			var e = Assets.tiles.getH2dBitmap("enluminure", win);
			e.setPos(-p, h+p);
			e.rotate(-MLib.PI*0.5);
		}
	}


	override function onDispose() {
		super.onDispose();

		for(e in inputs)
			e.i.destroy();
		inputs = null;
		Game.ME.typing = false;

		ctrap = null;
		wrapper = null;
		win = null;

		for(e in elements)
			e.s.dispose();
		elements = null;

		if( CURRENT==this )
			CURRENT = null;
	}


	public inline function getScale() return wrapper==null ? 1 : wrapper.scaleX;


	function updateInput(e:{ i:TextField, e:h2d.Sprite }) {
		e.i.x = wrapper.x + (e.e.x + 5)*wrapper.scaleX;
		e.i.y = wrapper.y + (e.e.y + 5)*wrapper.scaleY;
		e.i.textSize = 32*wrapper.scaleX;
		e.i.width = maxWid*wrapper.scaleX;
		e.i.height = Std.int( bhei*0.8*wrapper.scaleY );
	}

	override function update() {
		super.update();

		for(e in inputs)
			updateInput(e);
	}
}
