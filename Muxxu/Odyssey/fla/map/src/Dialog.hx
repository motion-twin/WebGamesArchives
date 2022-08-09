import Protocol;
import WorldData.PnjSkin;

class Dialog {

	public var mc : flash.display.Sprite;
	var d : DialogInfos;
	var m : Main;
	var box : DialogBox;
	var inv : SelectBox;
	var cont : Array<{ o : ObjContainer, name : String, id : String }>;
	var objectPos : Int;
	var objectAnimFrame : Int;
	var textPosition : Float;
	var clickLock : Bool;
	var scrollY : Null<Int>;
	var scroll : flash.display.Sprite;

	public function new(m) {
		this.m = m;
		mc = new flash.display.Sprite();
		m.ui.add(mc, 0);
		m.ui.under(mc);
		mc.graphics.beginFill(0, 0.2);
		var s = flash.Lib.current.stage;
		mc.graphics.drawRect(0, 0, s.stageWidth, s.stageHeight);
		mc.addEventListener(flash.events.MouseEvent.MOUSE_UP, onClick);
		mc.buttonMode = true;
	}
	
	function simplify( text : String ) {
		return text.split("œ").join("oe");
	}
	
	public dynamic function onClose() {
		m.command(AReloadActions);
	}
	
	dynamic function onEnd() {
	}
	
	function add( s : flash.display.Sprite ) {
		mc.addChild(s);
		var msk : flash.display.Sprite = Reflect.field(s, "_msk");
		if( msk != null ) {
			var b = msk.getBounds(s);
			s.x = (mc.stage.stageWidth - Std.int(b.width)) >> 1;
			s.y = (mc.stage.stageHeight - Std.int(b.height)) >> 1;
		}
		s.filters = (new UiBoxing()).getChildAt(0).filters;
	}
	
	function noDefClick() {
		mc.removeEventListener(flash.events.MouseEvent.MOUSE_UP, onClick);
		mc.buttonMode = false;
	}
	
	function splitText( t : flash.text.TextField, txt : String ) {
		t.text = txt;
		var curline = 0;
		var out = "";
		for( i in 0...txt.length ) {
			var l = t.getLineIndexOfChar(i);
			if( l != curline ) {
				out += "\n";
				curline = l;
			}
			out += txt.charAt(i);
		}
		t.text = "";
		return out;
	}
	
	public function showPnj( d ) {
		this.d = d;
		textPosition = 0;
		box = new DialogBox();
		for( t in [box._name, box._txt] ) {
			t.selectable = false;
			t.mouseEnabled = false;
		}
		box._name.text = d.name == null ? "" : simplify(d.name);
		for( i in 0...d.texts.length )
			d.texts[i] = splitText(box._txt,simplify(d.texts[i]));
		add(box);
		initSkin(box._pnj,d.id,d.skin);
		var nexts = [];
		var me = this;
		for( f in d.flags )
			switch( f ) {
			case FPassive:
				box._txt.textColor = 0xC0C0C0;
				textPosition = d.texts[0].length - 1;
			case FSell(_), FChooseObject(_):
			case FNext(r): nexts.push(r);
			}
		if( nexts.length > 0 )
			onClose = function() {
				for( r in nexts ) me.m.onResult(r);
				if( m.dialog == null ) m.command(AReloadActions);
			};
	}
	
	function initSell( obj : String, price : Int ) {
		var sell = new SellBox();
		sell._name.text = box._name.text;
		sell._txt.text = box._txt.text;
		for( t in [sell._name, sell._txt, sell._price] ) {
			t.selectable = false;
			t.mouseEnabled = false;
		}
		initSkin(sell._pnj,d.id,d.skin);
		loadIcon(sell._icons, obj);
		add(sell);
		box.parent.removeChild(box);
		sell.x = box.x;
		sell.y = box.y;
		noDefClick();
		sell._cancel.addEventListener(flash.events.MouseEvent.CLICK, onClick);
		var me = this;
		sell._ok.addEventListener(flash.events.MouseEvent.CLICK, function(e) {
			me.onClose = function() me.m.command(AAction(null, obj));
			me.onClick(e);
		});
		sell._price.text = "" + price;
		setButtonText(sell._ok,"buy");
		setButtonText(sell._cancel,"cancel");
	}
	
	function initChooseObject( invItems : Array<{ id : String, name : String, qty : Null<Int> }> ) {
		noDefClick();
		box.parent.removeChild(box);
		inv = new SelectBox();
		cont = [];
		for( i in invItems ) {
			var o = new ObjContainer();
			inv._container.addChild(o);
			loadIcon(o.smc._icons, i.id);
			if( i.qty == null )
				o.smc._txt.visible = false;
			else
				o.smc._txt.text = "x" + i.qty;
			cont.push({ o : o, id : i.id, name : i.name });
		}
		objectPos = invItems.length >> 1;
		objectAnimFrame = 0;
		updateObjects();
		var me = this;
		inv._prev.addEventListener(flash.events.MouseEvent.CLICK,callback(moveObjects, -1));
		inv._next.addEventListener(flash.events.MouseEvent.CLICK,callback(moveObjects, 1));
		setButtonText(inv._ok, "confirm");
		setButtonText(inv._cancel, "cancel");
		inv._ok.addEventListener(flash.events.MouseEvent.CLICK, function(e) {
			me.m.command(AAction(null, me.cont[me.objectPos].id));
			me.cleanup();
		});
		inv._cancel.addEventListener(flash.events.MouseEvent.CLICK, function(_) {
			me.cleanup();
		});
		add(inv);
	}
	
	function moveObjects(d,_) {
		if( objectAnimFrame != 0 )
			return;
		if( objectPos + d < 0 || objectPos + d >= cont.length )
			return;
		objectAnimFrame = d * 10;
		objectPos += d;
	}
	
	function updateObjects() {
		var delta = 5 - objectPos;
		for( o in cont ) {
			o.o.visible = delta >= 0 && delta <= 10;
			o.o.gotoAndStop((delta <= 0 ? 1 : delta * 10) + objectAnimFrame);
			delta++;
		}
		if( objectAnimFrame == 0 )
			inv._txt.text = simplify(cont[objectPos].name);
	}
	
	function setButtonText( s : flash.display.SimpleButton, tid : String ) {
		var text = Main.DATA.texts.get(tid);
		if( text == null ) text = "#" + tid;
		for( st in [s.upState, s.downState, s.overState, s.hitTestState] ) {
			var c = flash.Lib.as(st, flash.display.Sprite);
			if( c == null ) continue;
			for( i in 0...c.numChildren ) {
				var t = flash.Lib.as(c.getChildAt(i), flash.text.TextField);
				if( t != null )
					t.text = text;
			}
		}
	}
	
	public function showMessage(i, t) {
		var me = this;
		var msg = new NotificationBox();
		loadIcon(msg._icons, i);
		msg._txt.htmlText = simplify(t);
		msg._txt.selectable = false;
		msg._txt.mouseEnabled = false;
		add(msg);
	}
	
	public function showQuestion(i,act,t) {
		var me = this;
		var quest = new AnswerBox();
		loadIcon(quest._icons, i);
		quest._txt.htmlText = simplify(t);
		quest._txt.selectable = false;
		quest._txt.mouseEnabled = false;
		add(quest);
		noDefClick();
		setButtonText(quest._ok, "yes");
		setButtonText(quest._cancel, "no");
		var me = this;
		quest._ok.addEventListener(flash.events.MouseEvent.CLICK, function(e) {
			me.onClose = function() me.m.command(AAction(act,"yes"));
			me.onClick(e);
		});
		quest._cancel.addEventListener(flash.events.MouseEvent.CLICK, function(e) {
			me.onClose = function() me.m.command(AAction(act,"no"));
			me.onClick(e);
		});
	}
	
	public function selectHero( text : String, hl : Array<{ id : Int, name : String, frame : String }>, potion : Bool ) {
		noDefClick();
		var hsel = new SelectHeroBox();
		var curHero = hl[0];
		var fok = hsel._hero1.filters;
		var fno = hsel._hero2.filters;
		var clips = [hsel._hero1, hsel._hero2, hsel._hero3];
		var me = this;
		function selectHero(hmc, hinf) {
			curHero = hinf;
			for( h in clips )
				h.filters = (h == hmc) ? fok : fno;
		}
		function action(ok) {
			if( potion ) {
				if( ok )
					me.m.command(AUsePotion(curHero.id));
			} else
				me.m.command(AAction(null, ok ? "h_" + curHero.id : "no"));
			me.cleanup();
		}
		for( h in clips ) {
			var hinf = hl.shift();
			if( hinf == null ) {
				h.visible = false;
				continue;
			}
			loadIcon(h._snap, "hero_" + hinf.frame, true);
			h.buttonMode = true;
			h.addEventListener(flash.events.MouseEvent.MOUSE_UP, function(_) {
				selectHero(h, hinf);
			});
		}
		add(hsel);
		hsel._txt.selectable = false;
		hsel._txt.text = simplify(text);
		setButtonText(hsel._ok, "confirm");
		setButtonText(hsel._cancel, "cancel");
		hsel._ok.addEventListener(flash.events.MouseEvent.CLICK, function(_) action(true));
		hsel._cancel.addEventListener(flash.events.MouseEvent.CLICK, function(_) action(false));
	}
		
	
	function loadIcon( t : flash.display.Sprite, i : String, ?pnj ) {
		// remove previous loader
		var prev = flash.Lib.as(t.parent.getChildAt(t.parent.numChildren - 1), flash.display.Loader);
		if( prev != null )
			prev.parent.removeChild(prev);
		t.visible = false;
		var ic = new flash.display.Loader();
		ic.x = t.x;
		ic.y = t.y;
		t.parent.addChild(ic);
		ic.contentLoaderInfo.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, function(_) t.visible = true);
		ic.contentLoaderInfo.addEventListener(flash.events.IOErrorEvent.IO_ERROR, function(_) t.visible = true);
		ic.contentLoaderInfo.addEventListener(flash.events.IOErrorEvent.NETWORK_ERROR, function(_) t.visible = true);
		var url = "/img/icons/icon_" + i + ".png";
		if( i.substr(0, 5) == "hero_" ) {
			if( pnj )
				url = "/img/heroes/small/" + i.substr(5) + ".png";
			else {
				url = "/img/heroes/medium/" + i.substr(5) + ".png";
				ic.scaleX = ic.scaleY = 44 / 55;
			}
		}
		ic.load(new flash.net.URLRequest(url));
		if( !pnj )
			ic.filters = t.filters;
	}

	function initSkin( pnj : flash.display.MovieClip, id : String, skin : Int ) {
		var skin = Type.createEnumIndex(PnjSkin, skin);
		var chk = haxe.Md5.encode(id);
		var frames = [];
		for( i in 0...chk.length ) {
			var frame = chk.charCodeAt(i);
			if( frame >= 'A'.code && frame <= 'Z'.code )
				frame = frame - 'A'.code;
			else if( frame >= 'a'.code && frame <= 'z'.code )
				frame = frame - 'a'.code + 26;
			else if( frame >= '0'.code && frame <= '9'.code )
				frame = frame - '0'.code + 52;
			else
				frame = 62;
			frames.push(frame);
		}
		var frame = switch( skin ) {
		case KOld: 1;
		case KMan: 2;
		case KWomen: 3;
		case KBoy, KGirl: 4;
		case KSpecial: 5;
		case KMonk: 6;
		case KDrune: 7;
		}
		pnj.gotoAndStop(frame);
		var s = new mt.flash.Skin();
		var colors = [0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0xFF00FF, 0x00FFFF, 0xFFFFFF];
		var col = colors[frames.pop() % colors.length];
		for( i in 0...4 ) {
			var name = "_p" + (i + 1);
			var f = frames.pop();
			s.addAction(name, function(mc) mc.gotoAndStop(1 + (frame % mc.totalFrames)));
			s.addAction(name + "Col", function(mc) {
				mc.gotoAndStop(1 + (frame % mc.totalFrames));
				mc.transform.colorTransform = new flash.geom.ColorTransform(0, 0, 0, 1, (col >> 16), (col >> 8) & 0xFF, col & 0xFF, 0);
			});
		}
		s.apply(pnj, false);
		if( skin == KSpecial )
			loadIcon(pnj, "hero_" + id, true);
	}

	function cleanup() {
		m.dialog = null;
		mc.parent.removeChild(mc);
		onClose();
	}

	function onClick(e:flash.events.MouseEvent) {
		e.stopPropagation();
		if( clickLock )
			return;
		if( scroll != null ) {
			flash.Lib.getURL(new flash.net.URLRequest("/"),"_self");
			return;
		}
		if( d == null || d.texts.length == 0 ) {
			if( d != null )
				for( f in d.flags )
					switch( f ) {
					case FChooseObject(inv):
						d.flags = [];
						initChooseObject(inv);
						return;
					case FSell(obj, price):
						d.flags = [];
						initSell(obj, price);
						return;
					default:
					}
			cleanup();
			return;
		}
		// fast forward
		if( textPosition < d.texts[0].length ) {
			textPosition = d.texts[0].length;
			box._txt.text = d.texts[0];
		} else {
			d.texts.shift();
			if( d.texts.length == 0 ) {
				onClick(e);
				return;
			}
			box._txt.text = "";
			textPosition = 0;
		}
	}
	
	public function showWin( w : WinInfos ) {
		mc.graphics.clear();
		mc.graphics.beginFill(0, 0.8);
		var s = flash.Lib.current.stage;
		var width = s.stageWidth;
		mc.graphics.drawRect(0, 0, width, s.stageHeight);

		var py = 0;
		scroll = new flash.display.Sprite();
		mc.addChild(scroll);
		
		function tf(text, ?color, ?small) {
			var t = new flash.text.TextField();
			t.defaultTextFormat = m.uiClip.place.defaultTextFormat;
			if( small ) {
				var fmt = t.defaultTextFormat;
				fmt.size -= 2;
				t.defaultTextFormat = fmt;
			}
			t.width = width;
			t.textColor = color == null ? 0xDDC270 : color;
			t.selectable = false;
			t.text = StringTools.trim(text);
			t.y = py;
			scroll.addChild(t);
			py += 30;
		}
		
		function space(?n=1) {
			py += 30 * n;
		}
		
		var textIndex = 0;
		function text() return w.texts[textIndex++];
		
		tf(text(),0xFFFFFF);
		space(2);
		for( p in w.pnjs ) {
			var s = new PnjBox();
			s.x = (width - 42) >> 1;
			s.y = py;
			scroll.addChild(s);
			py += 44;
			initSkin(s._pnj, p.id, p.skin);
			tf(p.name);
			space(2);
		}
		space();
		tf(text(),0xFFFFFF);
		space(2);
		var level = text();
		for( h in w.heroes ) {
			var s = new PnjBox();
			s.x = (width - 42) >> 1;
			s.y = py;
			scroll.addChild(s);
			py += 44;
			initSkin(s._pnj, h.id, Type.enumIndex(KSpecial));
			tf(h.name,0xFFFFFF);
			tf(StringTools.trim(level) + " " + h.level);
			space(2);
		}
		space();
		tf(text(),0xFFFFFF);
		space(2);
		for( f in w.stats ) {
			tf(f);
			space();
		}
		space();
		tf(text(),0xFFFFFF);
		space(2);
		while( true ) {
			var t = text().split("|");
			if( t.length != 2 ) {
				textIndex--;
				break;
			}
			tf(t[0] + "\t\t" + t[1]);
			space(2);
		}
		space(2);
		tf(text(),0xFF8080);
		tf(text());
		space();
		for( t in text().split("|") )
			tf(t,true);
		space(7);
		tf(text(),0xFFFFFF);
		tf(text());
		clickLock = true;
		space(-8);
		scroll.y = s.stageHeight - 40;
		this.scrollY = -py;
		mc.buttonMode = false;
		mc.mouseChildren = false;
	}

	public function update() {
		if( objectAnimFrame != 0 ) {
			if( objectAnimFrame < 0 ) objectAnimFrame++ else objectAnimFrame--;
			updateObjects();
		}
		if( d != null && d.texts.length > 0 && textPosition < d.texts[0].length ) {
			switch( d.texts[0].charCodeAt(Std.int(textPosition)) ) {
			case ".".code:
				textPosition += 0.5;
			case " ".code:
				textPosition += 1.5;
			default:
				textPosition++;
			}
			box._txt.text = d.texts[0].substr(0, Std.int(textPosition));
		}
		if( scroll != null ) {
			scroll.y -= 0.4;
			if( scroll.y < scrollY ) {
				scroll.y = scrollY;
				clickLock = false;
				mc.buttonMode = mc.useHandCursor = true;
			}
		}
	}

}