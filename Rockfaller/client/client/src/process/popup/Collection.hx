package process.popup;

import data.Settings;
import data.LevelDesign;

import process.popup.BasePopup;
import mt.deepnight.slb.BLib;
import data.Lang;

/**
 * ...
 * @author Tipyx
 */
class Collection extends BasePopup
{
	public static var ME	: Collection;
	
	public static var NEW_LOOT	: Bool	= false;
	
	var bmBGLoot			: h2d.SpriteBatch;
	var bmLoot				: h2d.SpriteBatch;
	var bmLootColor			: h2d.SpriteBatch;
	
	var arLoot				: Array<Loot>;
	var interLeft			: h2d.Interactive;
	var interRight			: h2d.Interactive;
	var btnLeft				: mt.deepnight.slb.HSprite;
	var btnRight			: mt.deepnight.slb.HSprite;
	
	var i 					: Int;
	var j 					: Int;
	var fdBGLoot			: Null<FrameData>;
	var widPage				: Int;
	var scale				: Float;
	var arPage				: Array<h2d.Sprite>;

	var actualPageNum		: Int;
	
	var arFamilyLoot		: Array<Array<LootData>>;
	
	public function new (hparent:mt.deepnight.deprecated.HProcess) {
		ME = this;
		
		arLoot = [];
		
		super(hparent, SizePopUp.SPUBig);
		
		NEW_LOOT = false;
		
		onClose = close;
	}
	
	function close() {
		animEnd(function() {
			process.ProcessManager.ME.hideCollection(hparent, this);				
		});
	}
	
	override function init() {
		textLabel = Lang.GET_POPUP_TITLE(TypePopUp.TPCollection);
		
		super.init();
		
		mt.device.EventTracker.view("ui.Collection");
		
		isTweening = false;
		
	// BTN
		btnLeft = Settings.SLB_UI2.h_get("uiLeft");
		btnLeft.setCenterRatio(0, 0.5);
		btnLeft.scaleX = btnLeft.scaleY = Settings.STAGE_SCALE;
		btnLeft.filter = true;
		btnLeft.y = Std.int(heiBG / 2);
		popUp.add(btnLeft, 2);
		arHS.push(btnLeft);
		
		interLeft = new h2d.Interactive(btnLeft.width, btnLeft.height, popUp);
		interLeft.setPos(0, Std.int(btnLeft.y - interLeft.height / 2));
		interLeft.onPush = onPushAskLifeLeft;
		interLeft.onRelease = onReleaseAskLifeLeft;
		interLeft.onOut = onOutAskLifeLeft;
		
		btnRight = Settings.SLB_UI2.h_get("uiLeft");
		btnRight.setCenterRatio(0, 0.5);
		btnRight.scaleX = -Settings.STAGE_SCALE;
		btnRight.scaleY = Settings.STAGE_SCALE;
		btnRight.x = Std.int(Settings.STAGE_WIDTH);
		btnRight.y = Std.int(heiBG / 2);
		btnRight.filter = true;
		popUp.add(btnRight, 2);
		arHS.push(btnRight);
		
		interRight = new h2d.Interactive(btnRight.width, btnRight.height, popUp);
		interRight.setPos(Std.int(Settings.STAGE_WIDTH - interRight.width), Std.int(btnLeft.y - interRight.height / 2));
		interRight.onPush = onPushAskLifeRight;
		interRight.onRelease = onReleaseAskLifeRight;
		interRight.onOut = onOutAskLifeRight;
		
	// LOOT
		scale = Settings.STAGE_SCALE/* * 1.2*/;
		
		fdBGLoot = Settings.SLB_UI.getFrameData("objectiveBg");
		
		widPage = Std.int((fdBGLoot.wid * 1.5) * scale * 4);
		
		if (bmBGLoot == null)
			bmBGLoot = new h2d.SpriteBatch(Settings.SLB_UI.tile, popUp);
		if (bmLoot == null)
			bmLoot = new h2d.SpriteBatch(Settings.SLB_GRID.tile, popUp);
		if (bmLootColor == null) {
			bmLootColor = new h2d.SpriteBatch(Settings.SLB_GRID.tile, popUp);
			bmLootColor.color = new h3d.Vector();
			bmLootColor.colorAdd = h3d.Vector.fromColor(0x00483929);
		}
		
		i = j = 0;
		
		arLoot = [];
		
		arPage = [];
		
		actualPageNum = 0;
		
		isTweening = false;
		
		arFamilyLoot = [];
		
		for (l in LevelDesign.AR_LOOT) {
			var b = true;
			for (arL in arFamilyLoot)
				if (arL[0].family == l.family) {
					arL.push(l);
					b = false;
					break;
				}
				
			if (b) {
				arFamilyLoot.push([l]);
			}
		}
		
		for (i in 0...arFamilyLoot.length) {
			addFamilyLoot(arFamilyLoot[i], i);
		}
		
		btnLeft.visible = interLeft.visible = actualPageNum > 0;
		btnRight.visible = interRight.visible = actualPageNum + 1 < arPage.length;
	}
	
	function onPushAskLifeLeft(e) {
		btnLeft.set("uiLeftOver");
	}
	
	function onReleaseAskLifeLeft(e) {
		btnLeft.set("uiLeft");
		
		if (!isTweening && interLeft.visible) {
			isTweening = true;
			
			var actualPage = arPage[actualPageNum];
			tweener.create().to(0.2 * Settings.FPS, actualPage.x = actualPage.x + Settings.STAGE_WIDTH);
			
			actualPageNum--;
			if (actualPageNum < 0)
				actualPageNum = arPage.length - 1;
			var nextPage = arPage[actualPageNum];
			nextPage.x = Std.int((Settings.STAGE_WIDTH - widPage) / 2 - Settings.STAGE_WIDTH);
			function onComplete() {
				isTweening = false;
				
				btnLeft.visible = interLeft.visible = actualPageNum > 0;
				btnRight.visible = interRight.visible = actualPageNum + 1 < arPage.length;
			}
			
			var t2 = tweener.create().to(0.2 * Settings.FPS, nextPage.x = nextPage.x + Settings.STAGE_WIDTH);
			t2.onComplete = onComplete;
			t2.onUpdate = function (e) {
				for (l in arLoot)
					l.setPosBE();
			}
		}
	}
	
	function onOutAskLifeLeft(e) {
		btnLeft.set("uiLeft");
	}
	
	function onPushAskLifeRight(e) {
		btnRight.set("uiLeftOver");
	}
	
	function onReleaseAskLifeRight(e) {
		btnRight.set("uiLeft");
		
		if (!isTweening && interRight.visible) {
			isTweening = true;
			
			var actualPage = arPage[actualPageNum];
			tweener.create().to(0.2 * Settings.FPS, actualPage.x = actualPage.x - Settings.STAGE_WIDTH);
			
			actualPageNum++;
			if (actualPageNum >= arPage.length)
				actualPageNum = 0;
			var nextPage = arPage[actualPageNum];
			nextPage.x = Std.int((Settings.STAGE_WIDTH - widPage) / 2 + Settings.STAGE_WIDTH);
			function onComplete() {
				isTweening = false;
				
				btnLeft.visible = interLeft.visible = actualPageNum > 0;
				btnRight.visible = interRight.visible = actualPageNum + 1 < arPage.length;
			}
			var t2 = tweener.create().to(0.2 * Settings.FPS, nextPage.x = nextPage.x - Settings.STAGE_WIDTH);
			t2.onComplete = onComplete;
			t2.onUpdate = function (e) {
				for (l in arLoot)
					l.setPosBE();
			}
		}
	}
	
	function onOutAskLifeRight(e) {
		btnRight.set("uiLeft");
	}
	
	function addFamilyLoot(arL:Array<LootData>, num:Int) {
		var pageNum = Std.int(num / 3);
		
		if (arPage[pageNum] == null) {
			var page = new h2d.Sprite();
			page.x = Std.int((Settings.STAGE_WIDTH - widPage) * 0.5 + pageNum * Settings.STAGE_WIDTH);
			arPage.push(page);
			popUp.add(page, 1);
			
			j = i = 0;
		}
		
		var lblFamily = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_90);
		lblFamily.text = (Lang.GET_FAMILYLOOT(arL[0].family)).toLowerCase();
		lblFamily.x = Std.int((widPage - lblFamily.textWidth) * 0.5);
		lblFamily.y = (0.05 + 0.3 * j) * heiBG;
		arHS.push(lblFamily);
		arPage[pageNum].addChild(lblFamily);
		
		for (l in arL) {
			var loot = new Loot(scale, l, bmBGLoot, bmLoot, bmLootColor);
			loot.x = Std.int((fdBGLoot.wid * 1.5) * scale * (i % 5));
			loot.y = (0.25 + 0.3 * j) * heiBG;
			arLoot.push(loot);
			arPage[pageNum].addChild(loot);
			loot.setPosBE();
			
			i++;
		}
		
		j++;
	}
	
	override function onResize() {
		for (l in arLoot) {
			l.destroy();
			l = null;
		}
		
		if (interLeft != null) {
			interLeft.dispose();
			interLeft = null;			
		}
		
		if (interRight != null) {
			interRight.dispose();
			interRight = null;			 
		}
		
		super.onResize();
	}
	
	override function unregister() {
		for (l in arLoot) {
			l.destroy();
			l = null;
		}
		
		arLoot = [];
		
		for (p in arPage) {
			p.dispose();
			p = null;
		}
		
		arPage = null;
		
		if (interLeft != null) {
			interLeft.dispose();
			interLeft = null;			
		}
		
		if (interRight != null) {
			interRight.dispose();
			interRight = null;			 
		}

		ME = null;
		
		super.unregister();
	}
}

class Loot extends h2d.Sprite {
	var bgLoot			: mt.deepnight.slb.HSpriteBE;
	var hsLoot			: mt.deepnight.slb.HSpriteBE;
	var lblName			: h2d.Text;
	var lblNumber		: h2d.Text;
	
	var namePNG			: String;
	
	var num				: Int;
	
	public function new (scale:Float, l:LootData, bmBGLoot:h2d.SpriteBatch, bmLoot:h2d.SpriteBatch, bmLootColor:h2d.SpriteBatch) {
		super();
		
		namePNG = l.namePNG;
		
		num = 0;
		
		for (l in LevelDesign.USER_DATA.arLoots)
			if (l.id == namePNG)
				num = l.num;
		
		//bgLoot = Settings.SLB_UI.h_get("objectiveBg");
		bgLoot = Settings.SLB_UI.hbe_get(bmBGLoot, "objectiveBg");
		bgLoot.setCenterRatio(0.5, 0.5);
		bgLoot.scaleX = bgLoot.scaleY = scale;
		//this.addChild(bgLoot);
		
		if (num == 0)
			hsLoot = Settings.SLB_GRID.hbe_get(bmLootColor, namePNG);
		else
			hsLoot = Settings.SLB_GRID.hbe_get(bmLoot, namePNG);
		hsLoot.setCenterRatio(0.5, 0.5);
		hsLoot.scaleX = hsLoot.scaleY = scale;
		
		lblName = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_30);
		lblName.maxWidth = bgLoot.width;
		lblName.textAlign = h2d.Text.Align.Center;
		lblName.text = num > 0 ? l.name : "???";
		lblName.x = Std.int(-bgLoot.width / 2);
		lblName.y = Std.int(-bgLoot.height / 2 - lblName.textHeight - 10 * Settings.STAGE_SCALE);
		lblName.filter = true;
		this.addChild(lblName);
		
		lblNumber = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_50);
		lblNumber.textAlign = h2d.Text.Align.Center;
		lblNumber.text = num > 0 ? "$ " + num : "";
		lblNumber.x = Std.int(-lblNumber.textWidth / 2);
		lblNumber.y = Std.int(bgLoot.height / 2);
		lblNumber.filter = true;
		this.addChild(lblNumber);
	}
	
	public function setPosBE() {
		var newX = (parent != null ? parent.x : 0) + x;
		var newY = (parent != null ? parent.y : 0) + y;
		
		bgLoot.x = hsLoot.x = newX;
		bgLoot.y = hsLoot.y = newY;
	}
	
	public function destroy() {
		bgLoot.dispose();
		bgLoot = null;
		
		hsLoot.dispose();
		hsLoot = null;
		
		lblName.dispose();
		lblName = null;
		
		lblNumber.dispose();
		lblNumber = null;
	}
}