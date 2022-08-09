package mt.deepnight.deprecated;

using mt.deepnight.deprecated.SuperMovie;

import flash.ui.Keyboard;

enum InterfaceContainer {
	ITop;
	ILeft;
	IRight;
	IBottom;
	ICustomHorizontal(x:Int,y:Int);
	ICustomVertical(x:Int,y:Int);
}

@:debug class Interface {
	public static var TAB_INDEX = 100;
	public static var COLOR = 0x4F5E8E;
	public static var BT_WID = 120;
	public static var BT_HEI = 16;
	public static var MASK_ALPHA = 0.65;
	public static var CANCEL_NOTICE_KEY : Null<Int> = null; // si null, toutes les touches ferment les pop-ups
	//public static var NOTIFY_FILTERS = [
	//];
	//public static var BT_FILTERS = [
	//];
	//public static var INPUT_FILTERS = [
	//];
	public static var MARGIN = 1;
	public static var NOTIFY_FORMAT = {
		var tf = new flash.text.TextFormat();
		tf.font = "Arial";
		tf.size = 12;
		tf;
	}
	
	public var defColor		: Int;
	public var defWid		: Int;
	public var defHei		: Int;
	public var btFilters	: Array<flash.filters.BitmapFilter>;
	public var inputFilters	: Array<flash.filters.BitmapFilter>;
	public var notifyFilters: Array<flash.filters.BitmapFilter>;
	public var textFormat	: flash.text.TextFormat;
	
	public var root		: flash.display.Sprite;
	var all				: List<flash.display.DisplayObjectContainer>;
	var width			: Int;
	var height			: Int;
	var containers		: Hash<List<flash.display.DisplayObjectContainer>>;
	var shortcuts		: IntHash<{cb:Void->Void, skey:Null<Int>}>;
	var notices			: List<{mc:flash.display.Sprite,cb:Void->Void}>;
	var fl_canCancelNotice	: Bool;
	var fl_lockShortcuts	: Bool;
	var lastContainer		: InterfaceContainer;
	var events				: List<{ obj:flash.display.DisplayObject, cb:Dynamic->Void, e:String}>;
	var internalEvents		: List<{ obj:flash.display.DisplayObject, cb:Dynamic->Void, e:String}>;
	
	public var autoButtonWidth	: Bool;
	
	public function new(root:flash.display.Sprite, w, h) {
		defColor = COLOR;
		defWid = BT_WID;
		defHei = BT_HEI;
		btFilters = cast [
			new flash.filters.GlowFilter(0xffffff,0.15, 3,3, 10,1, true) ,
			new flash.filters.DropShadowFilter(1, 90, 0xffffff, 0.4, 1, 1,10,1, true ),
			new flash.filters.GlowFilter(0x0, 1, 3, 3, 2) ,
			new flash.filters.DropShadowFilter(3,90,0x0,0.2,0,0,3) ,
		];
		inputFilters = cast [
			new flash.filters.DropShadowFilter(2,90,0x0,0.2,4,4, 3, 1,true) ,
			new flash.filters.GlowFilter(0x0,1, 4,4, 1, 1,true) ,
			new flash.filters.GlowFilter(0xffffff,1, 2,2, 10, 1,true) ,
			new flash.filters.GlowFilter(0x0, 1, 3, 3, 2) ,
			new flash.filters.DropShadowFilter(3,90,0x0,0.2,0,0,3) ,
		];
		notifyFilters = cast [
			new flash.filters.DropShadowFilter(1, 90, 0xffffff, 0.3, 1, 1,10,1, true ),
			new flash.filters.GlowFilter(0x0, 1, 3, 3, 2) ,
			new flash.filters.DropShadowFilter(5,90,0x0,0.2,4,4, 1) ,
		];
		textFormat = new flash.text.TextFormat();
		textFormat.font = "Arial";
		textFormat.size = 10;
		
		this.root = root;
		lastContainer = ITop;
		width = w;
		height = h;
		autoButtonWidth = false;
		containers = new Hash();
		notices = new List();
		fl_canCancelNotice = false;
		fl_lockShortcuts = false;
		var me = this;
		shortcuts = new IntHash();
		events = new List();
		internalEvents = new List();
		all = new List();
		
		mt.flash.Key.init();
		addRemovableEvent( root.stage, flash.events.KeyboardEvent.KEY_DOWN, function(e:flash.events.KeyboardEvent) { me.onKey(e.keyCode); }, true );
		addRemovableEvent( root.stage, flash.events.KeyboardEvent.KEY_UP, function(e:flash.events.KeyboardEvent) { me.onKeyUp(e.keyCode); }, true );
		reset();
	}
	
	public function reset() {
		removeAll();
		
		containers = new Hash();
		for (k in Type.getEnumConstructs(InterfaceContainer))
			containers.set(k, new List());
	}
	
	public function removeAll() {
		for (e in events)
			e.obj.removeEventListener(e.e, e.cb);
		events = new List();

		for (mc in all)
			mc.parent.removeChild(mc);
		all = new List();
		shortcuts = new IntHash();

		for( k in containers.keys() )
			containers.set(k, new List());
	}
	
	public function destroy() {
		reset();
		for (e in internalEvents)
			e.obj.removeEventListener(e.e, e.cb);
		internalEvents = new List();
		root.parent.removeChild(root);
	}
	
	public function setContainer(c:InterfaceContainer) {
		lastContainer = c;
	}
	
	public function createHorizontalContainer(x:Int, y:Int) {
		var c = ICustomHorizontal(x,y);
		containers.set(Std.string(c), new List());
		return c;
	}
	public function createVerticalContainer(x:Int, y:Int) {
		var c = ICustomVertical(x,y);
		containers.set(Std.string(c), new List());
		return c;
	}
	
	function createField() {
		var tf = new flash.text.TextField();
		tf.defaultTextFormat = textFormat;
		tf.textColor = 0xFFFFFF;
		tf.embedFonts = textFormat.font!="Arial";
		tf.mouseEnabled = false;
		tf.mouseWheelEnabled = false;
		tf.setTextFormat(textFormat);
		return tf;
	}
	
	public function getMcByName(n:String) {
		for (mc in all)
			if (mc.name==n)
				return mc;
		throw "getMcByName : "+n;
	}
	
	function onKey(keyCode:Int) {
		if (fl_lockShortcuts)
			return;
		for (c in shortcuts.keys())
			if (c==keyCode) {
				var s = shortcuts.get(c);
				if(s.skey==null || s.skey!=null && mt.flash.Key.isDown(s.skey))
					s.cb();
			}
		if (root.stage.focus==null || root.stage.focus.parent==null)
			root.stage.focus = root.stage;
	}
	
	function onKeyUp(keyCode:Int) {
		if (notices.length>0 && fl_canCancelNotice && (CANCEL_NOTICE_KEY==null || keyCode==CANCEL_NOTICE_KEY) )
			clearNotice(notices.last());
		fl_canCancelNotice = true;
	}
	
	function placeMc(mc:flash.display.DisplayObjectContainer, cont:InterfaceContainer) {
		var list = containers.get(Std.string(cont));
		var sumWid = 0.0;
		var sumHei = 0.0;
		for (mc in list) {
			sumWid+=mc.width+MARGIN;
			sumHei+=mc.height+MARGIN;
		}
		var n = list.length;
		switch(cont) {
			case ILeft :
				mc.x = MARGIN;
				mc.y = MARGIN + sumHei;
				if (containers.get(Std.string(ITop)).length > 0) mc.y+=defHei+MARGIN;
			case IRight :
				mc.x = width - mc.width-MARGIN;
				mc.y = MARGIN + sumHei;
				if (containers.get(Std.string(ITop)).length > 0) mc.y+=defHei+MARGIN;
			case ITop :
				mc.x = MARGIN + sumWid;
				mc.y = MARGIN;
				if (containers.get(Std.string(ILeft)).length > 0) mc.x+=defHei+MARGIN;
			case IBottom :
				mc.x = MARGIN + sumWid;
				mc.y = height - mc.height - MARGIN;
			case ICustomHorizontal(cx,cy):
				mc.x = cx + sumWid;
				mc.y = cy;
			case ICustomVertical(cx,cy) :
				mc.x = cx;
				mc.y = cy + sumHei;
		}
		containers.get(Std.string(cont)).add(mc);
		all.add(mc);
	}
	
	public function addShortcut(key:Int, ?secondKey:Null<Int>, cb:Void->Void) {
		shortcuts.set(key, {cb:cb, skey:secondKey});
	}
	
	public function addSpacer(?wid=10) {
		var mc = new flash.display.Sprite();
		root.addChild(mc);
		var g = mc.graphics;
		g.beginFill(0x0, 0);
		g.drawRect(0,0,wid,defHei);
		g.endFill();
		placeMc(mc, lastContainer);
	}
	
	public function addButton(label:String, cb:Void-> Void, ?wid:Int, ?locked=false) {
		if (wid==null)
			wid = defWid;
		var mc = new flash.display.Sprite();
		root.addChild(mc);
		mc.buttonMode = mc.useHandCursor = true;
		mc.filters = btFilters;
		mc.tabIndex = TAB_INDEX++;

		var bg = new flash.display.Sprite();
		mc.addChild(bg);
		var g = bg.graphics;
		g.beginFill(defColor, 1);
		g.drawRect(0, 0, wid, defHei);
		g.endFill();

		if (locked)
			mc.alpha = 0.5;
		else
			mc.onClick( cb );
		mc.onOver( function() { bg.transform.colorTransform = mt.deepnight.Color.getSimpleCT(0xE2B18D, 0.8); } );
		mc.onOut( function() { bg.transform.colorTransform = new flash.geom.ColorTransform(); } );
		
		var tf = createField();
		mc.addChild(tf);
		tf.width = wid;
		tf.height = defHei;
		tf.text = label;
		tf.filters = [ new flash.filters.DropShadowFilter(1,90, 0x0,0.7, 0,0) ];
		
		if (autoButtonWidth) {
			bg.width = tf.textWidth+8;
			tf.width = bg.width;
		}
		placeMc(mc, lastContainer);
		return mc;
	}
		

	public function addInput(label:String, baseValue:Dynamic, cbValidate:String->Void, ?wid:Int, ?fl_readOnly=false) {
		if (wid==null)
			wid = defWid;
		var col = Color.offsetColorInt( defColor, 120 );
		var mc = new flash.display.Sprite();
		root.addChild(mc);
		mc.filters = inputFilters;
		
		var g = mc.graphics;
		g.beginFill(defColor, 1);
		g.drawRect(0,0,wid,defHei);
		g.endFill();

		var ltf = createField();
		mc.addChild(ltf);
		ltf.height = defHei;
		ltf.width = wid;
		ltf.text = label+":";
		ltf.width = ltf.textWidth+5;
		
		var tf = createField();
		mc.addChild(tf);
		tf.x = ltf.textWidth+3;
		tf.width = wid-ltf.width;
		tf.height = defHei;
		tf.type = if(fl_readOnly) flash.text.TextFieldType.DYNAMIC else flash.text.TextFieldType.INPUT;
		tf.text = if (baseValue!=null) baseValue else "";
		tf.textColor = col;
		tf.tabIndex = TAB_INDEX++;
		tf.mouseEnabled = true;
		if(!fl_readOnly) {
			var me = this;
			addRemovableEvent(tf, flash.events.Event.CHANGE, function(e) { tf.filters = [new flash.filters.GlowFilter(0xFFB340,1,16,16,3)];  tf.textColor = 0xFFFF00; } );
			addRemovableEvent(tf, flash.events.KeyboardEvent.KEY_DOWN, function(e) { tf.filters = []; tf.textColor = col; if (e.keyCode==Keyboard.ENTER || e.keyCode==Keyboard.TAB) { me.onFocusOut(tf, null); cbValidate(tf.text); } } );
			addRemovableEvent(tf, flash.events.FocusEvent.FOCUS_IN, callback(onFocusIn,tf) );
			addRemovableEvent(tf, flash.events.FocusEvent.FOCUS_OUT, callback(onFocusOut,tf) );
		}
		var f = tf.getTextFormat();
		f.align = flash.text.TextFormatAlign.LEFT;
		tf.setTextFormat(f);
		
		if (fl_readOnly) {
			mc.alpha = 0.5;
			tf.mouseEnabled = false;
		}
		
		placeMc(mc,lastContainer);
		return tf;
	}
	
	function onFocusIn(tf:flash.text.TextField, e) {
		fl_lockShortcuts = true;
	}
	function onFocusOut(tf:flash.text.TextField, e) {
		fl_lockShortcuts = false;
	}
	
	function drawCheck(g:flash.display.Graphics, x,y, b:Bool) {
		g.clear();
		g.beginFill(0x0,1);
		g.lineStyle(1,0xffffff,0.5,true);
		g.drawRect(x,y,defHei-6,defHei-6);
		g.endFill();
		if (b) {
			g.lineStyle(2, 0xffffff,1,true);
			g.moveTo(x+3,y+3);
			g.lineTo(x+defHei-8,y+defHei-8);
			g.moveTo(x+defHei-8,y+3);
			g.lineTo(x+3,y+defHei-8);
		}
	}
	
	public function addCheckBox(label:String, baseValue:Bool, cbChange:Bool->Void, ?wid:Int) {
		if (wid==null)
			wid = defWid;
		var mc = new flash.display.Sprite();
		root.addChild(mc);
		mc.handCursor(true);
		mc.filters = btFilters;
		mc.tabIndex = TAB_INDEX++;
		
		var bg = new flash.display.Sprite();
		mc.addChild(bg);
		var g = bg.graphics;
		g.beginFill(defColor, 1);
		g.drawRect(0,0,wid,defHei);
		g.endFill();
		
		var box = new flash.display.Sprite();
		mc.addChild(box);
		drawCheck(box.graphics, 3,3, baseValue);
		
		var tf = createField();
		mc.addChild(tf);
		tf.x = 4 + box.width;
		tf.width = wid-4-box.width;
		tf.height = defHei;
		tf.text = label;
		tf.textColor = 0xffffff;

		mc.onOver( function() { bg.transform.colorTransform = mt.deepnight.Color.getSimpleCT(0xE2B18D, 0.8); } );
		mc.onOut( function() { bg.transform.colorTransform = new flash.geom.ColorTransform(); } );
		var me = this;
		mc.onClick( function() {
			baseValue = !baseValue;
			me.drawCheck(box.graphics, 3,3, baseValue);
			cbChange(baseValue);
		});
		
		placeMc(mc,lastContainer);
		return mc;
	}
	
	public function notify(msg:String, ?bgColor:Int, ?onClearCb:Void->Void) {
		//fl_canCancelNotice = false;
		var notice = new flash.display.Sprite();
		root.addChild(notice);
		
		var mask = new flash.display.Sprite();
		notice.addChild(mask);
		var g = mask.graphics;
		g.beginFill(0x0,MASK_ALPHA);
		g.drawRect(0,0,width,height);
		g.endFill();
		mask.handCursor(true);
		
		var mc = new flash.display.Sprite();
		notice.addChild(mc);
		
		var tf = new flash.text.TextField();
		mc.addChild(tf);
		tf.multiline = true;
		tf.wordWrap = true;
		tf.x = 4;
		tf.width = width*0.3;
		tf.height = 300;
		tf.text = msg;
		tf.setTextFormat(NOTIFY_FORMAT);
		tf.width = tf.textWidth + 8;
		tf.height = tf.textHeight + 8;
		tf.textColor = 0xffffff;
		tf.mouseEnabled = false;
		
		var g = mc.graphics;
		g.beginFill( if(bgColor==null) defColor else bgColor, 1);
		g.drawRect(0,0, Math.max(200,tf.width+MARGIN*2), tf.height);
		
		mc.x = Std.int(width*0.5 - mc.width*0.5);
		mc.y = Std.int(height*0.5 - mc.height*0.5);
		mc.filters = notifyFilters;
		mc.disableMouse();
		
		var n = { mc:notice, cb:onClearCb };
		mask.onClick( callback(clearNotice,n) );
		notices.add(n);
	}
	
	public function clearNotice(n:{mc:flash.display.Sprite, cb:Void->Void}) {
		if(n.mc!=null && n.mc.parent!=null)
			n.mc.parent.removeChild(n.mc);
		notices.remove(n);
		resetFocus();
		if (n.cb!=null)
			n.cb();
	}
	
	public function watch(parent:Dynamic, varName:String, ?wid:Int) {
		if( Reflect.hasField(parent,varName) )
			return watch_(parent, varName, wid);
		else
			return watch_(parent, untyped __unprotect__(varName), wid); // champ obfusqué
	}
	
	function watch_(p:Dynamic, v:String, ?wid:Int) {
		if (wid==null)
			wid = defWid;
		var mc = new flash.display.Sprite();
		root.addChild(mc);
		mc.filters = inputFilters;

		var bg = new flash.display.Sprite();
		mc.addChild(bg);
		var g = bg.graphics;
		g.beginFill(defColor, 1);
		g.drawRect(0, 0, wid, defHei);
		g.endFill();
		
		var tf = createField();
		mc.addChild(tf);
		tf.multiline = false;
		tf.textColor = 0xffffff;
		tf.height = bg.height+2;
		updateWatch(tf,p,v, null);
		
		addRemovableEvent(mc, flash.events.Event.ENTER_FRAME, callback(updateWatch, tf, p,v));
		placeMc(mc,lastContainer);
	}
	
	function addRemovableEvent(obj:flash.display.DisplayObject, e:String, cb:Dynamic->Void, ?isInternal=false) {
		obj.addEventListener(e, cb);
		var infos = { obj:obj, e:e, cb:cb };
		if (isInternal)
			internalEvents.add(infos);
		else
			events.add(infos);
	}
	
	function updateWatch(tf:flash.text.TextField, p:Dynamic,v:String, event:Dynamic) {
		tf.text = v+"="+Reflect.field(p,v);
		tf.setTextFormat(textFormat);
	}
	
	public function hasNotice() { return notices.length>0; }
	
	public function resetFocus() {
		root.stage.focus = root.stage;
	}
}

