package manager ;

import Common;

import data.Settings;

/**
 * ...
 * @author Tipyx
 */
class GoalManager
{
	var game						: process.Game;
	
	var levelInfo					: LevelInfo;
	
	public var arRockRecovered		: Array<{tr:TypeRock, num:Int}>;
	
	public function new(levelInfo:LevelInfo) {
		this.levelInfo = levelInfo;
		
		game = process.Game.ME;
	}
	
	public function init() {
		arRockRecovered = [];
	}
	
	public function checkEnd():Bool {
		//trace(arRock);
		 
		switch (levelInfo.type) {
			case TypeGoal.TGScoring(v)	:
				return game.score.get() >= v;
			case TypeGoal.TGCollect(ar)	:
				var b = true;
				var c = 0;
				for (r in ar) {
					for (rock in arRockRecovered)
						if (r.tr.equals(rock.tr) && rock.num >= r.num)
							c++;
				}
				
				return c == ar.length;
			case TypeGoal.TGGelatin :
				return game.arGelatin.length == 0;
			case TypeGoal.TGMercury(num, ar) :
				return game.arMerc.length >= num;
		}
	}
	
	public function updateRockEliminated(r:Rock) {
	// ROCK
		game.uiTop.updateGoal(r);
		var b = true;
		for (rock in arRockRecovered) {
			if (r.type.equals(rock.tr)) {
				b = false;
				rock.num++;
			}
		}
		
		if (b)
			arRockRecovered.push( { tr:r.type, num:1 } );
	}
	
	public function updateUnder(cX:Int, cY:Int) {
	// GELATIN
		if (game.arGelatin != null) {
			for (g in game.arGelatin.copy()) {
				if (g.cX == cX && g.cY == cY) {
					g.hbeUnder.dispose();
					g.hbeUnder = null; 
					game.arGelatin.remove(g);
					FX.DESTROY_GELAT(g.cX, g.cY);
					game.uiTop.updateGoal();
				}
			}
		}
	}
	
	public function updateMercury(pack:Array<Rock>) {
		if (game.arMerc != null) {
			var b = false;
			for (r in pack)
				for (m in game.arMerc)
					if (r.cX == m.cX && r.cY == m.cY)
						b = true;
			
			if (b) {
				var ar = [];
				for (r in pack) {
					if (!SpecialManager.IS_ON_MERCURY(r.cX, r.cY))
						ar.push(r);
				}
				
				for (r in ar)
					SpecialManager.CREATE_MERCURY(r.cX, r.cY);
			}
			
			game.uiTop.updateGoal();			
		}
	}
	
	public function updateMercuryBomb(rbomb:Rock, arRock:Array<Rock>, tb:TypeBonus) {
		function isBlocker(cX, cY):Bool {	// LAVA, BUBBLE, ICE, HOLE, BLOCK
			var r = Rock.GET_AT(cX, cY);
			if (r == null)
				return false;
			else {
				
				return !r.isRotable || r.isBubble || r.freezeCounter > 0;
			}
		}
		
		function doHor() {
			var merc = false;
			var i = rbomb.cX;
			while (i >= 0) {
				if (isBlocker(i, rbomb.cY))
					merc = false;
				else if (SpecialManager.IS_ON_MERCURY(i, rbomb.cY))
					merc = true;
					
				if (merc)
					SpecialManager.CREATE_MERCURY(i, rbomb.cY);
					
				i--;
			}
			
			merc = false;
			for (i in rbomb.cX...Settings.GRID_WIDTH) {
				if (isBlocker(i, rbomb.cY))
					merc = false;
				else if (SpecialManager.IS_ON_MERCURY(i, rbomb.cY))
					merc = true;
					
				if (merc)
					SpecialManager.CREATE_MERCURY(i, rbomb.cY);
			}
		}
		
		function doVer() {
			var merc = false;
			var i = rbomb.cY;
			while (i >= 0) {
				if (isBlocker(rbomb.cX, i))
					merc = false;
				else if (SpecialManager.IS_ON_MERCURY(rbomb.cX, i))
					merc = true;
				
				if (merc)
					SpecialManager.CREATE_MERCURY(rbomb.cX, i);
					
				i--;
			}
			
			merc = false;
			for (i in rbomb.cY...Settings.GRID_HEIGHT) {
				if (isBlocker(rbomb.cX, i))
					merc = false;
				else if (SpecialManager.IS_ON_MERCURY(rbomb.cX, i))
					merc = true;
				
				if (merc)
					SpecialManager.CREATE_MERCURY(rbomb.cX, i);
			}
		}
		
		switch (tb) {
			case TypeBonus.TBColor :
				if (SpecialManager.IS_ON_MERCURY(rbomb.cX, rbomb.cY))
					for (r in arRock)
						SpecialManager.CREATE_MERCURY(r.cX, r.cY);
			case TypeBonus.TBBombMini :
				if (SpecialManager.IS_ON_MERCURY(rbomb.cX, rbomb.cY)) {
					if (rbomb.cX - 1 >= 0 && !isBlocker(rbomb.cX - 1, rbomb.cY))
						SpecialManager.CREATE_MERCURY(rbomb.cX - 1, rbomb.cY);
					if (rbomb.cX + 1 < Settings.GRID_WIDTH && !isBlocker(rbomb.cX + 1, rbomb.cY))
						SpecialManager.CREATE_MERCURY(rbomb.cX + 1, rbomb.cY);
					if (rbomb.cY - 1 >= 0 && !isBlocker(rbomb.cX, rbomb.cY - 1))
						SpecialManager.CREATE_MERCURY(rbomb.cX, rbomb.cY - 1);
					if (rbomb.cY + 1 < Settings.GRID_HEIGHT && !isBlocker(rbomb.cX, rbomb.cY + 1))
						SpecialManager.CREATE_MERCURY(rbomb.cX, rbomb.cY + 1);
				}
			case TypeBonus.TBBombHor :
				doHor();
				
			case TypeBonus.TBBombVert :
				doVer();
				
			case TypeBonus.TBBombPlus :
				doHor();
				doVer();
			case TypeBonus.TBBombCross :
				var merc = false;
				for (i in 0...Settings.GRID_HEIGHT) {
					if (rbomb.cX - i >= 0 && rbomb.cY - i >= 0) {
						if (isBlocker(rbomb.cX - i, rbomb.cY - i))
							merc = false;
						else if (SpecialManager.IS_ON_MERCURY(rbomb.cX - i, rbomb.cY - i))
							merc = true;
						
						if (merc)
							SpecialManager.CREATE_MERCURY(rbomb.cX - i, rbomb.cY - i);
					}
				}
				
				merc = false;
				for (i in 0...Settings.GRID_HEIGHT) {
					if (rbomb.cX - i >= 0 && rbomb.cY + i < Settings.GRID_HEIGHT) {
						if (isBlocker(rbomb.cX - i, rbomb.cY + i))
							merc = false;
						else if (SpecialManager.IS_ON_MERCURY(rbomb.cX - i, rbomb.cY + i))
							merc = true;
						
						if (merc)
							SpecialManager.CREATE_MERCURY(rbomb.cX - i, rbomb.cY + i);
					}
				}
				
				merc = false;
				for (i in 0...Settings.GRID_HEIGHT) {
					if (rbomb.cX + i < Settings.GRID_WIDTH && rbomb.cY - i >= 0) {
						if (isBlocker(rbomb.cX + i, rbomb.cY - i))
							merc = false;
						else if (SpecialManager.IS_ON_MERCURY(rbomb.cX + i, rbomb.cY - i))
							merc = true;
						
						if (merc)
							SpecialManager.CREATE_MERCURY(rbomb.cX + i, rbomb.cY - i);
					}
				}
				
				merc = false;
				for (i in 0...Settings.GRID_HEIGHT) {
					if (rbomb.cX + i < Settings.GRID_WIDTH && rbomb.cY + i < Settings.GRID_HEIGHT) {
						if (isBlocker(rbomb.cX + i, rbomb.cY + i))
							merc = false;
						else if (SpecialManager.IS_ON_MERCURY(rbomb.cX + i, rbomb.cY + i))
							merc = true;
						
						if (merc)
							SpecialManager.CREATE_MERCURY(rbomb.cX + i, rbomb.cY + i);
					}
				}
		}
	}
}