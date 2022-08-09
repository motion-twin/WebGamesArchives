package mod;

import ui.Button;
import Common;

/**
 * ...
 * @author Tipyx
 */

class ModGP extends Module
{
	public static var		ME		: ModGP;
	
	public static var MAX_LEVEL_GP	: Int		= 5;
	
	var bg					: h2d.Bitmap;
	
	var arGPBtn				: Array<ButtonGP>;
	
	public var	wid			: Int;
	public var	hei			: Int;

	public function new(le:LE) {
		super(le);
		
		ME = this;
		
		wid = Std.int(Settings.STAGE_WIDTH / 2);
		hei = Std.int(Settings.STAGE_HEIGHT / 2);
		
		bg = new h2d.Bitmap(h2d.Tile.fromColor(0xFF808080, wid, hei));
		bg.setPos(Std.int(Settings.STAGE_WIDTH / 4), Std.int(Settings.STAGE_HEIGHT / 4));
		root.addChild(bg);
		
		arGPBtn = [];
		
		addBtn(TypeGP.TGMagma);
		addBtn(TypeGP.TGWater);
	}
	
	var i = 0;
	var j = 0;
	
	function addBtn(t:TypeGP) {
		var btnGP = new ButtonGP(t, Std.int(wid / 4), Std.int(hei / 3), this);
		btnGP.x = i * Std.int(wid / 4);
		btnGP.y = j * Std.int(hei / 3);
		arGPBtn.push(btnGP);
		bg.addChild(btnGP);
		i++;
		if (i > 3) {
			i = 0;
			j++;
		}
		
		var c = 0;
		for (gp in LE.ME.actualLevel.arGP)
			if (btnGP.type.equals(gp))
				c++;
				
		if (c > MAX_LEVEL_GP)
			throw "NO MORE THAN " + MAX_LEVEL_GP + " LEVEL FOR EACH GP";
		else
			btnGP.setLevel(c);	
	}
	
	public function saveGP() {
		var ar = [];
		
		for (gp in arGPBtn) {
			for (i in 0...gp.level)
				ar.push(gp.type);
		}
		
		LE.ME.actualLevel.arGP = ar;
	}
}

class ButtonGP extends h2d.Sprite {
	var hs				: mt.deepnight.slb.HSprite;
	public var type		: TypeGP;
	var w				: Int;
	var h				: Int;
	
	var lblLevel		: h2d.Text;
	public var level	: Int;
	
	public function new (type:TypeGP, newW:Int, newH:Int, modgp:mod.ModGP) {
		super();
		
		level = 0;
		
		this.type = type;
		this.w = newW;
		this.h = newH;
		
		var border = 2;
		
		var inter = new h2d.Interactive(w, h);
		inter.backgroundColor = 0xFF000000;
		inter.onClick = function(e:hxd.Event) {
			setLevel(level + 1 > ModGP.MAX_LEVEL_GP ? 0 : level + 1);
			modgp.saveGP();
		}
		this.addChild(inter);
		
		var bg = new h2d.Bitmap(h2d.Tile.fromColor(0xFFFFFFFF, Std.int(w - border * 2), Std.int(h - border * 2)));
		bg.x = bg.y = border;
		this.addChild(bg);
		
		var id = "";
		switch (type) {
			case TGWater			: id = "bubble";
			case TGFreeze(v)		: id = "iceFront" + (2 - v);
			case TGMagma			: id = "lava";
			case TGBombCiv(n)		: id = "bombeCiv/000" + n;
			case TGPattern(ar)		:
			case TGGeyser(ar)		:
		}
		
		hs = Settings.SLB_GRID.h_get(id);
		hs.x = Std.int(w / 2);
		hs.y = Std.int(h / 2);
		hs.setCenterRatio(0.5, 0.5);
		hs.scaleX = hs.scaleY = 0.5;
		this.addChild(hs);
		
		lblLevel = new h2d.Text(Settings.FONT_ARIAL_26, this);
		lblLevel.text = "Level " + level;
		lblLevel.textColor = 0xFF000000;
		lblLevel.x = Std.int(hs.x - lblLevel.textWidth / 2);
		lblLevel.y = Std.int(bg.height - lblLevel.textHeight);
		
		setLevel(level);
	}
	
	public function setLevel(v:Int) {
		level = v;
		
		lblLevel.text = "Level " + level;
		
		if (level == 0)
			hs.alpha = 0.25;
		else {
			hs.alpha = 1;
			//switch (type) {
				//
			//}
		}
	}
}