package manager;

import Common;
import data.Settings;
import process.Game;

/**
 * ...
 * @author ...
 */

typedef ElToRegen = {
	var r			: {tr:TypeRock, x:Int, y:Int};
	var group		: Array<{tr:TypeRock, x:Int, y:Int}>;
	var freezeC		: Int;
	var isRotable	: Bool;
	var trClassic	: { isClassic:Bool, id:String };
} 

class RegenManager
{
	public var arElement		: Array<ElToRegen>	= [];
	var arElementCheck			: Array<ElToRegen>	= [];
	
	var arBackUpDeck			: Array<TypeRock>	= [];
	var arDeck					: Array<TypeRock>	= [];
	
	var arManualRocks			: Array<{tr:TypeRock, x:Int, y:Int}>;
	
	public var isOneMovePossible: Bool;

	public function new(arManualRocks:Array<{tr:TypeRock, x:Int, y:Int}>, ?firstInit:Bool = false, ?specialEffect:Bool = true) {
		this.arManualRocks = arManualRocks;
		
		arBackUpDeck = SpecialManager.POPRATE_ELEMENT.copy();
		
		isOneMovePossible = true;
		
		SpecialManager.AR_NEW_REGEN = [];
		
		for (r in Rock.ALL) {
			if (r != null) {
				arManualRocks.push( { tr:r.type, x:r.cX, y:r.cY } );
			}
		}
		
		var counterTry = 0;
		
		do {
			arElement = [];
			arElement[Settings.GRID_WIDTH * Settings.GRID_HEIGHT] = null;
			SpecialManager.AR_NEW_REGEN = [];
			SpecialManager.POPRATE_ELEMENT = arBackUpDeck.copy();
			arDeck = SpecialManager.POPRATE_ELEMENT.copy();
			
			for (m in arManualRocks) {
				switch (m.tr) {
					case TypeRock.TRFreeze, TypeRock.TRBubble :
					default :
						var mr = { r:m, group:[m], freezeC:0, isRotable:Rock.IS_ROTABLE(m.x, m.y, m.tr), trClassic:{isClassic:false, id:""}};
						arElement[m.x + m.y * Settings.GRID_WIDTH] = mr;
				}
			}
			
			var y = 0;
			var e = null;
			var tr = null;
			var r = null;
			
			for (i in 0...Settings.GRID_HEIGHT) {
				y = Settings.GRID_HEIGHT - 1 - i;
				for (x in 0...Settings.GRID_WIDTH) {
					e = getAt(x, y);
					if (e != null) {
						tr = e.r.tr;
						r = { tr:tr, x:x, y:y };
						e = { r:r, group:[r], freezeC:0, isRotable:Rock.IS_ROTABLE(x, y, tr), trClassic:{isClassic:false, id:""} };
						tr = e.r.tr;
						set(e, getAt(x - 1, y), tr);
						set(e, getAt(x + 1, y), tr);
						set(e, getAt(x, y - 1), tr);
						set(e, getAt(x, y + 1), tr);
						arElement[x + y * Settings.GRID_WIDTH] = e;
						
						switch (tr) {
							case TypeRock.TRClassic(id) :
								e.trClassic = { isClassic:true, id:id };
							default :
								e.trClassic = { isClassic:false, id:"" };
						}
					}
				}
			}
			
			y = 0;
			e = null;
			tr = null;
			r = null;
			var freezeC:Int = 0;
			var arId = [];
			
			for (i in 0...Settings.GRID_HEIGHT) {
				y = Settings.GRID_HEIGHT - 1 - i;
				for (x in 0...Settings.GRID_WIDTH) {
					e = getAt(x, y);
					tr = null;
					freezeC = 0;
					arId = [];
					for (id in Rock.GET_AVAILABLE_CLASSIC()) {
						arId.push( { id:id, n:0 } );
					}
					if (e == null) {
						check(getAt(x - 1, y), arId);
						check(getAt(x + 1, y), arId);
						check(getAt(x, y - 1), arId);
						check(getAt(x, y + 1), arId);
						if (!firstInit && !Game.ME.goalManager.checkEnd()) {
							var i = 0;
							var numTry = 0;
							while (tr == null) {
								i = getRandomTR();
								tr = arDeck[i];
								switch(tr) {
									case TypeRock.TRFreeze(v) :
										if (specialEffect && freezeC == 0) {
											freezeC = v;
											
											arDeck.splice(i, 1);
											
											checkShuffleDeck();
										}
										tr = null;
									case TypeRock.TRClassic(id) :
										var b = false;
										for (idC in arId) {
											if (id == idC.id)
												b = true;
										}
										
										if (!b)
											tr = null;
									default :
								}
								
								numTry++;
								if (numTry >= Settings.GRID_WIDTH * Settings.GRID_HEIGHT * 10) {
									SpecialManager.SHUFFLE_DECK();
									arDeck = SpecialManager.POPRATE_ELEMENT.copy();
								}
							}
							
							arDeck.splice(i, 1);
							
							checkShuffleDeck();
						}
						else
							tr = TypeRock.TRClassic(arId[Game.ME.rndS.irange(0, arId.length - 1)].id);
						r = { tr:tr, x:x, y:y };
						e = { r:r, group:[r], freezeC:freezeC, isRotable:Rock.IS_ROTABLE(x, y, tr), trClassic:{isClassic:false, id:""} };
						tr = e.r.tr;
						set(e, getAt(x - 1, y), tr);
						set(e, getAt(x + 1, y), tr);
						set(e, getAt(x, y - 1), tr);
						set(e, getAt(x, y + 1), tr);
						arElement[x + y * Settings.GRID_WIDTH] = e;
					}
					
					switch (e.r.tr) {
						case TypeRock.TRClassic(id) :
							e.trClassic = { isClassic:true, id:id };
						default :
							e.trClassic = { isClassic:false, id:"" };
					}
				}
			}
			
			counterTry++;
		} while (counterTry < 5 && !checkPossible());
		
		trace("trololo : counterTry : " + counterTry);
		
		SpecialManager.POPRATE_ELEMENT = arDeck.copy();
	}
	
	function checkPossible():Bool {
		if (Game.ME.levelInfo.level >= 10)
			return true;
		
		var actualCheck = { x:0, y:0 };
		
		var isPossible = false;
		
		var cX = actualCheck.x;
		var cY = actualCheck.y;
		
		var arSpin = [];
		var arRockVerified = [];
			
		var returnAsked = false;
		
		do {
			cX = actualCheck.x;
			cY = actualCheck.y;
			
			arElementCheck = arElement.copy();
			
			arSpin = [getAt(cX, cY), getAt(cX + 1, cY), getAt(cX, cY + 1), getAt(cX + 1, cY + 1)];
			
			arSpin[0].r.x += 1;
			arSpin[1].r.y += 1;
			arSpin[2].r.y -= 1;
			arSpin[3].r.x -= 1;
			
			arElementCheck[arSpin[0].r.x + arSpin[0].r.y * Settings.GRID_WIDTH] = arSpin[0];
			arElementCheck[arSpin[1].r.x + arSpin[1].r.y * Settings.GRID_WIDTH] = arSpin[1];
			arElementCheck[arSpin[2].r.x + arSpin[2].r.y * Settings.GRID_WIDTH] = arSpin[2];
			arElementCheck[arSpin[3].r.x + arSpin[3].r.y * Settings.GRID_WIDTH] = arSpin[3];
			
			function end() {
				arSpin[0].r.x -= 1;
				arSpin[1].r.y -= 1;
				arSpin[2].r.y += 1;
				arSpin[3].r.x += 1;
				
				actualCheck.x += 1;
				if (actualCheck.x >= Settings.GRID_WIDTH - 1) {
					actualCheck.x = 0;
					actualCheck.y += 1;
				}
			}
			
			returnAsked = false;
			
			for (r in arSpin)
				if (!Rock.IS_ROTABLE(r.r.x, r.r.y, r.r.tr) || r.freezeC > 0 || !r.trClassic.isClassic)
					returnAsked = true;
			
			if (!returnAsked) {
				arRockVerified = [];
				arRockVerified[Settings.GRID_HEIGHT * Settings.GRID_WIDTH] = null;
				
				for (r in arElement) {
					if (r != null) {
						if (arRockVerified[r.r.x + r.r.y * Settings.GRID_WIDTH] == null) {
							arRockVerified[r.r.x + r.r.y * Settings.GRID_WIDTH] = r;
							
							var pack = [r];
							
							for (rp in pack) {
								var rL = getAtTemp(rp.r.x - 1, rp.r.y);
								if (rL != null && arRockVerified[rL.r.x + rL.r.y * Settings.GRID_WIDTH] == null && isSameNeighboor(rp, rL)) {
									pack.push(rL);
									arRockVerified[rL.r.x + rL.r.y * Settings.GRID_WIDTH] = rL;
								}
								
								var rR = getAtTemp(rp.r.x + 1, rp.r.y);
								if (rR != null && arRockVerified[rR.r.x + rR.r.y * Settings.GRID_WIDTH] == null && isSameNeighboor(rp, rR)) {
									pack.push(rR);
									arRockVerified[rR.r.x + rR.r.y * Settings.GRID_WIDTH] = rR;
								}
								
								var rT = getAtTemp(rp.r.x, rp.r.y - 1);
								if (rT != null && arRockVerified[rT.r.x + rT.r.y * Settings.GRID_WIDTH] == null && isSameNeighboor(rp, rT)) {
									pack.push(rT);
									arRockVerified[rT.r.x + rT.r.y * Settings.GRID_WIDTH] = rT;
								}
								
								var rD = getAtTemp(rp.r.x, rp.r.y + 1);
								if (rD != null && arRockVerified[rD.r.x + rD.r.y * Settings.GRID_WIDTH] == null && isSameNeighboor(rp, rD)) {
									pack.push(rD);
									arRockVerified[rD.r.x + rD.r.y * Settings.GRID_WIDTH] = rD;
								}
								
								if (pack.length >= 4) {
									isOneMovePossible = true;
									return isOneMovePossible;
								}
							}
						}
					}
				}
			}
			
			end();
		} while (!isPossible && !(actualCheck.x == Settings.GRID_WIDTH - 2 && actualCheck.y == Settings.GRID_HEIGHT - 2));
		
		isOneMovePossible = false;
		return isPossible;
	}
		
	public function getAt(cX:Int, cY:Int) {
		return arElement[cX + cY * Settings.GRID_WIDTH];
	}
	
	function getAtTemp(cX:Int, cY:Int):ElToRegen {
		return arElementCheck[cX + cY * Settings.GRID_WIDTH];
	}
	
	function check(r:ElToRegen, ar:Array<{id:String, n:Int}>) {
		if (r != null && r.trClassic.isClassic) {
			for (e in ar)
				if (r.trClassic.id == e.id) {
					e.n += r.group.length;
					if (e.n >= 3)
						ar.remove(e);
					return;
				}
		}
	}
	
	function set(e:ElToRegen, r:ElToRegen, tr:TypeRock) {
		if (r != null && r.group != e.group && r.r.tr.equals(tr)) {
			for (el in r.group) {
				e.group.push(el);
				getAt(el.x, el.y).group = e.group;
			}
		}
	}
		
	function getRandomTR():Int {
		var tr = null;
		var i = 0;
		while (tr == null) {
			i = Game.ME.rndS.random(arDeck.length);
			tr = arDeck[i];
			switch (tr) {
				case TypeRock.TRBlock, TypeRock.TRBonus, 
						TypeRock.TRMagma, TypeRock.TRBubble,
						TypeRock.TRBlockBreakable, TypeRock.TRHole,
						TypeRock.TRCog :
					throw "No " + tr + " can pop";
				case TypeRock.TRLoot :
					if (SpecialManager.LOOT_SPAWNED >= Settings.MAX_LOOT_BY_GRID)
						tr = null;
					else
						SpecialManager.LOOT_SPAWNED++;
				case TypeRock.TRClassic, TypeRock.TRFreeze, TypeRock.TRBombCiv :
			}
		}
		return i;
	}
	
	function stillClassicInDeck():Bool {
		for (e in arDeck)
			if (e.match(TypeRock.TRClassic))
				return true;
		
		return false;
	}
	
	function checkShuffleDeck() {
		if (arDeck.length == 0 || !stillClassicInDeck()) {
			SpecialManager.SHUFFLE_DECK();
			arDeck = SpecialManager.POPRATE_ELEMENT.copy();
		}
	}
	
	function isSameNeighboor(e1:ElToRegen, e2:ElToRegen):Bool {
		if (e1 == null || e2 == null
		||	e1.freezeC > 0 || e2.freezeC > 0
		||	!e1.isRotable
		||	!e2.isRotable)
			return false;
		
		if (e1.trClassic.isClassic
		//&&	isNeighboor(e1.r.x, e1.r.y, e2.r.x, e2.r.y))
		&&	e1.trClassic.id == e2.trClassic.id)
			return true;
		else
			return false;
	}
	
	inline function isNeighboor(x1:Int, y1:Int, x2:Int, y2:Int):Bool {
		return (x1 == x2	&& y1 == y2 + 1)
		||	(x1 == x2		&& y1 == y2 - 1)
		||	(x1 == x2 + 1	&& y1 == y2)
		||	(x1 == x2 - 1	&& y1 == y2);
	}
	
	public function destroy() {
		arElement = null;
		arElementCheck = null;
		arBackUpDeck = null;
		arDeck = null;
		arManualRocks = null;
	}
}