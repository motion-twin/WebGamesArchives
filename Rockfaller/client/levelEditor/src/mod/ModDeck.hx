package mod;

import h2d.Text;
import mt.deepnight.slb.HSprite;

import Common;

import ui.Button;

/**
 * ...
 * @author Tipyx
 */

class ModDeck extends Module
{
	public static var		ME		: ModDeck;
	
	var bg					: h2d.Interactive;
	var lblEnter			: Text;
	
	var arGPBtn				: Array<{hs:HSprite, t:TypeRock, v:Int, input:ui.InputText}>;
	
	public var	wid			: Int;
	public var	hei			: Int;
	
	public var total		: Int;
	var sizeWid				: Int;
	var sizeHei				: Int;

	public function new(le:LE) {
		super(le);
		
		ME = this;
		
		wid = Std.int(Settings.STAGE_WIDTH / 2);
		hei = Std.int(Settings.STAGE_HEIGHT / 1.5);
		
		sizeWid = Std.int(wid / 4);
		sizeHei = Std.int(hei / 5);
		
		bg = new h2d.Interactive(wid, hei);
		bg.backgroundColor = 0xFF808080;
		bg.cursor = hxd.System.Cursor.Default;
		bg.setPos(Std.int((Settings.STAGE_WIDTH - bg.width) / 2), Std.int((Settings.STAGE_HEIGHT - bg.height) / 2));
		root.addChild(bg);
		
		total = 0;
		
		lblEnter = new h2d.Text(Settings.FONT_ARIAL_26);
		//lblEnter.text = "Total = " + Common.LENGTH_TOTAL_DECK + " => " + (total == Common.LENGTH_TOTAL_DECK) + " (" + total + ")";
		//lblEnter.x = Std.int((bg.width - lblEnter.textWidth) / 2);
		lblEnter.y = Std.int( -lblEnter.textHeight);
		bg.addChild(lblEnter);
		
		arGPBtn = [];
		
		for (c in Common.AR_ID_CLASSIC)
			addBtn(TypeRock.TRClassic(c));
		for (i in 0...2)
			addBtn(TypeRock.TRFreeze(i + 1));
		for (i in 0...Settings.SLB_GRID.countFrames("bombeCiv"))
			addBtn(TypeRock.TRBombCiv(i));
		// ADD LOOT
	}
	
	var i = 0;
	var j = 0;
	
	function addBtn(t:TypeRock) {
		var hs = Settings.SLB_GRID.h_get(Common.GET_HSID_FROM_TYPEROCK(t, TypeBiome.TBClassic));
		hs.x = Std.int(i * sizeWid + sizeWid * 0.5);
		hs.y = Std.int(j * sizeHei + sizeHei * 0.4);
		hs.setCenterRatio(0.5, 0.5);
		hs.scaleX = hs.scaleY = 0.5;
		bg.addChild(hs);
		
		var v = 0;
		
		for (c in LE.ME.actualLevel.arDeck)
			if (c.t.equals(t))
				v = c.v;
		
		var input = new ui.InputText(Std.int(Settings.SIZE), 30);
		input.x = Std.int(hs.x - input.wid * 0.5);
		input.y = Std.int(hs.y + Settings.SIZE * 0.75);
		input.setPosInput(Std.int(bg.x + input.x), Std.int(bg.y + input.y));
		input.setText(Std.string(v));
		bg.addChild(input);
		
		arGPBtn.push( { hs:hs, t:t, v:v, input:input } );
		
		i++;
		if (i > 3) {
			i = 0;
			j++;
		}
	}
	
	override function unregister() {
		LE.ME.updateUI();
		
		bg.dispose();
		bg = null;
		
		lblEnter.dispose();
		lblEnter = null;
		
		for (gp in arGPBtn) {
			gp.hs.dispose();
			gp.hs = null;
			
			gp.input.destroy();
			gp.input = null;
			
			gp = null;
		}
		
		arGPBtn = [];
		
		super.unregister();
	}
	
	override function update() {
		total = 0;
		
		var deck = [];
		
		for (gp in arGPBtn) {
			gp.v = Std.parseInt(gp.input.value);
			total += gp.v;
			if (gp.v > 0) {
				deck.push( { t:gp.t, v:gp.v } );				
			}
		}
		
		LE.ME.actualLevel.arDeck = deck;
		
		lblEnter.text = "Total = " + Common.LENGTH_TOTAL_DECK + " => " + (total == Common.LENGTH_TOTAL_DECK) + " (" + total + ")";
		lblEnter.x = Std.int((bg.width - lblEnter.textWidth) / 2);
		
		super.update();
	}
}