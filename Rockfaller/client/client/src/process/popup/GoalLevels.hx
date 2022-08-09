package process.popup;

import h2d.Text;

import mt.deepnight.slb.HSprite;

import Common;
import Protocol;

import process.popup.BasePopup;
import data.DataManager;
import data.Settings;
import manager.RockAssetManager;
import ui.Button;
import data.Lang;

/**
 * ...
 * @author Tipyx
 */
class GoalLevels extends BasePopup
{
	public static var ME	: GoalLevels;
	
	var btnPlay				: Button;
	
	var levelInfo			: LevelInfo;
	var isFromGame			: Bool;
	
	var offset				: Int;
	
	var waitingForServer	: Bool;
	
	var modFriend			: ModFriend;

	public function new(levelInfo:LevelInfo, isFromGame:Bool) {
		ME = this;
		
		this.isFromGame = isFromGame;
		this.levelInfo = levelInfo;
		
		waitingForServer = false;
		
		btnPlay = new Button("btOrange", data.Lang.GET_BUTTON(TypeButton.TBPlay), function () {
			if (!waitingForServer) {
				DataManager.DO_PROTOCOL(ProtocolCom.DoLaunchGame(levelInfo.level));
				waitingForServer = true;
			}
		} );
		
		if (isFromGame)
			super(Game.ME, SizePopUp.SPUBig);
		else
			super(Levels.ME, SizePopUp.SPUBig);
		
		if ( hparent == null ) throw "hparent is null (isFromGame="+isFromGame+")";
			
		hparent.pause();
		
		onClose = close;
		
		inter.onClick = onClickBG;
		
		popUp.add(btnPlay, 1);
	}
	
	function onClickBG(e) {
		if (!isTweening && (root.mouseY < popUp.y || root.mouseY > popUp.y + heiBG) && isCome && !isFromGame)
			onClose();
	}
	
	function close () {
		isCome = false;
		animEnd(function() {
			destroy();
			hparent.resume();
			if (isFromGame)		// GAME TO GAME
				process.ProcessManager.ME.goTo(Game.ME, Levels, [levelInfo.level, false]);
		});
	}
	
	public function goToLevel() {
		animEnd(function() {
			destroy();
			if (isFromGame) {	// GAME TO GAME
				Game.ME.resume();
			}
			else {				// LEVELS TO GAME
				ProcessManager.ME.goTo(Levels.ME, Game, [levelInfo.level, false]);
			}
		});
	}
	
	override function init() {
		speedFall = 0.75;
		
		Rock.RESIZE();
		
		textLabel = Lang.GET_POPUP_TITLE(TypePopUp.TPLevel) + " " + levelInfo.level;
		
		super.init();
		
		offset = Std.int(heiBG / 10);
		
		var padding = 50 * Settings.STAGE_SCALE;
		
	// GOAL
		var lblGoal = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_70, popUp);
		lblGoal.filter = true;
		lblGoal.textColor = 0xBA6837;
		switch (levelInfo.type) {
			case TypeGoal.TGScoring	: lblGoal.text = Lang.GET_VARIOUS(TypeVarious.TVGoalScore);
			case TypeGoal.TGCollect	: lblGoal.text = Lang.GET_VARIOUS(TypeVarious.TVGoalCollect);
			case TypeGoal.TGGelatin	: lblGoal.text = Lang.GET_VARIOUS(TypeVarious.TVGoalGelat);
			case TypeGoal.TGMercury	: lblGoal.text = Lang.GET_VARIOUS(TypeVarious.TVGoalMercure);
		}
		lblGoal.text = mt.Utf8.lowercase( lblGoal.text );
		lblGoal.maxWidth = Std.int(Settings.STAGE_WIDTH * 0.60);
		lblGoal.textAlign = Center;
		lblGoal.x = Std.int((Settings.STAGE_WIDTH - lblGoal.maxWidth) / 2);
		lblGoal.y = Std.int(offset - lblGoal.textHeight * 0.35);
		arHS.push(lblGoal);
		
		var hsBGGoal = Settings.SLB_NOTRIM.h_get("goalBg");
		hsBGGoal.setCenterRatio(0.5, 0.5);
		hsBGGoal.scaleX = hsBGGoal.scaleY = Settings.STAGE_SCALE/* * 2*/;
		hsBGGoal.x = Std.int(Settings.STAGE_WIDTH * 0.5);
		hsBGGoal.y = Std.int(offset * 3);
		popUp.addChild(hsBGGoal);
		arHS.push(hsBGGoal);
		
		switch (levelInfo.type) {
			case TypeGoal.TGScoring(v)	:
				var hText = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_150, popUp);
				hText.filter = true;
				hText.text = v + " " + Lang.GET_VARIOUS(TypeVarious.TVPoints);
				hText.text = mt.Utf8.lowercase( hText.text );
				hText.x = Std.int((Settings.STAGE_WIDTH - hText.textWidth) / 2);
				hText.y = Std.int(hsBGGoal.y - hText.height * 0.5);
				arHS.push(hText);
			case TypeGoal.TGCollect(ar)	:
				var cGoal = new h2d.Sprite();
				var widGoal = 0;				
				for (i in 0...ar.length) {
					var r = ar[i];
					var bg = setIcon(Common.GET_HSID_FROM_TYPEROCK(r.tr, levelInfo.biome), widGoal, cGoal);
					var hTxt = new h2d.Text(Settings.FONT_MOUSE_DECO_66);
					hTxt.textColor = 0xFFEFB4;
					hTxt.text = Std.string(r.num);
					hTxt.x = Std.int(bg.x - hTxt.textWidth * 0.5);
					hTxt.y = Std.int(Rock.SIZE_OFFSET + 10 * Settings.STAGE_SCALE);
					arHS.push(hTxt);
					cGoal.addChild(hTxt);
					
					widGoal = Std.int(bg.x + Rock.SIZE_OFFSET * 0.5 + 15 * Settings.STAGE_SCALE);
				}
				cGoal.x = Std.int((Settings.STAGE_WIDTH - cGoal.width) * 0.5);
				cGoal.y = Std.int(offset * 2.4);
				popUp.add(cGoal, 1);
			case TypeGoal.TGGelatin(ar) :
				var symbol = Settings.SLB_UI.h_get("mudBack");
				symbol.setCenterRatio(0.5, 0.5);
				symbol.scaleX = symbol.scaleY = Settings.STAGE_SCALE;
				symbol.filter = true;
				symbol.x = Std.int(Settings.STAGE_WIDTH * 0.5);
				symbol.y = Std.int(2.3 * offset + 0.5 * symbol.height);
				popUp.addChild(symbol);
				arHS.push(symbol);
				
				var hTxt = new h2d.Text(Settings.FONT_MOUSE_DECO_66);
				hTxt.filter = true;
				hTxt.textColor = 0xFFEFB4;
				hTxt.text = "x" + ar.length;
				hTxt.x = Std.int(symbol.x - hTxt.textWidth * 0.5);
				hTxt.y = Std.int(symbol.y + Rock.SIZE_OFFSET * 0.75);
				arHS.push(hTxt);
				popUp.addChild(hTxt);
			case TypeGoal.TGMercury(num, ar) :
				var symbol = Settings.SLB_UI.h_get("mercury");
				symbol.setCenterRatio(0.5, 0.5);
				symbol.scaleX = symbol.scaleY = Settings.STAGE_SCALE;
				symbol.filter = true;
				symbol.x = Std.int(Settings.STAGE_WIDTH * 0.5);
				symbol.y = Std.int(2.3 * offset + 0.5 * symbol.height);
				popUp.addChild(symbol);
				arHS.push(symbol);
				
				var hTxt = new h2d.Text(Settings.FONT_MOUSE_DECO_66);
				hTxt.filter = true;
				hTxt.textColor = 0xFFEFB4;
				hTxt.text = "x" + num;
				hTxt.x = Std.int(symbol.x - hTxt.textWidth * 0.5);
				hTxt.y = Std.int(symbol.y + Rock.SIZE_OFFSET * 0.75);
				arHS.push(hTxt);
				popUp.addChild(hTxt);
		}
		
	// STARS
		//setPoint(0, Std.int(Settings.STAGE_WIDTH * 0.5), Std.int(offset * 5.75));
		//
		//setPoint(1, Std.int(Settings.STAGE_WIDTH * 0.5), Std.int(offset * 6.75));
		//
		//setPoint(2, Std.int(Settings.STAGE_WIDTH * 0.5), Std.int(offset * 7.75));
		
	// BUTTON
		btnPlay.resize();
		btnPlay.x = Std.int(Settings.STAGE_WIDTH / 2 - btnPlay.w / 2);
		btnPlay.y = Std.int(offset * 9 - btnPlay.h / 2);
		//btnPlay.y = Std.int(offset * 4.75 - btnPlay.h / 2);
		
	// FRIENDS
		if (modFriend != null)
			modFriend.destroy();
		modFriend = new ModFriend(hparent, this, levelInfo.level);
		modFriend.y = Std.int(offset * 5);
		popUp.addChild(modFriend);
	}
	
	function setIcon(id:String, widGoal:Int, cGoal:h2d.Sprite):HSprite {
		var symbol = Settings.SLB_UI.h_get(id);
		symbol.setCenterRatio(0.5, 0.5);
		symbol.scaleX = symbol.scaleY = Settings.STAGE_SCALE;
		symbol.filter = true;
		symbol.x = Std.int(widGoal + symbol.width * 0.5);
		symbol.y = Std.int(symbol.height * 0.5);
		cGoal.addChild(symbol);
		arHS.push(symbol);
		
		return symbol;
	}
	
	function setPoint(step:Int, pointX:Int, pointY:Int) {
		var bgStar = Settings.SLB_UI.hbe_get(bm, "pointBg");
		bgStar.scaleX = bgStar.scaleY = Settings.STAGE_SCALE;
		bgStar.setCenterRatio(0.5, 0.5);
		bgStar.x = pointX;
		bgStar.y = pointY;
		bgStar.changePriority(6);
		arBE.push(bgStar);
		
		var hsStar1 = Settings.SLB_UI.hbe_get(bm, "starBig", 0);
		hsStar1.setCenterRatio(0.5, 0.5);
		hsStar1.scaleX = hsStar1.scaleY = Settings.STAGE_SCALE * 0.75;
		hsStar1.x = Std.int( -bgStar.width * 0.5) + pointX;
		hsStar1.y = pointY;
		hsStar1.changePriority(5);
		arBE.push(hsStar1);
		
		if (step > 0) {
			var hsStar2 = Settings.SLB_UI.hbe_get(bm, "starBig", 1);
			hsStar2.setCenterRatio(0.25, 0.5);
			hsStar2.scaleX = hsStar2.scaleY = Settings.STAGE_SCALE * 0.75;
			hsStar2.x = Std.int( -bgStar.width * 0.5) + pointX;
			hsStar2.y = pointY;
			hsStar1.setCenterRatio(0.75, 0.5);
			hsStar2.changePriority(5);
			arBE.push(hsStar2);
		}
		if (step > 1) {
			var hsStar3 = Settings.SLB_UI.hbe_get(bm, "starBig", 2);
			hsStar3.setCenterRatio(-0.25, 0.5);
			hsStar3.scaleX = hsStar3.scaleY = Settings.STAGE_SCALE * 0.75;
			hsStar3.x = Std.int( -bgStar.width * 0.5) + pointX;
			hsStar3.y = pointY;
			hsStar3.changePriority(5);
			arBE.push(hsStar3);
		}
		
		var lblPoint = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_50, popUp);
		lblPoint.text = levelInfo.arStepScore[step] + " " + Lang.GET_VARIOUS(TypeVarious.TVPoints);
		lblPoint.text = mt.Utf8.lowercase( lblPoint.text );
		lblPoint.x = Std.int(bgStar.width * 0.5 - lblPoint.textWidth - 10 * Settings.STAGE_SCALE) + pointX;
		lblPoint.y = Std.int(-lblPoint.textHeight * 0.5) + pointY;
		arHS.push(lblPoint);
	}
	
	override function unregister() {
		btnPlay.destroy();
		btnPlay = null;
		
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
	}
}
