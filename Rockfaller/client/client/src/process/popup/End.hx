package process.popup;

import mt.deepnight.slb.HSprite;
import mt.deepnight.slb.HSpriteBE;
import mt.deepnight.HParticle;

import Common;
import Protocol;

import process.popup.BasePopup;
import ui.Button;
import data.Settings;
import data.LevelDesign;
import data.DataManager;
import manager.SoundManager;
import data.Lang;

/**
 * ...
 * @author Tipyx
 */
 
class End extends BasePopup
{
	public static var ME	: End;
	
	var loose				: Bool;
	var score				: Int;
	var level				: Int;
	
	var bmStar				: h2d.SpriteBatch;
	var bgStar1				: HSpriteBE;
	var bgStar2				: HSpriteBE;
	var bgStar3				: HSpriteBE;
	var hsStar1				: HSpriteBE;
	var hsStar2				: HSpriteBE;
	var hsStar3				: HSpriteBE;
	var lblScore			: h2d.Text;
	
	var hsCapsFlux			: HSprite;
	var hsCapsule			: HSprite;
	
	var offset				: Int;
	
	var bmPartFX			: h2d.SpriteBatch;
	var poolPartFX			: Array<HParticle>;
	
	var modFriend			: ModFriend;
	
	public var btn				: Button;
	var isAnimScoreDone			: Bool;
	public var isSendGameGood	: Bool;
	
	public function new(success:Bool, score:Int, level:Int) {
		ME = this;
		
		this.level = level;
		this.score = score;
		this.loose = !success;
		
		isSendGameGood = false;
		
		var canRetry = LevelDesign.GET_USER_HIGHSCORE(level) != null;
		
		DataManager.SEND_GAMEDATA(level, score, success, false, Game.ME.score.bug || Game.ME.movesLeft.bug);
		
		if (success && LevelDesign.USER_DATA.levelMax == level)
			mt.device.EventTracker.levelAchieved(level);
			
		if (loose) {
			btn = new Button("btOrange", data.Lang.GET_BUTTON(TypeButton.TBRetry), function() {
				if (!isTweening) {
					if (LevelDesign.GET_LIFE() == 0) {
						animEnd(function() {
							ProcessManager.ME.showLife(Game.ME);
							Life.ME.lastLevelTry = level;
							destroy();
						});
					}
					else {
						isTweening = true;
						ProcessManager.ME.goTo(Game.ME, Game, [level, true]);
					}
				}
			});
		}
		else {
			if (LevelDesign.USER_DATA.arHighScore[level] == null || LevelDesign.USER_DATA.arHighScore[level] < score)
				LevelDesign.USER_DATA.arHighScore[level] = score;
			
			btn = new Button("btOrange", data.Lang.GET_BUTTON(canRetry ? TypeButton.TBRetry : TypeButton.TBNext), function() {
				if (!isTweening) {
					isTweening = true;
				#if mBase
					isSendGameGood = true;
				#end
					if (isSendGameGood) {
						if (canRetry) {
							if (LevelDesign.GET_LIFE() == 0)
								ProcessManager.ME.showLife(this);
							else
								ProcessManager.ME.goTo(Game.ME, Game, [level, true]);
						}
						if (level == LevelDesign.AR_LEVEL.length || !Common.VALIDATE_LEVEL(LevelDesign.GET_LEVEL(level + 1)))
							ProcessManager.ME.goTo(Game.ME, Levels, [level, false]);
						else
							ProcessManager.ME.goTo(Game.ME, Levels, [level + 1, true]);
					}
				}
			});
		}
		
		isAnimScoreDone = false;
		
		if (success && Game.ME.arLoots.length > 0)
			Collection.NEW_LOOT = true;
		
		if (loose)
			super(Game.ME, SizePopUp.SPUNormal);
		else
			super(Game.ME, SizePopUp.SPUBig);
		
		//disableCloseBtn();
		
		onClose = close;
		
		popUp.add(btn, 1);
		
		bmPartFX = new h2d.SpriteBatch(Settings.SLB_FX.tile);
		bmPartFX.filter = true;
		popUp.add(bmPartFX, 2);
		
		poolPartFX = HParticle.initPool(bmPartFX, 1000);
	}
	
	function close() {
		animEnd(function() {
			process.ProcessManager.ME.goTo(Game.ME, Levels, [level, false]);
			destroy();			
		});
	}
	
	override function init() {
		textLabel = loose ? Lang.GET_POPUP_TITLE(TypePopUp.TPEndLoose) : Lang.GET_POPUP_TITLE(TypePopUp.TPEndWin);
		
		super.init();
		
		offset = Std.int(heiBG / 10);
		
		if (!loose) {
			var leveInfo = LevelDesign.GET_LEVEL(level);
			
		// SCORE
			var lblYourScore = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_90);
			lblYourScore.filter = true;
			lblYourScore.textColor = 0xBA6837;
			lblYourScore.text = "score";
			lblYourScore.x = Std.int((Settings.STAGE_WIDTH - lblYourScore.textWidth) / 2);
			lblYourScore.y = Std.int(offset * 0.3);
			arHS.push(lblYourScore);
			popUp.add(lblYourScore, 1);
			
			lblScore = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_120);
			lblScore.filter = true;
			lblScore.textColor = 0xFFEFB4;
			lblScore.text = (isAnimScoreDone ? score : 0) + " points";
			lblScore.x = Std.int((Settings.STAGE_WIDTH - lblScore.textWidth) / 2);
			lblScore.y = Std.int(offset * 0.9);
			arHS.push(lblScore);
			popUp.add(lblScore, 1);
	
		// STARS
			var hsBGGoal = Settings.SLB_NOTRIM.h_get("goalBg");
			hsBGGoal.setCenterRatio(0.5, 0.5);
			hsBGGoal.scaleX = hsBGGoal.scaleY = Settings.STAGE_SCALE/* * 2*/;
			hsBGGoal.x = Std.int(Settings.STAGE_WIDTH * 0.5);
			hsBGGoal.y = Std.int(offset * 2.9);
			popUp.add(hsBGGoal, 1);
			arHS.push(hsBGGoal);
			
			{
				var lblStar1 = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_50);
				lblStar1.filter = true;
				lblStar1.textColor = 0xFFEFB4;
				lblStar1.text = Std.string(leveInfo.arStepScore[0]);
				lblStar1.x = Std.int(hsBGGoal.x - hsBGGoal.width * 0.25 - lblStar1.width * 0.5);
				lblStar1.y = Std.int(hsBGGoal.y + hsBGGoal.height * 0.4 - lblStar1.height);
				arHS.push(lblStar1);
				popUp.add(lblStar1, 1);
				
				var lblStar2 = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_50);
				lblStar2.filter = true;
				lblStar2.textColor = 0xFFEFB4;
				lblStar2.text = Std.string(leveInfo.arStepScore[1]);
				lblStar2.x = Std.int(hsBGGoal.x - lblStar2.width * 0.5);
				lblStar2.y = Std.int(hsBGGoal.y + hsBGGoal.height * 0.4 - lblStar2.height);
				arHS.push(lblStar2);
				popUp.add(lblStar2, 1);
				
				var lblStar3 = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_50);
				lblStar3.filter = true;
				lblStar3.textColor = 0xFFEFB4;
				lblStar3.text = Std.string(leveInfo.arStepScore[2]);
				lblStar3.x = Std.int(hsBGGoal.x + hsBGGoal.width * 0.25 - lblStar3.width * 0.5);
				lblStar3.y = Std.int(hsBGGoal.y + hsBGGoal.height * 0.4 - lblStar3.height);
				arHS.push(lblStar3);
				popUp.add(lblStar3, 1);				
			}
			
			if (bmStar != null)
				bmStar.dispose();
			bmStar = new h2d.SpriteBatch(Settings.SLB_UI.tile);
			popUp.add(bmStar, 2);
			
			bgStar1 = Settings.SLB_UI.hbe_get(bmStar, "bgStar");
			bgStar1.scaleX = bgStar1.scaleY = Settings.STAGE_SCALE * 0.6;
			bgStar1.setCenterRatio(0.5, 0.7);
			bgStar1.x = Std.int(hsBGGoal.x - hsBGGoal.width * 0.25);
			bgStar1.y = Std.int(hsBGGoal.y);
			
			bgStar2 = Settings.SLB_UI.hbe_get(bmStar, "bgStar");
			bgStar2.scaleX = bgStar2.scaleY = Settings.STAGE_SCALE * 0.8;
			bgStar2.setCenterRatio(0.5, 0.7);
			bgStar2.x = Std.int(hsBGGoal.x);
			bgStar2.y = Std.int(hsBGGoal.y);
			arBE.push(bgStar2);
			
			bgStar3 = Settings.SLB_UI.hbe_get(bmStar, "bgStar");
			bgStar3.scaleX = bgStar3.scaleY = Settings.STAGE_SCALE * 1;
			bgStar3.setCenterRatio(0.5, 0.7);
			bgStar3.x = Std.int(hsBGGoal.x + hsBGGoal.width * 0.25);
			bgStar3.y = Std.int(hsBGGoal.y);
			arBE.push(bgStar3);
			
			hsStar1 = Settings.SLB_UI.hbe_get(bmStar, "starBig");
			hsStar1.setCenterRatio(0.5, 0.7);
			hsStar1.scaleX = hsStar1.scaleY = bgStar1.scaleX * 2;
			hsStar1.x = bgStar1.x;
			hsStar1.y = bgStar1.y;
			hsStar1.alpha = 0;
			arBE.push(hsStar1);
			
			hsStar2 = Settings.SLB_UI.hbe_get(bmStar, "starBig");
			hsStar2.setCenterRatio(0.5, 0.7);
			hsStar2.scaleX = hsStar2.scaleY = bgStar2.scaleX * 2;
			hsStar2.x = bgStar2.x;
			hsStar2.y = bgStar2.y;
			hsStar2.alpha = 0;
			arBE.push(hsStar2);
			
			hsStar3 = Settings.SLB_UI.hbe_get(bmStar, "starBig");
			hsStar3.setCenterRatio(0.5, 0.7);
			hsStar3.scaleX = hsStar3.scaleY = bgStar3.scaleX * 2;
			hsStar3.x = bgStar3.x;
			hsStar3.y = bgStar3.y;
			hsStar3.alpha = 0;
			arBE.push(hsStar3);
			
			if (isAnimScoreDone) {
				if (score >= leveInfo.arStepScore[0])
					hsStar1.alpha = 1;
				if (score >= leveInfo.arStepScore[1])
					hsStar2.alpha = 1;
				if (score >= leveInfo.arStepScore[2])
					hsStar3.alpha = 1;
				
				hsStar1.scaleX = hsStar1.scaleY = bgStar1.scaleX;
				hsStar2.scaleX = hsStar2.scaleY = bgStar2.scaleX;
				hsStar3.scaleX = hsStar3.scaleY = bgStar3.scaleX;
			}
			
		// LOOTS
			//Game.ME.arLoots = [ { id:"animalMog", num:1 }, { id:"animalMog", num:1 } ];
			if (Game.ME.arLoots.length > 0 && !loose) {
				var lblLoot = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_90);
				lblLoot.filter = true;
				lblLoot.textColor = 0xBA6837;
				lblLoot.text = Lang.GET_VARIOUS(TypeVarious.TVLootGet);
				lblLoot.text = lblLoot.text.toLowerCase();
				lblLoot.x = Std.int((Settings.STAGE_WIDTH - lblLoot.textWidth) / 2);
				lblLoot.y = Std.int(offset * 4);
				arHS.push(lblLoot);
				popUp.add(lblLoot, 1);
				
				var i = 0;
				
				
				var cLoot = new h2d.Sprite();
				
				for (l in Game.ME.arLoots) {
					var loot = setLoot(l.id);
					loot.x = Std.int(i * loot.width * 1.25);
					cLoot.addChild(loot);
					i++;
				}
				
				cLoot.x = Std.int((Settings.STAGE_WIDTH - cLoot.width + Settings.SLB_UI.getFrameData("objectiveBg").wid * Settings.STAGE_SCALE) * 0.5);
				cLoot.y = Std.int(offset * 5.2);
				popUp.add(cLoot, 1);
			}
			
		// FRIENDS
			if (modFriend != null)
				modFriend.destroy();
			modFriend = new ModFriend(hparent, this, level);
			modFriend.y = Std.int(offset * 5.75);
			popUp.addChild(modFriend);
		}
		else {
			var bgCapsule = Settings.SLB_NOTRIM.h_get("lifeBg");
			bgCapsule.scaleX = bgCapsule.scaleY = Settings.STAGE_WIDTH / bgCapsule.width;
			bgCapsule.setCenterRatio(0.5, 0.5);
			arHS.push(bgCapsule);
			popUp.add(bgCapsule, 0);
			
			var lblMinus = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_120);
			lblMinus.filter = true;
			lblMinus.text = "-1";
			lblMinus.x = Std.int((Settings.STAGE_WIDTH - lblMinus.width) * 0.5);
			arHS.push(lblMinus);
			popUp.addChild(lblMinus);
			
		// CAPSULE
			hsCapsule = Settings.SLB_UI2.h_get("iconLifeBig");
			hsCapsule.setCenterRatio(0.5, 0.5);
			hsCapsule.filter = true;
			hsCapsule.visible = !isAnimScoreDone;
			hsCapsule.scaleX = hsCapsule.scaleY = Settings.STAGE_SCALE;
			hsCapsule.x = Std.int(Settings.STAGE_WIDTH * 0.5);
			hsCapsule.y = Std.int(heiBG * 0.4);
			arHS.push(hsCapsule);
			popUp.add(hsCapsule, 1);
			
			hsCapsFlux = Settings.SLB_FX.h_get("lifeFlux");
			hsCapsFlux.setCenterRatio(0.5, 0.5);
			hsCapsFlux.filter = true;
			hsCapsFlux.visible = false;
			hsCapsFlux.scaleX = hsCapsFlux.scaleY = Settings.STAGE_SCALE;
			hsCapsFlux.x = hsCapsule.x;
			hsCapsFlux.y = hsCapsule.y;
			arHS.push(hsCapsFlux);
			popUp.add(hsCapsFlux, 3);
			
			bgCapsule.x = hsCapsule.x;
			bgCapsule.y = hsCapsule.y;
			lblMinus.y = Std.int(bgCapsule.y - lblMinus.textHeight * 0.5);
			
		// TEXT
			var lblLoose = new h2d.Text(Settings.FONT_BENCH_NINE_90);
			lblLoose.filter = true;
			lblLoose.textColor = 0xBA6837;
			//lblLoose.textAlign = h2d.Text.Align.Center;
			lblLoose.maxWidth = Std.int(Settings.STAGE_WIDTH * 0.9);
			lblLoose.text = Lang.GET_VARIOUS(TypeVarious.TVNoGiveUp);
			lblLoose.x = Std.int((Settings.STAGE_WIDTH - lblLoose.textWidth) / 2);
			lblLoose.y = Std.int(heiBG * 0.725);
			arHS.push(lblLoose);
			popUp.add(lblLoose, 1);
			
			if (LevelDesign.GET_LIFE() == 0) {
				lblLoose.text = Lang.GET_VARIOUS(TypeVarious.TVNoGiveUp);
				lblLoose.x = Std.int((Settings.STAGE_WIDTH - lblLoose.textWidth) / 2);
			}
			else {
				lblLoose.text = Lang.GET_VARIOUS(TypeVarious.TVYouHave) +  " " + LevelDesign.GET_LIFE();
				var hsLifeLeft = Settings.SLB_UI.h_get("iconLife");
				arHS.push(hsLifeLeft);
				hsLifeLeft.setCenterRatio(0, 0.5);
				hsLifeLeft.scaleX = hsLifeLeft.scaleY = Settings.STAGE_SCALE;
				lblLoose.x = Std.int((Settings.STAGE_WIDTH - lblLoose.textWidth - hsLifeLeft.width) * 0.5);
				hsLifeLeft.x = lblLoose.x + lblLoose.textWidth;
				hsLifeLeft.y = lblLoose.y + lblLoose.textHeight * 0.5;
				popUp.addChild(hsLifeLeft);
			}
			
		}
		
	// BUTTON
		btn.resize();
		btn.x = Std.int((Settings.STAGE_WIDTH - btn.w) / 2);
		btn.y = Std.int(heiBG * 9 / 10 - btn.h / 2);
		
		onEndAnim = endAnim;
	}
	
	function endAnim() {
		animScore();
		SoundManager.PLAY_MENU_MUSIC();
	}
	
	function setLoot(id:String):h2d.Sprite {
		var cLoot = new h2d.Sprite();
		
		var bg = Settings.SLB_UI.h_get("objectiveBg");
		bg.setCenterRatio(0.5, 0.5);
		bg.filter = true;
		bg.scaleX = bg.scaleY = Settings.STAGE_SCALE;
		cLoot.addChild(bg);
		arHS.push(bg);
		
		var hsIcon = Settings.SLB_GRID.h_get(id);
		hsIcon.setCenterRatio(0.5, 0.5);
		hsIcon.filter = true;
		hsIcon.scaleX = hsIcon.scaleY = Settings.STAGE_SCALE;
		cLoot.addChild(hsIcon);
		arHS.push(hsIcon);
		
		return cLoot;
	}
	
	function animScore() {
		isAnimScoreDone = true;
		if (!loose) {
			var d = score / 10000;
			if (d > 3)
				d = 3;
			else if (d < 0.5)
				d = 0.5;
			
			var tweenScore = 0.;
			
			
			var leveInfo = LevelDesign.GET_LEVEL(level);
			
			lblScore.text = "0 points";
			
			var c = 0;
			function onUpdate(e) {
				c++;
				if (c % 4 == 0)
					SoundManager.SCORE_LOOP_SFX();
				lblScore.text = Std.int(tweenScore) + " points";
				if (Std.int(tweenScore) >= leveInfo.arStepScore[0] && hsStar1.alpha == 0) {
					tweener.create().to(0.1 * Settings.FPS, hsStar1.alpha = 1);
					var t = tweener.create();
					t.to(0.3 * Settings.FPS, hsStar1.scaleX = bgStar1.scaleX, hsStar1.scaleY = bgStar1.scaleX);
					function onCompleteTweenStar1() {
						FX.STARS(bmPartFX, poolPartFX, true, hsStar1);
						FX.DO_GENERAL_SHAKE(rnd(0, 10, true), rnd(0, 10, true));
						SoundManager.STARS1_SFX();
					};
					t.onComplete = onCompleteTweenStar1;
				}
				if (Std.int(tweenScore) >= leveInfo.arStepScore[1] && hsStar2.alpha == 0) {
					tweener.create().to(0.1 * Settings.FPS, hsStar2.alpha = 1);
					var t = tweener.create();
					t.to(0.3 * Settings.FPS, hsStar2.scaleX = bgStar2.scaleX, hsStar2.scaleY = bgStar2.scaleX);
					function onCompleteTweenStar2() {
						FX.STARS(bmPartFX, poolPartFX, true, hsStar2);
						FX.DO_GENERAL_SHAKE(rnd(0, 10, true), rnd(0, 10, true));
						SoundManager.STARS2_SFX();
					};
					t.onComplete = onCompleteTweenStar2;
				}
				if (Std.int(tweenScore) >= leveInfo.arStepScore[2] && hsStar3.alpha == 0) {
					tweener.create().to(0.1 * Settings.FPS, hsStar3.alpha = 1);
					var t = tweener.create();
					t.to(0.3 * Settings.FPS, hsStar3.scaleX = bgStar3.scaleX, hsStar3.scaleY = bgStar3.scaleX);
					function onCompleteTweenStar3() {
						FX.STARS(bmPartFX, poolPartFX, true, hsStar3);
						FX.DO_GENERAL_SHAKE(rnd(0, 10, true), rnd(0, 10, true));
						SoundManager.STARS3_SFX();
					};
					t.onComplete = onCompleteTweenStar3;
				}
				lblScore.x = Std.int((Settings.STAGE_WIDTH - lblScore.textWidth) / 2);
			}	
			tweener.create().to(d * Settings.FPS, tweenScore = score).onUpdate = onUpdate;	
		}
		else {
			function onEndDelayer() {
				SoundManager.LIFE_LOST_SFX();
				hsCapsFlux.visible = true;
				hsCapsule.visible = false;
				FX.DO_GENERAL_SHAKE(0, 30);
				var t = tweener.create().to(0.3 * Settings.FPS, hsCapsFlux.scaleY = 30);
				t.ease(mt.motion.Ease.easeInCubic);
				function onUpdateTweenLoseLife(e) {
					FX.DESTROY_LIFE(bmPartFX, poolPartFX, hsCapsFlux);
				}
				function onCompleteTweenLoseLife() {
					tweener.create().to(0.6 * Settings.FPS, hsCapsFlux.alpha = 0);
				};
				t.onUpdate = onUpdateTweenLoseLife;
				t.onComplete = onCompleteTweenLoseLife;
				for (i in 0...5) {
					var part = mt.deepnight.HParticle.allocFromPool(poolPartFX, Settings.SLB_FX.getTile("lifePart", i));
					part.scaleX = part.scaleY = Settings.STAGE_SCALE * 2;
					part.setPos(hsCapsFlux.x, hsCapsFlux.y);
					part.rotation = mt.MLib.toRad(Std.random(360));
					part.dr = 0.1;
					part.life = 2 + Std.int(2.5 * Settings.FPS);
					part.moveAng(mt.deepnight.Lib.rnd(-3.14, 0, false), 15 + Std.random(5));
					part.gy = 0.4;
					part.frictX = 0.99;
				}				
			}
			delayer.addFrameBased("", onEndDelayer, 0.5 * Settings.FPS);
		}
	}
	
	override function unregister() {
		for (p in poolPartFX) {
			p.dispose();
			p = null;
		}
		poolPartFX = null;
		
		bmPartFX.dispose();
		bmPartFX = null;
		
		if (bmStar != null)
			bmStar.dispose();
		bmStar = null;
		
		btn.destroy();
		btn = null;
		
		ME = null;
		
		if (modFriend != null)
			modFriend.destroy();
		modFriend = null;
		
		super.unregister();
	}
	
	override function update() {
		super.update();
		
		if (modFriend != null)
			modFriend.update();
		
		if (!loose) {
			if (Std.random(Settings.FPS) == 0 && hsStar1.alpha == 1)
				FX.STARS(bmPartFX, poolPartFX, false, hsStar1);
			if (Std.random(Settings.FPS) == 0 && hsStar2.alpha == 1)
				FX.STARS(bmPartFX, poolPartFX, false, hsStar2);
			if (Std.random(Settings.FPS) == 0 && hsStar3.alpha == 1)
				FX.STARS(bmPartFX, poolPartFX, false, hsStar3);			
		}
		
		for (p in poolPartFX)
			p.update(true);
		
		Settings.SLB_UI.updateChildren();
		Settings.SLB_FX.updateChildren();
	}
}
