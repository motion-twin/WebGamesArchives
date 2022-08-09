package mode ;

import GameData.Artefact ;
import GameData.ArtefactId ;
import Stage.TempEffect ;
import mt.bumdum.Lib ;



enum TransFormPos {
	BottomLeft ;
	BottomRight ;
	TopLeft ;
	TopRight ;
}


typedef TransformInfos = {
	var x : mt.flash.Volatile<Int> ;
	var y : mt.flash.Volatile<Int>;
	var e : StageObject ;
	var nextElt : mt.flash.Volatile<Int> ;
	var nextArt : ArtefactId ;
	
}


class GameMode {
	
	public var  chain : mt.flash.PArray<ArtefactId> ;
	public var  chWeight : mt.flash.PArray<mt.flash.Volatile<Int>> ;
	public var useBonus : Bool ;
	public var level : mt.flash.Volatile<Int> ;
	//public var staticScore : mt.flash.Volatile<Int> ;
	public var tpos : TransFormPos ;
	public var groundDone : Int ;
	
		
	public var objects : {ids : mt.flash.PArray<ArtefactId>, probs : mt.flash.PArray<mt.flash.Volatile<Int>>} ;
	
	
	
	public function new() {
		useBonus = false ;
		tpos = BottomLeft ;
		//staticScore = 0 ;
		groundDone = 0 ;
		initLevel() ;
	}
	
	
	function initLevel() {
		level = 3 ;
	}
	

	public static function get(data : GameData) : mode.GameMode {
		var m : GameMode = null ;
		switch(data.mode) {
			default : 		m = new GameMode() ;
		}
		
		m.setChain(data.chain, data.chWeight) ;
		m.useBonus = false ;
/*
		if (m.useBonus)
			Game.me.inventory = new Inventory(data._userobjects) ;*/
		
		m.setArtefacts(data.artefacts) ;
		
		return m ;
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
	
	public function checkEnd() { //default mode : nothing to do
		return false ;
	}
	
	public function loop() { //default mode : nothing to do 
	}
	
	public function updateScore() {
		return /*staticScore +*/ Game.me.stage.getPoints() ;
	}
	
/*	public function addToScore(s : Int) { //default mode : nothing to do 
		staticScore += s ;
	}
	*/
	
	public function setChain(ch : mt.flash.PArray<ArtefactId>, w : mt.flash.PArray<Int>) {
		if (ch.length != 12 || w.length != 12)
			throw "invalid chain" ;
		chain = ch ;
		chWeight = w ;	
	}
	
	
	public function isInChain(a : ArtefactId) : Int {
		for (i in 0...chain.length) {
			if (Type.enumEq(chain[i], a))
				return i ;
		}
		return null ;
	}
	

	
	
	public function setArtefacts(arts : mt.flash.PArray<Artefact>) {
		if (arts == null || arts.length == 0)
			return ;

		objects = {ids : new mt.flash.PArray() , probs : new mt.flash.PArray()} ;
		for (a in arts) {
			addArtefact(a) ;
		}
	}
	
	
	public function addArtefact(a : Artefact) {
		objects.ids.push(a.id) ;
		objects.probs.push(a.freq) ;
	}
	
	
	public function isEndChain(e : Element) : Bool {
		if (!Game.me.stage.hasEffect(FxDelorean))
			return e.index == chain.length - 1 ;
		else 
			return e.index == 0 ;
	}
	
	
	public function transformInfos(g : Array<Element>) : Array<{t : TransformInfos, g : Array<Element>}> {
		var t = getTransformed(g) ;
	

		var n : Int = 
			if (!Game.me.stage.hasEffect(FxDelorean))
				g[0].index + 1 ;
			else 
				g[0].index - 1 ;
		checkLevel(n) ;
		
		var rt : TransformInfos = {x : t.x, y : t.y, e : cast t, nextElt : null, nextArt : null} ;
		rt.nextElt = n ;
		return [{t : rt, g : g}] ;
		
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
	
	
	public function checkLevel(n : mt.flash.Volatile<Int>) {
		if (n  /*>*/  >= level && n < chain.length - 1) {
			level++ ;
			
			if (level - 1 < Game.me.mcChain.length)
				Col.setPercentColor(Game.me.mcChain[level - 1].mc, 0, Const.HIDE_CHAIN_COL) ;
			
			return true ;
		}
		return false ;
	}
	
	
	public function getNext() : ArtefactId {
		var i = Const.randomProbs(objects.probs) ;
		return objects.ids[i] ;
	}
	
	
	public function getRandomElement(?parasit : Bool = false, ?c = 0) : Int {
		 if (!parasit)
			return Const.randomProbs(chWeight.slice(0, level)) ;
		else {
			c++ ;
			return Const.randomProbs([Std.int(chWeight[0] / (c * c))].concat(chWeight.slice(0, level))) - 1 ;
		}

	}
	
	
}
