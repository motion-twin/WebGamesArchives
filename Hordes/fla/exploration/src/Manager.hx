import flash.filters.BitmapFilter;
import mt.DepthManager;
import mt.Timer;
import mt.bumdum.Lib;
import ExploCommon;
import flash.Key;
import Type;

typedef T_INTERFACE = {
	> flash.MovieClip,
	_oxygenTf	: flash.TextField,
	_pointsMc	: flash.MovieClip,
	_DescTf		: flash.TextField,
	_bgMc		: flash.MovieClip,
	_playerMc	: flash.MovieClip,
}


typedef T_CELL = {
	> flash.MovieClip,
	/*
	_porte1 : flash.MovieClip,
	_porte2 : flash.MovieClip,
	_porte3 : flash.MovieClip,
	_porte4 : flash.MovieClip,
	
	_corps1 : flash.MovieClip,
	_corps2 : flash.MovieClip,
	_corps3 : flash.MovieClip,
	_corps4 : flash.MovieClip,
	
	_homme1 : flash.MovieClip,
	_homme2 : flash.MovieClip,
	_homme3 : flash.MovieClip,
	_homme4 : flash.MovieClip,
	
	_chariot1 : flash.MovieClip,
	_chariot2 : flash.MovieClip,
	_chariot3 : flash.MovieClip,
	_chariot4 : flash.MovieClip,
	
	_plante1 : flash.MovieClip,
	_plante2 : flash.MovieClip,
	_plante3 : flash.MovieClip,
	_plante4 : flash.MovieClip,
	
	_banc1 : flash.MovieClip,
	_banc2 : flash.MovieClip,
	_banc3 : flash.MovieClip,
	_banc4 : flash.MovieClip,
	_banc5 : flash.MovieClip,
	_banc6 : flash.MovieClip,
	_banc7 : flash.MovieClip,
	_banc8 : flash.MovieClip,
	*/
}

typedef T_ARROW = {
	>flash.MovieClip,
}

typedef T_TEXT_MC = {
	>flash.MovieClip,
	_field	: flash.TextField,
	_field2	: flash.TextField,
	_bg		: flash.MovieClip
}

typedef T_Point = {
	x	: Int,
	y	: Int,
}

enum CellKind {
	CVertical;
	CHorizontal;
	CCross;
	CCornerTR;
	CCornerTL;
	CCornerBR;
	CCornerBL;
	CTCrossT;
	CTCrossB;
	CTCrossL;
	CTCrossR;
	CDeadEndL;
	CDeadEndT;
	CDeadEndR;
	CDeadEndB;
}

enum PHASE {
	Init;
	ReInit;
	Main;
	Server;
	Moving;
}

enum RoomKind {
	Hopital;
	Motel;
	Bunker;
}

enum MAP_MODE {
	Normal;
}

using Reflect;

class Manager {
	static var LCD			= 0xd7ff5b;
	static var RED			= 0xff6048;
	static var ICON_GLOW	= [null, RED];
	static var TILES = ["bunker_tiles", "motel_tiles", "hospital_tiles"];
	static var ZOMBIES = ["militaire", "cleaner", "nurse"];
	
	static var D	= 	[
"vVe%22S%25%3BeVn0mzeclaB%2B5%21BcFV",
"vVe%22S%25%3BeDn0m%7EevlaB%2B5%21BcFV",
"%60yv%7BG%20sh%21S%3DoExH%7D%25%3AVW%1Ch",
"%0E%60%25ax%20V%7DhWE%7B%3A%1CyB%2FhroH",
"vVe%22S%25%3BeDn0mieblaB%2B5%21BcFV",
"%60Vs%22L%25%7DxOo0mhe%3Al%3CKf5%21EcFV",
"tG5FldD%600oek%7C%04x%25%0AvwVb1g%60V%22",
"NFVltw%0F%60e%255VdlFrvaj0W%7B%3B%24%22eT",
"rMw%7Fc%601%20owSzmqvcRD%400s0Jl%22%7B%40E%04nD7",
"rMw%7Fc%601%20owSzmcvbRD%400s0Jl%22%7B%40V%04nD7",
"%22V%7DS0PJl%7B7mz%04ozDl0D%20Rc2%0C%7Fn%7Cb",
"%22E%7DS0PJl%7B7mz%04ozDl0D%20Rq2%0C%7Fn%7Cc",
"0KpD%7BzbVc%22xRkbg0klSo0w%04NJH0%7F7",
"0KpD%7BzcEq%22xRkbg0klSo0w%04NJH0%7F7",
"%3BN5FlaDb0ievcBn%25G%2BaVe1g%60V%22",
	];
	
	// flags
	static var fl_disposed		: Bool;
	public var root		: flash.MovieClip;
	//
	var target			: T_Point;
	var dm				: DepthManager;
	var dms				: DepthManager;
	var hud				: T_INTERFACE;
	var bgCell			: T_CELL;
	var bgOldCell		: flash.MovieClip;
	var room			: flash.MovieClip;
	var bitmap			: flash.display.BitmapData;
	//current location
	var cellX			: Int;
	var cellY			: Int;
	var cellKind		: CellKind;
	
	var exploKind		: Int;
	//requested direction
	var reqDx			: Int;
	var reqDy			: Int;
	//TEXTS
	//var starting		: T_TEXT_MC;
	//var status		: T_TEXT_MC;
	//var tip			: T_TEXT_MC;
	//current phase
	var phase			: PHASE;
	var response		: ExploResponse;
	// écrans de rendu
	var screen			: flash.MovieClip;
	// flèches de déplacement
	var arrows			: Array<T_ARROW>;
	var door			: Null<flash.MovieClip>;
	var zombies			: Array<flash.MovieClip>;
	//TODO vaut t'il mieux avoir un	e structure, ou bien un nombre est plus simple à stocker/gérer
	var kills			: Int;
	var oxygen			: Float;
	// moyen de vérifier la provenance des informations
	var mapId			: Int;
	var zoneId			: Int;
	var exploDetails	: Array<Array<ExploCellDetail>>;
	var inPanic			: Bool;
	var cellRand		: mt.Rand;
	
	var out 			: T_Point;
	var cityArr			: flash.MovieClip;
	/*------------------------------------------------------------------------
	CONSTRUCTOR
	------------------------------------------------------------------------*/
	public function new(r) {
		root = r;
		root.scrollRect = new flash.geom.Rectangle(0, 0, Const.WID, Const.HEI);
		FlashExplo.MANAGER = this;
		FlashExplo.connect();
		reqDx = reqDy = 0;
		target = null;
		inPanic = false;
		
		//#if !prod
		//var str = '"'+ExploCommon.encode("http://www.hordes.fr/swf/")+'",\n';
		//str += '"'+ExploCommon.encode("http://seb.hordes.fr/swf/")+'",\n';
		//str += '"'+ExploCommon.encode("http://dev.hordes/swf/")+'",\n';
		//str += '"'+ExploCommon.encode("http://dev.horde/swf/")+'",\n';
		//str += '"'+ExploCommon.encode("http://dev.hordes.fr/swf/")+'",\n';
		//str += '"'+ExploCommon.encode("http://en.hordes.com/swf/")+'",\n';
		//str += '"'+ExploCommon.encode("http://beta.hordes.fr/swf/")+'",\n';
		//str += '"'+ExploCommon.encode("http://local.hordes.de/swf/")+'",\n';
		//str += '"'+ExploCommon.encode("http://dev.dieverdammten.de/swf/")+'",\n';
		//str += '"'+ExploCommon.encode("http://www.dieverdammten.de/swf/")+'",\n';
		//str += '"'+ExploCommon.encode("http://www.die2nite.com/swf/")+'",\n';
		//str += '"'+ExploCommon.encode("http://dev.die2nite.com/swf/")+'",\n';
		//str += '"'+ExploCommon.encode("http://www.zombinoia.com/swf/")+'",\n';
		//str += '"' + ExploCommon.encode("http://dev.zombinoia.com/swf/") + '",\n';
		//str += '"'+ExploCommon.encode("http://dev.hordas.com/swf/")+'",\n';
		//flash.System.setClipboard(str);
		//trace(str);
		//#end
		
		dm 		= new DepthManager(root);
		screen 	= dm.empty(Const.DP_CELL);
		dms 	= new DepthManager(screen);
		arrows 	= new Array();
		zombies = new Array();
		setPhase(Init);
		// init data
		var raw : String = Reflect.field(flash.Lib._root, "data");
		var data: ExploInit;
		//
		if (raw == null)	return; // no local mode
		try {
			raw = ExploCommon.decode( raw );
			data = haxe.Unserializer.run( raw );
		} catch(e:Dynamic) { fatal("Unserialize failed ! ("+e+")"); return; }

		
		Const.MWID = data._w;
		Const.MHEI = data._h;
		mapId  = data._mid;
		zoneId = data._zid;
		exploKind = data._k;
		exploDetails = [];
		for ( i in 0...Const.MHEI ) {
			exploDetails[i] = [];
			for ( j in 0...Const.MWID )
				exploDetails[i][j] = { _seed:0, _room:null, _z:0, _k:0, _w:false, _exit:false };
		}
		
		if( !checkDomains() ) return;
		// base map
		hud = cast dms.attach("exploration", Const.DP_INTERFACE);
		hud._x += Std.int(Const.WID / 2);
		hud._y += Std.int(Const.HEI / 2);
		hud._playerMc._visible = false;
		//
		var r = new mt.Rand(mapId+zoneId);
		var namesList = getListFrom( Lang.getText("building_" + exploKind) );
		hud._DescTf.text = namesList[r.random(namesList.length)];
		hud._oxygenTf.text = Lang.get.oxygene;
		//
		bitmap 		= new  flash.display.BitmapData( Const.WID, Const.HEI, true, 0 );
		bgCell 		= cast dms.attach( TILES[exploKind], Const.DP_CELL );
		bgOldCell 	= cast dms.empty(Const.DP_CELL ); bgOldCell.attachBitmap( bitmap, 0 );
		room   		= cast dms.attach("chambres_tiles", Const.DP_CELL );
		
		room.gotoAndStop(exploKind + 1);
		room._visible = false;
		// To make a movement at initialisation
		if( data._r._d._exit )
			bgCell._y = Const.HEI;
		
		onResponse(data._r);
		if( data._d ) {
			out = { x : Const.START_X, y : Const.START_Y };
			
			cityArr = dms.attach("cityArrow", Const.DP_TOP);
			cityArr._x = Const.WID * 0.5;
			cityArr._y = Const.HEI * 0.5;
			cityArr.gotoAndStop(1);
			cityArr._alpha = 0;
			cityArr.filters = [ new flash.filters.GlowFilter(LCD, 1, 6, 6, 2) ];
		}
		
		if( phase == Init ) {
			if( FlashExplo.isJsReady() ) {
				setPhase(ReInit);
				FlashExplo.askInfos();
			}
		}
	}
	
	function checkDomains() {
		var shortUrl = root._url.substr(0,root._url.indexOf("explo"));
		for ( url in D ) {
			if ( ExploCommon.encode(shortUrl) == url ) {
				return true;
			}
		}
		fatal("ckdm");
		return false;
	}

	function setPhase(p:PHASE) {
		if ( p == phase )
			return;
		phase = p;
	}

	public static function fatal(?e:String) {
		if (e != null) trace("FATAL : "+e);
		if ( !fl_disposed ) flash.Lib._root.gotoAndStop("error");
		Reflect.deleteField(flash.Lib._root, "onEnterFrame");
	}

	function inte(min:Float,max:Float,fact:Float):Float {
		return min + (max-min) * fact;
	}

	function savePref(name:String, value:Dynamic) {
		var cookie = flash.SharedObject.getLocal("exploPrefs");
		Reflect.setField(cookie.data, name, value);
		cookie.flush();
	}

	function loadPref(name:String, type:ValueType, defValue:Dynamic) {
		var cookie = flash.SharedObject.getLocal("exploPrefs");
		if ( Reflect.hasField(cookie.data, name) ) {
			var v = Reflect.field(cookie.data, name);
			if ( Type.typeof(v) != type )
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
		if ( fl_disposed ) return;
	
		dm.destroy();
		dms.destroy();

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
	EVENT: MOVE BUTTON PRESSED
	------------------------------------------------------------------------*/
	function onMove(dx, dy) {
		if ( phase != Main ) return;
		reqDx = dx;
		reqDy = dy;
		setPhase(Server);
		for (mc in arrows)
			Reflect.deleteField(mc, "onRelease");
		if ( door != null )
			Reflect.deleteField(door, "onRelease");
		FlashExplo.move(zoneId, dx, dy);
	}

	/*------------------------------------------------------------------------
	UPDATE STATUS FIELD
	------------------------------------------------------------------------*/
	/*
	function setStatus(txt:String,?txt2:String,?x:Float,?y:Float) {
		status.field.text = txt;
		if ( txt2 != null ) {
			status.field2.text = txt2;
			status.field2._y = status.field._y + status.field.textHeight;
		} else {
			status.field2.text = "";
		}
		var w = Math.max(status.field.textWidth, status.field2.textWidth);
		if ( x != null ) {
			x = Math.min(Const.WID - w * 0.5 - 6, x);
			x = Math.min(Const.WID - w * 0.5 - 6, x);
			x = Math.max(w * 0.5 + 6, x);
			y = Math.max(22, y);
			status._x = Math.floor(x);
			status._y = Math.floor(y);
			status.bg._visible = true;
			status.bg._width = w + 10;
			status.bg._height = status.field.textHeight + status.field2.textHeight;
		} else {
			status.bg._visible = false;
			status._x = Const.WID - w * 0.5 - 10;
			status._y = Const.HEI - 18;
		}
	}
	
	function clearStatus() {
		status.bg._visible = false;
		status.field.text = "";
		status.field2.text = "";
	}
	*/
	function isValidCoord(x, y) {
		return x >= 0 && x < Const.MWID && y >= 0 && y < Const.MHEI;
	}
	
	function isCell(x, y) {
		return isValidCoord(x, y) && exploDetails[y][x]._w;
	}
	
	function getCellKind() {
		var c = exploDetails[cellY][cellX];
		var t = isCell(cellX, cellY - 1);
		var b = isCell(cellX, cellY + 1);
		var l = isCell(cellX - 1, cellY);
		var r = isCell(cellX + 1, cellY);
		// 4 directions
		if ( t && b && l && r )
			return CellKind.CCross;
		// 3 directions
		if ( t && l && r && !b )
			return CellKind.CTCrossT;
		if ( t && l && !r && b )
			return CellKind.CTCrossL;
		if ( t && !l && r && b )
			return CellKind.CTCrossR;
		if ( !t && l && r && b )
			return CellKind.CTCrossB;
		// 2 directions
		if ( t && r )
			return CellKind.CCornerBL;
		if ( t && l )
			return CellKind.CCornerBR;
		if ( b && r )
			return CellKind.CCornerTL;
		if ( b && l )
			return CellKind.CCornerTR;
		if ( r && l )
			return CellKind.CHorizontal;
		if ( t && b )
			return CellKind.CVertical;
		// 1 direction
		if ( t )
			return CellKind.CDeadEndB;
		if ( b )
			return CellKind.CDeadEndT;
		if ( r )
			return CellKind.CDeadEndL;
		//if ( l != null )
		return CellKind.CDeadEndR;
	}

	/*------------------------------------------------------------------------
	EVENT: SERVER RESPONSE
	------------------------------------------------------------------------*/
	public function onResponse(r : ExploResponse) {
		if ( fl_disposed ) 		return;
		if ( !checkDomains() ) 	return;
		if ( phase == Server && cellX == r._x && cellY == r._y && r._r == response._r && r._d == response._d ) {
			fatal("C'est quoi qui s'est passé ? ");
			//FlashExplo.reboot();
			return;
		}
		if ( reqDx != 0 || reqDy != 0 ) {
			bitmap.draw( bgCell );
			bgOldCell._x = bgCell._x;
			bgOldCell._y = bgCell._y;
			var dx = Std.int( reqDx * Const.WID );
			var dy = Std.int( reqDy * Const.HEI );
			bgCell._x = Std.int( bgCell._x + dx );
			bgCell._y = Std.int( bgCell._y + dy );
		} else {
			for (mc in zombies)
				mc.removeMovieClip();
			zombies = [];
			for (mc in arrows)
				mc.removeMovieClip();
			arrows = [];
		}
		response = r;
		exploDetails[response._y][response._x] = response._d;
		oxygen = response._o;
		hud._playerMc._visible = !response._r;
		room._visible = response._r;
		bgCell._visible = !response._r;
		//
		door 	 = null;
		cellX 	 = response._x;
		cellY 	 = response._y;
		if ( isValidCoord( cellX + 1, cellY ) ) exploDetails[cellY][cellX+1]._w = response._dirs[0];
		if ( isValidCoord( cellX, cellY - 1 ) ) exploDetails[cellY-1][cellX]._w = response._dirs[1];
		if ( isValidCoord( cellX - 1, cellY ) ) exploDetails[cellY][cellX-1]._w = response._dirs[2];
		if ( isValidCoord( cellX, cellY + 1 ) ) exploDetails[cellY+1][cellX]._w = response._dirs[3];
		cellKind = getCellKind();
		//
		if( response._r )
			initRoom();
		else
			initCell();
		setPhase(Moving);
		//
		reqDx = reqDy = 0;
	}

	function initRoom() {
		//TODO s'il y a qq chose à faire
	}
	
	public function onAskedMeIfReady() {
		if( phase == Init ) setPhase(Moving);
	}

	/*------------------------------------------------------------------------
	ATTACH SINGLE ARROW
	------------------------------------------------------------------------*/
	
	function attachArrow(x, y, rot, cb, fl_on) {
		var mc : T_ARROW = cast dms.attach("arrow", Const.DP_TOP);
		mc._x = x;
		mc._y = y;
		mc._rotation = rot;
		mc._alpha = 0;
		mc.gotoAndStop(1);
		
		if( fl_on ) {
			mc.onRelease = cb;
			mc.onRollOver = function() { mc.filters = [ new flash.filters.GlowFilter(LCD, 0.5, 4, 4, 6) ]; };
			mc.onRollOut  = function() { mc.filters = []; };
		} else {
			Reflect.deleteField(mc,"onRelease");
			mc._visible = false;
		}
		arrows.push(mc);
	}
	
	function attachZombie(x : Float, y:Float, dir : T_Point, ?killed = false) {
		var linkName = ZOMBIES[exploKind];
		if( cellRand.random(100) < 50 ) linkName = "zombie";
		
		var mc = dms.attach(linkName, Const.DP_CELL);
		var w = mc._width;
		var h = mc._height;
		mc._x = x - (w / 2) + dir.x * w;
		mc._y = y - (0.8 * h) + dir.y * h;//hack to fix gfx center point
		mc._alpha = 0;
		if( killed ) {
			mc.gotoAndStop("dead");
			mc.filters = [];
		} else {
			mc.gotoAndPlay( Std.random(mc._totalframes - 2) + 1 );
			mc.filters = [new flash.filters.GlowFilter(0xFF0000, 1, 2, 2, 500 )];
		}
		//
		zombies.push(mc);
	}

	public static function getListFrom(raw:String) {
		var list = raw.split("\n");
		var i = 0;
		while(i < list.length) {
			list[i] = StringTools.trim(list[i]);
			if( list[i].length == 0 )
				list.splice(i,1);
			else
				i++;
		}
		return list;
	}

	function getPhaseName(p:PHASE) {
		switch(p) {
			case Init	: return "INIT";
			case ReInit	: return "REINIT";
			case Main	: return "MAIN";
			case Server	: return "SERVER";
			case Moving	: return "MOVING";
			default		: return "-unknown("+p+")-";
		}
	}

	function initCell() {
		bgCell.gotoAndStop( Type.enumIndex( cellKind ) + 1 );
		var cell = exploDetails[cellY][cellX];
		cellRand = new mt.Rand(cell._seed);
		var keys = flash.Lib.keys(bgCell);
		for( o in keys ) {
			if( o.indexOf("_") != 0 ) continue;
			var mc = Reflect.field(bgCell, o);
			if ( Std.is( mc, flash.MovieClip ) )
				mc._visible = false;
		}
		// Si c'est la case de sortie
		if( Lambda.has(keys, "_exit") ) {
			Reflect.field(bgCell, "_exit")._visible = response._d._exit;
		}
		
		var tags = switch(exploKind) {
			case 0 : ["_flaque", "_tonneau", "_sticker", "_goutiere"];//bunker
			case 1 : ["_corps", "_homme", "_chariot", "_plante", "_banc"];//Hotel
			case 2 : ["_banc", "_femme", "_cadavre", "_lit", "_panneau"];//Hopital
		}
		for( tag in tags ) {
			var v = cellRand.random(10) + 1;
			if ( Lambda.has(keys, tag + v) )
				Reflect.field(bgCell, tag + v)._visible = true;
		}
		
		if( cell._room != null ) {
			var maxDoorCount = 0;
			while( Lambda.has(keys, "_porte" + maxDoorCount++)  ) {}
			
			door = cast Reflect.field(bgCell, "_porte" + (cellRand.random(maxDoorCount) + 1));
			if( door == null ) {
				fatal("Mais pourquoi une porte n'a pu etre trouvé ?? : " + maxDoorCount);
			}
			door._visible = true;

			var onDoorClick = null;
			if( !cell._room._locked ) {
				door.gotoAndStop(2);
				if( response._move )
					onDoorClick = enterRoom;
			}
			door.onRelease = onDoorClick;
			door.useHandCursor = onDoorClick != null;
			var color = response._move ? 0xFF00 : 0xFF0000;
			var fOn : Array<BitmapFilter> = [ new flash.filters.GlowFilter(color, 1 , 2, 2, 6) ];
			var fOff : Array<BitmapFilter> = [ new flash.filters.GlowFilter(color, .8, 3, 3, 4) ];
			door.filters = fOff;
			door.onRollOver = function() { door.filters = fOn; };
			door.onRollOut  = function() { door.filters = fOff; };
		}
	}

	function leaveRoom() {
		if( phase != Main ) return;
		setPhase(Server);
		FlashExplo.leaveRoom();
		for (mc in arrows)
			Reflect.deleteField(mc, "onRelease");
	}
	
	function enterRoom() {
		if( phase != Main ) return;
		reqDx = 0;
		reqDy = 0;
		setPhase(Server);
		for(mc in arrows)
			Reflect.deleteField(mc, "onRelease");
		if( door != null )
			Reflect.deleteField(door, "onRelease");
		FlashExplo.enterRoom();
	}
	
	function unlockDoor() {
		if( phase != Main ) return;
		reqDx = 0;
		reqDy = 0;
		setPhase(Server);
		//clearStatus();
		for(mc in arrows)
			Reflect.deleteField(mc, "onRelease");
		if( door != null )
			Reflect.deleteField(door, "onRelease");
		FlashExplo.unlockDoor();
	}
	
	/*------------------------------------------------------------------------
	MAIN LOOP
	------------------------------------------------------------------------*/
	public function main() {
		if( fl_disposed ) return;
		Timer.update();
		oxygen -= Timer.deltaT * 1000;
		// on affiche par paquet de 3 secondes
		var oxy = Std.int((oxygen / 1000) / 3);
		cast(hud._pointsMc.field("_nombreMc").field("_pointsTf"), flash.TextField).text = Std.string(Math.max(0, oxy));
		
		if( oxy <= 10 && !inPanic ) {
			hud._playerMc.gotoAndPlay("panique");
			inPanic = true;
		}
		
		switch(phase) {
			case Init:
			case Main:
				if( oxy < 0 ) {
					FlashExplo.refresh();
					setPhase(Server);
					return;
				}
				var cell = exploDetails[cellY][cellX];
				// attach zombies
				if( !response._r && zombies.length == 0 && (cell._k+cell._z) > 0 ) {
					var r = new mt.Rand( cell._seed );
					var d = 1;
					var dirs = [ { x:-d, y:0 }, { x:d, y:0 }, { x:0, y:d }, { x:0, y:-d } ];
					for( i in 0...(cell._z+cell._k) ) {
						var d = dirs[r.random(dirs.length)];
						dirs.remove(d);
						attachZombie(Const.WID / 2, Const.HEI / 2, d, i >= cell._z);
					}
				}
				// control arrows
				if( arrows.length == 0 && response._move ) {
					if( !response._r ) {
						attachArrow( Const.WID * 0.5, 	40, 				0, 		callback(onMove, 0, -1), 	response._dirs[1] ); // up
						attachArrow( Const.WID - 40, 	Const.HEI * 0.5, 	90, 	callback(onMove, 1, 0), 	response._dirs[0] ); // right
						attachArrow( 40, 				Const.HEI * 0.5,	270,	callback(onMove, -1, 0),	response._dirs[2] ); // left
						attachArrow( Const.WID * 0.5, 	Const.HEI - 40, 	180,	callback(onMove, 0, 1), 	response._dirs[3] ); // down
					} else {
						attachArrow( Const.WID * 0.5, 	Const.HEI - 40, 	180,	leaveRoom, 					true ); // down
					}
				}
				for(mc in arrows)
					if (mc._alpha < 100)
						mc._alpha = Math.min(100, mc._alpha + 7 * Timer.tmod);
				
				for(mc in zombies)
					if (mc._alpha < 100)
						mc._alpha = Math.min(100, mc._alpha + 20 * Timer.tmod);

			case Server:
				//trace("server...");
			case Moving:
				var dx = Std.int(bgCell._x / 4);
				var dy = Std.int(bgCell._y / 4);
				var cell = exploDetails[cellY][cellX];
				hud._playerMc._visible =  !(cell._exit && dy > 10);// pour l'effet d'entrée
				bgOldCell._x -= dx;
				bgOldCell._y -= dy;
				bgCell._x    -= dx;
				bgCell._y 	 -= dy;
				if( dx == 0 && dy == 0 ) setPhase( Main );
			default: fatal("unknown phase !");
		}

		// fade arrows
		if( phase != Main ) {
			var i = 0;
			while(i < zombies.length) {
				var mc = zombies[i];
				mc._alpha -= 10;
				if( mc._alpha <= 0 ) {
					mc.removeMovieClip();
					zombies.splice(i, 1);
					i--;
				}
				i++;
			}
			
			var i = 0;
			while(i < arrows.length) {
				var mc = arrows[i];
				mc._alpha -= 8;
				if( mc._alpha <= 0 ) {
					mc.removeMovieClip();
					arrows.splice(i, 1);
					i--;
				}
				i++;
			}
		}
		
		// Exit pointer
		if( out != null ) {
			var maxDist = 0.40;
			var dy = out.y - cellY;
			var dx = out.x - cellX;
			var ang = Math.atan2(dy, dx);
			var deltX : Float = dx * Const.CWID;
			var deltY : Float = dy * Const.CHEI;
			if( Math.abs(deltY) > Const.HEI * maxDist ) {
				deltX = Math.cos(ang) * Const.HEI * maxDist;
				deltY = Math.abs(Const.HEI * maxDist/deltY) * deltY;
			}
			if( Math.abs(deltX) > Const.WID * maxDist ) {
				deltX = Math.abs(Const.WID * maxDist/deltX) * deltX;
				deltY = Math.sin(ang) * Const.WID*maxDist;
			}
			cityArr._alpha = 100;
			cityArr._rotation = 180 * ang / Math.PI;
			cityArr._x += ((Const.WID * 0.5 + deltX) - cityArr._x) * 0.1;
			cityArr._y += ((Const.HEI * 0.5 + deltY) - cityArr._y) * 0.1;
			cityArr._y = Math.min(cityArr._y, Const.HEI - 20);
			if( Math.abs(dx) <= 1 && Math.abs(dy) <= 1 ) {
				cityArr.gotoAndStop(2);
				cityArr._rotation = 0;
			} else
				cityArr.gotoAndStop(1);
		}

	}
}
