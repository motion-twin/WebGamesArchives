package mod;

import Common;

/**
 * ...
 * @author Tipyx
 */
class ModFile extends h2d.Sprite
{
	
	var le					: LE;
	
	var gInfo				: mt.deepnight.hui.VGroup;
	var inter				: h2d.Interactive;
	
	public var wid			: Int;
	public var hei			: Int;
	
	var isTweening			: Bool;
	var isVisible			: Bool;
	
	public function new() {
		super();
		
		le = LE.ME;
		
		isTweening = false;
		isVisible = false;
		
		inter = new h2d.Interactive(Settings.STAGE_WIDTH, Settings.STAGE_HEIGHT);
		inter.backgroundColor = 0xFF000000;
		inter.alpha = 0;
		inter.visible = false;
		inter.onClick = function (e) {
			toggle();
		}
		this.addChild(inter);
		
		gInfo = new mt.deepnight.hui.VGroup(this);
		
		//var btnSave = gInfo.button("Save", function () {
			//le.save();
			//toggle();
		//});
		
		var btnTest = gInfo.button("Tester", function () {
			DataManager.TEST(le.actualLevel.level);
		});
		
		var btnGoto = gInfo.button("Go to level...", function () {
			new ModNewLevel(le);
		});
		
		var btnMove = gInfo.button("Move to...", function () {
			new ModMoveLevel(le);
		});
		
		var btnReset = gInfo.button("Reset", function () {
			le.reset();
			toggle();
		});
		
		var btnDelete = gInfo.button("DELETE", function () {
			new ModDeleteLevel(le);
		});
		
		wid = Std.int(gInfo.getWidth());
		hei = Std.int(gInfo.getHeight());
		
		gInfo.x = Std.int((-Settings.STAGE_WIDTH - wid) * 0.5);
		gInfo.y = Std.int((Settings.STAGE_HEIGHT - hei) * 0.5);
	}
	
	public function toggle() {
		if (!isTweening) {
			isTweening = true;
			var t = le.tweener.create();
			inter.visible = true;
			if (isVisible) {
				t.to(0.1 * 60, inter.alpha = 0, gInfo.x = Std.int((-Settings.STAGE_WIDTH - wid) * 0.5));				
			}
			else {
				t.to(0.1 * 60, inter.alpha = 0.75, gInfo.x = Std.int((Settings.STAGE_WIDTH - wid) * 0.5));
			}
			t.onComplete = function() {
				isVisible = !isVisible;
				isTweening = false;
				inter.visible = isVisible;
			}
		}
	}
}