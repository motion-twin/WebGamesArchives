package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import GameData._ArtefactId ;

typedef EmptyCombo = {
	var from : Array<_ArtefactId> ;
	var to : _ArtefactId ;
}


class Empty extends Element {
	
	static public var parsingWays = [[0, 1, 2, 3], [0, 1, 3, 2], [0, 2, 1, 3], [0, 2, 3, 1],
								[1, 0, 2, 3], [1, 0, 3, 2], [1, 2, 0, 3], [1, 2, 3, 0],
								[2, 1, 0, 3], [2, 1, 3, 0], [2, 0, 1, 3], [2, 0, 3, 1],
								[3, 1, 2, 0], [3, 1, 0, 2], [3, 2, 1, 0], [3, 2, 0, 1]] ;
	
	
	static public var combos = [{from : [_Elt(1), _Elt(1), _Elt(12)], to : _QuestObj("geminishregular")},
						{from : [_Elt(6), _Elt(6), _Elt(13)], to : _QuestObj("milk")},
						{from : [_Elt(4), _Elt(4), _Elt(7)], to : _QuestObj("menthol")},
						{from : [_Elt(0), _Elt(1), _Elt(2)], to : _CountBlock(4)}
					] ;
	
	public var curCombos : Array<EmptyCombo> ;
	public var curSearch : Array<StageObject> ;
	public var curCheck : Int ;	
	public var toTransformTo : _ArtefactId ;
	
	public function new(?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super(-1, dm, depth) ;
		id = Const.getArt(_Empty) ;
		checkHelp() ;
		autoFall = false ;
		isParasit = false ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		if (noOmc)
			return ;
		omc = new ObjectMc(_Empty, pdm,depth, null, null, null, withBmp, sc) ;
	}
	
	
	override public function copy(dm : mt.DepthManager, ?depth : Int) : StageObject {
		depth = if (depth == null) 2 else depth ;
		var e : Empty = null ;
		e = new Empty(dm, depth, false, omc.getBmp(), omc.initScale) ;
		e.isFalling = isFalling ;
		return e ;
	}
	
	
	
	public function initParse() {
		curSearch = new Array() ;
		curCombos = new Array() ;
		for (c in combos) {
			curCombos.push({from : c.from.copy(), to : c.to}) ; 
		}
		curCheck = -1 ;
	}
	
	public function nextTest() : Bool {
		curCheck++ ;
		toTransformTo = null ;
		if (curCheck >= combos.length) {
			curSearch = null ;
			curCombos = null ;
			curCheck = null ;
			return false ;
		}
		
		curSearch = new Array() ;
		return true ;
	}
	
	public function nextWay() {
		curSearch = new Array() ;
		curCombos[curCheck].from = combos[curCheck].from.copy() ; 
	}
	
	
	public function check(o : StageObject) : Int { //-1 if nothing found, 0 if possible future match, 1 if match
		for (c in curCombos[curCheck].from.copy()) {
			if (Type.enumEq(o.getArtId(), c)) {
				curCombos[curCheck].from.remove(c) ;
				curSearch.push(o) ;
				if (curCombos[curCheck].from.length > 0)
					return 0 ;
				else {
					toTransformTo = curCombos[curCheck].to ;
					return 1 ;
				}
			}
		}
		
		return -1 ;
	}
	
	
	
	
}