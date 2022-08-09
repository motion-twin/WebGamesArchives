package process.popup;

import Common;
import Protocol;

import process.popup.BasePopup;
import data.Settings;
import data.LevelDesign;
import data.DataManager;
import manager.SoundManager;
import ui.Button;
import data.Lang;

/**
 * ...
 * @author Tipyx
 */
class Pause extends BasePopup
{
	public static var ME	: Pause;

	var btnResume		: Button;
	var btnMusic		: Button;
	var btnSFX			: Button;
	var btnHint			: Button;
	var btnMobo			: Button;
	var btnQuit			: Button;
	var btnGamecenter   : Button;
	var btnLogout		: Button;

	var offset			: Int;

	public function new(hparent:mt.deepnight.deprecated.HProcess) {
		ME = this;

		mt.device.EventTracker.view("ui.Pause");

		btnResume = new Button("btGreen", data.Lang.GET_BUTTON(TypeButton.TBResume), function () {
			if (!isTweening) {
				animEnd(function() {
					process.ProcessManager.ME.hidePause(hparent, this);
				});
			}
		});

		btnMusic = new Button("btOrange", "", function () {
			if (!isTweening) {
				if ( LevelDesign.USER_DATA.flags.has( UserFlags.UFMusic) ) {
					LevelDesign.USER_DATA.flags.unset( UserFlags.UFMusic );
					DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateMusic(false));
					btnMusic.setLbl(data.Lang.GET_BUTTON(TypeButton.TBMusic) + " : OFF");

				}
				else {
					LevelDesign.USER_DATA.flags.set( UserFlags.UFMusic );
					DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateMusic(true));
					btnMusic.setLbl(data.Lang.GET_BUTTON(TypeButton.TBMusic) + " : ON");
				}
				SoundManager.SET_VOLUME();
			}
		});

		if (Common.HAS_FLAG(LevelDesign.USER_DATA, UserFlags.UFMusic))
			btnMusic.setLbl(data.Lang.GET_BUTTON(TypeButton.TBMusic) + " : ON");
		else
			btnMusic.setLbl(data.Lang.GET_BUTTON(TypeButton.TBMusic) + " : OFF");

		btnSFX = new Button("btOrange", "", function () {
			if (!isTweening) {
				if (Common.HAS_FLAG(LevelDesign.USER_DATA, UserFlags.UFSFX)) {
					Common.SET_FLAG(LevelDesign.USER_DATA, UserFlags.UFSFX, false);
					DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateSFX(false));
					btnSFX.setLbl(data.Lang.GET_BUTTON(TypeButton.TBSound) + " : OFF");
				}
				else {
					Common.SET_FLAG(LevelDesign.USER_DATA, UserFlags.UFSFX, true);
					DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateSFX(true));
					btnSFX.setLbl(data.Lang.GET_BUTTON(TypeButton.TBSound) + " : ON");
				}
				SoundManager.SET_VOLUME();
			}
		});

		if (Common.HAS_FLAG(LevelDesign.USER_DATA, UserFlags.UFSFX))
			btnSFX.setLbl(data.Lang.GET_BUTTON(TypeButton.TBSound) + " : ON");
		else
			btnSFX.setLbl(data.Lang.GET_BUTTON(TypeButton.TBSound) + " : OFF");

		btnHint = new Button("btOrange", "", function () {
			if (!isTweening) {
				if (Common.HAS_FLAG(LevelDesign.USER_DATA, UserFlags.UFHint)) {
					Common.SET_FLAG(LevelDesign.USER_DATA, UserFlags.UFHint, false);
					DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateHint(false));
					btnHint.setLbl(data.Lang.GET_BUTTON(TypeButton.TBHint) + " : OFF");
					if (Game.ME != null)
						Game.ME.hideHint();
				}
				else {
					Common.SET_FLAG(LevelDesign.USER_DATA, UserFlags.UFHint, true);
					DataManager.DO_PROTOCOL(ProtocolCom.DoUpdateHint(true));
					btnHint.setLbl(data.Lang.GET_BUTTON(TypeButton.TBHint) + " : ON");
				}
				//SoundManager.SET_VOLUME();
			}
		});

		if (Common.HAS_FLAG(LevelDesign.USER_DATA, UserFlags.UFHint))
			btnHint.setLbl(data.Lang.GET_BUTTON(TypeButton.TBHint) + " : ON");
		else
			btnHint.setLbl(data.Lang.GET_BUTTON(TypeButton.TBHint) + " : OFF");

		btnMobo = new Button("btOrange", data.Lang.GET_BUTTON(TypeButton.TBMobo), function () {
			if (!isTweening) {
				#if ios
					var link = "https://itunes.apple.com/album/rockfaller-journey-ost-single/id994048281#";
				#elseif android
					var link = "https://play.google.com/store/music/album/Elmobo_Rockfaller_Journey_OST?id=Bp6mqinuo5vru7ay6ljdqrowz7m";
				#else
					var link = "https://elmobo.bandcamp.com/album/rockfaller-journey";
				#end
				var urlRequest:openfl.net.URLRequest = new openfl.net.URLRequest(link);
				openfl.Lib.getURL(urlRequest, "_");
				mt.device.EventTracker.track("clickBtn", "Mobo music");
			}
		});

		btnQuit = new Button("btRed", data.Lang.GET_BUTTON(TypeButton.TBGiveUp), function () {
			if (!isTweening) {
				isTweening = true;
				DataManager.SEND_GAMEDATA(Game.ME.levelInfo.level, Game.ME.score.get(), false, true, Game.ME.score.bug || Game.ME.movesLeft.bug);
				process.ProcessManager.ME.goTo(Game.ME, process.Levels, [Game.ME.levelInfo.level, false]);
				mt.device.EventTracker.track("clickBtn", "Give Up");
			}
		});
		
		var gcName = mt.device.GameCenter.name();
		if( gcName == null )
			gcName = "";
		btnGamecenter = new Button("btGreen", mt.Utf8.uppercase(gcName),  function(){
			if( mt.device.GameCenter.isLogged() ){
				mt.device.GameCenter.showAchievements();
			}else{
				mt.device.GameCenter.connect(function(success){
					if( success )
						onClose();
				});
			}
		});

		btnLogout = new Button((mt.device.User.isLogged() ? "btRed" : "btGreen"), data.Lang.GET_BUTTON(mt.device.User.isLogged() ? TypeButton.TBLogOut : TypeButton.TBLogIn), function () {
			if (!isTweening) {
				isTweening = true;
				
			#if mBase
				if (mt.device.User.isLogged())
					mt.device.User.logout();
				else
			#end
					mt.device.User.login();
				
				destroy();
			}
		});
		
	#if standalone
		if (mt.device.User.isLogged())
			btnLogout.visible = false;
	#end

		super(hparent, SizePopUp.SPUNormal);

		if (Levels.ME != null) {
			btnResume.visible = false;
			btnQuit.visible = false;

			if( !mt.device.GameCenter.isAvailable() )
				btnGamecenter.visible = false;
		}
		else {
			btnLogout.visible = false;
			btnMobo.visible = false;
			btnGamecenter.visible = false;			
		}
		

		onClose = close;

		inter.onClick = onClickBlackBG;

		popUp.add(btnResume, 2);
		popUp.add(btnMusic, 2);
		popUp.add(btnSFX, 2);
		popUp.add(btnHint, 2);
		popUp.add(btnMobo, 2);
		popUp.add(btnGamecenter, 2);
		popUp.add(btnLogout, 2);
		popUp.add(btnQuit, 2);
	}

	function close() {
		animEnd(function() {
			process.ProcessManager.ME.hidePause(hparent, this);
		});
	}

	function onClickBlackBG(e) {
		if (!isTweening && (root.mouseY < popUp.y || root.mouseY > popUp.y + heiBG) && isCome)
			onClose();
	}

	override function init() {
		if (Game.ME != null)
			textLabel = Lang.GET_POPUP_TITLE(TypePopUp.TPLevel) + " " + Game.ME.levelInfo.level;
		else
			textLabel = Lang.GET_POPUP_TITLE(TypePopUp.TPOptions);
		
		super.init();

		offset = Std.int(heiBG / 10);

	// BTN
		#if mBase
		if (Game.ME == null && mt.device.User.isLogged()) {
			var lblLogged = new h2d.Text(Settings.FONT_BENCH_NINE_90);
			lblLogged.maxWidth = Settings.STAGE_WIDTH * 0.9;
			lblLogged.textAlign = Center;
			lblLogged.text = Lang.GET_VARIOUS(TypeVarious.TVLoggedAs) + " " + mt.device.User.getName();
			lblLogged.x = Std.int((Settings.STAGE_WIDTH - lblLogged.maxWidth) * 0.5);
			lblLogged.y = Std.int(offset);
			arHS.push(lblLogged);
			popUp.addChild(lblLogged);
		}
		#end
	
		btnResume.resize();
		btnResume.x = Std.int((Settings.STAGE_WIDTH - btnResume.w) / 2 );
		btnResume.y = Std.int(offset * 4);

		btnMusic.resize();
		btnMusic.scaleX = btnMusic.scaleY = 0.75;
		btnMusic.x = Std.int(Settings.STAGE_WIDTH * 0.49 - btnMusic.w * btnMusic.scaleX);
		btnMusic.y = Std.int(offset * 5.5);

		btnSFX.resize();
		btnSFX.scaleX = btnSFX.scaleY = 0.75;
		btnSFX.x = Std.int(Settings.STAGE_WIDTH * 0.51);
		btnSFX.y = Std.int(offset * 5.5);

		btnHint.resize();
		btnHint.x = Std.int((Settings.STAGE_WIDTH - btnHint.w) / 2 );
		btnHint.y = Std.int(offset * 7);

		btnMobo.resize();
		btnMobo.x = Std.int((Settings.STAGE_WIDTH - btnMobo.w) / 2 );

		btnLogout.resize();
		btnLogout.x = Std.int((Settings.STAGE_WIDTH - btnLogout.w) / 2 );

		btnGamecenter.resize();
		btnGamecenter.x = Std.int((Settings.STAGE_WIDTH - btnGamecenter.w) / 2 );


		btnQuit.resize();
		btnQuit.x = Std.int((Settings.STAGE_WIDTH - btnQuit.w) / 2 );
		btnQuit.y = Std.int(offset * 8.5);

	// STARS
		if (Game.ME != null) {
			setPoint(0, Std.int(Settings.STAGE_WIDTH * 0.5), Std.int(offset * 1));

			setPoint(1, Std.int(Settings.STAGE_WIDTH * 0.5), Std.int(offset * 2));

			setPoint(2, Std.int(Settings.STAGE_WIDTH * 0.5), Std.int(offset * 3));
		}
		else {
			btnMusic.y = btnSFX.y = Std.int(offset * 2.5);
			btnHint.y = Std.int(offset * 4);
			btnMobo.y = Std.int(offset * 5.5);
			btnGamecenter.y = Std.int(offset * 7);
			btnLogout.y = Std.int(offset * 8.5);
		}
	}

	function setPoint(step:Int, pointX:Int, pointY:Int) {
		var bgStar = Settings.SLB_UI.hbe_get(bm, "pointBg");
		bgStar.scaleX = bgStar.scaleY = Settings.STAGE_SCALE;
		bgStar.setCenterRatio(0.5, 0.5);
		bgStar.x = pointX;
		bgStar.y = pointY;
		bgStar.changePriority(6);
		arBE.push(bgStar);

		var hsStar1 = Settings.SLB_UI.hbe_get(bm, "starBig");
		hsStar1.setCenterRatio(0.5, 0.5);
		hsStar1.scaleX = hsStar1.scaleY = Settings.STAGE_SCALE * 0.5;
		hsStar1.x = Std.int( -bgStar.width * 0.5) + pointX;
		hsStar1.y = pointY;
		hsStar1.changePriority(5);
		arBE.push(hsStar1);

		if (step > 0) {
			var hsStar2 = Settings.SLB_UI.hbe_get(bm, "starBig");
			hsStar2.setCenterRatio(0.25, 0.5);
			hsStar2.scaleX = hsStar2.scaleY = Settings.STAGE_SCALE * 0.6;
			hsStar2.x = Std.int( -bgStar.width * 0.5) + pointX;
			hsStar2.y = pointY;
			hsStar1.setCenterRatio(0.75, 0.5);
			hsStar2.changePriority(5);
			arBE.push(hsStar2);
		}
		if (step > 1) {
			var hsStar3 = Settings.SLB_UI.hbe_get(bm, "starBig");
			hsStar3.setCenterRatio(-0.25, 0.5);
			hsStar3.scaleX = hsStar3.scaleY = Settings.STAGE_SCALE * 0.7;
			hsStar3.x = Std.int( -bgStar.width * 0.55) + pointX;
			hsStar3.y = pointY;
			hsStar3.changePriority(5);
			arBE.push(hsStar3);
		}

		var lblPoint = new h2d.Text(Settings.FONT_BENCH_NINE_BMF_50, popUp);
		lblPoint.text = Game.ME.levelInfo.arStepScore[step] + " " + Lang.GET_VARIOUS(TypeVarious.TVPoints);
		lblPoint.text = lblPoint.text.toLowerCase();
		lblPoint.x = Std.int(bgStar.width * 0.5 - lblPoint.textWidth - 10 * Settings.STAGE_SCALE) + pointX;
		lblPoint.y = Std.int(-lblPoint.textHeight * 0.5) + pointY;
		arHS.push(lblPoint);
	}

	override function unregister() {
		btnResume.destroy();
		btnResume = null;

		btnMusic.destroy();
		btnMusic = null;

		btnSFX.destroy();
		btnSFX = null;

		btnHint.destroy();
		btnHint = null;

		btnMobo.destroy();
		btnMobo = null;

		btnLogout.destroy();
		btnLogout = null;

		btnQuit.destroy();
		btnQuit = null;

		btnGamecenter.destroy();
		btnGamecenter = null;

		ME = null;
		
		super.unregister();
	}
}
