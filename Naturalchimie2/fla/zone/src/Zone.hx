import flash.Key ;
import mt.bumdum.Lib ;
import anim.Anim.AnimType ;
import anim.Transition ;
import MapData._MapData ;
import GameData._ArtefactId ;


enum Step {
	Default ;
	NoWay ;
	Dialog ;
	Map ;
	Transition ;
}


class Zone {
	
	public static var DP_BG = 0 ;
	public static var DP_GREY = 1 ;
	public static var DP_MAP = 6 ;
	public static var DP_EFFECT = 7 ;
	public static var DP_DIALOG = 8 ;
	public static var DP_INTERFACE = 9 ;
	public static var DP_FG = 10 ;
	public static var DP_LOADING = 11 ;
	public static var DP_BMP = 12 ;
		
	public static var WIDTH = 500 ;
	public static var HEIGHT = 300 ;
		
	
	public static var NOWAY_BG = "noway" ;
	public static var me : Zone ;
	
	public var data : ZoneData ;
	public var valid : Bool ;
	public var jsConnect : Dynamic ;
	public var step : Step ;

	public var mdm : mt.DepthManager ;
	
	public var loader : Load ;
	public var root : flash.MovieClip ;
	public var bg : flash.MovieClip ;
	var preLoadObject : ObjectMc ;
	
	var shakeTimer : Float ;
	var bgInfos : {x : Int, y : Int} ;
	
	//map
	public var map : Map ;
	public var mcMap : flash.MovieClip ;
	
	//dialog
	public var dialog : Dialog ;
	public var isSpeaking : Bool ;
	
	//effect 
	public var effect : ZoneEffect ;
	

	public function new(mc : flash.MovieClip, l : ZoneLoader) {
		for (d in ["www","beta","data"])
			flash.system.Security.allowDomain(d+".naturalchimie.com") ;
		
		loader = l ;
		mt.flash.Key.enableForWmode() ;
		
		var ctx = new haxe.remoting.Context() ;
		ctx.addObject("_Com", _Com) ;
		jsConnect = haxe.remoting.ExternalConnection.jsConnect("zone", ctx) ;
		
		me = this ;
		this.root = mc ;
		mdm = new mt.DepthManager(root) ;
		
		step = Default ;
		shakeTimer = 0 ;
		
		loader.initLoading(2) ;
		loadData() ;
	}
	
	
	function initMc() {
		initBg() ;
		
		var fg = mdm.attach("frame", DP_FG) ;
		fg._x = 0 ;
		fg._y = 0 ;
		
		if (data._effect == "cthulo")
			effect = new ZoneEffect(data._effect, Zone, DP_EFFECT) ;
	}
	
	
	function initFunc(cq : String) {
		switch(cq) {
			case "laph" : //quest "invité surprise ! "
				dialog.cmdFunc = callback(function(z : Zone) {
									z.effect = new ZoneEffect("cthulo", Zone, Zone.DP_EFFECT) ;
								}, this) ;
		}
	
	}
	
	
	function initBg() {
		bg = mdm.empty(DP_BG) ;
		
		var bgCoords = data._bginf.split(":") ;
		bgInfos = {x : Std.parseInt(bgCoords[0]), y : Std.parseInt(bgCoords[1])} ;
		
		if (bgCoords != null && bgCoords.length >2)
			Pnj.GLOW_TYPE = Std.parseInt(bgCoords[2]) ;
		
		if (valid) {
			bg._x = Std.parseInt(bgCoords[0]) ;
			bg._y = Std.parseInt(bgCoords[1]) ;
		} else {
			bg._x = 0 ;
			bg._y = 0 ;
		}
		
		var mcl = new flash.MovieClipLoader() ;
		var me = this ;
		mcl.onLoadError = function(_,err) {
			me.loader.reportError(err) ;
		}
		mcl.onLoadInit = function(_) {
			me.loader.done() ;
		}
				
		mcl.loadClip(loader.dataDomain + "/img/bg/" + (if (data._bg != null) data._bg else NOWAY_BG) + ".jpg", bg) ;
	}
	
	
	function setGrey() {
		var mcHide = mdm.empty(DP_GREY) ;
		mcHide.beginFill(0x000000, 87) ;
		mcHide.moveTo(0, 0) ;
		mcHide.lineTo(WIDTH, 0) ;
		mcHide.lineTo(WIDTH, HEIGHT) ;
		mcHide.lineTo(0, HEIGHT) ;
		mcHide.lineTo(0, 0) ;
		mcHide.endFill() ;
	}

	
	public function loop() {
		mt.Timer.update() ;
		updateMoves() ;
		
		switch(step) {
			case Default : 
				
			case NoWay : 
				
			case Dialog : 
				if (dialog != null)
					dialog.loop() ;
			case Map : 
				if (map != null)
					map.loop() ;
			case Transition : 
		}
		
		if (effect != null)
			effect.update() ;
		
		if (shakeTimer > 0)
			shake() ;
	}
	
	
	function updateMoves() {
		var list = anim.Anim.onStage.copy() ; 
		for (m in list) m.update() ;

	}
	
	
	function loadData() {
		try {
			/*var s = secure.Utils.decode(secure.Utils.getKey(loader.k, dat, loader.s, loader.n)) ;
			data = haxe.Unserializer.run(s) ;*/
			data = secure.Codec.getData("d") ;

			//secure.Utils.key = data._dialogKey ;	
			Pnj.DATA_URL = data._pnj_url ;
			//ObjectMc.DATA_URL = data._object_url ;
			ObjectMc.initMc(data._object_url, mdm, 0, callback(function() { Zone.me.initMc() ;})) ;
			
		} catch( e : Dynamic ) {
			loader.reportError(e) ;
			return ;
		}
		loader.done() ;
		valid = data._valid ;
		//initMc() ;
		
		if (data._noway != null) 
			setNoWay() ;
	}
	
	
	function setNoWay() {
		if (data._noway._did != null)
			startDialog(data._noway._did) ;
		else
			setInfo(data._noway._text, data._noway._redir) ;
	}


	//map 
	public function switchMap() : Bool{
		if (map == null)  {
			initMap() ;
			return true ;
		} else {
			exitMap() ;
			return false ;
		}
	}
	
	
	function initMap() {		
		mcMap = mdm.empty(DP_MAP) ;
		mcMap._alpha = 0 ;
		
		setStep(Transition, true) ;
		var f = callback(function(mc, z : Zone) {
					var m = new anim.Anim(mc, Alpha(1), Quint(1), {x : 0, y : 0, speed : 0.08}) ;
					m.onEnd = callback(z.setStep, Map, false) ;
					m.start() ;
				}, mcMap, this) ;
								
		map = new Map(mcMap, loader, data._map, f) ;
		var th = this ;
		map.fRefill = function(d : _MapData) { th.data._map = d ; } ;
	}
	
	
	function exitMap() {
		setStep(Transition, true) ;
		var m = new anim.Anim(mcMap, Alpha(-1), Quint(1), {x : 0, y : 0, speed : 0.08}) ;
		m.onEnd = callback(function(z : Zone) {
						z.map.kill() ;
						z.map = null ;
						z.setStep(Map, false) ;
				}, this) ;
		m.start() ;
	}
	
	
	function setStep(s : Step, ?l : Bool) {
		step = s ;
		if (l == null || !l)
			loader.unlock() ;
		else
			loader.lock() ;
	}
	
	
	public function startDialog(id : String) {
		if (dialog != null)
			return ;
		
		dialog = new Dialog(id, Zone, DP_DIALOG, null, "/act/") ;
		if (valid)
			dialog.postKill = callback(function() {flash.external.ExternalInterface.call("_activeAll") ; }) ;
			
		if (data._curquest != null)
			initFunc(data._curquest) ;
			
		setStep(Dialog) ;
	}
	
	
	public function setInfo(t : String, redir : String) {
		if (dialog != null)
			return ;
		if (!valid)
			setGrey() ;
		dialog = new Dialog(null, cast Zone, DP_DIALOG, null,  "/act/", t) ;
		if (valid)
			dialog.postKill = callback(function() {flash.external.ExternalInterface.call("_activeAll") ; }) ;
		setStep(Dialog) ;
	}	
	
	
	public function setShake(s : Float, ?limit : Int = 5) {
		shakeTimer = Math.min(limit, shakeTimer + s) ;
	}
	
	
	function shake() {
		shakeTimer -= 0.3 ;
		var pos = {x : 0, y : 0} ;
		var v = 5 ;
		
		var shx = Std.random(Math.round(shakeTimer * v)) / v * (Std.random(2) * 2 - 1) ;
		var shy = Std.random(Math.round(shakeTimer * v)) / v * (Std.random(2) * 2 - 1) ;
		
		bg._x = bgInfos.x + shx ;
		bg._y = bgInfos.y + shy ;
	}


	
}



//### JS CALLS
class _Com {
	
	
	public static function _sMap() : Bool {
		if (Zone.me.loader.isLoading() || Zone.me.dialog != null || !Zone.me.valid)
			return false ;
		return Zone.me.switchMap() ;
	}
	
	
	public static function _sDialog(did : String) : Bool {
		if (Zone.me.loader.isLoading() || Zone.me.map != null || !Zone.me.valid)
			return false ;
		
		if (Zone.me.dialog == null) {
			Zone.me.startDialog(did) ;
			return true ; 
		} else 
			return false ;
	}

	
	public static function _answer(aid : String) : Bool {		
		if (Zone.me.loader.isLoading() || Zone.me.dialog == null || aid == null)
			return false ;
		
		return Zone.me.dialog.answer(aid) ;
	}
	
	
}
	








