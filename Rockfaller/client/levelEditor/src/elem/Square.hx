package elem ;

import h2d.Layers;
import mt.deepnight.slb.HSprite;

import mod.ModAssets;

import Common;

import LE;

/**
 * ...
 * @author Tipyx
 */
class Square extends Layers
{
	var le					: LE;
	
	public var cX			: Int;
	public var cY			: Int;
	
	var tr					: TypeRock;
	
	var inter				: h2d.Interactive;
	public var hsMainBE		: HSprite;
	public var hsGela		: HSprite;
	public var hsMerc		: HSprite;
	public var hsFreeze		: HSprite;
	public var hsPattern	: HSprite;
	
	public function new(cX:Int, cY:Int) {
		super();
		
		le = LE.ME;
		
		this.cX = cX;
		this.cY = cY;
		
		inter = new h2d.Interactive(Settings.SIZE, Settings.SIZE);
		inter.propagateEvents = true;
		inter.setPos(-Std.int(Settings.SIZE * 0.5), -Std.int(Settings.SIZE * 0.5));
		inter.backgroundColor = 0xFF800000;
		inter.alpha = 0.25;
		inter.onOver = function onOverSquare(e) {
			if (LE.ME.mouseLeftDown)
				setHS();
		}
		inter.onPush = function onPushSquare(e) {
			setHS();
		}
		this.addChild(inter);
	}
	
	public function load(tr:TypeRock) {
		setHS(Common.GET_HSID_FROM_TYPEROCK(tr, le.actualLevel.biome));
	}
	
	public function setHS(?id:String, ?f:Int = 0, ?set:Bool = false) {
		var save = false;
		if (id == null) {
			save = true;
			
			if (le.modPattern.activeZone != null && Main.ME.input.p) {
				setPattern();
				return;
			}
			else {
				id = ModAssets.ME.activeAsset.id;
				f = ModAssets.ME.activeAsset.f;				
			}
		}
		
		switch (id) {
			case "mudBack" :
				if (le.paintingMode == PaintingMode.PMNone) {
					if (set || hsGela == null || hsGela.groupName != id)
						le.paintingMode = PaintingMode.PMAdd;
					else
						le.paintingMode = PaintingMode.PMRemove;
				}
				
				if (le.paintingMode == PaintingMode.PMAdd) {
					if (hsGela == null) {
						hsGela = Settings.SLB_GRID.h_get(id, f);
						hsGela.filter = true;
						hsGela.scaleX = hsGela.scaleY = 0.5;
						hsGela.setCenterRatio(0.5, 0.5);
						this.add(hsGela, 0);
					}
					else
						hsGela.set(id);
				}
				else if (le.paintingMode == PaintingMode.PMRemove && hsGela != null) {
					hsGela.dispose();
					hsGela = null;
				}
			case "mercury" :
				if (le.paintingMode == PaintingMode.PMNone) {
					if (set || hsMerc == null || hsMerc.groupName != id)
						le.paintingMode = PaintingMode.PMAdd;
					else
						le.paintingMode = PaintingMode.PMRemove;
				}
				
				if (le.paintingMode == PaintingMode.PMAdd) {
					if (hsMerc == null) {
						hsMerc = Settings.SLB_GRID.h_get(id, f);
						hsMerc.filter = true;
						hsMerc.scaleX = hsMerc.scaleY = 0.5;
						hsMerc.setCenterRatio(0.5, 0.5);
						this.add(hsMerc, 0);
					}
					else
						hsMerc.set(id);
				}
				else if (le.paintingMode == PaintingMode.PMRemove && hsMerc != null) {
					hsMerc.dispose();
					hsMerc = null;
				}
			case "iceFront" :
				if (le.paintingMode == PaintingMode.PMNone) {
					if (hsFreeze == null || hsFreeze.groupName != id)
						le.paintingMode = PaintingMode.PMAdd;
					else
						le.paintingMode = PaintingMode.PMRemove;
				}
				//trace(hsFreeze);
				if (le.paintingMode == PaintingMode.PMAdd) {
					if (save)
						tr = ModAssets.ME.activeAsset.tr;
						
					if (hsFreeze == null) {
						hsFreeze = Settings.SLB_GRID.h_get(id, f);
						hsFreeze.filter = true;
						hsFreeze.scaleX = hsFreeze.scaleY = 0.5;
						hsFreeze.setCenterRatio(0.5, 0.5);
						this.add(hsFreeze, 2);
					}
					else
						hsFreeze.set(id);
				}
				else if (le.paintingMode == PaintingMode.PMRemove && hsFreeze != null) {
					if (save)
						tr = null;
						
					hsFreeze.dispose();
					hsFreeze = null;
				}
				
				//trace(hsFreeze + " " + le.paintingMode);
			default :
				if (le.paintingMode == PaintingMode.PMNone) {
					if (hsMainBE == null || hsMainBE.groupName != id) {
						le.paintingMode = PaintingMode.PMAdd;
					}
					else
						le.paintingMode = PaintingMode.PMRemove;
				}
				
				if (le.paintingMode == PaintingMode.PMAdd) {
					if (save)
						tr = ModAssets.ME.activeAsset.tr;
					
					if (hsMainBE == null) {
						hsMainBE = Settings.SLB_GRID.h_get(id, f);
						hsMainBE.filter = true;
						hsMainBE.scaleX = hsMainBE.scaleY = 0.5;
						hsMainBE.setCenterRatio(0.5, 0.5);
						this.add(hsMainBE, 1);
					}
					else
						hsMainBE.set(id);
				}
				else if (le.paintingMode == PaintingMode.PMRemove && hsMainBE != null) {
					if (save)
						tr = null;
					
					hsMainBE.dispose();
					hsMainBE = null;
					
				}
		}
		
		//trace(id + " " + f + " " + tr);
		
	// Update Level Info
		if (save) {
			var b = true;
			for (mr in le.actualLevel.arManualRocks.copy()) {
				if (mr.x == cX && mr.y == cY) {
					switch (le.paintingMode) {
						case PaintingMode.PMNone	:
						case PaintingMode.PMAdd		:
							mr.tr = tr;
						case PaintingMode.PMRemove	:
							LE.ME.actualLevel.arManualRocks.remove(mr);
					}
					
					b = false;
					break;
				}
			}
			
			switch (ModAssets.ME.activeAsset.ta) {
				case TypeAsset.TAGela :
					var ar:Array<{cX:Int, cY:Int}> = [];
					for (s in mod.ModGrid.arSquare) {
						if (s.hsGela != null)
							ar.push( { cX:s.cX, cY:s.cY } );
					}
					switch (le.actualLevel.type) {
						case TypeGoal.TGGelatin :
							le.actualLevel.type = TypeGoal.TGGelatin(ar);
						case TypeGoal.TGCollect, TypeGoal.TGScoring, TypeGoal.TGMercury :
					}
				case TypeAsset.TAMerc :
					var ar:Array<{cX:Int, cY:Int}> = [];
					for (s in mod.ModGrid.arSquare) {
						if (s.hsMerc != null)
							ar.push( { cX:s.cX, cY:s.cY } );
					}
					switch (le.actualLevel.type) {
						case TypeGoal.TGMercury(num, oldAr) :
							le.actualLevel.type = TypeGoal.TGMercury(num, ar);
						case TypeGoal.TGCollect, TypeGoal.TGScoring, TypeGoal.TGGelatin :
					}
				default :
					if (b && le.paintingMode == PaintingMode.PMAdd)
						le.actualLevel.arManualRocks.push( { tr:tr, x:cX, y:cY } );
			}
			
			le.updateUI();
		}
	}
	
	public function setPattern() {
		var activeZoneNum = le.modPattern.activeZone.z;
		var arPattern = le.modPattern.arPattern;
		
		var p = null;
		for (e in arPattern) {
			if (e.cX == cX && e.cY == cY)
				p = e;
		}
		
		if (le.paintingMode == PaintingMode.PMNone) {
			if (hsPattern == null || p.z != activeZoneNum)
				le.paintingMode = PaintingMode.PMAdd;
			else
				le.paintingMode = PaintingMode.PMRemove;
		}
		
		if (le.paintingMode == PaintingMode.PMAdd) {
			if (hsPattern == null) {
				hsPattern = Settings.SLB_GRID.h_get("patternEditor");
				hsPattern.filter = true;
				hsPattern.scaleX = hsPattern.scaleY = 0.5;
				hsPattern.setCenterRatio(0.5, 0.5);
				this.add(hsPattern, 3);
			}
				
			
			if (p != null) {
				p.z = activeZoneNum;
				hsPattern.alpha = p.z == activeZoneNum ? 1 : 0.5;
			}
			else
				arPattern.push( { cX:cX, cY:cY, z:activeZoneNum } );
		}
		else if (le.paintingMode == PaintingMode.PMRemove && hsPattern != null && p.z == activeZoneNum) {
			hsPattern.dispose();
			hsPattern = null;
			
			arPattern.remove(p);
		}
		
		for (gp in le.actualLevel.arGP.copy()) {
			if (gp.match(TypeGP.TGPattern))
				le.actualLevel.arGP.remove(gp);
		}
		le.actualLevel.arGP.push(TypeGP.TGPattern(le.modPattern.arPattern));
	}
	
	public function loadPattern() {
		var activeZoneNum = le.modPattern.activeZone.z;
		var arPattern = le.modPattern.arPattern;
		
		var p = null;
		for (e in arPattern) {
			if (e.cX == cX && e.cY == cY)
				p = e;
		}
		
		if (hsPattern == null) {
			hsPattern = Settings.SLB_GRID.h_get("patternEditor");
			hsPattern.filter = true;
			hsPattern.scaleX = hsPattern.scaleY = 0.5;
			hsPattern.setCenterRatio(0.5, 0.5);
			this.add(hsPattern, 3);
		}
		
		hsPattern.alpha = p.z == activeZoneNum ? 1 : 0.5;
	}
	
	public function reset() {
		if (hsMainBE != null) {
			hsMainBE.dispose();
			hsMainBE = null;
		}
		
		if (hsFreeze != null) {
			hsFreeze.dispose();
			hsFreeze = null;
		}
		
		if (hsGela != null) {
			hsGela.dispose();
			hsGela = null;			
		}
		
		if (hsMerc != null) {
			hsMerc.dispose();
			hsMerc = null;			
		}
		
		if (hsPattern != null) {
			hsPattern.dispose();
			hsPattern = null;			
		}
	}
}