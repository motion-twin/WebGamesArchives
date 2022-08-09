package mode ;

import GameData._GameData ;
import GameData._Artefact ;
import GameData._ArtefactId ;
import Stage.TempEffect ;
import Const.Art ;


enum TransFormPos {
	BottomLeft ;
	BottomRight ;
	TopLeft ;
	TopRight ;
}


typedef TransformInfos = {
	var x : Int ;
	var y : Int ;
	var e : StageObject ;
	var nextElt : Int ;
	var nextArt : _ArtefactId ;	
}


class GameMode {
	
	public var  chain : Array<Art> ;
	public var  chWeight : Array<mt.flash.Volatile<Int>> ;
	public var chainKnown : mt.flash.Volatile<Int> ;
	public var curChainKnown : mt.flash.Volatile<Int> ;
	public var useBonus : mt.flash.Volatile<Int> ;
	public var level : mt.flash.Volatile<Int> ;
	public var qmin : mt.flash.Volatile<Int> ;		
	public var staticScore : mt.flash.Volatile<Int> ;
	public var tpos : TransFormPos ;
	public var hideSpirit : Bool ;
	public var groundDone : Int ;
	
	
	public var objects : {ids : Array<Art>, probs : Array<mt.flash.Volatile<Int>>} ;
	
	
	
	public function new() {
		useBonus = -1 ;
		tpos = BottomLeft ;
		staticScore = 0 ;
		hideSpirit = false ;
		groundDone = 0 ;
		initLevel() ;
	}
	
	
	function initLevel() {
		level = 3 ;
	}
	
	public function getFinalLevel() {
		return level ;
	}

	public static function get(data : _GameData) : mode.GameMode {
		var m : GameMode = null ;
		switch(data._mode) {
			case "IceAttack" :	m = new IceAttack() ;
			case "Dig" :		m = new Dig() ;
			case "Tutorial" :	m = new Tutorial() ;
			case "Wind" : 		m = new Wind() ;
			case "Mission" : 	m = new Mission() ;
			case "Default" : 	m = new GameMode() ;
			default : 		m = new GameMode() ;
		}
		
		m.setChain(data._chain, data._chWeight) ;

		m.chainKnown = data._chainknown ;
		m.curChainKnown = m.chainKnown ;
		m.useBonus = data._object ;
		
		m.qmin = data._qmin ;

		/*if (m.useBonus >= 0)
			Game.me.inventory = new Inventory(data._userobjects) ;*/
		
		m.setArtefacts(data._artefacts) ;

		
		return m ;
	}
	
	
	public function initInventory(data : _GameData) {
		if (useBonus >= 0)
			Game.me.inventory = new Inventory(data._userobjects) ;
	}
	
	public function initStage(st : Stage) { //default mode : nothing to do 
	}
	
	public function checkFallEnd() : Bool { //default mode : nothing to do 
		return false ;
	}
	
	public function onRelease() {
		groundDone = 0 ;
	}
	
	public function onGround()  { //default mode : nothing to do 
		groundDone ++ ;
	}
	
	public function onTransform() { //default mode : nothing to do
	}
	
	public function haveToParse() : Bool{ //default mode : no
		return false ;
	}
	
	public function startParse(o : StageObject, from : StageObject, st : Stage) : Bool { //default mode : nothing to do
		return false ;
	}
	
	public function checkEnd() { //default mode : nothing to do
		return false ;
	}
	
	public function onGameOver() { //default mode : nothing to do
	}
	
	public function loop() { //default mode : nothing to do 
	}
	
	public function updateEffect() { //default mode : nothing to do 
	}
	
	public function updateScore() {
		return staticScore + Game.me.stage.getPoints() ;
	}
	
	public function addToScore(s : Int) { //default mode : nothing to do 
		staticScore += s ;
	}
	
	
	public function setChain(ch : Array<_ArtefactId>, w : Array<Int>) {
		if (ch.length != 12 || w.length != 12) {
			trace("invalid chain") ;
			throw "invalid chain" ;
		}
		//chain = ch ;
		chain = new Array() ;
		for (a in ch) {
			chain.push(Const.getArt(a)) ;
		}
		chWeight = new Array() ;
		for (cw in w) {
			var v : mt.flash.Volatile<Int> = 0 ;
			v = cw ;
			chWeight.push(v) ;
		}
	}
	
	
	public function isInChain(a : _ArtefactId) : Int {
		for (i in 0...chain.length) {
			if (Type.enumEq(Const.fromArt(chain[i]), a))
				return i ;
		}
		return null ;
	}
	
	
	public function getUsedArtefacts() : Array<_Artefact> {
		var res = new Array() ;
		for (i in 0...objects.ids.length) {
			res.push({_id : Const.fromArt(objects.ids[i]), _freq : objects.probs[i]}) ;
		}
		
		return res ;
	}
	
	
	public function setArtefacts(arts : Array<_Artefact>) {
		if (arts == null || arts.length == 0)
			return ;

		objects = {ids : [], probs : []/*, artIds : []*/} ;
		for (a in arts) {
			addArtefact(a) ;
		}
	}
	
	
	public function addArtefact(a : _Artefact) {
		var art = Const.getArt(a._id) ;
		objects.ids.push(art) ;
		var v : mt.flash.Volatile<Int> = 0 ;
		v = a._freq ;
		objects.probs.push(v) ;
	}
	
	
	public function isEndChain(e : Element) : Bool {
		if (!Game.me.stage.hasEffect(FxDelorean))
			return e.index == chain.length - 1 ;
		else 
			return e.index == 0 ;
	}
	
	
	public function transformInfos(g : Array<Element>) : Array<{t : TransformInfos, g : Array<Element>}> {		
		if (Type.enumEq(g[0].getArtId(), _Empty)) //empty special transform
			return transformEmptyInfos(g) ;
		
		var t = getTransformed(g) ;
	
		var n = 
			if (!Game.me.stage.hasEffect(FxDelorean))
				g[0].index + 1 ;
			else 
				g[0].index - 1 ;
		
		checkLevel(n) ;
		
		if (!Game.me.stage.hasEffect(FxDollyxir))
			return [{t : {x : t.x, y : t.y, e : cast t, nextElt : n, nextArt : null}, g : g}] ;
			
		//### Dollyxir process
		var dg = g.copy() ;
		dg.remove(t) ;

		var tt = getTransformed(dg, t) ;
		var nn = n ;
		if (Std.random(15 - n) == 0) //pour de l'or, 1 chance sur 4 que ça foire
			nn = Std.random(t.index) ;
		
		return [{t : {x : t.x, y : t.y, e : cast t, nextElt : n, nextArt : null}, g : [t]},
			{t : {x : tt.x, y : tt.y, e : cast tt, nextElt : nn, nextArt : null}, g : dg}] ;
	}
	
	
	public function transformEmptyInfos(g : Array<Element>) : Array<{t : TransformInfos, g : Array<Element>}> {
		var t = getTransformed(g) ;
		
		if (!Game.me.stage.hasEffect(FxDollyxir))
			return [{t : {x : t.x, y : t.y, e : cast t, nextElt : null, nextArt : (cast g[0]).toTransformTo}, g : g}] ;
			
		//### Dollyxir process
		var dg = g.copy() ;
		dg.remove(t) ;

		var tt = getTransformed(dg, t) ;
		return [{t : {x : t.x, y : t.y, e : cast t, nextElt : null, nextArt : (cast g[0]).toTransformTo}, g : [t]},
			{t : {x : tt.x, y : tt.y, e : cast tt, nextElt : null, nextArt : (cast g[0]).toTransformTo}, g : dg}] ;
		
	}
	
	
	function getTransformed(g : Array<Element>, ?adjacent : Element) {
		var t = g[0] ;
		
		if (adjacent != null) {
			var gg = new Array() ;
			for (o in g) {
				if ((o.x == adjacent.x && Std.int(Math.abs(o.y - adjacent.y)) == 1) || (o.y == adjacent.y && Std.int(Math.abs( o.x - adjacent.x)) == 1))
					gg.push(o) ;
			}
			
			if (gg.length > 0) {
				g = gg ;
				t = gg[0] ;
				if (gg.length == 1)
					return t ;
			}
		}
		
		for (i in 1...g.length) {
			var e = g[i] ;
			switch (tpos) {
				case BottomLeft : 
					if (e.y < t.y || (e.y == t.y && e.x < t.x))
						t = e ;
				case BottomRight : 
					if (e.y < t.y || (e.y == t.y && e.x > t.x))
						t = e ;
				case TopLeft : 
					if (e.y > t.y || (e.y == t.y && e.x < t.x))
						t = e ;
				case TopRight : 
					if (e.y > t.y || (e.y == t.y && e.x > t.x))
						t = e ;
			}
		}
		return t ;
	}
	
	
	public function checkLevel(n : Int) {
		if (n  /*>*/  >= level && n < chain.length/* - 1*/) {
			level++ ;
			
			if (level > curChainKnown) {
				var eid = null ;
				switch(Const.fromArt(chain[n])) {
					case _Elt(ei) : eid = Std.string(ei) ;
					default : //nothing to do
				}
				
				if (eid != null) {
					Game.me.addToJs(callback(function(s : String, t : String) {flash.external.ExternalInterface.call("_majc", s, t) ; }, Std.string(n), "elt" + eid)) ;
					//flash.external.ExternalInterface.call("_majc", Std.string(n), "elt" + eid) ; //update tpl quest values
				}
				
				curChainKnown = level ;
			}
			
			return true ;
		}
		return false ;
	}
	
	
	public function getNext(?notOnlyElements : Bool = true) : _ArtefactId {
		var p = objects.probs ;
		if (!notOnlyElements) {
			p = [] ;
			for (i in 0...objects.probs.length) {
				switch(Const.fromArt(objects.ids[i])) {
					case _Elts(n, _) : 
						p.push(objects.probs[i]) ;
					default :
						p.push(0) ;
				}
			}
		}
		
		var i = Const.randomProbs(p) ;
		return Const.fromArt(objects.ids[i]) ;
	}
	
	
	public function getRandomElement(?parasit : Bool = false, ?c = 0) : Int {
		var max = Std.int(Math.min(level, chain.length - 1)) ;
		 if (!parasit)
			return Const.randomProbs(chWeight.slice(0, max)) ;
		else {
			c++ ;
			return Const.randomProbs([Std.int(chWeight[0] / (c * c))].concat(chWeight.slice(0, max))) - 1 ;
		}

	}
	
	
}
