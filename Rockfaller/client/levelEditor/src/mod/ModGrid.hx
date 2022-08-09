package mod;

import Common;
import mt.deepnight.slb.HSprite;

import elem.*;

/**
 * ...
 * @author Tipyx
 */
class ModGrid extends mt.deepnight.HProcess
{
	var wallLeft				: HSprite;
	var wallRight				: HSprite;
	
	public var modGeyser		: ModGeyser;
	
	public static var arSquare	: Array<Square>;

	public function new(le:LE) {
		super(/*le*/);
	
		arSquare = [];
		
		for (i in 0...Settings.GRID_WIDTH) {
			for (j in 0...Settings.GRID_HEIGHT) {
				var sq = new Square(i, j);
				sq.x = Std.int(i * (Settings.SIZE + 1));
				sq.y = Std.int(j * (Settings.SIZE + 1));
				//arSquare.push(sq);
				arSquare[i + j * Settings.GRID_WIDTH] = sq;
				root.addChild(sq);
			}
		}
		
		wallLeft = Settings.SLB_UNIVERS1.h_get("wall_classic");
		wallLeft.scaleX = wallLeft.scaleY = 0.5;
		wallLeft.setCenterRatio(1, 0);
		wallLeft.x = Std.int(-Settings.SIZE + 15);
		root.addChild(wallLeft);
		
		wallRight = Settings.SLB_UNIVERS1.h_get("wall_classic");
		wallRight.scaleX = wallRight.scaleY = 0.5;
		wallRight.setCenterRatio(1, 0);
		wallRight.scaleX = -wallRight.scaleX;
		wallRight.x = Std.int(Settings.GRID_WIDTH * Settings.SIZE - 15);
		root.addChild(wallRight);
		
		modGeyser = new ModGeyser();
		modGeyser.visible = false;
		root.addChild(modGeyser);
	}
	
	public function reset() {
		for (sq in arSquare) {
			sq.reset();
		}
	}
	
	public function load(actualLevel:LevelInfo) {
	// ManualRock
		for (mr in actualLevel.arManualRocks) {
			getAt(mr.x, mr.y).load(mr.tr);
		}
		
	// Pattern
		for (e in LE.ME.modPattern.arPattern) {
			getAt(e.cX, e.cY).loadPattern();
		}
		
		changeBiome();
		
		modGeyser.init();
	}
	
	public function changeBiome() {
		switch (LE.ME.actualLevel.biome) {
			case TypeBiome.TBClassic :
				wallLeft.set(Settings.SLB_UNIVERS1, "wall_classic");
				wallRight.set(Settings.SLB_UNIVERS1, "wall_classic");
			case TypeBiome.TBFreeze :
				wallLeft.set(Settings.SLB_UNIVERS1, "wall_ice");
				wallRight.set(Settings.SLB_UNIVERS1, "wall_ice");
			case TypeBiome.TBMagma :
				wallLeft.set(Settings.SLB_UNIVERS1, "wall_magma");
				wallRight.set(Settings.SLB_UNIVERS1, "wall_magma");
			case TypeBiome.TBWater :
				wallLeft.set(Settings.SLB_UNIVERS2, "wall_water");
				wallRight.set(Settings.SLB_UNIVERS2, "wall_water");
			case TypeBiome.TBCiv :
				wallLeft.set(Settings.SLB_UNIVERS2, "wall_civ");
				wallRight.set(Settings.SLB_UNIVERS2, "wall_civ");
			case TypeBiome.TBCentEarth :
				wallLeft.set(Settings.SLB_UNIVERS2, "wall_core");
				wallRight.set(Settings.SLB_UNIVERS2, "wall_core");
			case TypeBiome.TBNightmare :
				wallLeft.set(Settings.SLB_UNIVERS3, "wall_nightmare");
				wallRight.set(Settings.SLB_UNIVERS3, "wall_nightmare");
			case TypeBiome.TBLimbo :
				wallLeft.set(Settings.SLB_UNIVERS3, "wall_tree");
				wallRight.set(Settings.SLB_UNIVERS3, "wall_tree");
		}
	}
	
	public function setGelatine(set:Bool) {
		if (set) {
			switch (LE.ME.actualLevel.type) {
				case TypeGoal.TGGelatin(ar) :
					for (g in ar) {
						getAt(g.cX, g.cY).setHS("mudBack", true);
					}
				case TypeGoal.TGCollect, TypeGoal.TGScoring, TypeGoal.TGMercury :
			}
		}
		else {
			for (s in arSquare) {
				if (s.hsGela != null)
					s.hsGela.dispose();
				s.hsGela = null;
			}
		}
	}
	
	public function setMercure(set:Bool) {
		if (set) {
			trace(LE.ME.actualLevel.type);
			switch (LE.ME.actualLevel.type) {
				case TypeGoal.TGMercury(num, ar) :
					trace(num + " " + ar.length);
					for (g in ar) {
						getAt(g.cX, g.cY).setHS("mercury", true);
					}
				case TypeGoal.TGCollect, TypeGoal.TGScoring, TypeGoal.TGGelatin :
			}
		}
		else {
			for (s in arSquare) {
				if (s.hsMerc != null)
					s.hsMerc.dispose();
				s.hsMerc = null;
			}
		}
	}
	
	public function getAt(cX:Int, cY:Int):Square {
		var sq = arSquare[cX + cY * Settings.GRID_WIDTH];
		
		if (sq == null)
			throw "no square in " + cX + " : " + cY;
		else
			return sq;
	}
	
	public function showWall() {
		wallLeft.alpha = 1;
		wallRight.alpha = 1;
		
		modGeyser.visible = false;
	}
	
	public function hideWall() {
		wallLeft.alpha = 0.25;
		wallRight.alpha = 0.25;
		
		modGeyser.visible = true;
	}
}

class ModGeyser extends h2d.Sprite {
	public var arGeyser	: Array<{y:Int, isLeft:Bool, isEnable:Bool, hs:HSprite}>;
	
	public function new() {
		super();
		
		arGeyser = [];
		
		for (i in 0...Settings.GRID_HEIGHT) {
			createGeyser(i, true);
			createGeyser(i, false);
		}
	}
	
	public function init() {
		for (ge in arGeyser) {
			ge.isEnable = false;
			ge.hs.alpha = 0.25;
		}
		
		for (gp in LE.ME.actualLevel.arGP.copy())
			switch (gp) {
				case TypeGP.TGGeyser(ar) :
					for (g in ar) {
						for (ge in arGeyser) {
							if (ge.y == g.y && ge.isLeft == g.isLeft) {
								ge.isEnable = true;
								ge.hs.alpha = 1;
							}
						}
					}
					return;
				default :
			}
	}
	
	public function setGP() {
		var ar:Array<{y:Int, isLeft:Bool}> = [];
		
		for (g in arGeyser) {
			if (g.isEnable)
				ar.push( { y:g.y, isLeft:g.isLeft } );
		}
		
		var b = null;
		
		for (gp in LE.ME.actualLevel.arGP.copy()) {
			if (gp.match(TypeGP.TGGeyser))
				LE.ME.actualLevel.arGP.remove(gp);
		}
		
		if (ar.length > 0)
			LE.ME.actualLevel.arGP.push(TypeGP.TGGeyser(ar));
	}
	
	function createGeyser(i:Int, isLeft:Bool) {
		var geyser = {y:i, isLeft:isLeft, isEnable:false, hs:null};
		arGeyser.push(geyser);
		
		var hs = Settings.SLB_FX2.h_get("fxWaterCore", 6);
		hs.x = - Settings.SIZE;
		hs.y = (Settings.SIZE + 1) * i;
		hs.setCenterRatio(0.5, 0.5);
		hs.scaleX = hs.scaleY = 0.4;
		hs.alpha = geyser.isEnable ? 1 : 0.25;
		geyser.hs = hs;
		this.addChild(hs);
		
		var inter = new h2d.Interactive(Settings.SIZE, Settings.SIZE);
		inter.y = (Settings.SIZE + 1) * i;
		//inter.backgroundColor = 0x88800000;
		inter.onClick = function (e) {
			geyser.isEnable = !geyser.isEnable;
			hs.alpha = geyser.isEnable ? 1 : 0.25;
			
			if (geyser.isEnable) {
				for (g in arGeyser) {
					if (g.y == geyser.y && g.isLeft == !geyser.isLeft) {
						g.isEnable = false;
						g.hs.alpha = 0.25;
					}
				}
			}
		}
		this.addChild(inter);
		
		if (isLeft)
			inter.x = hs.x = - Settings.SIZE;
		else {
			hs.scaleX = -hs.scaleX;
			inter.x = hs.x = (Settings.SIZE + 1) * (Settings.GRID_WIDTH);
		}
			
		inter.setPos(inter.x - Std.int(Settings.SIZE * 0.5), inter.y - Std.int(Settings.SIZE * 0.5));
	}
}