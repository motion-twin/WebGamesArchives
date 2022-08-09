import Common;
import mt.deepnight.Tweenie;

import flash.text.TextField;

typedef ChatLine = { tf:TextField, life:Int }

@:bitmap("gfx/digger.png") class DiggerBmp extends flash.display.BitmapData { }
@:bitmap("gfx/icons.png") class IconsBmp extends flash.display.BitmapData {}

class Interface extends InterfInvent {

	public static inline var CBITS = 4;
	public static inline var TEXT_COLOR = 0xE0E0E0;
	
	static var _icons : mt.deepnight.SpriteLib;
	public static function getIcons() {
		if( _icons != null )
			return _icons;
		var icons : mt.deepnight.SpriteLib;
		icons = new mt.deepnight.SpriteLib( new IconsBmp(0,0) );
		icons.setCenter(0,0);
		icons.setUnit(16,16);
		icons.sliceUnit("charge", 0,0, 4);
		icons.sliceUnit("status_unknown", 0,2);
		icons.sliceUnit("status_power", 1, 2);
		_icons = icons;
		return icons;
	}
	
	var game : Game;
	var msgMC : {> flash.display.MovieClip, tf : flash.text.TextField };
	var errorMC : { > flash.display.MovieClip, tf : flash.text.TextField };
	var jetpackMC : flash.display.Sprite;
	var lifeMC : flash.display.Sprite;
	var oxygenMC : flash.display.Sprite;
	var ui : flash.display.Sprite;
	var lockMC : flash.display.Sprite;
	var cross : flash.display.Sprite;
	
	var curMessage : String;
	public var warnText : flash.text.TextField;
	public var hasFocus : Bool;
	public var hud : flash.display.Sprite;
	public var warnMC : flash.display.Sprite;
	public var warnAnim : Bool;
	
	var statuses : Hash<Bool>;
	public var statusMC : flash.display.Sprite;
	
	public var chatRoot : flash.display.MovieClip;
	public var chatList : Array<ChatLine>;
	
	public static inline var CHAT_FROM_BOTTOM = 48;
	public static inline var CHAT_WIDTH = 256;
	
	public var debugLog : TextField;
	
	public function new(g, infos, hud) {
		game = g;
		super(infos, new flash.display.Sprite(), game.tw);
		
		ui = new flash.display.Sprite();
		ui.addChild(invMC);
		
		statuses = new Hash();
		oxygenMC = new flash.display.Sprite();
		oxygenMC.filters = [ new flash.filters.GlowFilter(0x2C66D3, 0.8, 8,8, 1) ];
		
		statusMC = new flash.display.Sprite();
		statusMC.x = 5;
		statusMC.y = 5;

		lifeMC = new flash.display.Sprite();
		lifeMC.filters = [ new flash.filters.GlowFilter(0xA6FF00, 0.8, 8,8, 1) ];
		lifeMC.alpha = 0.8;
		
		jetpackMC = new flash.display.Sprite();
		jetpackMC.alpha = 0.9;
		
		cross = new flash.display.Sprite();
		cross.graphics.lineStyle(1,0x00FFFF, 1, true);
		var s = 7;
		cross.graphics.moveTo(0,-s); cross.graphics.lineTo(0,s);
		cross.graphics.moveTo(-s,0); cross.graphics.lineTo(s,0);
		cross.alpha = 0.4;
		setCross(false);
		ui.addChild(cross);
		
		this.hud = hud;
		
		game.root.addChild(hud);
		game.root.addChild(ui);
		game.root.tabChildren = false;
		game.root.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, function(_) hasFocus = true);
		game.root.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, function(e:flash.events.KeyboardEvent) { hasFocus = true; if( e.keyCode == flash.ui.Keyboard.F2 ) takeScreen(); });
		game.root.stage.addEventListener(flash.events.Event.ACTIVATE, function(_) hasFocus = true);
		game.root.stage.addEventListener(flash.events.Event.DEACTIVATE, function(_) hasFocus = false);
		game.root.stage.addEventListener(flash.events.MouseEvent.MOUSE_WHEEL, function(e:flash.events.MouseEvent) scrollInventory(e.delta));
		captureJSMouseWheel("client", function(delta) return game.mouseOut || game.lock || !hasFocus);
		
		warnText = newTextField(14);
		//warnText.mouseEnabled = false;
		//var fmt = warnText.defaultTextFormat;
		//fmt.font = "MainFont";
		//fmt.size = 14;
		//warnText.defaultTextFormat = fmt;
		
		warnMC = new flash.display.Sprite();
		warnMC.addChild(warnText);
		warnMC.visible = false;
		
		ui.addChild(warnMC);
		ui.addChild(lifeMC);
		ui.addChild(jetpackMC);
		ui.addChild(oxygenMC);
		ui.addChild(statusMC);
		
		chatRoot = new flash.display.MovieClip();
		chatRoot.x = 8;
		chatRoot.y = 200;
		
		chatList = [];
		ui.addChild( chatRoot );
		
		#if debug
		addChatEntry("[DEBUG] opening chat");
		#end
		recalChat();
		
		debugLog = newTextField(8);
		debugLog.multiline = debugLog.wordWrap = true;
		debugLog.width = 320;
		debugLog.height = 2000;
		debugLog.visible = #if debug true #else false #end;
		debugLog.textColor = 0x808080;
		ui.addChild(debugLog);
		Log.add = function(msg:Dynamic, ?pos:haxe.PosInfos) {
			if( debugLog.stage != null ) {
				var prefix = pos == null ? "" : pos.fileName + "(" + pos.lineNumber + ") : ";
				debugLog.appendText("[" + Date.now().toString().substr(11) + "] " + prefix + msg + "\n");
				updateDebugLog();
			} else
				haxe.Log.trace(msg, pos);
		};
		if( game.infos.debug )
			Log.debug = Log.add;
	}
	
	public inline function H()
		return game.engine.height
		
	public inline function W()
		return game.engine.width
		
	function updateDebugLog() {
		while( debugLog.textHeight > H() ) {
			var lines = debugLog.text.split("\n");
			if( lines.length == 0 ) break;
			lines.shift();
			debugLog.text = lines.join("\n");
		}
		debugLog.y = H() - 30 - debugLog.textHeight;
	}
	
	public function addChatEntry(s:String, fade = true, color = 0xFFFFFF )
	{
		var tf = newTextField(8);
		tf.textColor = color;
		tf.wordWrap  = tf.multiline = true;
		tf.width = CHAT_WIDTH - 8;
		tf.height = 100;
		
		var l = 180;
		if( !fade ) l = 0x7FffFFff;
		var t : ChatLine = { tf: tf, life:l };
		
		t.tf.text = s;
		chatList.unshift( t );
		chatRoot.addChild( t.tf );
		
		chatRoot.addEventListener( flash.events.MouseEvent.MOUSE_OVER, function(e)
		{
			for ( c in chatList)
			{
				c.life = 180;
				c.tf.alpha = 1;
			}
		});
		t.tf.height = t.tf.textHeight + 5;
		recalChat();
	}
	
	public function recalChat()
	{
		var cy = 0.0;
		
		//for ( i in 0...chatList.length )
		for ( i in 0...chatList.length)
		{
			var j = chatList.length - i - 1;
			var c = chatList[j];
			
			c.tf.x = 8;
			c.tf.y = cy;
			
			//cy += c.tf.height;
			//cy += 20;
			cy += c.tf.height;
		}
		chatRoot.y = game.engine.height - CHAT_FROM_BOTTOM - 24 - chatRoot.height;
	}
	
	var curInput : flash.text.TextField;
	public function chatInput( cbk )
	{
		if ( curInput != null)
		{
			flash.Lib.current.stage.focus = curInput;
			return;
		}
		var tf = new flash.text.TextField();
		
		tf.type = flash.text.TextFieldType.INPUT;
		tf.x = 8;
		tf.y = game.engine.height - 32;
		tf.height = 20;
		tf.width = 256;
		tf.border = true;
		tf.background = true;
		tf.textColor = 0x000;
		tf.borderColor = 0x7F7F7F;
		tf.backgroundColor = 0xFFFFFF;
		tf.alpha = 0.75;
		
		var onKeyProc = null;
		onKeyProc = function(e : flash.events.KeyboardEvent )
		{
			if ( e.keyCode == flash.ui.Keyboard.ENTER )
			{
				tf.type = flash.text.TextFieldType.DYNAMIC;
				if( flash.Lib.current.stage.focus == tf)
					flash.Lib.current.stage.focus = null;
				cbk( tf.text );
				
				tf.parent.removeChild( tf );
				tf.removeEventListener( flash.events.KeyboardEvent.KEY_DOWN, onKeyProc );
				curInput = null;
			}
		}
		
		ui.addChild( tf );
		focus(tf);
		tf.addEventListener( flash.events.KeyboardEvent.KEY_DOWN, onKeyProc );
		curInput = tf;
		
	}
	
	public function focus ( f ) 		flash.Lib.current.stage.focus = f
	
	public function message( ?txt : String, ?color = 0xB3FF00, ?alpha = 0.8 ) {
		if( txt == curMessage )
			return;
		curMessage = txt;
		if( txt == null ) {
			warnMC.visible = false;
			warnAnim = false;
			return;
		}
		warnAnim = alpha <= 0;
		if( alpha > 0 )
			warnMC.alpha = alpha;
		warnMC.scaleX = 1;
		warnText.text = txt;
		warnText.textColor = color;
		warnText.height = warnText.textHeight+5;
		//warnText.filters = [new flash.filters.GlowFilter((color >> 2) & 0x3F3F3F, 1, 2, 2, 10)];
		//var c =
		warnMC.alpha = 0;
		game.tw.create(warnMC, "alpha", 1, TEaseOut, 600);
		//warnMC.scaleX = 0;
		//game.tw.create(warnMC, "scaleX", 1, TEaseOut, 2000);
		warnText.filters = [
			new flash.filters.GlowFilter(mt.deepnight.Color.capBrightnessInt(color, 0.15),1, 2,2,10),
			new flash.filters.GlowFilter(mt.deepnight.Color.capBrightnessInt(color, 0.4), 057, 8,8, 1)
		];
		warnMC.visible = true;
	}
	
	function takeScreen() {
		var bmp = new flash.display.BitmapData(game.engine.width, game.engine.height, false, 0);
		game.render.takeScreenShot(bmp);
		var png = format.png.Tools.build32BE(bmp.width, bmp.height, haxe.io.Bytes.ofData(bmp.getPixels(bmp.rect)));
		var out = new haxe.io.BytesOutput();
		new format.png.Writer(out).write(png);
		new flash.net.FileReference().save(out.getBytes().getData(), "G55-" + Date.now().toString().split(":").join("_") + ".png");
	}

	static function captureJSMouseWheel( objName : String, callb : Int -> Bool ) {
		try {
			flash.external.ExternalInterface.addCallback("onWheel",#if !flash9 null,#end callb);
			flash.external.ExternalInterface.call("function() {
				var fla = window.document['"+objName+"'];
				if( fla == null ) return false;
				var wheel = function(e) {
					if( e == null ) e = window.event;
					if( fla.onWheel(e.wheelDelta == null ? -e.detail : e.wheelDelta) ) return true;
					if( e.preventDefault ) e.preventDefault();
					e.returnValue = false;
					return false;
				};
				if( window.addEventListener ) window.addEventListener('DOMMouseScroll', wheel, false);
				window.onmousewheel = document.onmousewheel = wheel;
			}".split("\r\n").join("").split("\n").join(""));
		} catch( e : Dynamic ) {
		}
	}
	
	public function resize(w, h) {
		updateLife(1);
		updateOxygen(1);

		debugLog.x = w - 330;
		if( debugLog.x < 5 ) debugLog.x = 5;
		updateDebugLog();
		
		lifeMC.x = Std.int(w*0.5 - 175);
		lifeMC.y = h-20;
		
		jetpackMC.x = Std.int(w*0.5 - 175);
		jetpackMC.y = h-25;
		
		oxygenMC.x = Std.int(w*0.5 - 175);
		oxygenMC.y = h-35;
		
		cross.x = Std.int(w*0.5);
		cross.y = Std.int(h * 0.5);
		
		warnText.width = w * 0.85;
		warnText.height = h * 0.55;
		
		invMC.x = (w - invContent.length*44)>>1;
		invMC.y = 5;
		
		if(curInput!=null)curInput.y = game.engine.height - 32;
		
		recalChat();
	}
	
	public function setCross(b) {
		cross.visible = b;
	}

	public function lockButtons(flag) {
		if( flag ) {
			if( lockMC != null ) return;
			lockMC = new flash.display.Sprite();
			lockMC.graphics.beginFill(0,0);
			lockMC.graphics.drawRect(0,0,game.root.stage.stageWidth,game.root.stage.stageHeight);
			game.root.addChild(lockMC);
		} else {
			if( lockMC == null ) return;
			game.root.removeChild(lockMC);
			lockMC = null;
		}
	}

	inline function attach(name) {
		return flash.Lib.attach(untyped __unprotect__(name));
	}
	
	public function setStatus(k:String, b:Bool) {
		if( b )
			statuses.set(k, true);
		else
			statuses.remove(k);
			
		while( statusMC.numChildren>0 )
			statusMC.removeChildAt(0);

		var i = 0;
		var icons = getIcons();
		for( k in statuses.keys() ) {
			var s = icons.exists("status_"+k) ? icons.getSprite("status_"+k) : icons.getSprite("status_unknown");
			statusMC.addChild(s);
			s.blendMode = flash.display.BlendMode.ADD;
			s.scaleX = s.scaleY = 2;
			s.y = s.scaleY*16*i;
			s.filters = [
				new flash.filters.GlowFilter(0x04E9FB,0.8, 16,16, 2, 2),
			];
			i++;
		}
	}
	
	public override function display() {
		clean();
		var mc = new flash.display.Sprite();
		drawInvBase(mc);
		var bmp = new flash.display.Bitmap( new DiggerBmp(0,0) );
		bmp.x = Std.int( 20 - bmp.width*0.5 );
		bmp.y = Std.int( 20 - bmp.height*0.5 );
		mc.addChild(bmp);
		invMC.addChild(mc);
		invContent.push({
			mc : mc,
			count : null,
			block : null,
			index : -1,
		});
		super.display();
	}
	
	public static function newTextField(size:Int) {
		var tf = new flash.text.TextField();
		
		var fmt = tf.defaultTextFormat;
		fmt.font = "default";
		fmt.size = size;
		fmt.color = TEXT_COLOR;
		tf.defaultTextFormat = fmt;
		tf.embedFonts = true;
		tf.sharpness = 400;
		tf.multiline = tf.wordWrap = false;
		tf.mouseEnabled = tf.selectable = false;
		tf.width = 150;
		tf.height = 25;
		tf.filters = [ new flash.filters.GlowFilter(0x0, 1, 2, 2, 10) ];
		return tf;
	}

	public function updateShake(f:Float) {
		if( f<=0 )
			ui.y = 0;
		else
			ui.y = Math.random() * 10 * f * (Std.random(2)*2-1);
	}

	public function updateOxygen( ratio : Float ) {
		oxygenMC.visible = ratio<1;
			
		if( oxygenMC.visible ) {
			var g = oxygenMC.graphics;
			g.clear();
			if( ratio <= 0 ) ratio = 0;
			if( ratio >= 1 ) ratio = 1;
			g.beginFill(0x0, 0.3);
			g.drawRect(0,0, 350,10);
			g.beginFill(0x4AA5FF, 1);
			g.drawRect(0,0, ratio*350,10);
		}
	}
	
	public function updateLife( ratio : Float ) {
		lifeMC.visible = ratio<1;
			
		var g = lifeMC.graphics;
		g.clear();
		if( ratio <= 0 ) ratio = 0;
		if( ratio >= 1 ) ratio = 1;
		g.beginFill(0x0, 0.3);
		g.drawRect(0,0, 350,5);
		g.beginFill(0xA3F50A, 1);
		g.drawRect(0,0, ratio*350,5);
	}
	
	public function updateJetpack( ratio:Float ) { // 0-1
		jetpackMC.visible = ratio>0;
		
		var g = jetpackMC.graphics;
		g.clear();
		if( ratio <= 0 ) ratio = 0;
		if( ratio >= 1 ) ratio = 1;
		g.beginFill(0x0, 0.3);
		g.drawRect(0,0, 350,4);
		var col  = if(ratio>=0.8) 0xFD5C17 else if(ratio>=0.6) 0xFFA428 else 0xFFD900;
		g.beginFill(col, 1);
		g.drawRect(0,0, ratio*350,4);
	}

	public function update()
	{
		if ( curInput != null )
			focus(curInput);
			
		var i = 0;
		for ( c in chatList.copy())
		{
			c.life--;
			if ( c.life <= 0 )
			{
				c.tf.alpha -= 0.1;
				c.tf.alpha = Math.max( -0.001, c.tf.alpha );
			}
			
			if ( c.tf.alpha <= 0 && i > 100)
				chatList.remove( c );
				
			i++;
		}
		
	}
	
	public function showInventory( b : Bool ) {
		ui.visible = b;
	}

	public function showDeadZone(r:Null<Float>) {
		var g = ui.graphics;
		if( r==null ) {
			g.clear();
			return;
		}
		var w = game.root.stage.stageWidth;
		var h = game.root.stage.stageHeight;
		var d =
		g.clear();
		g.lineStyle(1, 0x72F1E1, 0.3, true);
		var bh = 20;
		g.moveTo(w*0.5 - w*r*0.5, h*0.5-bh);
		g.lineTo(w*0.5 - w*r*0.5, h*0.5+bh);
		g.moveTo(w*0.5 + w*r*0.5, h*0.5-bh);
		g.lineTo(w*0.5 + w*r*0.5, h*0.5+bh);
	}

	public function logError( e : Dynamic ) {
		var str;
		try str = Std.string(e) catch( e : Dynamic ) str = "???";
		game.lock = true;
		if( errorMC == null ) {
			errorMC = cast attach("error");
			errorMC.buttonMode = true;
			errorMC.tf.text = "";
			errorMC.tf.mouseEnabled = false;
			errorMC.addEventListener(flash.events.MouseEvent.CLICK,function(_) {
				flash.Lib.getURL(new flash.net.URLRequest("/"),"_self");
			});
			game.root.addChild(errorMC);
		}
		errorMC.tf.appendText("["+Date.now().toString()+"] "+str+"\n");
	}
		
}