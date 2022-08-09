//-cmd obfu9 -key mxhotel %__file__% -o %__file__%
import Protocol;
import mt.deepnight.Tweenie;
import T;
import Gen;
import mt.deepnight.deprecated.Types;
import mt.deepnight.Color;
import mt.deepnight.Range;

using mt.deepnight.deprecated.SuperMovie;

typedef HPoint = { floor:Int, x:Int };

typedef MenuElement =  {
	icon	: Null<flash.display.DisplayObject>,
	label	: String,
	col		: Null<Int>,
	help	: String,
	cb		: Void->Void,
}

enum DecoPosition {
	Floating;
	Ground;
	GroundBase; // peut porter des objets
	GroundStack; // peut être porté
	//Ceil;
}

enum PendingAction {
	PA_AddClient(c:FlashClient);
	PA_MoveClient(r:_Room);
	PA_SendStaff(fs:FlashStaff);
	PA_UseItem(item:_Item);
	PA_PlaceDeco(deco:DecoItem);
}

class FlashRoom implements haxe.Public {
	var mc		: SPR;
	var data	: _Room;
	var x		: Int;
	var floor	: Int;
	//var cx		: Float;
	//var cy		: Float;
	var logs	: List<MC>;
	var fclient	: Null<FlashClient>;
	//var fstaff	: Null<FlashStaff>;
	
	function new(r, f, x) {
		data = r;
		floor = f;
		this.x = x;
		logs = new List();
	}
	
	function clearLogs() {
		for (mc in logs)
			mc.parent.removeChild(mc);
		logs = new List();
	}
}

class FlashClient implements haxe.Public {
	var mc			: MC;
	var clientMc	: MC;
	var data		: _Client;
	var x			: Float;
	var y			: Float;
	var animStep	: Float;
	var luggages: List<MC>;
	
	function new(mc, c) {
		this.mc = mc;
		luggages = new List();
		animStep = Std.random(1000)/100;
		data = c;
	}
	
	inline function isFlying() {
		return data._type == _MF_FLYING || data._type == _MF_BASIC;
	}
}

class FlashStaff implements haxe.Public {
	var mc 		: lmc.Staff;
	var data	: _Staff;
	var x		: Float;
	var y 		: Float;
	
	function new (mc, c) {
		this.mc = mc;
		data = c;
	}
}

//class FlashItem implements haxe.Public {
	//var mc 		: lmc.Item;
	//var data	: _Item;
	//
	//function new (mc, i) {
		//this.mc = mc;
		//data = i;
	//}
//}


class Game {
	static var auto = 0;
	
	public static var LANG = "en";
	
	public static var DP_SKY = auto++;
	public static var DP_HOTEL = auto++;
	public static var DP_INTERF = auto++;
	public static var DP_TOP = auto++;
	public static var DP_CURSOR = auto++;
	static var DEFAULT_MENU_COLOR = 0x4B4B4B;
	static var RANDOM_THOUGHTS_DELAY = Range.makeInclusive(6,15); // 9-20
	static var DAY_CLOUDS = 0x91D2FF;
	static var NIGHT_CLOUDS = 0x223460;
	public static var MIN_FLASH_VERSION = "10.1.102.64";

	static var RAW_CSS =  // ATTENTION : pas d'espace entre le nom de l'attribut css et le ":" !!!
	"
		.title {
			color: 0xFFD064;
			font-size: 20pt;
			font-weight: bold;
		}
		.ambiant {
			font-style: italic;
		}
		.rule {
			margin-top: 10px;
			color: 0xBED7E4;
		}
		.strong {
			color: 0xFFE4A8;
			font-weight: bold;
		}
	";
	static var CSS = {
		var css = new flash.text.StyleSheet();
		RAW_CSS = StringTools.replace(RAW_CSS, "0x", "#");
		css.parseCSS(RAW_CSS);
		css;
	}

	public static var ME	: Game;
	public static var TW	: Tweenie;
	static var TG			: TextGen;
	static var CD = 5;
	public static var WID		= Std.int(flash.Lib.current.stage.stageWidth);
	public static var HEI		= Std.int(flash.Lib.current.stage.stageHeight);
	public static var BMARGIN	= 40;
	static var OUT_WID			= 2500;
	public static var ROOM_WID	= Const.ROOM_WID;
	public static var FLOOR_HEI	= Const.FLOOR_HEI; // 96
	static var GROUND_HEI = 7;
	static var BAD_COLOR = 0xff0000;
	static var GOOD_COLOR = 0x006699;
	static var SHADOW_COLOR = 0x182869;
	
	var dm				: mt.DepthManager;
	var root			: MC;
	var sky				: MC;
	var skyNight		: MC;
	var scroller		: MC;
	var superBuilding	: MC;
	var building		: MC;
	var queueCont		: SPR;
	var outside			: SPR;
	var debug			: MC;
	var clouds			: List<{spd:Float,mc:fx.CloudBlur}>;
	var nextClock		: scen.Clock;
	var curClock		: scen.Clock;
	var tip				: interf.Tip;
	var popUp			: interf.Pop;
	var confBox			: interf.Pop;
	var mask			: interf.Mask;
	var notice			: interf.Pop;
	var loadingMc		: SPR;
	//var moneyCounter	: interf.Money;
	var cursor			: interf.Cursor;
	var menu			: SPR;
	var extButtons		: List<interf.RoomSlot>;
	var spreadList		: List<MC>;
	var luggages		: List<MC>;
	var hotelName		: scen.out.HotelName;
	var droppedItems	: List<{mc:SPR, y:Float, t:Float}>;
	var buildModeButton	: interf.BuildMode;
	var decoModeButton	: interf.DecoMode;
	var pnumberList		: List<interf.PopNumber>;
	var itemCategories	: IntHash<String>;
	var notLoadedIcons	: Int;
	var initData		: InitData;
	var iconsHash		: Hash<BD>;
	var decoCursor		: SPR;
	var floorMcs		: Array<SPR>;
	var oldDeco			: Null<DecoItem>;
	var decoStock		: List<SPR>;
	var decoItems		: IntHash<SPR>;
	
	var frooms			: List<FlashRoom>;
	var clientCursor	: SPR;
	//var vscroll			: Scrollbar;
	//var hscroll			: Scrollbar;
	
	var dragPt			: Null<flash.geom.Point>;
	var dragTime		: Int;
	var fl_cancelClick	: Bool;
	
	var hotel			: _Hotel;
	var queue			: List<FlashClient>;
	var pending			: PendingAction;
	var fstaff			: List<FlashStaff>;
	//var fitems			: List<FlashItem>;
	var catButtons		: List<MC>;
	var popQueue		: List<String>;
	//var money			: Int;
	var fl_stickyCursor	: Bool;

	var timer			: haxe.Timer;
	var seed			: Int;
	
	var date			: Date;
	var nextAutoRefresh	: Date;
	var nextThought		: Float;
	
	var ctx 			: haxe.remoting.Context;
	var js				: haxe.remoting.ExternalConnection;
	var fl_ready		: Bool;
	var fl_serverLock	: Bool;
	var fl_lock			: Bool;
	var fl_buildMode	: Bool;
	var fl_spectator	: Bool;
	var fl_decoMode		: Bool;
	var mouse 			: flash.geom.Point;
	
	public function new(r:MC) {
		ME = this;
		root = r;
		LANG = Reflect.field(flash.Lib.current.loaderInfo.parameters,"lang");
		if(LANG==null)
			LANG = "fr";
		dm = new mt.DepthManager(root);
		root.stage.quality = flash.display.StageQuality.MEDIUM;
		mt.deepnight.Lib.redirectTracesToConsole();
		root.addEventListener( flash.events.Event.ENTER_FRAME, main );
		clouds = new List();
		//rooms = new List();
		queue = new List();
		frooms = new List();
		spreadList = new List();
		fstaff = new List();
		//fitems = new List();
		popQueue = new List();
		luggages = new List();
		droppedItems = new List();
		extButtons = new List();
		pnumberList = new List();
		catButtons = new List();
		iconsHash = new Hash();
		floorMcs = new Array();
		decoStock = new List();
		decoItems = new IntHash();
		fl_ready = false;
		fl_buildMode = false;
		fl_spectator = false;
		fl_lock = false;
		fl_decoMode = false;
		fl_cancelClick = false;
		notLoadedIcons = 0;
		nextThought = -1;
		dragTime = 0;
		
		T.init();
		TG = new TextGen(1);
		TW = new Tweenie();
		setServerLock(false);
		
		// fond
		var g = root.graphics;
		g.beginFill(0x414270, 1);
		g.drawRect(0,0,WID,HEI);
		g.endFill();

		//TW.create(root, "x", 200, TLinear, DateTools.seconds(10)); // HACK
		
		//connexion avec le js
		ctx = new haxe.remoting.Context();
		ctx.addObject("GameJsApi", GameJsApi);
		js = haxe.remoting.ExternalConnection.jsConnect("cnx", ctx);
		
		// handler clavier amélioré (pour key.isDown...)
		mt.flash.Key.init();
		
		// init hotel
		var viewUid = Std.parseInt( Reflect.field(flash.Lib.current.loaderInfo.parameters,"viewUid") );
		if ( viewUid!=null && !Math.isNaN(viewUid) && viewUid>0 )
			sendAction(P_VIEW_HOTEL(viewUid));
		else
			sendAction(P_INIT);
	}
	
	inline function isLocked() {
		return fl_lock || fl_serverLock;
	}
	
	function lockGame() {
		fl_lock = true;
		attachMask();
	}
	function unlockGame() {
		fl_lock = false;
		detachMask();
		try {
			playLog();
		} catch(e:String) {}
	}
	
	public static function _unlockGame() {
		ME.unlockGame();
	}
	
	inline function isOldView() {
		return fl_spectator && Math.abs(mt.deepnight.Lib.countDeltaDays(date, initData._serverTime)) >= 1;
	}
	
	function getNextClient() {
		var delay = hotel._nextClient.getTime() - date.getTime();
		return DateTools.parse(delay);
	}
	
	function setServerLock(b:Bool) {
		fl_serverLock = b;
		if ( loadingMc!=null ) {
			loadingMc.parent.removeChild(loadingMc);
			loadingMc = null;
		}
		if (fl_serverLock) {
			loadingMc = new SPR();
			dm.add(loadingMc, DP_TOP);
			//var mask = new interf.Mask();
			//mask.width = WID;
			//mask.height = HEI;
			//mask.alpha = 0.6;
			//loadingMc.addChild(mask);
			var anim = new interf.Loading();
			anim.field.text = T.get.Loading;
			anim.x = WID - anim.field.textWidth - 5;
			anim.y = 5;
			loadingMc.addChild(anim);
		}
	}
	
	
	//function scrolling() {
		//if (building == null)
			//return;
		//var pY = root.mouseY;
		//var pX = root.mouseX;
		//var pBX = building.x;
		//var pBY = building.y;
		//
		//if (pY < 60.0 && pY > 0 && pBY < 650)
			//mouseScroll(true, pY );
		//if (HEI - pY < 60.0 && pY <= 400 && pBY > 320)
			//mouseScroll(true, (pY - HEI));
		//if (pX < 120 && pX > 1 && pBX < 50) {
			//mouseScroll(false, pX);
		//}
		//if (WID - pX < 120 && pX <= 800 && pBX > -600)
			//mouseScroll(false, pX - WID );
	//}
	
	function mouseScroll(dir1:Bool, dir2:Float) {
		var RATIOPX = 20;
		var RATIO:Float;
		if(dir1)
			RATIO = ( Math.abs(dir2) * 100) / 6000;
		else
			RATIO = ( Math.abs(dir2) * 100) / 12000;
			
			switch(dir1){
				case true :
					if (dir2 > 0)
						building.y += RATIOPX * (1-RATIO);
					else
						building.y -= RATIOPX * (1-RATIO);
				case false :
					if (dir2 > 0)
						building.x += RATIOPX * (1-RATIO);
					else
						building.x -= RATIOPX * (1-RATIO);
			}
		}
	
	
	function onServerData( r : Rsult ){
		try {
			var oldMoney = if (hotel!=null) hotel._money else 0;
			switch( r._rslt ) {
				case R_SPECTATOR(_) : fl_spectator = true;
				default:
			}
			hotel = r._h;
			date =
				if (hotel._debugDate != null )
					hotel._debugDate;
				else
					r._d;
					
			if (nextThought<=0)
				nextThought = DateTools.delta(date, 1000*RANDOM_THOUGHTS_DELAY.draw()).getTime();
				
			updateAutoRefresh();
			
			switch(r._rslt) {
				case R_SPECTATOR(idata) :
					initData = idata;
					loadIcons();
					
				case R_INIT(idata) :
					initData = idata;
					itemCategories = idata._itemCats;
					loadIcons();
					
				case R_ACTION(fl_shapeChanged) :
					if (fl_shapeChanged)
						initFlashRooms();
					loadIcons();
					onActionResult();
					setServerLock(false);
			}

			resetQuality();
			if( fl_ready )
				updateWeather();

			// log de jeu
			var log = Lambda.array(hotel._gameLog);
			log.reverse();
			try js.api.setLog.call([log]) catch(e:Dynamic) {}
			
			// compteurs
			if( !fl_spectator ) {
				try js.api.setMoney.call([hotel._money]) catch (e:Dynamic) { }
				try js.api.setFame.call([hotel._fame]) catch (e:Dynamic) { }
			}
		} catch (e:String) {}
	}
	
	function updateAutoRefresh(?minMinutes=2) {
		// calcul de la date d'auto-refresh
		if (fl_spectator)
			nextAutoRefresh = DateTools.delta(date, DateTools.minutes(10));
		else {
			var stamp = DateTools.delta(date, DateTools.hours(4)).getTime();
			stamp = Math.min(stamp, hotel._nextClient.getTime());
			for (c in hotel._clients) {
				if (c._activityEnd != null)
					stamp = Math.min(stamp, c._activityEnd.getTime());
				stamp = Math.min(stamp, c._dateLeaving.getTime());
			}
			for (f in 0...hotel._rooms.length)
				for (x in 0...hotel._rooms[f].length) {
					var r = hotel._rooms[f][x];
					if ( r._underConstruction != null )
						stamp = Math.min(stamp, r._underConstruction.getTime());
				}
			for (s in hotel._staff)
				if(s._endDate!=null)
					stamp = Math.min( stamp, s._endDate.getTime() );
			stamp += DateTools.seconds(5); // compensation du lag réseau
			stamp = Math.max(DateTools.delta(date,DateTools.minutes(minMinutes)).getTime(), stamp); // délai minimum
			nextAutoRefresh = Date.fromTime(stamp);
		}
	}
	
	inline function resetQuality() {
		root.stage.quality = if (initData!=null && initData._lowq) flash.display.StageQuality.LOW else flash.display.StageQuality.MEDIUM;
	}
	
	private function initWeather() {
		var min = date.getMinutes();
		var hour = date.getHours();
		if (hour >= 6 && hour < 10) {
			hour -= 6;
			min = hour * 60 + min;
			skyNight.alpha = (1 / 24)*min;
		}
		else if (hour >= 18 && hour < 22) {
			hour -= 18;
			min = hour * 90 + min;
			skyNight.alpha = -(1 / 24)*min;
		}
		else if (hour >= 10 && hour < 18){
			skyNight.alpha = 0;
		}
		else {
			skyNight.alpha = 1;
		}
	}

	function getNightRatio() : Float {
		var d = DateTools.parse(date.getTime());
		var min = d.minutes;
		var hour = d.hours +1 ;
		if (hour<6 || hour>=22)
			return 1;
		else if (hour >= 6 && hour < 10) {
			hour -= 6;
			min = hour * 60 + min;
			return 1 - (1 / 240)*min;
		}
		else if (hour >= 18 && hour < 22) {
			hour -= 18;
			min = hour * 60 + min;
			return (1 / 240) * min;
		}
		else return 0;
	}

	
	private function updateWeather () {
		skyNight.alpha = getNightRatio();
		var ct = Color.getSimpleCT( Color.interpolate( Color.intToRgb(DAY_CLOUDS), Color.intToRgb(NIGHT_CLOUDS), getNightRatio() ) );
		for (cloud in clouds) {
			cloud.mc.transform.colorTransform = ct;
			if ( isOldView() )
				cloud.mc.visible = false;
		}
	}
	
	private function onChangeTime(d:Float) {
		date = DateTools.delta(date, d);
		updateTime();
		if( date.getSeconds()%20==0 )
			updateWeather();
		
		if ( date.getTime() >= nextAutoRefresh.getTime() && !fl_decoMode && !isLocked() ) {
			nextAutoRefresh = DateTools.delta(date, DateTools.days(1));
			setServerLock(true);
			try js.api.refresh.call([]) catch(e:Dynamic) {}
		}
	}
	
	
	function loadIcons() {
		// listing des icones d'items à charger
		var ihash = new Hash();
		for (key in Type.getEnumConstructs(_Item))
			ihash.set(key, true);
		//for (id in hotel._items.keys())
			//ihash.set( Std.string(Type.createEnumIndex(_Item,id)), true );
		//for (floor in hotel._rooms)
			//for (r in floor) {
				//if(r._item!=null)
					//ihash.set( Std.string(r._item), true );
				//if(r._itemToTake!=null)
					//ihash.set( Std.string(r._itemToTake), true );
			//}
			
		// chargement
		notLoadedIcons = 0;
		for (name in ihash.keys()) {
			if ( iconsHash.exists(name) )
				continue;
			var container = new SPR();
			notLoadedIcons+=2;
			
			var loadContext = new flash.system.LoaderContext();
			loadContext.checkPolicyFile = true ;
			
			var url = StringTools.replace(initData._itemUrl, "%", "item_"+name.substr(1).toLowerCase());
			//var url = "http://urbanevolution.files.wordpress.com/2009/11/earth1.jpg"; // HACK
			var fdl = new flash.display.Loader();
			fdl.contentLoaderInfo.addEventListener( flash.events.Event.COMPLETE, callback(onLoadIcon,name,container) );
			fdl.contentLoaderInfo.addEventListener( flash.events.Event.INIT, callback(onLoadIcon,name,container) );
			fdl.contentLoaderInfo.addEventListener( flash.events.IOErrorEvent.IO_ERROR, callback(onLoadIconError, url) );
			fdl.load( new flash.net.URLRequest(url), loadContext );
			container.addChild(fdl);
		}
		
		if ( notLoadedIcons==0 )
			onLoadIcons();
	}
	
	function onLoadIcon(name:String, container:SPR, r:Dynamic) {
		notLoadedIcons--;
		if ( !iconsHash.exists(name) ) {
			// appel 1
			var bdata = new BD(16,16,true,0x0);
			iconsHash.set(name, bdata);
		}
		else {
			// appel 2.. oui je sais c'est pourri comme méthode
			iconsHash.get(name).draw( container );
		}
		
		if (notLoadedIcons<=0)
			onLoadIcons();
	}
	
	function onLoadIconError(r:Dynamic, url:String) {
		pop("LOAD ERROR : "+url);
	}
	
	function onLoadIcons() {
		if(!fl_ready) {
			onHotelReady();
			setServerLock(false);
			onActionResult();
		}
	}
	
	
	function onHotelReady() {
		fl_ready = true;
		timer = new haxe.Timer(Std.int(DateTools.seconds(1)));
		seed = hotel._id;
		if(!fl_spectator)
			timer.run = callback(onChangeTime, DateTools.seconds(1));
		
		// ciel
		sky = new scen.Sky();
		sky.width = WID;
		sky.height = HEI;
		if( isOldView() )
			sky.filters = [ getSpectatorFilter(0.8) ];
		dm.add(sky, DP_SKY);
		sky.onClick( cancelAll );
		
		skyNight = new scen.SkyNight();
		skyNight.width = WID;
		skyNight.height = HEI;
		skyNight.disableMouse();
		dm.add(skyNight, DP_SKY);
		initWeather();
		
		scroller = new MC();
		dm.add(scroller, DP_HOTEL);
		scroller.mouseEnabled = false;

		// nuages
		for (i in 0...10) {
			var mc = new fx.CloudBlur();
			mc.x = Std.random(600);
			mc.y = Std.random(300);
			//var ct = new flash.geom.ColorTransform();
			//ct.color = 0xffffff;
			//mc.transform.colorTransform = ct;
			//mc.transform.colorTransform = Color.getSimpleCT(DAY_CLOUDS);
			mc.gotoAndStop(Std.random(mc.totalFrames)+1);
			//mc.filters = [ new flash.filters.BlurFilter(2,2)];
			//mc.alpha = 0.20;
			mc.disableMouse();
			clouds.add({mc:mc, spd:Std.random(60) / 100+0.1});
			dm.add(mc, DP_SKY);
		}
		
		outside = new SPR();

		// décor de ville
		var rseed = new mt.Rand(0);
		rseed.initSeed(seed);
		var city = new SPR();
		outside.addChild(city);
		var dark = new flash.geom.ColorTransform();
		dark.color = 0x183E6B;
		var light = new flash.geom.ColorTransform();
		light.color = 0x286291;
		// bâtiments
		var x = 0;
		while(x<OUT_WID) {
			var mc = new scen.out.Building();
			mc.x = x;
			mc.y = HEI-BMARGIN;
			x+=rseed.random(50)+50;
			mc.rotation = rseed.random(5) * (rseed.random(2)*2-1);
			mc.scaleX = (rseed.random(30)+70) / 100;
			mc.scaleY = (rseed.random(80)+60) / 100;
			mc.gotoAndStop(rseed.random(mc.totalFrames)+1);
			mc.transform.colorTransform = if(rseed.random(100)<70) dark else light;
			mc.filters = [ new flash.filters.BlurFilter(6,6,2)];
			city.addChild(mc);
		}
		
		// arbres
		var trees = new SPR();
		city.addChild(trees);
		var x = 0;
		while(x<OUT_WID) {
			var mc = new scen.out.Tree();
			mc.x = x;
			mc.y = HEI - 5 + rseed.random(20) - BMARGIN;
			x+=rseed.random(60)+40;
			mc.rotation = rseed.random(5) * (rseed.random(2)*2-1);
			mc.scaleX = (rseed.random(40)+50) / 100;
			mc.scaleY = mc.scaleX;
			mc.scaleX *= rseed.random(2)*2-1;
			mc.gotoAndStop(rseed.random(mc.totalFrames)+1);
			trees.addChild(mc);
		}
		trees.filters = [ new flash.filters.GlowFilter(0x2F384A,1, 3,3,10) ];
		
		// sol extérieur
		var ground = new SPR();
		var g = ground.graphics;
		var bmp = new tex.out.Ground(0,0);
		g.beginBitmapFill(bmp, new flash.geom.Matrix(), true);
		g.drawRect(0,0,OUT_WID,bmp.height);
		g.endFill();
		ground.y = HEI-3-GROUND_HEI-BMARGIN;
		outside.addChild(ground);
		
		// cache bitmap du décor
		var bmp = new BD(OUT_WID, HEI,true,0x0);
		bmp.draw(outside);
		if( isOldView() )
			bmp.applyFilter( bmp, bmp.rect, new flash.geom.Point(0, 0), getSpectatorFilter(0.85) );
		outside = new SPR();
		outside.addChild( new flash.display.Bitmap(bmp) );
		outside.x = -800;
		outside.disableMouse();
		scroller.addChild(outside);

		var rseed = new mt.Rand(0);
		rseed.initSeed(seed);
		
		// init des flashrooms
		initFlashRooms();
		
		superBuilding = new MC();
		scroller.addChild(superBuilding);
		superBuilding.x = 0;
		
		// barre de menu
		if(!fl_spectator) {
			var bar = new interf.MenuBar();
			bar.width = WID;
			bar.filters = [
				new flash.filters.DropShadowFilter(1,90, 0x0,0.5, 0,0),
			];
			dm.add(bar, DP_INTERF);
		}

		// bouton Construction
		if (!fl_spectator) {
			var mc = new interf.BuildMode();
			dm.add(mc, DP_INTERF);
			buildModeButton = mc;
			mc.visible = hotel.canUseBuildMode();
			mc.x = 44;
			mc.y = 5;
			mc.transform.colorTransform = Color.getSimpleCT(0xF5AF47);
			var txt =
				paragraph(T.get.EnlargeButtonTitle,"title") +
				paragraph(T.get.EnlargeButton, "ambiant");
			mc.onOver( callback(createTip, txt, null) );
			mc.onOut( clearTip );
			mc.onClick( toggleBuildMode );
			mc.handCursor(true);
		}

		// bouton Décoration
		if (!fl_spectator) {
			var mc = new interf.DecoMode();
			dm.add(mc, DP_INTERF);
			decoModeButton = mc;
			mc.field.mouseEnabled = false;
			mc.x = 5;
			mc.y = 5;
			mc.transform.colorTransform = Color.getSimpleCT(0xFA9143);
			var txt =
				paragraph(T.get.DecoButtonTitle,"title") +
				paragraph(T.get.DecoButton, "ambiant");
			mc.onOver( callback(createTip, txt, null) );
			mc.onOut( clearTip );
			mc.onClick( toggleDecoMode );
			mc.handCursor(true);
			mc.visible = hotel._deco.length>0;
		}

		// scrollbars
		//vscroll = new Scrollbar(root, scroller, hotel);
		//vscroll.mc.onOver( callback(createTip, T.get.ScrollTip, null) );
		//vscroll.mc.onOut( clearTip );
		//dm.add(vscroll.mc, DP_INTERF);
//
		//hscroll = new Scrollbar(root, scroller, hotel);
		//hscroll.mc.onOver( callback(createTip, T.get.ScrollTip, null) );
		//hscroll.mc.onOut( clearTip );
		//hscroll.setHorizontal();
		//dm.add(hscroll.mc, DP_INTERF);
		
		
		// listener
		flash.Lib.current.stage.addEventListener( flash.events.KeyboardEvent.KEY_DOWN, onKeyDown );
		flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, onMouseDown, false, 100 );
		flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.MOUSE_UP, onMouseUp );
		flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.CLICK, onMouseClick, true, 100);
		flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.MOUSE_MOVE, onMouseMove);
		flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.MOUSE_WHEEL, onMouseWheel );
			
		updateWeather();
		
		if ( !mt.deepnight.Lib.atLeastVersion(MIN_FLASH_VERSION) ) {
			var lastAlert : Date = mt.deepnight.Lib.getCookie("hotel", "alert");
			//if(lastAlert==null || Date.now().getTime()-lastAlert.getTime()>=DateTools.hours(2)) {
				pop(T.get.FlashUpdateRequired, 0x9B1515);
				mt.deepnight.Lib.setCookie("hotel", "alert", Date.now());
			//}
		}
		
		if ( fl_spectator ) {
			var band = new interf.Band();
			dm.add(band, DP_INTERF);
			band.x = Std.int(WID * 0.5);
			band.y = 10;
			band.label.text = T.get.BandLabel;
			band.disableMouse();
			
			var delta = mt.deepnight.Lib.countDeltaDays(initData._serverTime, date);
			band.time.text =
				if (delta == 0)			DateTools.format( date, T.get.DateToday );
				else if (delta == -1)	DateTools.format( date, T.get.DateYesterday );
				else 					DateTools.format( date, T.get.DateLongAgo );
				
			//band.alpha = 0.7;
		}
	}
	
	function initFlashRooms() {
		frooms = new List();
		for (f in 0...hotel._rooms.length)
			for (x in 0...hotel._rooms[f].length) {
				var rdata = hotel._rooms[f][x];
				var fr = new FlashRoom(rdata,f,x);
				frooms.add(fr);
			}
		//if (vscroll!=null)
			//vscroll.setHotel(hotel);
		//if (hscroll!=null)
			//hscroll.setHotel(hotel);
	}
	
	function getSpectatorFilter(ratio:Float) {
		return new flash.filters.ColorMatrixFilter(Color.getDesaturateMatrix(ratio));
	}
	
	function onKeyDown(e:flash.events.KeyboardEvent) {
		onKey(e.keyCode);
	}
	
	function onKey(c:Int) {
		switch(c) {
			//case flash.ui.Keyboard.HOME	:
				//if (vscroll.mc.visible) vscroll.scroll(-ROOM_WID*50);
			//case flash.ui.Keyboard.END :
				//if (vscroll.mc.visible) vscroll.scroll(ROOM_WID*50);
//
			//case flash.ui.Keyboard.PAGE_UP	:
				//if (vscroll.mc.visible) vscroll.scroll(-ROOM_WID*3);
			//case flash.ui.Keyboard.PAGE_DOWN :
				//if (vscroll.mc.visible) vscroll.scroll(ROOM_WID*3);
//
			//case flash.ui.Keyboard.UP	:
				//if (vscroll.mc.visible) vscroll.scroll(-ROOM_WID);
			//case flash.ui.Keyboard.DOWN :
				//if (vscroll.mc.visible) vscroll.scroll(ROOM_WID);
				//
			//case flash.ui.Keyboard.LEFT	:
				//if (hscroll.mc.visible) hscroll.scroll(-ROOM_WID);
			//case flash.ui.Keyboard.RIGHT :
				//if (hscroll.mc.visible) hscroll.scroll(ROOM_WID);
				
		}
	}
	
	function onMouseWheel(e:flash.events.MouseEvent) {
		var dir = if (e.delta<0) 1 else -1;
	}
	
	function onMouseDown(e:flash.events.MouseEvent) {
		fl_cancelClick = false;
		dragTime = 0;
		dragPt = new flash.geom.Point(root.mouseX, root.mouseY);
	}
	
	function onMouseUp(e:flash.events.MouseEvent) {
		if ( !isDragging() && pending!=null && Type.enumIndex(pending)==Type.enumIndex(PA_PlaceDeco(null)) )
			validateDeco();
		if (isDragging())
			if ( pending!=null )
				setCursor("target",true);
			else
				setCursor(true);
		dragPt = null;
		resetQuality();
	}
	
	function onMouseMove(e:flash.events.MouseEvent) {
		if (dragPt!=null) {
			dragTime++;
			if (dragTime>=7)
				fl_cancelClick = true;
			if (dragTime>=4) {
				if(dragTime==4)
					setCursor("scroll",true);
				root.stage.quality = flash.display.StageQuality.LOW;
				var mouse = new flash.geom.Point(root.mouseX, root.mouseY);
				var speed = 1.3;
				scroller.x += (mouse.x-dragPt.x)*speed;
				scroller.y += (mouse.y-dragPt.y)*speed;
				limitScroller();
				dragPt = mouse;
			}
		}
	}
	
	inline function isDragging() {
		return dragPt!=null && dragTime>=4;
	}
	
	inline function limitScroller() {
		var xMax = Std.int( (4+hotel._width)*Game.ROOM_WID - Game.WID );
		scroller.x = Std.int(scroller.x);
		scroller.y = Std.int(scroller.y);
		if (scroller.x>xMax)
			scroller.x = xMax;
		if (scroller.x<-200)
			scroller.x = -200;
			
		var yMax = (2+hotel._floors)*Game.FLOOR_HEI-Game.HEI;
		if (scroller.y>yMax)
			scroller.y = yMax;
		if (scroller.y<0)
			scroller.y = 0;
	}
	
	function onMouseClick(e:flash.events.MouseEvent) {
		if (fl_cancelClick) {
			e.stopPropagation();
			fl_cancelClick = false;
		}
	}
	
	public function applyWheelDelta(d:Int) {
		var dir = if (d<0) 1 else -1;
		//vscroll.scroll(dir*FLOOR_HEI*1.5);
		scroller.y-=dir*FLOOR_HEI*2;
		limitScroller();
	}


	function onClickItem(it:_Item) {
		//it.mc.filters = [ new flash.filters.GlowFilter(0xffffff,1,2,2,10) ];
		if (it==_RANDDECO)
			sendAction( P_USE_ITEM(0,0,it) );
		else
			setPending( PA_UseItem(it) );
	}
	
	function onClickStaff(fs:FlashStaff) {
		if (fs.data._roomId != null)
			return;
			
		setPending( PA_SendStaff(fs) );
	}
	
	function getStaff(r:_Room) {
		for (s in fstaff)
			if (s.data._roomId!=null && s.data._roomId==r._id)
				return s;
		return null;
	}
	
	function getStaffList(r:_Room) {
		var list = new List();
		for (s in fstaff)
			if (s.data._roomId!=null && s.data._roomId==r._id)
				list.add(s);
		return list;
	}
	
	function getCoords(r:_Room) : HPoint {
		for (floor in 0...hotel._rooms.length)
			for (x in 0...hotel._rooms[floor].length)
				if ( hotel._rooms[floor][x] == r )
					return { floor:floor, x:x };
		return null;
	}
	
	function getFlashRoomAt(f, x) {
		for (fr in frooms)
			if (fr.floor==f && fr.x==x)
				return fr;
		//throw "unknown room @ f="+f+" x="+x;
		return null;
	}
	
	function getClientInQueue(cid:Int) {
		for (c in queue)
			if (c.data._id == cid)
				return c;
		return null;
	}
	
	//function getClientRoom(cid:Int) {
		//for (r in rooms)
			//if ( r.data.client!=null && r.data.client.id == cid )
				//return r;
		//return null;
	//}
	
	function onClickClient(c:FlashClient) {
		if (fl_spectator)
			return;
			
		var fl_reply = pending==null || switch(pending) {
			case PA_AddClient(pc) :
				if (pc==c) false else true;
			default : true;
		}
		
		// swap de client dans la file
		if ( pending!=null)
			switch(pending) {
				case PA_AddClient(pc) :
					if (pc!=c) {
						clearPending();
						sendAction( P_SWAP_QUEUE(pc.data._id, c.data._id) );
						return;
					}
				default :
			}
		
		if (fl_reply)
			bubble( c.mc, new flash.geom.Point(15,-75), TG.get("ClientClickReply") );
			
		setPending( PA_AddClient(c) );
	}
	
	function paragraph(s:String, ?className:String) {
		if (className != null)
			return "<p class='"+className+"'>"+s+"</p>";
		else
			return "<p>"+s+"</p>";
	}
	
	function div(s:String, className:String) {
		return "<div class='"+className+"'>"+s+"</div>";
	}
	
	function onOverItem(mc:MC, item:_Item) {
		mc.parent.setChildIndex(mc, mc.parent.numChildren-1);
		mc.filters = [ new flash.filters.GlowFilter(0xffffff,1,2,2 ,100, 1,true) ];
		var tpl = new haxe.Template(haxe.Resource.getString(LANG+".itemTip.mtt"));
		var html = tpl.execute({
			_item	: T.getItemText(item),
			_icon	: Std.string(item).toLowerCase().substr(1),
		});
		try js.api.print.call(["item", html]) catch (e:Dynamic) {throw e; }
	}
	
	function onOutItem(mc:MC) {
		mc.filters = [];
		try js.api.clear.call([]) catch (e:String) {}
	}
	
	function onOverClient(fc:FlashClient) {
		var c = fc.data;
		if ( c ==null )
			return;
		// side
		if(pending==null)
			fc.clientMc.filters = [ new flash.filters.GlowFilter(0xffffff, 1, 3, 3, 3), getDropShadow() ];
		try js.api.print.call(["client", getClientTip(c)]) catch (e:String) {}
	}

	function onOutClient(fc:FlashClient) {
		clearTip();
		setCursor();
		if ( pending == null )
			fc.clientMc.filters = getClientFilters(fc.data);
		try js.api.clear.call([]) catch (e:String) {}
	}
	
	function clearCursor() {
		fl_stickyCursor = false;
		setCursor();
	}
	
	function setCursor(?frame:String, ?fl_sticky=false) {
		if (fl_stickyCursor && !fl_sticky)
			return;

		if(cursor!=null)
			cursor.parent.removeChild(cursor);
		cursor = null;
		
		if (frame==null)
			flash.ui.Mouse.show();
		else {
			//if (fl_spectator)
				//return;
			fl_stickyCursor = fl_sticky;
			cursor = new interf.Cursor();
			if (!cursor.hasFrame(frame))
				throw "unknown cursor "+frame;
			cursor.gotoAndStop(frame);
			cursor.filters = [
				new flash.filters.DropShadowFilter(8,70, 0x0,0.5, 3,3),
			];
			cursor.disableMouse();
			flash.ui.Mouse.hide();
			dm.add(cursor, DP_CURSOR);
			updateCursor();
		}
	}
	
	function updateCursor() {
		if (cursor==null)
			return;
		cursor.x = root.mouseX+3;
		cursor.y = root.mouseY+3;
	}
	
	
	function notify(x,y, str:String) {
		clearNotice();
		notice = new interf.Pop();
		dm.add(notice, DP_INTERF);
		notice.x = x;
		notice.y = y;
		notice.disableMouse();
		notice.field.x = 3;
		notice.field.y = 3;
		notice.field.styleSheet = CSS;
		notice.field.htmlText = str;
		notice.field.width = 200;
		notice.bg.width = notice.field.width + 6;
		notice.bg.height = notice.field.textHeight + 6;
		notice.bg.height = notice.field.textHeight + 6;
		notice.bg.transform.colorTransform = Color.getSimpleCT(0xD04B2B, 0.8);
	}
	
	function clearNotice() {
		if(notice!=null) {
			notice.parent.removeChild(notice);
			notice = null;
		}
	}
	
	
	function clearPop(?fl_fast=false) {
		if (popUp != null) {
			if (fl_fast)
				mask.parent.removeChild(mask);
			else {
				var mc = mask;
				mc.disableMouse();
				TW.create(mc, "alpha", 0, TEaseOut, DateTools.seconds(0.5)).onEnd = function() {
					mc.parent.removeChild(mc);
				}
			}
			
			popUp.parent.removeChild(popUp);
			popUp = null;
			mask = null;
		}
	}
	
	//function nextPop() {
		//clearPop(true);
		//if (popQueue.length > 0)
			//pop( popQueue.pop() );
	//}
	
	function onClickPop() {
		clearPop();
		unlockGame();
	}
	
	function pop(msg:String, ?col:Int) {
		if (popUp != null) {
			popQueue.add(msg);
			return;
		}
		
		msg = StringTools.replace(msg, " !", " !"); // non-breaking space
		
		clearTip();
		clearMenu();
		clearPop();
		
		lockGame();

		popUp = new interf.Pop();
		popUp.field.styleSheet = CSS;
		popUp.field.htmlText = msg;
		popUp.field.width = Math.max(250, popUp.field.textWidth+5);
		popUp.field.height = popUp.field.textHeight+7;
		popUp.bg.width = popUp.field.width+10;
		popUp.bg.height = popUp.field.height+3;
		popUp.x = Std.int(WID*0.5 - popUp.width*0.5);
		popUp.y = Std.int(HEI*0.5 - popUp.height*0.5);
		if (col != null)
			popUp.bg.transform.colorTransform = Color.getSimpleCT(col, 0.8);
		dm.add(popUp, DP_TOP);

		popUp.disableMouse();
		mask.handCursor(true);
		mask.onClick(onClickPop);
	}
	
	function detachMask() {
		if (mask!=null)
			mask.parent.removeChild(mask);
		mask = null;
	}
	
	function attachMask() {
		detachMask();
		mask = new interf.Mask();
		dm.add(mask, DP_TOP);
		mask.width = WID;
		mask.height = HEI;
		mask.alpha = 0.6;
	}
	
	
	function confirm(msg:String, okcb:Void->Void) {
		clearTip();
		clearMenu();
		clearPop();
		clearConfirm();
		
		attachMask();
		
		confBox = new interf.Pop();
		dm.add(confBox, DP_TOP);
		confBox.field.styleSheet = CSS;
		confBox.field.htmlText = msg;
		confBox.field.width = 350;
		confBox.field.height = confBox.field.textHeight+7 + 30;
		confBox.bg.width = confBox.field.width+10;
		confBox.bg.height = confBox.field.height+3;
		confBox.x = Std.int(WID*0.5 - confBox.width*0.5);
		confBox.y = Std.int(HEI*0.5 - confBox.height*0.5);
		
		var ct = Color.getSimpleCT(0xBD6F17);
		
		// ok
		var bt = new interf.Button();
		confBox.addChild(bt);
		bt.field.text = T.get.Confirm;
		bt.field.width = confBox.width*0.4;
		bt.field.mouseEnabled = false;
		bt.bg.width = bt.field.width;
		bt.bg.transform.colorTransform = ct;
		bt.x = 5;
		bt.y = confBox.height-5 - bt.height;
		bt.onClick( function() {
			ME.clearConfirm();
			okcb();
		});
		bt.onOver( function() { bt.filters = [new flash.filters.GlowFilter(0xffffff,1,2,2,10) ]; } );
		bt.onOut( function() { bt.filters = []; } );
		bt.handCursor(true);
		
		// cancel
		var bt = new interf.Button();
		confBox.addChild(bt);
		bt.field.text = T.get.Cancel;
		bt.field.width = confBox.width*0.4;
		bt.field.mouseEnabled = false;
		bt.bg.width = bt.field.width;
		bt.bg.transform.colorTransform = ct;
		bt.x = confBox.width - 5 - bt.width;
		bt.y = confBox.height-5 - bt.height;
		bt.onClick( cancelConfirm );
		bt.onOver( function() { bt.filters = [new flash.filters.GlowFilter(0xffffff,1,2,2,10) ]; } );
		bt.onOut( function() { bt.filters = []; } );
		bt.handCursor(true);
	}
	
	function cancelConfirm() {
		clearPending();
		clearConfirm();
	}
	
	function clearConfirm() {
		if (confBox==null)
			return;
		mask.parent.removeChild(mask);
		confBox.parent.removeChild(confBox);
		confBox = null;
		mask = null;
	}
	
	
	function popString(str:String, col:Int, ?icon:String, x:Float, y:Float) {
		// décalage pour limiter les overlaps
		for (mc in pnumberList)
			if ( Math.abs(mc.x-x)<=20 && Math.abs(mc.y-y)<=20 )
				y-=17;
		
		var mc = new interf.PopNumber();
		scroller.addChild(mc);
		mc.x = x;
		mc.y = y;
		mc.sum.text = str;
		mc.sum.textColor = col;
		mc.bg.width = Math.ceil(mc.sum.textWidth+5);
		if (icon==null) {
			// pas d'icone
			mc.icon.visible = false;
			mc.icon.stop();
		}
		else {
			// icone
			mc.icon.gotoAndStop(icon);
			mc.sum.x-=10;
			mc.icon.x = Std.int(mc.sum.textWidth*0.5 - 6);
			mc.bg.width += 26;
		}
		mc.filters = [
			new flash.filters.GlowFilter(0x391615,1, 2,2, 4),
			getDropShadow(),
		];
		mc.disableMouse();
		
		pnumberList.add(mc);
		
		TW.create(mc, "y", mc.y-7, TJump, DateTools.seconds(0.5)).fl_pixel = true;
		TW.create(mc, "alpha", 0, TBurnOut, DateTools.seconds(4.5)).onEnd = function() {
			ME.pnumberList.remove(mc);
			mc.parent.removeChild(mc);
		}
	}
	
	function popNumber(n:Int, ?icon:String, x:Float,y:Float) {
		var str = (if (n>0) "+" else "") + n;
		var col =
			if (icon=="fame")
				0xEE5911;
			else
				if (n>0) 0x638000 else 0x950000;
		popString(str, col, icon, x,y);
	}
	
	
	function createTip(?str:String, ?inner:SPR) {
		//if (fl_spectator)
			//return;
		if (inner==null && str==null)
			return;

		clearTip();

		var margin = 5; // marge
		tip = new interf.Tip();
		tip.mouseChildren = false;
		tip.mouseEnabled = false;
		dm.add(tip, DP_INTERF);

		if (inner==null && str != null) {
			// contenu texte
			var tf = tip.field;
			tf.x = margin;
			tf.y = 0;
			tf.styleSheet = CSS;
			tf.htmlText = str;
			tf.width = Math.min(300, Math.max(200,tf.textWidth+5));
			tf.height = tf.textHeight+5;
			tip.bg.width = tf.width + margin*2;
			tip.bg.height = tf.height;
		} else {
			// contenu sprite
			tip.bg.width = inner.width + margin*2;
			tip.addChild(inner);
			inner.x = margin;
			inner.y = margin;
		}
		
		// fade-in décalé
		tip.alpha = 0;
		var me =  this;
		haxe.Timer.delay(function() {
			if(me.tip!=null)
				TW.create(me.tip, "alpha", 1, TEaseOut, DateTools.seconds(0.2));
		}, Std.int(DateTools.seconds(0.05)));
		
		//tip.filters = [
			//new flash.filters.GlowFilter(0x0,0.7, 2,2,100),
			//new flash.filters.DropShadowFilter(5, 45, 0x0, 0.3, 4, 4),
		//];

		//tip.addChild(tf);
		updateTip();
	}
	
	function updateTip() {
		if (tip != null) {
			tip.x = root.mouseX +28;
			tip.y = root.mouseY +15 ;
			if (tip.y+tip.height > HEI)
				tip.y = root.mouseY - tip.height - 20;
			if (tip.x+tip.width > WID)
				tip.x = root.mouseX - tip.width-20;
			tip.x = Std.int(tip.x);
			tip.y = Std.int(tip.y);
			//tip.x = WID - tip.width - 5;
			//tip.y = HEI - tip.height - 5;
		}
	}

	function clearTip() {
		if ( tip != null ) {
			tip.parent.removeChild(tip);
			tip = null;
		}
	}
	
	function pointAt(x:Float,y:Float, str:String, ?delay=0) {
		var mc = new interf.Pop();
		dm.add(mc, DP_INTERF);
		mc.disableMouse();
		mc.field.x = 3;
		mc.field.y = 3;
		mc.field.styleSheet = CSS;
		mc.field.htmlText = str;
		mc.field.width = 600;
		mc.field.width = mc.field.textWidth+6;
		mc.bg.width = mc.field.width + 6;
		mc.bg.height = mc.field.textHeight + 12;
		mc.bg.transform.colorTransform = Color.getSimpleCT(0xD04B2B, 0.8);
		mc.x = Math.max(0, Math.min(WID-mc.width, Std.int( x - mc.width*0.5 )) );
		mc.y = y-50;
		mc.alpha = 0;
		
		var arrow = new interf.Arrow();
		dm.add(arrow, DP_INTERF);
		arrow.rotation = -90;
		arrow.x = x;
		arrow.y = y+20;
		arrow.alpha = 0;
		TW.create(arrow, "alpha", 1, TEaseIn, delay+500);

		haxe.Timer.delay( function() {
			TW.create(mc, "alpha", 1, TEaseIn, 500);
			TW.create(mc, "y", y+20, TElasticEnd, 500);
			haxe.Timer.delay( function() {
				var anim = TW.create(mc, "alpha", 0, TEaseIn, 1500);
				anim.onUpdateT = function(t) { arrow.alpha = 1-t; }
				anim.onEnd = function() {
					arrow.parent.removeChild(arrow);
					mc.parent.removeChild(mc);
				}
			}, 1500);
		}, delay);
	}
	
	function clearMenu() {
		if(menu!=null)
			menu.parent.removeChild(menu);
		menu = null;
		//for (mc in menuList)
			//mc.parent.removeChild(mc);
		//menuList = new List();
	}
	
	function addMenuButton(label:String, icon:Null<flash.display.DisplayObject>, col:Int, ?help:String, cb:Void->Void, y) {
		var mc = new interf.Button();
		mc.y = y;
		mc.field.text = label;
		mc.field.textColor = 0xffffff;
		mc.field.filters = [
			new flash.filters.DropShadowFilter(1,90,0x0,0.5,1,1),
		];
		mc.bg.transform.colorTransform = Color.getSimpleCT(col);
		mc.field.mouseEnabled = false;
		mc.filters = [ new flash.filters.GlowFilter(0x414141,1,2,2,100) ];

		if (icon!=null)
			mc.addChild(icon);
		mc.field.x+=18;
		
		var me = this;
		mc.bg.onOver( function() {
			mc.filters = [ new flash.filters.GlowFilter(0xffffff, 1, 2, 2, 100) ];
			if (help != null)
				me.createTip(help);
		});
		mc.bg.onOut( function() {
			mc.filters = [ new flash.filters.GlowFilter(0x414141, 1, 2, 2, 100) ];
			if (help != null)
				me.clearTip();
		});
		
		if ( cb != null ) {
			mc.bg.onClick(cb);
			mc.bg.handCursor(true);
		}
		menu.addChild(mc);
		return mc;
	}
	
	function attachMenu(items: List<MenuElement> , bx, by) {
		clearMenu();
		clearPop(true);
		clearTip();
		setCursor();
		setBuildMode(false);
		updateAutoRefresh();
		
		menu = new SPR();
		
		var y = 0.0;
		var list = new List();
		for (it in items) {
			var me = this;
			var cb = function() {
				me.clearMenu();
				it.cb();
			}
			var c = if (it.col==null || it.col==0) DEFAULT_MENU_COLOR else it.col;
			var mc = addMenuButton(it.label, it.icon, c, it.help, cb, y);
			y += mc.bg.height+2;
			list.add(mc);
		}
		
		list.add( addMenuButton("[ "+T.get.Cancel+" ]", null, 0x222222, clearMenu, y) );
		
		// taille des boutons
		var max = 0.0;
		for (mc in list)
			max = Math.max(mc.field.x+mc.field.textWidth, max);
		for (mc in list) {
			mc.field.width = max + 5;
			mc.bg.width = mc.field.width+5;
		}

		// placement
		menu.x = Math.min(bx, WID-4-menu.width);
		menu.y = Math.min(by, HEI-4-menu.height);
		menu.filters = [
			new flash.filters.GlowFilter(0xE6E6E6,0.8,3,3,100),
			new flash.filters.GlowFilter(0x444444,1,2,2,100),
			new flash.filters.DropShadowFilter(8,60,0x0,0.6,4,4),
		];

		// affichage
		dm.add(menu, DP_INTERF);
	}
	
	function setBuildMode(b:Bool) {
		if (b==fl_buildMode)
			return;
		if (fl_spectator)
			b = false;
		fl_buildMode = b;
		var txt = paragraph(T.format.EnlargeCost({_money:initData._extCost, _currency:T.get.Currency}), "title");
		for (mc in extButtons) {
			mc.visible = fl_buildMode;
			mc.onOver( callback(createTip, txt, null) );
			mc.onOut( clearTip );
		}
		
		queueCont.alpha = if(fl_buildMode) 0.2 else 1;
		if ( fl_buildMode )
			queueCont.disableMouse();
		else
			queueCont.enableMouse();
		
		if(!fl_spectator)
			if (fl_buildMode) {
				notify(buildModeButton.x, buildModeButton.y+35, T.get.EnlargeButtonNotice);
				buildModeButton.filters = getGlow();
				clearPending();
				clearMenu();
			}
			else {
				clearNotice();
				buildModeButton.filters = [];
			}
	}
	
	function toggleBuildMode() {
		setBuildMode(!fl_buildMode);
	}
	
	function setDecoMode(b:Bool) {
		if (fl_spectator)
			b = false;
		fl_decoMode = b;
		
		if (!fl_spectator) {
			if (fl_decoMode) {
				oldDeco = null;
				decoModeButton.filters = getGlow();
				buildModeButton.visible = false;
			}
			else {
				if ( pending!=null && oldDeco!=null ) {
					// annulation du placement en cours
					switch(pending) {
						case PA_PlaceDeco(d) :
							d._x = oldDeco._x;
							d._y = oldDeco._y;
							d._floor = oldDeco._floor;
						default :
					}
				}
				buildModeButton.visible = hotel.canUseBuildMode();
				decoModeButton.filters = [];
			}
		}
		clearPending();
		clearMenu();
		attachHotel();
		if (fl_decoMode)
			notify(decoModeButton.x, decoModeButton.y+35, T.get.DecoButtonNotice);
		else
			clearNotice();

	}
	
	function toggleDecoMode() {
		setDecoMode(!fl_decoMode);
	}
	
	function toMC(m:MC) : MC {
		return m;
	}
	
	function makeTexture(mc:MC, ?frame=1, ?fl_transp=false ) {
		mc.gotoAndStop(frame);
		var bmp = new BD(Std.int(mc.width), Std.int(mc.height), fl_transp, 0xff0000);
		bmp.draw(mc);
		return bmp;
	}
	
	function colorize(bmp:BD, col:Int) {
		var gray = bmp.clone();
		bmp.fillRect(bmp.rect, col);
		bmp.draw(gray, flash.display.BlendMode.OVERLAY);
		gray.dispose();
	}
	
	function paintRect(g:flash.display.Graphics, bmp:BD, x, y, w, h, ?fl_dispose=true ) {
		var matrix = new flash.geom.Matrix();
		matrix.translate(x, y);
		g.beginBitmapFill(bmp, matrix, true, true);
		g.drawRect(x,y,w,h);
		g.endFill();
		//if (fl_dispose)
			//bmp.dispose();
	}
	
	inline function getAngle(pt1:PT, pt2:PT) {
		return Math.atan2(pt2.y-pt1.y, pt2.x-pt1.x) * 180/Math.PI;
	}
	
	inline function distance(pt1:PT, pt2:PT) {
		return Math.sqrt( Math.pow(pt1.x-pt2.x, 2) + Math.pow(pt1.y-pt2.y, 2) );
	}
	
	function getRandomWallScen(rseed:mt.Rand, x,y) {
		var mc : MC = null;
		if ( rseed.random(100) < 60 )
			mc = new scen.PaintingSmall();
		else
			mc = new scen.PaintingLarge();
		mc.gotoAndStop(rseed.random(mc.totalFrames + 1));
		mc.rotation = rseed.random(15) - 7;
		mc.x = Std.int(x);
		mc.y = Std.int(y);
		mc.disableMouse();
		return mc;
	}
	
	function getDropShadow() : flash.filters.BitmapFilter {
		return new flash.filters.DropShadowFilter(8,0,SHADOW_COLOR,0.6, 1,1);
	}
	
	function getClientFilters(c:_Client) : Array<flash.filters.BitmapFilter> {
		return
			if ( c.isUnstable() )
				[
					new flash.filters.GlowFilter(0xFF825E,1,2,2,10),
					new flash.filters.GlowFilter(0xff0000,1,8,8,2),
					getDropShadow(),
				];
			else if (c._vip)
				[
					new flash.filters.GlowFilter(0xFFFF00,1,2,2,5),
					new flash.filters.GlowFilter(0xFFA600,1,4,4,1),
					new flash.filters.GlowFilter(0xC62700,1,8,8,1),
					getDropShadow()
				];
			else
				[getDropShadow()];
	}
	
	function getGlow(?fl_inner=false) {
		return cast [
			new flash.filters.GlowFilter(0xFFE94F,1,3,3,10, 1, fl_inner),
			new flash.filters.GlowFilter(0xFEBF4B,0.8,16,16,2, 1, fl_inner),
		];
	}
	
	
	function attachSpecialRoom(seed:Int, fmc:SPR, rmc:SPR, fr:FlashRoom) {
		var room = fr.data;
		var x = fr.x;
		var rseed = new mt.Rand(seed+x);
		
		// porte
		var door = new scen.ShopDoor();
		rmc.addChild(door);
		var name = getRoomName(fr).split(" ")[0]; // troncature sur Espace
		door.field.text = name;
		door.x = 15 + rseed.random(15);
		door.y = FLOOR_HEI-GROUND_HEI;
		door.disableMouse();
		
		// client dedans
		if (room._clientId!=null && !fl_decoMode ) {
			var fclient = attachClient(getClient(room._clientId), false);
			var cmc = fclient.mc;
			door.inside.addChild(cmc);
			cmc.x = 20 + Std.random(20);
			cmc.y = 87;
			cmc.scaleX = 0.8;
			cmc.scaleY = cmc.scaleX;
			var ct = new flash.geom.ColorTransform();
			ct.color = 0x335E88;
			ct.alphaOffset = -160;
			cmc.transform.colorTransform = ct;
			fclient.x = cmc.x;
			fclient.y = cmc.y;
			fr.fclient = fclient;
			//cmc.visible = ( fclient.data.activity == _TR_BEDROOM ); // pas dans sa chambre
			if(fclient.data._vip) {
				var icon = new interf.Icon();
				icon.gotoAndStop("fame");
				icon.x = door.x + 15;
				icon.y = door.y - 40;
				rmc.addChild(icon);
				var icon = new interf.Icon();
				icon.gotoAndStop("fame");
				icon.x = door.x + 55;
				icon.y = door.y - 40;
				rmc.addChild(icon);
			}
		}
		
		
		switch(fr.data._type) {
			case _TR_RESTAURANT :
				var mc = new scen.Sign();
				rmc.addChild(mc);
				mc.gotoAndStop(1);
				mc.filters = [getDropShadow()];
				mc.x = 15;
				mc.y = FLOOR_HEI-GROUND_HEI;
			case _TR_POOL :
				var mc = new scen.WaterDoor();
				rmc.addChild(mc);
				mc.gotoAndStop(1);
				mc.x = door.x-13;
				mc.y = FLOOR_HEI-GROUND_HEI;
			case _TR_FURNACE :
				var mc = new scen.FireDoor();
				rmc.addChild(mc);
				mc.gotoAndStop(1);
				mc.x = door.x-13;
				mc.y = FLOOR_HEI-GROUND_HEI;
			case _TR_DISCO :
				var mc = new scen.Guard();
				rmc.addChild(mc);
				mc.gotoAndStop(1);
				mc.filters = [getDropShadow()];
				if(rseed.random(2)==0)
					mc.x = door.x - rseed.random(15);
				else
					mc.x = door.x + 50 + rseed.random(10);
				mc.y = FLOOR_HEI-GROUND_HEI;
			case _TR_BIN :
				var mc = new scen.Trash();
				rmc.addChild(mc);
				mc.gotoAndStop(1);
				mc.filters = [getDropShadow()];
				mc.x = 15;
				mc.y = FLOOR_HEI-GROUND_HEI;
				var mc = new scen.Trash();
				rmc.addChild(mc);
				mc.gotoAndStop(2);
				mc.filters = [getDropShadow()];
				mc.x = 50;
				mc.y = FLOOR_HEI-GROUND_HEI;
			default :
		}
		
		door.inside.mask = door.dmask;
	}
	
	function attachRoom(seed:Int, fmc:SPR, rmc:SPR, fr:FlashRoom) {
		var room = fr.data;
		var x = fr.x;
		var rseed = new mt.Rand(seed+x);
		if (fl_decoMode)
			rmc.disableMouse();
		else
			rmc.handCursor(true);
		
		// dégâts
		if( room.isDamaged() ) {
			var mc = new scen.Dirty();
			rmc.addChild(mc);
			mc.x = 0;
			mc.y = FLOOR_HEI-GROUND_HEI;
			//mc.alpha = Math.max( 0.5, 1-room._life/_Room.MAX_LIFE );
			mc.gotoAndStop( _Room.MAX_LIFE-room._life );
		}

		var rseed = new mt.Rand(seed+x);
		
		switch(room._type) {
			case _TR_BEDROOM :
				var offset = rseed.random(10);
				// porte
				var door = new scen.Door();
				door.door.gotoAndStop( if (room._clientId != null) 1 else 2 );
				door.outline.gotoAndStop(room._level+1);
				rmc.addChild(door);
				door.x = 17 + offset;
				door.y = FLOOR_HEI - GROUND_HEI;
				door.disableMouse();
				if ( room._underConstruction != null ) {
					var block = new scen.Blocked();
					rmc.addChild(block);
					block.x = door.x-2;
					block.y = door.y-5;
					block.disableMouse();
				}
					

				// fenêtre
				var win = new scen.Window();
				win.rotation = rseed.random(5) * (rseed.random(2)*2-1);
				rmc.addChild(win);
				win.gotoAndStop(1);
				win.x = 65 + offset;
				win.y = 22 + rseed.random(5)*(rseed.random(2)*2-1);
				win.inside.mask = win.wmask;
				win.inside.gotoAndStop(1);
				win.disableMouse();
				
				// objet de déco au mur
				//if (rseed.random(100) < 50 && x<hotel._width-1 && hotel._rooms[fr.floor][x+1]._type!=_TR_VOID)
					//rmc.addChild( getRandomWallScen(rseed, ROOM_WID / 2 + 45 + rseed.random(7), 20 ) );
				
				// objet de déco au sol
				//if ( room._underConstruction==null && rseed.random(100)<50 ) {
					//var mc = new scen.Plant();
					//mc.gotoAndStop(rseed.random(mc.totalFrames + 1));
					//if (rseed.random(100) < 33)
						//mc.x = 53;
					//else
						//mc.x = ROOM_WID-30-rseed.random(10);
					//mc.y = FLOOR_HEI - GROUND_HEI;
					//rmc.addChild(mc);
					//mc.filters = getDropShadow();
					//mc.disableMouse();
				//}
				
				// objet installé dans la room (équipement)
				var ix = 0;
				for(item in room._equipments) {
					var mc = new SPR();
					mc.addChild( new flash.display.Bitmap( iconsHash.get(Std.string(item)) ) );
					mc.x = Std.int(door.x+door.width*0.5 - mc.width*0.5 -4) + 8 + ix*17 - room._equipments.length*8;
					mc.y = Std.int(door.y-door.height-mc.height+2);
					mc.rotation = -fmc.rotation;
					//mc.disableMouse();
					var td = T.getItemText(item);
					mc.onOver( function() {
						ME.createTip( ME.paragraph(td._name, "title") + ME.paragraph(td._rule, "rule") );
						mc.filters = [ new flash.filters.GlowFilter(0xffffff, 1, 3, 3, 4) ];
					});
					mc.onOut( function() {
						ME.clearTip();
						mc.filters = [];
					});
					rmc.addChild(mc);
					ix++;
				}

				// client à l'intérieur
				if (room._clientId != null && !fl_decoMode) {
					win.filters = [ new flash.filters.GlowFilter(0xFFC600,0.7, 32,32) ]; // halo de lumière
					var fclient = attachClient(getClient(room._clientId), false);
					var cmc = fclient.mc;
					win.inside.addChild(cmc);
					var h = Math.min(_Client.MAX_HAPPYNESS, Math.max(0,fclient.data._happyness));
					var frame = Math.round((1-h/10) * 3);
					win.inside.gotoAndStop(2 + frame);
					cmc.x = 20 + rseed.random(20);
					if ( fclient.data._type==_MF_BUSINESS )
						cmc.y = 55 + rseed.random(10);
					else
						cmc.y = 65 + rseed.random(10);
					fclient.clientMc.filters = [];
					if (fl_spectator)
						cmc.scaleX*=Std.random(2)*2-1;
					cmc.alpha = 0.8;
					cmc.filters = getClientFilters(fclient.data);
					fclient.x = cmc.x;
					fclient.y = cmc.y;
					fr.fclient = fclient;
					cmc.visible = ( fclient.data._activity==null ); // pas dans sa chambre
					
					// un Service est en attente
					if ( date.getTime() >= DateTools.delta(fclient.data._serviceEnd, -Const.SERVICE_VISIBILITY).getTime() ) {
						var mc : MC = null;
						switch(fclient.data._serviceType) {
							case ServiceAlcool	: mc = new service.Alcool();
							case ServiceFridge	: mc = new service.Fridge();
							case ServiceShoe	: mc = new service.Shoe();
							case ServiceWash	: mc = new service.Wash();
						};
						mc.x = door.x+15;
						mc.y = FLOOR_HEI-GROUND_HEI;
						mc.disableMouse();
						mc.filters = [ new flash.filters.GlowFilter(0xFFFF00,1,2,2,10), new flash.filters.GlowFilter(0xF72D09,1,16,16,2) ];
						rmc.addChild(mc);
					}
					
					// VIP
					if ( fclient.data._vip ) {
						var imc = new interf.Icon();
						imc.gotoAndStop("fame");
						imc.x = Std.int( door.x+14 );
						imc.y = Std.int( door.y - 50 );
						imc.disableMouse();
						rmc.addChild(imc);
					}
					if ( fclient.data.isUnstable() ) {
						var imc = new interf.Icon();
						imc.gotoAndStop("warning");
						imc.x = Std.int( door.x+14 );
						imc.y = Std.int( door.y - 50 );
						imc.filters = [ new flash.filters.GlowFilter(0xff4422, 0.8, 4,4,2) ];
						imc.disableMouse();
						rmc.addChild(imc);
					}
				}
				
				// staff
				var s = getStaff(room);
				if (s!=null && !fl_decoMode) {
					win.inside.addChild(s.mc);

					s.mc.x = 10 + Std.random(20);
					s.mc.y = 65 + Std.random(15);
					if (fl_spectator)
						s.mc.scaleX*=Std.random(2)*2-1;
					if (room._clientId != null) {
						// aux petits soins du client
						s.mc.gotoAndStop(2);
						s.mc.item.gotoAndStop(rseed.random(s.mc.item.totalFrames)+1);
						s.mc.item.visible = true;
					}
					else {
						// réparations
						s.mc.gotoAndStop(3);
						s.mc.item.visible = false;
						win.inside.gotoAndStop(3);
					}
						
				}
					
					
			case _TR_LOBBY :
				// déco murale
				//if (rseed.random(100) < 50)
					//rmc.addChild( getRandomWallScen(rseed, 10 + rseed.random(40), 30) );
					
				// panneau
				var mc = new scen.LobbyPanel();
				rmc.addChild(mc);
				mc.x = 35;
				mc.y = 65;
				mc.disableMouse();
				mc.gotoAndStop(room._level+1);

				// horloge
				if (curClock==null && room._underConstruction==null) {
					curClock = new scen.Clock();
					rmc.addChild(curClock);
					curClock.x = 50;
					curClock.disableMouse();
					curClock.counter.textColor = 0x00D2FF;
					curClock.filters = [getDropShadow()];
					updateTime();
				}
				
				// staffs
				var n = 0;
				var slist = getStaffList(room);
				var wid = Std.int( Math.min(25, 112/slist.length) );
				for (s in slist) {
					rmc.addChild(s.mc);
					var x = if (slist.length<=2) 40 else if(slist.length<=4) 37 else 20;
					s.mc.x = Std.int(x+n*wid);
					s.mc.y = Std.int(FLOOR_HEI-GROUND_HEI) + rseed.random(3);
					s.mc.gotoAndStop(1);
					s.mc.item.visible = false;
					s.mc.scaleX = -1;
					n++;
					s.mc.filters = [getDropShadow()];
				}
				
			case _TR_NONE :
			case _TR_VOID :
			
			case _TR_SERV_WASH :
				var mc = new scen.WashMachine();
				rmc.addChild(mc);
				mc.x = 30 + rseed.random(60);
				mc.y = FLOOR_HEI-GROUND_HEI;
				mc.disableMouse();
				if (room._serviceEnd!=null)
					mc.gotoAndPlay(2+Std.random(8));
				else
					mc.gotoAndStop(1);
				//if (fl_spectator)
					//mc.stop();

			case _TR_SERV_SHOE :
				var mc = new scen.ShoeMachine();
				mc.filters = [getDropShadow()];
				rmc.addChild(mc);
				mc.x = 10 + rseed.random(60);
				mc.y = FLOOR_HEI-GROUND_HEI+1;
				mc.disableMouse();
				if (room._serviceEnd!=null)
					mc.gotoAndPlay(2+Std.random(8));
				else
					mc.gotoAndStop(1);
				//if (fl_spectator)
					//mc.stop();
					
			case _TR_SERV_FRIDGE :
				var mc = new scen.FridgeFiller();
				mc.filters = [getDropShadow()];
				rmc.addChild(mc);
				mc.x = 10 + rseed.random(60);
				mc.y = FLOOR_HEI-GROUND_HEI+1;
				mc.disableMouse();
				if (room._serviceEnd!=null)
					mc.gotoAndPlay(2+Std.random(8));
				else
					mc.gotoAndStop(1);
				//if (fl_spectator)
					//mc.stop();
				
			case _TR_SERV_ALCOOL :
				var mc = new scen.AlcoolMachine();
				rmc.addChild(mc);
				mc.filters = [getDropShadow()];
				mc.x = Range.makeInclusive(10,20).draw(rseed.random);
				mc.y = FLOOR_HEI-GROUND_HEI;
				mc.disableMouse();
				if (room._serviceEnd!=null)
					mc.gotoAndPlay(2+Std.random(8));
				else
					mc.gotoAndStop(1);
				//if (fl_spectator)
					//mc.stop();
					
			case _TR_LAB :
				var mc = new scen.Lab();
				rmc.addChild(mc);
				mc.x = Range.makeInclusive(24,50).draw(rseed.random);
				mc.y = FLOOR_HEI-GROUND_HEI;
				mc.disableMouse();
				if (room._serviceEnd!=null) {
					mc.gotoAndStop(2);
					mc.light1.gotoAndPlay(Std.random(15));
					mc.light2.gotoAndPlay(Std.random(15));
				}
				else {
					mc.gotoAndStop(1);
					mc.light1.stop();
					mc.light1.visible = false;
					mc.light2.stop();
					mc.light2.visible = false;
				}
				//if (fl_spectator)
					//mc.stop();
				mc.bar.scaleX = Math.min(1, room._life/Const.LAB_NEEDED_POINTS);
					
			default : // TODO autres rooms
				attachSpecialRoom(seed,fmc,rmc,fr);
		}
		
		// en travaux
		if ( room._underConstruction != null ) {
			// échelle
			if (rseed.random(100) < 50) {
				var mc = new scen.Construct();
				rmc.addChild(mc);
				mc.gotoAndStop(2);
				mc.x = rseed.random(10);
				mc.y = FLOOR_HEI-GROUND_HEI;
				mc.disableMouse();
			}
			// échaffaudage
			var mc = new scen.Construct();
			rmc.addChild(mc);
			mc.gotoAndStop(1);
			mc.x = 15+rseed.random(60);
			mc.y = FLOOR_HEI-GROUND_HEI;
			mc.filters = [getDropShadow()];
			mc.disableMouse();
			// monticule
			if (rseed.random(100)<40) {
				var mc = new scen.Construct();
				rmc.addChild(mc);
				mc.gotoAndStop( (rseed.random(100)<50?3:4) );
				mc.x = 10+rseed.random(80);
				mc.y = FLOOR_HEI-GROUND_HEI;
				mc.filters = [getDropShadow()];
				mc.disableMouse();
			}
		}
	}
	
	function attachFloorContent(seed:Int, fmc:SPR, floor:Int, rlist:Array<_Room>) {
		// rooms
		var x = 0;
		for (n in 0...rlist.length) {
			var fr = getFlashRoomAt(floor, n);
			if (fr.data._type==_TR_VOID)
				continue;
			var bx = x * ROOM_WID;
			var room = fr.data;
			var rmc = new SPR();
			fmc.addChild(rmc);
			rmc.x = Std.int(bx);
			rmc.y = Std.int(-FLOOR_HEI);
			var g = rmc.graphics;
			g.beginFill(0x0, 0); // zone de hit pour events souris
			g.drawRect(0, 0, ROOM_WID, FLOOR_HEI);
			g.endFill();
			rmc.onOver( callback(onOverRoom,fr) );
			rmc.onClick( callback(onClickRoom,fr) );
			rmc.onOut( onOutRoom );

			fr.mc = rmc;
			
			attachRoom(seed, fmc, rmc, fr);
			x++;
		}
		
		
		// déco premier plan
		if(fl_decoMode) {
			var fdeco = filterDecoList(hotel._deco, floor, false);
			attachDeco(fmc, fdeco);
		}
		var fdeco = filterDecoList(hotel._deco, floor, true);
		attachDeco(fmc, fdeco, true);

		// objets à ramasser
		for (n in 0...rlist.length) {
			var fr = getFlashRoomAt(floor, n);
			if (fr.data._type==_TR_VOID)
				continue;
			if ( fr.data._itemToTake != null ) {
				var mc = new SPR();
				mc.addChild( new flash.display.Bitmap( iconsHash.get(Std.string(fr.data._itemToTake)) ) );
				mc.x = fr.mc.x+40;
				mc.y = -GROUND_HEI-26;
				mc.rotation = -fmc.rotation;
				mc.filters = [
					new flash.filters.GlowFilter(0xFFFFB0,1,2,2,2),
					new flash.filters.GlowFilter(0xFFB13E,1,8,8,2),
					new flash.filters.GlowFilter(0xE85C00,1,32,32,3),
				];
				mc.disableMouse();
				droppedItems.add({mc:mc, y:mc.y, t:Std.random(400)/100});
				fmc.addChild(mc);
			}
		}
	}
	
	function createDecoSprite(d:DecoItem) {
		var mc = new SPR();
		switch(d._type) {
			case DecoPlantSmall	:
				var dmc = new scen.PlantSmall();
				dmc.gotoAndStop(d._frame);
				mc.addChildAt(dmc, 0);
			case DecoPlantLarge	:
				var dmc = new scen.PlantLarge();
				dmc.gotoAndStop(d._frame);
				mc.addChildAt(dmc,0);
			case DecoPaintSmall	:
				var dmc = new scen.PaintingSmall();
				dmc.gotoAndStop(d._frame);
				mc.addChildAt(dmc,0);
			case DecoLight	:
				var dmc = new scen.Light();
				dmc.gotoAndStop(d._frame);
				mc.addChildAt(dmc, 0);
			case DecoFurniture	:
				var dmc = new scen.Furniture();
				dmc.gotoAndStop(d._frame);
				mc.addChildAt(dmc,0);
			case DecoSofa :
				var dmc = new scen.Sofa();
				dmc.gotoAndStop(d._frame);
				mc.addChildAt(dmc, 0);
			case DecoDesk :
				var dmc = new scen.Desk();
				dmc.gotoAndStop(d._frame);
				mc.addChildAt(dmc, 0);
		}
		return mc;
	}
	
	function attachDeco(fmc:SPR, fdeco:List<DecoItem>, ?fl_shadow=false) {
		for (d in fdeco) {
			var mc = createDecoSprite(d);

			if (fl_decoMode) {
				mc.filters = [
					new flash.filters.GlowFilter(0xFFF548,1, 2,2, 10),
					new flash.filters.GlowFilter(0xFFB300,0.8, 8,8, 4),
				];
				mc.onClick( callback(onClickDeco, mc, d) );
				mc.handCursor(true);
				mc.onOver( callback(createTip, T.get.DecoTip, null) );
				mc.onOut( clearTip );
			}
			else {
				if( fl_shadow )
					mc.filters = [getDropShadow()];
				mc.disableMouse();
			}

			decoItems.set(d._id, mc);
		}
		
		// on fait le placement dans un second temps, car on a besoin des MCs (pour les groundStack)
		for (d in fdeco) {
			var mc = decoItems.get(d._id);
			// placement
			var pt = getDecoCoord(d);
			mc.x = pt.x;
			mc.y = pt.y;
			if ( getDecoPos(d)==Floating )
				mc.rotation = -5 + ((d._x+d._y)%10);

			// halo
			if (d._type==DecoLight && !fl_decoMode) {
				var halo = new scen.LightHalo();
				halo.blendMode = flash.display.BlendMode.SCREEN;
				halo.disableMouse();
				fmc.addChild(halo);
				halo.x = mc.x+mc.width*0.5;
				halo.y = mc.y-mc.height*0.7;
			}
			fmc.addChild(mc); // add après pour affiche le sprite au-dessus du halo
		}
	}
	
	function validateDeco() {
		clearPending();
		sendAction( P_SET_DECO(hotel._deco) );
	}
	
	function filterDecoList(dlist:List<DecoItem>, floor:Int, onFront:Bool) {
		return Lambda.filter(dlist, function(d) {
				return d._floor!=null && d._floor==floor && switch(d._type) {
					case DecoPaintSmall	: !onFront;
					case DecoPlantSmall	: onFront;
					case DecoPlantLarge	: onFront;
					case DecoLight		: !onFront;
					case DecoFurniture	: onFront;
					case DecoSofa		: onFront;
					case DecoDesk		: onFront;
				}
			});
	}
	
	inline function getDecoPos(d:DecoItem) : DecoPosition {
		return switch(d._type) {
			case DecoPlantSmall	: GroundStack;
			case DecoPlantLarge	: Ground;
			case DecoPaintSmall	: Floating;
			case DecoLight		: Floating;
			case DecoFurniture	: GroundBase;
			case DecoSofa		: Ground;
			case DecoDesk		: GroundBase;
		}
	}
	
	function getDecoCoord(d:DecoItem) {
		var pos : DecoPosition = getDecoPos(d);
		var pt = new flash.geom.Point(d._x, 0);
		switch(pos) {
			case Ground			: pt.y = -GROUND_HEI;
			case GroundBase		: pt.y = -GROUND_HEI;
			case Floating		: pt.y = -GROUND_HEI-d._y;
			case GroundStack	:
				pt.y = -GROUND_HEI;
				for (gd in hotel._deco) {
					var gdmc = decoItems.get(gd._id);
					if (gdmc!=null && gd._floor==d._floor && d._x>=gd._x-15 && d._x<=gd._x+gdmc.width && getDecoPos(gd)==GroundBase )
						pt.y= -GROUND_HEI - gdmc.height;
				}
		}
		return pt;
	}
	
	
	function onClickDeco(mc:SPR, d:DecoItem) {
		if (pending!=null)
			validateDeco();
		if ( mt.flash.Key.isDown(flash.ui.Keyboard.SHIFT) && d._floor!=null ) {
			// rangement
			d._floor = null;
			d._x = null;
			d._y = null;
			validateDeco();
		}
		else {
			// (dé)placement
			oldDeco = haxe.Unserializer.run( haxe.Serializer.run(d) );
			setPending(PA_PlaceDeco(d));
			decoCursor = new SPR();
			decoCursor.visible = false;
			decoCursor.disableMouse();
			var g = decoCursor.graphics;
			g.lineStyle(2,0xffffff,1);
			var w = Std.int(mc.width * (1/mc.scaleX));
			var h = Std.int(mc.height * (1/mc.scaleY));
			g.drawRect(0,-h, w,h);
			dm.add(decoCursor, DP_INTERF);
		}
	}
	
	/*
	function attachSpreads(client:_Client, xoff,yoff, ?floor, ?x) {
		var cont = new SPR();
		cont.mouseEnabled = false;
		cont.mouseChildren = false;
		for (es in client.effect) {
			if (es.effect==_NEIGHBOR)
				continue;
			var angles = getAngles(floor, x, es.spreading);
			for (a in angles) {
				var arad = a*Math.PI/180;
				var mc = new interf.Arrow();
				cont.addChild(mc);
				mc.arrow.rotation = a;
				mc.icon.gotoAndStop( getLikeIcon(es.effect) );
				//var pt = building.globalToLocal( door.localToGlobal(new PT(0, 0)) );
				mc.x = Math.cos(arad)*xoff;
				mc.y = Math.sin(arad)*yoff;
			}
		}
		return cont;
	}*/
	
	
	function hasItemInCat(cat:String) {
		for (id in hotel._items.keys())
			if (itemCategories.get(id)==cat && hotel._items.get(id)>0)
				return true;
		return false;
	}
	
	
	function showItems(cat:String, bx:Float, by:Float, col:Int) {
		clearPop(true);
		clearPending();
		clearTip();
		setCursor();
		setBuildMode(false);
		bx = Std.int(bx);
		by = Std.int(by);
		
		if ( menu!=null && menu.x==bx && menu.y==by ) {// réouverture du même menu
			clearMenu();
			return;
		}
			
		clearMenu();
		menu = new SPR();
		dm.add(menu, DP_INTERF);
		menu.x = bx;
		menu.y = by;
		
		//var hcount = new IntHash();
		//for (id in hotel._items.keys()) {
			//if ( itemCategories.get(id)!=cat )
				//continue;
			//if ( hcount.exists(id) )
				//hcount.set( id, hcount.get(id)+1 );
			//else
				//hcount.set( id, 1 );
		//}
		
		var n = 0;
		for (id in hotel._items.keys()) {
			var count = hotel._items.get(id);
			if ( itemCategories.get(id)!=cat || count<=0 )
				continue;
			var item = Type.createEnumIndex(_Item, id);
			var tdata = T.getItemText(item);
			var mc = new lmc.Item();
			menu.addChild(mc);
			var icon = new flash.display.Bitmap( iconsHash.get(Std.string(item)) );
			//var icon = iconsHash.get(Std.string(item));
			icon.x = 3;
			icon.y = 3;
			mc.addChild(icon);
			mc.y = n*(Std.int(mc.height));
			mc.label.text = tdata._name;
			mc.label.mouseEnabled = false;
			mc.counter.text = Std.string(count);
			mc.counter.mouseEnabled = false;
			mc.onClick( callback(onClickItem, item) );
			mc.bg.transform.colorTransform = Color.getSimpleCT(col);

			mc.onOver( callback(onOverItem, mc, item) );
			mc.onOut( callback(onOutItem, mc) );
			mc.handCursor(true);
			n++;
		}
	}
	
	function detachHotel() {
		detachQueue();
		if(building!=null)
			building.parent.removeChild(building);
		building = new MC();
		queueCont = null;
		superBuilding.addChild(building);
		nextClock = null;
		curClock = null;
		decoItems = new IntHash();
	}
	
	
	function attachHotel() {
		detachHotel();
		queueCont = new SPR();
		queueCont.mouseEnabled = false;
		
		// calcul position de l'entrée
		var entranceX = 0;
		while (hotel._rooms[0][entranceX]._type==_TR_VOID)
			entranceX++;
		
			
		// déco en stock
		var fl_animStock = decoStock.length==0;
		if(!fl_spectator)
			decoModeButton.visible = hotel._deco.length>1;
		for (mc in decoStock)
			mc.parent.removeChild(mc);
		decoStock = new List();
		var bx = 0;
		var by = 0;
		if (fl_decoMode) {
			for (d in hotel._deco)
				if (d._floor==null) {
					var mc = createDecoSprite(d);
					dm.add(mc, DP_INTERF);
					decoStock.add(mc);
					var sratio = 1 / (mc.width/30);
					if (sratio<1) {
						mc.scaleX = sratio;
						mc.scaleY = sratio;
					}
					mc.x = 50+bx;
					var y = Math.min(40,mc.height);
					if(fl_animStock) {
						mc.y = 0;
						TW.create(mc,"y", 30+by, TEase, 300);
					}
					else
						mc.y = 30+by;
					mc.onClick( callback(onClickDeco, mc, d) );
					mc.onOver( function() { mc.filters = [new flash.filters.GlowFilter(0xffffff,1,4,4,10)]; } );
					mc.onOut( function() { mc.filters = []; } );
					mc.handCursor(true);
					bx+= Std.int(mc.width+2);
					if ( bx>=WID-100 ) {
						bx = 0;
						by += 50;
					}
				}
		}
		// compteur de déco en stock
		if(!fl_spectator) {
			var inStock = Lambda.filter(hotel._deco, function(d) { return d._floor==null; } ).length;
			if (inStock>0) {
				decoModeButton.field.visible = true;
				decoModeButton.field.text = ""+inStock;
			}
			else
				decoModeButton.field.visible = false;
		}

		// catégories d'objets (inventaire)
		for (mc in catButtons)
			mc.parent.removeChild(mc);
		catButtons = new List();
		if( !fl_spectator && !fl_decoMode) {
			var cats = new Hash();
			for (cat in itemCategories)
				cats.set(cat,true);
			var i = 0;
			var sorted = new Array();
			for (cat in cats.keys())
				sorted.push(cat);
			sorted.sort(function(a,b) {
				return Reflect.compare(a,b);
			});
			var colors = [0x426DAE, 0x3096CD, 0x7B9133, 0xB15B3F];
			for (cat in sorted) {
				var col = colors.shift();
				var bt = new interf.Button();
				dm.add(bt, DP_INTERF);
				bt.field.text = cat;
				bt.field.width = 70;
				bt.field.mouseEnabled = false;
				bt.bg.width = bt.field.width;
				bt.bg.filters = [
					new flash.filters.GlowFilter(0x0,0.6, 2,2,10),
					new flash.filters.GlowFilter(0xffffff,0.4, 2,2,10, 1,true),
				];
				bt.x = 84 + i*(bt.field.width+10);
				bt.y = 4;
				if ( hasItemInCat(cat) ) {
					bt.bg.transform.colorTransform = Color.getSimpleCT(col);
					bt.onClick( callback(showItems, cat, bt.x, bt.y+bt.height+2, col) );
					bt.onOver( function() { bt.filters = [new flash.filters.GlowFilter(0xffffff,1,2,2,10) ]; } );
					bt.onOut( function() { bt.filters = []; } );
					bt.handCursor(true);
				}
				else {
					bt.field.filters = [];
					bt.alpha = 0.5;
				}
				catButtons.add(bt);
				i++;
			}
		}
				
		
		// staff
		for (fs in fstaff)
			if(fs.mc.parent!=null)
				fs.mc.parent.removeChild(fs.mc);
		fstaff = new List();
		if( !fl_decoMode ) {
			var n = 0;
			for (g in hotel._staff){
				var mc = new lmc.Staff();
				var fs = new FlashStaff(mc, g);
				fstaff.add(fs);
				if ( !fl_spectator && fs.data._roomId==null ) {
					// disponible
					dm.add(mc, DP_INTERF);
					mc.x = 15 + n*20;
					mc.y = 105;
					//mc.scaleX = -1;
					mc.gotoAndStop(1);
					mc.item.visible = false;
					mc.onClick( callback(onClickStaff, fs) );
					mc.onOver( callback(createTip, T.get.StaffHelp, null) );
					mc.onOut( clearTip );
					mc.handCursor(true);
					n++;
				}
			}
		}
		
		// entrée (bg)
		var mc = new scen.EntranceBg();
		mc.x = entranceX*ROOM_WID;
		mc.y = -GROUND_HEI;
		mc.disableMouse();
		building.addChild(mc);
		
		
		// étages
		var l = new PT(0, 0);
		var r = new PT(ROOM_WID*hotel._width, 0);
		var slopeSign = 1;
		var rseed = new mt.Rand(0);
		for (f in 0...hotel._rooms.length) {
			var design = hotel._design.get(f);
			rseed.initSeed(seed + f);
			
			// on mesure l'étage en ignorant les VOIDs
			var fstart = -1;
			var fend = -1;
			for (x in 0...hotel._rooms[f].length)
				if (hotel._rooms[f][x]._type != _TR_VOID) {
					if(fstart<0)
						fstart = x;
					fend = x+1;
				}

			var groundAng = getAngle(l, r);
			var groundAngRad = groundAng*Math.PI/180;
			
			var y = -FLOOR_HEI * f;
			l = new PT(fstart*ROOM_WID, y+Math.tan(groundAngRad)*fstart*ROOM_WID);
			r = new PT(fend*ROOM_WID, y+Math.tan(groundAngRad)*fend*ROOM_WID);
			
			var ceilAng = (groundAng+(rseed.random(10)/10)*slopeSign) * Math.PI/180;
			var y = -FLOOR_HEI * (f+1);
			var ul = new PT(fstart*ROOM_WID, y+Math.tan(ceilAng)*fstart*ROOM_WID);
			var ur = new PT(fend*ROOM_WID, y+Math.tan(ceilAng)*fend*ROOM_WID);
			
			if (f >= 0) {
				var me = this;
				// bouton extension gauche
				var extMc = new interf.RoomSlot();
				extMc.x = ul.x;
				extMc.y = ul.y+2;
				extMc.height = FLOOR_HEI-4;
				extMc.scaleX = -1;
				extMc.onClick( callback(sendAction, P_EXTEND_FLOOR_L(f)) );
				extMc.handCursor(true);
				extMc.visible = false;
				extButtons.add(extMc);
				building.addChild(extMc);
				
				// bouton extension droite
				var extMc = new interf.RoomSlot();
				extMc.x = ur.x;
				extMc.y = ur.y+2;
				extMc.height = FLOOR_HEI-4;
				extMc.onClick( callback(sendAction, P_EXTEND_FLOOR_R(f)) );
				extMc.handCursor(true);
				extMc.visible = false;
				extButtons.add(extMc);
				building.addChild(extMc);
			}
				
			var fmc = new SPR();
			floorMcs[f] = fmc;
			fmc.x = Std.int(l.x);
			fmc.y = Std.int(l.y);
			fmc.rotation = groundAng;
			
			// papier peint
			var wpmc = new tex.Wallpaper();
			var wpid = design._wall % wpmc.totalFrames;
			var bmp = makeTexture(wpmc, wpid+1);
			var wcol = if (design._wallColor==-1) Const.WALL_COLOR_BASE else if(design._wallColor==-2) Const.WALL_COLOR_DESTROY else Const.allWallColors()[design._wallColor];
			colorize(bmp, wcol);
			
			var wallBg = new SPR();
			var g = wallBg.graphics;
			var matrix = new flash.geom.Matrix();
			matrix.rotate( (rseed.random(5)+5)/100 * (rseed.random(2)*2-1) );
			g.beginBitmapFill(bmp, matrix, true, true);
			g.moveTo(l.x, l.y);
			g.lineTo(r.x, r.y);
			g.lineTo(ur.x, ur.y);
			g.lineTo(ul.x, ul.y);
			g.lineTo(l.x, l.y);
			g.endFill();
			wallBg.filters = [ new flash.filters.DropShadowFilter(7,90,SHADOW_COLOR,0.6, 8,16,1, 1,true) ];
			building.addChild(wallBg);
			
			var left = 10*(1-fstart/hotel._width);
			var right = 10*(fend/hotel._width);
			var top = 3+10*(f/hotel._floors);
			var mid = 28;
			
			// bevel gauche
			g.beginFill( Color.interpolateInt(wcol, 0x0, 0.3) );
			g.moveTo(ul.x+10, ul.y);
			g.lineTo(ul.x+10+left, ul.y+top);
			g.lineTo(l.x+10+left, l.y);
			g.lineTo(l.x+10, l.y);
			g.lineTo(ul.x+10, ul.y);
			g.endFill();
			if (design._bottom>=0) {
				g.beginFill( Color.interpolateInt(wcol, 0x0, 0.6) );
				g.moveTo(l.x+10+left, l.y-mid);
				g.lineTo(l.x+10+left, l.y);
				g.lineTo(l.x+5, l.y);
				g.lineTo(l.x+5, l.y-mid-top*0.5);
				g.endFill();
			}
				
			
			// bevel droit
			g.beginFill( Color.interpolateInt(wcol, 0x0, 0.4) );
			g.moveTo(ur.x-10, ur.y);
			g.lineTo(ur.x-10-right, ur.y+top);
			g.lineTo(r.x-10-right, r.y);
			g.lineTo(r.x-10, r.y);
			g.lineTo(ur.x-10, ur.y);
			g.endFill();
			if (design._bottom>=0) {
				g.beginFill( Color.interpolateInt(wcol, 0x0, 0.6) );
				g.moveTo(r.x-10-right, r.y-mid);
				g.lineTo(r.x-10-right, r.y);
				g.lineTo(r.x-5, r.y);
				g.lineTo(r.x-5, r.y-mid-top*0.5);
				g.endFill();
			}
			
			// bevel plafond
			g.beginFill( Color.interpolateInt(wcol, 0x0, 0.6) );
			g.moveTo(ul.x+10, ul.y);
			g.lineTo(ul.x+10+left, ul.y+top);
			g.lineTo(ur.x-10-right, ur.y+top);
			g.lineTo(ur.x-10, ur.y);
			g.lineTo(ul.x+10, ul.y);
			g.endFill();

			building.addChild(fmc);
			
			//décors mur
			var d = distance(l, r);
			var mur = new SPR();
			fmc.addChild(mur);
			
			// bande centrale
			if(design._mid>=0) {
				var midWall = new tex.MidWall();
				var frame = design._mid % midWall.totalFrames;
				var bmp = makeTexture( midWall, frame, true );
				var matrix = new flash.geom.Matrix();
				matrix.translate(0,-30);
				mur.graphics.beginBitmapFill(bmp, matrix, true, true);
				mur.graphics.drawRect(10+left-1, -30, d-right-left-19, midWall.height);
				mur.graphics.endFill();
			}

			// bande inférieure
			if(design._bottom>=0) {
				var bottomWall = new tex.BottomWall();
				var frame = design._bottom % bottomWall.totalFrames;
				var bmp = makeTexture(bottomWall, frame, true);
				var matrix = new flash.geom.Matrix();
				mur.graphics.beginBitmapFill(bmp, matrix, true, true);
				mur.graphics.drawRect(10+left-1,-25, d-right-left-19, bmp.height);
				mur.graphics.endFill();
			}
			
			// déco d'arrière plan (mur)
			if(!fl_decoMode) {
				var fdeco = filterDecoList(hotel._deco, f, false);
				attachDeco(fmc, fdeco);
			}
			
			// sol / plancher
			var bbmp = makeTexture(new tex.Ground() );
			var matrix = new flash.geom.Matrix();
			matrix.translate(0, -GROUND_HEI);
			mur.graphics.beginBitmapFill(bbmp, matrix, true, true);
			mur.graphics.drawRect(0, -GROUND_HEI, d, GROUND_HEI);
			mur.graphics.endFill();

	
			// porte d'entrée de l'hôtel
			var entranceDoor : scen.EntranceDoor = null;
			if (f==0) {
				entranceDoor = new scen.EntranceDoor();
				building.addChild(entranceDoor);
				entranceDoor.x = entranceX*ROOM_WID;
				entranceDoor.y -= GROUND_HEI;
				entranceDoor.disableMouse();
			}
			
			var wbmp = makeTexture(new tex.SideWall());

			// mur gauche
			if (f==0) {
				var d = distance(l, ul) - entranceDoor.height - GROUND_HEI+1;
				var ang = getAngle(l, ul);
				var lw = new SPR();
				building.addChild(lw);
				paintRect(
					lw.graphics, wbmp,
					0, 0, wbmp.width, d);
				lw.x = ul.x;
				lw.y = ul.y;
				lw.rotation = 90+ang;
				lw.disableMouse();
				//lw.filters = [ new flash.filters.DropShadowFilter(5,0, 0x0,0.3, 2,2) ];
			}
			else {
				var d = distance(l, ul)+2;
				var ang = getAngle(l, ul);
				var lw = new SPR();
				building.addChild(lw);
				paintRect(
					lw.graphics, wbmp,
					0, -d+1, wbmp.width, d);
				lw.x = l.x;
				lw.y = l.y;
				lw.rotation = 90+ang;
				lw.disableMouse();
				if(fstart>hotel._width*0.5)
					lw.filters = [ new flash.filters.DropShadowFilter(6*(fstart/hotel._width), 180, 0x4D1C1A,1, 0,0,10) ];
				//lw.filters = [ new flash.filters.DropShadowFilter(5,0, 0x0,0.3, 2,2) ];
			}

			// cellshading
			wallBg.filters = [ new flash.filters.GlowFilter(0x582F27,1, 2,2,10) ];
			
			// mur droit
			var d = distance(r, ur)+2;
			var ang = getAngle(r, ur);
			var rw = new SPR();
			building.addChild(rw);
			paintRect(
				rw.graphics, wbmp,
				-wbmp.width, -1, wbmp.width, d-1);
			rw.x = ur.x;
			rw.y = ur.y;
			rw.rotation = 90+ang;
			rw.disableMouse();
			if(fend<hotel._width*0.5)
				rw.filters = [ new flash.filters.DropShadowFilter(6*(1-fend/hotel._width),0, 0x4D1C1A,1, 0,0,10) ];
			//rw.filters = [ new flash.filters.DropShadowFilter(5, 180, 0x0, 0.3, 2, 2) ];

			// sol
			//if (f > 0) {
				//var d = distance(l, r);
				//var ground = new SPR();
				//building.addChild(ground);
				//ground.rotation = groundAng;
				//ground.mouseChildren = false;
				//ground.mouseEnabled = false;
				//ground.alpha = 0.3;
				//ground.x = l.x;
				//ground.y = l.y;
				//ground.filters = [ new flash.filters.DropShadowFilter(4,90, 0x0,0.3, 0,0) ];
				//var gbmp = makeTexture(new tex.Barrer(), 1, true);
				//paintRect(
					//ground.graphics, gbmp,
					//wbmp.width, -gbmp.height, d - wbmp.width * 2 + 1, gbmp.height );
				//paintRect(
					//ground.graphics, gbmp,
					//wbmp.width, 0, d-wbmp.width*2+1, 0 );
			//}

			// plafond
			var barrer = new SPR();
			building.addChild(barrer);
			barrer.x = ul.x;
			barrer.y = Std.int(ul.y+2);
			barrer.rotation = getAngle(ul,ur);
			barrer.disableMouse();
			
			// cellshading
			barrer.filters = [ new flash.filters.GlowFilter(0x582F27,1, 2,2,5) ];

			var rbmp = new tex.roof.Barrer(0,0);
			var d = distance(ul,ur);
			paintRect(
				barrer.graphics, rbmp,
				0, -rbmp.height, d, rbmp.height );
				
			// bevel extérieur
			var bottom = 15*(f/hotel._floors);
			var g = building.graphics;
			g.beginFill(0x4D1C1A, 1);
			g.moveTo(l.x-2, l.y-1);
			g.lineTo(l.x+left, l.y+bottom);
			g.lineTo(r.x-right, r.y+bottom);
			g.lineTo(r.x+2, r.y-1);
			g.lineTo(l.x, l.y-1);
			g.endFill();
				
			// contenu de l'etage
			attachFloorContent(seed+f, fmc, f, hotel._rooms[f]);
			
			slopeSign = -slopeSign;
			l = ul;
			r = ur;
		}
		
		building.addChild(queueCont);

		// entrée (front)
		var entrance = new scen.EntranceFg();
		entrance.x = entranceX*ROOM_WID;
		entrance.y = -GROUND_HEI;
		entrance.disableMouse();
		building.addChild(entrance);

	
		// horloge next
		if (nextClock==null) {
			nextClock = new scen.Clock();
			building.addChild(nextClock);
			nextClock.x = entranceX*ROOM_WID-65;
			nextClock.y = -95;
			nextClock.mouseChildren = false;
			//nextClock.disableMouse();
			nextClock.onOver(
				callback( createTip,T.format.NextClock({_wakeUp:_Hotel.WAKEUP_HOUR+":00"}),null )
			);
			nextClock.onOut( clearTip );
			updateTime();
		}
		rseed.initSeed(seed);


		// toit
		var roofWid = 0;
		for (r in hotel._rooms[hotel._floors-1])
			if (r._type != _TR_VOID)
				roofWid++;
		var roofX = 0;
		while( hotel._rooms[hotel._floors-1][roofX]._type==_TR_VOID )
			roofX++;
		var ang = getAngle(l, r);
		var d = distance(l, r);
		var roof = new SPR();
		building.addChildAt(roof,0);
		roof.x = roofX*ROOM_WID;
		roof.y = l.y;
		roof.rotation = ang;
		roof.disableMouse();
		
		var x = rseed.random(30)+10;
		// cheminées
		while(x<d-20) {
			var elem = new scen.out.RoofElem();
			roof.addChild(elem);
			elem.gotoAndStop( rseed.random(elem.totalFrames)+1 );
			elem.x = x;
			elem.y -= 3;
			elem.disableMouse();
			x+=rseed.random(40)+10;
		}
		// blocs
		for(i in 0...rseed.random(2)+1) {
			var rb = new scen.out.RoofBuilding();
			roof.addChild(rb);
			rb.gotoAndStop( rseed.random(rb.totalFrames)+1 );
			rb.x = rseed.random(roofWid*ROOM_WID-70)+10;
			rb.disableMouse();
		}
		
		//var barrer = new SPR();
		//roof.addChild(barrer);
		//var rbmp = new tex.roof.Barrer(0,0);
		//paintRect(
			//barrer.graphics, rbmp,
			//0, -rbmp.height, d, rbmp.height );

		// nom de l'hôtel (néon)
		hotelName = new scen.out.HotelName();
		hotelName.smc.field.text = hotel._name.toUpperCase();
		var ratio = hotelName.smc.field.textWidth / (ROOM_WID*2);
		if(ratio<1) {
			hotelName.scaleX = 1 + 1-ratio;
			hotelName.scaleY = hotelName.scaleX;
		}
		hotelName.smc.field.width = hotelName.smc.field.textWidth+5;
		var pt = scroller.globalToLocal( roof.localToGlobal( new flash.geom.Point(Std.int(roofWid*ROOM_WID*0.5 - hotelName.width*0.5), -12) ) );
		hotelName.x = Std.int(roofWid*ROOM_WID*0.5 - hotelName.width*0.5);
		hotelName.y = -12;
		hotelName.disableMouse();
		//hotelName.smc.filters = [
			//new flash.filters.GlowFilter(0xFFCC00,1, 6,6, 1),
			//new flash.filters.GlowFilter(0xffffff,1, 2,2, 2.5),
			//new flash.filters.GlowFilter(0xFFFF00,1, 8,8, 1),
			//new flash.filters.GlowFilter(0xFF6600,1, 32,32, 1.5),
		//];
		//for (i in 0...hotel._stars) {
		var wid = hotelName.smc.width;
		for (i in 0...hotel._stars) {
			var s = new interf.Star();
			hotelName.smc.addChild(s);
			s.x = Std.int(wid*0.5 - hotel._stars*19*0.25 - 2 + 19*i);
			//s.x = Std.int(19*i);
			s.y = -32;
		}
		setNeonColor(1);
		roof.addChild(hotelName);

		// boutons extension toit
		for(x in 0...roofWid) {
			var extMc = new interf.RoomSlot();
			extMc.x = 7 + (roofX+x)*ROOM_WID;
			extMc.y = -hotel._floors*FLOOR_HEI-4;
			extMc.height = ROOM_WID-10; // inversion à cause de rotation
			extMc.rotation = -90;
			extMc.onClick( callback(sendAction, P_EXTEND_ROOF(x+roofX)) );
			extMc.handCursor(true);
			extMc.visible = false;
			extButtons.add(extMc);
			building.addChild(extMc);
		}
		setBuildMode(false);

		/*if ( isOldView() ) {
			// snapshot & désaturation en mode spectateur
			var bd = new BD(Std.int(building.width), Std.int(building.height), true, 0x0);
			var matrix = new flash.geom.Matrix();
			matrix.translate(100,building.height);
			root.stage.quality = flash.display.StageQuality.HIGH;
			bd.draw(superBuilding, matrix);
			applySpectatorFilter(bd, 0.6);
			var b = new flash.display.Bitmap(bd);
			b.x = WID*0.5 - (hotel._width*ROOM_WID)*0.5 - entrance.width + 27;
			b.y = HEI-b.height-BMARGIN;
			//building.alpha = 0;
			//superBuilding.addChild(b);
			//building.visible = false;
			root.stage.quality = flash.display.StageQuality.MEDIUM;
		}*/
		
		// centrage
		if( isOldView() )
			building.filters = [ getSpectatorFilter(0.7) ];
		building.x = entrance.width*0.5 + WID*0.5 - (hotel._width*ROOM_WID)*0.5;
		building.y = HEI-BMARGIN;
		if (hotel._width<=2)
			building.x += 100;

		// queue
		attachQueue();
	}
	
	function setNeonColor(alpha:Float) {
		var col = hotel.getNeonColor();
		var rgb = Color.intToRgb(col);
		hotelName.smc.field.textColor = Color.rgbToInt( Color.offsetColor(rgb,-30) );
		hotelName.smc.filters = [
			new flash.filters.GlowFilter(Color.interpolateInt(col,0xFFCC00, 0.5),alpha, 6,6, 1),
			new flash.filters.GlowFilter(0xffffff,alpha, 2,2, 2.5),
			new flash.filters.GlowFilter(Color.interpolateInt(col,0xFFFF00, 0.5),alpha, 8,8, 1),
			new flash.filters.GlowFilter(Color.rgbToInt(Color.offsetColor(rgb,-50)),alpha*(0.3+0.7*getNightRatio()), 32,32, 1.5),
		];
	}
	
	
	function detachQueue() {
		for (c in queue)
			c.mc.parent.removeChild(c.mc);
		queue = new List();
	}
	
	function attachQueue() {
		detachQueue();
		
		for (cid in hotel._clientQueue)
			attachClient( getClient(cid) );
		if(fl_spectator)
			for (c in hotel._friends)
				attachClient(c);
		updateQueue();
		
		if (fl_decoMode) {
			queueCont.alpha = 0.2;
			queueCont.disableMouse();
		}
	}

	function updateQueue() {
		// début du lobby
		var x = 0;
		while (x < hotel._width) {
			if (hotel._rooms[0][x]._type==_TR_LOBBY)
				break;
			x++;
		}
		var lobbyX = x*ROOM_WID;
		
		// clean up bagages
		for (mc in luggages)
			mc.parent.removeChild(mc);
		luggages = new List();
		
		// queue
		var n = 0;
		var dist = if(queue.length>=11) 38 else if(queue.length>=7) 50 else 50+25*(1-queue.length/7);
		for (c in queue) {
			c.luggages = new List();
			var rseed = new mt.Rand(c.data._id + hotel._id);
			c.mc.x = Std.int( lobbyX - (40 + dist*n) );
			c.mc.y = -GROUND_HEI;
			// bagage(s)
			for(i in 0...rseed.random(2)+1) {
				var lug = new lmc.Luggage();
				queueCont.addChild(lug);
				lug.x = c.mc.x + (rseed.random(15)+5) * (if (i%2==0) -1 else 1);
				lug.y = c.mc.y;
				lug.scaleX=-1;
				lug.gotoAndStop( rseed.random(lug.totalFrames)+1 );
				lug.filters = [getDropShadow()];
				lug.disableMouse();
				if (i%2!=0)
					queueCont.swapChildren(lug, c.mc);
				c.luggages.add(lug);
				luggages.add(lug);
			}
			n++;
		}
	}
		
	function attachClient(cdata:_Client, ?fl_inQueue = true ) {
		var container = new MC();
		var cmc : MC;
		switch(cdata._type) {
			case _MF_AQUA		: cmc = new monster.Aqua();
			case _MF_FIRE		: cmc = new monster.Fire();
			case _MF_BOMB		: cmc = new monster.Bomb();
			case _MF_SM			: cmc = new monster.Doll();
			case _MF_BLOB		: cmc = new monster.Blob();
			case _MF_VEGETAL	: cmc = new monster.Plant();
			case _MF_GHOST		: cmc = new monster.Ghost();
			case _MF_BUSINESS	: cmc = new monster.Business();
			case _MF_FRANK		: cmc = new monster.Frank();
			case _MF_GIFT		: cmc = new monster.Gift();
			case _MF_BASIC		: cmc = new monster.Witch();
			case _MF_ZOMBIE		: cmc = new monster.Zombie();
			case _MF_FLYING		: cmc = new monster.Flying();
		}
		
		cmc.scaleX=-1;
		cmc.gotoAndStop(1);
		if (cdata._type==_MF_SM && cdata._happyness <= Const.HYSTERIA_LIMIT && !fl_inQueue)
			cmc.gotoAndPlay(2);
		cmc.filters = getClientFilters(cdata);
		
		container.addChild(cmc);
		var fclient = new FlashClient(container, cdata);
		fclient.clientMc = cmc;
		
		// chat volant
		if (cdata._type == _MF_FLYING) {
			var casted : monster.Flying = cast cmc;
			var f = Std.random(casted.left.totalFrames)+1;
			casted.left.gotoAndPlay(f);
			casted.right.gotoAndPlay(f);
		}
		
		// cadeau
		if (cdata._type == _MF_GIFT) {
			var casted : monster.Gift = cast cmc;
			var ct = new flash.geom.ColorTransform();
			ct.color = cdata._color;
			casted.teint.transform.colorTransform = ct;
			casted.teint.blendMode = flash.display.BlendMode.OVERLAY;
		}
		
		if (fl_inQueue) {
			queueCont.addChild(container);
			queue.add(fclient);
			container.onClick( callback(onClickClient, fclient) );
			container.onOver( callback(onOverClient, fclient) );
			container.onOut( callback(onOutClient, fclient) );
			container.handCursor(true);

			// nom
			var name = new interf.Name();
			container.addChild(name);
			//name.scaleX = -1;
			name.field.text = cdata._name;
			name.field.textColor = if (cdata._vip) 0xFFFF00 else 0xffffff;
			name.y = -container.height+7;
			name.field.width = name.field.textWidth+4;
			name.field.filters = [
				new flash.filters.GlowFilter(0x0,0.7,2,2,1),
				new flash.filters.DropShadowFilter(2,90, SHADOW_COLOR,1, 2,2)
			];
			name.field.x = -Std.int(name.field.textWidth*0.5);
		}
		
		return fclient;
	}

	
	function removeFromQueue(cid:Int) {
		for (c in queue) {
			if (c.data._id != cid)
				continue;
			c.mc.parent.removeChild(c.mc);
			queue.remove(c);
		}
		updateQueue();
	}
	
	
	function getClientTip(c:_Client, ?r:_Room) {
		if (c==null)
			return "";

		var cseed = hotel._id + c._id;
		TG.initSeed(cseed);

		var tpl = new haxe.Template( haxe.Resource.getString(LANG+".clientTip.mtt") );
		var staff = if(r!=null) getStaff(r);
		
		// happy log
		var hlogLines = new Array();
		if ( c!=null && c._happyLog.length > 0 ) {
			for (log in c._happyLog)
				if (log._n != 0 || log._mod==M_BASE)
					hlogLines.push( _Client.printHappyLog(log) );
		}
		
		// template
		return tpl.execute({
			_client			: c,
			_likes			: getLikeSentence(c),
			_hasService		: c.hasServiceWaiting(date),
			_spreads		: getSpreadSentence(c),
			_happyness		: if(r!=null) c.getHappyness() else c._baseHappy + c._malusHappy,
			_sad			: c.getHappyness()<=4,
			_happyLog		: hlogLines,
			_inQueue		: r==null,
			_stayDays		: mt.deepnight.Lib.countDeltaDays(date, c._dateLeaving),
			_workEnd		: if (staff!=null) DateTools.format(staff.data._endDate, T.get.TimeFormat),
			_repairing		: (staff!=null && c==null),
			_mrule			: T.getClientRule(c._type),
			_spectator		: fl_spectator,
			_vipJob			: if (c._vip) TG.get("vipJob"),
			_death			: if(c.isUnstable()) DateTools.format(c._death, T.get.TimeFormat),
			//_item			: if(!fl_spectator && initData._clientItem) Std.string(c._item).toLowerCase().substr(1),
		});
	}
	
	
	function onOverRoom(fr:FlashRoom) {
		if ( fl_decoMode || fl_buildMode )
			return;
		var r = fr.data;
		var c = getClient(r._clientId);
		var staff = getStaff(r);
		
		if ( fl_spectator && (r._type != _TR_BEDROOM || c == null) )
			return;
		
		var tpl = new haxe.Template( haxe.Resource.getString(LANG+".roomTip.mtt") );
		var rname =
			if(r._type==_TR_BEDROOM)
				""+getRoomNumber(fr)
			else {
				var n = getRoomName(fr);
				if ( n.length>15 )
					n = n.substr(0, n.indexOf(" "));
				n;
			}
			
		var lockEnd =
			if( _Room.isServiceRoom(r._type) )
				r._serviceEnd;
			else  if ( r._type==_TR_LAB )
				r._serviceEnd;
			else null;
			
		// template
		var clientDelay = DateTools.parse( hotel.getClientDelay(hotel.countStaffDoing(J_LOBBY)) );
		var html = tpl.execute({
			_clientTpl		: getClientTip(c,r),
			_client			: c,
			_nextClient		: DateTools.format(hotel._nextClient, T.get.TimeFormat),
			_clientDelay	: StringTools.replace( StringTools.replace(T.get.TimeFormat,"%H",""+clientDelay.hours), "%M", mt.deepnight.Lib.leadingZeros(""+clientDelay.minutes,2)),
			
			_roomName		: rname,
			_roomTexts		: _Room.getRoomText(r._type),
			_isDamaged		: r.isDamaged(),
			_isBedroom		: r._type==_TR_BEDROOM,
			_roomLevel		: r._level,
			_isLobby		: r._type==_TR_LOBBY,
			_itemToTake		: if (r._itemToTake!=null) T.getItemText(r._itemToTake),
			_constEnd		: if (r._underConstruction!=null) DateTools.format(r._underConstruction, T.get.TimeFormat),
			_lockEnd		: if (lockEnd!=null) DateTools.format(lockEnd, T.get.TimeFormat),
			_workEnd		: if (r._type!=_TR_LOBBY && staff!=null) DateTools.format(staff.data._endDate, T.get.TimeFormat),
			_repairing		: (staff!=null && c==null),
			_research		: if (r._type==_TR_LAB) Math.floor(100*r._life/Const.LAB_NEEDED_POINTS),
		});
		
		try {
			var className = Std.string(r._type).substr(4).toLowerCase();
			js.api.print.call([className, html]);
		} catch (e:String) {}
	}
	
	
	
	function onOutRoom() {
		clearTip();
		clearSpreadings();
		try js.api.clear.call([]) catch (e:String) {}
		setCursor();
	}
	
	#if !prod
	function debugRoom(fr:FlashRoom) {
		sendAction( P_DEBUG(fr.floor, fr.x) );
	}
	#end
	
	function onClickRoom(fr:FlashRoom) {
		if ( isLocked() || fl_spectator || fl_buildMode )
			return;
		var r = fr.data;
		if (pending != null)
			runPendingOnRoom(r);
		else
			if ( r._type==_TR_LOBBY && getStaff(r)!=null )
				sendAction( P_CANCEL_STAFF(fr.floor, fr.x) ); // rappeler staff au lobby
			else if( r._underConstruction==null && !fl_decoMode ) {
				var menu : List<MenuElement> = new List();
					
				#if !prod
				menu.add( { label:"DEBUG", icon:null, col:0xB70000, help:null, cb:callback(debugRoom, fr) } );
				#end
		
				// client
				if ( r._clientId!=null ) {
					if ( Std.random(100)<66 && getClient(r._clientId)._activity==null )
						bubbleRoom(fr, TG.get("RoomClickReply"));
					var icon = new interf.Icon();
					icon.gotoAndStop("view");
					icon.disableMouse();
					menu.add( { label:T.get.ClientInfos, icon:cast icon, col:null, help:null, cb:callback(sendAction, P_CLIENT_INFOS(r._clientId)) } );
					if( r._type==_TR_BEDROOM )
						menu.add( { label:T.get.MoveClient, icon:null, col:0xB70000, help:null, cb:callback(setPending, PA_MoveClient(r)) } );
				}
				
				// item à ramasser
				if (fr.data._itemToTake != null) {
					var tdata = T.getItemText(fr.data._itemToTake);
					var icon : flash.display.DisplayObject = new flash.display.Bitmap( iconsHash.get(""+fr.data._itemToTake) );
					menu.add( { label:T.format.TakeItem({_item:tdata._name}), icon:icon, col:0xB67A0C, help:null, cb:callback(sendAction, P_TAKE_ITEM(fr.floor, fr.x) ) } );
				}

				// service
				if ( r._clientId!=null && getClient(r._clientId).hasServiceWaiting(date) ) {
					var icon : flash.display.DisplayObject = switch(getClient(r._clientId)._serviceType) {
						case ServiceWash	: cast new service.Wash();
						case ServiceAlcool	: cast new service.Alcool();
						case ServiceFridge	: cast new service.Fridge();
						case ServiceShoe	: cast new service.Shoe();
					}
					var iconCont :flash.display.DisplayObjectContainer = new SPR();
					iconCont.addChild(icon);
					icon.x=10;
					icon.y=18;
					menu.add( { label:T.get.DoService, icon:cast iconCont, col:0xC87402, help:null, cb:callback(sendAction, P_SERVICE(fr.floor, fr.x)) } );
				}

				// rappeler staff
				var s = getStaff(r);
				if ( s!=null )
					menu.add( { label:T.get.CancelStaff, icon:null, col:null, help:null, cb:callback(sendAction, P_CANCEL_STAFF(fr.floor,fr.x)) } );
	
					
				// level up de chambre
				if ( r._type==_TR_LOBBY && r._level<Const.MAX_LOBBY_LEVEL ) {
					var cb = callback( confirm, T.get.ConfirmAction, callback(sendAction, P_LEVEL_UP(fr.floor, fr.x)) );
					menu.add( { label:T.get.LevelUpLobbyTitle+" ("+Const.LEVELUP_LOBBY_COST[r._level+1]+")", icon:null, col:0x3398C8, help:paragraph(T.get.LevelUpLobby,"rule"), cb:cb } );
				}
				
				if (r._clientId==null && s==null && r._itemToTake==null) {
					// level up de chambre
					if ( r._type==_TR_BEDROOM && r._level<Const.MAX_ROOM_LEVEL ) {
						var cb = callback( confirm, T.get.ConfirmAction, callback(sendAction, P_LEVEL_UP(fr.floor, fr.x)) );
						menu.add( { label:T.get.LevelUpTitle+" ("+Const.LEVELUP_COST[r._level+1]+")", icon:null, col:0x3398C8, help:paragraph(T.get.LevelUp,"rule"), cb:cb } );
					}
					// construction	de room
					for (e in _Room.getBuildList(fr.floor, r._type)) {
						if ( !hotel.canBuildRoom(e) )
							continue;
						var tdata = _Room.getRoomText(e);
						var help = paragraph(tdata._name,"title") + paragraph(tdata._ambiant, "ambiant") +"<br>"+ paragraph(tdata._rule,"rule");
						var confTxt =
							if( r._type!=_TR_NONE )
								paragraph(T.format.ConfirmReplacement({_old:_Room.getRoomText(r._type)._name}));
							else
								paragraph(T.get.ConfirmAction);
						if ( r.hasEquipment() )
							confTxt += paragraph(T.get.ConfirmEquipLoss);
						if ( r._level>0 )
							confTxt += paragraph(T.get.ConfirmLevelLoss);
						var cb = callback( confirm, confTxt, callback(sendAction, P_SWAP_ROOM(fr.floor, fr.x, e)) );
						var col = if (_Room.isServiceRoom(e)) 0x9FAA17 else 0x8039BF;
						var iconKey = switch(e) {
							case _TR_BIN		: Std.string(_STINK_BOMB);
							case _TR_RESTAURANT	: Std.string(_BUFFET);
							case _TR_DISCO		: Std.string(_HIFI_SYSTEM);
							case _TR_FURNACE	: Std.string(_RADIATOR);
							case _TR_POOL		: Std.string(_HUMIDIFIER);
							case _TR_LAB		: Std.string(_RESEARCH);
							default: null;
						}
						var cost = if (_Room.isSpecialRoom(e)) initData._sroomCost else _Room.getRoomCost(e);
						var icon : flash.display.DisplayObject = if (iconKey!=null) new flash.display.Bitmap(iconsHash.get(iconKey)) else null;
						menu.add( { label:T.format.Build({_name:tdata._name})+" ("+cost+")", icon:icon, col:col, help:help, cb:cb } );
					}
				}

				// item à supprimer
				for(item in fr.data._equipments) {
					var tdata = T.getItemText(item);
					var icon : flash.display.DisplayObject = new flash.display.Bitmap( iconsHash.get(""+item) );
					var cb = callback(sendAction, P_REMOVE_ITEM(fr.floor, fr.x, item) );
					menu.add( { label:T.format.RemoveItem({_item:tdata._name}), icon:icon, col:0xB70000, help:null, cb:callback(confirm, T.get.ConfirmAction, cb) } );
				}

				if (menu.length > 0)
					attachMenu(menu, root.mouseX, root.mouseY);
			}
	}
	
	
	function runPendingOnRoom(r:_Room) {
		if (pending == null)
			return;
		var pt = getCoords(r);
		switch(pending) {
			case PA_AddClient(c) :
				clearPending();
				sendAction( P_ADD_CLIENT_FROM_QUEUE(c.data._id, pt.floor, pt.x) );
				
			case PA_MoveClient(oldr) :
				var opt = getCoords(oldr);
				clearPending();
				sendAction( P_MOVE_CLIENT(opt.floor, opt.x, pt.floor, pt.x) );
		
			case PA_SendStaff(s) :
				clearPending();
				sendAction( P_SEND_STAFF(s.data._id, pt.floor, pt.x) );
				
			case PA_UseItem(it) :
				//if ( r._item!=null && Const.isEquipment(it) )
					//confirm( paragraph(T.get.ConfirmAction)+paragraph(T.get.ConfirmEquipLoss), callback(function() {ME.runPendingOnRoom(r); }) );
				//else {
					clearPending();
					sendAction( P_USE_ITEM(pt.floor, pt.x, it) );
				//}
				
			case PA_PlaceDeco(d) :
				validateDeco();
		}
	}
	

	function setPending(a:PendingAction) {
		if (isLocked())
			return;
			
		clearMenu();
		setBuildMode(false);
		updateAutoRefresh();
		if ( Type.enumEq(a,pending) ) {
			clearPending();
			return;
		}
		else
			clearPending();
			
		setCursor("target", true);
		switch(a) {
			case PA_AddClient(c) :
				c.clientMc.filters = getGlow();
			case PA_MoveClient(r) :
			case PA_SendStaff(s) :
				s.mc.filters = getGlow();
			case PA_UseItem(it) :
				//it.mc.filters = getGlow(true);
			case PA_PlaceDeco(_) :
				for (fr in frooms)
					if (fr.mc!=null)
						fr.mc.enableMouse();
		}
		pending = a;
	}
	
	function cancelAll() {
		clearPending();
		clearMenu();
	}
	
	public function isOut() {
		return mouse.x<0 || mouse.x>=WID || mouse.y<0 || mouse.y>HEI;
	}
	
	public function onClickPage() {
		if( isOut() ) {
			clearPending();
			clearMenu();
		}
	}
	
	public function clearPending() {
		//if (lock)
			//return;
		if (pending == null)
			return;

		if(clientCursor!=null) {
			clientCursor.parent.removeChild(clientCursor);
			clientCursor = null;
		}
		
		clearCursor();
			
		switch(pending) {
			case PA_AddClient(c) :
				//c.mc.parent.removeChild(c.mc);
				//building.addChild(c.mc);
				//updateQueue();
				c.clientMc.filters = [getDropShadow()];
				
			case PA_MoveClient(r) :
			case PA_SendStaff(s) : // TODO drag & drop
				s.mc.filters = [];
			case PA_UseItem(it) :
				//it.mc.filters = [];
			case PA_PlaceDeco(_) : // TODO
				decoCursor.parent.removeChild(decoCursor);
				decoCursor = null;
		}
		pending = null;
		
	}
	
	/*
	function clearBubbles() {
		clearSubBubbles(null);
		for (mc in bubbles)
			TW.create(mc, "alpha", 0, TEaseOut, DateTools.seconds(0.5)).end = function() { mc.parent.removeChild(mc); }
		bubbles = new List();
	}
	
	function bubble(fr:FlashRoom, ic:String, ?label:String, ?subList:List<{icon:String, label:String, col:Int}>) {
		var bmc = new interf.Bubble();
		scroller.addChild(bmc);
		var pt = fr.mc.localToGlobal(new flash.geom.Point(0, 0));
		bmc.x = pt.x + fr.mc.width*0.5 + 50;
		bmc.y = pt.y + fr.mc.height*0.5 - 25;
		
		bmc.icon.gotoAndStop(ic);
		//icon.filters = [
			//new flash.filters.DropShadowFilter(3, 90, 0x0, 0.3, 2, 2),
		//];
		
		if (label == null) {
			bmc.icon.x = 0;
			bmc.field.visible = false;
		}
		else
			bmc.field.text = label;
		
		if (subList != null && subList.length > 0) {
			bmc.hit.addEventListener( flash.events.MouseEvent.MOUSE_OVER, callback(subBubble, bmc, subList) );
			bmc.hit.addEventListener( flash.events.MouseEvent.MOUSE_OUT, clearSubBubbles );
		}
		
		bubbles.add(bmc);
	}
	*/
	
	function bubbleRoom(room:FlashRoom, str:String, ?col:Null<Int>) {
		bubble(room.mc, new flash.geom.Point(70,10), str, col);
	}
	
	function bubble(ref:SPR, pt:flash.geom.Point, str:String, ?col:Null<Int>) {
		if (col==null)
			col = 0x334F91;
		str = str.substr(0,1).toUpperCase() + str.substr(1);
		var mc = new interf.BubbleAuto();
		scroller.addChild(mc);
		mc.disableMouse();
		
		//mc.x = base.x+15;
		//mc.y = base.y-10;
		
		mc.field.text = str;
		mc.field.textColor = col;
		mc.field.width = mc.field.textWidth+7;

		// stretch + texture répétée
		mc.right.x = mc.field.x + mc.field.textWidth;
		var bg = new SPR();
		mc.left.addChild(bg);
		bg.graphics.beginBitmapFill(new tex.BubbleBg(0,0), true);
		bg.graphics.drawRect( 0, 0, mc.right.x-mc.left.x, mc.left.height-1);
		bg.graphics.endFill();
		
		// placement
		var base = new flash.geom.Point(pt.x, pt.y);
		base = ref.localToGlobal(base);
		//if ( base.x+mc.width*0.5>=WID-30 )
			//base.x = WID-mc.width*0.5-30;
		base = scroller.globalToLocal(base);
		mc.x = Std.int(base.x-mc.width*0.5);
		mc.y = Std.int(base.y);
		mc.small.x = mc.width*0.5;
		mc.small.scaleX = -1;
	
		mc.alpha = 0;
		TW.create(mc, "x", mc.x-3, TEaseOut, DateTools.seconds(0.3)).fl_pixel= true;
		TW.create(mc, "alpha", 1, TEaseOut, DateTools.seconds(0.3));
		haxe.Timer.delay( function() {
			TW.create(mc, "alpha",0, TEaseIn, DateTools.seconds(1)).onEnd = function() {
				mc.parent.removeChild(mc);
			}
		}, 2000);
	}
	
	
	//function addRoomLog(r:FRoom, value:Dynamic, ?ic:String) { // TODO recode
		//var lmc = new MC();
		//lmc.x = 5;
		//lmc.y = -18-r.logs.length*16;
			//
		//var tf = new flash.text.TextField();
		//tf.width = 120;
		//tf.height = 18;
		//tf.textColor = 0xFFFFFF;
		//tf.filters = [ new flash.filters.DropShadowFilter(2,90, 0x0,1, 2,2) ];
		//tf.text = "" + value;
		//tf.selectable = false;
		//lmc.addChild(tf);
		//
		//icone
		//if(ic!=null) {
			//var icon = new interf.Icon();
			//icon.gotoAndStop(ic);
			//lmc.addChild(icon);
			//tf.x = 16;
		//}
		//
		//r.mc.addChild(lmc);
		//r.logs.add(lmc);
	//}
	
	public function onMuxxuStartComment() {
		updateAutoRefresh(5);
	}
	
	public function sendAction(act:_PlayerAction) {
		if (isLocked())
			return;
		setServerLock(true);
		trace(act);
		switch(act) {
			case P_VIEW_HOTEL(_) :
				var h = new haxe.Http("/visitData");
				var chk = Reflect.field(flash.Lib.current.loaderInfo.parameters,"vc");
				h.setParameter( "id", Reflect.field(flash.Lib.current.loaderInfo.parameters,"viewUid") );
				h.setParameter( "c", chk );
				h.onData = function(d:String) {
					trace("received "+d);
					if( d!=chk )
						return;
					onServerData( Codec.getData("vd") );
				};
				h.request(true);
				return;
			default:
		}
		#if !prod
			trace("sendAction "+act);
			if( Reflect.field(flash.Lib.current.loaderInfo.parameters,"d") == "true" )
				Codec.FAKE = true;
		#end
		Codec.load("/action", { _a: act }, onServerData);
	}
	
	function getRoomName(fr:FlashRoom) {
		var r = fr.data;
		var data = _Room.getRoomText(r._type);
		if (r._type==_TR_BEDROOM)
			data._name += " "+getRoomNumber(fr);
		//if (r._type==_TR_BEDROOM && r._level>0)
			//data.name+=" ("+T.format.Level({_n:r._level+1})+")";
		return data._name;
	}
	

	function getRoomNumber(r:FlashRoom) {
		return _Room.getNumber(r.floor, r.x);
	}
	
	
	function onActionResult() {
		for (f in frooms)
			f.data =  hotel._rooms[f.floor][f.x];

		attachHotel();
		attachQueue();

		// lecture du log (autres évènements)
		playLog();
	}
	
	function getAngles(?f:Int,?x:Int, ts:_TypeSpread) {
		var list = new List();
		switch(ts) {
			case LEFT_RIGHT :
				if(x==null || x>0) list.add(180);
				if(x==null || x<hotel._width-1) list.add(0);
			case UP :
				if(f==null || f<hotel._floors-1) list.add(-90);
			case DOWN :
				if(f==null || f>0) list.add(90);
			case HORIZONTAL : // TODO
				if(x==null || x>0) list.add(180);
				if(x==null || x<hotel._width-1) list.add(0);
			case CROSS :
				if(x==null || x>0) list.add(180);
				if(x==null || x<hotel._width-1) list.add(0);
				if(f==null || f<hotel._floors-1) list.add(-90);
				if(f==null || f>0) list.add(90);
			//case CIRCLE : // TODO
			case MYSELF : //rien a faire ?
		}
		return list;
	}
	
	function clearSpreadings() {
		for (mc in spreadList)
			mc.parent.removeChild(mc);
		spreadList = new List();
	}
	
	
	function playLog() {
		while (playNextLog()) { }
	}
	
	function playNextLog() : Bool { // renvoie true si la lecture du log doit être continuée
		if (fl_spectator || fl_lock || hotel._actionLog.length==0)
			return false;
		var l = hotel._actionLog.pop();
		if (fl_decoMode)
			setDecoMode(false);
		#if !prod trace(l); #end
		switch(l) {
			case L_REFRESH :
				try js.api.refresh.call([]) catch(e:Dynamic) {}
				throw "stop";
			case L_NEW_EXT_COST(cost) :
				initData._extCost = cost;

			case L_NEW_SROOM_COST(cost) :
				initData._sroomCost = cost;
				
			case L_MSG(msg) :
				pop(msg);
				return false;
				
			case L_EVENT(msg) :
				pop(msg, 0xB90000);
				return false;
				
			case L_ERROR(e) :
				pop(e, 0xB90000);
				return false;
			case L_FATAL(e) :
				pop("FATAL ! "+e);
				return false;
				
			case L_QUEST(isNew, html) :
				if ( html==null )
					try js.api.empty.call(["quest"]) catch (e:Dynamic) {}
				else
					if(isNew) {
						try js.api.injectAnim.call(["quest", html]) catch (e:Dynamic) {}
						pointAt(WID*0.5, 20, T.get.NewQuest, 600);
					}
					else
						try js.api.inject.call(["quest", html]) catch (e:Dynamic) {}
					
			case L_ADD_A_CLIENT_IN_ROOM(cid, f, x) :
				if( getClient(cid)._activityEnd==null )
					showClientThought( getFlashRoomAt(f,x) );
					
			case L_MOVE_A_CLIENT(of,ox, tf, tx) :
				var from = getFlashRoomAt(of,ox);
				from.fclient = null;
				showClientThought( getFlashRoomAt(tf,tx) );
			case L_SWAP_ROOM(f, x, type) : // TODO
			case L_NEW_FLOOR : // TODO
			case L_CLIENT_LEFT(f, x) :
			case L_ROOM_CHANGE_LIFE(f, x) :
			case L_NEW_ITEM(f,x,i) :
			case L_TAKE_ITEM(i) :
			case L_ADD_STAFF_IN_ROOM(f,x,id, job) :
				var fr = getFlashRoomAt(f,x);
				if(job==J_HOUSEWORK || job==J_LOBBY)
					bubbleRoom(fr, TG.get("StaffThink"), 0xCC2F2F);
			case L_ADD_A_CLIENT_IN_LAB(f,x) :
				var fr = getFlashRoomAt(f,x);
				bubbleRoom(fr, TG.get("ClientInLab"), 0xCC2F2F);
			case L_HTML(str) :
				lockGame();
				try js.api.htmlPopUp.call([str]) catch(e:Dynamic) {}
				return false;
			case L_ANIM(f,x, anim) :
				var pt = building.localToGlobal( new flash.geom.Point(x*ROOM_WID + ROOM_WID*0.5, -f*FLOOR_HEI - FLOOR_HEI*0.5+30) );
				pt = scroller.globalToLocal(pt);
				switch(anim) {
					case Explode :
						TW.create(scroller, "x", scroller.x+5, TShakeBoth, DateTools.seconds(1));
						TW.create(scroller, "y", scroller.y-5, TShakeBoth, DateTools.seconds(0.7));
					case HappyChange(n) :
						popNumber(n, if(n>0) "happy" else "sad", pt.x, pt.y);
					case HappyChangeQueue(cid, n) :
						var qc = getClientInQueue(cid);
						var qpt = building.localToGlobal( new flash.geom.Point(qc.mc.x, qc.mc.y) );
						qpt = scroller.globalToLocal(qpt);
						popNumber(n, if(n>0) "happy" else "sad", qpt.x, qpt.y-55);
					case MoneyChange(n) :
						popNumber(n, "money", pt.x, pt.y);
					case FameChange(n) :
						popNumber(n, "fame", pt.x, pt.y);
					case ResearchUp(n) :
						popString("+"+Math.floor(100*n/Const.LAB_NEEDED_POINTS)+"%", 0x2F7B7B, pt.x, pt.y);
					case ClientTimeChange(m) :
						if( m!=0 ) {
							var data = DateTools.parse(DateTools.minutes(Math.abs(m)));
							var msg = StringTools.replace(T.get.TimeFormat, "%H", ""+data.hours);
							msg = StringTools.replace(msg, "%M", mt.deepnight.Lib.leadingZeros(Std.string(data.minutes),2));
							msg = (if (m<0) "-" else "+") + msg;
							var col = if (m<0) 0x689933 else 0xCC0000;
							var pt = nextClock.localToGlobal( new flash.geom.Point(30,5) );
							pt = scroller.globalToLocal(pt);
							popString(msg, col, "time", pt.x, pt.y);
						}
					case NewClient(cid) :
						var c = getClientInQueue(cid);
						if (c!=null) {
							c.mc.alpha = 0;
							TW.create(c.mc, "alpha", 1);
							var x = c.mc.x;
							var baseY = c.mc.y;
							c.mc.x -= 300;
							var anim = TW.create(c.mc, "x", x, TLinear, DateTools.seconds(1.2));
							for (mc in c.luggages)
								mc.alpha = 0;
							anim.onUpdateT = function(t) {
								c.mc.y = baseY - Math.abs(Math.sin(t*Math.PI*7)*8);
							}
							anim.onEnd = function() {
								ME.bubble(c.mc, new flash.geom.Point(15,-80+Std.random(10)), TG.get("Hello"));
								for (mc in c.luggages)
									TW.create(mc, "alpha", 1);
							}
						}
				}
		}
		return hotel._actionLog.length>0;
	}
	
	function showClientThought(fr:FlashRoom) {
		if ( fr==null || fr.fclient==null )
			return;
		var h = fr.fclient.data._happyness;
		if ( h<5 )
			bubbleRoom(fr, TG.get("ClientThinkBad"), 0xCC2F2F);
		else if ( h>6 )
			bubbleRoom(fr, TG.get("ClientThinkGood"), 0x6A862B);
		else
			bubbleRoom(fr, TG.get("ClientThinkNeutral"), 0xB39B48);
	}
	
	function updateTime() {
		if (hotel==null)
			return;
		if(curClock!=null) {
			curClock.counter.text = DateTools.format(date, "%H:%M");
			curClock.dots.visible = !curClock.dots.visible;
		}
		if(nextClock!=null) {
			nextClock.counter.text = DateTools.format(hotel._nextClient, "%H:%M");
			//nextClock.dots.visible = !nextClock.dots.visible;
		}
	}
	
	//function updateMoney() {
		//moneyCounter.field.text = ""+money;
	//}
	
	
	
	/*
	function makeReason(l:Likes, v:Int, from:FlashRoom, to:FlashRoom) {
		var str = "";
		
		var clientFrom = if (from != null) getClient(from.data.clientId) else null;
				
		str +=
			switch(l) { // TODO : améliorer ces phrases :)
				case FLOOR_TOP 	: " ";
				case FLOOR_DOWN : " ";
				case FLOOR_LEFT : " ";
				case FLOOR_RIGHT: " ";
				case NEIGHBOR 	: " ";
					if (clientFrom==null)
						if (v > 0) "Pas de voisin" else "Je me sens seul(e) !";
					else
						if (v > 0) "Cool un voisin @" else "Que fait ce type @ ?!";
				case NOISE :
					if (clientFrom==null)
						if (v > 0) "C'est calme" else "Pas un bruit, c'est nul !";
					else
						if (v > 0) "Yes, ça bouge @ !" else "C'est le bordel @ !";
				//case MOVE :
					//if (v > 0) "J'adore bouger !" else "J'aime pas qu'on me déplace";
				//case FLOOR(_) :
					//if( v>0 ) "J'aime bien cet étage !" else "Il craint cet étage...";
				case ODOR :
					if (clientFrom==null)
						if(v>0) "Aucune odeur bizarre" else "Ca sent rien ici..."
					else
						if(v>0) "Délicieux fumet @" else "Ca pue @ !";
				case WATER :
					if (from==null)
						if (v > 0) "C'est bien sec ici" else "Ca manque de fraicheur";
					else
						if (v > 0) "Fraicheur @" else "Voisin humide @";
				case FIRE :
					if(from==null) "Température normale" else "Ca chauffe @ !";
				case FOOD :
					if (from==null)
						if (v > 0) "Ca ne sent pas la bouffe" else "Y a rien à grignoter";
					else
						if (v > 0) "Il y a à manger @ !" else "Trop de bouffe @";
				//case QUALITY(_) :
					//"qualité TODO";
				//case FLOOR_PARITY(_) :
					//"floor parity (todo :p)";
				//case ROOM_DESTROYED :
					//"cette chambre est dans un sale état...";
			}
		
		// nécessite une localisation ?
		if (str.indexOf("@") >= 0) {
			var loc = "";
			if ( from.floor == to.floor ) {
				if (from.x==to.x-1)
					loc="à gauche";
				if (from.x==to.x+1)
					loc="à droite";
			}
			if ( from.x == to.x ) {
				if (from.floor==to.floor+1)
					loc="au dessus";
				if (from.floor==to.floor-1)
					loc="en dessous";
			}
			if ( from.x==to.x && from.floor==to.floor )
				loc = "dans cette chambre";
			str = StringTools.replace(str, "@", loc);
		}
		return "("+str+")";
	}*/
	
	
	function getLikeSentence(c:_Client) {
		var likeSentences = new Array();
		for (like in c._like)
			if(like!=_LUX_ROOM)
				likeSentences.push( TG.get("LIKE"+like) );
		likeSentences.sort(function(a,b) { return Reflect.compare(a.length, b.length); } );
		
		// dislikes
		var dislikeSentences = new Array();
		for (like in c._dislike)
			dislikeSentences.push( TG.get("DISLIKE"+like) );
		
		var final = "";
		if (likeSentences.length>0)
			final += TG.get("CLIENT_LIKES") +" "+ likeSentences.join(" "+TG.get("AND")+" ");
		if (dislikeSentences.length>0) {
			if (likeSentences.length>0)
				final+=TG.get("CLIENT_DISLIKES_TRANSITION")+" ";
			final += TG.get("CLIENT_DISLIKES") +" "+ dislikeSentences.join(" "+TG.get("AND")+" ");
		}
		final += ".";
		final = final.substr(0,1).toUpperCase() + final.substr(1);
		final = StringTools.replace(final, " ,", ",");
		return final;
	}
	
	function getSpreadSentence(c:_Client) {
		var fxList = Lambda.filter(c._effect, function(e) { return e._effect!=_NEIGHBOR && e._effect!=_JOY; });
		switch(fxList.length) {
			case 0 :
				return "";
			case 1 :
				return TG.get("THIS_CLIENT")+" "+TG.get("SPREAD"+fxList.first()._effect);
			case 2 :
				var first = TG.get("SPREAD"+fxList.first()._effect);
				first = StringTools.replace(first, ".", "");
				first = StringTools.replace(first, "!", "");
				var second = TG.get("SPREAD"+fxList.last()._effect);
				return TG.get("THIS_CLIENT")+" "+ first +" "+ TG.get("AND") +" "+ second;
			default :
				return "ERROR : too many spreads";
		}
	}
	
	/*
	function parseClient(c:_Client) {
		var cseed = hotel._id + c._id;
		var lines = new List();
		
		TG.initSeed(cseed);
		
		//lines.add( div(c._money+"{money}", "money") );
		lines.add(paragraph(c._name, "monsterName"));

		// likes
		lines.add( paragraph(getLikeSentence(c), "likes") );

		
		// spread
		lines.add( paragraph(getSpreadSentence(c), "spread") );
		
		// départ
		var fl_inqueue = getClientInQueue(c._id) != null;
		if ( fl_inqueue )
			// dans le file
			lines.add( paragraph(
				T.format.QueueLeaveDate({ _day:mt.deepnight.Lib.countDeltaDays(date, c._dateLeaving) }), "leaveDate"
			));

		// règle de type de monstre
		if ( fl_inqueue ) {
			var rule = T.getByKey("Rule"+Std.string(c._type).substr(3)); // on retire "_MF_"
			lines.add( paragraph(rule, "monsterRule") );
		}
		
		// happyness
		if ( c._happyLog.length > 0 ) {
			for (log in c._happyLog)
				if (log._n != 0 || log._mod==M_BASE)
					lines.add( paragraph(_Client.printHappyLog(log), "happyLine") );
			var h = Math.max(0, Math.min(_Client.MAX_HAPPYNESS, c._happyness));
			lines.add( paragraph(""+h,"happyTotal "+if(c._happyness<=_Client.MAX_HAPPYNESS*0.5) "negative" else "positive") );
		}
		
		
		return lines.join("");
	}*/
	
	private function getClient(id:Null<Int>) {
		if (id!=null && hotel._clients.exists(id))
			return hotel._clients.get(id);
		else
			return null;
	}
	
	
	
	function main(_) {
		mouse = new flash.geom.Point(root.mouseX, root.mouseY);
		TW.update();
		updateTip();
		updateCursor();
		
		//if(vscroll!=null)
			//vscroll.update();
		//if(hscroll!=null)
			//hscroll.update();
		
		//if ( scroller != null ) {
			//var spd = 10;
			//var xm = root.mouseX;
			//var ym = root.mouseY;
			//if (ym<=20)
				//scroller.y+=spd;
			//if (ym>=HEI-20)
				//scroller.y-=spd;
			//scroller.y = Math.max(0, Math.min(maxScrollY, scroller.y));
		//}
		
		if ( pending!=null )
			switch(pending) {
				case PA_PlaceDeco(d) :
					// preview du placement d'un objet de déco
					var m = new flash.geom.Point(root.mouseX, root.mouseY);
					var pt = building.globalToLocal(m);
					var f = Math.floor(-pt.y/FLOOR_HEI);
					if (f>=0 && f<hotel._floors) {
						var fmc = floorMcs[f];
						var fpt = fmc.globalToLocal(m);
						var pos = getDecoPos(d);
						var fwid = hotel._rooms[f].length*ROOM_WID;
						var fl_valid = fpt.x>=5 && fpt.x<=fwid-decoCursor.width-5 && (pos!=Floating || pos==Floating && fpt.y>-FLOOR_HEI+decoCursor.height);
						if (f==0 && (pos==Ground || pos==GroundStack || pos==GroundBase))
							fl_valid = true;
						if(fl_valid) {
							d._floor = f;
							d._x = Std.int(fpt.x-3);
							d._y = Std.int( Math.abs(fpt.y) );
							var pt = getDecoCoord(d);
							var pt = fmc.localToGlobal(pt);
							decoCursor.x = Std.int(pt.x);
							decoCursor.y = Std.int(pt.y);
							decoCursor.visible = true;
						}
					}
					else
						decoCursor.visible = false;
				default :
			}
		
		for (froom in frooms) {
			var range = if(froom.data._type==_TR_BEDROOM) 40 else 80;
			// clients dans leur chambre
			if ( froom.fclient != null ) {
				var fc = froom.fclient;
				var cmc = fc.mc;
				if ( !TW.exists(cmc, "x") ) {
					var tx = Std.random(range);
					cmc.scaleX = Math.abs(cmc.scaleX) * if (tx > cmc.x) 1 else -1;
					TW.create(cmc, "x", tx, TEase, Std.random(2500)+2000);
				}
				if( !fc.isFlying() )
					cmc.y = froom.fclient.y - Math.sin( (cmc.x / range) * Math.PI * 20 ) * 2;
				else {
					fc.clientMc.y = (1+fc.data._id%5) * Math.sin(fc.animStep);
					fc.animStep += 0.1;
				}
			}
			
			// staff dans une chambre
			var s = getStaff(froom.data);
			if ( s != null && froom.data._type != _TR_LOBBY ) {
				var mc = s.mc;
				if ( !TW.exists(mc, "x") ) {
					var tx = -5+Std.random(range);
					mc.scaleX = if (tx > mc.x) 1 else -1;
					//TW.create(mc, "x", tx, TEase, Std.random(2500)+2000);
					TW.create(mc, "x", tx, TEase, Std.random(1500)+2000);
				}
				mc.y = 70 - Math.sin( (mc.x/range)*Math.PI * 20 )*2;
			}
		}
			
		// anim du néon
		if (hotelName!=null && Std.random(1000) < 20 && hotelName!=null) {
			setNeonColor(0.5 + Std.random(3)/10);
			haxe.Timer.delay( callback(setNeonColor,1), Std.random(150)+20 );
		}
		
		// anim des hystériques
		for (fr in frooms)
			if ( fr.fclient != null && fr.fclient.data._type==_MF_SM )
				if (fr.fclient.mc.currentFrame==2 && Std.random(100)<5)
					fr.fclient.mc.play();
		
		// items flottants (à pickup)
		for (it in droppedItems) {
			it.mc.y = it.y + 5 * Math.sin(it.t);
			it.t+=0.1;
		}
		
		// clients volants
		for (fc in queue)
			if ( fc.isFlying() ) {
				fc.clientMc.y = (1+fc.data._id%5) * Math.sin(fc.animStep);
				fc.animStep += 0.1;
			}
		
		// messages aléatoires
		if (!fl_decoMode && nextThought>0 && date.getTime()>=nextThought) {
			var all = new Array();
			for (r in frooms)
				if (r.fclient!=null)
					all.push(r);
			if (all.length > 0) {
				var r = all[Std.random(all.length)];
				showClientThought(r);
				nextThought = DateTools.delta(date, 1000*RANDOM_THOUGHTS_DELAY.draw()).getTime();
			}
		}
		
		// anim nuages
		if( !isDragging() )
			for (c in clouds) {
				var mc = c.mc;
				mc.x+=c.spd;
				if (mc.x < -mc.width*0.5) {
					mc.x = WID + mc.width * 0.5;
					mc.y = Std.random(300);
				}
			}
	}
}

class GameJsApi {
	static function _unlockGame() {
		Game._unlockGame();
	}
	
	static function _onWheel(delta:Int) {
		Game.ME.applyWheelDelta(delta);
	}
	
	static function _onClickPage() {
		Game.ME.onClickPage();
	}
	
	static function _clientCall() {
		Game.ME.sendAction(P_CLIENT_CALL);
	}
	
	static function _payTax() {
		Game.ME.sendAction(P_PAY_TAX);
	}
	
	static function _onComment() {
		Game.ME.onMuxxuStartComment();
	}
}

