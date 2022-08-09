package;

import mt.deepnight.hui.Button;

import Common;

import mod.ModAssets;

/**
 * ...
 * @author ...
 */
class RightMenu extends h2d.Sprite
{
	var le					: LE;
	
	var btnAssets			: Button;
	var btnHole				: Button;
	var btnBombCiv			: Button;
	var btnFreeze			: Button;
	var btnGelat			: Button;
	var btnPattern			: Button;
	var btnCiment			: Button;
	var btnGeyser			: Button;
	
	public var wid			: Int;
	public var hei			: Int;

	public function new() 
	{
		super();
		
		le = LE.ME;
		
		var vgroup = new mt.deepnight.hui.VGroup(this);
		
		btnAssets = vgroup.button("Assets", function () {
			selectBtn(btnAssets);
			le.modAssets.showItem(TypeAsset.TABasic);
		});
		
		btnHole = vgroup.button("Hole", function () {
			selectBtn(btnHole);
			le.modAssets.showItem(TypeAsset.TABlock);
		});
		
		btnBombCiv = vgroup.button("Bomb Civ", function () {
			selectBtn(btnBombCiv);
			le.modAssets.showItem(TypeAsset.TABombCiv);
		});
		
		vgroup.separator();
		
		btnFreeze = vgroup.button("Freeze", function () {
			selectBtn(btnFreeze);
			le.modAssets.showItem(TypeAsset.TAFreeze);
		});
		
		btnGelat = vgroup.button("Gelat'", function () {
			selectBtn(btnGelat);
			le.modAssets.showItem(TypeAsset.TAGela);
		});
		
		btnCiment = vgroup.button("Ciment", function () {
			selectBtn(btnCiment);
			le.modAssets.showItem(TypeAsset.TAMerc);
		});
		
		vgroup.separator();
		
		btnPattern = vgroup.button("Pattern", function () {
			selectBtn(btnPattern);
			le.modAssets.showItem(TypeAsset.TAPattern);
		});
		
		btnGeyser = vgroup.button("Geyser", function () {
			selectBtn(btnGeyser);
			le.modAssets.showItem(TypeAsset.TAGeyser);
		});
		
		btnAssets.onClick();
		
		wid = Std.int(vgroup.getWidth());
		hei = Std.int(vgroup.getHeight());
	}
	
	public function init(actualLevel:LevelInfo) {
		enableGelat(false);
		enableCiment(false);
		switch (actualLevel.type) {
			case TypeGoal.TGScoring, TypeGoal.TGCollect :
			case TypeGoal.TGGelatin :
				enableGelat(true);
			case TypeGoal.TGMercury :
				enableCiment(true);
		}
		
		btnAssets.onClick();
	}
	
	public function enableGelat(b:Bool) {
		if (b)
			btnGelat.show();
		else
			btnGelat.hide();
		
		LE.ME.modGrid.setGelatine(b);
	}
	
	public function enableCiment(b:Bool) {
		if (b)
			btnCiment.show();
		else
			btnCiment.hide();
		
		LE.ME.modGrid.setMercure(b);
	}
	
	public function selectBtn(btn:Button) {
		btnAssets.bg.alpha = 0.5;
		btnHole.bg.alpha = 0.5;
		btnBombCiv.bg.alpha = 0.5;
		btnFreeze.bg.alpha = 0.5;
		btnGelat.bg.alpha = 0.5;
		btnPattern.bg.alpha = 0.5;
		btnCiment.bg.alpha = 0.5;
		btnGeyser.bg.alpha = 0.5;
		
		btn.bg.alpha = 1;
	}
}