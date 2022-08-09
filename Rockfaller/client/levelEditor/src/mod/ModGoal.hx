package mod;

import h2d.Sprite;

import Common;

import mt.deepnight.slb.HSprite;
import mt.deepnight.hui.Button;
import mt.deepnight.HProcess;

/**
 * ...
 * @author Tipyx
 */
 
class ModGoal extends Module
{
	var bg					: h2d.Interactive;
	
	public var	wid			: Int;
	public var	hei			: Int;
	
	var btnScoring			: Button;
	var btnCollect			: Button;
	var btnGelat			: Button;
	var btnCiment			: Button;
	
	var inputScore			: ui.InputText;
	
	var arElemCollect		: Array<{hs:HSprite, input:ui.InputText}>;
	
	var actualTypeGoal		: TypeGoal;
	
	public function new(le:LE) {
		super(le);
		
		wid = Std.int(Settings.STAGE_WIDTH / 2);
		hei = Std.int(Settings.STAGE_HEIGHT / 2);
		
		bg = new h2d.Interactive(wid, hei);
		bg.backgroundColor = 0xFF681A1C;
		bg.cursor = hxd.System.Cursor.Default;
		bg.setPos(Std.int((Settings.STAGE_WIDTH - bg.width) / 2), Std.int((Settings.STAGE_HEIGHT - bg.height) / 2));
		root.addChild(bg);
		
		var hgroup = new mt.deepnight.hui.VGroup(root);
		
		btnScoring = hgroup.button("Scoring", function () {
			choose(le.actualLevel.type.match(TypeGoal.TGScoring) ? le.actualLevel.type : TypeGoal.TGScoring(0));
			selectBtn(btnScoring);
		});
		btnCollect = hgroup.button("Collect", function () {
			choose(le.actualLevel.type.match(TypeGoal.TGCollect) ? le.actualLevel.type : TypeGoal.TGCollect([]));
			selectBtn(btnCollect);
		});
		btnGelat = hgroup.button("Gelat", function () {
			choose(le.actualLevel.type.match(TypeGoal.TGGelatin) ? le.actualLevel.type : TypeGoal.TGGelatin([]));
			selectBtn(btnGelat);
		});
		btnCiment = hgroup.button("Ciment", function () {
			choose(le.actualLevel.type.match(TypeGoal.TGMercury) ? le.actualLevel.type : TypeGoal.TGMercury(LE.ME.modInfo.numSquareValid, []));
			selectBtn(btnCiment);
		});
		
		hgroup.x = bg.x - hgroup.getWidth();
		hgroup.y = bg.y;
		
	// Scoring
		inputScore = new ui.InputText(100, 27);
		inputScore.x = Std.int((bg.width - inputScore.wid) / 2);
		inputScore.y = Std.int((bg.height - inputScore.hei) / 2);
		inputScore.setPosInput(Std.int(bg.x + inputScore.x), Std.int(bg.y + inputScore.y));
		bg.addChild(inputScore);
	
	// Goal
		arElemCollect = [];
	
		for (e in Settings.AR_BASIC)
			addElement(e);
		
		switch (le.actualLevel.type) {
			case TypeGoal.TGScoring(v) :
				inputScore.setText(Std.string(v));
			case TypeGoal.TGMercury(num, ar) :
				//inputScore.setText(Std.string(num));
			case TypeGoal.TGCollect, TypeGoal.TGGelatin(_) :
		}
		
		actualTypeGoal = le.actualLevel.type;
		choose(le.actualLevel.type);
		
		var btnOk = new Button(bg, "Valider", function() {
			validate();
		});
		btnOk.setWidth(wid - 20);
		btnOk.x = Std.int((bg.width - btnOk.getWidth()) * 0.5);
		btnOk.y = Std.int(bg.height - btnOk.getHeight() - 10);
	}
	
	function selectBtn(btn:mt.deepnight.hui.Button) {
		btnScoring.bg.alpha = 0.5;
		btnCollect.bg.alpha = 0.5;
		btnGelat.bg.alpha = 0.5;
		btnCiment.bg.alpha = 0.5;
		
		btn.bg.alpha = 1;
	}
	
	var i = 0;
	var j = 0;
	
	function addElement(id:String) {
		var hs = Settings.SLB_GRID.h_get(id);
		hs.scaleX = hs.scaleY = 0.5;
		hs.setCenterRatio(0.5, 0.5);
		hs.x = Std.int((i + 0.5) * wid * 0.2);
		hs.y = Std.int(j * Settings.SIZE * 1 + 100);
		bg.addChild(hs);
		
		var input = new ui.InputText(Std.int(Settings.SIZE), 30);
		input.x = hs.x - input.wid / 2;
		input.y = hs.y + Settings.SIZE;
		input.setPosInput(Std.int(bg.x + input.x), Std.int(bg.y + input.y));
		bg.addChild(input);
		
		i++;
		if (i > 5) {
			i = 0;
			j++;
		}
		
		arElemCollect.push({hs:hs, input:input});
	}
	
	function choose(tg:TypeGoal) {
		hideSubElement();
		
		switch (tg) {
			case TypeGoal.TGScoring :
				selectBtn(btnScoring);
				inputScore.show();
				actualTypeGoal = TypeGoal.TGScoring(Std.parseInt(inputScore.getText()));
			case TypeGoal.TGCollect :
				selectBtn(btnCollect);
				for (e in arElemCollect) {
					e.hs.visible = true;
					e.input.show();
					switch (LE.ME.actualLevel.type) {
						case TypeGoal.TGCollect(ar) :
							for (el in ar)
								if (Common.GET_HSID_FROM_TYPEROCK(el.tr, LE.ME.actualLevel.biome) == e.hs.groupName)
									e.input.setText(Std.string(el.num));
						case TypeGoal.TGScoring, TypeGoal.TGGelatin, TypeGoal.TGMercury :
					}
				}
				actualTypeGoal = TypeGoal.TGCollect([]);
			case TypeGoal.TGGelatin(ar) :
				selectBtn(btnGelat);
				actualTypeGoal = tg;
			case TypeGoal.TGMercury(num, ar) :
				selectBtn(btnCiment);
				//inputScore.show();
				actualTypeGoal = TypeGoal.TGMercury(num, ar);
		}
	}
	
	function validate() {
		switch (actualTypeGoal) {
			case TypeGoal.TGScoring(v) :
				LE.ME.actualLevel.type = TypeGoal.TGScoring(Std.parseInt(inputScore.getText()));
				LE.ME.rightMenu.enableGelat(false);
				LE.ME.rightMenu.enableCiment(false);
			case TypeGoal.TGCollect :
				var ar = [];
				for (e in arElemCollect) {
					var v = Std.parseInt(e.input.getText());
					if (v > 0) {
						switch (e.hs.groupName) {
							case "crystal", "ground", "roc", "sand", "vegeta" :
								ar.push( { tr:TypeRock.TRClassic(e.hs.groupName), num:v } );
							case "objectiveCog" :
								ar.push( { tr:TypeRock.TRCog(), num:v } );
							case "lava" :
								ar.push( { tr:TypeRock.TRMagma, num:v } );
							case "bubble" :
								ar.push( { tr:TypeRock.TRBubble, num:v } );
							case "chest" :
								ar.push( { tr:TypeRock.TRLoot(), num:v } );
						}
					}
				}
				LE.ME.actualLevel.type = TypeGoal.TGCollect(ar);
				LE.ME.rightMenu.enableGelat(false);
				LE.ME.rightMenu.enableCiment(false);
			case TypeGoal.TGGelatin(ar) :
				LE.ME.actualLevel.type = actualTypeGoal;
				LE.ME.rightMenu.enableGelat(true);
				LE.ME.rightMenu.enableCiment(false);
			case TypeGoal.TGMercury(num, ar) :
				//LE.ME.actualLevel.type = TypeGoal.TGMercury(Std.parseInt(inputScore.getText()), ar);
				LE.ME.actualLevel.type = TypeGoal.TGMercury(LE.ME.modInfo.numSquareValid, ar);
				LE.ME.rightMenu.enableGelat(false);
				LE.ME.rightMenu.enableCiment(true);
		}
		
		LE.ME.updateUI();
		
		destroy();
	}
	
	public function show() {
		root.visible = true;
		
		choose(LE.ME.actualLevel.type);
	}
	
	function hideSubElement() {
		inputScore.hide();
		
		for (e in arElemCollect) {
			e.hs.visible = false;
			e.input.hide();
		}
	}
	
	override function unregister() {
		bg.dispose();
		bg = null;
		
		inputScore.destroy();
		inputScore = null;
		
		for (e in arElemCollect) {
			e.hs.dispose();
			e.hs = null;
			
			e.input.destroy();
			e.input = null;
		}
		
		super.unregister();
	}
}