import flash.Key ;
import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import mt.bumdum.Phys ;
import anim.Anim.AnimType ;
import anim.Transition ;
import GameData._ArtefactId ;
import ZoneData.WheelData ;
import flash.Key ;


class TextFr {
	public static var ERR_STD = "{Aïe, une erreur est survenue ! } Vous n'avez rien perdu, mais rechargez la page avant de faire un nouvel essai. ";
	public static var ERR_SVR = "Impossible de contacter le serveur de jeu." ;
}


enum Step {
	Loading ;
	Waiting ;
	Wheeling ;
	Result ;
	SDialog ;
}

typedef Plot = {
	var ang : Float ; 
	var mc : flash.MovieClip ;
	var reward : String ;
}



class Wheel {
	
	public static var TEXT = TextFr ;
	
	public static var DEBUG = false ;
		
	public static var DP_BG = 0 ;
	
	public static var DP_WHEEL = 1 ;
	public static var DP_CHX = 2 ;
	
	public static var DP_STOCK = 4 ;
	
	public static var DP_DIALOG = 9 ;	
	public static var DP_FG = 12 ;
	public static var DP_LOADING = 13 ;
	
	public static var WHEEL_DIAMETER = [257.0, 130.0, 110.0, 83.0, 190.0] ;
	
	public static var WIDTH = 500 ;
	public static var HEIGHT = 300 ;
	
	
	public static var START_MOVE = 6.28 ;
	public static var START_SPEED = 0.015 ;
	public static var MAX_SPEED = 0.2 ;
	public static var ROPE_MAX_SPEED = 0.35 ;
	
	public static var TURN_MAX_SPEED = 10 ;
	public static var TURN_DECC_SPEED = 26 ;
	
	public static var MIN_FRICT = 0.000001 ;
	
	//public static var FRICTION = 0.97 ;
	public static var ROPE_FRICTION = /*0.95*/0.985 ;
	
	public static var me : Wheel ;
	
	public var stock : Int ;
	
	public var initRot : Float ;
	public var finalRot : Float ;
	public var targetRot : Float ;
	public var lastRot : Float ;
	public var countTurns : Int ;
	
//	public var wTimer : Float ; 
//	public var wSpeed : Float ;
	
	public var ropeTimer : Float ; 
	public var ropeSpeed : Float ;
	
	public var waitingResponse : Bool ;
	public var jsConnect : Dynamic ;
	public var step : Step ;
	public var subStep : Int ;
	
	var lastRecal : {side : Int, dist : Float} ;

	public var mdm : mt.DepthManager ;
	public var ddm : mt.DepthManager ;
		
	public var loader : Load ;
	public var root : flash.MovieClip ;
	public var bg : flash.MovieClip ;
		
	var preLoadObject : ObjectMc ;
		
	public var pnj : Pnj ;

	public var data : WheelData ;	
	var bgInfos : {x : Int, y : Int} ;
	
	
	public var mcGui : {>flash.MovieClip, 
					_bg1 : flash.MovieClip, _bg2 : flash.MovieClip, _bg3 : flash.MovieClip, 
					_planche1 : flash.MovieClip, _planche2 : flash.MovieClip, _planche3 : flash.MovieClip, 
					_rop1 : flash.MovieClip, _rop2 : flash.MovieClip, _rop3 : flash.MovieClip, _rop4 : flash.MovieClip, 
					_fix1 : flash.MovieClip, _fix3 : flash.MovieClip, _fix4 : flash.MovieClip, 
					_w1 : {>flash.MovieClip, _blur : flash.MovieClip}, _w2 : {>flash.MovieClip, _blur : flash.MovieClip}, 
					_w3 : {>flash.MovieClip, _blur : flash.MovieClip}, _w4 : {>flash.MovieClip, _blur : flash.MovieClip}, 
					_mainWheel : {>flash.MovieClip, _blur : flash.MovieClip, _plots : {>flash.MovieClip, 
						_p0 : flash.MovieClip, _p1 : flash.MovieClip, _p2 : flash.MovieClip, _p3 : flash.MovieClip, _p4 : flash.MovieClip, _p5 : flash.MovieClip, 
						_p6 : flash.MovieClip, _p7 : flash.MovieClip, _p8 : flash.MovieClip, _p9 : flash.MovieClip, _p10 : flash.MovieClip, _p11 : flash.MovieClip}},
					_wing : {>flash.MovieClip, _w : {>flash.MovieClip, _p0 : flash.MovieClip, _p1 : flash.MovieClip}},
					_button : flash.MovieClip } ;
	public var chx : flash.MovieClip ;
	public var mcStock : ObjectMc ;
					
					
	public var wheels : Array<{mc : {>flash.MovieClip, _blur : flash.MovieClip}, d : Float, wait : Float, timer : Float, v : Float, fr : Float, sp : Float, side : Int}> ;
	public var plots :Array<Plot> ;
	public var ropes : Array<{mc : flash.MovieClip, sx : Float, side : Int}> ;
	public var floors : Array<{mc : flash.MovieClip, sx : Float}> ;
	public var bgs : Array<{mc : flash.MovieClip, sx : Float, sy : Float}> ;
	public var fixs : Array<{mc : flash.MovieClip, sx : Float, sy : Float}> ;
	
	public var wingAnim : anim.Anim ;
	
	
	
	public var mcSubmit : {>flash.MovieClip, active : Bool} ;
	public var mcCancel : {>flash.MovieClip, active : Bool} ;
	public var submitMove : anim.Anim ;
	var submitStep : Int ;
	var submitData : Dynamic ;
	var shakeTimer : Float ;
	var result : Array<String> ;
	//public var submitBalance : Float ;
	
	
	//dialog
	public var dialog : Dialog ;
	/*public var isSpeaking : Bool ;
	public var resultWait : Float ;
	public var resultDialogFunc : Void -> Void ;
	public var waitingDialog :String ;*/
	
	

	public function new(mc : flash.MovieClip, l : WheelLoader) {
		for (d in ["www","beta","data"])
			flash.system.Security.allowDomain(d+".naturalchimie.com") ;
		
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces() ;
		
		loader = l ;
		mt.flash.Key.enableForWmode() ;
		
		var ctx = new haxe.remoting.Context() ;
		ctx.addObject("_Com", _Com) ;
		jsConnect = haxe.remoting.ExternalConnection.jsConnect("zone", ctx) ;
		
		me = this ;
		this.root = mc ;
		mdm = new mt.DepthManager(root) ;
		shakeTimer = 0 ;
		subStep = 0 ;
		stock = 0 ;
		step = Loading ;
		
		waitingResponse = false ;
		
		loader.initLoading(2) ;
		loadData() ;
		
		
		//### DEV ONLY
		/*Key.addListener({
			onKeyDown:callback(onKeyPress),
			onKeyUp:callback(onKeyRelease)
		}) ;*/
		//###
	}
		
	
	//### DEV ONLY
/*	function onKeyPress() {}
		
	public function onKeyRelease() {
		var n = Key.getCode() ;
			
		switch(n) {
			case Key.SPACE : submit() ;
			case Key.BACKSPACE : step = Waiting ;
			case Key.ALT : step = Wheeling ;
			case Key.HOME : trace(lastRecal) ;
			case Key.END: 
				
				var bmc = mcGui._wing._w._p0.getBounds(root) ;
				var ma = {x : bmc.xMax, y : bmc.yMin} ;
		
				bmc = mcGui._wing._w._p1.getBounds(root) ;
				var mb = {x : bmc.xMax, y : bmc.yMin} ;
				
				trace("p0 : " + ma.x + ", " + ma.y) ;
				trace("p1 : " + mb.x + ", " + mb.y) ;
				trace("rot :" + mcGui._wing._rotation) ;
			
			
				for (p in plots) {
					var bmc = p.mc.getBounds(root) ;
					var pp = {x : bmc.xMin + (bmc.xMax - bmc.xMin) / 2, y : bmc.yMin} ;
					
					
					var s = wingState(p, mcGui._wing._w._p0, mcGui._wing._w._p1) ;
					
					trace(p.reward + " # " + pp.x + ", " + pp.y + " side : " + s.side + " / dist : " + s.dist) ;
					
				}
				
				trace(lastRecal) ;
				trace("speed : " + wheels[0].sp) ;
				trace("v: " + wheels[0].v) ;
		}
	}
*/
	
	function initMc() {	
		initBg() ;
		initWheel() ;
		initStockMc() ;
		
		chx = mdm.attach("chx", DP_CHX) ;
		chx._x = 411.8 ;
		chx._y = 195.9 ;
		
		pnj = new Pnj("kat", mdm, 4, loader, null, true) ;
		pnj.mc = cast chx ;
		pnj.currentFrame = "normal" ;
		
		
		var fg = mdm.attach("frame", DP_FG) ;
		fg._x = 0 ;
		fg._y = 0 ;
	}
	
	function initStockMc() {
		mcStock = new ObjectMc(_GodFather, Wheel.me.mdm, Wheel.DP_STOCK) ;
		mcStock.mcQty = cast mcStock.mc.attachMovie("mcQty", "mcQty_0", 2) ;
		mcStock.mcQty._x = -17 ;
		mcStock.mcQty._y = 13 ;
		mcStock.mcQty._field.text = Std.string(stock) ;
		
		mcStock.mc._x = 8 ;
		mcStock.mc._y = 183 ;
		
		
		mcGui._button.onRollOver = callback(onRollOver, cast mcGui._button, mcStock.mcQty) ;
		mcGui._button.onRelease = callback(drop) ;
		mcGui._button.onPress = callback(onPress, cast mcGui._button) ;
		mcGui._button.onRollOut = callback(onRollOut, cast mcGui._button, mcStock.mcQty) ;	
		mcGui._button.onReleaseOutside = mcGui._button.onRollOut ;
	}
	
	
	//### ROLLS
	static function onRollOver(m : {>flash.MovieClip, _b : flash.MovieClip}, mcQty : flash.MovieClip) {
		if (Wheel.me.step != Waiting)
			return ;
		
		m.gotoAndStop(3) ;
		//objectHoverRender(m);
		/*m._b._xscale = 100 ;
		m._b._yscale = m.smc.smc._xscale ;*/
		/*mcQty._xscale = 115 ;
		mcQty._yscale = mcQty._xscale  ;*/
		
	}
	
	
	static function onRollOut(m : {>flash.MovieClip, _b : flash.MovieClip}, mcQty : flash.MovieClip) {
		if (Wheel.me.step != Waiting)
			return ;
		//objectRender(m);
		m.gotoAndStop(1) ;
		/*m._b._xscale = 100 ;
		m._b._yscale = m.smc.smc._xscale ;
		mcQty._xscale = 100 ;
		mcQty._yscale = mcQty._xscale  ;*/
	}
	
	static function onPress(m : {>flash.MovieClip, _b : flash.MovieClip}) {
		m.gotoAndStop(2) ;
	}
	
	
	static function objectRender(m : flash.MovieClip) {
		m.filters = [
			new flash.filters.GlowFilter(0x7A97AD, 2,3,3,3),
			new flash.filters.DropShadowFilter(5,110,0x1E272B,1,5,5,0.4)
		] ;
	}
	
	static function objectHoverRender(m : flash.MovieClip) {
		m.filters = [
			new flash.filters.GlowFilter(0xD9EFFF, 2,6,6,5),
			new flash.filters.DropShadowFilter(5,110,0x1E272B,1,5,5,0.4)
		] ;
	}	
	
	function initWheel() {
		mcGui = cast mdm.attach("gui", DP_WHEEL) ;
		mcGui._mainWheel._blur._alpha = 0 ;
		mcGui._w1._blur._alpha = 0 ;
		mcGui._w2._blur._alpha = 0 ;
		mcGui._w3._blur._alpha = 0 ;
		mcGui._w4._blur._alpha = 0 ;
		
		mcGui._button.gotoAndStop(1) ;
		
		wheels = new Array() ;
		wheels.push(cast {mc : mcGui._mainWheel, d : WHEEL_DIAMETER[0], wait : 7.0, timer : 0.0, v : 0, fr : 0.985, sp : START_SPEED, side : 1 }) ;
		wheels.push(cast {mc : mcGui._w1, d : WHEEL_DIAMETER[1], wait : 2.0, timer : 0.0, v : 0, fr : 0.975, sp : START_SPEED, side : -1 }) ;
		wheels.push(cast {mc : mcGui._w2, d : WHEEL_DIAMETER[2], wait : 4.0, timer : 0.0, v : 0, fr : 0.97, sp : START_SPEED, side : -1 }) ;
		wheels.push(cast {mc : mcGui._w3, d : WHEEL_DIAMETER[3], wait : 6.0, timer : 0.0, v : 0, fr : 0.975, sp : START_SPEED, side : -1 }) ;
		wheels.push(cast {mc : mcGui._w4, d : WHEEL_DIAMETER[4], wait : null, timer : 0.0, v : 0, fr : 0.96, sp : START_SPEED, side : -1 }) ;
		
		mcGui._rop3.smc._x += 30 ;
		mcGui._rop4.smc._x += 30 ;
			
		ropes = new Array() ;
		ropes.push({mc : mcGui._rop1.smc, sx : mcGui._rop1.smc._x, side : 1}) ;
		ropes.push({mc : mcGui._rop2.smc, sx : mcGui._rop2.smc._x, side : 1}) ;
		ropes.push({mc : mcGui._rop3.smc, sx : mcGui._rop3.smc._x, side : -1}) ;
		ropes.push({mc : mcGui._rop4.smc, sx : mcGui._rop4.smc._x, side : -1}) ;
		floors = new Array() ;
		floors.push({mc : mcGui._planche1, sx : mcGui._planche1._x}) ;
		floors.push({mc : mcGui._planche2, sx : mcGui._planche2._x}) ;
		floors.push({mc : mcGui._planche3, sx : mcGui._planche3._x}) ;
			
			
		bgs = new Array() ;
		bgs.push({mc : mcGui._bg1, sx : mcGui._bg1._x, sy : mcGui._bg1._y}) ;
		bgs.push({mc : mcGui._bg2, sx : mcGui._bg2._x, sy : mcGui._bg2._y}) ;
		bgs.push({mc : mcGui._bg3, sx : mcGui._bg3._x, sy : mcGui._bg3._y}) ;
			
		fixs = new Array() ;
		fixs.push({mc : mcGui._fix1, sx : mcGui._fix1._x, sy : mcGui._fix1._y}) ;
		fixs.push({mc : mcGui._fix3, sx : mcGui._fix3._x, sy : mcGui._fix3._y}) ;
		fixs.push({mc : mcGui._fix4, sx : mcGui._fix4._x, sy : mcGui._fix4._y}) ;
		
		//public static var LIMITS = [0.55, 0.73, 1.26, 1.78, 2.31, 2.83, 3.36, 3.87, 4.4, 4.93, 5.45, 5.95] ;
		plots = new Array() ; 
		plots.push({ang : 5.95, mc : mcGui._mainWheel._plots._p0, reward : "pyram3"}) ;
		plots.push({ang : 0.55, mc : mcGui._mainWheel._plots._p1, reward : "wind"}) ;
		plots.push({ang : 0.73, mc : mcGui._mainWheel._plots._p2, reward : "pa_1"}) ;
		plots.push({ang : 1.26, mc : mcGui._mainWheel._plots._p3, reward : "pyram1_1"}) ;
		plots.push({ang : 1.78, mc : mcGui._mainWheel._plots._p4, reward : "recipe"}) ;
		plots.push({ang : 2.31, mc : mcGui._mainWheel._plots._p5, reward : "water"}) ;
		plots.push({ang : 2.83, mc : mcGui._mainWheel._plots._p6, reward : "pyram5"}) ;
		plots.push({ang : 3.36, mc : mcGui._mainWheel._plots._p7, reward : "earth"}) ;
		plots.push({ang : 3.87, mc : mcGui._mainWheel._plots._p8, reward : "pa_2"}) ;
		plots.push({ang : 4.4, mc : mcGui._mainWheel._plots._p9, reward : "pyram1_2"}) ;
		plots.push({ang : 4.93, mc : mcGui._mainWheel._plots._p10, reward : "slot"}) ;
		plots.push({ang : 5.45, mc : mcGui._mainWheel._plots._p11, reward : "fire"}) ;
		
		
		initRot = plots[Std.random(plots.length - 1)].ang + 0.08 + Math.random() * (0.34  -0.08) ;
		
		mcGui._mainWheel._rotation = 180 * initRot / 3.14 ;
		
	}
	
	
	/*public function enableSubmit(b : Bool) {		
		if (b == mcSubmit.active)
			return ;
		
		mcSubmit.active = b ;
		mcCancel.active = b ;
		if (b) {
			mcSubmit.filters = [] ;
			Filt.glow(mcSubmit, 2, 0.7, 0xfffffff, true) ;
			Filt.glow(mcSubmit, 4, 2, 0x1A1612) ;
			Filt.glow(mcSubmit, 15, 1.1, 0x02051c) ;		
			
			submitMove = new anim.Anim(mcSubmit, Translation, Elastic(-1, 0.8), {x : mcSubmit._x, y : Const.MCSUBMIT_Y, speed : 0.01}) ;
			submitMove.onEnd = callback(function(c : Cauldron) {
							c.submitMove = null ;
						}, this) ;
			submitMove.sleep = 15.0 ;
			submitMove.start() ;
						
			var cMove = new anim.Anim(mcCancel, Translation, Quint(-1), {x : Const.MCCANCEL_X, y : Const.MCCANCEL_Y, speed : 0.02}) ;
			cMove.sleep = 15.0 ;
			cMove.start() ;
			
		}
	}*/
	
	
	function initBg() {
		bg = mdm.empty(DP_BG) ;
		
		var bgCoords = data._bginf.split(":") ;
		bgInfos = {x : Std.parseInt(bgCoords[0]), y : Std.parseInt(bgCoords[1])} ;
		if (bgCoords != null && bgCoords.length >2)
			Pnj.GLOW_TYPE = Std.parseInt(bgCoords[2]) ;
		
		bg._x = Std.parseInt(bgCoords[0]) ;
		bg._y = Std.parseInt(bgCoords[1]) ;
	
		
		var mcl = new flash.MovieClipLoader() ;
		var me = this ;
		mcl.onLoadError = function(_,err) {
			me.loader.reportError(err) ;
		}
		mcl.onLoadInit = function(_) {
			me.loader.done() ;
		}
		mcl.loadClip(loader.dataDomain + "/img/bg/" + data._bg + ".jpg",bg) ;
	}

	
	public function loop() {
				
		mt.Timer.update() ;
		updateMoves() ;
		
		updateSprites() ;
		
		if (shakeTimer > 0)
			shake() ;
		

		switch(step) {
			case Loading : 
				
			case Waiting :
				
				
			case Wheeling :
				switch(subStep) {
					case 0 : 
						//wTimer = wSpeed * mt.Timer.tmod ;
					
						var t = mt.Timer.tmod ;
						if (checkWait(t)) {
							rotate(t, 0.0, targetRot) ;
						} else {
							rotate(t, anim.TransitionFunctions.quint(wheels[0].timer) * wheels[0].sp, targetRot) ;
							
							if (wheels[0].timer == 1.0) {
								subStep = 1 ;
								initRot = lastRot ;
								countTurns = TURN_MAX_SPEED ;
								for (w in wheels)
									w.timer = 0.0 ;
							}
						}
						
					case 1 : 
						//wSpeed = Math.min(wSpeed + 0.002 * mt.Timer.tmod, MAX_SPEED) ;
						for (w in wheels) 
							w.sp = Math.min(w.sp + 0.002 * mt.Timer.tmod, MAX_SPEED) ;
					
						rotate(mt.Timer.tmod, wheels[0].sp / MAX_SPEED) ;
					
						if (wheels[0].timer == 1.0) {
							countTurns-- ;
							initRot = lastRot % 6.28 ;
							for (w in wheels)
								w.timer = 0.0 ;
							if (countTurns <= 0) {
								countTurns = TURN_DECC_SPEED ;
								subStep = 2 ;
							}
						}
					
						
					case 2 :
						wheels[0].sp = Math.max(wheels[0].sp - 0.001 * mt.Timer.tmod, 0.01) ;
					
						rotate(mt.Timer.tmod, wheels[0].sp / MAX_SPEED, TURN_DECC_SPEED * 6.28) ;
				
						if (wheels[0].timer == 1.0) {
							initRot = lastRot % 6.28 ;
							for (w in wheels)
								w.timer = 0.0 ;
							subStep = 3 ;
						}
						
					case 3 : 
						step = Result ;
					
					
						dialog = new Dialog(null, cast Wheel, DP_DIALOG, pnj, "/act/", null, true) ;
						dialog.autoKill = false ;
						if (result[0] == "1") {
							dialog.cmdFunc = callback(function(w : Wheel) {
													flash.external.ExternalInterface.call("_avu", Std.string(14) + ":" + Std.string(1)) ;
												}, this) ;
						}
					
						dialog.infos = BotText.getRewardDialog(result) ;
					
						dialog.processInfos() ;
						
					
				}
			
			
			case Result : 
				if (dialog != null)
					dialog.loop() ;
				
			case SDialog : 
				if (dialog != null)
					dialog.loop() ;
		}
	}
	
	
	function checkWait(t : Float) : Bool {
		t *= 15 * wheels[0].sp ;
		var res = false ;
		
		for (i in 0...wheels.length) {
			var w = wheels[i] ;
			if (i == 0 && w.wait == null)
				return false ;
			
			if (w.wait == null)
				continue ;
			w.wait -= t ;
			if (w.wait <= 0.0)
				w.wait = null ;
			else
				res = true ;
		}
		
		return res ; 
	}
	
	
	function rotate(timer : Float, ?acc = 1.0, ?toRot = 6.28) {
		if (wheels[0].wait == null) {
			if (subStep <= 1)
				wheels[0].v = acc ;
			else {
				wheels[0].v *= Math.max(Math.pow(wheels[0].fr, mt.Timer.tmod), 0.0) ;
			}
			
			if (subStep <= 1)
				wheels[0].timer = Math.min(wheels[0].timer + timer * wheels[0].sp, 1.0) ;
			else
				wheels[0].timer = Math.min(wheels[0].timer + timer * wheels[0].sp / TURN_DECC_SPEED, 1.0) ;
			
			var dt = switch(subStep) {
						case 0 : anim.TransitionFunctions.quint(wheels[0].timer) ;
						case 1 : wheels[0].timer ;
						case 2 : 1 - anim.TransitionFunctions.quad(1  -wheels[0].timer) ;
					}
			var nRot = initRot + dt * toRot ;
			mcGui._mainWheel._rotation = 180 * nRot / 3.14 ;
			mcGui._mainWheel._blur._alpha = wheels[0].v  * 100 ;
			mcGui._mainWheel.smc._alpha = 100 - 70 * wheels[0].v ;
			
			lastRot = nRot ;
					
					
			updateWing(nRot) ;
			
		}
		
		for (i in 1...wheels.length) {
			if (wheels[i].wait != null)
				continue ;
			
			if (subStep <= 1)
				wheels[i].v = acc ;
			else  {
				if (wheels[i].sp <= MIN_FRICT)
					continue ;
				wheels[i].v *= Math.max(Math.pow(wheels[i].fr, mt.Timer.tmod), MIN_FRICT) ;
				wheels[i].sp *= Math.max(Math.pow(wheels[i].fr, mt.Timer.tmod), MIN_FRICT) ;
			}
			
			wheels[i].timer += timer * wheels[i].sp ;
			
			var dt = if (subStep == 0) 
						anim.TransitionFunctions.quint(wheels[i].timer) ;
					else wheels[i].timer ;
			var localRot = toRot * wheels[0].d / wheels[i].d * wheels[i].side ;
			
			wheels[i].mc._rotation = (180 * (dt * localRot) / 3.14) % 360 ;
			wheels[i].mc._blur._alpha = wheels[i].v  * 80 ;
			wheels[i].mc.smc._alpha = 100 - 20 * wheels[i].v ;
		}
		
		
		
		
		if (subStep < 2)
			ropeSpeed = Math.min(ropeSpeed + 0.0015 * mt.Timer.tmod, ROPE_MAX_SPEED) ;
		else if (ropeSpeed > MIN_FRICT) 
			ropeSpeed *= Math.max(Math.pow(ROPE_FRICTION, mt.Timer.tmod), 0.0) ;
		
		if (ropeSpeed > MIN_FRICT) {
			ropeTimer = Math.min(ropeTimer + ropeSpeed * mt.Timer.tmod, 1.0) ;
	
			for (i in 0...ropes.length) {
				var r = ropes[i] ;
				r.mc._x = r.sx + r.side *  30 * ropeTimer ; 
			}
		
			if (ropeTimer == 1.0)
				ropeTimer = 0 ;
		}
		
		
		if (acc > 0.35) {
			var strength = acc * 3 ;
			var v = 3 ;
			var max = 0.5 ;
			for (f in floors) {
				var r = Math.min(Std.random(Math.round(strength * v)) / v, max) * (Std.random(2) * 2 - 1) ;
				f.mc._x = f.sx + r ;
			}
			
			
			for (f in fixs) {
				f.mc._x = f.sx + Math.min(Std.random(Math.round(strength * v)) / v, max) * (Std.random(2) * 2 - 1) ;
				f.mc._y = f.sy + Math.min(Std.random(Math.round(strength * v)) / v, max) * (Std.random(2) * 2 - 1) ;
			}
			max = 0.35 ;
			for (b in bgs) {
				b.mc._x = b.sx + Math.min(Std.random(Math.round(strength * v)) / v, max) * (Std.random(2) * 2 - 1) ;
				b.mc._y = b.sy + Math.min(Std.random(Math.round(strength * v)) / v, max) * (Std.random(2) * 2 - 1) ;
			}
			
		}
	}
	
	
	public function updateWing(wr : Float) {
		var r = wr % 6.28 ;
		var deltaR = 1.57 ;
		var hitIt = null ;
		var dl = 0.0 ;
		
		if ((subStep < 2 && wheels[0].v > 0.001) || (subStep >= 2 && wheels[0].sp > MAX_SPEED  * 0.10)) { //auto tac-tac
			if (wingAnim != null) {
				return ;
			}
			var fromRot = (mcGui._wing._rotation * 3.14 / 180 + 6.28) % 6.28 ;
			
			var rot = (30 * 3.14  / 180 - (if (fromRot != 0 ) 6.28 - fromRot else 0)) % 6.28 ;
			var backRot = (15 + Std.random(10)) * 3.14 / 180 ;
			var spMult = 8 ;
			
			
			var v = if (subStep < 2) 0.18 / 2 else wheels[0].sp ;
		
			wingAnim = new anim.Anim(mcGui._wing, Rotation(-1), Linear, {r : rot, speed : v * spMult}) ;
			wingAnim.onEnd = callback(function(w : Wheel) {
				w.wingAnim = new anim.Anim(w.mcGui._wing, Rotation(1), Quad(1), {r : backRot, speed : v * spMult}) ;
				w.wingAnim.onEnd = callback(function (ww : Wheel) {
					ww.wingAnim = null ;
				}, w) ;
				w.wingAnim.start() ;
			
			}, this) ;
			wingAnim.start() ;
			
		} else { //recal 
			for (p in plots) {
				
				var bmc = p.mc.getBounds(root) ;
				var pp = {x : bmc.xMin + (bmc.xMax - bmc.xMin) / 2, y : bmc.yMin} ;
				
				
				
				
				if (!p.mc.hitTest(mcGui._wing._w))
					continue ; 
				
				if ((wheels[0].sp < 0.05 && pp.y >153))
					continue ;
				
				hitIt = p ;
				
				break ;
			}
			
			
			
			if (hitIt == null)
				return ;
			
			var distLimit = 5.0 ;
			
			 lastRecal = wingState(hitIt, mcGui._wing._w._p0, mcGui._wing._w._p1) ;
			if (lastRecal.side > 0 && lastRecal.dist > distLimit)
				return ;
			
			if (wingAnim != null) {
				wingAnim.kill() ;
				wingAnim = null ;
			}
			
			var max = 10 ;
			var dr = -2.0 ;
			
			while (lastRecal.side < 0 || max == 10) {
				mcGui._wing._rotation = (mcGui._wing._rotation + dr) % 360;
				
				max-- ;
				
				lastRecal = wingState(hitIt, mcGui._wing._w._p0, mcGui._wing._w._p1) ;
				
				if (max < 0)
					break ;
			}
			
			
			
			max = 50 ;
			while (max > 0 && lastRecal.dist > distLimit) {
				max-- ;
				var ndr = dr / 2 * -1 ;
				mcGui._wing._rotation = (mcGui._wing._rotation + ndr) % 360 ;
				//trace("RECAL : " + mcGui._wing._rotation) ;
				
				lastRecal = wingState(hitIt, mcGui._wing._w._p0, mcGui._wing._w._p1) ;
				if (lastRecal.side > 0) {
					//trace("bad") ;
					mcGui._wing._rotation = ( mcGui._wing._rotation - ndr) % 360 ;
					ndr /= 2 ;
				}
				dr = ndr ;
			}
			
			
			var fromRot = (mcGui._wing._rotation * 3.14 / 180 + 6.28) % 6.28 ;
			var backRot = 6.28 - fromRot ;
			var spMult = 10 ;
			
			wingAnim = new anim.Anim(mcGui._wing, Rotation(1), /*Quad(-1)*/Bounce(-1), {r : backRot, speed : wheels[0].sp* spMult}) ;
			wingAnim.onEnd = callback(function (ww : Wheel) {
				ww.wingAnim = null ;
			}, this) ;
			wingAnim.start() ;
			
		}
		
	}
	
	
	function wingState(plot : Plot, p0 : flash.MovieClip, p1 : flash.MovieClip) : {side : Int, dist : Float, reward : String, y : Float} {
		var bmc = plot.mc.getBounds(root) ;
		
		var p = {x : bmc.xMin + (bmc.xMax - bmc.xMin) / 2, y : bmc.yMin} ;
		var y = p.y ;
		
		bmc = p0.getBounds(root) ;
		var ma = {x : bmc.xMax, y : bmc.yMin} ;
		
		bmc = p1.getBounds(root) ;
		var mb = {x : bmc.xMax, y : bmc.yMin} ;
		
		//var da = mb.y - ma.y ;
		var da = ma.y - mb.y ;
		var db = mb.x - ma.x ;
		var dc = da * ma.x + db * ma.y ;
		
		var res = {side : if (da * p.x + db * p.y > dc) 1 else -1, dist : Math.abs(da * p.x + db * p.y - dc) / Math.sqrt(da * da + db * db), reward : plot.reward, y : y} ;
		return  res ;
	}
	
	
	public function updateSprites() {
		var list = Sprite.spriteList.copy() ; 
		for (s in list) s.update() ;
	}
	
	
	function updateMoves() {
		var list = anim.Anim.onStage.copy() ; 
		for (m in list) m.update() ;
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
		
		pos = {x : 240, y : 140} ;
		Wheel.me.mcGui._x = pos.x + Std.random(Math.round(shakeTimer * v)) / v * (Std.random(2) * 2 - 1) ;
		Wheel.me.mcGui._y = pos.y + Std.random(Math.round(shakeTimer * v)) / v * (Std.random(2) * 2 - 1) ;
			
		if (Wheel.me.bg != null) {
			Wheel.me.bg._x = Wheel.me.bgInfos.x + shx ;
			Wheel.me.bg._y = Wheel.me.bgInfos.y + shy ;
		}
		
		
		Wheel.me.root._x = Std.random(Math.round(shakeTimer * v)) / v * (Std.random(2) * 2 - 1) ;
		Wheel.me.root._y = Std.random(Math.round(shakeTimer * v)) / v * (Std.random(2) * 2 - 1) ;
			
		
		
	}
	
	
	//### DATA


	function cacheObject() {
		preLoadObject = new ObjectMc(_Dynamit(0), mdm, 0, 
						callback(function(gg : Wheel) { gg.preLoadObject.mc._x = -1000 ; }, this)) ;
	}
	

	function loadData() {
		try {
			/*var s = secure.Utils.decode(secure.Utils.getKey(loader.k, dat, loader.s, loader.n)) ;
			data = haxe.Unserializer.run(s) ;*/
			data = secure.Codec.getData("d") ;
			ObjectMc.initMc(data._object_url, mdm, 0, callback(function() { Wheel.me.initMc() ;})) ; 
			stock = data._nb ;
			
			setStep(Waiting) ;
		} catch( e : Dynamic ) {
			loader.reportError(e) ;
			return ;
		}
		loader.done() ;
		//initMc() ;
	}

	
	
	function drop() {
		if (stock <= 0 || waitingResponse || step != Waiting)
			return ;
		
		//onRollOut(cast mcStock, cast mcStock.mcQty) ;
		//mcGui._button.gotoAndStop(2) ;
		
		var d = new ObjectMc(_GodFather, Wheel.me.mdm, Wheel.DP_STOCK -1) ;
		d.mc._x = mcStock.mc._x ;
		d.mc._y = mcStock.mc._y ;
		
		mcStock.mcQty._field.text = Std.string(stock - 1) ;
		
		waitingResponse = true ;
		
		submit() ;
		
		//var a= new anim.Anim(d.mc, Translation, Quad(1), {speed : 0.05, x : d.mc._x, y : 360}) ;
		//a.onEnd = callback(function(w : Wheel) {
			//w.submit() ;
		//}, this) ;
		//a.start() ;
	}
	
	
	function submit() {
		if (step != Waiting)
			return ;
		
		if (stock <= 0) {
			//### TODO : msg pas de chouette d'or dispo
			return ;
		}
		submitStep = 0 ;
		
		stock-- ;
		
		var lv = new flash.LoadVars() ;
		lv.onData = onSubmitReturn ;
		var url = loader.domain + "/gf/spend?rn=" + Std.random(100000) ;
		if( !lv.load(url)) {
			trace("error server access") ;
		}
		
	}
	
	
	function onSubmitReturn(dat : String) {		
		//try {
		waitingResponse = false ;
		
		if (dat == "no_object") {
			//### TODO : msg pas de chouette
			return ;
		}
		
		step = Wheeling ;
		
		/*if (submitData != null && submitData._error != null) {
			dialog = new Dialog(null, cast Cauldron, DP_DIALOG, null, "/act/", submitData._error) ;
		}*/
		
		setResult(dat) ;
			
		/*} catch( e : Dynamic ) {
			dialog = new Dialog(null, cast Cauldron, DP_DIALOG, null, "/act/", TEXT.ERR_STD) ;
		}*/
		
	}
	
	
	public function setResult(res : String) {
		try {
			result = res.split(";") ;
			
			finalRot = null ;
			
			var delta = 0.16 ;
			
			switch(result[1]) {
				case "pyram1" : //1.26 >1.6 OU 4.4 > 4.75
					finalRot = if (Std.random(2) == 0) (1.26+ delta + Math.random() * (1.6-1.26- delta)) else (4.4 + delta+ Math.random() * (4.75 - 4.4- delta))  ;
				case "pyram3" : //5.95 > 0.02 
					finalRot = 5.95 + delta + Math.random() * (0.35 - delta)  ;
				case "pyram5" : //2.83 > 3.18
					finalRot = 2.83 + delta+ Math.random() * (3.18 - 2.83 - delta) ;
				case "slot", "slot1", "slot2", "slot3" : //4.93 > 5.27
					finalRot = 4.93 + delta + Math.random() * (5.27 - 4.93 - delta) ;
				case "pa" : //0.73 > 1.08 OU 3.87 > 4.22
					finalRot = if (Std.random(2) == 0) (0.73 + delta + Math.random() * ( 1.08 - 0.73 - delta)) else (3.87 + delta + Math.random() * (4.22 - 3.87 - delta))  ;
				case "recipe" : //1.78 > 2.13
					finalRot = 1.78 + delta + Math.random() * (2.13 - 1.78 - delta) ;
				case "elt_earth" : //3.36 > 3.70
					finalRot = 3.36 + delta+ Math.random() * (3.7 - 3.36 - delta) ;
				case "elt_water" : //2.31 > 2.65
					finalRot = 2.31 + delta+ Math.random() * (2.65 - 2.31 - delta) ;
				case "elt_fire" : //5.45 > 5.78
					finalRot = 5.45 + delta+ Math.random() * (5.78 - 5.45 - delta) ;
				case "elt_wind" : //0.2 > 0.55
					finalRot = 0.2 + delta+ Math.random() * (0.55 - 0.2 - delta) ;
				default : 
					throw "bad result type" ;
			}
			
			if (finalRot != null) {
				setStep(Wheeling) ;
				subStep = 0 ;
				//wSpeed = START_SPEED ;
				targetRot = 6.28 - initRot + START_MOVE + finalRot ;
				
				ropeTimer = 0 ;
				ropeSpeed = START_SPEED ;
				
				// (initRot + " # " + targetRot + " # " + finalRot) ;
				lastRot = initRot ;
			}
				 
			
		
		} catch( e : Dynamic ) {
			//dialog = new Dialog(null, cast Wheel, DP_DIALOG, null, "/act/", TEXT.ERR_STD) ; // ### TO ACTIVATE FOR ERROR
		}
		
	}

	
	
	public function makeTextPart(t : String, delay : Float) {
		var m = mdm.attach("caulInfos", DP_DIALOG) ;
		(cast m)._field.text = t ;

		var p = new Phys(m) ;
		
		//p.root.blendMode = "overlay" ;
		p.x = WIDTH / 2 ;
		p.y = HEIGHT / 2 - 30 ;
		p.weight = -0.065 ;
		p.frict = 0.98 ;
		p.sleep = delay ;
		p.timer = 70 ;
		p.fadeType = 4 ;
	}


	
	public function setStep(s : Step, ?l : Bool) {
		step = s ;
		
		/*
		if (step == Default && waitingDialog != null) {
			if (dialog == null) {
				startDialog(waitingDialog) ;
				waitingDialog = null ;
				
			}
		}*/
		
		if (l == null || !l)
			loader.unlock() ;
		else
			loader.lock() ;
	}
	
	
	public function startDialog(id : String) {
		if (dialog != null)
			return false ;
		
		dialog = new Dialog(id, Wheel, DP_DIALOG, pnj, "/act/") ;
		dialog.postKill = callback(function(w : Wheel) {
			flash.external.ExternalInterface.call("_activeAll") ;
			w.pnj.setFrame("normal") ;
			w.setStep(Waiting) ;
			
			}, this) ;
		setStep(SDialog) ;
		return true ;
	}
	
	
	/*public function setInfo(t : String) {
		if (dialog != null)
			return ;
		dialog = new Dialog(null, cast Cauldron, DP_DIALOG, null, t) ;
		if (valid)
			dialog.postKill = callback(function() {flash.external.ExternalInterface.call("_activeAll") ; }) ;
		setStep(SDialog) ;
	}*/


	function submitOver() { //### TEMP
		/*if (!mcSubmit.active)
			return ;
		
		if (step != Default)
			return ;
		
		if (submitMove != null)
			submitMove.kill() ;
		
		var targetY = if (!mcSubmit.active) Const.MCSUBMIT_Y_UNACTIVE else Const.MCSUBMIT_Y_ACTIVE ;
		submitMove = new anim.Anim(mcSubmit, Translation, Elastic(-1, 0.8), {x : mcSubmit._x, y : targetY, speed : 0.02}) ;
		submitMove.onEnd = callback(function(c : Cauldron) {
							c.submitMove = null ;
						}, this) ;
		submitMove.start() ;*/
		
		
	}
	
	
	function submitOut() { //### TEMP
		/*if (!mcSubmit.active)
			return ;
		
		if (step != Default)
			return ;
		upRope() ;*/
		
	
	}
	
}




//### JS CALLS
class _Com {
	

	
	
	public static function _sDialog(did : String) : Bool {
		if (did == "callChx") //no chx call in cauldron 
			return false ;
		
		if (Wheel.me.loader.isLoading() || Wheel.me.step != Waiting || Wheel.me.waitingResponse)
			return false ;
		
		if (Wheel.me.dialog == null) {
			return Wheel.me.startDialog(did) ;
		} else 
			return false ;
	}

	
	public static function _answer(aid : String) : Bool {
		//trace("answer : " + aid );
		if (Wheel.me.loader.isLoading() || Wheel.me.dialog == null || aid == null)
			return false ;
		
		return Wheel.me.dialog.answer(aid) ;
	}
	
	
}
	
