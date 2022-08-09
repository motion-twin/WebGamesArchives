package mod;

import Common;

/**
 * ...
 * @author Tipyx
 */
class ModSet extends h2d.Sprite
{
	var le					: LE;
	
	var gInfo				: mt.deepnight.hui.VGroup;
	var inter				: h2d.Interactive;
	
	var arBtn				: Array<{ id:String, img:mt.deepnight.hui.Image }>;
	
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
		
		arBtn = [];
		
		createButton("Goal", function() {
			new ModGoal(le);
		}, true);
		
		createButton("GP", function () {
			new ModGP(le);
		}, false);
		
		createButton("Moves", function() {
			new ModMoves(le);
		}, true);
		
		createButton("Steps Score", function() {
			new ModStepScore(le);
		}, true);
		
		createButton("Biome", function () {
			new ModBiome(le);
		}, false);
		
		createButton("Deck", function() {
			new ModDeck(le);
		}, true);
		
		wid = Std.int(gInfo.getWidth());
		hei = Std.int(gInfo.getHeight());
		
		gInfo.x = Std.int((-Settings.STAGE_WIDTH - wid) * 0.5);
		gInfo.y = Std.int((Settings.STAGE_HEIGHT - hei) * 0.5);
	}
	
	function createButton(id:String, cb:Void->Void, needImage:Bool) {
		var hgroup = gInfo.hgroup();
		
		hgroup.button(id, 100, cb);
		
		if (needImage) {
			var tile = Settings.SLB_UI.getTile("editorCancel");
			tile.scale(0.5, 0.5);
			var img = hgroup.image(tile);
			arBtn.push( { id:id, img:img } );
		}
	}
	
	public function updateBtn(id:String, bool:Bool) {
		for (b in arBtn) {
			if (b.id == id) {
				var tile = Settings.SLB_UI.getTile(bool ? "editorValid" : "editorCancel");
				tile.scale(0.3, 0.3);
				b.img.setTile(tile);
			}
		}
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