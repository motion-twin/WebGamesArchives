package mod;

import Common;

/**
 * ...
 * @author Tipyx
 */
class ModBiome extends Module
{
	public static var RATIO = 0.40;
	
	var bg					: h2d.Interactive;
	var lblChoose			: h2d.Text;
	
	var wid					: Int;
	var hei					: Int;
	
	var arBiome				: Array<Biome>;

	public function new(le:LE) {
		super(le);
		
		lblChoose = new h2d.Text(Settings.FONT_ARIAL_26);
		lblChoose.text = "Choose a Biome";
		
		wid = Std.int(TypeBiome.createAll().length * Settings.SLB_UNIVERS1.getFrameData("bgGlobal_classic", 0).wid * RATIO + (TypeBiome.createAll().length - 1) * 10);
		hei = Std.int(lblChoose.textHeight + Settings.SLB_UNIVERS1.getFrameData("bgGlobal_classic", 0).hei * RATIO);
		
		bg = new h2d.Interactive(wid, hei);
		bg.backgroundColor = 0xFF808080;
		bg.cursor = hxd.System.Cursor.Default;
		bg.setPos(Std.int((Settings.STAGE_WIDTH - bg.width) / 2), Std.int((Settings.STAGE_HEIGHT - bg.height) / 2));
		root.addChild(bg);
		
		lblChoose.x = Std.int((bg.width - lblChoose.textWidth) / 2);
		bg.addChild(lblChoose);
		
		arBiome = [];
		
		var i = 0;
		
		for (b in TypeBiome.createAll()) {
			var biome = new Biome(b);
			
			biome.onClick = function () {
				choose(biome.type);
			}
			biome.x = (10 + biome.w) * i;
			biome.y = lblChoose.textHeight;
			arBiome.push(biome);
			i++;
			bg.addChild(biome);
		}
		
		choose(le.actualLevel.biome);
	}
	
	function choose(biome:TypeBiome) {
		for (b in arBiome) {
			if (b.type == biome) {
				b.show();
				LE.ME.actualLevel.biome = biome;
				LE.ME.modGrid.changeBiome();
			}
			else {
				b.hide();
			}
		}
	}
	
	override function unregister() {
		bg.dispose();
		bg = null;
		
		lblChoose.dispose();
		lblChoose = null;
		
		for (b in arBiome) {
			b.destroy();
			b = null;
		}
		
		super.unregister();
	}
}

class Biome extends h2d.Sprite {
	var hs				: mt.deepnight.slb.HSprite;
	var inter			: h2d.Interactive;
	
	public var type		: TypeBiome;
	var slb				: mt.deepnight.slb.BLib;
	var id				: String;
	
	public var w		: Int;
	
	public var onClick	: Void->Void;
	
	public function new(type:TypeBiome) {
		super();
		
		this.type = type;
		
		switch (type) {
			case TypeBiome.TBClassic :
				slb = Settings.SLB_UNIVERS1;
				id = "bgGlobal_classic";
			case TypeBiome.TBFreeze :
				slb = Settings.SLB_UNIVERS1;
				id = "bgGlobal_ice";
			case TypeBiome.TBMagma :
				slb = Settings.SLB_UNIVERS1;
				id = "bgGlobal_magma";
			case TypeBiome.TBWater :
				slb = Settings.SLB_UNIVERS2;
				id = "bgGlobal_water";
			case TypeBiome.TBCiv :
				slb = Settings.SLB_UNIVERS2;
				id = "bgGlobal_civ";
			case TypeBiome.TBCentEarth :
				slb = Settings.SLB_UNIVERS2;
				id = "bgGlobal_core";
			case TypeBiome.TBNightmare :
				slb = Settings.SLB_UNIVERS3;
				id = "bgGlobal_nightmare";
			case TypeBiome.TBLimbo :
				slb = Settings.SLB_UNIVERS3;
				id = "bgGlobal_tree";
		}
		
		hs = slb.h_get(id, 0);
		hs.scaleX = hs.scaleY = ModBiome.RATIO;
		this.addChild(hs);
		
		inter = new h2d.Interactive(Std.int(hs.width), Std.int(hs.height));
		inter.cursor = hxd.System.Cursor.Default;
		inter.onClick = function(e) {
			if (onClick != null)
				onClick();
		}
		this.addChild(inter);
		
		w = Std.int(hs.width);
	}
	
	public function show() {
		hs.alpha = 1;
	}
	
	public function hide() {
		hs.alpha = 0.25;
	}
	
	public function destroy() {
		hs.dispose();
		hs = null;
		
		inter.dispose();
		inter = null;
	}
}