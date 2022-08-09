package ui.top ;

import mt.deepnight.slb.HSprite;
import mt.deepnight.deprecated.TinyProcess;

import Common;

import data.Settings;
import Rock;
import manager.RockAssetManager;
import data.Lang;

/**
 * ...
 * @author Tipyx
 */
class ModuleGoal extends h2d.Layers {
	var game			: process.Game;
	
	var lblGoal			: h2d.Text;
	
	var arSprite		: Array<h2d.Sprite>;
	
	var arRockCollect	: Array<{tr:TypeRock, num:Int, text:h2d.Text, hs:HSprite, point:h2d.col.Point}>;
	var symbolGoldMerc		: HSprite;
	var lblGoldMerc		: h2d.Text;
	
	var scaleMini		: Float;
	
	var arFXCollect		: Array<{ hs:HSprite, tp:TinyProcess }>;
	var hlIsVisible		: Bool;

	public function new() {
		super();
		
		game = process.Game.ME;
		
		scaleMini = 0.6;
		
		arRockCollect = [];
		
		arSprite = [];
		arFXCollect = [];
		
		hlIsVisible = false;
	}
	
	public function init() {
		for (s in arSprite) {
			s.dispose();
			s = null;
		}
		arSprite = [];
		
	// RESIZE
		if (lblGoal != null)
			lblGoal.dispose();
		lblGoal = new h2d.Text(Settings.FONT_MOUSE_DECO_66);
		lblGoal.textColor = 0xe59537;
		lblGoal.text = Lang.GET_VARIOUS(TypeVarious.TVGoal);
		this.add(lblGoal, 1);
		
		switch (game.levelInfo.type) {
			case TypeGoal.TGScoring(v) :
				var lblTxt = new h2d.Text(Settings.FONT_MOUSE_DECO_100, this);
				lblTxt.letterSpacing = Std.int( -5 * Settings.STAGE_SCALE);
				lblTxt.textColor = 0xFFEFB4;
				lblTxt.text = Std.string(v);
				lblTxt.y = Std.int(lblGoal.y + lblGoal.textHeight * 1.5);
				arSprite.push(lblTxt);
			case TypeGoal.TGCollect(ar) :
				var newX = 0;
				for (r in ar) {
					var id = Common.GET_HSID_FROM_TYPEROCK(r.tr, game.levelInfo.biome);
					var symbol = Settings.SLB_UI.h_get(id);
					symbol.setCenterRatio(0.5, 0);
					symbol.scaleX = symbol.scaleY = Settings.STAGE_SCALE * scaleMini;
					if (newX == 0)
						newX = Std.int(symbol.width * 0.5);
					symbol.x = Std.int(newX);
					symbol.y = Std.int(lblGoal.textHeight * 0.7);
					symbol.filter = true;
					this.add(symbol, 2);
					
					setHL(symbol);
					
					var lblTxt = new h2d.Text(Settings.FONT_MOUSE_DECO_50);
					lblTxt.textColor = 0xFFEFB4;
					lblTxt.textAlign = h2d.Text.Align.Center;
					lblTxt.maxWidth = Rock.SIZE_OFFSET * scaleMini;
					lblTxt.text = Std.string(r.num);
					lblTxt.x = Std.int(symbol.x - lblTxt.maxWidth * 0.5);
					lblTxt.y = Std.int(symbol.y + Rock.SIZE_OFFSET * scaleMini * 1.35);
					this.add(lblTxt, 2);
					
					var point1 = new h2d.col.Point(symbol.x + Rock.SIZE_OFFSET * scaleMini * 0.4, symbol.y + Rock.SIZE_OFFSET * scaleMini);
					var p = game.root.localToGlobal(point1);
					
					arRockCollect.push( { tr:r.tr, num:r.num, text:lblTxt, hs:symbol, point:p } );
					
					newX += Std.int(Rock.SIZE_OFFSET * scaleMini * 1.2);
				}
			case TypeGoal.TGGelatin :
				symbolGoldMerc = Settings.SLB_UI.h_get("mudBack");
				symbolGoldMerc.setCenterRatio(0.5, 0);
				symbolGoldMerc.scaleX = symbolGoldMerc.scaleY = Settings.STAGE_SCALE * 0.5;
				symbolGoldMerc.x = symbolGoldMerc.width * 0.5;
				symbolGoldMerc.y = Std.int(lblGoal.textHeight * 0.85);
				setHL(symbolGoldMerc);
				this.addChild(symbolGoldMerc);
				arSprite.push(symbolGoldMerc);
				
				lblGoldMerc = new h2d.Text(Settings.FONT_MOUSE_DECO_50);
				lblGoldMerc.textColor = 0xFFEFB4;
				lblGoldMerc.maxWidth = Rock.SIZE_OFFSET * scaleMini;
				lblGoldMerc.textAlign = h2d.Text.Align.Center;
				lblGoldMerc.text = Std.string(game.arGelatin.length);
				lblGoldMerc.y = Std.int(symbolGoldMerc.y + Rock.SIZE_OFFSET * scaleMini * 1.3);
				this.addChild(lblGoldMerc);
				arSprite.push(lblGoldMerc);
			case TypeGoal.TGMercury(num, ar) :
				symbolGoldMerc = Settings.SLB_UI.h_get("mercury");
				symbolGoldMerc.setCenterRatio(0.5, 0);
				symbolGoldMerc.scaleX = symbolGoldMerc.scaleY = Settings.STAGE_SCALE * 0.5;
				symbolGoldMerc.x = symbolGoldMerc.width * 0.5;
				symbolGoldMerc.y = Std.int(lblGoal.textHeight * 0.85);
				setHL(symbolGoldMerc);
				this.addChild(symbolGoldMerc);
				arSprite.push(symbolGoldMerc);
				
				lblGoldMerc = new h2d.Text(Settings.FONT_MOUSE_DECO_50);
				lblGoldMerc.textColor = 0xFFEFB4;
				lblGoldMerc.maxWidth = Rock.SIZE_OFFSET * scaleMini;
				lblGoldMerc.textAlign = h2d.Text.Align.Center;
				lblGoldMerc.text = Std.string(num);
				lblGoldMerc.y = Std.int(symbolGoldMerc.y + Rock.SIZE_OFFSET * scaleMini * 1.3);
				this.addChild(lblGoldMerc);
				arSprite.push(lblGoldMerc);
		}
		
		updateValue();
	}
	
	public function getPos(n:Int) {
		var hs = arRockCollect.length > 0 ? arRockCollect[n].hs : symbolGoldMerc;
		var p =  game.root.localToGlobal(new h2d.col.Point(hs.x, hs.y + hs.height * 0.5));
		return { x:p.x, y:p.y };
	}
	
	public function showHL() {
		hlIsVisible = true;
		for (fx in arFXCollect)
			fx.hs.visible = true;
	}
	
	public function hideHL() {
		hlIsVisible = false;
		for (fx in arFXCollect)
			fx.hs.visible = false;
	}
	
	function setHL(symbol:HSprite) {
		var color = "fxShineWhite";
		
		var hs1 = Settings.SLB_FX.h_get(color + "A");
		hs1.setCenterRatio(0.5, 0.5);
		hs1.blendMode = Add;
		hs1.filter = true;
		hs1.visible = hlIsVisible;
		hs1.scaleX = hs1.scaleY = Settings.STAGE_SCALE * 2;
		hs1.x = Std.int(symbol.x);
		hs1.y = Std.int(symbol.y + 0.75 * Rock.SIZE_OFFSET * scaleMini);
		this.add(hs1, 0);
		
		var tp1 = game.createTinyProcess();
		tp1.onUpdate = function () {
			if (hs1 == null)
				tp1.destroy();
			else
				hs1.rotation += 0.02;
		}
		
		arFXCollect.push( { hs:hs1, tp:tp1 } );
		
		var hs2 = Settings.SLB_FX.h_get(color + "B");
		hs2.setCenterRatio(0.5, 0.5);
		hs2.blendMode = Add;
		hs2.filter = true;
		hs2.visible = hlIsVisible;
		hs2.x = hs1.x;
		hs2.y = hs1.y;
		hs2.scaleX = hs2.scaleY = Settings.STAGE_SCALE * 2;
		this.add(hs2, 0);
		
		var tp2 = game.createTinyProcess();
		tp2.onUpdate = function () {
			if (hs2 == null)
				tp2.destroy();
			else
				hs2.rotation -= 0.02;
		}
		
		arFXCollect.push( { hs:hs2, tp:tp2 } );
		
		var hs3 = Settings.SLB_FX.h_get(color + "C");
		hs3.setCenterRatio(0.5, 0.5);
		hs3.blendMode = Add;
		hs3.filter = true;
		hs3.visible = hlIsVisible;
		hs3.x = hs1.x;
		hs3.y = hs1.y;
		hs3.scaleX = hs3.scaleY = Settings.STAGE_SCALE * 2;
		this.add(hs3, 0);
		
		var tp3 = game.createTinyProcess();
		tp3.onUpdate = function () {
			if (hs3 == null)
				tp3.destroy();
			else
				hs3.rotation -= 0.01;
		}
		
		arFXCollect.push( { hs:hs3, tp:tp3 } );
		
		color = "fxShineWhite";
		
		var hs4 = Settings.SLB_FX.h_get(color + "C");
		hs4.setCenterRatio(0.5, 0.5);
		hs4.blendMode = Add;
		hs4.filter = true;
		hs4.alpha = 0.25;
		hs4.visible = hlIsVisible;
		hs4.x = hs1.x;
		hs4.y = hs1.y;
		hs4.scaleX = hs4.scaleY = Settings.STAGE_SCALE * 2;
		this.add(hs4, 0);
		
		var tp4 = game.createTinyProcess();
		tp4.onUpdate = function () {
			if (hs4 == null)
				tp4.destroy();
			else
				hs4.rotation -= 0.01;
		}
		
		arFXCollect.push( { hs:hs4, tp:tp4 } );
	}
	
	public function updateValue(r:Rock = null) {
		switch (game.levelInfo.type) {
			case TypeGoal.TGScoring(v) :
			case TypeGoal.TGCollect(ar) :
				if (r != null) {
					for (ro in arRockCollect) {
						if (ro.tr.equals(r.type)) {
							for (e in ar) {
								if (e.tr.equals(r.type) && ro.num > 0)
									FX.GO_TO_OBJECTIVE(r, ro.hs, ro.point, function() {
										ro.num--;
										if (ro.num < 0)
											ro.num = 0;
										ro.text.text = Std.string(ro.num);
									});
							}
						}
					}
				}
			case TypeGoal.TGGelatin :
				lblGoldMerc.text = Std.string(game.arGelatin.length);
				lblGoldMerc.x = Std.int(symbolGoldMerc.x - lblGoldMerc.maxWidth * 0.5);
			
			case TypeGoal.TGMercury(num, ar) :
				var numTxt = num - game.arMerc.length;
				if (numTxt < 0)
					numTxt = 0;
				lblGoldMerc.text = Std.string(numTxt);
				lblGoldMerc.x = Std.int(symbolGoldMerc.x - lblGoldMerc.maxWidth * 0.5);
		}
	}
	
	public function resize() {
		for (fx in arFXCollect) {
			fx.hs.dispose();
			fx.hs = null;
			fx.tp.destroy();
		}
		
		arFXCollect = [];
		
		for (r in arRockCollect) {
			r.hs.dispose();
			r.hs = null;
			
			r.text.dispose();
			r.text = null;
			
			r.point = null;
		}
		arRockCollect = [];
	
		init();
		
		switch (game.levelInfo.type) {
			case TypeGoal.TGScoring(v) :
			case TypeGoal.TGCollect(ar) :
				for (r in game.goalManager.arRockRecovered) {
					for (ro in arRockCollect) {
						if (ro.tr.equals(r.tr)) {
							ro.num -= r.num;
							if (ro.num < 0)
								ro.num = 0;
							ro.text.text = Std.string(ro.num);
						}
					}					
				}
			case TypeGoal.TGGelatin :
				lblGoldMerc.text = Std.string(game.arGelatin.length);
				lblGoldMerc.x = Std.int(symbolGoldMerc.x - lblGoldMerc.maxWidth * 0.5);
			case TypeGoal.TGMercury(num, ar) :
				var numTxt = num - game.arMerc.length;
				if (numTxt < 0)
					numTxt = 0;
				lblGoldMerc.text = Std.string(numTxt);
				lblGoldMerc.x = Std.int(symbolGoldMerc.x - lblGoldMerc.maxWidth * 0.5);
		}
	}
	
	public function destroy() {
		lblGoal.dispose();
		lblGoal = null;
		
		for (r in arRockCollect) {
			r.hs.dispose();
			r.hs = null;
			
			r.text.dispose();
			r.text = null;
			
			r.point = null;
		}
		arRockCollect = null;
		
		for (fx in arFXCollect) {
			fx.hs.dispose();
			fx.hs = null;
			fx.tp.destroy();
		}
		
		arFXCollect = null;
		
		for (s in arSprite) {
			s.dispose();
			s = null;
		}
		arSprite = null;
	}
}
