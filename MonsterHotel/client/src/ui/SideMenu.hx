package ui;

import mt.MLib;
import mt.data.GetText;
import mt.deepnight.Lib;
import com.Protocol;
import b.Room;
import h2d.SpriteBatch;

@:allow(ui.side.Button) class SideMenu extends H2dProcess {
	public static var ALL : Array<SideMenu> = [];

	public var ctrap		: h2d.Interactive;
	public var wrapper		: h2d.Layers;
	var buttons				: Array<ui.side.Button>;
	var drag				: { clicking:Bool, x:Float, y:Float, dy:Float, active:Bool, vertical:Bool, value:Null<Dynamic>, time:Float };
	var cursor				: h2d.Sprite;
	var bg					: h2d.Bitmap;

	var invalidated			: Bool;
	public var isOpen		: Bool;
	var cols				: Int;
	public var wid			: Int;
	public var bhei			: Int;
	var margin				: Int;
	var g(get,never)		: Game;
	var collapsed			: Bool;
	var topLimitRatio		: Float;
	var locked				: Bool;

	var sb					: h2d.SpriteBatch;
	var tsb					: h2d.SpriteBatch;
	var utsb				: h2d.SpriteBatch;

	public var left			: Bool;

	var shotel(get,never)	: com.SHotel; inline function get_shotel() return Game.ME.shotel;

	public function new() {
		super(Game.ME);


		locked = false;
		ALL.push(this);
		left = false;
		topLimitRatio = 0.1;

		invalidated = true;
		isOpen = false;
		drag = { clicking:false, x:0, y:0, dy:0, active:false, vertical:false, value:null, time:0 }
		buttons = [];
		name = 'SideMenu';
		wid = 400;
		bhei = 100;
		cols = 1;
		margin = 0;
		collapsed = false;

		bg = Assets.tiles.getH2dBitmap("sideBg",0);
		Main.ME.uiWrapper.add(bg, Const.DP_POP_UP_BG);

		ctrap = new h2d.Interactive(8,8,root);
		ctrap.onPush = onPush;
		ctrap.onRelease = onRelease;
		ctrap.onWheel = onWheel;

		wrapper = new h2d.Layers(root);
		wrapper.x = getClosedX();

		ctrap.x = getClosedX();

		sb = new h2d.SpriteBatch(Assets.tiles.tile, wrapper);
		sb.filter = true;
		sb.name = name+".sb";

		tsb = new h2d.SpriteBatch(Assets.fontTiny.tile, wrapper);
		tsb.filter = true;
		tsb.name = name+".tsb";

		utsb = new h2d.SpriteBatch(Assets.fontHuge.tile, wrapper);
		utsb.filter = true;
		utsb.name = name+".utsb";

		cursor = new h2d.Sprite(root);
		cursor.visible = false;

		onResize();
		hide();
	}

	inline function isSmall() return hcm()<9;

	//override function set_name(s:String) {
		//super.set_name(s);
		//if( sb!=null ) {
			//sb.name = name+".sb";
			//tsb.name = name+".tsb";
			//utsb.name = name+".utsb";
		//}
		//return s;
	//}

	function setCollapsed(v) {
		if( !isOpen )
			return;

		collapsed = v;
		updateCoords();
	}

	public inline function isCollapsed() return collapsed;

	inline function get_g() return Game.ME;

	public function invalidate() {
		if( destroyed )
			return;

		if( isOpen )
			refresh();
		else
			invalidated = true;
	}

	function refresh() {
		invalidated = false;
	}

	public function close() {
		if( !isOpen )
			return;

		isOpen = false;
		Assets.SBANK.slide2().play(0.25, 0.5);

		tw.create(wrapper.x, getClosedX(), 200);
		tw.create(ctrap.x, getClosedX(), 300)
			.update( ui.HudMenu.CURRENT.updateCoords )
			.end( hide );
	}

	public function toggle() {
		if( isOpen )
			close();
		else
			open();
		return isOpen;
	}

	public function open() {
		closeAll();

		isOpen = true;

		Main.ME.uiWrapper.add(root, Const.DP_POP_UP);
		root.visible = true;
		bg.visible = true;
		wrapper.y = hcm()>9 ? h()*0.05 : 0;

		Assets.SBANK.slide1().play(0.35, 0.5);
		Assets.SBANK.click1(1);
		Game.ME.unselect();

		setCollapsed(false);

		if( invalidated )
			refresh();

		resume();
		onResize();
	}


	function hide() {
		root.detach();
		root.visible = false;
		bg.visible = false;
		isOpen = false;

		pause();
	}


	function isMoving() return cd.has("moving");

	function updateCoords() {
		if( isOpen ) {
			var s = wrapper.scaleX;
			if( collapsed ) {
				tw.create(ctrap.x, getCollapsedX(), 300).onUpdate = ui.HudMenu.CURRENT.updateCoords;
				tw.create(wrapper.x, getCollapsedX(), 200);
				cd.set("moving", Const.ms(200));
			}
			else {
				tw.create(wrapper.x, getOpenX(), 200);
				tw.create(ctrap.x, getOpenX(), 300);
				cd.set("moving", Const.ms(200));
			}
		}
		else {
			if( paused )
				wrapper.x = ctrap.x = getClosedX();
			else {
				tw.create(wrapper.x, getClosedX(), 200);
				tw.create(ctrap.x, getClosedX(), 300);
				cd.set("moving", Const.ms(200));
			}
		}
	}

	function getClosedX() return left ? -wid*wrapper.scaleX : w();
	function getCollapsedX() return left ? (-wid+20)*wrapper.scaleX : w()-20*wrapper.scaleX;
	function getOpenX() return left ? 0 : w() - wrapper.scaleX*wid;

	public static function isDragging() {
		for(e in ALL)
			if( e.drag.active )
				return true;
		return false;
	}


	public static function allClosed() {
		for(e in ALL)
			if(e.isOpen)
				return false;
		return true;
	}


	public function onBack() {
		close();
	}


	public static function getOpened() : ui.SideMenu {
		for(e in ALL)
			if(e.isOpen)
				return e;
		return null;
	}

	public static function closeAll() {
		if( Game.ME==null || Game.ME.destroyed || Game.ME.tuto.commandLocked("side") )
			return false;

		var found = false;
		for(e in ALL)
			if( !e.destroyed && e.isOpen ) {
				found = true;
				e.toggle();
			}
		return found;
	}

	function onWheel(e:hxd.Event) {
		drag.dy += -e.wheelDelta*12;
	}

	function onPush(_) {
		var m = g.getMouse();
		drag.x = m.ux;
		drag.y = m.uy;
		drag.clicking = true;
		drag.active = false;
		drag.vertical = false;
		drag.value = null;
		drag.time = ftime;
	}

	function onRelease(_) {
		if( destroyed )
			return;

		// Release drag
		var m = g.getMouse();
		if( drag.active && !drag.vertical && canDrag(drag.value) && m.ux<wrapper.x )
			onDragOnScene(drag.value, m.rx, m.ry, g.hotelRender.getRoomAt(m.rx, m.ry));

		clearCursor();
		drag.clicking = false;
		drag.active = false;
		drag.value = null;

		setCollapsed(false);

		onStopDrag();
	}

	function removeButton(value:Dynamic) { // TODO remplacer par des remplacements à la volée du ui.Button
		var i = 0;
		while( i<buttons.length )
			if( buttons[i].value==value ) {
				buttons[i].destroy();
				buttons.splice(i,1);
				return i;
			}
			else
				i++;

		return -1;
	}

	function createButton(?cb:Null<Void->Void>, ?value:Dynamic) {
		return new ui.side.Button(this, cb, value);
	}

	function addSeparator() {
		var b = createButton();
		b.disableRollover();

		var line = b.addElement("sep"+buttons.length, "popUpBottom");
		line.alpha = 0.5;
		line.width = wid;
		line.height = 2;
		line.y = bhei*0.5;

		b.position();
	}

	function addTitle(str:LocaleString, ?col:Null<Int>) {
		var id = str.substr(0,10);
		var b = createButton();
		b.disableRollover();

		var tf = b.addTextHuge("title"+id, str, 32);
		tf.textColor = col==null ? Const.TEXT_GOLD : col;
		tf.x = 20;
		tf.maxWidth = (wid-tf.x*2) / tf.scaleX;
		tf.y = Std.int( bhei - tf.textHeight*tf.scaleY - 10 );

		var line = b.addElement("line"+id, "popUpBottom");
		line.width = wid;
		line.y = bhei - 7;

		b.position();
	}

	function addText(str:LocaleString, ?col:Null<Int>) {
		var b = createButton();
		b.disableRollover();

		var tf = b.addText("text"+str, str, 20);
		tf.textColor = col==null ? Const.TEXT_GRAY : col;
		tf.x = 20;
		tf.maxWidth = (wid-tf.x*2) / tf.scaleX;
		tf.y = Std.int( bhei*0.5 - tf.textHeight*tf.scaleY*0.5 );

		b.position();
	}

	override function onResize() {
		super.onResize();

		if( wrapper!=null ) {
			var widCm = wcm()>=10 ? 6 : 4;
			wrapper.setScale( Main.getScale(wid, widCm) );

			ctrap.width = wid*wrapper.scaleX;
			ctrap.height = h();

			bg.width = wid*wrapper.scaleX * (left?-1:1);
			bg.height = h();

			updateCoords();
		}
	}


	function getButton(val:Dynamic) : ui.side.Button {
		for(b in buttons)
			if( b.value==val )
				return b;
		return null;
	}

	function getButtonEnum(val:EnumValue) : ui.side.Button {
		for(b in buttons)
			if( val.equals(b.value) )
				return b;
		return null;
	}

	public function getButtonCenter(val:Dynamic, ?center=false) {
		var b = switch( Type.typeof(val) ) {
			case TEnum(_) : getButtonEnum(val);
			default : getButton(val);
		}
		if( b!=null )
			return {
				x	: wrapper.x + (b.getX() + (center?wid*0.5:left?wid-60:60))*wrapper.scaleX,
				y	: wrapper.y + (b.getY() + bhei*0.5)*wrapper.scaleY,
			}
		else
			return { x:0, y:0 };
	}

	public function focus(v:Dynamic) {
		var e = getButton(v);
		if( e!=null ) {
			var pt = getButtonCenter(v);
			tw.create(wrapper.y, h()*0.5 - pt.y + wrapper.y, 800);
		}
	}


	function clearContent() {
		for(e in buttons)
			e.destroy();
		buttons = [];

		sb.removeAllElements();
		sb.disposeAllChildren();

		tsb.removeAllElements();
		tsb.disposeAllChildren();

		utsb.removeAllElements();
		utsb.disposeAllChildren();
	}


	override function onDispose() {
		super.onDispose();

		onCursorDisposal();

		ctrap.dispose();
		ctrap = null;

		bg.dispose();
		bg = null;

		sb.dispose();
		sb = null;

		tsb.dispose();
		tsb = null;

		utsb.dispose();
		utsb = null;

		wrapper.dispose();
		wrapper = null;

		for(b in buttons)
			b.destroy();
		buttons = null;

		drag = null;
		cursor = null;

		ALL.remove(this);
	}

	dynamic function onCursorDisposal() {}

	function clearCursor() {
		cursor.disposeAllChildren();
		cursor.visible = false;
		onCursorDisposal();
		onCursorDisposal = function() {}
	}

	function canDrag(value:Dynamic) {
		return true;
	}

	function onStartDrag(value:Dynamic) {
		clearCursor();
		cd.set("dragCancel", 20);
		setCollapsed(true);
		g.followCursor = true;

		Game.ME.unselect();
		Game.ME.viewport.forceZoomOut();
		Assets.SBANK.drag(0.5);
	}

	function onStopDrag() {
		g.clearHudLayer();
		g.followCursor = false;
		Game.ME.viewport.resetForcedZoom();
	}

	function onDragOnScene(value:Dynamic, cx:Int, cy:Int, ?r:b.Room) {
	}

	public static function getCurrentWidth() {
		var max : Float = 0;
		for( e in ALL )
			if( !e.left )
				max = MLib.fmax(max, e.w()-e.ctrap.x);

		return max + (max!=0 ? 10 : 0);
	}

	override function update() {
		super.update();

		if( isOpen ) {
			var m = g.getMouse();
			if( drag.clicking ) {
				drag.dy*=0.6;
				var d = mt.Metrics.cm2px(0.4);
				if( !drag.active && Lib.distanceSqr(m.ux, m.uy, drag.x, drag.y)>=d*d ) {
					drag.active = true;
					var a = Math.atan2( m.uy-drag.y, m.ux-drag.x );
					drag.vertical = drag.value==null || a>=-1.57-0.65 && a<1.57+0.65;
					if( !drag.vertical && canDrag(drag.value) && drag.value!=null )
						onStartDrag(drag.value);
				}

				// Long press
				if( !drag.active && ftime-drag.time>=10 && drag.value!=null && canDrag(drag.value) ) {
					drag.active = true;
					onStartDrag(drag.value);
				}

				if( drag.active && drag.vertical ) {
					drag.dy+= (m.uy - drag.y)*0.7;
					drag.y = m.uy;
					if( m.ux<wrapper.x && drag.value!=null && canDrag(drag.value) ) {
						onStartDrag( drag.value );
						drag.vertical = false;
					}
				}
			}

			cursor.visible = drag.active && !drag.vertical;
			if( cursor.visible ) {
				cursor.scale( Main.getScale(cursor.width,1.4) );
				var r = Game.ME.hotelRender.getRoomAt(m.rx, m.ry);
				if( r!=null && Game.ME.validRooms.exists(r.rx+","+r.ry) )
					Game.ME.fx.roomOvered(r);

				cursor.setPos( m.ux, m.uy );
			}

			//var wh = wrapper.height; // h2d.Interactive height bug
			var wh = buttons.length*bhei * wrapper.scaleY;
			wrapper.y+=drag.dy;
			drag.dy*=0.8;
			if( MLib.fabs(drag.dy)<=0.05 )
				drag.dy = 0;

			// Top limit
			var y = h() * (Game.ME.tuto.isRunning() ? 0.4 : topLimitRatio);
			if( wrapper.y>y )
				wrapper.y += (y-wrapper.y) * 0.4;

			// Bottom limit
			var y = h()*0.8-wh;
			if( wrapper.y<y )
				wrapper.y += (y-wrapper.y) * 0.4;

			wrapper.y = Std.int(wrapper.y);

			// Buttons
			for(b in buttons)
				b.update();
		}

		bg.x = wrapper.x + (left?wid*wrapper.scaleX:0);
	}
}