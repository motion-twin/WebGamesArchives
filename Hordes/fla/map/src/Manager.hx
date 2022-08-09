import mt.DepthManager;
import mt.Timer;
import mt.bumdum.Lib;
import MapCommon;
import flash.Key;
import Type;

typedef T_BG = {
	> flash.MovieClip,
	base	: flash.MovieClip,
	mask	: flash.MovieClip,
	blur	: flash.MovieClip,
	fog		: T_FOG,
}

typedef T_FOG = {
	> flash.MovieClip,
	holes	: flash.MovieClip,
}

typedef T_ARROW = {
	>flash.MovieClip,
	field		: flash.TextField,
	bg			: flash.MovieClip,
	iconEmpty	: flash.MovieClip,
	iconGather	: flash.MovieClip,
}

typedef T_TEXT_MC = {
	>flash.MovieClip,
	field	: flash.TextField,
	field2	: flash.TextField,
	bg		: flash.MovieClip
}

typedef T_ICON = {
	ox		: Float,
	oy		: Float,
	step	: Float,
	mc		: flash.MovieClip,
	glow	: flash.filters.GlowFilter,
	frame	: Int,
}

typedef T_Point = {
	x	: Int,
	y	: Int,
}

enum PHASE {
	Init;
	ReInit;
	Main;
	Server;
	Moving;
	Map;
	ExpList;
}

enum MAP_MODE {
	Normal;
	Tags;
	Global;
	Close;
}

class Manager {

	static var LCD			= 0xd7ff5b;
	static var RED			= 0xff6048;
	static var ICON_GLOW	= [null,RED,LCD];
	static var SCROLL_SPD	= 0.2; // 0.2 / 4
	static var MAX_SPD		= 4;
	static var FOCAL_BLUR	= 4;
	static var NIGHT		= null;
	static var PAN_MARGIN	= 40;
	static var PANNING		= 0.13;//0.07;
	static var HANG_LIMIT	= 32;
	static var LOW_FPS		= 18; // 22
	
	static var D		= [
		"cW85sip4sdvus%3F6%3E%60hvzre%7Ec%2C",
		"cW85sip4fvvus%3F6%3E%60hvzve%7Ec%2C",
		"%3F%60shpu%7E%3Evraus546erbzc%2C",
		"sl%60e%60%3Bbf9lrx%2Apts%3F6bn%20",
		"cW85sip4rvvus%3F6%3E%60hvzae%7Ec%2C",
		"c%0Au5shf4%2A%7D%60rn%3F6x%60h%7Fz%60e%7E%7C%2C",
		"A8shv%3F6c5pq3tmvw%7Ee%60%7Fc4xgz%2C",
		"2tg%3F65siqhq%7C%7E8bazncj4%60tce%40%2C",
		"yit%3F%7E%7Fs3aAwxOthf%7Cweekc%3B%23%3F%7F%2Asohh6",
		"yit%3F%7E%7Fs3sAdxOthg%7Cweekc%3B%23%3F%7F%2Asohh6",
		"du%7Fs%7D%3F6%3F%7Es%2Ag%7Fyr5eu%60%3Euh%7C%2CMcz4",
		"vu%7Fr%7D%3F6%3F%7Es%2Ag%7Fya5eu%60%3Euh%7C%2CMcz4",
		"Wushv%3F6c5r%3Eusp%7Fr%7Ee%60i%7C4%25az%2C",
		"%7B%3F%60tqhtsdg%3Bfow%23Mermw%3E%7F%7F%7C3m%2Ai6",
	];

	static var DANGER_COLORS : Array<Int> = [
		0xffff00, // 1-2
		0xffa040, // 3-4
		0xff0000, // 5-6
		0xff0000, // 7-8
		0x6873f4, // 9+
	];

	public var root		: flash.MovieClip;
	var dm				: DepthManager;
	var dms				: DepthManager;
	var dmBg			: DepthManager;
	var bg				: T_BG;
	var localFog		: T_FOG;
	var cx				: Int;
	var cy				: Int;
	var tx				: Float;
	var ty				: Float;
	var reqDx			: Int;
	var reqDy			: Int;
	var mapX			: Float;
	var mapY			: Float;
	var phase			: PHASE;
	var knownMap		: Array<Int>;
	var revealedMap		: Array<Array<Bool>>;
	var globalMap		: Array<Int>;
	var noise			: flash.MovieClip;
	var screen			: flash.MovieClip;
	var screenBmp		: flash.display.BitmapData;
	var screenDist		: flash.MovieClip;
	var starting		: T_TEXT_MC;
	var status			: T_TEXT_MC;
	var tip				: T_TEXT_MC;
	var over			: flash.MovieClip;
	var prevTip			: String;
	var prevTipX		: Float;
	var prevTipY		: Float;
	var psychoTimer		: Float;
	var psychoCD		: Float;

	var dispMap			: flash.display.BitmapData;
	var dispY			: Float;
	var fl_disp			: Bool;
	var scanner			: flash.MovieClip;
	var abList			: Array<flash.MovieClip>;

	var arrows			: Array<T_ARROW>;
	var raStep			: Float;
	var icons			: Array<T_ICON>;
	var zombies			: Int;
	var kills			: Int;
	var humans			: Int;
	var buildings		: Array<flash.MovieClip>;
	var oldMouse		: Float;
	var hangTimer		: Float;
	var alarm			: flash.MovieClip;

	var respCpt			: Int;
	var moves			: Int;
	var response		: OutMapResponse;
	var mapDetails		: Array<OutMapDetail>;
	var fl_danger		: Bool;
	var fl_map			: Bool;
	var fl_mapZoom		: Bool;
	var fl_betterMap	: Bool;
	var fl_tracker		: Bool;
	var hallu			: flash.MovieClip;
	public var wmapCont		: {>flash.MovieClip,left:flash.MovieClip,right:flash.MovieClip};
	public var wmapButtonCont	: flash.MovieClip;
	var soulsCont 		: flash.MovieClip;
	var wmapBmp			: flash.display.BitmapData;
	var mapStep			: Float;
	var mapButton		: T_TEXT_MC;
	var tagModeButton	: T_TEXT_MC;
	var globalModeButton: T_TEXT_MC;
	var zoomButton		: T_TEXT_MC;
	var expButton		: T_TEXT_MC;
	var black			: flash.MovieClip;
	var blackExp		: flash.MovieClip;
	var expButtons		: Array<T_TEXT_MC>;

	var expeditions		: Array<OutMapExpeditions>;
	var path			: String;
	var pathMC			: flash.MovieClip;
	var pathStep		: Int;

	var trackX			: Int;
	var trackY			: Int;
	var cityArr			: flash.MovieClip;
	var cityX			: Int;
	var cityY			: Int;

	var fl_townMode		: Bool;
	var fl_slow			: Bool;
	var fl_pathPreview	: Bool;
	var fl_pathEditor	: Bool;
	static var fl_disposed	: Bool;

	var lastCoord		: T_Point;
	var mapId			: Int;
	var zoneId			: Int;
	var users			: Array<OutMapCitizen>;
	var neightbours		: Array<Int>;
	var neigDrops		: Array<Bool>;
	
	static var GC_SAVE;
	
	/*------------------------------------------------------------------------
	CONSTRUCTOR
	------------------------------------------------------------------------*/
	public function new(r) {
		root = r;
		FlashMap.MANAGER = this;
		FlashMap.connect();

		/*** HACK : COMMENT THIS !! **
		
		#if !prod
		var str = '"'+MapCommon.encode("http://www.hordes.fr/swf/")+'",\n';
		str += '"'+MapCommon.encode("http://seb.hordes.fr/swf/")+'",\n';
		str += '"'+MapCommon.encode("http://dev.hordes/swf/")+'",\n';
		str += '"'+MapCommon.encode("http://dev.horde/swf/")+'",\n';
		str += '"'+MapCommon.encode("http://dev.hordes.fr/swf/")+'",\n';
		str += '"'+MapCommon.encode("http://en.hordes.com/swf/")+'",\n';
		str += '"'+MapCommon.encode("http://beta.hordes.fr/swf/")+'",\n';
		str += '"'+MapCommon.encode("http://local.hordes.de/swf/")+'",\n';
		str += '"'+MapCommon.encode("http://dev.dieverdammten.de/swf/")+'",\n';
		str += '"'+MapCommon.encode("http://www.dieverdammten.de/swf/")+'",\n';
		str += '"'+MapCommon.encode("http://www.die2nite.com/swf/")+'",\n';
		str += '"'+MapCommon.encode("http://dev.die2nite.com/swf/")+'",\n';
		str += '"'+MapCommon.encode("http://dev.hordas.com/swf/")+'",\n';
		str += '"'+MapCommon.encode("http://www.zombinoia.com/swf/")+'",\n';
		flash.System.setClipboard(str);
		trace(str);
		#end
		/***/

		dm = new DepthManager(root);
		screen = dm.empty(Const.DP_BG);
		dms = new DepthManager(screen);
		raStep = 0;
		hangTimer = 0;
		psychoTimer = 0;
		respCpt = 0;
		psychoCD = 200+Std.random(400); // 200+r(400)
		arrows = new Array();
		icons = new Array();
		buildings = new Array();
		abList = new Array();
		setPhase(Init);
		fl_slow = false;
		fl_disposed = false;
		fl_mapZoom = loadPref("zoom", TBool, false);
		if( fl_mapZoom && !isBigMap() ) {
			fl_mapZoom = false;
			savePref("zoom", false);
		}

		reqDx = 0;
		reqDy = 0;
		mapStep = 0;
		kills = 0;
		pathStep = -1;

		// init data
		var raw : String = Reflect.field(flash.Lib._root, "data");
		var data : OutMapInit;
		if( raw == null ) {
			return; // no local mode
		} else {
			try {
				raw = MapCommon.decode( raw );
				data = haxe.Unserializer.run(raw);
			} catch(e:Dynamic) {
				fatal("Unserialize failed ! ("+e+")");
				return;
			}
		}

		if( data._details == null ) {
			fatal();
			return;
		}

		expeditions = data._e;
		fl_townMode = data._town==true;
		mapDetails = data._details;
		
		Const.MWID = data._w;
		Const.MHEI = data._h;
		Const.init(data._b, data._city);
		cx = data._x;
		cy = data._y;
		moves = data._r._m;
		fl_slow = data._slow;

		fl_map = data._map;
		fl_betterMap = data._up;
		fl_tracker = fl_map && !fl_townMode;
		if( data._path != null && fl_townMode ) {
			if( data._path != "" ) {
				path = data._path;
			}
		}
		fl_pathEditor = data._editor==true;
		fl_pathPreview = (data._path!=null && !fl_pathEditor);
		users = data._users;

		zoneId = data._r._zid;
		mapId = data._mid;
		onResponse(data._r);

		if( !checkDomains() ) return;

		// night filter
		var matrix : Array<Float> = new Array();
		var nf = 0.0;
		if( data._hour >= 17 ) nf = Math.min(1, (data._hour-17)/3);
		if( data._hour <=  8 ) nf = Math.min(1, (8-data._hour)/3);
		matrix = matrix.concat( [inte(1, 0.5,nf)	,	0.0				,	0.3	,	0.0	,	0.0] );
		matrix = matrix.concat( [0.0				,	inte(1, 0.7,nf)	,	0.4	,	0.0	,	0.0] );
		matrix = matrix.concat( [inte(0, 0.2,nf)	,	inte(0, 0.1,nf)	,	1.5	,	0.0	,	0.0] );
		matrix = matrix.concat( [0.0				,	0.0				,	0.0	,	1.0	,	0.0] );
		NIGHT = new flash.filters.ColorMatrixFilter(matrix);
		// base map
		bg = cast dms.empty(Const.DP_BG);
		bg.base = bg.attachMovie("bg","base",Const.uniq++);
		bg.base.filters = [NIGHT];
		bg.blur = bg.attachMovie("bg","blur",Const.uniq++);
		bg.mask = bg.attachMovie("mask","mask",Const.uniq++);
		bg.blur.filters = [ NIGHT, new flash.filters.BlurFilter(FOCAL_BLUR,FOCAL_BLUR) ];
		bg.blur.setMask(bg.mask);
		var mc = bg.createEmptyMovieClip("base",Const.uniq++);
		mc.cacheAsBitmap = true;
		dmBg = new DepthManager(mc);
		// fog of war v2
		localFog = cast dms.empty(Const.DP_FOG);
		localFog.smc = localFog.createEmptyMovieClip("blackMC",Const.uniq++);
		localFog.holes = localFog.createEmptyMovieClip("holesMC",Const.uniq++);
		localFog.smc.beginFill(0x330000);
		localFog.smc.moveTo(-Const.WID,-Const.HEI);
		localFog.smc.lineTo(Const.WID*2, -Const.HEI);
		localFog.smc.lineTo(Const.WID*2, Const.HEI*2);
		localFog.smc.lineTo(-Const.WID, Const.HEI*2);
		localFog.smc.moveTo(-Const.WID,-Const.HEI);
		localFog.smc.endFill();
		localFog.holes.blendMode = "erase";
		localFog.blendMode = "layer";
		localFog.filters = [ new flash.filters.BlurFilter(64,64,2) ];
		localFog.cacheAsBitmap = true;
		revealedMap = new Array();
		for( x in 0...Const.MWID )
			revealedMap[x] = new Array();

		bg.base.cacheAsBitmap = true;
		bg.blur.cacheAsBitmap = true;

		// first fog reveals
		knownMap = new Array();
		globalMap = new Array();
		var x=0;
		var y=0;
		for( c in data._view ) {
			knownMap.push(c);
			if( c != null ) {
				revealFog(x,y);
				if( c != 0 ) {
					addBuilding(c,x,y);
					if( c == 1 ) {
						cityX = x;
						cityY = y;
					}
				}
			}
			x++;
			if( x >= Const.MWID ) {
				x=0; y++;
			}
		}
		for( c in data._global )
			globalMap.push(c);
		redrawFog();

		lastCoord = {x : cityX, y : cityY};
		printMap(knownMap);

		var cookie = flash.SharedObject.getLocal("mapTrack");
		if( cookie.data.tx != null && mapId == cookie.data.mapId ) {
			trackX = cookie.data.tx;
			trackY = cookie.data.ty;
		} else {
			trackX = cityX;
			trackY = cityY;
		}
		if( !fl_pathPreview && !fl_pathEditor && cookie.data.pathId != null ) {
			var id = cookie.data.pathId;
			for( e in expeditions ) {
				if( e._i == id ) path = e._p;
			}
			pathStep = cookie.data.pathStep;
			if( path == null ) {
				cookie.data.pathStep = -1;
				cookie.data.pathId = null;
				cookie.flush();
			}
		}

		var pathList = path.split(MapCommon.GroupSep);
		if( pathList.length > 0 ) {
			var c = pathList[ pathList.length-1 ].split(MapCommon.CoordSep);
			lastCoord = { x:Std.parseInt(c[0]), y:Std.parseInt(c[1]) } ;
		}

		// darkness radius
		var mc = dms.attach("dark",Const.DP_FX);
		mc._x = Const.WID*0.5;
		mc._y = Const.HEI*0.5;
		mc._alpha = 90;
		// FX : noise
		noise = dm.attach("fx_noise",Const.DP_FX);
		noise._alpha = 0;
		// FX :displacement map
		var dispMapMC = dm.attach("fx_dispMap",Const.DP_FX);
		dispMap = new flash.display.BitmapData(Const.WID,Const.HEI);
		dispMap.draw(dispMapMC);
		dispMapMC.removeMovieClip();
		fl_disp = false;
		screenBmp = new flash.display.BitmapData(Const.WID,Const.HEI,false,0x0);
		screenDist = dm.empty(Const.DP_BG);
		screenDist.attachBitmap(screenBmp,0);
		screenDist._visible = false;
		// graphical top interface
		mc = dm.attach("interf",Const.DP_INTERF);
		// Top field
		status = cast dm.attach("field",Const.DP_INTERF);
		initField(status);
		clearStatus();
		// initializing msg
		starting = cast dm.attach("field", Const.DP_INTERF);
		starting._x = Const.WID*0.5;
		starting._y = Const.HEI*0.5;
		initField(starting);
		starting.bg._visible = false;
		starting.field.text=Lang.get.starting;
		// tool tip
		tip = cast dms.attach("field",Const.DP_INTERF);
		tip.field._width = 130;
		tip.field._x = -tip.field._width*0.5;
		initField(tip);
		tip.field.filters = [ new flash.filters.GlowFilter( LCD,1, 6,6,1 ) ];
		// Map button
		if( fl_map ) {
			GC_SAVE = callback(showMap, Normal);
			mapButton = attachButton( 1, Lang.get.map, GC_SAVE );
		} else {
			mapButton = attachButton( 1, Lang.get.map, null );
		}
		mapButton._visible = false;
		// Expeditions button
		if( !fl_pathPreview && !fl_pathEditor ) {
			expButton = attachButton( 4, Lang.get.expedition, callback(showExpList) );
			expButton._x = Const.WID-expButton._width;
			expButton._visible = false;
		}
		
		// Map : tags mode
		tagModeButton = attachButton( 2, Lang.get.mapModeTags, callback(showMap,Tags) );
		if( !fl_townMode )
			tagModeButton._x += 65;
		tagModeButton._visible = false;

		// Map : global mode
		globalModeButton = attachButton( 2, Lang.get.mapModeGlobal, callback(showMap,Global) );
		if( !fl_townMode )
			globalModeButton._x += 130;
		globalModeButton._visible = false;

		// Map : zoom toggle
		zoomButton = attachButton( if(fl_mapZoom) 8 else 7, "", callback(showMap,Global) );
		zoomButton._x = 196;
		zoomButton._visible = false;

		
		
		if( fl_tracker ) {
			cityArr = dms.attach("cityArrow",Const.DP_TOP);
			cityArr._x = Const.WID*0.5;
			cityArr._y = Const.HEI*0.5;
			cityArr.gotoAndStop(1);
			cityArr._alpha = 0;
			cityArr.filters = [ new flash.filters.GlowFilter(LCD,1, 6,6,2) ];
		}

		setTarget(cx,cy);
		mapX = tx;
		mapY = ty;
		updateScroll(0,0);
		black = dms.attach("blackMask",Const.DP_INTERF);
		black._alpha = Const.BLACK_ALPHA;

		if( fl_townMode ) {
			setPhase(Main);
			mapButton.removeMovieClip();
			showMap(Normal);
			wmapCont.left.removeMovieClip();
		} else {
			black._visible = false;
		}

		if( phase == Init ) {
			if( FlashMap.isJsReady() ) {
				setPhase(ReInit);
				FlashMap.askInfos();
			}
		}
		
	}

	function checkDomains() {
		var shortUrl = root._url.substr(0, root._url.indexOf("map"));
		for( url in D ) {
			if( MapCommon.encode(shortUrl) == url ) {
				return true;
			}
		}
		fatal("ckdm");
		return false;
	}

	function modeToString(e:MAP_MODE) {
		switch(e) {
			case Normal	: return "Normal";
			case Tags	: return "Tags";
			case Global	: return "Global";
			case Close	: return "Close";
		}
		return "UNKNOWN !";
	}

	function setPhase(p:PHASE) {
		if( p == phase )
			return;
		phase = p;
	}

	public static function fatal(?e:String) {
		if( e != null ) Boot.log("FATAL : "+e);
		if( !fl_disposed ) flash.Lib._root.gotoAndStop(2);
		Reflect.deleteField(flash.Lib._root, "onEnterFrame");
	}

	function inte(min:Float, max:Float, fact:Float):Float {
		return min + (max - min) * fact;
	}

	function savePref(name:String, value:Dynamic) {
		var cookie = flash.SharedObject.getLocal("mapPrefs");
		Reflect.setField(cookie.data, name, value);
		cookie.flush();
	}

	function loadPref(name:String, type:ValueType, defValue:Dynamic) {
		var cookie = flash.SharedObject.getLocal("mapPrefs");
		if( Reflect.hasField(cookie.data, name) ) {
			var v = Reflect.field(cookie.data, name);
			if( Type.typeof(v) != type )
				return defValue;
			else
				return v;
		}
		else
			return defValue;
	}

	/*------------------------------------------------------------------------
	DESTRUCTION (IE FIX)
	------------------------------------------------------------------------*/
	public function dispose() {
		if( fl_disposed ) return;
		screenBmp.dispose();
		dispMap.dispose();
		wmapBmp.dispose();
		dm.destroy();
		dms.destroy();
		dmBg.destroy();
		// classes
		Reflect.deleteField(flash.Lib._global, "api");
		Reflect.deleteField(root, "onEnterFrame");
		Reflect.deleteField(flash.Lib._root, "onEnterFrame");
		Boot.man = null;

		fl_disposed = true;
		flash.Lib._root.gotoAndStop(1);
		root.removeMovieClip();
	}

	/*------------------------------------------------------------------------
	FPS CHECK
	------------------------------------------------------------------------*/
	function fpsOk() {
		if( phase == Moving ) return false;
		var flag = Timer.fps() >= LOW_FPS;
		if( !flag ) {
			fl_slow = true;
			screenBmp.dispose();
			screenBmp = null;
		}
		return flag && !fl_slow;
	}

	/*------------------------------------------------------------------------
	UPDATE SCROLLING
	------------------------------------------------------------------------*/
	function updateScroll(ox:Float, oy:Float) {
		var maxSpd = MAX_SPD;
		var scrSpd = SCROLL_SPD * Timer.tmod;
		var dx = Math.max(-maxSpd, Math.min(maxSpd,(tx+ox*PANNING-mapX)*scrSpd) );
		var dy = Math.max(-maxSpd, Math.min(maxSpd,(ty+oy*PANNING-mapY)*scrSpd) );
		mapX += dx;
		mapY += dy;
		// bleep icons
		for( icon in icons ) {
			icon.mc._x += Math.floor(mapX)-bg._x;
			icon.mc._y += Math.floor(mapY)-bg._y;
		}
		if( moveMap(mapX, mapY) ) {
			// fog
			localFog._x += dx;
			localFog._y += dy;
			// buildings blur
			var centX = Const.WID*0.5;
			var centY = Const.HEI*0.5;
			for( b in buildings ) {
				var x = b._x+mapX;
				var y = b._y+mapY;
				var d = Math.max( Math.abs(x-centX), Math.abs(y-centY) );
				var fact = Math.min( 1, d/Const.CWID ); // **** WARNING: this supposes wid==hei
				b.filters = [ NIGHT, new flash.filters.BlurFilter(fact*FOCAL_BLUR,fact*FOCAL_BLUR) ];
			}
		}

		if( Math.abs(mapX-tx) <= 0.5 && Math.abs(mapY-ty) <= 0.5 ) {
			mapX = tx;
			mapY = ty;
			onArrive();
		}
	}

	/*------------------------------------------------------------------------
	CHANGE SCROLLING TARGET
	------------------------------------------------------------------------*/
	function setTarget(cx, cy) {
		tx = Const.WID*0.5 - Const.CWID*0.5 - cx*Const.CWID;
		ty = Const.HEI*0.5 - Const.CHEI*0.5 - cy*Const.CHEI;
	}

	function revealFog(x, y) {
		revealedMap[x][y] = true;
	}

	function redrawFog() {
		if( fl_townMode || fl_pathEditor )
			return;
		localFog._x = Const.CWID;
		localFog._y = Const.CHEI;
		localFog.holes.clear();
		for( x in -2...3 )
			for( y in -2...3 )
				if( revealedMap[cx+x][cy+y] == true ) {
					localFog.holes.beginFill(0x0);
					localFog.holes.moveTo(x*Const.CWID,		y*Const.CHEI);
					localFog.holes.lineTo((x+1)*Const.CWID,	y*Const.CHEI);
					localFog.holes.lineTo((x+1)*Const.CWID,	(y+1)*Const.CHEI);
					localFog.holes.lineTo(x*Const.CWID,		(y+1)*Const.CHEI);
					localFog.holes.lineTo(x*Const.CWID,		y*Const.CHEI);
					localFog.holes.endFill();
				}
	}

	/*------------------------------------------------------------------------
	CHANGE MAP COORDS
	------------------------------------------------------------------------*/
	function moveMap(x, y) {
		if( bg._x != Math.floor(x) || bg._y != Math.floor(y) ) {
			bg._x = Math.floor(x);
			bg._y = Math.floor(y);
			bg.mask._x = -bg._x;
			bg.mask._y = -bg._y;
			var zx = Math.floor( (-bg._x+Const.CWID)/(Const.CWID*Const.BGWID) );
			var zy = Math.floor( (-bg._y+Const.CHEI)/(Const.CHEI*Const.BGHEI) );
			bg.base._x = zx*(Const.CWID*Const.BGWID);
			bg.base._y = zy*(Const.CHEI*Const.BGHEI);
			bg.blur._x = zx*(Const.CWID*Const.BGWID);
			bg.blur._y = zy*(Const.CHEI*Const.BGHEI);
			return true;
		} else
			return false;
	}

	/*------------------------------------------------------------------------
	EVENT: END OF SCROLLING
	------------------------------------------------------------------------*/
	function onArrive() {
		if( phase != Moving ) return;
		if( icons.length == 0 ) {
			var rseed = new mt.Rand(cx+cy*Const.MWID);
			for( i in 0...response._h ) {
				if( i == 0 ) {
					addIcon(null, 2); // me
				} else {
					addIcon(rseed, 2); // human
				}
			}
			for( i in 0...response._z ) {
				addIcon(rseed,1); // zombie
			}
			for( i in 0...kills ) {
				addIcon(rseed,3); // kills
			}
			if( icons.length > 0 ) {
				scan();
			}
		}
		raStep = 0;
		moveMap(tx, ty);
		redrawFog();
		setStatus(Lang.get.pos+" "+coords(cx, cy, false));
		setPhase(Main);
	}

	/*------------------------------------------------------------------------
	EVENT: MOVE BUTTON PRESSED
	------------------------------------------------------------------------*/
	function onMove(dx,dy) {
		if( phase != Main ) return;
		if( moves <= 0 ) return;
		scanner.removeMovieClip();
		reqDx = dx;
		reqDy = dy;
		setPhase(Server);
		clearStatus();
		for( mc in arrows )
			Reflect.deleteField(mc,"onRelease");
		FlashMap.move(zoneId,dx,dy);
	}


	/*------------------------------------------------------------------------
	EVENTS: BUILDINGS ROLLOVERS
	------------------------------------------------------------------------*/
	function onOverBuilding(mc:flash.MovieClip, txt:String) {
		if( phase == Map ) return;
		tip.field.text = txt;
		tip.bg._visible = true;
		tip.bg._width = tip.field.textWidth+10;
		tip.bg._height = tip.field.textHeight;
		prevTip = txt;
		over = mc;
	}

	function onOutBuilding() {
		tip.field.text = "";
		tip.bg._visible = false;
		prevTip = "";
	}

	/*------------------------------------------------------------------------
	EVENT: MAP ZONES ROLLOVERS
	------------------------------------------------------------------------*/
	function onOverMapZone(mc:flash.MovieClip,txt,?txt2) {
		// local to global
		var x = mc._x;
		var y = mc._y;
		var parent = mc._parent;
		while( parent != null ) {
			x += parent._x;
			y += parent._y;
			parent = parent._parent;
		}
		// tooltip
		mc._alpha = 75;
		mc.filters = [ new flash.filters.GlowFilter(LCD,1, 6,6,2) ];
		if( txt2 == null )
			setStatus( txt, x+mc._width*0.5, y-5 );
		else
			setStatus( txt, txt2, x+mc._width*0.5, y-5 );
	}

	function onOutMapZone(mc:flash.MovieClip) {
		mc._alpha = 0;
		mc.filters = [];
		clearStatus();
	}

	function onSelectZone(x:Int,y:Int) {
		if( fl_pathEditor ) {
			if( path.length > MapCommon.MaxPathStringLength ) return;
			if( x != lastCoord.x && y != lastCoord.y ) return;
			if( x == lastCoord.x && y == lastCoord.y ) return;
			if( x == cityX && y == cityY ) return;
			lastCoord = {x:x,y:y};
			if( path == null ) {
				path = x+":"+y;
			} else {
				path += "|"+x+":"+y;
			}
			showMap(Normal);
			FlashMap.sendCoord(cityX, cityY, x, y);
		} else {
			if( fl_townMode ) return;
			if( fl_tracker )
				setTracker(x, y);
			hideMap();
		}
	}

	function setTracker(x,y) {
		trackX = x;
		trackY = y;
		var cookie = flash.SharedObject.getLocal("mapTrack");
		cookie.data.tx = trackX;
		cookie.data.ty = trackY;
		cookie.data.mapId = mapId;
		cookie.flush();
	}

	/*------------------------------------------------------------------------
	UPDATE STATUS FIELD
	------------------------------------------------------------------------*/
	function setStatus(txt:String,?txt2:String,?x:Float,?y:Float) {
		if( psychoTimer > 0 ) {
			psychoCD = Std.random(100);
			resetPsychoField(status);
		}
		status.field.text = txt;
		if( txt2 != null ) {
			status.field2.text = txt2;
			status.field2._y = status.field._y+status.field.textHeight;
		} else {
			status.field2.text = "";
		}
		var w = Math.max(status.field.textWidth, status.field2.textWidth);
		if( x != null ) {
			x = Math.min(Const.WID-w*0.5-6, x);
			x = Math.min(Const.WID-w*0.5-6, x);
			x = Math.max(w*0.5+6, x);
			y = Math.max(22, y);
			status._x = Math.floor(x);
			status._y = Math.floor(y);
			status.bg._visible = true;
			status.bg._width = w+10;
			status.bg._height = status.field.textHeight + status.field2.textHeight;
		} else {
			status.bg._visible = false;
			status._x = Const.WID-w*0.5-10;
			status._y = Const.HEI-18;
		}
	}

	function clearStatus() {
		status.bg._visible = false;
		status.field.text = "";
		status.field2.text = "";
	}

	/*------------------------------------------------------------------------
	EVENT: SERVER RESPONSE
	------------------------------------------------------------------------*/
	public function onResponse(r:OutMapResponse) {
		if( fl_disposed ) return;
		if( !checkDomains() ) return;
		response = r;
		if( phase == Server && zoneId == r._zid ) {
			FlashMap.reboot();
			return;
		}
		respCpt ++;
		neightbours = r._neig;
		neigDrops = r._neigDrops;
		if( zombies == null ) zombies = r._z;
		if( humans == null ) humans = r._h;

		if( reqDx != 0 || reqDy != 0 ) {
			kills = 0;
			revealFog(cx+reqDx, cy+reqDy);
			redrawFog();
			cx += reqDx;
			cy += reqDy;
			if( mapGet(cx,cy) == null && r._c != null && r._c != 0 ) {
				addBuilding(r._c, cx, cy);
			}
			mapSet(cx, cy, r._c);
		} else {
			// not a move, update only
			if( r._z != zombies || r._h != humans ) {
				for( icon in icons ) {
					icon.mc.removeMovieClip();
				}
				icons = new Array();
			} else {
				for( icon in icons ) {
					icon.step = 0.9;
				}
			}
			if( r._z != zombies ) {
				kills += Std.int( Math.max(0, zombies-r._z) );
			}
			if( phase == Map ) {
				hideMap();
			}
		}

		trackPath(path);
		zombies = r._z;
		humans = r._h;
		zoneId = r._zid;

		if( mapDetails != null ) {
			var s = false;
			if( mapDetails[cx + cy * Const.MWID] != null ) s = mapDetails[cx + cy * Const.MWID]._s;
			var detail : OutMapDetail = {
				_z	: r._z,
				_c	: r._c,
				_t	: r._t,
				_nvt: false,
				_s : s,
			}
			mapDetails[cx+cy*Const.MWID] = detail;
		}

		if( phase != Init ) setPhase(Moving);
		setTarget(cx, cy);
		fl_danger = r._state;
		moves = r._m;
		if( moves <= 0 ) {
			for( mc in arrows ) mc.removeMovieClip();
			arrows = new Array();
		}
		reqDx = 0;
		reqDy = 0;
	}

	public function onAskedMeIfReady() {
		if( phase == Init ) setPhase(Moving);
	}

	function initField(f:T_TEXT_MC) {
		f.field.text = "";
		f.field2.text = "";
		f.bg._visible = false;
		f.bg.filters = [ new flash.filters.GlowFilter(LCD,1, 3,3,3) ];
		f.bg._alpha = 60;
	}

	/*------------------------------------------------------------------------
	CREATES A BUTTON
	------------------------------------------------------------------------*/
	function attachButton(frame, label, cb) {
		var but : T_TEXT_MC = cast dm.attach("mapButton",Const.DP_INTERF);
		but._x = 2;
		but._y = Const.HEI-17;
		but.gotoAndStop(frame);
		if( cb != null ) {
			but.field.text = label;
			if( frame == 5 || frame == 6 )  {
				but.onRollOver = function() { but._alpha=100; but.filters = [ new flash.filters.GlowFilter(LCD,0.8, 4,4, 6) ]; };
				but.onRollOut = function() { but._alpha=70; but.filters = []; };
			} else {
				but.onRollOver = function() { but.filters = [ new flash.filters.GlowFilter(0xf0d79e,1, 3,3, 3) ]; };
				but.onRollOut = function() { but.filters = []; };
			}
			but.onRelease = cb;
		} else {
			but.field.text = label;
			but._alpha = Const.OFF_ALPHA;
		}
		return but;
	}

	/*------------------------------------------------------------------------
	ATTACH SINGLE ARROW
	------------------------------------------------------------------------*/
	function attachArrow(x,y,rot,cb,fl_on, info:Int, hasDrops:Bool) {
		if( fl_townMode ) return;
		var mc : T_ARROW = cast dms.attach("arrow",Const.DP_INTERF);
		mc._x = x;
		mc._y = y;
		mc.bg._rotation = rot;
		mc.bg.gotoAndStop(1);
		if( info != null ) {
			var danger = 1;
			if( info > 4 ) danger=2;
			if( info > 8 ) danger=3;
			mc.bg.gotoAndStop(danger);
			if( info <= 0 ) {
				mc.field._visible = false;
			} else {
				mc.field.text = Std.string(info);
				mc.field.filters = [ new flash.filters.GlowFilter(0x0,0.5, 6,6,1) ];
			}
		} else {
			mc.field._visible = false;
		}

		mc.iconGather._visible = false;
		mc.iconEmpty._visible = false;
		if( hasDrops != null ) {
			if( hasDrops ) {
				mc.iconGather._visible = true;
			} else {
				mc.iconEmpty._visible = true;
				mc.bg.gotoAndStop(3);
			}
		}
		mc._alpha = 0;
		if( fl_on ) {
			mc.onRelease = cb;
			mc.onRollOver = function() { mc.filters = [ new flash.filters.GlowFilter(LCD,0.5, 4,4, 6) ]; };
			mc.onRollOut = function() { mc.filters = []; };
		} else {
			Reflect.deleteField(mc,"onRelease");
			mc._visible = false;
		}
		arrows.push(mc);
	}


	/*------------------------------------------------------------------------
	ADDS A SPECIAL BUILDING
	------------------------------------------------------------------------*/
	function addBuilding(id:Int,x,y) {
		var mc = dmBg.attach("building",Const.DP_BG);
		var rs = new mt.Rand(x+y*Const.MWID);
		var ox = rs.random(20)*(rs.random(2)*2-1);
		var oy = rs.random(20)*(rs.random(2)*2-1);
		mc._x = Math.floor( x*Const.CWID + Const.CWID*0.5 + ox );
		mc._y = Math.floor( y*Const.CHEI + Const.CHEI*0.5 + oy );

		if( id == -1 ) {
			mc.gotoAndStop(70);
		} else {
			mc.gotoAndStop(id);
		}

		mc.filters=[NIGHT];
		mc.cacheAsBitmap = true;
		if( !fl_townMode ) {
			if( id == -1 ) {
				mc.onRollOver = callback(onOverBuilding,mc,Lang.get.undigged);
				mc.onRollOut= callback(onOutBuilding);
				mc.useHandCursor = false;
			}
			if( Const.BUILDING_NAMES[id] != null ) {
				mc.onRollOver = callback(onOverBuilding,mc,Const.BUILDING_NAMES[id]);
				mc.onRollOut= callback(onOutBuilding);
				mc.useHandCursor = false;
			}
		}
		buildings.push(mc);
	}

	/*------------------------------------------------------------------------
	ATTACH AN HIDDEN ACTIVE BOX OVER A MC
	------------------------------------------------------------------------*/
	function addActiveBox(parent:flash.MovieClip, mc:flash.MovieClip, cb) {
		var ab = parent.attachMovie("activeBox", "activeBox_"+Const.uniq, Const.uniq++);
		ab._alpha = 0;
		ab._x = mc._x;
		ab._y = mc._y;
		ab._width = mc._width;
		ab._height = mc._height;
		ab.onRelease = cb;
		ab.onReleaseOutside = cb;
		abList.push(ab);
		return ab;
	}

	/*------------------------------------------------------------------------
	ADDS AN ICON
	------------------------------------------------------------------------*/
	function addIcon(rseed:mt.Rand,frame:Int) {
		if( fl_townMode ) return;
		var mc = dms.attach("icons",Const.DP_INTERF);
		if( rseed == null ) {
			mc._x = Const.WID*0.5;
			mc._y = Const.HEI*0.5;
		} else {
			mc._x = rseed.random( Math.floor(Const.CWID*0.7) )+Const.CWID*1.15;
			mc._y = rseed.random( Math.floor(Const.CHEI*0.7) )+Const.CHEI*1.15;
		}
		mc.gotoAndStop(1);
		mc._alpha = 0;
		var glow = null;
		if( ICON_GLOW[frame] != null ) {
			glow = new flash.filters.GlowFilter(ICON_GLOW[frame],0.7, 3,3,4);
		}
		mc.blendMode = "add";
		icons.push( {ox:mc._x, oy:mc._y, step:0.0,mc:mc,glow:glow,frame:frame} );
		// z-sort
		icons.sort( function(a,b) {
			if( a.mc._y > b.mc._y ) return 1;
			if( a.mc._y < b.mc._y ) return -1;
			return 0;
		} );
		for( icon in icons ) {
			dms.over(icon.mc);
		}
	}

	/*------------------------------------------------------------------------
	ATTACH SCANNER
	------------------------------------------------------------------------*/
	function scan() {
		if( fl_townMode ) return;
		scanner.removeMovieClip();
		scanner = dm.attach("fx_scan",Const.DP_FX);
		scanner.blendMode = "add";
		scanner._alpha = 20;
	}

	/*------------------------------------------------------------------------
	MAP GETTER/SETTER
	------------------------------------------------------------------------*/
	function mapGet(x, y) {
		return knownMap[x + y * Const.MWID];
	}

	function mapSet(x:Int, y:Int, v:Int) {
		return knownMap[x + y * Const.MWID] = v;
	}

	function isBigMap() {
		return Const.MWID >= Const.BIG_MAP_WID;
	}

	function getMapScale() {
		if( fl_mapZoom )
			return Math.min( Const.WID*0.9 / (30*Const.BIG_MAP_WID), Const.HEI*0.9 / (30*Const.BIG_MAP_WID) );
		else
			return Math.min( Const.WID*0.9 / (30*Const.MWID), Const.HEI*0.9 / (30*Const.MHEI) );
	}

	function coords(x:Int,y:Int, ?fl_full=true) {
		var c = MapCommon.coords(cityX,cityY, x,y);
		if( fl_full )
			return "[ "+c.x+c.sep+c.y+" ]";
		else
			return c.x+c.sep+c.y;
	}

	/*------------------------------------------------------------------------
	PRINT THE MAP ON OUTPUT
	------------------------------------------------------------------------*/
	function printMap(list:Array<Int>) {
		var x=0;
		var y=0;
		var str = "\n   ";
		for( i in 0...Const.MWID ) {
			if(i < 10) str+=i+" "; else str+=i+"";
		}
		str += "\n0  ";
		for (c in list) {
			if(c != null) {
				str += ""+c;
			} else {
				str += "·";
			}
			if( cx == x && cy == y ) {
				str = str.substr(0,str.length-1);
				str += "x";
			}
			x++;
			str+=" ";
			if(x >= Const.MWID) {
				x=0; y++;
				if( y < Const.MHEI ) {
					if( y < 10 ) str+="\n"+y+"  "; else str+="\n"+y+" ";
				}
			}
		}
	}

	/*------------------------------------------------------------------------
	DISPLAY WORLD MAP
	------------------------------------------------------------------------*/
	static var souls : Array<SoulBehaviour> = [];
	function showMap(mode:MAP_MODE) {
		Boot.log("showMap "+mode);
		if( !checkDomains() ) return;
		if( phase == Init || phase == ReInit ) return;
		if( mode == null ) {
			fatal("map mode is null !");
			return;
		}
		
		for( soul in souls ) {
			soul.dispose();
		}
		
		if( mode == Close && wmapCont != null ) {
			hideMap();
			return;
		}
		if( mode != Close && wmapCont != null ) {
			if( fl_townMode ) {
				for( mc in abList ) mc.removeMovieClip();
				abList = new Array();
			} else {
				hideMap();
			}
			removeMapMCs();
		}
		if( phase != Main ) return;
		// buttons
		if( !fl_townMode ) {
			globalModeButton.gotoAndStop(2);
			globalModeButton._visible = true;
			globalModeButton.onRelease = callback(showMap,Global);
		}
		tagModeButton.gotoAndStop(2);
		tagModeButton._visible = true;
		tagModeButton.onRelease = callback(showMap,Tags);
		switch(mode) {
			case Tags :
				tagModeButton.gotoAndStop(3);
				tagModeButton.onRelease = callback(showMap,Normal);
				globalModeButton.gotoAndStop(3);
				globalModeButton.onRelease = callback(showMap,Normal);
			case Global :
				globalModeButton.gotoAndStop(3);
				globalModeButton.onRelease = callback(showMap,Normal);
			default :
		}
		globalModeButton.field.text = Lang.get.mapModeGlobal;
		tagModeButton.field.text = Lang.get.mapModeTags;
		mapButton.gotoAndStop(4);
		mapButton.field.text = Lang.get.close;
		mapButton.onRelease = callback(showMap,Close);
		expButton._visible = true;
		zoomButton._visible = isBigMap();
		zoomButton.onRelease = callback(toggleZoom,mode);

		for( ic in icons )
			ic.mc._visible = false;

		wmapBmp = new flash.display.BitmapData(Const.WID*2, Const.HEI*2, true, 0x0);

		var ratio = Math.min( Const.WID/bg._width, Const.HEI/bg._height );
		wmapCont = cast dms.empty(Const.DP_INTERF);
		wmapButtonCont = cast dms.empty(Const.DP_INTERF);
		
		
		var dmm = new DepthManager(wmapCont);
		if( !fl_townMode ) {
			black._alpha = 0;
		}
		black._visible = true;
		cityArr._alpha = 35;

		// map
		var x = 0;
		var y = 0;
		var n = 0;
		var scale = getMapScale();
		var grid = dmm.empty(Const.DP_BG);
		var tags = grid.createEmptyMovieClip("tags", Const.uniq++);
		var map = if(fl_townMode || mode == Global || mode == Tags) globalMap else knownMap;
		for( c in map ) {
			var rseed = new mt.Rand(x + y * Const.MWID);
			var mc = grid.attachMovie("mapIcon", "icon_"+Const.uniq, Const.uniq++);
			mc._x = Math.floor(Const.WID * 0.05 + x * 30 * scale);
			mc._y = Math.floor(Const.HEI * 0.03 + y * 30 * scale);
			mc._xscale = scale * 100;
			mc._yscale = scale * 100;
			var ab = addActiveBox(wmapButtonCont, mc, callback(onSelectZone, x, y) );
			ab.onRollOut = callback(onOutMapZone,ab);
			ab.onReleaseOutside = ab.onRollOut;
			// scout infos
			var zdetails = null;
			var fl_inFog = (c == null);
			if( mapDetails != null ) {
				var detail = mapDetails[n];
				if( detail._z > 0 ) {
					if( fl_betterMap ) {
						zdetails = detail._z+" "+Lang.get.zombie+(if(detail._z > 1) "s" else "");
					} else {
						switch(MapCommon.zombieDanger(mapId + x + y * Const.MWID, detail._z, fl_betterMap)) {
							case 0	: zdetails = Lang.get.fewZombies;
							case 1	: zdetails = Lang.get.medZombies;
							default	: zdetails = Lang.get.manyZombies;
						}
					}
				}
	
				var uCpt = 0;
				if( fl_townMode && (x != cityX || y != cityY) ) {
					var ulist = new Array();
					for( u in users ) {
						if( u._x == x && u._y == y ) {
							ulist.push(u._n);
						}
					}
					uCpt = ulist.length;
					if( ulist.length > 0 ) {
						if( zdetails == null )
							zdetails=ulist.join(", ");
						else
							zdetails += "\n"+ulist.join(", ");
					}
				}
				if( fl_inFog ) {
					mc.gotoAndStop(1);
					if( Const.MWID>12 || Const.MHEI>12 ) {
						cast(mc).hashes.gotoAndStop(2);
					} else {
						cast(mc).hashes.gotoAndStop(1);
					}
				} else {
					switch(c) {
					case 0: // empty
						if(detail._nvt) {
							mc.gotoAndStop(9);
						} else {
							mc.gotoAndStop(2);
						}
					case 1: // town
						mc.gotoAndStop(3);
					default: // other building
						if(detail._nvt) {
							mc.gotoAndStop(10);
						} else {
							mc.gotoAndStop(4);
						}
					}
				}
				if( detail._z != null && c != null ) { // tags
					var tag = tags.attachMovie("mapIcon","icon_"+Const.uniq,Const.uniq++);
					tag._x = mc._x;
					tag._y = mc._y;
					tag._width = mc._width;
					tag._height = mc._height;
					tag.gotoAndStop(6);
					tag._alpha = 15;
				}
				if( fl_inFog && detail._c != null && detail._c != 0 ) { // building in fog
						mc.gotoAndStop(5);
					c = detail._c;
				}
				if( c > 0 ) { // building rollover
					ab.onRollOver = callback(onOverMapZone,ab,Const.BUILDING_NAMES[c]+" "+coords(x,y), zdetails);
				}
				if( c == -1 ) { // undigged building
					ab.onRollOver = callback(onOverMapZone,ab,Lang.get.undigged+" "+coords(x,y), zdetails);
				}

				// danger colors
				if( detail._z > 0 ) {
					var danger = grid.attachMovie("danger","danger_"+Const.uniq,Const.uniq++);
					danger._x = mc._x;
					danger._y = mc._y;
					danger._width = mc._width;
					danger._height = mc._height;
					var z = MapCommon.zombieDanger(mapId+x+y*Const.MWID,detail._z,fl_betterMap);
					var cid = Std.int( Math.min( DANGER_COLORS.length-1, z ) );
					Col.setPercentColor( danger, 100, DANGER_COLORS[cid] );
					danger._alpha = 40;
				}

				switch(mode) {
					case Normal :
						var scale = getMapScale();
						var w = Math.round(mc._width*2*scale);
						// zombie dots
						if( fl_betterMap ) {
							var maxZ = if(fl_mapZoom) 5 else (if(isBigMap()) 3 else 5);
							for (i in 0...Std.int(Math.min(maxZ,detail._z))) {
								var dot = grid.attachMovie("dot","dot_"+Const.uniq,Const.uniq++);
								dot.gotoAndStop(1);
								dot._x = Math.round( mc._x+w*0.2 + rseed.random(Math.ceil(w*0.4)) );
								dot._y = Math.round( mc._y+w*0.2 + rseed.random(Math.ceil(w*0.4)) );
								dot.filters = [ new flash.filters.GlowFilter(RED,1, 5,5,2) ];
							}
						}
						//user dots
						if( fl_townMode && (x!=cityX || y!=cityY) )
							for( i in 0...uCpt ) {
								var dot = grid.attachMovie("dot","dot_"+Const.uniq,Const.uniq++);
								dot.gotoAndStop(2);
								dot._x = Math.round( mc._x+w*0.2 + rseed.random(Math.ceil(w*0.4)) );
								dot._y = Math.round( mc._y+w*0.2 + rseed.random(Math.ceil(w*0.4)) );
								dot.filters = [ new flash.filters.GlowFilter(LCD,0.5, 5,5,2) ];
							}
					case Tags :
						// infoTags
						if( detail._t!=null && detail._t>0 ) {
							var infTag = grid.attachMovie("mapTag", "icon_"+Const.uniq, Const.uniq++);
							var off = mc._width * 0.5 - infTag._width * 0.5;
							infTag._x = Math.floor( mc._x + mc._width * 0.5 - infTag._width * 0.5);
							infTag._y = Math.floor( mc._y + mc._height * 0.5 - infTag._height * 0.5);
							infTag.filters = [ new flash.filters.GlowFilter(LCD,1, 6,6,2) ];
							infTag.gotoAndStop( detail._t );
							ab.onRollOver = callback(onOverMapZone,ab, Lang.get.tag+"\n"+Lang.getText("tag_"+detail._t)+" "+coords(x,y), zdetails);
						}
					case Global :
					default :
				}
			}

			if( fl_inFog ) {
				// fog coords
				if( ab.onRollOver == null ) ab.onRollOver = callback(onOverMapZone,ab,coords(x,y), zdetails);
			} else {
				// empty zone
				if( ab.onRollOver == null ) ab.onRollOver = callback(onOverMapZone,ab,Lang.get.explored+" "+coords(x,y), zdetails);
			}

			if( !fl_townMode && x == trackX && y == trackY ) {
				var trackIcon = grid.attachMovie("mapIcon","icon_"+Const.uniq,Const.uniq++);
				trackIcon._x = mc._x;
				trackIcon._y = mc._y;
				trackIcon._width = mc._width;
				trackIcon._height= mc._height;
				trackIcon.gotoAndStop(8);
			}

			x++;
			if(x >= Const.MWID) {
				x = 0;
				y++;
			}
			n++;
		}
		
		// user pos
		var mc = grid.attachMovie("mapUser", "user", Const.uniq++);
		mc._x = Const.WID * 0.05 + cx * 30 * scale - 1;
		mc._y = Const.HEI * 0.03 + cy * 30 * scale - 1;
		mc._xscale = scale * 100;
		mc._yscale = scale * 100;
		mc.filters = [ new flash.filters.GlowFilter(LCD, 1, 6, 6, 2) ];

		showPath(grid);
		wmapBmp.draw(grid);
		grid.removeMovieClip();

		wmapCont.removeMovieClip();
		wmapCont = cast dms.empty(Const.DP_INTERF);
		dmm = new DepthManager(wmapCont);
		if( !fl_townMode ) {
			wmapCont.left = wmapCont.createEmptyMovieClip("left",Const.uniq++);
			wmapCont.left.attachBitmap(wmapBmp, 0);
		}
		wmapCont.right = wmapCont.createEmptyMovieClip("right",Const.uniq++);
		wmapCont.right.attachBitmap(wmapBmp, 1);
		if( mode == Close && fpsOk() ) {
			mapStep = 0;
		} else {
			mapStep = 0.9;
		}
		if( !fl_townMode && !fpsOk() )
			wmapCont.right.removeMovieClip();
		setPhase(Map);
		clearStatus();
		dmm.destroy();
		wmapCont.onRelease = hideMap;
		dms.over( wmapButtonCont );
		
		n = x = y = 0;
		for( c in map ) {
			if( mapDetails != null ) {
				var detail = mapDetails[n];
				if( detail._s ) {
					Boot.log("soul");
					var mcx = Math.floor(Const.WID * 0.05 + x * 30 * scale);
					var mcy = Math.floor(Const.HEI * 0.03 + y * 30 * scale);
					var soul : flash.MovieClip = dmm.attach("soul",Const.DP_TOP);
					soul._x = mcx;
					soul._y = mcy;
					soul._alpha = 80;
					souls.push(new SoulBehaviour(soul, scale));
				}
			}
			x++;
			if(x >= Const.MWID) {
				x = 0;
				y++;
			}
			n++;
		}

	}

	/*------------------------------------------------------------------------
	HIDE WORLD MAP
	------------------------------------------------------------------------*/
	function hideMap() {
		if( fl_townMode ) return;
		for( ic in icons )
			ic.mc._visible = true;
		expButton._visible = false;
		Reflect.deleteField(root, "onRelease");
		setPhase(Main);
		for( mc in abList ) mc.removeMovieClip();
		abList = new Array();
		setStatus(Lang.get.pos+" "+coords(cx, cy, false));
		cityArr._alpha = 100;
		mapButton.gotoAndStop(1);
		mapButton.field.text = Lang.get.map;
		mapButton.onRelease = callback(showMap, Normal);
		tagModeButton._visible = false;
		globalModeButton._visible = false;
		zoomButton._visible = false;
		for( soul in souls ) {
			soul.dispose();
		}
		souls = [];
	}

	function toggleZoom(mmode) {
		fl_mapZoom = !fl_mapZoom;
		savePref("zoom", fl_mapZoom);
		zoomButton.gotoAndStop( if(fl_mapZoom) 8 else 7 );
		showMap(mmode);
	}

	function getMapCenter() {
		return 	{ 	x : if( fl_townMode ) cityX else cx,
					y : if( fl_townMode ) cityY else cy
				};
	}
	
	function updateMapScrolling() {
		if( wmapCont == null )
			return;
		if( fl_mapZoom ) {
			var center = getMapCenter();
			if( fl_pathEditor ) {
				center.x = lastCoord.x;
				center.y = lastCoord.y;
			}
			var mcx = 20 + center.x * 30 * getMapScale();
			var mcy = 20 + center.y * 30 * getMapScale();
			var mdx = (root._xmouse - Const.WID * 0.5) / (Const.WID * 0.5);
			var mdy = (root._ymouse - Const.HEI * 0.5) / (Const.HEI * 0.5);
			wmapCont._x = Const.WID * 0.5 - mcx + (-mdx * 30);
			wmapCont._y = Const.WID * 0.5 - mcy + ( -mdy * 30);
			soulsCont._x = wmapCont._x;
			soulsCont._y = wmapCont._y;
		} else {
			wmapCont._x = 0;
			wmapCont._y = 0;
		}
		wmapButtonCont._x = wmapCont._x;
		wmapButtonCont._y = wmapCont._y;
	}

	function removeMapMCs() {
		mapButton.gotoAndStop(1);
		mapButton.field.text = Lang.get.map;
		tagModeButton._visible = false;
		black._visible = false;
		wmapBmp.dispose();
		
		soulsCont.removeMovieClip();
		soulsCont = null;
		
		wmapCont.removeMovieClip();
		wmapCont = null;
		
		wmapButtonCont.removeMovieClip();
		wmapButtonCont = null;
	}

	function addExp(name,cb,?fl_important) {
		var b = attachButton( (if(fl_important) 6 else 5),name, cb);
		b._x = Const.WID - b._width - 5;
		b._y = Const.HEI - 35 - (b._height+1) * expButtons.length;
		b._alpha = 70;
		expButtons.push(b);
	}

	function hideExpList() {
		for( b in expButtons ) {
			b.removeMovieClip();
		}
		for( mc in abList ) {
			mc._visible = true;
		}
		expButtons = new Array();
		expButton.field.text = Lang.get.expedition;
		expButton.onRelease = showExpList;
		blackExp.removeMovieClip();
		mapButton._alpha = 100;
		mapButton.onRelease = callback(showMap,Close);
		tagModeButton._alpha = 100;
		tagModeButton.onRelease = callback(showMap,Tags);
		globalModeButton._alpha = 100;
		globalModeButton.onRelease = callback(showMap,Global);
		zoomButton._visible = isBigMap();

		if( fl_townMode )
			setPhase(Main);
		else
			setPhase(Map);
	}

	function showExpList() {
		if( phase != Map && !fl_townMode )
			return;
		Reflect.deleteField(wmapCont,"onRelease");
		blackExp = dms.attach("blackMask",Const.DP_INTERF);
		blackExp._alpha = 70;
		setStatus("");
		expButtons = new Array();
		setPhase(ExpList);
		expButton.field.text = Lang.get.close;
		expButton.onRelease = hideExpList;
		black._visible = true;
		black._alpha = Const.BLACK_ALPHA;
		mapButton._alpha = Const.OFF_ALPHA;
		tagModeButton._alpha = Const.OFF_ALPHA;
		globalModeButton._alpha = Const.OFF_ALPHA;
		zoomButton._visible = false;
		Reflect.deleteField(mapButton,"onRelease");
		Reflect.deleteField(tagModeButton,"onRelease");
		Reflect.deleteField(globalModeButton,"onRelease");
		for (mc in abList)
			mc._visible = false;

		addExp(Lang.get.cancelExp, hidePath, true);
		for (e in expeditions)
			addExp(e._n, callback(selectPath,e));
	}

	function hidePath() {
		path = null;
		pathStep = -1;
		var cookie = flash.SharedObject.getLocal("mapTrack");
		cookie.data.pathId = null;
		cookie.data.pathStep = -1;
		cookie.flush();
		hideExpList();
		showMap(Normal);
	}

	function swap(a:T_Point,b:T_Point) {
		var ox = a.x;
		var oy = a.y;
		a.x = b.x;
		a.y = b.y;
		b.x = ox;
		b.y = oy;
	}

	function between(x:Int,y:Int, ptA:T_Point,ptB:T_Point) {
		if( y==ptA.y && ptA.y==ptB.y ) { // horizontal
			if( ptA.x<ptB.x && x>=ptA.x && x<=ptB.x ) return true;
			if( ptA.x>ptB.x && x>=ptB.x && x<=ptA.x ) return true;
		}
		if( x==ptA.x && ptA.x==ptB.x ) { // vertical
			if( ptA.y<ptB.y && y>=ptA.y && y<=ptB.y ) return true;
			if( ptA.y>ptB.y && y>=ptB.y && y<=ptA.y ) return true;
		}
		return false;
	}

	function selectPath(e) {
		path = e._p;
		pathStep = -1;
		trackPath(path);
		var cookie = flash.SharedObject.getLocal("mapTrack");
		cookie.data.pathId = e._i;
		cookie.flush();
		hideExpList();
		showMap(Normal);
	}

	function trackPath(p:String) {
		if( fl_townMode ) return;
		if( p==null ) return;
		var pts = getPathPoints(p,true);
		var prev : T_Point = null;
		var n = 0;
		for (pt in pts) {
			if( n>pathStep && pt.x==cx && pt.y==cy ) {
				pathStep=n;
				var cookie = flash.SharedObject.getLocal("mapTrack");
				cookie.data.pathStep = pathStep;
				cookie.flush();
			}
			if( prev!=null && (pt.x!=cx || pt.y!=cy) && (pathStep==-1 || n==pathStep+1) ) {
				if( between(cx,cy, pt,prev) ) {
					setTracker(pt.x,pt.y);
					return;
				}
			}
			n++;
			prev = pt;
		}
	}

	function getPathPoints(p:String,?fl_full:Bool): Array<T_Point> {
		var list = p.split(MapCommon.GroupSep);
		var pts = new Array();
		if(fl_full) pts.push({x:cityX,y:cityY});
		for (c in list ) {
			var clist = c.split(MapCommon.CoordSep);
			pts.push( {x:Std.parseInt(clist[0]), y:Std.parseInt(clist[1])} );
		}
		if( fl_full && ( pts[pts.length-1].x==cityX || pts[pts.length-1].y==cityY ) ) {
			pts.push({x:cityX,y:cityY});
		}
		return pts;
	}

	function showPath(cont:flash.MovieClip) {
		if( path==null ) return;
		var scale = getMapScale();
		var pts = getPathPoints(path,true);
		var prev : flash.MovieClip = null;
		var lineCont = cont.createEmptyMovieClip("lineCont", Const.uniq++);
		var dotCont = cont.createEmptyMovieClip("dotCont", Const.uniq++);
		lineCont.lineStyle( 2, LCD, 70);
		var n = 0;
		for (pt in pts) {
			var mc = dotCont.attachMovie("pathDot","pathDot_"+Const.uniq,Const.uniq++);
			if( pt.x==cityX && pt.y==cityY ) {
				mc.gotoAndStop(2);
			}
			else {
				mc.gotoAndStop(1);
			}
			mc._x = Const.WID*0.05 + pt.x*30*scale + 15*scale;
			mc._y = Const.HEI*0.03 + pt.y*30*scale + 15*scale;
			if(n>0) { cast(mc).field.text = n; }
			mc.filters = [
				new flash.filters.GlowFilter(0x2f410a, 1, 3,3, 4),
				new flash.filters.GlowFilter(LCD, 0.7, 4,4, 3),
			];
			if( prev!=null ) {
				lineCont.moveTo(mc._x,mc._y);
				lineCont.lineTo( prev._x, prev._y );
			}
			prev = mc;
			n++;
		}
	}

	public static function getListFrom(raw:String) {
		var list = raw.split("\n");
		var i = 0;
		while(i<list.length) {
			list[i] = StringTools.trim(list[i]);
			if( list[i].length==0 )
				list.splice(i,1);
			else
				i++;
		}
		return list;
	}

	/*------------------------------------------------------------------------
	RETURNS A HORRIBLE WORD CLOSE IN LENGTH FROM TXT
	------------------------------------------------------------------------*/
	function getHorribleWord(txt:String) {
		var list = getListFrom( Lang.get.HorribleWords );
		var tries = 0;
		var toler = 8;

		while( true) {
			var w = list[Std.random(list.length)];
			if( Math.abs(txt.length-w.length)<=toler ) return w;
			if( tries%10==0 ) toler++;
			tries++;
		}
		return txt;
	}

	function resetPsychoField(mc:T_TEXT_MC) {
		psychoTimer = 0;
		mc.field.text = prevTip;
		mc._x = prevTipX;
		mc._y = prevTipY;
		mc.field.filters = [];
	}

	function psychoField( mc:T_TEXT_MC ) {
		psychoCD -= Timer.tmod;
		if( mc.field.text != "" && psychoCD <= 0 && psychoTimer <= 0 && Std.random(120) == 0 ) { // 120
			prevTip = mc.field.text;
			prevTipX = mc._x;
			prevTipY = mc._y;
			mc.field.text = getHorribleWord(prevTip);
			psychoTimer = 20+Std.random(15);
		}

		if( psychoTimer>0 ) {
			psychoTimer-=Timer.tmod;
			mc._x+= (Std.random(2)*2-1) * Std.random(2);
			mc.field.filters = [ new flash.filters.BlurFilter(Std.random(4),Std.random(2)) ];
			if( psychoTimer <= 0 ) {
				resetPsychoField(mc);
				psychoCD = 250+Std.random(650);
			}
		}
	}


	function getPhaseName(p:PHASE) {
		switch(p) {
			case Init	: return "INIT";
			case ReInit	: return "REINIT";
			case Main	: return "MAIN";
			case Server	: return "SERVER";
			case Moving	: return "MOVING";
			case Map	: return "MAP";
			case ExpList: return "EXPLIST";
			default		: return "-unknown("+p+")-";
		}
	}


	/*------------------------------------------------------------------------
	MAIN LOOP
	------------------------------------------------------------------------*/
	public function main() {
		if( fl_disposed ) return;
		Timer.update();
		if( fl_townMode && phase != ExpList ) setPhase(Main);

		switch (phase) {
		case Init:
		case Main:
			if( starting != null ) {
				starting._alpha-=12;
				if( starting._alpha <= 0 ) {
					starting.removeMovieClip();
					starting = null;
				}
			}
			mapButton._visible = true;
			updateMapScrolling();
			// control arrows
			if( moves > 0 && arrows.length == 0 ) {
				attachArrow( Const.WID*0.5, 30, 0, callback(onMove,0,-1), (cy>0), neightbours[0], neigDrops[0] ); // up
				attachArrow( Const.WID-30, Const.HEI*0.5, 90, callback(onMove,1,0), (cx<Const.MWID-1), neightbours[1], neigDrops[1] ); // right
				attachArrow( Const.WID*0.5, Const.HEI-30, 180, callback(onMove,0,1), (cy<Const.MHEI-1), neightbours[2], neigDrops[2] ); // down
				attachArrow( 30, Const.HEI*0.5, 270, callback(onMove,-1,0), (cx>0), neightbours[3], neigDrops[3] ); // left
			}
			var i=0;
			for( mc in arrows ) {
				mc.field.text = Std.string(neightbours[i]);
				i++;
				if( mc._alpha < 100 ) {
					mc._alpha = Math.min(100, mc._alpha + 7 * Timer.tmod);
				}
			}

			// shows bleep icons
			for( icon in icons ) {
				icon.step += 0.2;
				if( icon.step < 2 ) {
					var nfact = Math.max(0,Math.min(1,icon.step));
					icon.mc._alpha = Math.min(100, 2 * nfact * 100);
					icon.mc._xscale = 100 + 100 * (1-nfact);
					icon.mc._yscale = 100 * nfact;
					if( icon.mc._currentframe == 1 ) {
						icon.mc.filters = [
							new flash.filters.GlowFilter(LCD, 0.5, 4, 4, 2),
							new flash.filters.GlowFilter(LCD, 1-icon.step, 7+10*nfact, 7+10*nfact, 4)
						];
					} else {
						if( icon.glow != null ) {
							icon.mc.filters = [ icon.glow, new flash.filters.GlowFilter(LCD,1-icon.step, 7+10*nfact,7+10*nfact,4) ];
						} else {
							icon.mc.filters = [ new flash.filters.GlowFilter(LCD,1-icon.step, 7+10*nfact,7+10*nfact,4) ];
						}
					}
				}
			}


		case Server:
			screen.filters = [];
		case Moving:
			// nothing
		case Map:
			mapStep = Math.min(1, mapStep+0.04);
			if( mapStep<2 ) {
				wmapCont.left._x = Math.cos(mapStep*Math.PI*4)*(1-mapStep)*12;
				wmapCont.right._x = -Math.cos(mapStep*Math.PI*4)*(1-mapStep)*8;
				wmapCont.right._y = -Math.cos(mapStep*Math.PI*4)*(1-mapStep)*5;
				wmapCont.left._alpha = Math.min(100,100*mapStep);
				wmapCont.right._alpha = Math.min(100,Math.sin(mapStep*Math.PI)*100);
//				wmapCont._xscale = (1-mapStep)*10+100;
//				wmapCont._yscale = wmapCont._xscale;
				wmapCont._x = Const.WID*0.5 - wmapCont._width*0.5;
				wmapCont._y = Const.HEI*0.5 - wmapCont._height*0.5;
				wmapCont.filters = [ new flash.filters.BlurFilter((1-mapStep)*8,(1-mapStep)*16)];
//				wmapCont.right.filters = [ new flash.filters.BlurFilter((1-mapStep)*8,(1-mapStep)*1)];
				black._alpha = mapStep*Const.BLACK_ALPHA;
			}
			updateMapScrolling();

		case ExpList:
			for( b in expButtons ) {
				if( b._alpha < 100 ) {
					if( Std.random(100) == 0 ) {
						b.filters = [ new flash.filters.BlurFilter(8,0) ];
					} else {
						b.filters = [];
					}
				}
			}
		default: fatal("unknown phase !");
		}

		if( phase == Main || phase == Map ) {
			mapButton._alpha = 100;
		} else {
			mapButton._alpha = Const.OFF_ALPHA;
		}
		// Map disappears
		if( wmapCont!=null && phase!=ExpList && phase!=Map && !fl_townMode ) {
			wmapCont._alpha -= 5;
			var r = 1-wmapCont._alpha/100;
			wmapCont.filters = [ new flash.filters.BlurFilter(r*16,0) ];
			black._alpha -=5;
			mapButton._alpha = Const.OFF_ALPHA;
			if( wmapCont._alpha<=0 ) {
				removeMapMCs();
				mapButton._alpha = 100;
			}
		}
		// tooltip
		if( tip.field.text != "" ) {
			dms.over(tip);
			tip._x = Math.floor(bg._x+over._x);
			tip._y = Math.min( Math.floor(bg._y+over._y+25), Const.HEI-10 );

			psychoField(tip);
		}
		if( phase == Map ) {
			psychoField(status);
		}
		// FX : scanner
		if( scanner._name!=null ) {
			scanner._y+= 10*Timer.tmod;
			for (icon in icons) {
				if(icon.mc._currentframe==1 && icon.mc._y<scanner._y ) {
					icon.step = if(fpsOk()) 0 else 1;
					icon.mc.blendMode = "layer";
					icon.mc.gotoAndStop(icon.frame+1);
				}
			}
			if( scanner._y>Const.HEI+scanner._height ) {
				scanner.removeMovieClip();
			}
		}

		// fade arrows
		if( phase!=Main ) {
			var i=0;
			while (i<arrows.length) {
				var mc = arrows[i];
				mc._alpha -= 8;
				if( mc._alpha<=0 ) {
					mc.removeMovieClip();
					arrows.splice(i,1);
					i--;
				}
				i++;
			}
		}

		// bleep icons
		if( phase==Server || phase==Moving ) {
			var i=0;
			while(i<icons.length) {
				var icon = icons[i];
				icon.mc._alpha-=9;
				if( icon.mc._alpha<=0 ) {
					icon.mc.removeMovieClip();
					icons.splice(i,1);
					i--;
				}
				i++;
			}
		}


		// map positionning (with mouse offset)
		if( oldMouse==root._xmouse+Const.WID*root._ymouse )
			hangTimer+=Timer.tmod;
		else
			hangTimer = 0;
		oldMouse = root._xmouse+Const.WID*root._ymouse;
		if( !fl_townMode && (phase==Main || phase==Server) && hangTimer<HANG_LIMIT && root._xmouse!=0 && root._ymouse!=0 ) {
			var ox = root._xmouse - Const.WID*0.5;
			var oy = root._ymouse - Const.HEI*0.5;
			var dist = Math.sqrt( Math.pow(ox,2) + Math.pow(oy,2) );
			updateScroll(-ox,-oy);
		} else {
			updateScroll(0,0);
		}


		// noise fx
		if( fpsOk() ) {
			if( !noise._visible ) noise._visible = true;
			if( noise._alpha==0 ) {
				if( Std.random(15)==0 ) {
					noise._alpha = 5;
				}
			} else {
				noise._alpha = Std.random(6);
				noise.smc._xscale = 100*(Std.random(2)*2-1);
				noise.smc._yscale = 100*(Std.random(2)*2-1);
			}
		} else {
			if( noise._visible ) noise._visible = false;
		}


		// FX : hallu
		if( hallu!=null ) {
			if( phase==Main && !hallu._visible && Std.random(100)==0 ) {
				hallu._visible = true;
				hallu.gotoAndStop( Std.random(hallu._totalframes)+1 );
			}
			if( hallu._visible ) {
				hallu._x =Std.random(30) * (Std.random(2)*2-1);
				hallu._y =Std.random(30) * (Std.random(2)*2-1);
				if( Std.random(3)==0 ) {
					hallu._visible = false;
				}
			}
		}


		// Bitmap preparation
		if( fpsOk() ) {
			if( !screenDist._visible ) screenDist._visible = true;
//			screen._visible = false;
			screenBmp.draw(screen);
		} else {
			if( screenDist._visible ) screenDist._visible = false;
		}

		// FX : displacement
		var rect = new flash.geom.Rectangle(0,0,Const.WID,Const.HEI);
		var pt = new flash.geom.Point(0,0);
		if( fpsOk() ) {
			if( !fl_disp ) {
				fl_disp = Std.random(30)==0;
				if( fl_disp ) {
					dispY = Std.random(Const.HEI)-50;
				}
			}
			if( fl_disp ) {
				var p = new flash.geom.Point(0.0, dispY);
				var str = Std.random(3)+8;
				var df = new flash.filters.DisplacementMapFilter(dispMap,p, 4,4, str,0);
				screenBmp.applyFilter(screenBmp,rect,pt,df);
				dispY+=Std.random(10)*(Std.random(2)*2-1);
				fl_disp = Std.random(20)!=0;
			}
		}

		// FX : red alert
		if( !fl_townMode && fl_danger && phase==Main) {
			if( alarm == null ) {
				alarm = dm.attach("alarm",Const.DP_FX);
				alarm._x = Const.WID*0.5;
				alarm._y = Const.HEI*0.5;
				alarm._xscale = 100 * (Std.random(2)*2-1);
				alarm._alpha = 0;
				alarm.filters = [
					new flash.filters.BlurFilter(5,15),
				];
				alarm.blendMode = "overlay";
			}
			if( alarm._alpha < 24 ) {
				alarm._alpha += Timer.tmod;
			}
		} else {
			if( alarm != null ) {
				alarm._alpha -= Timer.tmod;
				if( alarm._alpha <= 0 ) {
					alarm.removeMovieClip();
					alarm = null;
				}
			}
		}

		// City pointer
		if( fl_tracker && phase!=Map && phase!=ExpList ) {
			var maxDist = 0.40;
			var ang = Math.atan2(trackY-cy,trackX-cx);
			var deltX : Float = (trackX-cx)*Const.CWID;
			var deltY : Float = (trackY-cy)*Const.CHEI;
			if( Math.abs(deltY) > Const.HEI*maxDist ) {
				deltX = Math.cos(ang)*Const.HEI*maxDist;
				deltY = Math.abs(Const.HEI*maxDist/deltY) * deltY;
			}
			if( Math.abs(deltX)>Const.WID*maxDist ) {
				deltX = Math.abs(Const.WID*maxDist/deltX) * deltX;
				deltY = Math.sin(ang)*Const.WID*maxDist;
			}
			cityArr._alpha = 100;
			cityArr._rotation = 180 * ang / Math.PI;
			cityArr._x += ((Const.WID*0.5+deltX) - cityArr._x)*0.1;
			cityArr._y += ((Const.HEI*0.5+deltY) - cityArr._y)*0.1;
			cityArr._y = Math.min(cityArr._y,Const.HEI-20);
			if( Math.abs(cx-trackX)<=1 && Math.abs(cy-trackY)<=1 ) {
				cityArr.gotoAndStop(2);
				cityArr._rotation = 0;
			}
			else
				cityArr.gotoAndStop(1);
		}
	}
}
