package mod;

import mt.deepnight.HProcess;
import mt.deepnight.hui.Button;

import Common;

import elem.Square;

/**
 * ...
 * @author Tipyx
 */
class ModPattern extends h2d.Sprite
{
	var le							: LE;
	
	var hgroupZone					: mt.deepnight.hui.HGroup;
	var arZone						: Array<{btn:Button, z:Int}>;
	
	public var activeZone			: {btn:Button, z:Int};
	
	//public var patternAsset			: mod.ModAssets.Asset;
	
	public var arPattern			: Array<{cX:Int, cY:Int, z:Int}>;
	
	public function new() {
		super();
		
		le = LE.ME;
		
		arZone = [];
		
		var hgroup = new mt.deepnight.hui.HGroup(this);
		
		var btnCreate = hgroup.button("Create", 100, function () {
			if (arZone.length == 0)
				createZone();
			createZone();
		});
		
		var btnDelete = hgroup.button("Delete", 100, function () {
			deleteZone();
		});
		
		hgroup.x = Std.int((Settings.STAGE_WIDTH - hgroup.getWidth()) * 0.5);
		
		hgroupZone = new mt.deepnight.hui.HGroup(this);
		
		hgroupZone.y = Std.int(75);
		
		//patternAsset = new mod.ModAssets.Asset(null, null, null, "patternEditor");
		
		arPattern = [];
	}
	
	public function init(actualLevel:LevelInfo) {
		reset();
		
		for (gp in actualLevel.arGP) {
			switch (gp) {
				case TypeGP.TGPattern(ar) :
					arPattern = ar;
				default :
			}
		}
		
		var max = -1;
		for (e in arPattern)
			if (e.z > max)
				max = e.z;
		
		if (max >= 0) {
			for (i in 0...(max + 1)) {
				createZone();
			}			
		}
		
		for (e in arPattern)
			trace(e);
	}
	
	public function reset() {
		arPattern = [];
		
		for (zone in arZone)
			zone.btn.destroy();
			
		arZone = [];
		
		activeZone = null;
	}
	
	function createZone() {
		//if (arBtnZone.length < 4) {
			//var n = arBtnZone.length;
			//var btnZone = new ui.Button(Std.string(n), null);
			//btnZone.x = Std.int( -(Settings.STAGE_WIDTH - 400) + btnZone.w * arBtnZone.length);
			//btnZone.onClick = function() {
				//activateZone(n);
			//}
			////root.addChild(btnZone);
			//arBtnZone.push(btnZone);			
			//activateZone(n);
		//}
		
		if (arZone.length < 10) {
			var n = arZone.length;
			var btnZone = hgroupZone.button(Std.string(n), 50, function () {
				activateZone(n);
			});
			arZone.push({btn:btnZone, z:n});
			activateZone(n);			
		}
		
		hgroupZone.x = Std.int((Settings.STAGE_WIDTH - hgroupZone.getWidth()) * 0.5);
	}
	
	function deleteZone() {
		if (activeZone != null) {
			var grid = LE.ME.modGrid;
			for (e in arPattern.copy()) {
				if (e.z == activeZone.z) {
					var s = grid.getAt(e.cX, e.cY);
					if (s.hsPattern != null) {
						s.hsPattern.dispose();
						s.hsPattern = null;
					}
					
					arPattern.remove(e);
				}
			}
			
			for (e in arPattern) {
				if (e.z > activeZone.z)
					e.z--;
			}
			
			init(LE.ME.actualLevel);
		}
	}
	
	function activateZone(n:Int) {
		var grid = LE.ME.modGrid;
		for (zone in arZone) {
			if (zone.z == n) {
				activeZone = zone;
				zone.btn.bg.alpha = 1;
				
				for (e in arPattern) {
					var s = grid.getAt(e.cX, e.cY);
					if (s.hsPattern != null && e.z == zone.z) {
						s.hsPattern.alpha = 1;
					}
				}
			}
			else {
				if (activeZone != null && zone.z == activeZone.z)
					activeZone = null;
				zone.btn.bg.alpha = 0.5;
				
				for (e in arPattern) {
					var s = grid.getAt(e.cX, e.cY);
					if (s.hsPattern != null && e.z == zone.z) {
						s.hsPattern.alpha = 0.5;
					}
				}
			}
		}
	}
}