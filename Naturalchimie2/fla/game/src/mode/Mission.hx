package mode ;

import GameData._ArtefactId ;
import anim.Transition ;
import anim.Anim.AnimType ;
import Game.GameStep ;
import StageObject.DestroyMethod ;
import mode.GameMode.TransformInfos ;
import Stage.TempEffect ;


class Mission extends GameMode {
	
	static var START_TURNS = 13 ;
	static var DELTA_TURN = 3 ;
	static var MIN_TURN = 5 ;
	static var QUEST_SIZE = 3 ;
	static var DELTA_HIDE_GROUP = 70.0 ;
	static var GROUP_X = 233.0 ;
	static var GROUP_Y = 83.0 ;
	
	
	var mc : flash.MovieClip ;
	var dm : mt.DepthManager ;
	var mcTurn : {>flash.MovieClip, _nb : flash.TextField} ;
	var ttMc : flash.MovieClip ;
	var tdm : mt.DepthManager ;
	
	var toTransform : Array<StageObject> ;
	var turns : mt.flash.Volatile<Int> ;
	var countDone : mt.flash.Volatile<Int> ;
	var plops : Array<{e : Element, wait : Float}> ;
	public var step : Int ;
	public var timer : Float ;
	
	public var curCombos : Array<_ArtefactId> ;
	public var curSearch : Array<StageObject> ;
	public var curCheck : Int ;
	public var tgroup : Array<Element> ;
	
	
	public function new() {
		super() ;
		hideSpirit = true ;
		countDone = 0 ;
		step = 0 ;
		turns = getTurns() ;
		
		initMc() ;
	}
	
	
	function initMc() {
		mc = Game.me.mdm.empty(Const.DP_INVENTORY) ;
		dm = new mt.DepthManager(mc) ;
	}
	
	
	override public function initStage(st : Stage) { 
		super.initStage(st) ;
		init() ;
	}
	
	
	function init() {
		ttMc = Game.me.mdm.empty(Const.DP_NEXT_GROUP) ;
		ttMc.setMask(Game.me.gui._spirit_box._spmask) ;
		tdm = new mt.DepthManager(ttMc) ;
		
		setMission() ;
		
		mcTurn = cast dm.attach("questTurn", 2) ;
		mcTurn._x = 257;
		mcTurn._y = 34 ;
		mcTurn._nb.text = Std.string(turns) ;
		mcTurn._alpha = 0 ;
		
		var speed = 0.01 ;
		var a = new anim.Anim(mcTurn, Alpha(1) , Quint(-1), {speed : speed}) ;
		a.sleep = 24 ;
		a.start() ;
		
		showMission() ;
	}
	
	
	function showMission(?f : Void -> Void, ?sound = true) {
		var d = DELTA_HIDE_GROUP ;
		for (o in toTransform) {
			var a = new anim.Anim(o.omc.mc, Translation, Elastic(-1, 1.0), {x : o.omc.mc._x, y : o.omc.mc._y - d, speed : 0.01}) ;
			a.onEnd = f ;
			a.start() ;
		}
		
		Game.me.sound.play("inversion", null, 2) ;
		mcTurn._nb.text = Std.string(turns) ;
	}
	
	override public function loop() {
		switch(step) {
			case 0 : 
				timer = Math.min(timer + 0.07 * mt.Timer.tmod, 1.0) ;
			
				if (timer == 1.0) {
					plops = new Array() ;
					for (i in 0...Stage.WIDTH) {
						if (Game.me.stage.grid[i][Stage.LIMIT - 1] != null)
							continue ;
						else {
							var e = new Element(Game.me.mode.getRandomElement(), Game.me.stage.dm, Stage.HEIGHT - 3) ;
							e.omc.mc._alpha = 0 ;
							e.place(i, Stage.HEIGHT - 3, Stage.X + i * Const.ELEMENT_SIZE, Const.HEIGHT - (Stage.Y + (Stage.HEIGHT - 3) * Const.ELEMENT_SIZE +  Math.random() * 40)) ;
							Game.me.stage.add(e) ;
							plops.push({e : e, wait : Math.random() * 15}) ;
						}
					}
						
						
					step = 1 ;
					timer = 0.0 ;
				}
			
			case 1 : 
				var t = mt.Timer.tmod ;
				var all = 0 ;
				for (o in plops) {
					if (o.wait <= 0) {
						if (all == 0)
							Game.me.sound.play("protoplop") ;
						all++ ;
						continue ;
					}
					
					o.wait -= t ;
					if (o.wait > 0)
						continue ;
					
					var c = o.e.getCenter() ;
					var explode = o.e.pdm.attach("transformExplosion", Const.DP_PART) ;
					explode.blendMode = "overlay" ;
					explode._rotation = Math.random()*360 ;
					explode._x = c.x ;
					explode._y = c.y ;
					explode._xscale = 80 ;
					explode._yscale = 80 ;
					
					o.e.omc.mc._alpha = 100 ;
				}
				
				if (all == plops.length) {
					Game.me.sound.play("chute") ;
					setMission() ;
					turns  = getTurns() ;
					
					showMission(null, false) ;
					
					Game.me.setStep(Destroy) ;
					
					step = 2 ;
					
					
				}
			
			case 2 : //waitong for animation end
				
		}
	}
	
	public function flushMission() {
		var sp = 0.035 ;
		
		var a = new anim.Anim(mcTurn, Alpha(-1) , Quint(1), {speed : sp}) ;
		a.start() ;
		
		//for (i in 0...toTransform.length) {
			//var o = toTransform[i] ;
			//var a = new anim.Anim(o.omc.mc, Alpha(-1) , Quint(1), {speed : sp}) ;
			var a = new anim.Anim(ttMc, Alpha(-1) , Quint(1), {speed : sp}) ;
			//if (i == toTransform.length - 1) {
				a.onEnd = callback(function(m : mode.Mission) {
					for (o in m.toTransform) {
						o.kill() ;
					}
					m.setMission() ;
					m.turns = m.getTurns() ;
					var aa = new anim.Anim(m.mcTurn, Alpha(1) , Quint(-1), {speed : 0.01}) ;
					aa.start() ;
					m.showMission() ;
					
				}, this) ;
			//}
			a.start() ;
		//}
	}
	
	
	public function setMission() {
		toTransform = new Array() ;
		
		ttMc._alpha = 100 ;

		var countParasit = 0 ;
		var last = null ;
		
		var n = QUEST_SIZE ;
		
		for (i in 0...n) {
			var depth = n + 1 - i ;
			var r = Game.me.mode.getRandomElement(false, 0) ;
			if (i == n -1) {
				if (r == last) {
					var cmax = 20 ;
					var cc = 0 ;
					while(r == last && cc < cmax) {
						r = Game.me.mode.getRandomElement(false, 0) ;
						cc++ ;
					}
				}
			}
			
			last = r ;
			
			var o = null ;
			o = new Element(r, tdm, depth) ;
			
			o.omc.mc._x = GROUP_X ;
			o.omc.mc._y = GROUP_Y + DELTA_HIDE_GROUP ;
			o.omc.mc._alpha = 65 ;
			
			switch(i) {
				case 0 : 
					o.omc.mc._x += Const.ELEMENT_SIZE / 2 ;
					o.omc.mc._y += Const.ELEMENT_SIZE / 2 ;
				case 1 : 
					o.omc.mc._x -= Const.ELEMENT_SIZE / 2 ;
					o.omc.mc._y += Const.ELEMENT_SIZE / 2 ;
				case 2 : 
					o.omc.mc._x -= Const.ELEMENT_SIZE / 2 ;
					o.omc.mc._y -= Const.ELEMENT_SIZE / 2 ;
				case 3 :
					o.omc.mc._x += Const.ELEMENT_SIZE / 2 ;
					o.omc.mc._y -= Const.ELEMENT_SIZE / 2 ;
			}
				
			toTransform.push(o) ; 
		}
		
	}
	
	function getTurns() : Int {
		return Std.int(Math.max(MIN_TURN, START_TURNS - countDone * 0.07)) + (Std.random(2) * 2 - 1) * Std.random(DELTA_TURN) ; 
		
	}
	
	override public function onRelease() {
		super.onRelease() ;
		
		tgroup = null ;
	}
	
	
	override public function onGround() {
		super.onGround() ;
		
		if (groundDone > 1 || Game.me.stage.lastNextSize < 2)
			return ;
		
		turns-- ;
		if (turns >= 0)
			mcTurn._nb.text = Std.string(turns) ;
		
		if (turns >= 0)
			return ;
		
		questLost() ;
	}
	
	
	function questLost() {
		countDone++ ;
		step = 0 ;
		timer = 0.0 ;
		
		for (i in 0...toTransform.length) {
			var o = toTransform[i] ; 
			
			o.toDestroy(Flame(true)) ;
			o.fEndDestroy = callback(function(oo : StageObject, mm : mode.Mission)  {
				mm.killTransform(o) ;
			}, o, this) ;
		}
		
		Game.me.setStep(Destroy) ;
		Game.me.stage.setShake(3) ;
	}
	
	
	public function killTransform(o : StageObject) {
		toTransform.remove(o) ;
		o.kill() ;
		if (toTransform.length == 0)
			Game.me.setStep(Mode) ;
	}
	
	
	
	//##########" PARSING
	
	override public function haveToParse() : Bool { 
		return true ;
	}
	
	
	override public function startParse(o : StageObject, from : StageObject, st : Stage) : Bool {
		if (tgroup != null) {
			//trace("tgroup not null for " + Std.string(from.getArtId())) ;
			return false ;
		}
		
		//trace("start Parse for : " + from.getArtId() + " # " + from.x + ", " + from.y ) ;
		curSearch = new Array() ;
		curCombos = new Array() ;
		var found = false ;
		for (to in toTransform) {
			var tid = to.getArtId() ;
			if (!found && Type.enumEq(tid, o.getArtId()))
				found = true ;
			curCombos.push(tid) ;
		}
		
		if (!found)
			return false ;
		
		curCheck = -1 ;
		
		var g = st.getNewGroup() ;
		check(o) ;
		
		if (parseEG(o, st)) {
			for (oo in curSearch) {
				oo.setGroup(g, true) ;
			}
			tgroup = cast g ;
			/*trace("tgroup done :  " + Std.string(tgroup.length)) ;
			for (t in tgroup)
				trace(t.getArtId() + " # " + t.x + " , " + t.y) ;*/
			return true ;
		} else {
			//trace("ungroup " + Std.string(from.getArtId()) + " # " + from.x + " , " + from.y) ;
			st.groups.remove(g) ;
			return false ;
		}
	}
	
	
	function parseEG(o : StageObject, st : Stage) : Bool {
		var r = false ;
		
		for(d in 0...4) {
			var neighbour = st.getNeighbour(o, d) ;
			
				
			if (neighbour == null || Lambda.exists(curSearch, function(x) { return x == neighbour ;}))
				continue ;
			
			//trace("neighbour : " + neighbour.getArtId() + " # " + neighbour.x + ", " + neighbour.y) ;

			
			var res = check(neighbour) ;
			
			switch(res) {
				case -1 : 
					continue ;
				case 0 : 
					//curSearch.push(neighbour) ;
					r = r || parseEG(neighbour, st) ;
					if (r)
						break ;
				case 1 : 
					//curSearch.push(neighbour) ;
					r = true ;
					break ;
			}
		}
		
		return r ;
	}

	
	public function check(o : StageObject) : Int { //-1 if nothing found, 0 if possible future match, 1 if match
		for (c in curCombos.copy()) {
			if (Type.enumEq(o.getArtId(), c)) {
				curCombos.remove(c) ;
				curSearch.push(o) ;
				if (curCombos.length > 0)
					return 0 ;
				else 
					return 1 ;
			}
		}
		
		return -1 ;
	}
	
	
	override public function transformInfos(g : Array<Element>) : Array<{t : TransformInfos, g : Array<Element>}> {
		if (g == tgroup) {
			countDone++ ;
			flushMission() ;
			
			var t = getTransformed(g) ;
			
			var next = _Block(2 + Std.random(2)) ;
		
			if (!Game.me.stage.hasEffect(FxDollyxir))
				return [{t : {x : t.x, y : t.y, e : cast t, nextElt : null, nextArt : next}, g : g}] ;
			
			//### Dollyxir process
			var dg = g.copy() ;
			dg.remove(t) ;

			var tt = getTransformed(dg, t) ;
			return [{t : {x : t.x, y : t.y, e : cast t, nextElt : null, nextArt : next}, g : [t]},
				{t : {x : tt.x, y : tt.y, e : cast tt, nextElt : null, nextArt : next}, g : dg}] ;
		
		}
		
		
		return super.transformInfos(g) ;
	}
	
}