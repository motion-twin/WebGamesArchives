import Protocol;
import WorldData.Pos;

typedef Mode = {
	function display( world : mt.DepthManager ) : Void;
	function update() : Void;
	function cleanup() : Void;
	function click(x:Float,y:Float) : Void;
	function action( id : String ) : Bool;
	function mouseMove() : Void;
	function result( r : Result ) : Void;
}

class Main {
	
	public static var WIDTH = 600;
	public static var HEIGHT = 400;
	static inline var GREEN = 0x44BB00;
	
	var root : flash.display.MovieClip;
	var mode : Mode;
	var oldZoom : Null<Bool>;
	var adminText : flash.text.TextField;
	public var js : haxe.remoting.Connection;
	public var fight : Fight;
	public var zoomMode : Null<Bool>;
	public var admin(default, null) : Bool;
	public var sea : MapSea;
	public var curIsland : MapIsland;
	public var curPos : MapCurrent;
	public var needRedraw : Bool;
	public var px : Int;
	public var py : Int;
	public var boat : { x : Int, y : Int, move : Int };
	public var world(default, null) : mt.DepthManager;
	public var ui : mt.DepthManager;
	public var fx : mt.DepthManager;
	public var dialog : Dialog;
	public var curWind : Int;
	public var uiClip : Ui;
	var lock : Bool;
	var defaultMapsColor : Int;
	var defaultFoodColor : Int;
	var trans : Transition;
	var fxm:mt.fx.Manager;
	var stip : flash.display.Sprite;
	var waiting : Bool;
	var waitingCommands : Array<Act>;
	public var qmap : haxe.remoting.AsyncConnection;
	
	function new(r, adm) {
		root = r;
		admin = adm;
		var me = this;
		#if debug
		if( DATA.load != null )
			haxe.Log.trace = customTrace;
		#end
		waitingCommands = [];
		Codec.displayError = function(err) me.onResult(RMessage("cancel",Std.string(err),"/"));
		var ctx = new haxe.remoting.Context();
		var me = this;
		fxm = new mt.fx.Manager();
		ctx.addObject("api", { _action : action, _msg : function(msg) me.onResult(new Codec().unserialize(msg)) } );
		js = haxe.remoting.ExternalConnection.jsConnect("cnx", ctx).api;
		uiClip = new Ui();
		for( t in [uiClip.food, uiClip.money, uiClip.map, uiClip.place,uiClip.potion,uiClip.latlong] ) {
			t.selectable = false;
			t.mouseEnabled = false;
		}
		defaultMapsColor = uiClip.map.textColor;
		defaultFoodColor = uiClip.food.textColor;
		updateLatLon(Math.floor(Const.BP(DATA.boat.x) / 3), Math.floor(Const.BP(DATA.boat.y) / 3));
		if( DATA.infos != null )
			onResult(RRefresh(DATA.infos));
		var uiRoot = new flash.display.Sprite();
		var fxRoot = new flash.display.Sprite();
		ui = new mt.DepthManager(uiRoot);
		ui.add(uiClip, 0);
		addTip(5, 0, 38, 25, "potion").addEventListener(flash.events.MouseEvent.MOUSE_UP, function(_) action('potion'));
		addTip(47, 0, 65, 25, "food");
		addTip(505, 0, 70, 25, "gold");
		addTip(580, 0, 70, 25, "maps");
		fx = new mt.DepthManager(fxRoot);
		root.addChild(fxRoot);
		root.addChild(uiRoot);
		qmap = haxe.remoting.FlashJsConnection.connect("cnx", "qmap").api;
	}
	
	function addTip( x:Int, y:Int, w:Int, h:Int, tip ) {
		var s = new flash.display.Sprite();
		s.graphics.beginFill(0xFF0000, 0);
		s.graphics.drawRect(0, 0, w, h);
		s.x = x;
		s.y = y;
		s.buttonMode = s.useHandCursor = true;
		ui.add(s,0);
		s.addEventListener(flash.events.MouseEvent.MOUSE_OVER, function(_) showTip(x,w,y+h+5,tip));
		s.addEventListener(flash.events.MouseEvent.MOUSE_OUT, function(_) this.stip.visible = false);
		return s;
	}

	function showTip(x:Int, w:Int, y:Int, txt) {
		if( stip != null ) ui.getMC().removeChild(stip);
		var tw = 180;
		
		var tf = new flash.text.TextField();
		var fmt = tf.defaultTextFormat;
		fmt.align = flash.text.TextFormatAlign.CENTER;
		tf.defaultTextFormat = fmt;
		tf.width = tw;
		tf.height = 1000;
		tf.wordWrap = true;
		if( txt == "maps" && uiClip.mapIcon.currentFrame != 1 )
			txt = "compass";
		var t = DATA.texts.get("t_"+txt);
		if( t == null ) t = "#" + txt;
		tf.textColor = 0xD0B66A;
		tf.text = t;
		var th = tf.textHeight + 5;
		tf.height = th + 5;

		
		stip = new flash.display.Sprite();
		ui.add(stip, 0);
		stip.y = y;
		var sw = flash.Lib.current.stage.stageWidth;
		if( x < sw >> 1 )
			stip.x = x;
		else
			stip.x = x + w - tw;
		stip.graphics.beginFill(0x5E513D,0.9);
		stip.graphics.lineStyle(1,0xD0B66A);
		stip.graphics.drawRect(0, 0, tw, th);
		stip.addChild(tf);
	}
	
	public function command( a : Act #if debug, ?p : haxe.PosInfos #end ) {
		if( DATA.load == null ) return;
		if( waiting ) {
			waitingCommands.push(a);
			return;
		}
		waiting = true;
		Codec.load(DATA.load, a, onResponse, 3);
		#if debug
		haxe.Log.trace(a, p);
		#end
	}
	
	function onResponse(r) {
		waiting = false;
		if( waitingCommands.length > 0 )
			command(waitingCommands.shift());
		onResult(r);
	}
	
	public function updateTarget(curX:Float,curY:Float) {
		if( DATA.target == null )
			uiClip.compass.wind.visible = false;
		else
			uiClip.compass.wind.rotation = 90 - Math.atan2( -(DATA.target.y * 0.5 - curY), DATA.target.x * 0.5 - curX) * 180 / Math.PI;
	}
	
	public function onResult( r : Result ) {
		var dialog = null;
		switch( r ) {
		case RNothing:
			// nothing
		case RGoto(url):
			flash.Lib.getURL(new flash.net.URLRequest(url),"_self");
		case RDialog(d):
			dialog = new Dialog(this);
			dialog.showPnj(d);
		case RMessage(i, t, url):
			dialog = new Dialog(this);
			dialog.showMessage(i, t);
			var me = this;
			if( url != null ) dialog.onClose = function() {
				me.lock = true;
				flash.Lib.getURL(new flash.net.URLRequest(url),url.substr(0,7)=="http://" ? "_blank" : "_self");
			};
		case RQuestion(i, act, t):
			dialog = new Dialog(this);
			dialog.showQuestion(i, act, t);
		case RSelectHero(text, hl, mode):
			dialog = new Dialog(this);
			dialog.selectHero(text, hl, mode);
		case RRefresh(infos):
			if( infos.popGold != null ) {
				var view = flash.Lib.as(mode, View);
				if( view != null ) {
					infos.gold -= infos.popGold;
					view.popGold(infos.popGold,infos.gold);
				}
			}
			curWind = infos.wind;
			uiClip.money.text = makeNum(infos.gold);
			var req = Const.MAP_REQ(infos.mapMax);
			if( infos.map <= req ) {
				uiClip.mapIcon.gotoAndStop(1);
				uiClip.map.text = infos.map + "/" + req;
				uiClip.map.textColor = infos.map == req ? GREEN : defaultMapsColor;
			} else {
				uiClip.mapIcon.gotoAndStop(2);
				uiClip.map.text = (infos.map - req) + "/" + (infos.mapMax - req);
				uiClip.map.textColor = infos.map == infos.mapMax ? GREEN : defaultMapsColor;
			}
			updateFood(infos.food,infos.foodMax);
			uiClip.potion.text = "" + infos.potions;
			try js.setHTML.call(["utoken", infos.tokens]) catch( e : Dynamic ) { };
			if( infos.menuHtml != null ) {
				tip();
				js.setHTML.call(["mapMenu", infos.menuHtml]);
				#if debug
				var icons = ~/img\/icons\/icon_([a-z]+)/;
				var f = [];
				while( icons.match(infos.menuHtml) ) {
					f.push(icons.matched(1));
					infos.menuHtml = icons.matchedRight();
				}
				infos.menuHtml = Std.string(f);
				#end
			}
		case RMulti(r):
			for( r in r )
				onResult(r);
			return;
		case RRunAction(act):
			if( dialog == null )
				mode.action(act);
			else {
				var old = dialog.onClose;
				var me = this;
				dialog.onClose = function() {
					old();
					me.onResult(RRunAction(act));
				};
			}
		case RRemovePoint(x,y,k):
			qmap._rm.call([x, y, k]);
		case RAddPoints(pl):
			qmap._add.call([pl]);
		case RWin(w):
			dialog = new Dialog(this);
			dialog.showWin(w);
		default:
			mode.result(r);
		}
		if( dialog != null )
			setDialog(dialog);
			
		#if debug
		haxe.Log.trace(r, null);
		#end
	}
	
	function setDialog( d : Dialog ) {
		if( dialog == null ) {
			dialog = d;
			return;
		}
		d.mc.visible = false;
		var old = dialog.onClose;
		var me = this;
		dialog.onClose = function() {
			old();
			d.mc.visible = true;
			me.setDialog(d);
		};
	}
	
	public function setAdminText( t : Dynamic ) {
		if( adminText == null ) {
			var stage = root.stage;
			var inf = new flash.text.TextField();
			inf.width = stage.stageWidth;
			inf.height = 20;
			inf.y = stage.stageHeight - inf.height;
			inf.selectable = false;
			inf.mouseEnabled = false;
			inf.filters = [new flash.filters.GlowFilter(0xEEEEEE, 1.0, 1.5, 1.5, 100, 3)];
			adminText = inf;
			stage.addChild(adminText);
		}
		adminText.text = Std.string(t);
	}

	public function tip( ?s : String ) {
		js.setTip.call([s]);
	}
	
	public function htmlLock(l:Bool) {
		js.setLock.call([l]);
	}
	
	function init( s : MapSea, b ) {
		this.boat = b;
		px = Const.BP(b.x);
		py = Const.BP(b.y);
		if( s == null ) {
			if( !admin )
				throw "No sea @" + px + "," + py;
			s = {
				id: -1,
				x : px,
				y : py,
				w : 1,
				h : 1,
				il : new List(),
				name : "",
			};
		}
		sea = s;
		if( curIsland == null && DATA.cur != null )
			for( i in sea.il )
				if( i.id == DATA.cur.iid ) {
					curIsland = i;
					curPos = DATA.cur;
					zoomMode = true;
					DATA.cur = null;
					break;
				}
		updateTarget(boat.x / Const.BSIZE,boat.y / Const.BSIZE);
		display();
	}
	
	public function display() {
		if( world != null )
			root.removeChild(world.getMC());
		needRedraw = false;
		root.stage.focus = root;
		var mc = new flash.display.Sprite();
		mc.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, onMouseMove);
		mc.addEventListener(flash.events.MouseEvent.MOUSE_UP, onClick);
		world = new mt.DepthManager(mc);
		root.addChildAt(mc,0);
		
		// check zoomMode
		var found = false;
		for( i in sea.il )
			if( i == curIsland ) {
				found = true;
				zoomMode = true;
				break;
			}
		if( !found )
			curIsland = null;
		if( curIsland == null )
			zoomMode = false;
		if( fight != null )
			zoomMode = null;
	
		if( oldZoom != zoomMode ) {
			oldZoom = zoomMode;
			if( mode != null )
				mode.cleanup();
			if( zoomMode == null )
				mode = fight;
			else if( zoomMode )
				mode = new View(this);
			else
				mode = new Map(this);
		}
		mode.display(world);
		updatePlace();

		
	}
	
	function onClick(e) {
		if( lock ) return;
		var mc = world.getMC();
		if( mode != null ) mode.click(mc.mouseX,mc.mouseY);
	}
	
	function update(_) {
		if( trans != null && !trans.update() ) {
			trans.cleanup();
			trans = null;
		}
		if( needRedraw ) display();
		if( lock ) return;
		if( dialog != null ) {
			dialog.update();
			return;
		}
		fxm.update();
		mode.update();
	}

	public function transition() {
		if( trans != null ) trans.cleanup();
		trans = new Transition(this);
		var old = zoomMode;
		display();
		trans.init(old,zoomMode);
	}
	
	public function onMouseMove(_) {
		if( lock ) return;
		mode.mouseMove();
	}
	
	public function makeNum( v : Int ) {
		if( v < 1000 )
			return Std.string(v);
		return Std.int(v / 1000) + "." + StringTools.lpad(Std.string(v % 1000), "0", 3);
	}
	
	public function updateFood(v:Int,max:Int) {
		uiClip.food.text = v+"/"+max;
		uiClip.food.textColor = v <= 5 ? 0xF00000 : (v == max ? GREEN : defaultFoodColor);
	}
	
	public function updatePlace( ?name : String ) {
		if( name == null )
			name = (curIsland == null) ? ((sea == null) ? "???" : sea.name) : curIsland.name;
		uiClip.place.text = name;
	}
	
	public function updateLatLon( lat : Int, lon : Int ) {
		uiClip.latlong.text = lat + "° " + lon + "'";
	}
	
	public function setHeroLife( hid : Int, life : Int, max : Int ) {
		try {
			js.updateBar.call(["hero_" + hid, "hp", life, max]);
		} catch( e : Dynamic ) {
		}
	}
	
	public function clearActions( ?text ) {
		js.setHTML.call(["actionBox", text == null ? "" : '<span class="info">'+text+'</text>']);
		tip();
	}
	
	function action(id) {
		if( dialog != null )
			return;
		if( !mode.action(id) )
			throw "Unknown action " + id;
	}
	
	function customTrace( v : Dynamic, ?pos : #if debug haxe.PosInfos #else { } #end ) {
		#if debug
		if( pos != null ) {
			var p = { };
			Reflect.setField(p, "fileName", pos.fileName);
			Reflect.setField(p, "lineNumber", pos.lineNumber);
			pos = cast p;
		}
		#end
		js.log.call([Std.string(v), pos]);
	}
	
	public function displayInfos( name : String ) {
		var fx = new DisplayInfo();
		var t : flash.text.TextField = untyped fx.sub.place;
		t.text = name;
		t.selectable = false;
		var msk = new DisplayInfoMask();
		fx.mask = msk;
		fx.y = msk.y = 140;
		this.fx.add(fx, 0);
		this.fx.add(msk, 0);
	}

	
	public static var inst : Main;
	public static var DATA : MapInit;
	
	
	static function randIslands() {
		var l = new List();
		var pos = [ { x : 7, y : 9, s : 2 }, { x : 12, y : 12, s : 1 } ];
		for( p in pos ) {
			var i = {
				x : p.x,
				y : p.y,
				w : p.s,
				h : p.s,
				e : SEFree,
				id : l.length,
				name : "Ile Debug" + l.length,
				bmp : null,
				segs : null,
				pts : null,
				tiles : [0, 1, 2],
				seed : Std.random(0x1000000),
			};
			var g = new Generator(i.w * Const.ISIZE, i.h * Const.ISIZE, i.seed);
			while( !g.generate([]) ) {
			}
			g.saveTo(i);
			l.add(i);
		}
		return l;
	}
	
	static function main() {
		mt.flash.Gc.init();
		mt.flash.Key.init();
		mt.flash.Key.enableJSKeys("map");
		var mc = flash.Lib.current;
		Codec.addObfuType("Bits", Bits);
		Codec.addObfuType("Pos", Pos);
		try {
			DATA = Codec.getData("data");
			if( cast(DATA) == 54 )
				DATA = {
					adm : false,
					boat : { x : 0, y : 0, speed : 1, move : 0 },
					cli : null,
					cur : null,
					infos : { wind : Std.random(8), tokens : 0, potions : 0, menuHtml : null, mapMax : 6, map : 1, gold : 666, food : 666, foodMax : 777, popGold : null },
					target : null,
					load : null,
					sea : { x : -10, y : -10, w : 20, h : 30, name : "Sea of debug", id : 0, il : randIslands() },
					texts : new Hash(),
				};
		} catch( e : Dynamic ) {
			throw e;
		}
		inst = new Main(mc,DATA.adm);
		inst.init(DATA.sea, DATA.boat);
		mc.stage.addEventListener(flash.events.Event.ENTER_FRAME, inst.update );
	}
	
}