package mod;

import Common;

import h2d.Sprite;
import ui.Button;

/**
 * ...
 * @author Tipyx
 */

enum TypeAsset {
	TABasic;
	TABlock;
	TABombCiv;
	
	TAGela;
	TAMerc;
	
	TAFreeze;
	
	TAPattern;
	
	TAGeyser;
}

class ModAssets extends mt.deepnight.HProcess
{
	public static var ME	: ModAssets;
	
	public var height		: Int;
	
	var yAsset				: Int;
	
	var arAssets			: Array<Asset>;
	
	var btnGela				: ui.Button;
	var btnMerc				: ui.Button;
	
	public var arBtn		: Array<Button>;
	
	public var activeAsset	: Asset;

	public function new(le:LE) {
		super();
		
		ME = this;
		
		height = 150;
		
		arAssets = [];
		
		activeAsset = null;
		
	// BG
		var bg = new h2d.Bitmap(h2d.Tile.fromColor(0xFF681A1C, Settings.STAGE_WIDTH, height));
		root.addChild(bg);
		
	// BUTTON
		arBtn = [];
		
	// BASIC ASSETS
		for (e in Settings.AR_BASIC)
			addElement(TypeAsset.TABasic, TypeRock.TRClassic(e), e);
		
		//addElement(TypeAsset.TABasic, TypeRock.TRMagma, "lava");
		addElement(TypeAsset.TABasic, TypeRock.TRBubble, "bubble");
		
		addElement(TypeAsset.TABasic, TypeRock.TRBlockBreakable(3), "blocBreak", 0);
		addElement(TypeAsset.TABasic, TypeRock.TRBlockBreakable(2), "blocBreak", 1);
		addElement(TypeAsset.TABasic, TypeRock.TRBlockBreakable(1), "blocBreak", 2);
		
		addElement(TypeAsset.TABasic, TypeRock.TRBonus(TypeBonus.TBBombMini), "bombMini");
		addElement(TypeAsset.TABasic, TypeRock.TRBonus(TypeBonus.TBBombHor), "bombHoriz");
		addElement(TypeAsset.TABasic, TypeRock.TRBonus(TypeBonus.TBBombVert), "bombVert");
		addElement(TypeAsset.TABasic, TypeRock.TRBonus(TypeBonus.TBBombPlus), "bombPlus");
		addElement(TypeAsset.TABasic, TypeRock.TRBonus(TypeBonus.TBBombCross), "bombCross");
		addElement(TypeAsset.TABasic, TypeRock.TRBonus(TypeBonus.TBColor()), "bombColor");
		
		addElement(TypeAsset.TAGela, "mudBack");
		
		addElement(TypeAsset.TAMerc, "mercury");
		
		addElement(TypeAsset.TAFreeze, TypeRock.TRFreeze(2), "iceFront", 0);
		addElement(TypeAsset.TAFreeze, TypeRock.TRFreeze(1), "iceFront", 1);
		
		for (i in 0...Settings.SLB_GRID.getAnimDuration("hole")) {
			addElement(TypeAsset.TABlock, TypeRock.TRHole(i), "hole" + i);
		}
		
		for (i in 0...Settings.SLB_GRID.countFrames("bombeCiv")) {
			addElement(TypeAsset.TABombCiv, TypeRock.TRBombCiv(i), "bombeCiv", i);
		}
		
		arAssets[0].showHL();
		activeAsset = arAssets[0];
		
		showItem(TypeAsset.TABasic);
	}
	
	function addElement(ta:TypeAsset, ?tr:TypeRock, ?id:String, ?f:Int = 0) {
		var e = new Asset(ta, tr, this, id, f);
		e.y = yAsset;
		root.addChild(e);
		arAssets.push(e);
	}
	
	function addBtn(name:String, ta:TypeAsset):Button {
		var btn = new ui.Button(name, ta);
		btn.onClick = function () { showItem(ta); };
		root.addChild(btn);
		arBtn.push(btn);
		
		return btn;
	}
	
	public function showItem(ta:TypeAsset) {
		var i = 1;
		var j = 0;
		
		var b = true;
		
		LE.ME.modGrid.showWall();
		
		for (a in arAssets) {
			if (a.ta == ta) {
				a.visible = true;
				a.x = Std.int(i * Settings.SIZE * 1.1);
				a.y = Std.int(Settings.SIZE * 0.6 + j * Settings.SIZE * 1.1);
				if (a.x > Settings.STAGE_WIDTH - Settings.SIZE) {
					i = 1;
					j++;
					a.x = Settings.SIZE * 1.1;
					a.y = Std.int(Settings.SIZE * 0.6 + j * Settings.SIZE * 1.1);
				}
				i++;
				if (b) {
					a.showHL();
					activeAsset = a;
					b = false;
				}
			}
			else
				a.visible = false;
		}
		
		if (LE.ME.modPattern != null) {
			LE.ME.modPattern.visible = false;
			
			switch (ta) {
				case TypeAsset.TAPattern :
					LE.ME.modPattern.visible = true;
				case TypeAsset.TAGeyser :
					LE.ME.modGrid.hideWall();
				default : 
			}
		}
	}
}

class Asset extends h2d.Sprite {
	
	var modAsset	: ModAssets;
	
	public var id	: String;
	public var f	: Int;
	
	public var ta	: TypeAsset;
	public var tr	:TypeRock;
	
	var hs			: mt.deepnight.slb.HSprite;
	
	public function new (ta:TypeAsset, tr:TypeRock, modAsset:ModAssets, id:String, f:Int = 0) {
		super();
		
		this.id = id;
		this.f = f;
		this.tr = tr;
		
		this.ta = ta;
		
		this.modAsset = modAsset;
		
		hs = Settings.SLB_GRID.h_get(id, f);
		hs.filter = true;
		hs.scaleX = hs.scaleY = 0.5;
		hs.setCenterRatio(0.5, 0.5);
		this.addChild(hs);
		
		var inter = new h2d.Interactive(Settings.SIZE, Settings.SIZE);
		//inter.backgroundColor = 0x88FF0000;
		inter.setPos(-Std.int(Settings.SIZE * 0.5), -Std.int(Settings.SIZE * 0.5));
		inter.onRelease = function(e) {
			if (modAsset.activeAsset != this) {
				if (modAsset.activeAsset != null)
					modAsset.activeAsset.hideHL();
				modAsset.activeAsset = this;
				showHL();
			}
		}
		this.addChild(inter);
	}
	
	public function showHL() {
		if (Settings.SLB_GRID.exists(id + "Over"))
			hs.set(id + "Over", f);
	}
	
	public function hideHL() {
		hs.set(id, f);
	}
}