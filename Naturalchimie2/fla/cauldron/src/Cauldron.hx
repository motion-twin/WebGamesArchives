import flash.Key ;
import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import mt.bumdum.Phys ;
import anim.Anim.AnimType ;
import anim.Transition ;
import MapData._MapData ;
import GameData._ArtefactId ;
import CauldronData._CauldronSubmit ;
import CauldronData.CauldronResult ;
import CauldronData._RaceSubmit ;
import CauldronData.RaceResult ;

class TextFr {
	public static var ERR_STD = "{Aïe, une erreur est survenue ! } Vous n'avez pas perdu vos éléments, mais rechargez la page avant de faire un nouvel essai. ";
	public static var ERR_SVR = "Impossible de contacter le serveur de jeu. Vos éléments ne sont pas perdus." ;
}


enum Step {
	NoWay ;
	SDialog ;
	Map ;
	Default ;
	WaitResult ;
	Results ; // special effect (recipe result)
	Transition ; //loading, waiting response
}

typedef Drop = {
	var omc : ObjectMc ;
	var cOmc : ObjectMc ;
	var rOmc : ObjectMc ;
	var sOmc : ObjectMc ;
	var cMask : flash.MovieClip ;
	var rMask : flash.MovieClip ;
	var sMask : flash.MovieClip ;
	var timer : Float ;
	var x : Float ;
	var y : Float ;
	var sx : Float ;
	var sy : Float ;
	var ex : Float ;
	var ey : Float ;
	var zf : Float ; 
	var vr : Float ;
	var sp: Float ;
	var weight : Float ;
	var frict : Float ;
	var h : Float ;
	var step : Int ;
	var back : Float ;
	var rDecal : Float ;
}



class Cauldron {
	
	public static var TEXT = TextFr ;
	
	public static var DEBUG = false ;
		
	public static var DP_BG = 0 ;
	public static var DP_PNJ = 1 ;
	public static var DP_ELEMENTS_BG = 2 ;
	public static var DP_CAULDRON_INTO = 4 ;

	public static var DP_ELEMENTS = 5 ;
	public static var DP_DROPS = 6;
	
	
	public static var DP_INTERFACE = 7 ;
	public static var DP_EFFECT = 8 ;
	public static var DP_DIALOG = 9 ;	
	public static var DP_CLOUDS = 10 ;

	public static var DP_MAP = 11 ;
	public static var DP_FG = 12 ;
	public static var DP_LOADING = 13 ;
		
	public static var WIDTH = 500 ;
	public static var HEIGHT = 300 ;
	
	public static var NOWAY_BG = "noway" ;
	
	public static var me : Cauldron ;
		
	var waitingResponse : Bool ;
	
	public var data : CauldronData ;
	public var cIdx : Int ;
	public var valid : Bool ;
	public var jsConnect : Dynamic ;
	public var step : Step ;

	public var mdm : mt.DepthManager ;
	public var ddm : mt.DepthManager ;
		
	public var loader : Load ;
	public var root : flash.MovieClip ;
	public var bg : flash.MovieClip ;
		
	var preLoadObject : ObjectMc ;
		
	//inventory
	public var inventory : Inventory ;
	public var drops : Array<Drop> ;
	public var soupMove : anim.Anim ;
	public var soupRots : Array<{mc : flash.MovieClip, sr : flash.MovieClip, timer : Float, s : Int}> ;
	var nPlop : Int ;
	var bgInfos : {x : Int, y : Int} ;
	
	//cauldron
	//public var mcCauldron : {>flash.MovieClip, front : flash.MovieClip, mask : flash.MovieClip, back : flash.MovieClip} ;
	public var mcCauldron : {>flash.MovieClip, _soupe : flash.MovieClip, _dropZone : flash.MovieClip, _debug : flash.TextField} ;
	
	public var mcSubmit : {>flash.MovieClip, active : Bool} ;
	public var mcCancel : {>flash.MovieClip, active : Bool} ;
	public var submitMove : anim.Anim ;
	var submitStep : Int ;
	var submitData : Dynamic ;
	var shakeTimer : Float ;
	//public var submitBalance : Float ;
	
	//result
	public var result : result.Result ;
	
	//effect 
	public var effect : ZoneEffect ;
	
	//map
	public var map : Map ;
	public var mcMap : flash.MovieClip ;
	
	//dialog
	public var dialog : Dialog ;
	public var isSpeaking : Bool ;
	public var keeper : Pnj ;
	public var keeperGone : Bool ;
	var waitPlop : Float ;
	public var resultWait : Float ;
	public var resultDialogFunc : Void -> Void ;
	public var waitingDialog :String ;
	
	
	

	public function new(mc : flash.MovieClip, l : CauldronLoader) {
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
		waitPlop = 50 ;
		cIdx = 0 ;
		
		drops = new Array() ;
		waitingResponse = false ;
		
		loader.initLoading(2) ;
		loadData() ;
		
	}
	
	
	function initMc() {	
		initBg() ;
		initCauldron() ;
		
		var fg = mdm.attach("frame", DP_FG) ;
		fg._x = 0 ;
		fg._y = 0 ;
		
		if (data._effect == "cthulo")
			effect = new ZoneEffect(data._effect, Cauldron, DP_EFFECT) ;
	}
	
	
	function initCauldron() {
		var cx = WIDTH / 2 ;

		mcCauldron = cast mdm.attach(Const.CAULDRON_NAME[cIdx], DP_CAULDRON_INTO) ;
		mcCauldron._x = Const.CAULDRON_PLACE[cIdx][0] ;
		mcCauldron._y = Const.CAULDRON_PLACE[cIdx][1] ;
		Const.SOUP_MAX = mcCauldron._soupe._y ;

		switch(cIdx) {
			case 0 : //dungeon cauldron   
				nPlop = 5 ;
				mcCauldron._soupe._y += Const.SOUP_DELTA_INIT ;

			case 1 : //race well	
				nPlop = 0 ;
				Const.SOUP_DELTA_INIT = 0 ;
		}

		
		ddm = new mt.DepthManager(mcCauldron._dropZone) ;
		
		if (!DEBUG)
			mcCauldron._debug._visible = false;
		
		if (!isRace()) {
			soupRots = new Array() ;
			for (i in 0...4) {
				if (i > 1)
					continue ;
				var r = {mc : mcCauldron._soupe.createEmptyMovieClip("rot" + i, i + 1), sr : null, timer : 50.0 + Std.random(800), s : Std.random(2) * 2 -1} ;
				var sr = r.mc.attachMovie("soupeRot", "sr" + i, 1) ;
				sr._yscale = 25 ;
				
				sr.gotoAndStop(i + 1) ;
				sr.blendMode = "overlay" ;
				sr._alpha = 60 ;
				r.sr = sr ;
				r.sr.smc._rotation = Std.random(360 - (i + 1) * 45) + (i + 1) * 45 ;
				Filt.blur(sr, 10, 0) ;
				
				soupRots.push(r) ;
			}
		}
		
		mcSubmit = cast mdm.attach("shazam", DP_ELEMENTS) ;
		mcSubmit._x = 30 ;
		
		mcCancel = cast mdm.attach("cancelButton", DP_INTERFACE) ;
		mcCancel._x = - 50 ;
		mcCancel.gotoAndStop(1) ;
		
		//mcSubmit._y = Const.MCSUBMIT_Y ;
		mcSubmit._y = Const.MCSUBMIT_Y_NOT_READY ;
		
		mcSubmit.onRollOver = submitOver ;
		mcSubmit.onRollOut = submitOut ;
		mcSubmit.onReleaseOutside = submitOut ;
		mcSubmit.onRelease = submit ;
		
		mcCancel.onRollOver = cancelOver ;
		mcCancel.onRollOut = cancelOut ;
		mcCancel.onReleaseOutside = cancelOut ;
		mcCancel.onRelease = cancel ;
		
		enableSubmit(false) ;
		
	}
	
	
	public function initKeeper() {
		var df = callback(function(c : Cauldron) {
			c.keeper.mc._alpha = 100 ;
			c.keeper.setGlow() ;
			c.keeper.mc._x = WIDTH - Dialog.PNJ_PADDING ;
			c.keeper.mc._y = HEIGHT - Dialog.PNJ_DY ;
			c.keeperGone = false ;
			
		}, this) ;
		
		keeper = new Pnj(data._keeper._gfx, mdm, DP_PNJ, loader, df) ;
		
	}
	
	
	public function enableSubmit(b : Bool) {
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
		
		/*if (b)
			Col.setPercentColor(mcSubmit, 0, 0xFFFFFF) ;
		else { 
			mcSubmit.onRollOut() ;
			Col.setPercentColor(mcSubmit, 80, 0xFFFFFF) ;
		}*/
		
	}

	
	function initInventory() {
		inventory = new Inventory() ;
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
		mcl.loadClip(loader.dataDomain + "/img/bg/" + (if (valid) data._bg else NOWAY_BG) + ".jpg",bg) ;
	}

	
	public function loop() {
				
		mt.Timer.update() ;
		updateMoves() ;
		
		if (DEBUG){
			mcCauldron._debug.text="FPS : "+mt.Timer.fps();
		}
		
		if (step != Map) {
			updateSprites() ;
			updateDrops() ;
			updateCauldron() ;
			
			if (shakeTimer > 0)
				shake() ;
			
			if (effect != null)
				effect.update() ;
			
			if (dialog != null)
				dialog.loop() ;
			else if (resultDialogFunc != null && resultWait > 0.0) {
				resultWait = resultWait - 1.0 * mt.Timer.tmod ;
				if (resultWait <= 0.0) {
					resultWait = null ;
					var f = resultDialogFunc ;
					resultDialogFunc = null ;
					f() ;
				}
			}
		}
		

		
		switch(step) {
			case Default : 
				if (dialog == null)
					inventory.loop() ;
				
			case WaitResult :
				switch(submitStep) {
					case 0, 1, 2 : //wait for anim complete and submit return
					case 3 : 
						if (isRace())
							updateRace(cast submitData) ;
						else
							showResult(cast submitData) ;
						//submitData = null ; 
				}					
				
			case Results :
				if (result != null)
					result.loop() ;
				else 
					setStep(Default) ;
				
			case NoWay : 
				
			case SDialog : 
				
			case Map : 
				if (map != null)
					map.loop() ;
			case Transition : 
				
		}
	}
	
	
	function updateCauldron() {
		if (mcCauldron == null ||isRace())
			return ;
		
		waitPlop = Math.max(0, waitPlop - 2.0 * mt.Timer.tmod) ;
		if (waitPlop == 0 && step == Default) {
			waitPlop = 10.0 + Std.random(90) ;
			nPlop = ((nPlop + 1) % 60) + 5 ;
			var plop = mcCauldron._soupe.attachMovie("bulle", "b_" + Std.random(9999), nPlop) ;
			plop.gotoAndStop(Std.random(3) + 1) ;
			plop.blendMode = "overlay" ;
			plop._xscale = 75 + Std.random(40) ;
			plop._yscale = 75 + Std.random(40) ;
			if (Std.random(2) == 0)
				plop._xscale *= -1 ;
			
			plop._x = (Std.random(2) * 2 - 1) * Std.random(80) ;
			plop._y = (Std.random(2) * 2 - 1) * Std.random(Std.int((80 - Math.abs(plop._x )) / 5)) - 20 * (1.0 - Math.abs(plop._x) / 100) ;
		}
		
	}
	
	public function updateSprites() {
		var list = Sprite.spriteList.copy() ; 
		for (s in list) s.update() ;
	}
	
	
	public function resetSubmitAnim(?fast = false) {
		if (fast) 
			moveSoup(Elastic(-1, 0.8), 0.01, Const.SOUP_MAX + Const.SOUP_DELTA_INIT) ;
		else
			moveSoup(Elastic(-1, 0.5), 0.015, Const.SOUP_MAX + Const.SOUP_DELTA_INIT) ;
		upRope(true) ;
	}
	
	
	public function resetRaceSubmitAnim(?halo = false, ?url : String) {
		moveSoup(Elastic(-1, 0.3), 0.015, Const.SOUP_MAX) ;
		upRope(true) ;
	}
	
	
	function updateDrops() {
		/*if (flash.Key.isDown(flash.Key.SHIFT)) {
				trace(drops.length) ;
			return ;
		}*/
				
		var cc = 0.0 ;
		var plouf = 0 ;
		for (d in drops.copy()) {
			
			//d.sp = 0.015 ;
			
			switch(d.step) {
				case 0 : 
					var oldTimer = d.timer ;
					var tLimit = 0.5 ;
				
					d.timer = Math.min(d.timer + d.sp * mt.Timer.tmod, 1.0) ;
					
					//var dt = anim.Anim.getValue(Pow(1), d.timer) ; 
					var dt = d.timer ;
					
					d.sp += d.weight * mt.Timer.tmod ;
					d.sp *= Math.pow(d.frict, mt.Timer.tmod) ;
					
					d.x = d.sx * (1 - dt) + d.ex * dt ;
					d.y = d.sy * (1 - dt) + d.ey * dt ;
					cc = Math.sin((Const.RAD / 2) * dt) * d.zf ;					
					
					if (oldTimer < tLimit && d.timer >= tLimit) {
						d.cOmc.mc._x = d.x - mcCauldron._x - mcCauldron._dropZone._x ;
						d.cOmc.mc._y = d.y - mcCauldron._y - mcCauldron._dropZone._y ;
						d.cOmc.mc._b._rotation = d.omc.mc._b._rotation ;
						d.cOmc.mc._visible = true ;
						d.omc.kill() ;

					}
					
					var toReflect = null ;
					if (d.timer < tLimit) {
						d.omc.mc._x = d.x ;
						d.omc.mc._y = d.y ;
						d.omc.mc._y -= cc ;
						toReflect = d.omc.mc ;
						
						if (d.vr != null) 
							d.omc.mc._b._rotation += d.vr * mt.Timer.tmod ;
					} else {
						d.cOmc.mc._x = d.x - mcCauldron._x - mcCauldron._dropZone._x ;
						d.cOmc.mc._y = d.y - mcCauldron._y - mcCauldron._dropZone._y ;
						d.cOmc.mc._y -= cc ;
						toReflect = d.cOmc.mc ;
						
						
						if (d.vr != null) 
							d.cOmc.mc._b._rotation += d.vr * mt.Timer.tmod ;
						
						d.sOmc.mc._x = d.cOmc.mc._x ;
						d.sOmc.mc._y = d.cOmc.mc._y ;
						d.sOmc.mc._b._rotation = d.cOmc.mc._b._rotation ;
					}
					
					if (toReflect != null) {
						d.rOmc.mc._x = toReflect._x ;
						d.rOmc.mc._y = toReflect._y + Math.abs(d.ey - d.y + cc) * 2 + d.rDecal / 2 ;
						
						d.rOmc.mc._alpha = Math.min(30, d.timer * 40) ;
						
						d.rOmc.mc._b._rotation = toReflect._b._rotation ;
					}
					
					if (d.timer == 1) {
						d.step = 1 ;
						d.timer = 0.0 ;
						var osx = d.sx ;
						d.sx = d.ex ;
						d.sy = d.ey ;
						d.ex = d.ex + (d.ex - osx) / 30 ;
						d.ey = d.ey + 80 ;
						
						if (Std.random(3) == 0)
							d.sp = 0.038 ;
						
						if (Math.abs(d.vr) < 0.5 && Std.random(3) == 0)
							d.vr *= -1 ;
						plouf++ ;
						
						
						//parts//
						animPlouf(d.cOmc.mc) ;
					}
					
			case 1 : 
				d.sp += d.weight * mt.Timer.tmod / 1.1 ;
				d.sp *= Math.pow(d.frict, mt.Timer.tmod) ;
			
				d.timer = Math.min(d.timer + d.sp / 2 * mt.Timer.tmod, 1.0) ;
			
				var dt = anim.Anim.getValue(Back(1, d.back), d.timer) ;  /*Elastic(1, 0.25)*/
			
				d.x = d.sx * (1 - dt) + d.ex * dt ;
				d.y = d.sy * (1 - dt) + d.ey * dt ;
			
				d.cOmc.mc._x = d.x - mcCauldron._x - mcCauldron._dropZone._x ;
				d.cOmc.mc._y = d.y - mcCauldron._y - mcCauldron._dropZone._y ;
						
						
				if (d.vr != null) 
					d.cOmc.mc._b._rotation += d.vr * mt.Timer.tmod / 6 ;
				
				d.rOmc.mc._x = d.cOmc.mc._x ;
				
				d.rOmc.mc._y = d.cOmc.mc._y + ((d.sy - d.y) * 2 + d.rDecal / 2) ;
				d.rOmc.mc._b._rotation = d.cOmc.mc._b._rotation ;
				
				d.sOmc.mc._x = d.cOmc.mc._x ;
				d.sOmc.mc._y = d.cOmc.mc._y ;
				d.sOmc.mc._b._rotation = d.cOmc.mc._b._rotation ;

				if (d.timer == 1) {
					//plouf++ ;
					drops.remove(d) ;
					d.omc.kill() ;
					d.cOmc.kill() ;
					d.rOmc.kill() ;
					d.sOmc.kill() ;
					if (d.cMask != null)
						d.cMask.removeMovieClip() ;
					if (d.rMask != null)
						d.rMask.removeMovieClip() ;
					if (d.sMask != null)
						d.sMask.removeMovieClip() ;
				}
			}
			
			//trace("step : " + d.step + " # " + d.rOmc.mc._y + " # " + d.y + " # " +  d.cOmc.mc._y + " # " + (Math.abs(d.ey - d.y + cc) * 2 + 19) + " # " + (Math.abs(d.sy - d.y) * 2 + 19)) ;
		}
		upSoup(plouf) ;
	}
	
	
	function upSoup(n : Int) {
		if (n <= 0 || mcCauldron._soupe._y <= Const.SOUP_MAX)
			return ;
		
		if (soupMove != null) {
			return ;
			//soupMove.kill() ;
		}
		
		var p = 1.5 ;
		
		var target = Math.max(Const.SOUP_MAX, mcCauldron._soupe._y - n * p) ;
		soupMove = new anim.Anim(mcCauldron._soupe, Translation, Quint(-1)/*Elastic(-1, 1 + 0.05 * n)*/, {x : mcCauldron._soupe._x, y : target, speed : 0.05}) ;
		soupMove.onEnd = callback(function(c : Cauldron) {
							c.soupMove = null ;
						}, this) ;
		soupMove.start() ;
	}
	
	
	function moveSoup(?type, ?sp = 0.03, ?target : Float) {
		if (soupMove != null)
			soupMove.kill() ;
		
		if (type == null)
			type = Quint(1) ;
		if (target == null)
			target = Const.SOUP_MAX + Const.SOUP_DELTA_SUBMIT ;
		
		soupMove = new anim.Anim(mcCauldron._soupe, Translation, type, {x : mcCauldron._soupe._x, y : target, speed : sp}) ;
		soupMove.onEnd = callback(function(c : Cauldron, stt : Bool) {
							c.soupMove = null ;
							if (stt)
								c.submitStep++ ;
						}, this, target > mcCauldron._soupe._y) ;
		soupMove.start() ;
	}
	
	
	function animPlouf(from : flash.MovieClip) {
		var plop = ddm.attach("bulle", 7) ; //mcCauldron._soupe.attachMovie("bulle", "b_" + Std.random(9999), nPlop) ;
		plop.gotoAndStop(2) ;
		plop.smc.gotoAndPlay(18 + Std.random(3)) ;
		if (isRace())
				Col.setPercentColor(plop, 75, 0x7ae9fa) ;
		plop.blendMode = "overlay" ;
		plop._xscale = 120 + Std.random(30) ;
		plop._yscale = plop._xscale ;
		plop._x = from._x + 15 ;
		plop._y = from._y + 5 ;
		
		
		var np = 15 ;
		for (i in 0...np) {	
			var p = new Phys(ddm.attach("liquid_part",7)) ;

			if (isRace())
				Col.setPercentColor(p.root, 75, 0x7ae9fa) ;
				

			p.root.blendMode = "overlay" ;
			p.root._xscale = 80 + Math.random() *  100 ;
			p.root._yscale = 80 + Math.random() *  100 ;
			p.x = from._x + 15 + (Std.random(2) * 2 -1) * 10 ;
			p.y = from._y ;
			p.weight = 0.3+Math.random() * 0.5 ;
			
			var a = - Math.random() * 3.14 ;
			p.vx = Math.cos(a) * 2 ;
			p.vy = Math.sin(a) * 5 ;
			p.vr = (Std.random(2) * 2 - 1) * Math.random() * 2 ;
			
			p.timer = 20 ;
			p.fadeType = 6 ;
		}
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
		
		if (keeper != null) {
			pos.x = WIDTH - Dialog.PNJ_PADDING ;
			pos.y = HEIGHT - Dialog.PNJ_DY ;
			keeper.mc._x = pos.x + shx ;
			keeper.mc._y = pos.y + shy ;
		}
		
		pos = {x : 240, y : 140} ;
		Cauldron.me.mcCauldron._x = pos.x + Std.random(Math.round(shakeTimer * v)) / v * (Std.random(2) * 2 - 1) ;
		Cauldron.me.mcCauldron._y = pos.y + Std.random(Math.round(shakeTimer * v)) / v * (Std.random(2) * 2 - 1) ;
		
		
			
		if (Cauldron.me.bg != null) {
			Cauldron.me.bg._x = Cauldron.me.bgInfos.x + shx ;
			Cauldron.me.bg._y = Cauldron.me.bgInfos.y + shy ;
		}
		
		
		Cauldron.me.root._x = Std.random(Math.round(shakeTimer * v)) / v * (Std.random(2) * 2 - 1) ;
		Cauldron.me.root._y = Std.random(Math.round(shakeTimer * v)) / v * (Std.random(2) * 2 - 1) ;
		
		
		
	}
	
	
	//### DATA
	function loadData() {
		try {
			data = secure.Codec.getData("d") ;
			Pnj.DATA_URL = data._pnj_url ;
			secure.Utils.key = data._dialogKey ;
			ObjectMc.initMc(data._object_url, mdm, 0, callback(function() { Cauldron.me.initInventory() ;})) ; //### TEST TEST
			if (isRace())
				cIdx = 1 ;
			setStep(Default) ;
		
		} catch(e : Dynamic) {
			loader.reportError(e) ;
			return ;
		}

		loader.done() ;
		valid = data._valid ;
		initMc() ;
		//initInventory() ;
		
		keeperGone = true ;
		if (data._keeper != null)
			initKeeper() ;
		
		if (data._noway != null) 
			setNoWay() ;

		
	}
	
	
	function cacheObject() {
		preLoadObject = new ObjectMc(_Dynamit(0), mdm, 0, 
						callback(function(gg : Cauldron) { gg.preLoadObject.mc._x = -1000 ; }, this)) ;
	}
	
	/*
	function onData(dat : String) {
		try {
			var s = secure.Utils.decode(secure.Utils.getKey(loader.k, dat, loader.s, loader.n)) ;
			data = haxe.Unserializer.run(s) ;
			
		} catch( e : Dynamic ) {
			loader.reportError(e) ;
			return ;
		}
		loader.done() ;
		valid = data._valid ;
		initMc() ;
		
		keeperGone = true ;
		if (data._keeper != null)
			initKeeper() ;
		
		if (data._noway != null) 
			setNoWay() ;
	}*/

	
	function setNoWay() {
		if (data._noway._did != null)
			startDialog(data._noway._did) ;
		else
			setInfo(data._noway._text) ; //###TODO
	}
	
	
	function submit() {
		if (waitingResponse)
			return ;
		
		var ds = inventory.getDrops() ;
		if (ds.length == 0)
			return ;
		
		//anim
		if (submitMove != null)
			submitMove.kill() ;
		
		submitMove = new anim.Anim(mcSubmit, Translation, Elastic(-1, 0.7), {x : mcSubmit._x, y : Const.MCSUBMIT_Y_DONE, speed : 0.02}) ;
		submitMove.onEnd = callback(function(c : Cauldron) {
							c.submitMove = null ;
							c.submitStep++ ;
						}, this) ;
		submitMove.addOnCoef(0.10, callback(function(c : Cauldron) {
							c.moveSoup() ;
						}, this)) ;
		submitMove.start() ;
		
		submitStep = 0 ;
		hideCancel() ;
		
		waitingResponse = true ;
		setStep(WaitResult) ;
		inventory.stop() ;
		enableSubmit(false) ;
		
		// send server request
		/*var lv = new flash.LoadVars() ;
		var url = null ;*/

		if (!isRace()) {
			var v : _CauldronSubmit = {_objects : ds, _v : secure.Codec.VERSION} ;
			/*var data = secure.Utils.encode(haxe.Serializer.run(v)) ;
			lv.onData = onSubmitReturn ;
			url = loader.domain + "/cauldron/transform?rn=" + Std.random(100000) + "&d=" + data ;*/

			secure.Codec.load(loader.domain + "/cauldron/transform?rn=" + Std.random(100000), v, onSubmitReturn) ;

		} else {
			var rds = new Array() ;
			for (d in ds) {
				var found = false ;
				if (data != null && data._raceNeedState != null) {
					for (s in data._raceNeedState) {
						if (!Type.enumEq(s._o, d._o))
							continue ;
						rds.push({_o : d._o, _qty : d._qty, _from : s._qty}) ;
						found = true ;
						break ;
					}
				}

				if (!found)
					rds.push({_o : d._o, _qty : d._qty, _from : null}) ;
			}

			var v : _RaceSubmit = {_curLevel : data._raceLevel, _objects : rds, _v : secure.Codec.VERSION} ;
			/*var data = secure.Utils.encode(haxe.Serializer.run(v)) ;
			lv.onData = onSubmitReturn ;
			url = loader.domain + "/cauldron/raceGive?rn=" + Std.random(100000)  + "&d=" + data ;*/
			secure.Codec.load(loader.domain + "/cauldron/raceGive?rn=" + Std.random(100000), v, onSubmitReturn) ;
		}
		
		/*if( !lv.load(url))
			trace("error server access") ;*/
	}
	
	
	function onSubmitReturn(dat : Dynamic) {
		
		try {
			waitingResponse = false ;
			inventory.resetDrops() ;
			/*var s = secure.Utils.decode(dat) ;
			submitData = haxe.Unserializer.run(s) ;*/
			submitData = dat ;
			
			if (submitData != null && submitData._error != null) {
				dialog = new Dialog(null, cast Cauldron, DP_DIALOG, null, "/act/", submitData._error) ;
			}
			
			submitStep++ ;
			//showResult(result) ;
			
		} catch( e : Dynamic ) {
			if (isRace()) {
				var lv = new flash.LoadVars() ;
				lv.send(Cauldron.me.loader.domain + "/cauldron", "_self") ;
			} else
				dialog = new Dialog(null, cast Cauldron, DP_DIALOG, null, "/act/", TEXT.ERR_STD) ;
		}
		
	}
	
	function updateRace(r : RaceResult) {
		var defaultWait = 40.0 ;

		result = new result.RaceDonation(r._toMaj, r._url, r._done) ;
		setStep(Results) ;
	}
	
	
	function showResult(r : CauldronResult) {
		
		if (r._dialog != null) {
			if (r._dialog._answers != null && r._dialog._answers.length > 0) //real dialog ==> to start after result anim
				waitingDialog = r._dialog._id ;
			else { //just a keeper joke
				resultDialogFunc = callback(function(c : Cauldron, d) {
					c.dialog = new Dialog(null, cast Cauldron, DP_DIALOG, c.keeper, "/act/", null, true) ;
					c.dialog.infos = d ;
					c.dialog.postKill = callback(function(cc : Cauldron) {
						if (cc.keeper != null)
							cc.keeper.setFrame(cc.data._keeper._frame) ;
					}, c) ;
					c.dialog.processInfos() ;
				}, this, r._dialog) ;
			
			}
		}
		
		var defaultWait = 40.0 ;
		
		if (r._rRank != null) //maj book js
			flash.external.ExternalInterface.call("_upbo", r._rid, Std.string(r._rRank), if (r._rAgain) "1" else "0") ;


		if (r._activeDouble != null) //maj actrec button
			flash.external.ExternalInterface.call("_dorec", if (r._activeDouble) "1" else "0") ;
		
		
		if (r._isForb) {
			result = new result.Forbidden() ;
			resultWait = defaultWait  ;
			
		} else {
			switch(r._result) {
				case _Fail : 
					result = new result.Fail() ;
					resultWait = defaultWait * 2 ;
				
				case _Add(o, qty, questQty) :
					result = new result.Add(o, qty, questQty, r._gotRank) ;
					resultWait = defaultWait ;

				case _Win(token, gold) : 
					result = new result.Win(token, gold, r._gotRank) ;
					resultWait = defaultWait ;
					
				case _Avatar(a, b, icon) :
					flash.external.ExternalInterface.call("_avu", Std.string(a) + ":" + Std.string(b)) ;
					
					result = new result.Avatar(icon, r._gotRank) ;
					resultWait = defaultWait ;
				
					/*resetSubmitAnim() ;
					setStep(Default) ;*/
				
				case _AvatarList(l, icon) :
					var sl = "" ;
					for (a in l) {
						if (sl != "")
							sl +="," ;
						switch(a) {
							case _Avatar(c, d, ic) : 
								sl += Std.string(c) + ":" + Std.string(d) ;
							default : 
								//do nothing ;
						}
					}
				
					flash.external.ExternalInterface.call("_avu", sl) ;
					result = new result.Avatar(icon, r._gotRank) ;
					resultWait = defaultWait ;
					/*resetSubmitAnim() ;
					setStep(Default) ;*/
					
				case _KeeperGoOut(fx, done) :
					if (keeperGone || keeper == null) {
						resetSubmitAnim() ;
						setStep(Default) ;
					} else {
						result = new result.Fx(fx) ;
						if (fx == "umbra")
							resultWait = 0.001 ;
						else if (fx == "redux")
							resultWait = defaultWait / 4 ;
						else
							resultWait = defaultWait ;
					}
				
				case _Smiley(img, nb) : 
					result = new result.Smiley(img, nb, r._gotRank) ;
					resultWait = defaultWait ;
				
				case _Color(c, chars) : 
					result = new result.Color(c, r._gotRank) ;
					resultWait = defaultWait ;
				
				case _Texture(t) : 
					//### TODO
					resetSubmitAnim() ;
					setStep(Default) ;
				
				//unused here
				case _AvatarRand(a, rMax, p) : 
					throw "Error AvatarRand " ;
				case _AvatarTemp(fx, av, icon) : //always return avatarlist
					throw "Error AvatarTemp " ;
				case _AvatarInc(a, s) : 
					throw "Error AvatarInc" ;
				case _Temp(fx, time) :
					result = new result.Fx(fx) ;
					resultWait = defaultWait ;
					
				case _Kaboom(fx) :
					switch(fx) {
						case "nocthul" : 
							if (effect != null)
								effect.goOut() ;
							resetSubmitAnim() ;
							setStep(Default) ;
						
						default : 
							result = new result.Fx(fx) ;
							resultWait = defaultWait ;
					}
			}
		}
		
		if (resultDialogFunc == null)
			resultWait = null ;
		
		setStep(Results) ;
	}


	public function postResult() {

		if (submitData != null && submitData._backFire != null) {
			result = new result.Add(submitData._backFire, 1, 0, null, true) ;
			setStep(Results) ;
		} else
			setStep(Default) ;

		submitData = null ;


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


	//### MAP
	public function switchMap() : Bool {
		if (map == null) {
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
		var f = callback(function(mc, z : Cauldron) {
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
		m.onEnd = callback(function(z : Cauldron) {
						z.map.kill() ;
						z.map = null ;
						z.setStep(Default, false) ;
				}, this) ;
		m.start() ;
	}
	
	
	public function setStep(s : Step, ?l : Bool) {
		step = s ;
				
		if (step == Default && waitingDialog != null) {
			if (dialog == null) {
				startDialog(waitingDialog) ;
				waitingDialog = null ;
				
			}
		}
		
		if (l == null || !l)
			loader.unlock() ;
		else
			loader.lock() ;
	}
	
	
	public function startDialog(id : String) {
		if (keeper == null || keeperGone || dialog != null)
			return false ;
		
		dialog = new Dialog(id, Cauldron, DP_DIALOG, keeper, "/act/") ;
		if (valid)
			dialog.postKill = callback(function(c : Cauldron) {
				flash.external.ExternalInterface.call("_activeAll") ;
				if (c.keeper != null)
					c.keeper.setFrame(c.data._keeper._frame) ;
				c.setStep(Default) ;
				
				}, this) ;
		setStep(SDialog) ;
		return true ;
	}
	
	
	public function setInfo(t : String) {
		if (dialog != null)
			return ;
		dialog = new Dialog(null, cast Cauldron, DP_DIALOG, null, t) ;
		if (valid)
			dialog.postKill = callback(function() {flash.external.ExternalInterface.call("_activeAll") ; }) ;
		setStep(SDialog) ;
	}


	function submitOver() { //### TEMP
		if (!mcSubmit.active)
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
		submitMove.start() ;
		
		/*mcSubmit._xscale = 105 ;
		mcSubmit._yscale = mcSubmit._xscale ;
		mcSubmit._y += 10 ;*/
	}
	
	public function isRace() {
		return data._type == "race" ;
	}
	
	
	function submitOut() { //### TEMP
		if (!mcSubmit.active)
			return ;
		
		if (step != Default)
			return ;
		upRope() ;
		
		/*if (!mcSubmit.active)
			return ;
		mcSubmit._xscale = 100 ;
		mcSubmit._yscale = mcSubmit._xscale ;
		mcSubmit._y -= 10 ;*/
	}
	
	
	function cancelOver() {
		/*if (submitMove != null)
			return ;*/
		
		mcCancel.gotoAndStop(2) ;
	}
	
	function cancelOut() {
		mcCancel.gotoAndStop(1) ;
	}
	
	
	function cancel() {
		if (step != Default || !mcCancel.active)
			return ;
		
		if (!inventory.cancelDrops())
			return ;
		
		enableSubmit(false) ;
		hideCancel() ;
		upRope(true) ;
		
	}
	
	
	function hideCancel() {
		//mcCancel.onRelease = null ;
		var cMove=  new anim.Anim(mcCancel, Translation, Quint(1), {x : -50, y : Const.MCCANCEL_Y, speed : 0.035}) ;
		cMove.start() ;
	}
	

	function upRope(?hide = false) {
		if (submitMove != null)
			submitMove.kill() ;
		
		submitMove = new anim.Anim(mcSubmit, Translation, Elastic(-1, 0.3), {x : mcSubmit._x, y : if (hide) Const.MCSUBMIT_Y_NOT_READY else Const.MCSUBMIT_Y, speed : 0.03}) ;
		submitMove.onEnd = callback(function(c : Cauldron) {
							c.submitMove = null ;
						}, this) ;
		submitMove.start() ;
	}
}




//### JS CALLS
class _Com {
	
	public static function _sMap() : Bool {
		if (Cauldron.me.loader.isLoading() || Cauldron.me.dialog != null || !Cauldron.me.valid)
			return false ;
		return Cauldron.me.switchMap() ;
	}
	
	
	public static function _sDialog(did : String) : Bool {
		//trace("sDialog ####") ;
		if (did == "callChx") //no chx call in cauldron 
			return false ;
		
		if (Cauldron.me.loader.isLoading() || Cauldron.me.map != null || !Cauldron.me.valid)
			return false ;
		
		if (Cauldron.me.dialog == null) {
			return Cauldron.me.startDialog(did) ;
		} else 
			return false ;
	}

	
	public static function _answer(aid : String) : Bool {
		//trace("answer : " + aid );
		if (Cauldron.me.loader.isLoading() || Cauldron.me.dialog == null || aid == null)
			return false ;
		
		return Cauldron.me.dialog.answer(aid) ;
	}
	
	
}
	
