package process;

import data.Lang;
import h2d.Sprite;
import manager.SoundManager;
import manager.TutoManager;

import mt.deepnight.slb.HSprite;
import mt.deepnight.deprecated.HProcess;
import mt.deepnight.HParticle;

import data.Settings;
import data.LevelDesign;

/**
 * ...
 * @author Tipyx
 */
class LootEarned extends HProcess
{
	var game				: Game;
	
	var arDrawable			: Array<h2d.Drawable>;
	
	var inter				: h2d.Interactive;
	var hsLoot				: HSprite;
	var arFXLoot			: Array<{hs:HSprite, tp:mt.deepnight.deprecated.TinyProcess}>;
	var hsText				: HSprite;
	var lblLoot				: h2d.Text;
	var lblSucceed			: h2d.Text;
	var hsStarLeft			: mt.deepnight.slb.HSprite;
	var hsStarRight			: mt.deepnight.slb.HSprite;
	
	var fdText				: mt.deepnight.slb.BLib.FrameData;
	
	var id					: String;
	var nameLoot				: String;
	
	var tweener				: mt.motion.Tweener;
	
	var enableClick			: Bool;
	var maxWidth			: Int;
	
	var bmPartFX			: h2d.SpriteBatch;
	var poolPartFX			: Array<HParticle>;

	public function new(id:String) 
	{
		this.id = id;
		game = Game.ME;
		
		super();
		
		tweener = new mt.motion.Tweener();
		
		arFXLoot = [];
		
		fdText = Settings.SLB_LANG.getFrameData("lootCatch_" + (Settings.SLB_LANG_IS_DL ? data.Lang.LANG : "en"));
		
		bmPartFX = new h2d.SpriteBatch(Settings.SLB_FX.tile);
		bmPartFX.filter = true;
		root.add(bmPartFX, 1);
		
		poolPartFX = HParticle.initPool(bmPartFX, 200);
		
		arDrawable = [];
		
		maxWidth = Std.int(Settings.STAGE_WIDTH * 0.75);
		nameLoot = "";
		for (l in LevelDesign.AR_LOOT)
			if (l.namePNG == id)
				nameLoot = l.name;
		
		init();
	}
	
	function init() {
		enableClick = false;
		
		inter = new h2d.Interactive(1, 1, root);
		inter.backgroundColor = 0xDF000000;
		inter.alpha = 0;
		inter.scaleX = Settings.STAGE_WIDTH;
		inter.scaleY = Settings.STAGE_HEIGHT;
		inter.onClick = onClickLootEarned;
		
		function onComplete1() {
			hsText = Settings.SLB_LANG.h_get("lootCatch_" + (Settings.SLB_LANG_IS_DL ? data.Lang.LANG : "en"));
			hsText.setCenterRatio(0, 1);
			hsText.filter = true;
			hsText.scaleX = hsText.scaleY = 0;
			hsText.rotation = -3.14 / 4;
			hsText.x = Std.int((Settings.STAGE_WIDTH - fdText.realFrame.realWid * (Settings.STAGE_SCALE  #if !standalone / 0.65 #end)) * 0.5);
			hsText.y = Std.int(Settings.STAGE_HEIGHT * 0.5);
			hsText.y = Std.int(Settings.STAGE_HEIGHT * 0.3);
			arDrawable.push(hsText);
			root.add(hsText, 1);
			
			SoundManager.TREASURE_TEXT_SFX();
			
			function onComplete2() {
				hsLoot = Settings.SLB_GRID.h_get(id);
				hsLoot.filter = true;
				hsLoot.setCenterRatio(0.5, 0.5);
				hsLoot.scaleX = hsLoot.scaleY = 4 * Settings.STAGE_SCALE;
				hsLoot.x = Std.int(Settings.STAGE_WIDTH * 0.5);
				hsLoot.y = Std.int(Settings.STAGE_HEIGHT * 0.4);
				arDrawable.push(hsLoot);
				
				root.add(hsLoot, 1);
				
				
				SoundManager.TREASURE_SFX();
				
				var t = tweener.create().to(0.3 * Settings.FPS, hsLoot.scaleX = 2 * Settings.STAGE_SCALE,
																hsLoot.scaleY = 2 * Settings.STAGE_SCALE);
				t.ease(mt.motion.Ease.easeInCircular);
				function onComplete3() {
					FX.DO_GENERAL_SHAKE(5 * Settings.STAGE_SCALE, 0);
					FX.STARS(bmPartFX, poolPartFX, true, hsLoot);
					
					setIsLoot();
					
					for (fx in arFXLoot) {
						fx.hs.alpha = 0;
						fx.hs.scaleX = fx.hs.scaleY = 0;
						tweener.create().to(0.5 * Settings.FPS, fx.hs.alpha = 1,
																fx.hs.scaleX = 2 * Settings.STAGE_SCALE * 2,
																fx.hs.scaleY = 2 * Settings.STAGE_SCALE * 2);
						fx.hs.x = hsLoot.x;
						fx.hs.y = hsLoot.y;
						arDrawable.push(fx.hs);
					}
					
					lblLoot = new h2d.Text(Settings.FONT_BIRMINGHAM_BMF_120);
					lblLoot.filter = true;
					lblLoot.text = nameLoot;
					lblLoot.alpha = 0;
					lblLoot.textAlign = h2d.Text.Align.Center;
					lblLoot.maxWidth = maxWidth;
					lblLoot.x = Std.int((Settings.STAGE_WIDTH - maxWidth) * 0.5);
					lblLoot.y = Std.int(Settings.STAGE_HEIGHT * 0.6);
					arDrawable.push(lblLoot);
					root.add(lblLoot, 2);
					
					hsStarLeft = Settings.SLB_UI2.h_get("starLoot");
					hsStarLeft.filter = true;
					hsStarLeft.setCenterRatio(0.5, 0.5);
					hsStarLeft.alpha = 0;
					hsStarLeft.scaleX = -Settings.STAGE_SCALE;
					hsStarLeft.scaleY = Settings.STAGE_SCALE;
					hsStarLeft.x = Std.int(Settings.STAGE_WIDTH * 0.5 - lblLoot.width * 0.6);
					hsStarLeft.y = Std.int(lblLoot.y + lblLoot.height * 0.5);
					arDrawable.push(hsStarLeft);
					root.add(hsStarLeft, 2);
					
					hsStarRight = Settings.SLB_UI2.h_get("starLoot");
					hsStarRight.filter = true;
					hsStarRight.setCenterRatio(0.5, 0.5);
					hsStarRight.alpha = 0;
					hsStarRight.scaleX = hsStarRight.scaleY = Settings.STAGE_SCALE;
					hsStarRight.x = Std.int(Settings.STAGE_WIDTH * 0.5 + lblLoot.width * 0.6);
					hsStarRight.y = Std.int(lblLoot.y + lblLoot.height * 0.5);
					arDrawable.push(hsStarRight);
					root.add(hsStarRight, 2);
					
					lblSucceed = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_70);
					lblSucceed.filter = true;
					lblSucceed.textColor = 0xBA6837;
					lblSucceed.alpha = 0;
					lblSucceed.text = Lang.GET_VARIOUS(TypeVarious.TVIfSucceed).toLowerCase();
					lblSucceed.maxWidth = Std.int(Settings.STAGE_WIDTH * 0.75);
					lblSucceed.textAlign = h2d.Text.Align.Center;
					lblSucceed.x = Std.int((Settings.STAGE_WIDTH - lblSucceed.maxWidth) / 2);
					lblSucceed.y = Std.int(Settings.STAGE_HEIGHT * 0.80);
					arDrawable.push(lblSucceed);
					root.add(lblSucceed, 2);
					
					tweener.create().to(0.2 * Settings.FPS,	lblLoot.alpha = 1,
															hsStarLeft.alpha = 1, 
															hsStarRight.alpha = 1, 
															lblSucceed.alpha = 1).onComplete = function () {
																enableClick = true;
																};
					
				}
				t.onComplete = onComplete3;
			}
			tweener.create().to(0.2 * Settings.FPS, hsText.rotation = 0, hsText.scaleX = Settings.STAGE_SCALE #if !standalone / 0.65 #end, hsText.scaleY = Settings.STAGE_SCALE #if !standalone / 0.65 #end).onComplete = onComplete2;
		}
		tweener.create().to(0.2 * Settings.FPS, inter.alpha = 1).onComplete = onComplete1;
	}
	
	function onClickLootEarned(e) {
		if (enableClick)
			game.closeLoot();
	}
	
	function setIsLoot() {
		var color = "fxShineYellow";
		
		var hs1 = Settings.SLB_FX.h_get(color + "A");
		hs1.setCenterRatio(0.5, 0.5);
		hs1.blendMode = Add;
		hs1.filter = true;
		root.add(hs1, 0);
		
		var tp1 = createTinyProcess();
		tp1.onUpdate = function () {
			if (hs1 == null)
				tp1.destroy();
			else
				hs1.rotation += 0.02;
		}
		
		arFXLoot.push( { hs:hs1, tp:tp1 } );
		
		var hs2 = Settings.SLB_FX.h_get(color + "B");
		hs2.setCenterRatio(0.5, 0.5);
		hs2.blendMode = Add;
		hs2.filter = true;
		root.add(hs2, 0);
		
		var tp2 = createTinyProcess();
		tp2.onUpdate = function () {
			if (hs2 == null)
				tp2.destroy();
			else
				hs2.rotation -= 0.02;
		}
		
		arFXLoot.push( { hs:hs2, tp:tp2 } );
		
		var hs3 = Settings.SLB_FX.h_get(color + "C");
		hs3.setCenterRatio(0.5, 0.5);
		hs3.blendMode = Add;
		hs3.filter = true;
		root.add(hs3, 0);
		
		var tp3 = createTinyProcess();
		tp3.onUpdate = function () {
			if (hs3 == null)
				tp3.destroy();
			else
				hs3.rotation -= 0.01;
		}
		
		arFXLoot.push( { hs:hs3, tp:tp3 } );
		
		var hs4 = Settings.SLB_FX.h_get(color + "C");
		hs4.setCenterRatio(0.5, 0.5);
		hs4.blendMode = Add;
		hs4.filter = true;
		hs4.alpha = 0.25;
		//root.add(hs4, 0);
		
		var tp4 = createTinyProcess();
		tp4.onUpdate = function () {
			if (hs4 == null)
				tp4.destroy();
			else
				hs4.rotation -= 0.01;
		}
		
		arFXLoot.push( { hs:hs4, tp:tp4 } );
	}
	
	override function onResize() {
		super.onResize();
		
		maxWidth = Std.int(Settings.STAGE_WIDTH * 0.6);
		
		tweener.dispose();
		tweener = new mt.motion.Tweener();
		
		inter.scaleX = Settings.STAGE_WIDTH;
		inter.scaleY = Settings.STAGE_HEIGHT;
		
		hsText.scaleX = hsText.scaleY = Settings.STAGE_SCALE;
		hsText.x = Std.int((Settings.STAGE_WIDTH  - fdText.realFrame.realWid * (Settings.STAGE_SCALE  #if !standalone / 0.65 #end)) * 0.5);
		hsText.y = Std.int(Settings.STAGE_HEIGHT * 0.3);
		
		hsLoot.scaleX = hsLoot.scaleY = 2 * Settings.STAGE_SCALE;
		hsLoot.x = Std.int(Settings.STAGE_WIDTH * 0.5);
		hsLoot.y = Std.int(Settings.STAGE_HEIGHT * 0.4);
		
		for (fx in arFXLoot) {
			fx.hs.scaleX = fx.hs.scaleY = hsLoot.scaleX * 1.6;
			fx.hs.x = hsLoot.x;
			fx.hs.y = hsLoot.y;
		}
		
		if (lblLoot != null) {
			arDrawable.remove(lblLoot);
			lblLoot.dispose();
		}
		lblLoot = new h2d.Text(Settings.FONT_BIRMINGHAM_BMF_120);
		lblLoot.filter = true;
		lblLoot.text = nameLoot;
		lblLoot.textAlign = h2d.Text.Align.Center;
		lblLoot.maxWidth = maxWidth;
		lblLoot.x = Std.int((Settings.STAGE_WIDTH - maxWidth) * 0.5);
		lblLoot.y = Std.int(Settings.STAGE_HEIGHT * 0.6);
		arDrawable.push(lblLoot);
		root.add(lblLoot, 2);
		
		hsStarLeft.scaleX = -Settings.STAGE_SCALE;
		hsStarLeft.scaleY = Settings.STAGE_SCALE;
		hsStarLeft.x = Std.int(Settings.STAGE_WIDTH * 0.5 - lblLoot.width * 0.6);
		hsStarLeft.y = Std.int(lblLoot.y + lblLoot.height * 0.5);
		
		hsStarRight.scaleX = hsStarRight.scaleY = Settings.STAGE_SCALE;
		hsStarRight.x = Std.int(Settings.STAGE_WIDTH * 0.5 + lblLoot.width * 0.6);
		hsStarRight.y = Std.int(lblLoot.y + lblLoot.height * 0.5);
		
		if (lblSucceed != null) {
			arDrawable.remove(lblSucceed);
			lblSucceed.dispose();
		}
		lblSucceed = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_70);
		lblSucceed.filter = true;
		lblSucceed.textColor = 0xBA6837;
		lblSucceed.text = Lang.GET_VARIOUS(TypeVarious.TVIfSucceed).toLowerCase();
		lblSucceed.maxWidth = Std.int(Settings.STAGE_WIDTH * 0.75);
		lblSucceed.textAlign = h2d.Text.Align.Center;
		lblSucceed.x = Std.int((Settings.STAGE_WIDTH - lblSucceed.maxWidth) / 2);
		lblSucceed.y = Std.int(Settings.STAGE_HEIGHT * 0.80);
		arDrawable.push(lblSucceed);
		root.add(lblSucceed, 2);
	}
	
	public function delete() {
		for (d in arDrawable) {
			if (d != null)
				tweener.create().to(0.2 * Settings.FPS, d.alpha = 0);
		}
		function onComplete() {
			destroy();
			if (TutoManager.GET(6, 1).done && !TutoManager.GET(6, 2).done && !LevelDesign.TUTO_IS_DONE(6)) {
				TutoManager.GET(6, 2).left = !TutoManager.GET(6, 1).left;
				TutoManager.SHOW_POPUP(6, 2);			
			}
		}
		tweener.create().to(0.2 * Settings.FPS, inter.alpha = 0).onComplete = onComplete;
	}
	
	override function unregister() {
		inter.dispose();
		inter = null;
		
		hsText.dispose();
		hsText = null;
		
		hsLoot.dispose();
		hsLoot = null;
		
		for (fx in arFXLoot) {
			fx.hs.dispose();
			fx.hs = null;
			
			fx.tp.destroy();
		}
		
		for (p in poolPartFX) {
			p.dispose();
			p = null;
		}
		poolPartFX = null;
		
		bmPartFX.dispose();
		bmPartFX = null;
		
		lblLoot.dispose();
		lblLoot = null;
		
		hsStarLeft.dispose();
		hsStarLeft = null;
		
		hsStarRight.dispose();
		hsStarRight = null;
		
		lblSucceed.dispose();
		lblSucceed = null;
		
		tweener.dispose();
		tweener = null;
		
		super.unregister();			
	}
	
	override function update() {
		super.update();
		
		tweener.update();
		
		for (p in poolPartFX)
			p.update(true);
		
		if (hsStarLeft != null)
			hsStarLeft.rotation += 0.01;
		if (hsStarRight != null)
			hsStarRight.rotation -= 0.01;
		
		//Settings.SLB_UI.updateChildren();
		//Settings.SLB_FX.updateChildren();
	}
}